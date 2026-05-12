import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { prisma } from '@/lib/prisma'

// ---------- Types ----------

export interface MetricasHoteleirasPorImovel {
  id: string
  nome: string
  occupancyPct: number
  revPar: number
  adr: number
  rentCoverage: number
  nQuartos: number
}

export interface MetricasHoteleirasMetricas {
  occupancyEffectivePct: number
  revPar: number
  adr: number
  rentCoverageRatio: number
  collectionRate: number | null
}

export interface MetricasHoteleirasYoY {
  occupancyEffectivePctAnterior: number
  occupancyDelta: number
  revParAnterior: number
  revParDeltaPct: number
  adrAnterior: number
  adrDeltaPct: number
  rentCoverageRatioAnterior: number
  rentCoverageDeltaPct: number
  collectionRateAnterior: number | null
  collectionRateDeltaPct: number | null
}

export interface MetricasHoteleirasResponse {
  anoLectivoAtual: string
  metricas: MetricasHoteleirasMetricas
  yoy: MetricasHoteleirasYoY
  porImovel: MetricasHoteleirasPorImovel[]
}

// ---------- Helpers ----------

function toNum(v: unknown): number {
  if (v === null || v === undefined) return 0
  return Number(v)
}

/**
 * Ano lectivo: 1 Setembro a 31 Agosto.
 * Se hoje >= 1 Setembro, ano lectivo = Set/anoCivil → Ago/anoCivil+1.
 * Senao ano lectivo = Set/anoCivil-1 → Ago/anoCivil.
 */
function getAnoLectivoBoundaries(ref: Date): { start: Date; end: Date; label: string } {
  const m = ref.getMonth() // 0-indexed
  const y = ref.getFullYear()
  const startYear = m >= 8 ? y : y - 1 // Set = 8
  const start = new Date(startYear, 8, 1) // 1 Set
  const end = new Date(startYear + 1, 8, 1) // 1 Set ano seguinte (exclusivo)
  const label = `${startYear}/${String((startYear + 1) % 100).padStart(2, '0')}`
  return { start, end, label }
}

function deltaPct(novo: number, antigo: number): number {
  if (antigo === 0) return novo === 0 ? 0 : 100
  return ((novo - antigo) / antigo) * 100
}

interface ReceitaCustosResult {
  receita: number
  custosRDA: number
  receitaPorImovel: Map<string, number>
  custosRDAPorImovel: Map<string, number>
}

async function computeReceitaECustos(
  start: Date,
  end: Date,
  rdaRubricaId: string,
): Promise<ReceitaCustosResult> {
  // Receita: classificacoes confirmadas (RECEITA) + lancamentos manuais (RECEITA)
  // Custos RDA: classificacoes confirmadas + lancamentos manuais com rubrica RDA

  const [faturaClassificacoes, lancamentos] = await Promise.all([
    prisma.faturaClassificacao.findMany({
      where: {
        confirmado: true,
        fatura: { dataFatura: { gte: start, lt: end } },
      },
      include: { fatura: true, rubrica: true },
    }),
    prisma.lancamentoManual.findMany({
      where: { dataDoc: { gte: start, lt: end } },
      include: { rubrica: true },
    }),
  ])

  let receita = 0
  let custosRDA = 0
  const receitaPorImovel = new Map<string, number>()
  const custosRDAPorImovel = new Map<string, number>()

  for (const fc of faturaClassificacoes) {
    const valor = fc.valorAtribuido ? toNum(fc.valorAtribuido) : toNum(fc.fatura.totalComIva)
    if (fc.rubrica.tipo === 'RECEITA') {
      receita += valor
      receitaPorImovel.set(fc.imovelId, (receitaPorImovel.get(fc.imovelId) ?? 0) + valor)
    } else if (fc.rubricaId === rdaRubricaId) {
      custosRDA += valor
      custosRDAPorImovel.set(fc.imovelId, (custosRDAPorImovel.get(fc.imovelId) ?? 0) + valor)
    }
  }

  for (const lm of lancamentos) {
    const valor = toNum(lm.totalComIva)
    if (lm.rubrica.tipo === 'RECEITA') {
      receita += valor
      receitaPorImovel.set(lm.imovelId, (receitaPorImovel.get(lm.imovelId) ?? 0) + valor)
    } else if (lm.rubricaId === rdaRubricaId) {
      custosRDA += valor
      custosRDAPorImovel.set(lm.imovelId, (custosRDAPorImovel.get(lm.imovelId) ?? 0) + valor)
    }
  }

  return { receita, custosRDA, receitaPorImovel, custosRDAPorImovel }
}

// ---------- Handler ----------

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const hoje = new Date()
    const atual = getAnoLectivoBoundaries(hoje)
    // Ano lectivo anterior: simplesmente desloca 1 ano para trás
    const startAnterior = new Date(atual.start.getFullYear() - 1, 8, 1)
    const endAnterior = new Date(atual.end.getFullYear() - 1, 8, 1)

    // RDA rubrica id
    const rdaRubrica = await prisma.rubrica.findUnique({ where: { codigo: 'RDA' } })
    const rdaRubricaId = rdaRubrica?.id ?? ''

    // Imoveis activos com suas fracoes — exclui centros de custo (GERAL/PESSOAL)
    const imoveisDb = await prisma.imovel.findMany({
      where: { ativo: true, tipo: { notIn: ['GERAL', 'PESSOAL'] } },
      include: {
        fracoes: { select: { id: true, estado: true } },
      },
      orderBy: { codigo: 'asc' },
    })

    // Numero total de quartos (todas as fracoes de imoveis activos)
    const nQuartosTotal = imoveisDb.reduce((s, im) => s + im.fracoes.length, 0)

    // Quartos-meses ocupados:
    // Simplificacao: se a fracao tem estado='OCUPADO', conta 12 meses no ano corrente.
    // TODO: melhorar com base em contratos historicos quando houver tabela de historico de ocupacao.
    const quartosMesesOcupadosAtual = imoveisDb.reduce(
      (s, im) => s + im.fracoes.filter((f) => f.estado === 'OCUPADO').length * 12,
      0,
    )

    const [atualResult, anteriorResult] = await Promise.all([
      computeReceitaECustos(atual.start, atual.end, rdaRubricaId),
      computeReceitaECustos(startAnterior, endAnterior, rdaRubricaId),
    ])

    // ---------- Metricas globais (ano atual) ----------
    const denomQuartosMeses = nQuartosTotal * 12
    const occupancyEffectivePct = denomQuartosMeses > 0
      ? (quartosMesesOcupadosAtual / denomQuartosMeses) * 100
      : 0
    const revPar = denomQuartosMeses > 0 ? atualResult.receita / denomQuartosMeses : 0
    const adr = quartosMesesOcupadosAtual > 0 ? atualResult.receita / quartosMesesOcupadosAtual : 0
    const rentCoverageRatio = atualResult.custosRDA > 0
      ? atualResult.receita / Math.abs(atualResult.custosRDA)
      : 0

    // TODO: collectionRate requer dados de cobrancas/pagamentos efectivos vs faturado.
    // Sem tabela de pagamentos por contrato, devolve null por agora.
    const collectionRate: number | null = null

    // ---------- YoY (ano anterior — proxy: ocupacao actual aplicada a receita anterior) ----------
    // TODO: ocupacao historica nao esta registada; uso proxy = ocupacao actual.
    const occupancyAnteriorPct = occupancyEffectivePct
    const quartosMesesOcupadosAnterior = quartosMesesOcupadosAtual
    const revParAnterior = denomQuartosMeses > 0 ? anteriorResult.receita / denomQuartosMeses : 0
    const adrAnterior = quartosMesesOcupadosAnterior > 0
      ? anteriorResult.receita / quartosMesesOcupadosAnterior
      : 0
    const rentCoverageAnterior = anteriorResult.custosRDA > 0
      ? anteriorResult.receita / Math.abs(anteriorResult.custosRDA)
      : 0

    const yoy: MetricasHoteleirasYoY = {
      occupancyEffectivePctAnterior: occupancyAnteriorPct,
      occupancyDelta: occupancyEffectivePct - occupancyAnteriorPct, // pp
      revParAnterior,
      revParDeltaPct: deltaPct(revPar, revParAnterior),
      adrAnterior,
      adrDeltaPct: deltaPct(adr, adrAnterior),
      rentCoverageRatioAnterior: rentCoverageAnterior,
      rentCoverageDeltaPct: deltaPct(rentCoverageRatio, rentCoverageAnterior),
      collectionRateAnterior: null,
      collectionRateDeltaPct: null,
    }

    // ---------- Por imóvel ----------
    const porImovel: MetricasHoteleirasPorImovel[] = imoveisDb.map((im) => {
      const nQuartos = im.fracoes.length
      const quartosMesesOcup = im.fracoes.filter((f) => f.estado === 'OCUPADO').length * 12
      const denomIm = nQuartos * 12
      const receitaIm = atualResult.receitaPorImovel.get(im.id) ?? 0
      const custosRDAIm = atualResult.custosRDAPorImovel.get(im.id) ?? 0
      return {
        id: im.id,
        nome: im.nome,
        occupancyPct: denomIm > 0 ? (quartosMesesOcup / denomIm) * 100 : 0,
        revPar: denomIm > 0 ? receitaIm / denomIm : 0,
        adr: quartosMesesOcup > 0 ? receitaIm / quartosMesesOcup : 0,
        rentCoverage: custosRDAIm > 0 ? receitaIm / Math.abs(custosRDAIm) : 0,
        nQuartos,
      }
    })

    const response: MetricasHoteleirasResponse = {
      anoLectivoAtual: atual.label,
      metricas: {
        occupancyEffectivePct,
        revPar,
        adr,
        rentCoverageRatio,
        collectionRate,
      },
      yoy,
      porImovel,
    }

    return Response.json(response)
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) {
      return Response.json({ error: (e as Error).message }, { status: 403 })
    }
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
