import { prisma } from '@/lib/prisma'

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

// IRC PME calculation com reporte de prejuizos (Art. 52.º CIRC)
function calcIrc(
  lucroTributavel: number,
  derramaPct: number,
  regimePme: boolean,
  taxaPme: number,
  taxaNormal: number,
  limitePme: number,
  prejuizoDisponivel: number = 0,
  reportePct: number = 65,
) {
  // Dedução de prejuízos: limite 65% do lucro tributável
  const deducaoPrejuizos = lucroTributavel > 0
    ? Math.min(prejuizoDisponivel, lucroTributavel * (reportePct / 100))
    : 0
  const mc = Math.max(lucroTributavel - deducaoPrejuizos, 0)

  let coleta: number
  if (regimePme) {
    coleta = Math.min(mc, limitePme) * (taxaPme / 100) + Math.max(mc - limitePme, 0) * (taxaNormal / 100)
  } else {
    coleta = mc * (taxaNormal / 100)
  }

  // Derrama incide sobre lucro tributável (não sobre matéria colectável)
  const derrama = Math.max(lucroTributavel, 0) * (derramaPct / 100)
  const ircTotal = coleta + derrama
  const taxaEfetiva = pct(ircTotal, lucroTributavel)

  // Prejuizo a reportar para anos seguintes
  const prejuizoNovo = lucroTributavel < 0 ? Math.abs(lucroTributavel) : 0
  const prejuizoRestante = prejuizoDisponivel - deducaoPrejuizos + prejuizoNovo

  return { mc, coleta, derrama, ircTotal, taxaEfetiva, deducaoPrejuizos, prejuizoDisponivel, prejuizoRestante, lucroTributavel }
}

// ---------- Types ----------

export interface MonthData {
  mes: number
  receita: number
  custos: number
  resultado: number
  ircAcumulado: number
}

export interface ImovelAnalise {
  id: string
  codigo: string
  nome: string
  tipo: string
  valorPatrimonial: number | null
  areaMt2: number | null
  receita: number
  rendaPaga: number
  custosOperacionais: number
  custoTotal: number
  margemBruta: number
  margemBrutaPct: number
  resultadoLiquido: number
  resultadoLiquidoPct: number
  ratiCobertura: number
  yieldBruta: number | null
  custoPorMt2: number | null
  ocupacao: { total: number; ocupados: number; totalMeses: number; pct: number } | null
  potencialAnual: number
  pctPotencial: number
  meses: { mes: number; receita: number; custos: number }[]
  custosPorRubrica: { rubricaId: string; rubricaNome: string; valor: number }[]
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  fracoes: any[]
}

export interface GlobalAnalise {
  receitaTotal: number
  rendaPagaTotal: number
  custosOperacionaisTotal: number
  custoTotal: number
  margemBruta: number
  margemBrutaPct: number
  resultadoLiquido: number
  resultadoLiquidoPct: number
  ratiCobertura: number
}

export interface IrcAnalise {
  resultadoAntesImpostos: number
  materiaColetavel: number
  coleta: number
  derrama: number
  ircTotal: number
  taxaEfetiva: number
  retencoesFeitasTotal: number
  prejuizoDisponivel?: number
  deducaoPrejuizos?: number
  prejuizoRestante?: number
}

export interface ConfigAnalise {
  derramaMunicipal: number
  regimePme: boolean
  taxaIrcPme: number
  taxaIrcNormal: number
  limitePme: number
  taxaRetencao: number
}

export interface AnaliseData {
  imoveis: ImovelAnalise[]
  global: GlobalAnalise
  irc: IrcAnalise
  evolucaoMensal: MonthData[]
  config: ConfigAnalise
}

// ---------- Main data loader ----------

export async function loadAnaliseData(ano: number): Promise<AnaliseData> {
  const dateStart = new Date(ano, 0, 1)
  const dateEnd = new Date(ano + 1, 0, 1)

  // 1. Load configurations — prioridade: ConfiguracaoFiscal do ano > fallback ano mais proximo > Configuracao global > defaults
  const configFiscalAno = await prisma.configuracaoFiscal.findUnique({ where: { ano } })
  const configFiscalMaisProxima = configFiscalAno ?? await prisma.configuracaoFiscal.findFirst({
    where: { ano: { lte: ano } },
    orderBy: { ano: 'desc' },
  })

  const configRows = await prisma.configuracao.findMany()
  const configMap: Record<string, string> = {}
  for (const r of configRows) configMap[r.chave] = r.valor

  const derramaMunicipal = configFiscalMaisProxima
    ? Number(configFiscalMaisProxima.derramaMunicipal)
    : cfgNum(configMap, 'derramaMunicipal', 1.5)
  const regimePme = configFiscalMaisProxima
    ? configFiscalMaisProxima.regimePme
    : cfgBool(configMap, 'regimePme', true)
  const taxaIrcPme = configFiscalMaisProxima
    ? Number(configFiscalMaisProxima.taxaIrcPme)
    : cfgNum(configMap, 'taxaIrcPme', 17)
  const taxaIrcNormal = configFiscalMaisProxima
    ? Number(configFiscalMaisProxima.taxaIrcNormal)
    : cfgNum(configMap, 'taxaIrcNormal', 21)
  const limitePme = configFiscalMaisProxima
    ? Number(configFiscalMaisProxima.limitePme)
    : cfgNum(configMap, 'limitePme', 50000)
  const taxaRetencao = configFiscalMaisProxima
    ? Number(configFiscalMaisProxima.taxaRetencao)
    : cfgNum(configMap, 'taxaRetencao', 25)
  const reportePrejuizoPct = configFiscalMaisProxima
    ? Number(configFiscalMaisProxima.reportePrejuizoPct)
    : 65

  // 1b. Calcular prejuízos acumulados de anos anteriores
  const anosAnteriores = await prisma.fatura.findMany({
    where: { dataFatura: { lt: dateStart } },
    select: { dataFatura: true },
    distinct: ['dataFatura'],
  })
  const anosUnicos = new Set<number>()
  for (const f of anosAnteriores) anosUnicos.add(f.dataFatura.getFullYear())
  // Calcular prejuizos por ano (recursivo conceptualmente, aqui linear)
  let prejuizoDisponivel = 0
  const anosOrdenados = Array.from(anosUnicos).sort()
  for (const a of anosOrdenados) {
    const startA = new Date(a, 0, 1)
    const endA = new Date(a + 1, 0, 1)
    const fatA = await prisma.fatura.findMany({
      where: { dataFatura: { gte: startA, lt: endA } },
      include: { classificacoes: { include: { rubrica: true } } },
    })
    let receita = 0, gasto = 0
    for (const f of fatA) {
      for (const c of f.classificacoes) {
        const v = c.valorAtribuido ? Number(c.valorAtribuido) : Number(f.totalComIva)
        if (c.rubrica.tipo === 'RECEITA') receita += v
        else gasto += v
      }
    }
    const lt = receita - gasto
    if (lt < 0) {
      prejuizoDisponivel += Math.abs(lt)
    } else {
      const deducao = Math.min(prejuizoDisponivel, lt * (reportePrejuizoPct / 100))
      prejuizoDisponivel -= deducao
    }
  }

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
  const dateStartExpanded = new Date(ano - 1, 11, 1) // 1 Dec year-1
  const faturaClassificacoes = await prisma.faturaClassificacao.findMany({
    where: {
      confirmado: true,
      fatura: { dataFatura: { gte: dateStartExpanded, lt: dateEnd } },
    },
    include: { fatura: true },
  })

  // 5. Load manual entries in period (same expanded range)
  const lancamentos = await prisma.lancamentoManual.findMany({
    where: { dataDoc: { gte: dateStartExpanded, lt: dateEnd } },
  })

  // ---------- Build per-property analysis ----------

  interface MonthBucket { receita: number; custos: number }
  interface RubricaBucket { rubricaId: string; rubricaNome: string; valor: number }

  const imoveisResult: ImovelAnalise[] = imoveisDb.map((im) => {
    let receita = 0
    let rendaPaga = 0
    let custosOperacionais = 0
    const meses: MonthBucket[] = Array.from({ length: 12 }, () => ({ receita: 0, custos: 0 }))
    const custosPorRubricaMap = new Map<string, number>()

    for (const fc of faturaClassificacoes) {
      if (fc.imovelId !== im.id) continue
      const rub = rubricaMap.get(fc.rubricaId)
      if (!rub) continue
      const valor = fc.valorAtribuido ? toNum(fc.valorAtribuido) : toNum(fc.fatura.totalComIva)
      const dataFatura = new Date(fc.fatura.dataFatura)
      const faturaAno = dataFatura.getFullYear()
      const mesIdx = dataFatura.getMonth()

      if (rub.tipo === 'RECEITA') {
        const mesReferencia = mesIdx + 1
        if (faturaAno === ano && mesIdx === 11) continue
        if (faturaAno === ano - 1 && mesIdx === 11) {
          receita += valor
          meses[0].receita += valor
        } else if (faturaAno === ano && mesReferencia <= 11) {
          receita += valor
          meses[mesReferencia].receita += valor
        }
      } else {
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

    for (const lm of lancamentos) {
      if (lm.imovelId !== im.id) continue
      const rub = rubricaMap.get(lm.rubricaId)
      if (!rub) continue
      const valor = toNum(lm.totalComIva)
      const dataDoc = new Date(lm.dataDoc)
      const lmAno = dataDoc.getFullYear()
      const mesIdx = dataDoc.getMonth()

      if (rub.tipo === 'RECEITA') {
        const mesReferencia = mesIdx + 1
        if (lmAno === ano && mesIdx === 11) continue
        if (lmAno === ano - 1 && mesIdx === 11) {
          receita += valor
          meses[0].receita += valor
        } else if (lmAno === ano && mesReferencia <= 11) {
          receita += valor
          meses[mesReferencia].receita += valor
        }
      } else {
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

    const receitaPorFracao = new Map<string, { total: number; count: number }>()
    for (const fc of faturaClassificacoes) {
      if (fc.imovelId !== im.id || !fc.fracaoId) continue
      const rub = rubricaMap.get(fc.rubricaId)
      if (!rub || rub.tipo !== 'RECEITA') continue
      const entry = receitaPorFracao.get(fc.fracaoId) || { total: 0, count: 0 }
      entry.total += fc.valorAtribuido ? toNum(fc.valorAtribuido) : toNum(fc.fatura.totalComIva)
      entry.count += 1
      receitaPorFracao.set(fc.fracaoId, entry)
    }
    for (const lm of lancamentos) {
      if (lm.imovelId !== im.id || !lm.fracaoId) continue
      const rub = rubricaMap.get(lm.rubricaId)
      if (!rub || rub.tipo !== 'RECEITA') continue
      const entry = receitaPorFracao.get(lm.fracaoId) || { total: 0, count: 0 }
      entry.total += toNum(lm.totalComIva)
      entry.count += 1
      receitaPorFracao.set(lm.fracaoId, entry)
    }

    const now = new Date()
    const mesesRef = ano < now.getFullYear() ? 12 : Math.max(now.getMonth(), 1)

    const fracoes = im.fracoes.map((f) => {
      const recData = receitaPorFracao.get(f.id)
      const rendaMedia = recData && recData.count > 0 ? recData.total / recData.count : toNum(f.renda)

      let mesesDisponiveis = mesesRef
      const entradaMercado = f.dataEntradaMercado ? new Date(f.dataEntradaMercado) : null
      if (entradaMercado && entradaMercado.getFullYear() <= ano) {
        if (entradaMercado.getFullYear() === ano) {
          const mesEntrada = entradaMercado.getMonth()
          mesesDisponiveis = Math.max(mesesRef - mesEntrada, 0)
        } else {
          mesesDisponiveis = mesesRef
        }
      } else if (!entradaMercado && recData && recData.count > 0) {
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
    const totalMesesPossiveis = fracoes.reduce((s, f) => s + f.mesesDisponiveis, 0)
    const totalMesesOcupados = fracoes.reduce((s, f) => s + f.mesesOcupado, 0)
    const ocupacao = totalFracoes > 0
      ? { total: totalFracoes, ocupados: totalMesesOcupados, totalMeses: totalMesesPossiveis, pct: pct(totalMesesOcupados, totalMesesPossiveis) }
      : null

    const potencialAnual = fracoes.reduce((s, f) => s + f.potencialAnual, 0)
    const pctPotencial = potencialAnual > 0 ? Math.min((receita / potencialAnual) * 100, 100) : 0

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

  const global: GlobalAnalise = {
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
    prejuizoDisponivel,
    reportePrejuizoPct,
  )

  const retencoesFeitasTotal = rendaPagaTotal * (taxaRetencao / 100)

  const irc: IrcAnalise = {
    resultadoAntesImpostos: resultadoLiquidoGlobal,
    materiaColetavel: ircCalc.mc,
    coleta: ircCalc.coleta,
    derrama: ircCalc.derrama,
    ircTotal: ircCalc.ircTotal,
    taxaEfetiva: ircCalc.taxaEfetiva,
    retencoesFeitasTotal,
    prejuizoDisponivel: ircCalc.prejuizoDisponivel,
    deducaoPrejuizos: ircCalc.deducaoPrejuizos,
    prejuizoRestante: ircCalc.prejuizoRestante,
  }

  // ---------- Monthly evolution ----------

  const evolucaoMensal: MonthData[] = Array.from({ length: 12 }, (_, i) => {
    const mes = i + 1
    let receitaMes = 0
    let custosMes = 0
    for (const im of imoveisResult) {
      const m = im.meses[i]
      receitaMes += m.receita
      custosMes += m.custos
    }
    return { mes, receita: receitaMes, custos: custosMes, resultado: receitaMes - custosMes, ircAcumulado: 0 }
  })

  // Cumulative IRC
  let receitaAcum = 0
  let custosAcum = 0
  for (const m of evolucaoMensal) {
    receitaAcum += m.receita
    custosAcum += m.custos
    const resultadoAcum = receitaAcum - custosAcum
    const ircAcum = calcIrc(resultadoAcum, derramaMunicipal, regimePme, taxaIrcPme, taxaIrcNormal, limitePme)
    m.ircAcumulado = ircAcum.ircTotal
  }

  // ---------- Config block ----------

  const config: ConfigAnalise = {
    derramaMunicipal,
    regimePme,
    taxaIrcPme,
    taxaIrcNormal,
    limitePme,
    taxaRetencao,
  }

  return {
    imoveis: imoveisResult,
    global,
    irc,
    evolucaoMensal,
    config,
  }
}
