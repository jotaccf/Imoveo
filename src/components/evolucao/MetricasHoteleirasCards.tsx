'use client'

import { Card } from '@/components/ui/Card'
import { formatCurrency } from '@/lib/utils'

// Mirror da response do endpoint /api/evolucao/metricas-hoteleiras
export interface MetricasHoteleirasResponse {
  anoLectivoAtual: string
  metricas: {
    occupancyEffectivePct: number
    revPar: number
    adr: number
    rentCoverageRatio: number
    collectionRate: number | null
  }
  yoy: {
    occupancyEffectivePctAnterior: number
    occupancyDelta: number
    revParAnterior: number
    revParDeltaPct: number
    adrAnterior: number
    adrDeltaPct: number
    rentCoverageRatioAnterior: number
    rentCoverageDeltaPct: number
    collectionRateAnterior: number | null
    collectionRateDeltaPct: number | null
  }
  porImovel: Array<{
    id: string
    nome: string
    occupancyPct: number
    revPar: number
    adr: number
    rentCoverage: number
    nQuartos: number
  }>
}

interface Props {
  data: MetricasHoteleirasResponse
}

type Tone = 'default' | 'amber' | 'red'

interface CardConfig {
  label: string
  helper: string
  value: string
  delta: number
  deltaIsPct: boolean // true: %, false: pp
  betterIsUp: boolean
  tone: Tone
}

function toneBg(tone: Tone): string {
  switch (tone) {
    case 'red': return '#FCEBEB'
    case 'amber': return '#FAEEDA'
    default: return '#FFFFFF'
  }
}

function deltaColor(delta: number, betterIsUp: boolean): string {
  if (delta === 0) return '#6B7280'
  const isPositive = delta > 0
  const isGood = betterIsUp ? isPositive : !isPositive
  return isGood ? '#0F6E56' : '#A32D2D'
}

function deltaArrow(delta: number): string {
  if (delta > 0) return 'up'
  if (delta < 0) return 'down'
  return 'flat'
}

function formatDelta(delta: number, isPct: boolean): string {
  const sign = delta > 0 ? '+' : ''
  const suffix = isPct ? '%' : 'pp'
  return `${sign}${delta.toFixed(1)}${suffix}`
}

function ArrowIcon({ kind }: { kind: string }) {
  if (kind === 'up') {
    return (
      <svg width="10" height="10" viewBox="0 0 10 10" fill="none" aria-hidden="true">
        <path d="M5 2 L8 7 L2 7 Z" fill="currentColor" />
      </svg>
    )
  }
  if (kind === 'down') {
    return (
      <svg width="10" height="10" viewBox="0 0 10 10" fill="none" aria-hidden="true">
        <path d="M5 8 L2 3 L8 3 Z" fill="currentColor" />
      </svg>
    )
  }
  return (
    <svg width="10" height="10" viewBox="0 0 10 10" fill="none" aria-hidden="true">
      <path d="M2 5 H8" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  )
}

export function MetricasHoteleirasCards({ data }: Props) {
  const { metricas, yoy } = data

  // Helpers de saude
  const occToneFn = (occ: number): Tone => (occ < 90 ? 'amber' : 'default')
  const rcToneFn = (rc: number): Tone => (rc < 1.2 ? 'red' : 'default')

  const cards: CardConfig[] = [
    {
      label: 'REVPAR',
      helper: 'Receita por quarto disponivel (mes)',
      value: formatCurrency(metricas.revPar),
      delta: yoy.revParDeltaPct,
      deltaIsPct: true,
      betterIsUp: true,
      tone: 'default',
    },
    {
      label: 'ADR',
      helper: 'Receita media por quarto ocupado (mes)',
      value: formatCurrency(metricas.adr),
      delta: yoy.adrDeltaPct,
      deltaIsPct: true,
      betterIsUp: true,
      tone: 'default',
    },
    {
      label: 'OCUPACAO EFECTIVA',
      helper: 'Quartos-meses ocupados / disponiveis',
      value: `${metricas.occupancyEffectivePct.toFixed(1)}%`,
      delta: yoy.occupancyDelta,
      deltaIsPct: false,
      betterIsUp: true,
      tone: occToneFn(metricas.occupancyEffectivePct),
    },
    {
      label: 'RENT COVERAGE',
      helper: 'Receita bruta / renda paga ao senhorio',
      value: `${metricas.rentCoverageRatio.toFixed(2)}×`,
      delta: yoy.rentCoverageDeltaPct,
      deltaIsPct: true,
      betterIsUp: true,
      tone: rcToneFn(metricas.rentCoverageRatio),
    },
  ]

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
      {cards.map((c) => {
        const color = deltaColor(c.delta, c.betterIsUp)
        const arrow = deltaArrow(c.delta)
        return (
          <Card
            key={c.label}
            style={{ background: toneBg(c.tone) }}
            className={c.tone !== 'default' ? 'border-transparent' : undefined}
          >
            <div className="text-[11px] font-medium uppercase tracking-wide" style={{ color: '#6B7280' }}>
              {c.label}
            </div>
            <div className="text-[10px] mt-0.5" style={{ color: '#9CA3AF' }}>
              {c.helper}
            </div>
            <div className="text-xl font-medium mt-2" style={{ color: '#0D1B1A' }}>
              {c.value}
            </div>
            <div
              className="flex items-center gap-1 mt-1 text-[11px] font-medium"
              style={{ color }}
            >
              <ArrowIcon kind={arrow} />
              <span>{formatDelta(c.delta, c.deltaIsPct)}</span>
              <span style={{ color: '#9CA3AF', fontWeight: 400 }}>vs ano anterior</span>
            </div>
          </Card>
        )
      })}
    </div>
  )
}
