'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/components/ui/Card'
import { formatCurrency } from '@/lib/utils'
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  Legend,
  ReferenceArea,
} from 'recharts'
import { MetricasHoteleirasCards, type MetricasHoteleirasResponse } from '@/components/evolucao/MetricasHoteleirasCards'
import { PipelineWidget, type PipelineResponse } from '@/components/evolucao/PipelineWidget'
import { ConcentracaoRiscoWidget, type ConcentracaoResponse } from '@/components/evolucao/ConcentracaoRiscoWidget'

// ----------------------------------------------------------------------------
// Types — espelho do response de /api/evolucao
// ----------------------------------------------------------------------------

interface Banner {
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

interface AnoCivil {
  ano: number
  receita: number
  custos: number
  resultado: number
  margemPct: number
}

interface MesLectivo {
  mesLectivo: number
  mesNome: string
  receita: number
  custos: number
  resultado: number
}

interface AnoLectivoBlock {
  anoLectivo: string
  isAtual: boolean
  meses: MesLectivo[]
}

interface ImovelHistorico {
  ano: number
  margemPct: number
  receita: number
  custo: number
}

interface ImovelEvol {
  id: string
  codigo: string
  nome: string
  margemActualPct: number
  deltaYoyPct: number
  historico: ImovelHistorico[]
}

interface EvolucaoData {
  banner: Banner
  anosCivis: AnoCivil[]
  anosLectivos: AnoLectivoBlock[]
  imoveis: ImovelEvol[]
}

// ----------------------------------------------------------------------------
// Cores
// ----------------------------------------------------------------------------
const COLOR_GREEN = '#1D9E75'
const COLOR_RED = '#A32D2D'
const COLOR_BLACK = '#0D1B1A'
const COLOR_BLUE = '#0C447C'
const COLOR_GREY_BAR = '#D1D5DB'
const COLOR_AMBER = '#633806'

// Cor por delta margem (pp): >0 verde, entre -10 e 10 âmbar, <-10 vermelho
function colorPorMargem(v: number): string {
  if (v > 0) return '#0F6E56'
  if (v >= -10 && v <= 10) return COLOR_AMBER
  return COLOR_RED
}

// Cor por delta (pp/%) com sinal: positivo verde, negativo vermelho
function colorPorDelta(v: number): string {
  return v >= 0 ? '#0F6E56' : COLOR_RED
}

function formatPct(v: number, casas = 1): string {
  if (!Number.isFinite(v)) return '—'
  return `${v >= 0 ? '+' : ''}${v.toFixed(casas)}%`
}
function formatPp(v: number, casas = 1): string {
  if (!Number.isFinite(v)) return '—'
  return `${v >= 0 ? '+' : ''}${v.toFixed(casas)}pp`
}

// ----------------------------------------------------------------------------
// Página
// ----------------------------------------------------------------------------

export default function EvolucaoPage() {
  const [data, setData] = useState<EvolucaoData | null>(null)
  const [metricas, setMetricas] = useState<MetricasHoteleirasResponse | null>(null)
  const [pipeline, setPipeline] = useState<PipelineResponse | null>(null)
  const [concentracao, setConcentracao] = useState<ConcentracaoResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [anosOcultos, setAnosOcultos] = useState<Set<string>>(new Set())

  useEffect(() => {
    let cancelled = false
    Promise.all([
      fetch('/api/evolucao').then((r) => r.json()).catch(() => null),
      fetch('/api/evolucao/metricas-hoteleiras').then((r) => r.json()).catch(() => null),
      fetch('/api/evolucao/pipeline').then((r) => r.json()).catch(() => null),
      fetch('/api/evolucao/concentracao-risco').then((r) => r.json()).catch(() => null),
    ])
      .then(([evol, met, pip, conc]) => {
        if (cancelled) return
        if (evol?.data) setData(evol.data as EvolucaoData)
        if (met && !met.error) setMetricas(met as MetricasHoteleirasResponse)
        if (pip && !pip.error) setPipeline(pip as PipelineResponse)
        if (conc && !conc.error) setConcentracao(conc as ConcentracaoResponse)
      })
      .finally(() => { if (!cancelled) setLoading(false) })
    return () => { cancelled = true }
  }, [])

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!data) return <div className="text-sm text-gray-400">Sem dados.</div>

  const { banner, anosCivis, anosLectivos, imoveis } = data
  const anoActual = new Date().getFullYear()
  const anoAnterior = anoActual - 1

  // -------- Dados para LineChart (sazonalidade) --------
  // Cria array com 12 pontos (Set..Ago). Cada ponto tem { mesNome, [anoLectivo]: receita, ... }
  const sazonalidadeData: Array<Record<string, number | string>> = []
  if (anosLectivos.length > 0) {
    for (let i = 0; i < 12; i++) {
      const ponto: Record<string, number | string> = {
        mesNome: anosLectivos[0].meses[i]?.mesNome ?? '',
      }
      for (const al of anosLectivos) {
        ponto[al.anoLectivo] = al.meses[i]?.receita ?? 0
      }
      sazonalidadeData.push(ponto)
    }
  }

  // Cor por ano lectivo: actual=verde brand 100%, anteriores em verde com opacity decrescente
  function corAnoLectivo(al: AnoLectivoBlock, idx: number, total: number): { stroke: string; strokeWidth: number; opacity: number } {
    if (al.isAtual) return { stroke: COLOR_GREEN, strokeWidth: 3, opacity: 1 }
    // idx 0 = mais recente (actual). idx 1 = ano-1, etc.
    const ordemAntiguidade = idx // 1, 2, 3, ...
    const minOpacity = 0.2
    const maxOpacity = 0.85
    const range = maxOpacity - minOpacity
    const step = total > 1 ? range / Math.max(total - 1, 1) : 0
    const opacity = Math.max(minOpacity, maxOpacity - step * ordemAntiguidade)
    return { stroke: '#6B7280', strokeWidth: 1.5, opacity }
  }

  function toggleAno(anoLectivo: string) {
    setAnosOcultos((prev) => {
      const next = new Set(prev)
      if (next.has(anoLectivo)) next.delete(anoLectivo)
      else next.add(anoLectivo)
      return next
    })
  }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div>
        <div className="text-[11px] text-gray-400 mb-0.5">Analise › Evolucao</div>
        <h2 className="text-sm font-medium" style={{ color: COLOR_BLACK }}>Evolucao plurianual</h2>
      </div>

      {/* A. Banner KPI executivo (2 cards grandes) */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <Card>
          <div className="text-[11px] font-medium uppercase tracking-wide" style={{ color: '#6B7280' }}>Receita YTD</div>
          <div className="text-3xl font-medium mt-1" style={{ color: '#0F6E56' }}>{formatCurrency(banner.receitaYtd)}</div>
          <div className="text-[11px] mt-1 flex items-center gap-1" style={{ color: colorPorDelta(banner.receitaYoyPct) }}>
            <span>{banner.receitaYoyPct >= 0 ? '▲' : '▼'}</span>
            <span>{formatPct(banner.receitaYoyPct)} vs {anoAnterior} ({formatCurrency(banner.receitaYtdAnterior)})</span>
          </div>
        </Card>

        <Card>
          <div className="text-[11px] font-medium uppercase tracking-wide" style={{ color: '#6B7280' }}>Resultado YTD</div>
          <div className="text-3xl font-medium mt-1" style={{ color: banner.resultadoYtd >= 0 ? '#0F6E56' : COLOR_RED }}>
            {formatCurrency(banner.resultadoYtd)}
          </div>
          <div className="text-[11px] mt-1 flex items-center gap-1" style={{ color: colorPorDelta(banner.resultadoYoyPct) }}>
            <span>{banner.resultadoYoyPct >= 0 ? '▲' : '▼'}</span>
            <span>{formatPct(banner.resultadoYoyPct)} vs {anoAnterior} ({formatCurrency(banner.resultadoYtdAnterior)})</span>
          </div>
        </Card>
      </div>

      {/* B. Metricas hoteleiras (Sprint 2) */}
      {metricas && <MetricasHoteleirasCards data={metricas} />}

      {/* C. Pipeline 90 dias + Concentracao risco (forward-looking, accionavel) */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-3">
        {pipeline && <PipelineWidget data={pipeline} />}
        {concentracao && <ConcentracaoRiscoWidget data={concentracao} />}
      </div>

      {/* B. Bar chart anual */}
      <Card>
        <h3 className="text-[11px] font-medium uppercase tracking-wide mb-3" style={{ color: '#6B7280' }}>
          Receita vs Custos vs Resultado (anual)
        </h3>
        {anosCivis.length > 0 ? (
          <div style={{ width: '100%', height: 280 }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={anosCivis} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="ano" tick={{ fontSize: 10, fill: '#6B7280' }} />
                <YAxis
                  tick={{ fontSize: 10, fill: '#6B7280' }}
                  tickFormatter={(v: number) => `€${(v / 1000).toFixed(0)}k`}
                />
                <Tooltip
                  formatter={(v, name) => {
                    const label = typeof name === 'string' ? name : ''
                    return [formatCurrency(Number(v)), label]
                  }}
                />
                <Legend wrapperStyle={{ fontSize: 11 }} />
                <Bar dataKey="receita" name="Receita" fill={COLOR_GREEN} radius={[3, 3, 0, 0]} />
                <Bar dataKey="custos" name="Custos" fill={COLOR_GREY_BAR} radius={[3, 3, 0, 0]} />
                <Bar dataKey="resultado" name="Resultado" fill={COLOR_BLUE} radius={[3, 3, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        ) : (
          <div className="h-40 flex items-center justify-center text-[12px] text-gray-400">Sem dados</div>
        )}
        {/* Tabela compacta de margens — leitura rápida */}
        {anosCivis.length > 0 && (
          <div className="mt-3 flex flex-wrap gap-x-5 gap-y-1 text-[11px]" style={{ color: '#6B7280' }}>
            {anosCivis.map((a) => (
              <span key={a.ano}>
                {a.ano}: <span className="font-medium" style={{ color: a.margemPct >= 0 ? '#0F6E56' : COLOR_RED }}>{a.margemPct.toFixed(1)}%</span>
              </span>
            ))}
          </div>
        )}
      </Card>

      {/* C. Sazonalidade — Linhas sobrepostas por ano lectivo */}
      <Card>
        <h3 className="text-[11px] font-medium uppercase tracking-wide mb-3" style={{ color: '#6B7280' }}>
          Sazonalidade — receita por ano lectivo
        </h3>
        {sazonalidadeData.length > 0 && anosLectivos.length > 0 ? (
          <div style={{ width: '100%', height: 320 }}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={sazonalidadeData} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="mesNome" tick={{ fontSize: 10, fill: '#6B7280' }} />
                <YAxis
                  tick={{ fontSize: 10, fill: '#6B7280' }}
                  tickFormatter={(v: number) => `€${(v / 1000).toFixed(0)}k`}
                />
                <Tooltip formatter={(v) => formatCurrency(Number(v))} />
                <Legend
                  wrapperStyle={{ fontSize: 11 }}
                  onClick={(o) => {
                    const dk = (o as { dataKey?: unknown }).dataKey
                    if (typeof dk === 'string') toggleAno(dk)
                  }}
                />
                {/* ReferenceArea sombreando Jul (mes lectivo 11) e Ago (mes 12) */}
                <ReferenceArea x1="Jul" x2="Ago" fill="#FEF3C7" fillOpacity={0.4} />
                {anosLectivos.map((al, idx) => {
                  const { stroke, strokeWidth, opacity } = corAnoLectivo(al, idx, anosLectivos.length)
                  const hidden = anosOcultos.has(al.anoLectivo)
                  return (
                    <Line
                      key={al.anoLectivo}
                      type="monotone"
                      dataKey={al.anoLectivo}
                      name={al.anoLectivo}
                      stroke={stroke}
                      strokeWidth={strokeWidth}
                      strokeOpacity={opacity}
                      dot={al.isAtual ? { r: 3 } : false}
                      hide={hidden}
                      isAnimationActive={false}
                    />
                  )
                })}
              </LineChart>
            </ResponsiveContainer>
          </div>
        ) : (
          <div className="h-40 flex items-center justify-center text-[12px] text-gray-400">Sem dados</div>
        )}
        <p className="text-[10px] text-gray-400 mt-2">
          Area sombreada: Jul-Ago (vale sazonal estudantes). Clique nos rotulos para ocultar/mostrar.
        </p>
      </Card>

      {/* D. Small multiples por imóvel */}
      <Card>
        <h3 className="text-[11px] font-medium uppercase tracking-wide" style={{ color: '#6B7280' }}>
          Performance por imovel
        </h3>
        <p className="text-[11px] text-gray-400 mb-3">Ordenado por variacao YoY (piores primeiro)</p>
        {imoveis.length > 0 ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
            {imoveis.map((im) => {
              const corMargem = colorPorMargem(im.margemActualPct)
              const corDelta = colorPorDelta(im.deltaYoyPct)
              return (
                <div key={im.id} className="rounded-lg p-3 bg-white border border-gray-100">
                  <div className="text-[10px] text-gray-500 truncate" title={im.nome}>{im.nome}</div>
                  <div className="text-xl font-medium mt-1" style={{ color: corMargem }}>
                    {im.margemActualPct.toFixed(1)}%
                  </div>
                  <div className="mt-1.5" style={{ height: 30 }}>
                    <ResponsiveContainer width="100%" height={30}>
                      <LineChart data={im.historico} margin={{ top: 2, right: 2, left: 2, bottom: 2 }}>
                        <Line
                          type="monotone"
                          dataKey="margemPct"
                          stroke={corMargem}
                          strokeWidth={2}
                          dot={false}
                          isAnimationActive={false}
                        />
                      </LineChart>
                    </ResponsiveContainer>
                  </div>
                  <div className="text-[10px] mt-1 flex items-center gap-1" style={{ color: corDelta }}>
                    <span>{im.deltaYoyPct >= 0 ? '▲' : '▼'}</span>
                    <span>{formatPp(im.deltaYoyPct)}</span>
                  </div>
                </div>
              )
            })}
          </div>
        ) : (
          <div className="text-[12px] text-gray-400">Sem dados</div>
        )}
      </Card>
    </div>
  )
}
