'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { KpiCard } from '@/components/ui/KpiCard'
import { formatCurrency } from '@/lib/utils'
import {
  ResponsiveContainer, ComposedChart, Bar, Line,
  XAxis, YAxis, Tooltip, CartesianGrid, Legend,
} from 'recharts'

const MESES = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiData = any

// ---------- YoY helpers ----------

function VarBadge({ value, invert = false }: { value: number; invert?: boolean }) {
  const positive = invert ? value < 0 : value >= 0
  const arrow = value >= 0 ? '\u2191' : '\u2193'
  const color = positive ? '#0F6E56' : '#A32D2D'
  const bg = positive ? '#E1F5EE' : '#FCEBEB'
  return (
    <span
      className="inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[11px] font-medium"
      style={{ color, backgroundColor: bg }}
    >
      {arrow} {Math.abs(value).toFixed(1)}%
    </span>
  )
}

export default function AnalisePage() {
  const [ano, setAno] = useState(new Date().getFullYear())
  const [years, setYears] = useState<number[]>([new Date().getFullYear()])
  const [data, setData] = useState<ApiData>(null)
  const [loading, setLoading] = useState(true)

  // YoY state
  const [yoyActive, setYoyActive] = useState(false)
  const [yoyData, setYoyData] = useState<ApiData>(null)
  const [yoyLoading, setYoyLoading] = useState(false)

  useEffect(() => {
    fetch('/api/anos').then(r => r.json()).then(j => { if (j.data) setYears(j.data) }).catch(() => {})
  }, [])

  useEffect(() => {
    setLoading(true)
    fetch(`/api/analise?ano=${ano}`)
      .then((r) => r.json())
      .then((j) => { if (j.data) setData(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [ano])

  // Fetch YoY data when toggle is active
  useEffect(() => {
    if (!yoyActive) { setYoyData(null); return }
    setYoyLoading(true)
    fetch(`/api/analise/yoy?ano=${ano}`)
      .then((r) => r.json())
      .then((j) => { if (j.data) setYoyData(j.data) })
      .catch(() => {})
      .finally(() => setYoyLoading(false))
  }, [yoyActive, ano])

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!data) return <div className="text-sm text-gray-400">Sem dados</div>

  const g = data.global || {}
  const irc = data.irc || {}
  const imoveis = data.imoveis || []
  const evolucao = (data.evolucaoMensal || []).map((m: ApiData, i: number) => ({
    mes: MESES[i] || `M${i + 1}`,
    receita: m.receita || 0,
    custos: m.custos || 0,
    resultado: m.resultado || 0,
    ircAcumulado: m.ircAcumulado || 0,
  }))

  // Risk indicators
  const totalFracoes = imoveis.reduce((s: number, im: ApiData) => s + (im.ocupacao?.total || 0), 0)
  const totalOcupados = imoveis.reduce((s: number, im: ApiData) => s + (im.ocupacao?.ocupados || 0), 0)
  const taxaVacancia = totalFracoes > 0 ? ((totalFracoes - totalOcupados) / totalFracoes) * 100 : 0

  const maxReceita = Math.max(...imoveis.map((im: ApiData) => im.receita || 0), 1)
  const concentracao = g.receitaTotal > 0 ? (maxReceita / g.receitaTotal) * 100 : 0

  const menosRentavel = imoveis.length > 0
    ? imoveis.reduce((min: ApiData, im: ApiData) => (im.resultadoLiquidoPct < min.resultadoLiquidoPct ? im : min), imoveis[0])
    : { nome: '—', resultadoLiquidoPct: 0 }

  return (
    <div className="space-y-5">
      {/* Year selector + YoY toggle + PDF export */}
      <div className="flex items-center gap-2">
        {years.map((y) => (
          <Button key={y} variant={y === ano ? 'primary' : 'secondary'} onClick={() => setAno(y)}>{y}</Button>
        ))}
        <Button
          variant={yoyActive ? 'primary' : 'secondary'}
          onClick={() => setYoyActive((v) => !v)}
          className="ml-2"
        >
          Comparacao YoY
        </Button>
        <div className="ml-auto">
          <Button variant="secondary" onClick={() => {
            const link = document.createElement('a')
            link.href = `/api/analise/pdf?ano=${ano}`
            link.download = `Imoveo_Analise_${ano}.pdf`
            link.click()
          }}>
            Exportar PDF
          </Button>
        </div>
      </div>

      {/* YoY Section — shown when toggle is active */}
      {yoyActive && (
        yoyLoading ? (
          <div className="text-sm text-gray-400">A carregar comparacao...</div>
        ) : yoyData ? (
          <div className="space-y-5">
            {/* YoY KPIs */}
            <div>
              <h2 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>
                Comparacao YoY — {yoyData.anoAnterior} vs {yoyData.ano}
              </h2>
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
                <div className="rounded-lg p-3.5" style={{ background: '#F3F4F6' }}>
                  <div className="text-[11px] font-medium mb-1" style={{ color: '#6B7280' }}>Receita Total</div>
                  <div className="text-xl font-medium" style={{ color: '#0F6E56' }}>{formatCurrency(yoyData.global.receitaTotal.atual)}</div>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px]" style={{ color: '#9CA3AF' }}>{formatCurrency(yoyData.global.receitaTotal.anterior)}</span>
                    <VarBadge value={yoyData.global.receitaTotal.pct} />
                  </div>
                </div>
                <div className="rounded-lg p-3.5" style={{ background: '#F3F4F6' }}>
                  <div className="text-[11px] font-medium mb-1" style={{ color: '#6B7280' }}>Custos Totais</div>
                  <div className="text-xl font-medium" style={{ color: '#A32D2D' }}>{formatCurrency(yoyData.global.custoTotal.atual)}</div>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px]" style={{ color: '#9CA3AF' }}>{formatCurrency(yoyData.global.custoTotal.anterior)}</span>
                    <VarBadge value={yoyData.global.custoTotal.pct} invert />
                  </div>
                </div>
                <div className="rounded-lg p-3.5" style={{ background: '#F3F4F6' }}>
                  <div className="text-[11px] font-medium mb-1" style={{ color: '#6B7280' }}>Resultado Liquido</div>
                  <div className="text-xl font-medium" style={{ color: yoyData.global.resultadoLiquido.atual >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(yoyData.global.resultadoLiquido.atual)}</div>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px]" style={{ color: '#9CA3AF' }}>{formatCurrency(yoyData.global.resultadoLiquido.anterior)}</span>
                    <VarBadge value={yoyData.global.resultadoLiquido.pct} />
                  </div>
                </div>
                <div className="rounded-lg p-3.5" style={{ background: '#F3F4F6' }}>
                  <div className="text-[11px] font-medium mb-1" style={{ color: '#6B7280' }}>Margem Bruta</div>
                  <div className="text-xl font-medium" style={{ color: '#0D1B1A' }}>{yoyData.global.margemBrutaPct.atual.toFixed(1)}%</div>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px]" style={{ color: '#9CA3AF' }}>{yoyData.global.margemBrutaPct.anterior.toFixed(1)}%</span>
                    <VarBadge value={yoyData.global.margemBrutaPct.delta} />
                  </div>
                </div>
                <div className="rounded-lg p-3.5" style={{ background: '#F3F4F6' }}>
                  <div className="text-[11px] font-medium mb-1" style={{ color: '#6B7280' }}>IRC Estimado</div>
                  <div className="text-xl font-medium" style={{ color: '#633806' }}>{formatCurrency(yoyData.ircAtual)}</div>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px]" style={{ color: '#9CA3AF' }}>{formatCurrency(yoyData.ircAnterior)}</span>
                    <VarBadge value={yoyData.ircVar} invert />
                  </div>
                </div>
              </div>
            </div>

            {/* YoY Per-property comparison table */}
            <Card className="p-0 overflow-x-auto">
              <div className="px-5 pt-4 pb-2">
                <h3 className="text-sm font-semibold" style={{ color: '#0D1B1A' }}>Comparacao por Imovel</h3>
              </div>
              <table className="w-full text-left text-[13px]">
                <thead>
                  <tr>
                    {['Imovel', `Receita ${yoyData.anoAnterior}`, `Receita ${yoyData.ano}`, 'Var %', `Resultado ${yoyData.anoAnterior}`, `Resultado ${yoyData.ano}`, 'Var %'].map((h) => (
                      <th key={h} className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {(yoyData.imoveis || []).map((im: ApiData) => (
                    <tr key={im.id}>
                      <td className="px-3 py-2.5 border-b border-gray-50 font-medium" style={{ color: '#0D1B1A' }}>{im.nome}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#6B7280' }}>{formatCurrency(im.receitaAnterior)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#0F6E56' }}>{formatCurrency(im.receitaAtual)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right"><VarBadge value={im.receitaVar} /></td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#6B7280' }}>{formatCurrency(im.resultadoAnterior)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: im.resultadoAtual >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(im.resultadoAtual)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right"><VarBadge value={im.resultadoVar} /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </Card>

            {/* YoY Monthly comparison table */}
            <Card className="p-0 overflow-x-auto">
              <div className="px-5 pt-4 pb-2">
                <h3 className="text-sm font-semibold" style={{ color: '#0D1B1A' }}>Evolucao Mensal Comparada</h3>
              </div>
              <table className="w-full text-left text-[13px]">
                <thead>
                  <tr>
                    {['Mes', `Receita ${yoyData.anoAnterior}`, `Receita ${yoyData.ano}`, 'Var', `Custos ${yoyData.anoAnterior}`, `Custos ${yoyData.ano}`, 'Var'].map((h) => (
                      <th key={h} className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {(yoyData.evolucaoMensal || []).map((m: ApiData, i: number) => (
                    <tr key={m.mes}>
                      <td className="px-3 py-2.5 border-b border-gray-50 font-medium" style={{ color: '#0D1B1A' }}>{MESES[i]}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#6B7280' }}>{formatCurrency(m.receitaAnterior)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#0F6E56' }}>{formatCurrency(m.receitaAtual)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right"><VarBadge value={m.receitaVar} /></td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#6B7280' }}>{formatCurrency(m.custosAnterior)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#A32D2D' }}>{formatCurrency(m.custosAtual)}</td>
                      <td className="px-3 py-2.5 border-b border-gray-50 text-right"><VarBadge value={m.custosVar} invert /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </Card>
          </div>
        ) : (
          <div className="text-sm text-gray-400">Sem dados de comparacao</div>
        )
      )}

      {/* Section 1 — Rentabilidade Global */}
      <div>
        <h2 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>Rentabilidade Global</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
          <KpiCard label="Receita Total" value={formatCurrency(g.receitaTotal || 0)} color="green" />
          <KpiCard label="Custos Totais" value={formatCurrency(g.custoTotal || 0)} color="red" />
          <KpiCard label="Resultado Liquido" value={formatCurrency(g.resultadoLiquido || 0)} color={(g.resultadoLiquido || 0) >= 0 ? 'green' : 'red'} />
          <KpiCard label="Margem Bruta" value={`${(g.margemBrutaPct || 0).toFixed(1)}%`} />
          <KpiCard label="Racio Cobertura" value={(g.ratiCobertura || 0).toFixed(2)} />
          <KpiCard label="IRC Estimado" value={formatCurrency(irc.ircTotal || 0)} color="amber" />
        </div>
      </div>

      {/* Section 2 — Rentabilidade por Imovel */}
      <Card className="p-0 overflow-x-auto">
        <div className="px-5 pt-4 pb-2">
          <h3 className="text-sm font-semibold" style={{ color: '#0D1B1A' }}>Rentabilidade por Imovel</h3>
        </div>
        <table className="w-full text-left text-[13px]">
          <thead>
            <tr>
              {['Imovel', 'Receita', 'Renda Paga', 'Custos Ops', 'Resultado', 'Margem %', 'Racio', 'Ocupacao'].map((h) => (
                <th key={h} className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {imoveis.map((im: ApiData) => (
              <tr key={im.id}>
                <td className="px-3 py-2.5 border-b border-gray-50 font-medium" style={{ color: '#0D1B1A' }}>{im.nome}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#0F6E56' }}>{formatCurrency(im.receita || 0)}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#A32D2D' }}>{formatCurrency(im.rendaPaga || 0)}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#A32D2D' }}>{formatCurrency(im.custosOperacionais || 0)}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: (im.resultadoLiquido || 0) >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(im.resultadoLiquido || 0)}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: (im.resultadoLiquidoPct || 0) >= 0 ? '#0F6E56' : '#A32D2D' }}>{(im.resultadoLiquidoPct || 0).toFixed(1)}%</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right">
                  <span style={{ color: (im.ratiCobertura || 0) > 1.5 ? '#0F6E56' : (im.ratiCobertura || 0) >= 1.0 ? '#633806' : '#A32D2D' }}>
                    {(im.ratiCobertura || 0).toFixed(2)}
                  </span>
                </td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right">
                  {im.ocupacao ? `${im.ocupacao.ocupados}/${im.ocupacao.total}` : '—'}
                </td>
              </tr>
            ))}
            {/* TOTAIS */}
            <tr className="border-t-2 border-[#0D1B1A]">
              <td className="px-3 py-2.5 font-bold" style={{ color: '#0D1B1A' }}>TOTAIS</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: '#0F6E56' }}>{formatCurrency(g.receitaTotal || 0)}</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: '#A32D2D' }}>{formatCurrency(g.rendaPagaTotal || 0)}</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: '#A32D2D' }}>{formatCurrency(g.custosOperacionaisTotal || 0)}</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: (g.resultadoLiquido || 0) >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(g.resultadoLiquido || 0)}</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: (g.margemBrutaPct || 0) >= 0 ? '#0F6E56' : '#A32D2D' }}>{(g.margemBrutaPct || 0).toFixed(1)}%</td>
              <td className="px-3 py-2.5 text-right font-bold">
                <span style={{ color: (g.ratiCobertura || 0) > 1.5 ? '#0F6E56' : (g.ratiCobertura || 0) >= 1.0 ? '#633806' : '#A32D2D' }}>
                  {(g.ratiCobertura || 0).toFixed(2)}
                </span>
              </td>
              <td className="px-3 py-2.5 text-right font-bold">{totalFracoes > 0 ? `${totalOcupados}/${totalFracoes}` : '—'}</td>
            </tr>
          </tbody>
        </table>
      </Card>

      {/* Section 3 — Cash Flow / Evolucao Mensal */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Evolucao Mensal</h3>
        <div style={{ width: '100%', height: 350 }}>
          <ResponsiveContainer width="100%" height="100%">
            <ComposedChart data={evolucao}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey="mes" tick={{ fontSize: 11, fill: '#6B7280' }} />
              <YAxis tick={{ fontSize: 11, fill: '#6B7280' }} tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`} />
              <Tooltip formatter={(value) => formatCurrency(Number(value))} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Bar dataKey="receita" name="Receita" fill="#1D9E75" radius={[2, 2, 0, 0]} />
              <Bar dataKey="custos" name="Custos" fill="#E24B4A" radius={[2, 2, 0, 0]} />
              <Line type="monotone" dataKey="resultado" name="Resultado" stroke="#0C447C" strokeWidth={2} dot={{ r: 3 }} />
            </ComposedChart>
          </ResponsiveContainer>
        </div>
      </Card>

      {/* Section 4 — Indicadores de Risco */}
      <div>
        <h2 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>Indicadores de Risco</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <KpiCard label="Taxa de Vacancia" value={`${taxaVacancia.toFixed(1)}%`} sub="quartos vagos / total" color={taxaVacancia > 20 ? 'red' : 'amber'} />
          <KpiCard label="Concentracao Receita" value={`${concentracao.toFixed(1)}%`} sub="% do maior imovel" color={concentracao > 50 ? 'red' : 'amber'} />
          <KpiCard label="Racio Cobertura" value={(g.ratiCobertura || 0).toFixed(2)} color={(g.ratiCobertura || 0) > 1.5 ? 'green' : (g.ratiCobertura || 0) >= 1.0 ? 'amber' : 'red'} />
          <KpiCard label="Menos Rentavel" value={menosRentavel.nome || '—'} sub={`Margem: ${(menosRentavel.resultadoLiquidoPct || 0).toFixed(1)}%`} color="red" />
        </div>
      </div>

      {/* Section 5 — Previsao IRC */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Previsao IRC</h3>
        <div className="space-y-3 text-[13px]">
          <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Resultado antes de impostos</span><span>{formatCurrency(irc.resultadoAntesImpostos || g.resultadoLiquido || 0)}</span></div>
          <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Materia coletavel</span><span>{formatCurrency(irc.mc || 0)}</span></div>
          <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Coleta IRC (PME)</span><span>{formatCurrency(irc.coleta || 0)}</span></div>
          <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Derrama municipal</span><span>{formatCurrency(irc.derrama || 0)}</span></div>
          <div className="flex justify-between pt-2 border-t border-gray-200">
            <span className="font-bold text-base" style={{ color: '#0D1B1A' }}>IRC Total Estimado</span>
            <span className="font-bold text-base" style={{ color: '#633806' }}>{formatCurrency(irc.ircTotal || 0)}</span>
          </div>
          <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Taxa efectiva</span><span>{(irc.taxaEfetiva || 0).toFixed(1)}%</span></div>
          <div className="flex justify-between pt-2 border-t border-gray-100"><span style={{ color: '#6B7280' }}>Retencoes na fonte (25% rendas pagas)</span><span>{formatCurrency(irc.retencoesFeitasTotal || 0)}</span></div>
          <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Pagamento por Conta (80% IRC)</span><span>{formatCurrency((irc.ircTotal || 0) * 0.8)}</span></div>
        </div>
      </Card>
    </div>
  )
}
