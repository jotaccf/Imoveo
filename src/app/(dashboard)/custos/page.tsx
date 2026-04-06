'use client'

import { useEffect, useState, useMemo } from 'react'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Select } from '@/components/ui/Select'
import { KpiCard } from '@/components/ui/KpiCard'
import { formatCurrency } from '@/lib/utils'
import {
  ResponsiveContainer, PieChart, Pie, Cell,
  AreaChart, Area, XAxis, YAxis, Tooltip, Legend, CartesianGrid,
} from 'recharts'

const MESES = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']
const PIE_COLORS = ['#1D9E75', '#0F6E56', '#E24B4A', '#0C447C', '#633806', '#3C3489', '#085041', '#791F1F', '#6B7280', '#9CA3AF']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiData = any

export default function CustosPage() {
  const [ano, setAno] = useState(new Date().getFullYear())
  const [years, setYears] = useState<number[]>([new Date().getFullYear()])
  const [imovelId, setImovelId] = useState('')
  const [raw, setRaw] = useState<ApiData>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/anos').then(r => r.json()).then(j => { if (j.data) setYears(j.data) }).catch(() => {})
  }, [])

  useEffect(() => {
    setLoading(true)
    fetch(`/api/analise?ano=${ano}`)
      .then((r) => r.json())
      .then((j) => { if (j.data) setRaw(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [ano])

  // Derive cost data from the API response, optionally filtered by imovel
  const data = useMemo(() => {
    if (!raw) return null
    const imoveis: ApiData[] = raw.imoveis || []
    const source = imovelId ? imoveis.filter((im: ApiData) => im.id === imovelId) : imoveis

    // Aggregate costs by rubrica
    const rubricaMap: Record<string, { nome: string; valor: number }> = {}
    let custoTotal = 0
    let receitaTotal = 0
    let rendaPagaTotal = 0

    for (const im of source) {
      receitaTotal += im.receita || 0
      rendaPagaTotal += im.rendaPaga || 0
      for (const cr of (im.custosPorRubrica || [])) {
        if (!rubricaMap[cr.rubricaId]) rubricaMap[cr.rubricaId] = { nome: cr.rubricaNome, valor: 0 }
        rubricaMap[cr.rubricaId].valor += cr.valor || 0
        custoTotal += cr.valor || 0
      }
    }

    const rubricas = Object.values(rubricaMap)
      .filter((r) => r.valor > 0)
      .map((r) => ({ ...r, percentagem: custoTotal > 0 ? (r.valor / custoTotal) * 100 : 0 }))
      .sort((a, b) => b.valor - a.valor)

    const rubricaMaisCara = rubricas[0] || { nome: '—', valor: 0 }
    const custoMedioMensal = custoTotal / 12
    const custoPercentReceita = receitaTotal > 0 ? (custoTotal / receitaTotal) * 100 : 0
    const ratiCobertura = (rendaPagaTotal + custoTotal) > 0 ? receitaTotal / (rendaPagaTotal + custoTotal) : 0

    // Monthly evolution per rubrica
    const top5 = rubricas.slice(0, 5).map((r) => r.nome)
    const mensal = MESES.map((mes, i) => {
      const row: Record<string, string | number> = { mes }
      let outrosTotal = 0
      for (const im of source) {
        const m = (im.meses || [])[i]
        if (!m) continue
        // We only have total costs per month per property, not per rubrica per month
        // Use proportional distribution
      }
      // Simplified: distribute monthly total proportionally across rubricas
      let totalMes = 0
      for (const im of source) {
        const m = (im.meses || [])[i]
        if (m) totalMes += m.custos || 0
      }
      for (const r of rubricas) {
        const proporcao = custoTotal > 0 ? r.valor / custoTotal : 0
        const valorMes = totalMes * proporcao
        if (top5.includes(r.nome)) {
          row[r.nome] = Math.round(valorMes * 100) / 100
        } else {
          outrosTotal += valorMes
        }
      }
      if (outrosTotal > 0) row['Outros'] = Math.round(outrosTotal * 100) / 100
      return row
    })

    const areaKeys = [...top5]
    if (mensal.some((d) => (d['Outros'] as number) > 0)) areaKeys.push('Outros')

    return {
      custoTotal, receitaTotal, custoPercentReceita, custoMedioMensal,
      rubricaMaisCara, ratiCobertura, rubricas, mensal, areaKeys,
      imovelOptions: imoveis.map((im: ApiData) => ({ value: im.id, label: `${im.codigo} - ${im.nome}` })),
    }
  }, [raw, imovelId])

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!data) return <div className="text-sm text-gray-400">Sem dados</div>

  const maxRubricaValor = data.rubricas.length > 0 ? Math.max(...data.rubricas.map((r: { valor: number }) => r.valor)) : 1

  return (
    <div className="space-y-5">
      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="flex items-center gap-2">
          {years.map((y) => (
            <Button key={y} variant={y === ano ? 'primary' : 'secondary'} onClick={() => setAno(y)}>{y}</Button>
          ))}
        </div>
        <div className="w-56">
          <Select
            options={[{ value: '', label: 'Todos os imoveis' }, ...data.imovelOptions]}
            value={imovelId}
            onChange={(e) => setImovelId(e.target.value)}
          />
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
        <KpiCard label="Custo Operacional Total" value={formatCurrency(data.custoTotal)} color="red" />
        <KpiCard label="Custo % da Receita" value={`${data.custoPercentReceita.toFixed(1)}%`} color="amber" />
        <KpiCard label="Custo Medio Mensal" value={formatCurrency(data.custoMedioMensal)} />
        <KpiCard label="Rubrica Mais Cara" value={data.rubricaMaisCara.nome} sub={formatCurrency(data.rubricaMaisCara.valor)} />
        <KpiCard label="Racio Cobertura" value={data.ratiCobertura.toFixed(2)} color={data.ratiCobertura > 1.5 ? 'green' : data.ratiCobertura >= 1.0 ? 'amber' : 'red'} />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Donut */}
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Distribuicao por Rubrica</h3>
          <div style={{ width: '100%', height: 280 }}>
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={data.rubricas} dataKey="valor" nameKey="nome" cx="40%" cy="50%" innerRadius={60} outerRadius={100} paddingAngle={2}>
                  {data.rubricas.map((_: unknown, i: number) => (
                    <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Legend layout="vertical" align="right" verticalAlign="middle" wrapperStyle={{ fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Stacked Area */}
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Evolucao Mensal de Custos</h3>
          <div style={{ width: '100%', height: 280 }}>
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data.mensal}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="mes" tick={{ fontSize: 11, fill: '#6B7280' }} />
                <YAxis tick={{ fontSize: 11, fill: '#6B7280' }} tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Legend wrapperStyle={{ fontSize: 11 }} />
                {data.areaKeys.map((key: string, i: number) => (
                  <Area key={key} type="monotone" dataKey={key} stackId="1" fill={PIE_COLORS[i % PIE_COLORS.length]} stroke={PIE_COLORS[i % PIE_COLORS.length]} fillOpacity={0.7} />
                ))}
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>
      </div>

      {/* Ranking */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Ranking de Rubricas</h3>
        <div className="space-y-2">
          {data.rubricas.map((rubrica: { nome: string; valor: number; percentagem: number }, i: number) => (
            <div key={rubrica.nome} className="flex items-center gap-3">
              <div className="w-36 text-[13px] font-medium truncate" style={{ color: '#0D1B1A' }}>{rubrica.nome}</div>
              <div className="flex-1 h-6 rounded overflow-hidden" style={{ backgroundColor: '#F3F4F6' }}>
                <div className="h-full rounded" style={{ width: `${(rubrica.valor / maxRubricaValor) * 100}%`, backgroundColor: PIE_COLORS[i % PIE_COLORS.length], transition: 'width 0.3s ease' }} />
              </div>
              <div className="text-[13px] font-medium w-24 text-right" style={{ color: '#0D1B1A' }}>{formatCurrency(rubrica.valor)}</div>
              <div className="text-[11px] w-12 text-right" style={{ color: '#9CA3AF' }}>{rubrica.percentagem.toFixed(1)}%</div>
            </div>
          ))}
        </div>
      </Card>
    </div>
  )
}
