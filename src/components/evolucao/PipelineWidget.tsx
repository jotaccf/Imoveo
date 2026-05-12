'use client'

import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Table, Th, Td } from '@/components/ui/Table'
import { formatCurrency, formatDate } from '@/lib/utils'

export interface PipelineResponse {
  janelaDias: number
  totalQuartos: number
  quartosEmRisco: number
  percentagemEmRisco: number
  receitaEmRisco: number
  porImovel: Array<{
    id: string
    nome: string
    totalQuartos: number
    quartosEmRisco: number
    receitaEmRisco: number
  }>
  contratosCriticos: Array<{
    contratoId: string
    fracaoNome: string
    imovelNome: string
    dataFim: string
    diasRestantes: number
    renda: number
    inquilino: string | null
    renovacaoAutomatica: boolean
  }>
}

interface Props {
  data: PipelineResponse
}

function pctTone(pct: number): { color: string; bg: string } {
  if (pct === 0) return { color: '#0F6E56', bg: '#EAF3DE' }
  if (pct <= 25) return { color: '#633806', bg: '#FAEEDA' }
  return { color: '#A32D2D', bg: '#FCEBEB' }
}

function diasVariant(dias: number): 'green' | 'amber' | 'red' {
  if (dias > 60) return 'green'
  if (dias >= 30) return 'amber'
  return 'red'
}

export function PipelineWidget({ data }: Props) {
  const tone = pctTone(data.percentagemEmRisco)

  return (
    <Card>
      {/* Banner topo */}
      <div
        className="rounded-md p-4 mb-4"
        style={{ background: tone.bg }}
      >
        <div className="text-[11px] font-medium uppercase tracking-wide" style={{ color: '#6B7280' }}>
          Pipeline — proximos {data.janelaDias} dias
        </div>
        <div className="mt-1 text-2xl font-medium" style={{ color: tone.color }}>
          {data.quartosEmRisco} {data.quartosEmRisco === 1 ? 'quarto' : 'quartos'} em risco
        </div>
        <div className="text-[12px] mt-1" style={{ color: '#374151' }}>
          {data.percentagemEmRisco.toFixed(1)}% do total ({data.totalQuartos} quartos) —{' '}
          <span className="font-medium">{formatCurrency(data.receitaEmRisco)}</span> em receita mensal
        </div>
      </div>

      {/* Tabela contratos criticos */}
      {data.contratosCriticos.length === 0 ? (
        <div className="text-center py-6 text-[13px]" style={{ color: '#6B7280' }}>
          Sem contratos criticos na janela.
        </div>
      ) : (
        <Table>
          <thead>
            <tr>
              <Th>Imovel</Th>
              <Th>Quarto</Th>
              <Th>Inquilino</Th>
              <Th>Dias</Th>
              <Th>Data fim</Th>
              <Th className="text-right">Renda</Th>
              <Th>Renovacao</Th>
            </tr>
          </thead>
          <tbody>
            {data.contratosCriticos.map((c) => (
              <tr key={c.contratoId}>
                <Td>{c.imovelNome}</Td>
                <Td>{c.fracaoNome}</Td>
                <Td>{c.inquilino ?? '-'}</Td>
                <Td>
                  <Badge variant={diasVariant(c.diasRestantes)}>{c.diasRestantes}d</Badge>
                </Td>
                <Td>{formatDate(c.dataFim)}</Td>
                <Td className="text-right tabular-nums">{formatCurrency(c.renda)}</Td>
                <Td>
                  {c.renovacaoAutomatica
                    ? <Badge variant="green">Auto-renew</Badge>
                    : <Badge variant="gray">Manual</Badge>}
                </Td>
              </tr>
            ))}
          </tbody>
        </Table>
      )}
    </Card>
  )
}
