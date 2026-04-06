import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

// ---------- helpers ----------

function toNum(v: unknown): number {
  if (v === null || v === undefined) return 0
  return Number(v)
}

function pct(numerator: number, denominator: number): number {
  return denominator !== 0 ? (numerator / denominator) * 100 : 0
}

function cfgNum(configs: Record<string, string>, key: string, fallback: number): number {
  const v = configs[key]
  return v !== undefined ? Number(v) : fallback
}

function cfgBool(configs: Record<string, string>, key: string, fallback: boolean): boolean {
  const v = configs[key]
  if (v === undefined) return fallback
  return v === 'true' || v === '1'
}

// IRC PME calculation
function calcIrc(
  resultadoAntesImpostos: number,
  derramaPct: number,
  regimePme: boolean,
  taxaPme: number,
  taxaNormal: number,
  limitePme: number,
) {
  const mc = Math.max(resultadoAntesImpostos, 0) // materia coletavel

  let coleta: number
  if (regimePme) {
    coleta = Math.min(mc, limitePme) * (taxaPme / 100) + Math.max(mc - limitePme, 0) * (taxaNormal / 100)
  } else {
    coleta = mc * (taxaNormal / 100)
  }

  const derrama = mc * (derramaPct / 100)
  const ircTotal = coleta + derrama
  const taxaEfetiva = pct(ircTotal, resultadoAntesImpostos)

  return { mc, coleta, derrama, ircTotal, taxaEfetiva }
}

// ---------- main handler ----------

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const { searchParams } = req.nextUrl
    const ano = searchParams.get('ano') ? Number(searchParams.get('ano')) : new Date().getFullYear()

    const dateStart = new Date(ano, 0, 1)
    const dateEnd = new Date(ano + 1, 0, 1)

    // 1. Load configurations
    const configRows = await prisma.configuracao.findMany()
    const configMap: Record<string, string> = {}
    for (const r of configRows) configMap[r.chave] = r.valor

    const derramaMunicipal = cfgNum(configMap, 'derramaMunicipal', 1.5)
    const regimePme = cfgBool(configMap, 'regimePme', true)
    const taxaIrcPme = cfgNum(configMap, 'taxaIrcPme', 17)
    const taxaIrcNormal = cfgNum(configMap, 'taxaIrcNormal', 21)
    const limitePme = cfgNum(configMap, 'limitePme', 50000)
    const taxaRetencao = cfgNum(configMap, 'taxaRetencao', 25)

    // 2. Load active properties with fracoes
    const imoveisDb = await prisma.imovel.findMany({
      where: { ativo: true },
      include: {
        fracoes: { select: { id: true, nome: true, renda: true, estado: true, nifInquilino: true, dataEntradaMercado: true }, orderBy: { nome: 'asc' } },
      },
      orderBy: { codigo: 'asc' },
    })

    // 3. Load rubricas
    const rubricas = await prisma.rubrica.findMany()
    const rubricaMap = new Map(rubricas.map((r) => [r.id, r]))

    // Find the RDA rubrica id
    const rdaRubrica = rubricas.find((r) => r.codigo === 'RDA')
    const rdaRubricaId = rdaRubrica?.id ?? ''

    // 4. Load classified invoices in period
    // Expand range to include Dec of previous year (for Jan revenue — accrual basis)
    const dateStartExpanded = new Date(ano - 1, 11, 1) // 1 Dec year-1
    const faturaClassificacoes = await prisma.faturaClassificacao.findMany({
      where: {
        fatura: { dataFatura: { gte: dateStartExpanded, lt: dateEnd } },
      },
      include: { fatura: true },
    })

    // 5. Load manual entries in period (same expanded range)
    const lancamentos = await prisma.lancamentoManual.findMany({
      where: { dataDoc: { gte: dateStartExpanded, lt: dateEnd } },
    })

    // ---------- Build per-property analysis ----------

    // Structures to accumulate per imovel
    interface MonthBucket { receita: number; custos: number }
    interface RubricaBucket { rubricaId: string; rubricaNome: string; valor: number }

    const imoveisResult = imoveisDb.map((im) => {
      let receita = 0
      let rendaPaga = 0
      let custosOperacionais = 0
      const meses: MonthBucket[] = Array.from({ length: 12 }, () => ({ receita: 0, custos: 0 }))
      const custosPorRubricaMap = new Map<string, number>()

      // -- FaturaClassificacao entries for this property --
      for (const fc of faturaClassificacoes) {
        if (fc.imovelId !== im.id) continue
        const rub = rubricaMap.get(fc.rubricaId)
        if (!rub) continue
        const valor = toNum(fc.fatura.totalComIva)
        const dataFatura = new Date(fc.fatura.dataFatura)
        const faturaAno = dataFatura.getFullYear()
        const mesIdx = dataFatura.getMonth()

        if (rub.tipo === 'RECEITA') {
          // Regime de acréscimo: receita pertence ao mês seguinte (mês do serviço)
          // Fatura de Dez do ano anterior → Janeiro deste ano (mesRef = 0)
          // Fatura de Dez deste ano → Janeiro do ano seguinte (EXCLUIR)
          const mesReferencia = mesIdx + 1
          if (faturaAno === ano && mesIdx === 11) continue // Dez deste ano → pertence ao ano seguinte
          if (faturaAno === ano - 1 && mesIdx === 11) {
            // Dez do ano anterior → Janeiro deste ano
            receita += valor
            meses[0].receita += valor
          } else if (faturaAno === ano && mesReferencia <= 11) {
            receita += valor
            meses[mesReferencia].receita += valor
          }
        } else {
          // GASTO — só incluir se pertence ao ano seleccionado
          if (faturaAno !== ano) continue
          if (fc.rubricaId === rdaRubricaId) {
            rendaPaga += valor
          } else {
            custosOperacionais += valor
          }
          meses[mesIdx].custos += valor
          custosPorRubricaMap.set(fc.rubricaId, (custosPorRubricaMap.get(fc.rubricaId) ?? 0) + valor)
        }
      }

      // -- LancamentoManual entries for this property --
      for (const lm of lancamentos) {
        if (lm.imovelId !== im.id) continue
        const rub = rubricaMap.get(lm.rubricaId)
        if (!rub) continue
        const valor = toNum(lm.totalComIva)
        const dataDoc = new Date(lm.dataDoc)
        const lmAno = dataDoc.getFullYear()
        const mesIdx = dataDoc.getMonth()

        if (rub.tipo === 'RECEITA') {
          // Mesmo regime de acréscimo
          const mesReferencia = mesIdx + 1
          if (lmAno === ano && mesIdx === 11) continue // Dez deste ano → ano seguinte
          if (lmAno === ano - 1 && mesIdx === 11) {
            receita += valor
            meses[0].receita += valor
          } else if (lmAno === ano && mesReferencia <= 11) {
            receita += valor
            meses[mesReferencia].receita += valor
          }
        } else {
          // Gastos — só do ano seleccionado
          if (lmAno !== ano) continue
          if (lm.rubricaId === rdaRubricaId) {
            rendaPaga += valor
          } else {
            custosOperacionais += valor
          }
          meses[mesIdx].custos += valor
          custosPorRubricaMap.set(lm.rubricaId, (custosPorRubricaMap.get(lm.rubricaId) ?? 0) + valor)
        }
      }

      const custoTotal = rendaPaga + custosOperacionais
      const margemBruta = receita - rendaPaga
      const resultadoLiquido = receita - custoTotal
      const valorPatrimonial = im.valorPatrimonial !== null ? toNum(im.valorPatrimonial) : null
      const areaMt2 = im.areaMt2 !== null ? toNum(im.areaMt2) : null

      // Potencial por fracao — baseado na receita real (media das faturas emitidas × 12)
      const receitaPorFracao = new Map<string, { total: number; count: number }>()
      for (const fc of faturaClassificacoes) {
        if (fc.imovelId !== im.id || !fc.fracaoId) continue
        const rub = rubricaMap.get(fc.rubricaId)
        if (!rub || rub.tipo !== 'RECEITA') continue
        const entry = receitaPorFracao.get(fc.fracaoId) || { total: 0, count: 0 }
        entry.total += toNum(fc.fatura.totalComIva)
        entry.count += 1
        receitaPorFracao.set(fc.fracaoId, entry)
      }
      // Tambem contar lancamentos manuais de receita por fracao
      for (const lm of lancamentos) {
        if (lm.imovelId !== im.id || !lm.fracaoId) continue
        const rub = rubricaMap.get(lm.rubricaId)
        if (!rub || rub.tipo !== 'RECEITA') continue
        const entry = receitaPorFracao.get(lm.fracaoId) || { total: 0, count: 0 }
        entry.total += toNum(lm.totalComIva)
        entry.count += 1
        receitaPorFracao.set(lm.fracaoId, entry)
      }

      // Meses de referencia: ano actual = meses decorridos - 1 (renda em avanço), anos passados = 12
      const now = new Date()
      const mesesRef = ano < now.getFullYear() ? 12 : Math.max(now.getMonth(), 1) // meses - 1

      // Occupancy + potencial from fracoes
      const fracoes = im.fracoes.map((f) => {
        const recData = receitaPorFracao.get(f.id)
        const rendaMedia = recData && recData.count > 0 ? recData.total / recData.count : toNum(f.renda)

        // Meses disponiveis: desde entrada no mercado (ou primeira fatura como fallback)
        let mesesDisponiveis = mesesRef
        const entradaMercado = f.dataEntradaMercado ? new Date(f.dataEntradaMercado) : null
        if (entradaMercado && entradaMercado.getFullYear() <= ano) {
          if (entradaMercado.getFullYear() === ano) {
            // Entrou no mercado este ano — contar desde o mês de entrada
            const mesEntrada = entradaMercado.getMonth() // 0-based
            mesesDisponiveis = Math.max(mesesRef - mesEntrada, 0)
          } else {
            // Entrou em ano anterior — disponível o ano todo
            mesesDisponiveis = mesesRef
          }
        } else if (!entradaMercado && recData && recData.count > 0) {
          // Sem data de entrada — usar primeira fatura como fallback (já está implícito no count)
          mesesDisponiveis = mesesRef
        }

        const potencial = rendaMedia * mesesDisponiveis
        const receitaReal = recData?.total || 0
        const mesesOcupado = Math.min(recData?.count || 0, mesesDisponiveis)
        return {
          id: f.id,
          nome: f.nome,
          renda: toNum(f.renda),
          rendaMedia,
          estado: f.estado,
          nifInquilino: f.nifInquilino,
          dataEntradaMercado: f.dataEntradaMercado,
          faturas: recData?.count || 0,
          mesesOcupado,
          mesesDisponiveis,
          mesesRef,
          receitaReal,
          potencialAnual: potencial,
          pctPotencial: potencial > 0 ? Math.min((receitaReal / potencial) * 100, 100) : 0,
        }
      })
      const totalFracoes = fracoes.length
      // Ocupacao real: meses ocupados / meses disponiveis (ajustado por data de entrada)
      const totalMesesPossiveis = fracoes.reduce((s, f) => s + f.mesesDisponiveis, 0)
      const totalMesesOcupados = fracoes.reduce((s, f) => s + f.mesesOcupado, 0)
      const ocupacao = totalFracoes > 0
        ? { total: totalFracoes, ocupados: totalMesesOcupados, totalMeses: totalMesesPossiveis, pct: pct(totalMesesOcupados, totalMesesPossiveis) }
        : null

      // Potencial total do imovel
      const potencialAnual = fracoes.reduce((s, f) => s + f.potencialAnual, 0)
      const pctPotencial = potencialAnual > 0 ? Math.min((receita / potencialAnual) * 100, 100) : 0

      // Cost breakdown by rubrica
      const custosPorRubrica: RubricaBucket[] = []
      for (const [rubId, valor] of custosPorRubricaMap) {
        const rub = rubricaMap.get(rubId)
        custosPorRubrica.push({ rubricaId: rubId, rubricaNome: rub?.nome ?? '', valor })
      }
      custosPorRubrica.sort((a, b) => b.valor - a.valor)

      return {
        id: im.id,
        codigo: im.codigo,
        nome: im.nome,
        tipo: im.tipo,
        valorPatrimonial,
        areaMt2,
        fracoes,
        receita,
        rendaPaga,
        custosOperacionais,
        custoTotal,
        margemBruta,
        margemBrutaPct: pct(margemBruta, receita),
        resultadoLiquido,
        resultadoLiquidoPct: pct(resultadoLiquido, receita),
        ratiCobertura: rendaPaga !== 0 ? receita / rendaPaga : 0,
        yieldBruta: valorPatrimonial ? (receita / valorPatrimonial) * 100 : null,
        custoPorMt2: areaMt2 ? custoTotal / areaMt2 : null,
        ocupacao,
        potencialAnual,
        pctPotencial,
        meses: meses.map((m, i) => ({ mes: i + 1, receita: m.receita, custos: m.custos })),
        custosPorRubrica,
      }
    })

    // ---------- Global totals ----------

    const receitaTotal = imoveisResult.reduce((s, im) => s + im.receita, 0)
    const rendaPagaTotal = imoveisResult.reduce((s, im) => s + im.rendaPaga, 0)
    const custosOperacionaisTotal = imoveisResult.reduce((s, im) => s + im.custosOperacionais, 0)
    const custoTotalGlobal = rendaPagaTotal + custosOperacionaisTotal
    const margemBrutaGlobal = receitaTotal - rendaPagaTotal
    const resultadoLiquidoGlobal = receitaTotal - custoTotalGlobal

    const global = {
      receitaTotal,
      rendaPagaTotal,
      custosOperacionaisTotal,
      custoTotal: custoTotalGlobal,
      margemBruta: margemBrutaGlobal,
      margemBrutaPct: pct(margemBrutaGlobal, receitaTotal),
      resultadoLiquido: resultadoLiquidoGlobal,
      resultadoLiquidoPct: pct(resultadoLiquidoGlobal, receitaTotal),
      ratiCobertura: rendaPagaTotal !== 0 ? receitaTotal / rendaPagaTotal : 0,
    }

    // ---------- IRC estimate ----------

    const ircCalc = calcIrc(
      resultadoLiquidoGlobal,
      derramaMunicipal,
      regimePme,
      taxaIrcPme,
      taxaIrcNormal,
      limitePme,
    )

    const retencoesFeitasTotal = rendaPagaTotal * (taxaRetencao / 100)

    const irc = {
      resultadoAntesImpostos: resultadoLiquidoGlobal,
      materiaColetavel: ircCalc.mc,
      coleta: ircCalc.coleta,
      derrama: ircCalc.derrama,
      ircTotal: ircCalc.ircTotal,
      taxaEfetiva: ircCalc.taxaEfetiva,
      retencoesFeitasTotal,
    }

    // ---------- Monthly evolution ----------

    const evolucaoMensal = Array.from({ length: 12 }, (_, i) => {
      const mes = i + 1
      let receitaMes = 0
      let custosMes = 0
      for (const im of imoveisResult) {
        const m = im.meses[i]
        receitaMes += m.receita
        custosMes += m.custos
      }
      return { mes, receita: receitaMes, custos: custosMes, resultado: receitaMes - custosMes }
    })

    // Cumulative IRC
    let receitaAcum = 0
    let custosAcum = 0
    for (const m of evolucaoMensal) {
      receitaAcum += m.receita
      custosAcum += m.custos
      const resultadoAcum = receitaAcum - custosAcum
      const ircAcum = calcIrc(resultadoAcum, derramaMunicipal, regimePme, taxaIrcPme, taxaIrcNormal, limitePme)
      ;(m as typeof m & { ircAcumulado: number }).ircAcumulado = ircAcum.ircTotal
    }

    // ---------- Config block ----------

    const config = {
      derramaMunicipal,
      regimePme,
      taxaIrcPme,
      taxaIrcNormal,
      limitePme,
      taxaRetencao,
    }

    return Response.json({
      data: {
        imoveis: imoveisResult,
        global,
        irc,
        evolucaoMensal: evolucaoMensal as (typeof evolucaoMensal[number] & { ircAcumulado: number })[],
        config,
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
