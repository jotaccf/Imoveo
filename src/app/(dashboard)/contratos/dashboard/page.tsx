'use client'

import { useEffect, useState } from 'react'
import { useSession } from 'next-auth/react'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { KpiCard } from '@/components/ui/KpiCard'
import { Table, Th, Td } from '@/components/ui/Table'
import { formatCurrency } from '@/lib/utils'
import type { Role } from '@/lib/permissions'
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from 'recharts'

interface DashboardData {
  byEstado: { ATIVO: number; EXPIRADO: number; TERMINADO: number }
  receitaMensal: number
  duracaoMedia: number
  expiring: { d30: number; d60: number; d90: number }
  upcoming: {
    id: string
    imovel: string
    fracao: string
    inquilino: string
    dataFim: string | null
    diasRestantes: number | null
    renovacaoAuto: boolean
  }[]
  projecaoMensal: { mes: string; receita: number }[]
  cobertura: { comContrato: number; total: number }
  atencao: {
    id: string
    imovel: string
    fracao: string
    inquilino: string
    motivo: string
    estado: string
  }[]
}

function formatDate(d: string | null) {
  if (!d) return '-'
  return new Intl.DateTimeFormat('pt-PT').format(new Date(d))
}

function diasBadge(dias: number | null) {
  if (dias === null) return <Badge variant="gray">Sem prazo</Badge>
  if (dias <= 0) return <Badge variant="red">Expirado</Badge>
  if (dias <= 30) return <Badge variant="red">{dias}d</Badge>
  if (dias <= 60) return <Badge variant="amber">{dias}d</Badge>
  return <Badge variant="green">{dias}d</Badge>
}

export default function ContratosDashboardPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role
  const [data, setData] = useState<DashboardData | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/contratos/dashboard')
      .then((r) => r.json())
      .then((j) => { if (j.data) setData(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="text-[13px] text-gray-400">A carregar...</div>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="text-[13px] text-gray-400">Erro ao carregar dados</div>
      </div>
    )
  }

  const totalContratos = data.byEstado.ATIVO + data.byEstado.EXPIRADO + data.byEstado.TERMINADO
  const coberturaPercent = data.cobertura.total > 0
    ? Math.round((data.cobertura.comContrato / data.cobertura.total) * 100)
    : 0

  return (
    <div className="space-y-5">
      {/* KPIs */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <KpiCard
          label="Contratos Ativos"
          value={String(data.byEstado.ATIVO)}
          sub={`${totalContratos} total`}
          color="green"
        />
        <KpiCard
          label="Receita Mensal"
          value={formatCurrency(data.receitaMensal)}
          sub="contratos ativos"
          color="green"
        />
        <KpiCard
          label="Duracao Media"
          value={`${data.duracaoMedia} meses`}
          sub="contratos ativos"
        />
        <KpiCard
          label="A Expirar (30 dias)"
          value={String(data.expiring.d30)}
          sub={`${data.expiring.d60} em 60d / ${data.expiring.d90} em 90d`}
          color={data.expiring.d30 > 0 ? 'red' : 'default'}
        />
      </div>

      {/* Coverage + Estado summary */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        <KpiCard
          label="Cobertura Fracoes"
          value={`${coberturaPercent}%`}
          sub={`${data.cobertura.comContrato} de ${data.cobertura.total} fracoes`}
          color={coberturaPercent >= 80 ? 'green' : 'amber'}
        />
        <KpiCard
          label="Expirados"
          value={String(data.byEstado.EXPIRADO)}
          color={data.byEstado.EXPIRADO > 0 ? 'red' : 'default'}
        />
        <KpiCard
          label="Terminados"
          value={String(data.byEstado.TERMINADO)}
          color="amber"
        />
      </div>

      {/* Projected monthly revenue chart */}
      <Card>
        <h2 className="text-[13px] font-medium text-gray-700 mb-4">
          Projecao Receita Mensal (12 meses)
        </h2>
        <div style={{ width: '100%', height: 280 }}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={data.projecaoMensal} margin={{ top: 5, right: 20, bottom: 5, left: 10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey="mes" tick={{ fontSize: 11, fill: '#6B7280' }} />
              <YAxis tick={{ fontSize: 11, fill: '#6B7280' }} tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`} />
              <Tooltip
                formatter={(value) => [formatCurrency(Number(value)), 'Receita']}
                contentStyle={{ fontSize: 12, borderRadius: 8, border: '1px solid #E5E7EB' }}
              />
              <Bar dataKey="receita" fill="#1D9E75" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </Card>

      {/* Upcoming expirations table */}
      {data.upcoming.length > 0 && (
        <Card>
          <h2 className="text-[13px] font-medium text-gray-700 mb-3">
            Expiracoes Proximas (90 dias)
          </h2>
          <Table>
            <thead>
              <tr>
                <Th>Imovel</Th>
                <Th>Fracao</Th>
                <Th>Inquilino</Th>
                <Th>Fim</Th>
                <Th>Dias Restantes</Th>
                <Th>Renovacao Auto</Th>
              </tr>
            </thead>
            <tbody>
              {data.upcoming.map((c) => (
                <tr key={c.id}>
                  <Td>{c.imovel}</Td>
                  <Td>{c.fracao}</Td>
                  <Td>{c.inquilino}</Td>
                  <Td>{formatDate(c.dataFim)}</Td>
                  <Td>{diasBadge(c.diasRestantes)}</Td>
                  <Td>
                    {c.renovacaoAuto ? (
                      <Badge variant="green">Sim</Badge>
                    ) : (
                      <Badge variant="amber">Nao</Badge>
                    )}
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        </Card>
      )}

      {/* Contracts needing attention */}
      {data.atencao.length > 0 && (
        <Card>
          <h2 className="text-[13px] font-medium text-gray-700 mb-3">
            Contratos que Requerem Atencao
          </h2>
          <Table>
            <thead>
              <tr>
                <Th>Imovel</Th>
                <Th>Fracao</Th>
                <Th>Inquilino</Th>
                <Th>Motivo</Th>
              </tr>
            </thead>
            <tbody>
              {data.atencao.map((c, i) => (
                <tr key={`${c.id}-${i}`}>
                  <Td>{c.imovel}</Td>
                  <Td>{c.fracao}</Td>
                  <Td>{c.inquilino}</Td>
                  <Td>
                    <Badge variant={c.motivo.includes('Expirado') ? 'red' : 'amber'}>
                      {c.motivo}
                    </Badge>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        </Card>
      )}
    </div>
  )
}
