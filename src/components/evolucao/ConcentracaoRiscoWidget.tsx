'use client'

import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { formatCurrency } from '@/lib/utils'
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Cell,
} from 'recharts'

export interface ConcentracaoResponse {
  anoLectivoAtual: string
  receitaTotal: number
  top3: Array<{ imovelId: string; nome: string; receita: number; percentagem: number }>
  outros: { receita: number; percentagem: number; numeroImoveis: number }
  top3Percentagem: number
  cr3Risk: 'baixo' | 'medio' | 'alto'
  numeroImoveisTotal: number
}

interface Props {
  data: ConcentracaoResponse
}

const RISK_LABEL: Record<ConcentracaoResponse['cr3Risk'], string> = {
  baixo: 'Baixo',
  medio: 'Medio',
  alto: 'Alto',
}

const RISK_VARIANT: Record<ConcentracaoResponse['cr3Risk'], 'green' | 'amber' | 'red'> = {
  baixo: 'green',
  medio: 'amber',
  alto: 'red',
}

// Degrade verde → amber consoante posicao (top1 mais "concentrado" = mais quente)
const BAR_COLORS = ['#A32D2D', '#F59E0B', '#1D9E75', '#9CA3AF']

interface BarDatum {
  nome: string
  receita: number
  percentagem: number
}

export function ConcentracaoRiscoWidget({ data }: Props) {
  const barData: BarDatum[] = [
    ...data.top3.map((t) => ({
      nome: t.nome,
      receita: t.receita,
      percentagem: t.percentagem,
    })),
    {
      nome: `Outros (${data.outros.numeroImoveis} imoveis)`,
      receita: data.outros.receita,
      percentagem: data.outros.percentagem,
    },
  ]

  // Altura dinamica: ~44px por barra + margem
  const chartHeight = Math.max(barData.length * 44 + 24, 180)

  return (
    <Card>
      <div className="flex items-start justify-between gap-3 mb-3">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide" style={{ color: '#6B7280' }}>
            Concentracao de receita — {data.anoLectivoAtual}
          </div>
          <div className="text-lg font-medium mt-1" style={{ color: '#0D1B1A' }}>
            Top 3 imoveis = {data.top3Percentagem.toFixed(1)}% da receita anual
          </div>
          <div className="text-[12px] mt-0.5" style={{ color: '#6B7280' }}>
            {formatCurrency(data.receitaTotal)} total ({data.numeroImoveisTotal} imoveis)
          </div>
        </div>
        <Badge variant={RISK_VARIANT[data.cr3Risk]}>
          Risco: {RISK_LABEL[data.cr3Risk]}
        </Badge>
      </div>

      <div style={{ width: '100%', height: chartHeight }}>
        <ResponsiveContainer>
          <BarChart
            layout="vertical"
            data={barData}
            margin={{ top: 5, right: 20, bottom: 5, left: 10 }}
          >
            <XAxis
              type="number"
              tick={{ fontSize: 11, fill: '#6B7280' }}
              tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`}
            />
            <YAxis
              type="category"
              dataKey="nome"
              tick={{ fontSize: 11, fill: '#374151' }}
              width={160}
            />
            <Tooltip
              cursor={{ fill: 'rgba(0,0,0,0.04)' }}
              formatter={(value, _name, item) => {
                const v = typeof value === 'number' ? value : Number(value ?? 0)
                const pct = (item?.payload as BarDatum | undefined)?.percentagem ?? 0
                return [`${formatCurrency(v)} (${pct.toFixed(1)}%)`, 'Receita']
              }}
            />
            <Bar dataKey="receita" radius={[0, 4, 4, 0]}>
              {barData.map((_, i) => (
                <Cell key={i} fill={BAR_COLORS[i] ?? '#9CA3AF'} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </Card>
  )
}
