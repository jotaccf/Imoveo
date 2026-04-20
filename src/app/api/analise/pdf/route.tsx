import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { renderToBuffer, Document, Page, Text, View, StyleSheet } from '@react-pdf/renderer'

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

function fmt(value: number): string {
  return new Intl.NumberFormat('pt-PT', { style: 'currency', currency: 'EUR' }).format(value)
}

function calcIrc(
  resultadoAntesImpostos: number,
  derramaPct: number,
  regimePme: boolean,
  taxaPme: number,
  taxaNormal: number,
  limitePme: number,
) {
  const mc = Math.max(resultadoAntesImpostos, 0)
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

// ---------- PDF Styles ----------

const MESES = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

const s = StyleSheet.create({
  page: { padding: 40, fontSize: 9, fontFamily: 'Helvetica', color: '#0D1B1A' },
  header: { marginBottom: 20, borderBottom: '2px solid #1D9E75', paddingBottom: 10 },
  title: { fontSize: 18, fontFamily: 'Helvetica-Bold', color: '#0D1B1A' },
  subtitle: { fontSize: 10, color: '#6B7280', marginTop: 2 },
  section: { marginBottom: 16 },
  sectionTitle: { fontSize: 11, fontFamily: 'Helvetica-Bold', color: '#0D1B1A', marginBottom: 8, borderBottom: '1px solid #E5E7EB', paddingBottom: 4 },
  kpiRow: { flexDirection: 'row', gap: 8, marginBottom: 12 },
  kpiBox: { flex: 1, padding: 8, backgroundColor: '#F9FAFB', borderRadius: 4, border: '1px solid #E5E7EB' },
  kpiLabel: { fontSize: 7, color: '#6B7280', marginBottom: 2, textTransform: 'uppercase' as const },
  kpiValue: { fontSize: 12, fontFamily: 'Helvetica-Bold' },
  table: { width: '100%' },
  tableHeader: { flexDirection: 'row', backgroundColor: '#F3F4F6', borderBottom: '1px solid #D1D5DB', paddingVertical: 4 },
  tableRow: { flexDirection: 'row', borderBottom: '1px solid #F3F4F6', paddingVertical: 3 },
  tableRowTotal: { flexDirection: 'row', borderTop: '2px solid #0D1B1A', paddingVertical: 4, marginTop: 2 },
  cellName: { width: '18%', paddingHorizontal: 3 },
  cell: { width: '10.25%', paddingHorizontal: 2, textAlign: 'right' as const },
  cellBold: { fontFamily: 'Helvetica-Bold' },
  green: { color: '#0F6E56' },
  red: { color: '#A32D2D' },
  amber: { color: '#633806' },
  row: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 3 },
  rowLabel: { color: '#6B7280' },
  rowBorder: { borderTop: '1px solid #E5E7EB', paddingTop: 4, marginTop: 2 },
  footer: { position: 'absolute', bottom: 25, left: 40, right: 40, flexDirection: 'row', justifyContent: 'space-between', fontSize: 7, color: '#9CA3AF' },
})

// ---------- Data Loading (same logic as /api/analise) ----------

async function loadAnaliseData(ano: number) {
  const dateEnd = new Date(ano + 1, 0, 1)

  const configRows = await prisma.configuracao.findMany()
  const configMap: Record<string, string> = {}
  for (const r of configRows) configMap[r.chave] = r.valor

  const derramaMunicipal = cfgNum(configMap, 'derramaMunicipal', 1.5)
  const regimePme = cfgBool(configMap, 'regimePme', true)
  const taxaIrcPme = cfgNum(configMap, 'taxaIrcPme', 17)
  const taxaIrcNormal = cfgNum(configMap, 'taxaIrcNormal', 21)
  const limitePme = cfgNum(configMap, 'limitePme', 50000)
  const taxaRetencao = cfgNum(configMap, 'taxaRetencao', 25)

  const imoveisDb = await prisma.imovel.findMany({
    where: { ativo: true },
    include: {
      fracoes: { select: { id: true, nome: true, renda: true, estado: true, nifInquilino: true, dataEntradaMercado: true }, orderBy: { nome: 'asc' } },
    },
    orderBy: { codigo: 'asc' },
  })

  const rubricas = await prisma.rubrica.findMany()
  const rubricaMap = new Map(rubricas.map((r) => [r.id, r]))
  const rdaRubrica = rubricas.find((r) => r.codigo === 'RDA')
  const rdaRubricaId = rdaRubrica?.id ?? ''

  const dateStartExpanded = new Date(ano - 1, 11, 1)
  const faturaClassificacoes = await prisma.faturaClassificacao.findMany({
    where: { confirmado: true, fatura: { dataFatura: { gte: dateStartExpanded, lt: dateEnd } } },
    include: { fatura: true },
  })

  const lancamentos = await prisma.lancamentoManual.findMany({
    where: { dataDoc: { gte: dateStartExpanded, lt: dateEnd } },
  })

  interface MonthBucket { receita: number; custos: number }

  const imoveisResult = imoveisDb.map((im) => {
    let receita = 0
    let rendaPaga = 0
    let custosOperacionais = 0
    const meses: MonthBucket[] = Array.from({ length: 12 }, () => ({ receita: 0, custos: 0 }))

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
          receita += valor; meses[0].receita += valor
        } else if (faturaAno === ano && mesReferencia <= 11) {
          receita += valor; meses[mesReferencia].receita += valor
        }
      } else {
        if (faturaAno !== ano) continue
        if (fc.rubricaId === rdaRubricaId) { rendaPaga += valor } else { custosOperacionais += valor }
        meses[mesIdx].custos += valor
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
          receita += valor; meses[0].receita += valor
        } else if (lmAno === ano && mesReferencia <= 11) {
          receita += valor; meses[mesReferencia].receita += valor
        }
      } else {
        if (lmAno !== ano) continue
        if (lm.rubricaId === rdaRubricaId) { rendaPaga += valor } else { custosOperacionais += valor }
        meses[mesIdx].custos += valor
      }
    }

    const custoTotal = rendaPaga + custosOperacionais
    const resultadoLiquido = receita - custoTotal
    const totalFracoes = im.fracoes.length
    const ocupados = im.fracoes.filter(f => f.estado === 'OCUPADO').length

    return {
      id: im.id, codigo: im.codigo, nome: im.nome,
      receita, rendaPaga, custosOperacionais, custoTotal, resultadoLiquido,
      resultadoLiquidoPct: pct(resultadoLiquido, receita),
      ratiCobertura: rendaPaga !== 0 ? receita / rendaPaga : 0,
      ocupacao: totalFracoes > 0 ? { total: totalFracoes, ocupados } : null,
      meses,
    }
  })

  const receitaTotal = imoveisResult.reduce((s, im) => s + im.receita, 0)
  const rendaPagaTotal = imoveisResult.reduce((s, im) => s + im.rendaPaga, 0)
  const custosOperacionaisTotal = imoveisResult.reduce((s, im) => s + im.custosOperacionais, 0)
  const custoTotalGlobal = rendaPagaTotal + custosOperacionaisTotal
  const margemBruta = receitaTotal - rendaPagaTotal
  const resultadoLiquido = receitaTotal - custoTotalGlobal

  const ircCalc = calcIrc(resultadoLiquido, derramaMunicipal, regimePme, taxaIrcPme, taxaIrcNormal, limitePme)
  const retencoesFeitasTotal = rendaPagaTotal * (taxaRetencao / 100)

  const evolucao = Array.from({ length: 12 }, (_, i) => {
    let rec = 0, cst = 0
    for (const im of imoveisResult) { rec += im.meses[i].receita; cst += im.meses[i].custos }
    return { mes: MESES[i], receita: rec, custos: cst, resultado: rec - cst }
  })

  const totalFracoes = imoveisResult.reduce((s, im) => s + (im.ocupacao?.total || 0), 0)
  const totalOcupados = imoveisResult.reduce((s, im) => s + (im.ocupacao?.ocupados || 0), 0)
  const taxaVacancia = totalFracoes > 0 ? ((totalFracoes - totalOcupados) / totalFracoes) * 100 : 0
  const maxReceita = Math.max(...imoveisResult.map(im => im.receita), 1)
  const concentracao = receitaTotal > 0 ? (maxReceita / receitaTotal) * 100 : 0

  return {
    ano,
    global: { receitaTotal, rendaPagaTotal, custosOperacionaisTotal, custoTotal: custoTotalGlobal, margemBruta, margemBrutaPct: pct(margemBruta, receitaTotal), resultadoLiquido, ratiCobertura: rendaPagaTotal !== 0 ? receitaTotal / rendaPagaTotal : 0 },
    irc: { resultadoAntesImpostos: resultadoLiquido, mc: ircCalc.mc, coleta: ircCalc.coleta, derrama: ircCalc.derrama, ircTotal: ircCalc.ircTotal, taxaEfetiva: ircCalc.taxaEfetiva, retencoesFeitasTotal },
    imoveis: imoveisResult,
    evolucao,
    risco: { taxaVacancia, concentracao, ratiCobertura: rendaPagaTotal !== 0 ? receitaTotal / rendaPagaTotal : 0 },
  }
}

// ---------- PDF Document Component ----------

interface AnaliseData {
  ano: number
  global: { receitaTotal: number; rendaPagaTotal: number; custosOperacionaisTotal: number; custoTotal: number; margemBruta: number; margemBrutaPct: number; resultadoLiquido: number; ratiCobertura: number }
  irc: { resultadoAntesImpostos: number; mc: number; coleta: number; derrama: number; ircTotal: number; taxaEfetiva: number; retencoesFeitasTotal: number }
  imoveis: { id: string; codigo: string; nome: string; receita: number; rendaPaga: number; custosOperacionais: number; resultadoLiquido: number; resultadoLiquidoPct: number; ratiCobertura: number; ocupacao: { total: number; ocupados: number } | null }[]
  evolucao: { mes: string; receita: number; custos: number; resultado: number }[]
  risco: { taxaVacancia: number; concentracao: number; ratiCobertura: number }
}

function AnalisePDF({ data }: { data: AnaliseData }) {
  const g = data.global
  const irc = data.irc
  const dataGerada = new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(new Date())

  return (
    <Document>
      {/* Page 1 — Rentabilidade Global + Por Imovel */}
      <Page size="A4" orientation="landscape" style={s.page}>
        <View style={s.header}>
          <Text style={s.title}>Analise Financeira {data.ano}</Text>
          <Text style={s.subtitle}>Imoveo — Relatorio gerado em {dataGerada}</Text>
        </View>

        {/* KPIs */}
        <View style={s.section}>
          <Text style={s.sectionTitle}>Rentabilidade Global</Text>
          <View style={s.kpiRow}>
            <View style={s.kpiBox}><Text style={s.kpiLabel}>Receita Total</Text><Text style={[s.kpiValue, s.green]}>{fmt(g.receitaTotal)}</Text></View>
            <View style={s.kpiBox}><Text style={s.kpiLabel}>Custos Totais</Text><Text style={[s.kpiValue, s.red]}>{fmt(g.custoTotal)}</Text></View>
            <View style={s.kpiBox}><Text style={s.kpiLabel}>Resultado Liquido</Text><Text style={[s.kpiValue, g.resultadoLiquido >= 0 ? s.green : s.red]}>{fmt(g.resultadoLiquido)}</Text></View>
            <View style={s.kpiBox}><Text style={s.kpiLabel}>Margem Bruta</Text><Text style={s.kpiValue}>{g.margemBrutaPct.toFixed(1)}%</Text></View>
            <View style={s.kpiBox}><Text style={s.kpiLabel}>Racio Cobertura</Text><Text style={s.kpiValue}>{g.ratiCobertura.toFixed(2)}</Text></View>
            <View style={s.kpiBox}><Text style={s.kpiLabel}>IRC Estimado</Text><Text style={[s.kpiValue, s.amber]}>{fmt(irc.ircTotal)}</Text></View>
          </View>
        </View>

        {/* Tabela por Imovel */}
        <View style={s.section}>
          <Text style={s.sectionTitle}>Rentabilidade por Imovel</Text>
          <View style={s.table}>
            <View style={s.tableHeader}>
              <Text style={[s.cellName, s.cellBold]}>Imovel</Text>
              <Text style={[s.cell, s.cellBold]}>Receita</Text>
              <Text style={[s.cell, s.cellBold]}>Renda Paga</Text>
              <Text style={[s.cell, s.cellBold]}>Custos Ops</Text>
              <Text style={[s.cell, s.cellBold]}>Resultado</Text>
              <Text style={[s.cell, s.cellBold]}>Margem %</Text>
              <Text style={[s.cell, s.cellBold]}>Racio</Text>
              <Text style={[s.cell, s.cellBold]}>Ocupacao</Text>
            </View>
            {data.imoveis.map((im) => (
              <View key={im.id} style={s.tableRow}>
                <Text style={s.cellName}>{im.nome}</Text>
                <Text style={[s.cell, s.green]}>{fmt(im.receita)}</Text>
                <Text style={[s.cell, s.red]}>{fmt(im.rendaPaga)}</Text>
                <Text style={[s.cell, s.red]}>{fmt(im.custosOperacionais)}</Text>
                <Text style={[s.cell, im.resultadoLiquido >= 0 ? s.green : s.red]}>{fmt(im.resultadoLiquido)}</Text>
                <Text style={[s.cell, im.resultadoLiquidoPct >= 0 ? s.green : s.red]}>{im.resultadoLiquidoPct.toFixed(1)}%</Text>
                <Text style={[s.cell, im.ratiCobertura > 1.5 ? s.green : im.ratiCobertura >= 1 ? s.amber : s.red]}>{im.ratiCobertura.toFixed(2)}</Text>
                <Text style={s.cell}>{im.ocupacao ? `${im.ocupacao.ocupados}/${im.ocupacao.total}` : '-'}</Text>
              </View>
            ))}
            <View style={s.tableRowTotal}>
              <Text style={[s.cellName, s.cellBold]}>TOTAIS</Text>
              <Text style={[s.cell, s.cellBold, s.green]}>{fmt(g.receitaTotal)}</Text>
              <Text style={[s.cell, s.cellBold, s.red]}>{fmt(g.rendaPagaTotal)}</Text>
              <Text style={[s.cell, s.cellBold, s.red]}>{fmt(g.custosOperacionaisTotal)}</Text>
              <Text style={[s.cell, s.cellBold, g.resultadoLiquido >= 0 ? s.green : s.red]}>{fmt(g.resultadoLiquido)}</Text>
              <Text style={[s.cell, s.cellBold, g.margemBrutaPct >= 0 ? s.green : s.red]}>{g.margemBrutaPct.toFixed(1)}%</Text>
              <Text style={[s.cell, s.cellBold]}>{g.ratiCobertura.toFixed(2)}</Text>
              <Text style={[s.cell, s.cellBold]}></Text>
            </View>
          </View>
        </View>

        <View style={s.footer}>
          <Text>Imoveo — Analise Financeira</Text>
          <Text render={({ pageNumber, totalPages }) => `Pagina ${pageNumber} / ${totalPages}`} />
        </View>
      </Page>

      {/* Page 2 — Evolucao Mensal + IRC + Risco */}
      <Page size="A4" orientation="landscape" style={s.page}>
        <View style={s.header}>
          <Text style={s.title}>Analise Financeira {data.ano}</Text>
          <Text style={s.subtitle}>Evolucao Mensal, IRC e Indicadores de Risco</Text>
        </View>

        {/* Evolucao Mensal */}
        <View style={s.section}>
          <Text style={s.sectionTitle}>Evolucao Mensal</Text>
          <View style={s.table}>
            <View style={s.tableHeader}>
              <Text style={[{ width: '10%', paddingHorizontal: 3 }, s.cellBold]}>Mes</Text>
              <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.cellBold]}>Receita</Text>
              <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.cellBold]}>Custos</Text>
              <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.cellBold]}>Resultado</Text>
            </View>
            {data.evolucao.map((m) => (
              <View key={m.mes} style={s.tableRow}>
                <Text style={{ width: '10%', paddingHorizontal: 3 }}>{m.mes}</Text>
                <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.green]}>{fmt(m.receita)}</Text>
                <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.red]}>{fmt(m.custos)}</Text>
                <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, m.resultado >= 0 ? s.green : s.red]}>{fmt(m.resultado)}</Text>
              </View>
            ))}
            <View style={s.tableRowTotal}>
              <Text style={[{ width: '10%', paddingHorizontal: 3 }, s.cellBold]}>Total</Text>
              <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.cellBold, s.green]}>{fmt(g.receitaTotal)}</Text>
              <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.cellBold, s.red]}>{fmt(g.custoTotal)}</Text>
              <Text style={[{ width: '30%', paddingHorizontal: 3, textAlign: 'right' as const }, s.cellBold, g.resultadoLiquido >= 0 ? s.green : s.red]}>{fmt(g.resultadoLiquido)}</Text>
            </View>
          </View>
        </View>

        {/* IRC + Risco side by side */}
        <View style={{ flexDirection: 'row', gap: 20 }}>
          {/* Previsao IRC */}
          <View style={[s.section, { flex: 1 }]}>
            <Text style={s.sectionTitle}>Previsao IRC</Text>
            <View style={s.row}><Text style={s.rowLabel}>Resultado antes de impostos</Text><Text>{fmt(irc.resultadoAntesImpostos)}</Text></View>
            <View style={s.row}><Text style={s.rowLabel}>Materia coletavel</Text><Text>{fmt(irc.mc)}</Text></View>
            <View style={s.row}><Text style={s.rowLabel}>Coleta IRC (PME)</Text><Text>{fmt(irc.coleta)}</Text></View>
            <View style={s.row}><Text style={s.rowLabel}>Derrama municipal</Text><Text>{fmt(irc.derrama)}</Text></View>
            <View style={[s.row, s.rowBorder]}><Text style={s.cellBold}>IRC Total Estimado</Text><Text style={[s.cellBold, s.amber]}>{fmt(irc.ircTotal)}</Text></View>
            <View style={s.row}><Text style={s.rowLabel}>Taxa efectiva</Text><Text>{irc.taxaEfetiva.toFixed(1)}%</Text></View>
            <View style={[s.row, s.rowBorder]}><Text style={s.rowLabel}>Retencoes na fonte (25%)</Text><Text>{fmt(irc.retencoesFeitasTotal)}</Text></View>
            <View style={s.row}><Text style={s.rowLabel}>Pagamento por Conta (80%)</Text><Text>{fmt(irc.ircTotal * 0.8)}</Text></View>
          </View>

          {/* Indicadores de Risco */}
          <View style={[s.section, { flex: 1 }]}>
            <Text style={s.sectionTitle}>Indicadores de Risco</Text>
            <View style={s.kpiRow}>
              <View style={s.kpiBox}>
                <Text style={s.kpiLabel}>Taxa de Vacancia</Text>
                <Text style={[s.kpiValue, data.risco.taxaVacancia > 20 ? s.red : s.amber]}>{data.risco.taxaVacancia.toFixed(1)}%</Text>
              </View>
              <View style={s.kpiBox}>
                <Text style={s.kpiLabel}>Concentracao Receita</Text>
                <Text style={[s.kpiValue, data.risco.concentracao > 50 ? s.red : s.amber]}>{data.risco.concentracao.toFixed(1)}%</Text>
              </View>
            </View>
            <View style={s.kpiRow}>
              <View style={s.kpiBox}>
                <Text style={s.kpiLabel}>Racio Cobertura</Text>
                <Text style={[s.kpiValue, data.risco.ratiCobertura > 1.5 ? s.green : data.risco.ratiCobertura >= 1 ? s.amber : s.red]}>{data.risco.ratiCobertura.toFixed(2)}</Text>
              </View>
              <View style={s.kpiBox}>
                <Text style={s.kpiLabel}>IRC / Receita</Text>
                <Text style={s.kpiValue}>{g.receitaTotal > 0 ? ((irc.ircTotal / g.receitaTotal) * 100).toFixed(1) : '0.0'}%</Text>
              </View>
            </View>
          </View>
        </View>

        <View style={s.footer}>
          <Text>Imoveo — Analise Financeira</Text>
          <Text render={({ pageNumber, totalPages }) => `Pagina ${pageNumber} / ${totalPages}`} />
        </View>
      </Page>
    </Document>
  )
}

// ---------- API Route ----------

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const { searchParams } = req.nextUrl
    const ano = searchParams.get('ano') ? Number(searchParams.get('ano')) : new Date().getFullYear()

    const data = await loadAnaliseData(ano)

    const buffer = await renderToBuffer(<AnalisePDF data={data} />)
    const uint8 = new Uint8Array(buffer)

    return new Response(uint8, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="Imoveo_Analise_${ano}.pdf"`,
        'Content-Length': String(buffer.length),
      },
    })
  } catch (e) {
    console.error('[analise/pdf] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao gerar PDF', details: String(e) }, { status: 500 })
  }
}
