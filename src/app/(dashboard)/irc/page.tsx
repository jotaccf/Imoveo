'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { KpiCard } from '@/components/ui/KpiCard'
import { formatCurrency } from '@/lib/utils'
import {
  ResponsiveContainer, LineChart, Line,
  XAxis, YAxis, Tooltip, CartesianGrid,
} from 'recharts'

const MESES = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiData = any

export default function IRCPage() {
  const [ano, setAno] = useState(new Date().getFullYear())
  const [years, setYears] = useState<number[]>([new Date().getFullYear()])
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

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!raw) return <div className="text-sm text-gray-400">Sem dados</div>

  const g = raw.global || {}
  const irc = raw.irc || {}
  const cfg = raw.config || {}
  const evolucao = (raw.evolucaoMensal || []).map((m: ApiData, i: number) => ({
    mes: MESES[i] || `M${i + 1}`,
    ircAcumulado: m.ircAcumulado || 0,
  }))

  const resultadoAI = g.resultadoLiquido || 0
  const mc = irc.materiaColetavel || irc.mc || 0
  const limitePme = cfg.limitePme || 50000
  const taxaPme = cfg.taxaIrcPme || 17
  const taxaNormal = cfg.taxaIrcNormal || 21
  const derramaPct = cfg.derramaMunicipal || 1.5
  const taxaRetencao = cfg.taxaRetencao || 25

  const coletaPme = Math.min(mc, limitePme) * (taxaPme / 100)
  const coletaNormal = Math.max(mc - limitePme, 0) * (taxaNormal / 100)
  const coletaSubtotal = irc.coleta || (coletaPme + coletaNormal)
  const derramaValor = irc.derrama || (Math.max(resultadoAI, 0) * derramaPct / 100)
  const ircTotal = irc.ircTotal || (coletaSubtotal + derramaValor)
  const taxaEfetiva = irc.taxaEfetiva || (resultadoAI > 0 ? (ircTotal / resultadoAI) * 100 : 0)

  const rendaPagaTotal = g.rendaPagaTotal || 0
  const retencao25 = rendaPagaTotal * (taxaRetencao / 100)
  const ppc = ircTotal * 0.8
  const prestacao = ppc / 3

  return (
    <div className="space-y-5">
      <div className="flex items-center gap-2">
        {years.map((y) => (
          <Button key={y} variant={y === ano ? 'primary' : 'secondary'} onClick={() => setAno(y)}>{y}</Button>
        ))}
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <KpiCard label="Resultado Antes Impostos" value={formatCurrency(resultadoAI)} color={resultadoAI >= 0 ? 'green' : 'red'} />
        <KpiCard label="IRC Estimado Total" value={formatCurrency(ircTotal)} color="amber" />
        <KpiCard label="Taxa Efectiva" value={`${taxaEfetiva.toFixed(1)}%`} />
        <KpiCard label="Retencoes Entregues" value={formatCurrency(retencao25)} sub="25% das rendas pagas" />
      </div>

      {/* IRC Calculation Breakdown */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Calculo Detalhado do IRC</h3>
        <div className="space-y-2.5 text-[13px]">
          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>1. Receita total</span>
            <span>{formatCurrency(g.receitaTotal || 0)}</span>
          </div>
          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>2. (-) Custos dedutiveis</span>
            <span style={{ color: '#A32D2D' }}>{formatCurrency(g.custoTotal || 0)}</span>
          </div>
          <div className="flex justify-between pt-1 border-t border-gray-100">
            <span className="font-medium">3. (=) Lucro tributavel</span>
            <span className="font-medium" style={{ color: resultadoAI >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(resultadoAI)}</span>
          </div>

          {(irc.prejuizoDisponivel || 0) > 0 && (
            <>
              <div className="flex justify-between pl-4">
                <span style={{ color: '#6B7280' }}>(-) Deducao prejuizos anos anteriores (max 65%)</span>
                <span style={{ color: '#A32D2D' }}>-{formatCurrency(irc.deducaoPrejuizos || 0)}</span>
              </div>
              <div className="flex justify-between pl-4 text-[11px]">
                <span style={{ color: '#9CA3AF' }}>Prejuizos disponiveis: {formatCurrency(irc.prejuizoDisponivel || 0)} | A reportar: {formatCurrency(irc.prejuizoRestante || 0)}</span>
              </div>
              <div className="flex justify-between pt-1 border-t border-gray-50">
                <span className="font-medium">(=) Materia colectavel</span>
                <span className="font-medium">{formatCurrency(mc)}</span>
              </div>
            </>
          )}

          <div className="pt-2"><span className="font-medium">4. Coleta IRC (regime PME):</span></div>
          <div className="flex justify-between pl-4">
            <span style={{ color: '#6B7280' }}>Primeiros {formatCurrency(limitePme)} x {taxaPme}%</span>
            <span>{formatCurrency(coletaPme)}</span>
          </div>
          <div className="flex justify-between pl-4">
            <span style={{ color: '#6B7280' }}>Restante x {taxaNormal}%</span>
            <span>{formatCurrency(coletaNormal)}</span>
          </div>
          <div className="flex justify-between pl-4 pt-1 border-t border-gray-50">
            <span style={{ color: '#6B7280' }}>Subtotal coleta</span>
            <span className="font-medium">{formatCurrency(coletaSubtotal)}</span>
          </div>

          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>5. (+) Derrama municipal ({derramaPct}% sobre lucro tributavel)</span>
            <span>{formatCurrency(derramaValor)}</span>
          </div>

          <div className="flex justify-between pt-3 border-t-2 border-brand-black">
            <span className="font-bold text-base">6. (=) IRC Total</span>
            <span className="font-bold text-base" style={{ color: '#633806' }}>{formatCurrency(ircTotal)}</span>
          </div>

          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>7. Taxa efectiva</span>
            <span>{taxaEfetiva.toFixed(1)}%</span>
          </div>
        </div>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Retencoes na Fonte */}
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Retencoes na Fonte</h3>
          <div className="space-y-2.5 text-[13px]">
            <div className="flex justify-between">
              <span style={{ color: '#6B7280' }}>Total rendas pagas aos senhorios</span>
              <span>{formatCurrency(rendaPagaTotal)}</span>
            </div>
            <div className="flex justify-between">
              <span style={{ color: '#6B7280' }}>Retencao {taxaRetencao}%</span>
              <span>{formatCurrency(retencao25)}</span>
            </div>
            <div className="flex justify-between pt-2 border-t border-gray-100">
              <span className="font-medium">Entregues a AT (acumulado)</span>
              <span className="font-medium">{formatCurrency(retencao25)}</span>
            </div>
          </div>
        </Card>

        {/* Pagamento por Conta */}
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Pagamento por Conta</h3>
          <div className="space-y-2.5 text-[13px]">
            <div className="flex justify-between">
              <span style={{ color: '#6B7280' }}>Estimativa anual (80% do IRC)</span>
              <span className="font-medium">{formatCurrency(ppc)}</span>
            </div>
            <div className="pt-2 border-t border-gray-100">
              <div className="text-[11px] font-medium mb-2" style={{ color: '#6B7280' }}>3 Prestacoes:</div>
              <div className="space-y-1.5">
                <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Julho</span><span>{formatCurrency(prestacao)}</span></div>
                <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Setembro</span><span>{formatCurrency(prestacao)}</span></div>
                <div className="flex justify-between"><span style={{ color: '#6B7280' }}>Dezembro</span><span>{formatCurrency(prestacao)}</span></div>
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Evolucao Mensal IRC */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Evolucao Mensal IRC (acumulado)</h3>
        <div style={{ width: '100%', height: 300 }}>
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={evolucao}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey="mes" tick={{ fontSize: 11, fill: '#6B7280' }} />
              <YAxis tick={{ fontSize: 11, fill: '#6B7280' }} tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`} />
              <Tooltip formatter={(value) => formatCurrency(Number(value))} />
              <Line type="monotone" dataKey="ircAcumulado" name="IRC Acumulado" stroke="#633806" strokeWidth={2} dot={{ r: 3, fill: '#633806' }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </Card>
    </div>
  )
}
