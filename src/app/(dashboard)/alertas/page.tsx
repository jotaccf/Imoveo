'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/components/ui/Card'
import { KpiCard } from '@/components/ui/KpiCard'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Table, Th, Td } from '@/components/ui/Table'

interface Alerta {
  imovelId: string
  imovelNome: string
  tipo: string
  valor: number
  threshold: number
  severidade: 'critico' | 'aviso'
}

interface Thresholds {
  alerta_yield_min: number
  alerta_ocupacao_min: number
  alerta_racio_min: number
  alerta_margem_min: number
}

interface ApiData {
  thresholds: Thresholds
  alertas: Alerta[]
}

function formatValor(tipo: string, valor: number): string {
  if (tipo === 'Racio Cobertura') return valor.toFixed(2) + 'x'
  return valor.toFixed(1) + '%'
}

function formatThreshold(tipo: string, threshold: number): string {
  if (tipo === 'Racio Cobertura') return threshold.toFixed(2) + 'x'
  return threshold.toFixed(1) + '%'
}

export default function AlertasPage() {
  const [data, setData] = useState<ApiData | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [form, setForm] = useState<Thresholds>({
    alerta_yield_min: 5,
    alerta_ocupacao_min: 70,
    alerta_racio_min: 1.2,
    alerta_margem_min: 10,
  })

  useEffect(() => {
    fetch('/api/alertas')
      .then((r) => r.json())
      .then((j) => {
        if (j.data) {
          setData(j.data)
          setForm(j.data.thresholds)
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  async function handleSave() {
    setSaving(true)
    try {
      await fetch('/api/alertas', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      // Reload alerts with new thresholds
      const res = await fetch('/api/alertas')
      const j = await res.json()
      if (j.data) {
        setData(j.data)
        setForm(j.data.thresholds)
      }
    } catch { /* ignore */ }
    setSaving(false)
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!data) return <div className="text-sm text-gray-400">Sem dados</div>

  const { alertas } = data
  const totalAlertas = alertas.length
  const criticos = alertas.filter((a) => a.severidade === 'critico').length
  const imoveisComAlertas = new Set(alertas.map((a) => a.imovelId)).size

  return (
    <div className="space-y-5">
      {/* KPIs */}
      <div className="grid grid-cols-3 gap-4">
        <KpiCard label="Total de Alertas" value={String(totalAlertas)} color={totalAlertas > 0 ? 'red' : 'green'} />
        <KpiCard label="Alertas Criticos" value={String(criticos)} color={criticos > 0 ? 'red' : 'default'} />
        <KpiCard label="Imoveis com Alertas" value={String(imoveisComAlertas)} color={imoveisComAlertas > 0 ? 'amber' : 'default'} />
      </div>

      {/* Alerts Table */}
      <Card>
        <div className="mb-3">
          <h2 className="text-sm font-medium text-gray-900">Alertas Activos</h2>
          <p className="text-[11px] text-[#9CA3AF] mt-0.5">Imoveis com metricas abaixo dos thresholds definidos</p>
        </div>

        {alertas.length === 0 ? (
          <div className="text-sm text-gray-400 py-6 text-center">Nenhum alerta activo — todos os imoveis estao dentro dos thresholds.</div>
        ) : (
          <Table>
            <thead>
              <tr>
                <Th>Imovel</Th>
                <Th>Tipo</Th>
                <Th className="text-right">Valor Actual</Th>
                <Th className="text-right">Threshold</Th>
                <Th>Severidade</Th>
              </tr>
            </thead>
            <tbody>
              {alertas.map((a, i) => (
                <tr key={`${a.imovelId}-${a.tipo}-${i}`}>
                  <Td className="font-medium text-gray-900">{a.imovelNome}</Td>
                  <Td>{a.tipo}</Td>
                  <Td className="text-right font-mono">{formatValor(a.tipo, a.valor)}</Td>
                  <Td className="text-right font-mono">{formatThreshold(a.tipo, a.threshold)}</Td>
                  <Td>
                    <Badge variant={a.severidade === 'critico' ? 'red' : 'amber'}>
                      {a.severidade === 'critico' ? 'Critico' : 'Aviso'}
                    </Badge>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        )}
      </Card>

      {/* Threshold Configuration */}
      <Card>
        <div className="mb-4">
          <h2 className="text-sm font-medium text-gray-900">Configurar Thresholds</h2>
          <p className="text-[11px] text-[#9CA3AF] mt-0.5">Defina os valores minimos para gerar alertas</p>
        </div>

        <div className="grid grid-cols-2 gap-4 max-w-lg">
          <Input
            label="Yield minima (%)"
            type="number"
            step="0.1"
            value={form.alerta_yield_min}
            onChange={(e) => setForm({ ...form, alerta_yield_min: Number(e.target.value) })}
          />
          <Input
            label="Ocupacao minima (%)"
            type="number"
            step="1"
            value={form.alerta_ocupacao_min}
            onChange={(e) => setForm({ ...form, alerta_ocupacao_min: Number(e.target.value) })}
          />
          <Input
            label="Racio cobertura minimo (x)"
            type="number"
            step="0.1"
            value={form.alerta_racio_min}
            onChange={(e) => setForm({ ...form, alerta_racio_min: Number(e.target.value) })}
          />
          <Input
            label="Margem bruta minima (%)"
            type="number"
            step="1"
            value={form.alerta_margem_min}
            onChange={(e) => setForm({ ...form, alerta_margem_min: Number(e.target.value) })}
          />
        </div>

        <div className="mt-4">
          <Button onClick={handleSave} disabled={saving}>
            {saving ? 'A guardar...' : 'Guardar Thresholds'}
          </Button>
        </div>
      </Card>
    </div>
  )
}
