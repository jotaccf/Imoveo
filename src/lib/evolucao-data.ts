import { prisma } from '@/lib/prisma'

// ----------------------------------------------------------------------------
// Helper: evolução plurianual
// ----------------------------------------------------------------------------
// Empresa subarrenda quartos a estudantes em PT. Ano lectivo (Set-Ago) é a
// agregação mais relevante para sazonalidade — Set-Jun cheio, Jul-Ago vazio.
//
// Este loader retorna 4 blocos:
//   - banner    KPI YTD com YoY
//   - anosCivis agregados Jan-Dez para comparação inter-anual
//   - anosLectivos sazonalidade por mês lectivo
//   - imoveis   small multiples + sparkline histórico
// ----------------------------------------------------------------------------

function toNum(v: unknown): number {
  if (v === null || v === undefined) return 0
  return Number(v)
}

function pct(num: number, den: number): number {
  return den !== 0 ? (num / den) * 100 : 0
}

function yoyPct(actual: number, anterior: number): number {
  if (anterior === 0) return 0
  return ((actual - anterior) / Math.abs(anterior)) * 100
}

// Set=1, Out=2, Nov=3, Dez=4, Jan=5, Fev=6, Mar=7, Abr=8, Mai=9, Jun=10, Jul=11, Ago=12
// mesCivil é 1..12 (Jan=1). Spec: (mesCivil + 4) % 12 || 12.
export function mesLectivoFromCivil(mesCivil: number): number {
  return (mesCivil + 4) % 12 || 12
}

const MES_LECTIVO_NOMES = ['Set', 'Out', 'Nov', 'Dez', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago']

export interface EvolucaoBanner {
  receitaYtd: number
  receitaYtdAnterior: number
  receitaYoyPct: number
  resultadoYtd: number
  resultadoYtdAnterior: number
  resultadoYoyPct: number
  ocupacaoActualPct: number
  ocupacaoAnoAnteriorPct: number
  ocupacaoYoyDelta: number
}

export interface AnoCivilLinha {
  ano: number
  receita: number
  custos: number
  resultado: number
  margemPct: number
}

export interface MesLectivoLinha {
  mesLectivo: number
  mesNome: string
  receita: number
  custos: number
  resultado: number
}

export interface AnoLectivoBlock {
  anoLectivo: string
  isAtual: boolean
  meses: MesLectivoLinha[]
}

export interface ImovelHistoricoLinha {
  ano: number
  margemPct: number
  receita: number
  custo: number
}

export interface ImovelEvolucao {
  id: string
  codigo: string
  nome: string
  margemActualPct: number
  deltaYoyPct: number
  historico: ImovelHistoricoLinha[]
}

export interface EvolucaoData {
  banner: EvolucaoBanner
  anosCivis: AnoCivilLinha[]
  anosLectivos: AnoLectivoBlock[]
  imoveis: ImovelEvolucao[]
}

// ----------------------------------------------------------------------------
// Estrutura interna: agregado de transações em memória
// ----------------------------------------------------------------------------

interface Transaccao {
  data: Date
  imovelId: string | null
  valor: number
  isReceita: boolean
}

async function loadTransaccoes(dateMin: Date, dateMax: Date): Promise<Transaccao[]> {
  // Faturas confirmadas (apenas tipo RECEITA ou GASTO; schema actual não tem AMBOS)
  const classificacoes = await prisma.faturaClassificacao.findMany({
    where: {
      confirmado: true,
      fatura: { dataFatura: { gte: dateMin, lt: dateMax } },
    },
    include: {
      fatura: { select: { dataFatura: true, totalComIva: true } },
      rubrica: { select: { tipo: true } },
    },
  })

  // Lancamentos manuais: alargar janela 1 mes a tras para apanhar Dez do ano anterior
  // (receitas de renda são lançadas no mês ANTERIOR ao da renda — ver shift abaixo)
  const lmDateMin = new Date(dateMin.getFullYear(), dateMin.getMonth() - 1, 1)
  const lancamentos = await prisma.lancamentoManual.findMany({
    where: { dataDoc: { gte: lmDateMin, lt: dateMax } },
    include: { rubrica: { select: { tipo: true } } },
  })

  const out: Transaccao[] = []
  for (const fc of classificacoes) {
    const tipo = fc.rubrica.tipo
    if (tipo !== 'RECEITA' && tipo !== 'GASTO') continue
    const valor = fc.valorAtribuido ? toNum(fc.valorAtribuido) : toNum(fc.fatura.totalComIva)
    out.push({
      data: new Date(fc.fatura.dataFatura),
      imovelId: fc.imovelId,
      valor,
      isReceita: tipo === 'RECEITA',
    })
  }
  for (const lm of lancamentos) {
    const tipo = lm.rubrica.tipo
    if (tipo !== 'RECEITA' && tipo !== 'GASTO') continue
    // Lancamentos manuais de RECEITA seguem regra de renda: lançamento em mês N
    // representa a renda do mês N+1 (renda cobrada em Janeiro = lançamento de Dezembro).
    // Ver analise-data.ts linhas 352-361 para padrão consistente com o dashboard.
    const dataDoc = new Date(lm.dataDoc)
    const dataEfectiva =
      tipo === 'RECEITA'
        ? new Date(dataDoc.getFullYear(), dataDoc.getMonth() + 1, 1)
        : dataDoc
    out.push({
      data: dataEfectiva,
      imovelId: lm.imovelId,
      valor: toNum(lm.totalComIva),
      isReceita: tipo === 'RECEITA',
    })
  }
  return out
}

function filterRange(txs: Transaccao[], gte: Date, lt: Date): Transaccao[] {
  return txs.filter((t) => t.data >= gte && t.data < lt)
}

function sumReceita(txs: Transaccao[]): number {
  return txs.reduce((s, t) => (t.isReceita ? s + t.valor : s), 0)
}
function sumCustos(txs: Transaccao[]): number {
  return txs.reduce((s, t) => (!t.isReceita ? s + t.valor : s), 0)
}

// ----------------------------------------------------------------------------
// Main entry
// ----------------------------------------------------------------------------

export async function loadEvolucaoData(): Promise<EvolucaoData> {
  const now = new Date()
  const anoActual = now.getFullYear()

  // Janela: 7 anos para histórico anual + ano corrente + (eventualmente) ano lectivo que arrancou em anoActual-1
  const dateMin = new Date(anoActual - 7, 0, 1)
  const dateMax = new Date(anoActual + 1, 0, 1)

  const txs = await loadTransaccoes(dateMin, dateMax)

  // -------------------- Banner KPIs (YTD vs YTD ano anterior) --------------------
  // YTD ano corrente: 1 Jan anoActual até hoje
  const ytdStart = new Date(anoActual, 0, 1)
  const ytdNow = now
  const ytdAnteriorStart = new Date(anoActual - 1, 0, 1)
  // Para comparação justa: mesmo período do ano anterior
  const ytdAnteriorEnd = new Date(anoActual - 1, now.getMonth(), now.getDate(), 23, 59, 59)

  const txsYtd = filterRange(txs, ytdStart, ytdNow)
  const txsYtdAnt = filterRange(txs, ytdAnteriorStart, ytdAnteriorEnd)

  const receitaYtd = sumReceita(txsYtd)
  const custosYtd = sumCustos(txsYtd)
  const resultadoYtd = receitaYtd - custosYtd
  const receitaYtdAnt = sumReceita(txsYtdAnt)
  const custosYtdAnt = sumCustos(txsYtdAnt)
  const resultadoYtdAnt = receitaYtdAnt - custosYtdAnt

  // Ocupação: snapshot actual (count de fracoes onde estado=OCUPADO sobre total
  // de fracoes em imóveis activos). Não há histórico temporal de estados, pelo
  // que ocupação "ano anterior" é uma aproximação igual ao actual — devolvemos
  // delta 0 e marcamos a hipótese no comentário acima.
  const fracoes = await prisma.fracao.findMany({
    where: { imovel: { ativo: true } },
    select: { estado: true },
  })
  const totalFracoes = fracoes.length
  const ocupadas = fracoes.filter((f) => f.estado === 'OCUPADO').length
  const ocupacaoActualPct = totalFracoes > 0 ? (ocupadas / totalFracoes) * 100 : 0
  const ocupacaoAnoAnteriorPct = ocupacaoActualPct
  const ocupacaoYoyDelta = 0

  const banner: EvolucaoBanner = {
    receitaYtd,
    receitaYtdAnterior: receitaYtdAnt,
    receitaYoyPct: yoyPct(receitaYtd, receitaYtdAnt),
    resultadoYtd,
    resultadoYtdAnterior: resultadoYtdAnt,
    resultadoYoyPct: yoyPct(resultadoYtd, resultadoYtdAnt),
    ocupacaoActualPct,
    ocupacaoAnoAnteriorPct,
    ocupacaoYoyDelta,
  }

  // -------------------- Anos civis (até 7 atrás, só os com dados) --------------------
  const anosCivisRaw: AnoCivilLinha[] = []
  for (let a = anoActual - 6; a <= anoActual; a++) {
    const ini = new Date(a, 0, 1)
    const fim = new Date(a + 1, 0, 1)
    const inRange = filterRange(txs, ini, fim)
    const receita = sumReceita(inRange)
    const custos = sumCustos(inRange)
    const resultado = receita - custos
    if (receita === 0 && custos === 0) continue
    anosCivisRaw.push({
      ano: a,
      receita,
      custos,
      resultado,
      margemPct: pct(resultado, receita),
    })
  }
  // Ordenado ASC (mais antigo à esquerda) para o bar chart
  anosCivisRaw.sort((a, b) => a.ano - b.ano)

  // -------------------- Anos lectivos (Set-Ago) --------------------
  // Ano lectivo X/Y começa em Set X e acaba em Ago Y+1 (exclusivo Set Y+1)
  // Ano lectivo "actual" = aquele cujo periodo Set-Ago contém today (ou já arrancou).
  // Se today >= Set anoActual -> ano lectivo actual = anoActual/anoActual+1
  // Caso contrário -> anoActual-1/anoActual
  const anoLectivoInicioActual = now.getMonth() >= 8 ? anoActual : anoActual - 1

  const anosLectivosOut: AnoLectivoBlock[] = []
  for (let inicio = anoLectivoInicioActual - 6; inicio <= anoLectivoInicioActual; inicio++) {
    const dtIni = new Date(inicio, 8, 1) // 1 Set
    const dtFim = new Date(inicio + 1, 8, 1) // 1 Set ano seguinte
    const txsLect = filterRange(txs, dtIni, dtFim)
    if (txsLect.length === 0) continue
    const meses: MesLectivoLinha[] = []
    for (let mesLect = 1; mesLect <= 12; mesLect++) {
      // mesLect 1..12 corresponde a: 1=Set inicio, 4=Dez inicio, 5=Jan inicio+1, 12=Ago inicio+1
      const mesCivil = mesLect <= 4 ? 8 + mesLect : mesLect - 5 // 0-indexed month
      const anoCivil = mesLect <= 4 ? inicio : inicio + 1
      const mIni = new Date(anoCivil, mesCivil, 1)
      const mFim = new Date(anoCivil, mesCivil + 1, 1)
      const txsMes = filterRange(txsLect, mIni, mFim)
      const receita = sumReceita(txsMes)
      const custos = sumCustos(txsMes)
      meses.push({
        mesLectivo: mesLect,
        mesNome: MES_LECTIVO_NOMES[mesLect - 1],
        receita,
        custos,
        resultado: receita - custos,
      })
    }
    const yy = String(inicio + 1).slice(2)
    anosLectivosOut.push({
      anoLectivo: `${inicio}/${yy}`,
      isAtual: inicio === anoLectivoInicioActual,
      meses,
    })
  }
  // Mais recente primeiro
  anosLectivosOut.sort((a, b) => b.anoLectivo.localeCompare(a.anoLectivo))

  // -------------------- Imoveis: histórico anual + delta YoY --------------------
  const imoveisDb = await prisma.imovel.findMany({
    where: { ativo: true },
    select: { id: true, codigo: true, nome: true },
    orderBy: { codigo: 'asc' },
  })

  const imoveisOut: ImovelEvolucao[] = imoveisDb.map((im) => {
    const historico: ImovelHistoricoLinha[] = []
    for (let a = anoActual - 6; a <= anoActual; a++) {
      const ini = new Date(a, 0, 1)
      const fim = new Date(a + 1, 0, 1)
      const txsIm = txs.filter(
        (t) => t.imovelId === im.id && t.data >= ini && t.data < fim,
      )
      const receita = sumReceita(txsIm)
      const custos = sumCustos(txsIm)
      historico.push({
        ano: a,
        margemPct: pct(receita - custos, receita),
        receita,
        custo: custos,
      })
    }
    const ultimo = historico[historico.length - 1]
    const penultimo = historico.length >= 2 ? historico[historico.length - 2] : null
    const margemActualPct = ultimo ? ultimo.margemPct : 0
    const margemAnteriorPct = penultimo ? penultimo.margemPct : 0
    // delta em pontos percentuais (diferença simples), não yoyPct
    const deltaYoyPct = margemActualPct - margemAnteriorPct

    return {
      id: im.id,
      codigo: im.codigo,
      nome: im.nome,
      margemActualPct,
      deltaYoyPct,
      historico,
    }
  })

  // Filtrar imóveis sem qualquer movimento nos últimos anos
  const imoveisComDados = imoveisOut.filter((im) =>
    im.historico.some((h) => h.receita > 0 || h.custo > 0),
  )

  // Ordenar por deltaYoyPct ASC (piores primeiro)
  imoveisComDados.sort((a, b) => a.deltaYoyPct - b.deltaYoyPct)

  return {
    banner,
    anosCivis: anosCivisRaw,
    anosLectivos: anosLectivosOut,
    imoveis: imoveisComDados,
  }
}
