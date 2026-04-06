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

export default function AnalisePage() {
  const [ano, setAno] = useState(new Date().getFullYear())
  const [years, setYears] = useState<number[]>([new Date().getFullYear()])
  const [data, setData] = useState<ApiData>(null)
  const [loading, setLoading] = useState(true)

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
      {/* Year selector + PDF export */}
      <div className="flex items-center gap-2">
        {years.map((y) => (
          <Button key={y} variant={y === ano ? 'primary' : 'secondary'} onClick={() => setAno(y)}>{y}</Button>
        ))}
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
