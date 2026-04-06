'use client'

import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { KpiCard } from '@/components/ui/KpiCard'
import { Button } from '@/components/ui/Button'
import { formatCurrency } from '@/lib/utils'
import {
  ResponsiveContainer, ComposedChart, Bar, Line,
  XAxis, YAxis, Tooltip, CartesianGrid, Legend,
} from 'recharts'

const MESES = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

const ESTADO_BADGE: Record<string, 'green' | 'red' | 'amber' | 'gray'> = {
  ACTIVO: 'green', VAGO: 'red', EM_OBRAS: 'amber', INACTIVO: 'gray',
}

const FRACAO_ESTADO_BADGE: Record<string, 'green' | 'red' | 'amber'> = {
  OCUPADO: 'green', VAGO: 'red', EM_OBRAS: 'amber',
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Any = any

function n(v: unknown): number {
  if (v === null || v === undefined) return 0
  return Number(v) || 0
}

function yieldColor(v: number | null): 'green' | 'amber' | 'red' | 'default' {
  if (v === null) return 'default'
  if (v > 5) return 'green'
  if (v >= 3.5) return 'amber'
  return 'red'
}

function yieldLiqColor(v: number | null): 'green' | 'amber' | 'red' | 'default' {
  if (v === null) return 'default'
  if (v > 4) return 'green'
  if (v >= 2.5) return 'amber'
  return 'red'
}

function margemColor(v: number): 'green' | 'amber' | 'red' {
  if (v > 25) return 'green'
  if (v >= 15) return 'amber'
  return 'red'
}

function racioColor(v: number): 'green' | 'amber' | 'red' {
  if (v > 1.40) return 'green'
  if (v >= 1.15) return 'amber'
  return 'red'
}

export default function ImovelDetailPage() {
  const params = useParams()
  const id = params?.id as string

  const currentYear = new Date().getFullYear()
  const [ano, setAno] = useState(currentYear)
  const [imovel, setImovel] = useState<Any>(null)
  const [analise, setAnalise] = useState<Any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!id) return
    setLoading(true)

    Promise.all([
      fetch('/api/imoveis').then((r) => r.json()),
      fetch(`/api/analise?ano=${ano}`).then((r) => r.json()),
    ])
      .then(([imoveisRes, analiseRes]) => {
        const imList = imoveisRes.data || []
        const found = imList.find((im: Any) => im.id === id)
        setImovel(found || null)

        const analiseImoveis = analiseRes.data?.imoveis || []
        const foundAnalise = analiseImoveis.find((im: Any) => im.id === id)
        setAnalise(foundAnalise || null)
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [id, ano])

  const [years, setYears] = useState<number[]>([currentYear])
  useEffect(() => {
    fetch('/api/anos').then(r => r.json()).then(j => { if (j.data) setYears(j.data) }).catch(() => {})
  }, [])

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!imovel) return <div className="text-sm text-gray-400">Imovel nao encontrado</div>

  // --- Computed values ---
  const receita = n(analise?.receita)
  const rendaPaga = n(analise?.rendaPaga)
  const custosOperacionais = n(analise?.custosOperacionais)
  const custoTotal = n(analise?.custoTotal)
  const valorPatrimonial = analise?.valorPatrimonial != null ? n(analise.valorPatrimonial) : (imovel.valorPatrimonial != null ? n(imovel.valorPatrimonial) : null)

  const yieldBruta = valorPatrimonial && valorPatrimonial > 0 ? (receita / valorPatrimonial) * 100 : null
  const yieldLiquida = valorPatrimonial && valorPatrimonial > 0 ? ((receita - custoTotal) / valorPatrimonial) * 100 : null
  const margemOperacional = receita > 0 ? ((receita - custoTotal) / receita) * 100 : 0
  const racioCob = (rendaPaga * 1.25 + custosOperacionais) > 0 ? receita / (rendaPaga * 1.25 + custosOperacionais) : 0
  const cashFlowMensal = (receita - custoTotal) / 12

  // Occupancy
  const fracoes = analise?.fracoes || imovel.fracoes || []
  const totalFracoes = fracoes.length
  const ocupados = fracoes.filter((f: Any) => f.estado === 'OCUPADO').length
  const taxaOcupacao = totalFracoes > 0 ? (ocupados / totalFracoes) * 100 : null

  // Cost breakdown
  const custosPorRubrica: { rubricaNome: string; valor: number; rubricaId: string }[] = analise?.custosPorRubrica || []
  const maxCusto = custosPorRubrica.length > 0 ? Math.max(...custosPorRubrica.map((c: Any) => n(c.valor))) : 1
  const totalCustos = custosPorRubrica.reduce((s: number, c: Any) => s + n(c.valor), 0)

  // Monthly evolution
  const meses = (analise?.meses || []).map((m: Any, i: number) => ({
    mes: MESES[i] || `M${i + 1}`,
    receita: n(m.receita),
    custos: n(m.custos),
    resultado: n(m.receita) - n(m.custos),
  }))

  // --- Verdicts ---
  const verdicts: { text: string; variant: 'green' | 'amber' | 'red' }[] = []

  if (yieldBruta !== null && yieldBruta >= 5) verdicts.push({ text: 'Yield bruta acima da media', variant: 'green' })
  if (yieldBruta !== null && yieldBruta < 3.5) verdicts.push({ text: 'Yield bruta abaixo do minimo', variant: 'red' })
  if (yieldLiquida !== null && yieldLiquida >= 4) verdicts.push({ text: 'Yield liquida saudavel', variant: 'green' })
  if (yieldLiquida !== null && yieldLiquida < 2.5) verdicts.push({ text: 'Yield liquida insuficiente', variant: 'red' })
  if (margemOperacional > 25) verdicts.push({ text: 'Margem operacional saudavel', variant: 'green' })
  if (margemOperacional > 0 && margemOperacional < 15) verdicts.push({ text: 'Margem operacional fraca', variant: 'red' })
  if (racioCob >= 1.40) verdicts.push({ text: 'Racio de cobertura confortavel', variant: 'green' })
  if (racioCob > 0 && racioCob < 1.15) verdicts.push({ text: 'Racio de cobertura critico', variant: 'red' })
  if (taxaOcupacao !== null && taxaOcupacao >= 90) verdicts.push({ text: 'Taxa de ocupacao excelente', variant: 'green' })
  if (taxaOcupacao !== null && taxaOcupacao < 80) verdicts.push({ text: 'Taxa de ocupacao baixa', variant: 'amber' })
  if (cashFlowMensal < 0) verdicts.push({ text: 'Cash flow negativo', variant: 'red' })
  if (cashFlowMensal > 0) verdicts.push({ text: 'Cash flow positivo', variant: 'green' })

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          <Link href="/imoveis">
            <Button variant="ghost" className="px-2 py-1 text-[13px]">&larr; Voltar</Button>
          </Link>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-lg font-semibold" style={{ color: '#0D1B1A' }}>{imovel.nome}</h1>
              <Badge variant={ESTADO_BADGE[imovel.estado] ?? 'gray'}>{(imovel.estado || '').replace('_', ' ')}</Badge>
            </div>
            <div className="text-[12px] text-gray-500 mt-0.5">
              <span className="font-mono">{imovel.codigo}</span>
              <span className="mx-1.5">&middot;</span>
              <span>{imovel.tipo}</span>
              <span className="mx-1.5">&middot;</span>
              <span>{imovel.localizacao}</span>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {years.map((y) => (
            <Button key={y} variant={y === ano ? 'primary' : 'secondary'} onClick={() => setAno(y)} className="text-[13px] px-3 py-1.5">{y}</Button>
          ))}
        </div>
      </div>

      {/* Section 1: KPI Cards */}
      <div>
        <h2 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>Indicadores Financeiros</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
          <KpiCard
            label="Yield Bruta"
            value={yieldBruta !== null ? `${yieldBruta.toFixed(1)}%` : '\u2014'}
            sub={valorPatrimonial ? `s/ ${formatCurrency(valorPatrimonial)}` : 'Sem valor patrimonial'}
            color={yieldColor(yieldBruta)}
          />
          <KpiCard
            label="Yield Liquida"
            value={yieldLiquida !== null ? `${yieldLiquida.toFixed(1)}%` : '\u2014'}
            sub="receita - custos / VP"
            color={yieldLiqColor(yieldLiquida)}
          />
          <KpiCard
            label="Margem Operacional"
            value={receita > 0 ? `${margemOperacional.toFixed(1)}%` : '\u2014'}
            sub={`${formatCurrency(receita - custoTotal)} resultado`}
            color={receita > 0 ? margemColor(margemOperacional) : 'default'}
          />
          <KpiCard
            label="Racio Cobertura"
            value={racioCob > 0 ? racioCob.toFixed(2) : '\u2014'}
            sub="receita / (renda*1.25 + ops)"
            color={racioCob > 0 ? racioColor(racioCob) : 'default'}
          />
          <KpiCard
            label="Cash Flow Mensal"
            value={formatCurrency(cashFlowMensal)}
            sub={`${formatCurrency(receita - custoTotal)} anual`}
            color={cashFlowMensal >= 0 ? 'green' : 'red'}
          />
          <KpiCard
            label="Taxa Ocupacao"
            value={taxaOcupacao !== null ? `${taxaOcupacao.toFixed(0)}%` : '\u2014'}
            sub={totalFracoes > 0 ? `${ocupados}/${totalFracoes} quartos` : 'Sem fracoes'}
            color={taxaOcupacao !== null ? (taxaOcupacao >= 90 ? 'green' : taxaOcupacao >= 70 ? 'amber' : 'red') : 'default'}
          />
        </div>
      </div>

      {/* Section 2: Cost Decomposition + Verdicts */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
        {/* Left — Decomposicao de Custos (60%) */}
        <Card className="lg:col-span-3">
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Decomposicao de Custos</h3>
          {custosPorRubrica.length === 0 ? (
            <p className="text-[13px] text-gray-400">Sem custos registados para {ano}</p>
          ) : (
            <div className="space-y-2.5">
              {custosPorRubrica.map((c: Any) => {
                const valor = n(c.valor)
                const pctTotal = totalCustos > 0 ? (valor / totalCustos) * 100 : 0
                const barWidth = maxCusto > 0 ? (valor / maxCusto) * 100 : 0
                const isRenda = (c.rubricaNome || '').toLowerCase().includes('renda')
                return (
                  <div key={c.rubricaId || c.rubricaNome}>
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-[12px] font-medium" style={{ color: '#374151' }}>{c.rubricaNome || 'Sem rubrica'}</span>
                      <span className="text-[12px] font-mono" style={{ color: '#6B7280' }}>
                        {formatCurrency(valor)} <span className="text-[10px]">({pctTotal.toFixed(1)}%)</span>
                      </span>
                    </div>
                    <div className="w-full h-3 rounded-full" style={{ background: '#F3F4F6' }}>
                      <div
                        className="h-3 rounded-full transition-all"
                        style={{ width: `${barWidth}%`, background: isRenda ? '#E24B4A' : '#1D9E75' }}
                      />
                    </div>
                  </div>
                )
              })}
              <div className="flex justify-between pt-3 border-t border-gray-100 mt-3">
                <span className="text-[12px] font-semibold" style={{ color: '#0D1B1A' }}>Total Custos</span>
                <span className="text-[12px] font-mono font-semibold" style={{ color: '#0D1B1A' }}>{formatCurrency(totalCustos)}</span>
              </div>
            </div>
          )}
        </Card>

        {/* Right — Avaliacao (40%) */}
        <Card className="lg:col-span-2">
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Avaliacao</h3>
          {verdicts.length === 0 ? (
            <p className="text-[13px] text-gray-400">Sem dados suficientes para avaliacao</p>
          ) : (
            <div className="flex flex-wrap gap-2">
              {verdicts.map((v, i) => (
                <Badge key={i} variant={v.variant} className="text-[12px] px-3 py-1">
                  {v.variant === 'green' && <span className="mr-1">&#10003;</span>}
                  {v.variant === 'red' && <span className="mr-1">&#10007;</span>}
                  {v.variant === 'amber' && <span className="mr-1">&#9888;</span>}
                  {v.text}
                </Badge>
              ))}
            </div>
          )}
        </Card>
      </div>

      {/* Section 3: Quartos */}
      {totalFracoes > 0 && (
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Quartos / Fracoes</h3>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-[13px]">
              <thead>
                <tr>
                  {['Nome', 'Renda', 'NIF Inquilino', 'Estado'].map((h) => (
                    <th key={h} className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {fracoes.map((f: Any) => (
                  <tr key={f.id} className="hover:bg-gray-50">
                    <td className="px-3 py-2.5 border-b border-gray-50 font-medium" style={{ color: '#0D1B1A' }}>{f.nome}</td>
                    <td className="px-3 py-2.5 border-b border-gray-50 font-mono" style={{ color: '#0F6E56' }}>{formatCurrency(n(f.renda))}</td>
                    <td className="px-3 py-2.5 border-b border-gray-50 font-mono text-gray-500">{f.nifInquilino || '\u2014'}</td>
                    <td className="px-3 py-2.5 border-b border-gray-50">
                      <Badge variant={FRACAO_ESTADO_BADGE[f.estado] ?? 'gray'}>{(f.estado || '').replace('_', ' ')}</Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="flex items-center gap-6 mt-4 pt-3 border-t border-gray-100 text-[12px]">
            <div>
              <span className="text-gray-500">Renda mensal total: </span>
              <span className="font-mono font-medium" style={{ color: '#0F6E56' }}>
                {formatCurrency(fracoes.filter((f: Any) => f.estado === 'OCUPADO').reduce((s: number, f: Any) => s + n(f.renda), 0))}
              </span>
            </div>
            <div>
              <span className="text-gray-500">Potencial anual: </span>
              <span className="font-mono font-medium" style={{ color: '#0D1B1A' }}>
                {formatCurrency(fracoes.reduce((s: number, f: Any) => s + n(f.renda), 0) * 12)}
              </span>
            </div>
            <div>
              <span className="text-gray-500">Ocupacao: </span>
              <span className="font-medium" style={{ color: taxaOcupacao !== null && taxaOcupacao >= 80 ? '#0F6E56' : '#A32D2D' }}>
                {taxaOcupacao !== null ? `${taxaOcupacao.toFixed(0)}%` : '\u2014'}
              </span>
            </div>
          </div>
        </Card>
      )}

      {/* Section 4: Evolucao Mensal */}
      {meses.length > 0 && (
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Evolucao Mensal</h3>
          <div style={{ width: '100%', height: 350 }}>
            <ResponsiveContainer width="100%" height="100%">
              <ComposedChart data={meses}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="mes" tick={{ fontSize: 11, fill: '#6B7280' }} />
                <YAxis tick={{ fontSize: 11, fill: '#6B7280' }} tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`} />
                <Tooltip formatter={(value: number) => formatCurrency(value)} />
                <Legend wrapperStyle={{ fontSize: 12 }} />
                <Bar dataKey="receita" name="Receita" fill="#1D9E75" radius={[2, 2, 0, 0]} />
                <Bar dataKey="custos" name="Custos" fill="#9CA3AF" radius={[2, 2, 0, 0]} />
                <Line type="monotone" dataKey="resultado" name="Resultado" stroke="#0C447C" strokeWidth={2} dot={{ r: 3 }} />
              </ComposedChart>
            </ResponsiveContainer>
          </div>
        </Card>
      )}

      {/* Section 5: Informacoes do Imovel */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Informacoes do Imovel</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-y-4 gap-x-6 text-[13px]">
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>Codigo</div>
            <div className="font-mono" style={{ color: '#0D1B1A' }}>{imovel.codigo}</div>
          </div>
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>Tipo</div>
            <div style={{ color: '#0D1B1A' }}>{imovel.tipo}</div>
          </div>
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>Localizacao</div>
            <div style={{ color: '#0D1B1A' }}>{imovel.localizacao}</div>
          </div>
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>Morada</div>
            <div style={{ color: '#0D1B1A' }}>{imovel.morada || '\u2014'}</div>
          </div>
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>NIF Proprietario</div>
            <div className="font-mono" style={{ color: '#0D1B1A' }}>{imovel.nifProprietario || '\u2014'}</div>
          </div>
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>Valor Patrimonial</div>
            <div className="font-mono" style={{ color: '#0D1B1A' }}>{valorPatrimonial ? formatCurrency(valorPatrimonial) : '\u2014'}</div>
          </div>
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>Area m&sup2;</div>
            <div style={{ color: '#0D1B1A' }}>{imovel.areaMt2 ? `${n(imovel.areaMt2).toFixed(0)} m\u00B2` : '\u2014'}</div>
          </div>
          <div>
            <div className="text-[11px] font-medium mb-0.5" style={{ color: '#6B7280' }}>Estado</div>
            <Badge variant={ESTADO_BADGE[imovel.estado] ?? 'gray'}>{(imovel.estado || '').replace('_', ' ')}</Badge>
          </div>
        </div>
      </Card>
    </div>
  )
}
