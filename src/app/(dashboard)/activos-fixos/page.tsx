'use client'

import { useEffect, useState, useCallback } from 'react'
import { useSession } from 'next-auth/react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Badge } from '@/components/ui/Badge'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Modal } from '@/components/ui/Modal'
import { hasPermission, type Role } from '@/lib/permissions'
import { formatCurrency } from '@/lib/utils'

interface Activo {
  id: string
  nome: string
  tipo: 'VIATURA_LIGEIRA' | 'VIATURA_PESADA' | 'EQUIPAMENTO' | 'OUTRO'
  combustivel: 'COMBUSTAO' | 'HIBRIDO_PLUG_IN' | 'GPL_GNV' | 'ELECTRICO' | null
  matricula: string | null
  valorAquisicao: string
  dataAquisicao: string
  taxaDepreciacaoAnual: string
  alienadoEm: string | null
  valorAlienacao: string | null
  notas: string | null
}

const TIPO_OPTIONS = [
  { value: 'VIATURA_LIGEIRA', label: 'Viatura ligeira' },
  { value: 'VIATURA_PESADA', label: 'Viatura pesada' },
  { value: 'EQUIPAMENTO', label: 'Equipamento' },
  { value: 'OUTRO', label: 'Outro' },
]

const COMBUSTIVEL_OPTIONS = [
  { value: '', label: '— (nao aplicavel)' },
  { value: 'COMBUSTAO', label: 'Combustao (gasolina/diesel)' },
  { value: 'HIBRIDO_PLUG_IN', label: 'Hibrido plug-in' },
  { value: 'GPL_GNV', label: 'GPL / GNV' },
  { value: 'ELECTRICO', label: 'Electrico' },
]

const TIPO_LABEL: Record<string, string> = {
  VIATURA_LIGEIRA: 'Viatura ligeira',
  VIATURA_PESADA: 'Viatura pesada',
  EQUIPAMENTO: 'Equipamento',
  OUTRO: 'Outro',
}

const COMB_LABEL: Record<string, string> = {
  COMBUSTAO: 'Combustao',
  HIBRIDO_PLUG_IN: 'Hibrido PI',
  GPL_GNV: 'GPL/GNV',
  ELECTRICO: 'Electrico',
}

function taxaDefault(tipo: string): string {
  if (tipo === 'VIATURA_LIGEIRA') return '25'
  if (tipo === 'VIATURA_PESADA') return '20'
  if (tipo === 'EQUIPAMENTO') return '20'
  return '12.5'
}

const emptyForm = {
  nome: '', tipo: 'VIATURA_LIGEIRA', combustivel: 'COMBUSTAO',
  matricula: '', valorAquisicao: '', dataAquisicao: '',
  taxaDepreciacaoAnual: '25', alienadoEm: '', valorAlienacao: '',
  notas: '',
}

export default function ActivosFixosPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role
  const canEdit = role ? hasPermission(role, 'utilizadores:editar') : false

  const [activos, setActivos] = useState<Activo[]>([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editId, setEditId] = useState<string | null>(null)
  const [form, setForm] = useState(emptyForm)
  const [deleteId, setDeleteId] = useState<string | null>(null)

  const fetchData = useCallback(() => {
    fetch('/api/activos-fixos')
      .then((r) => r.json())
      .then((j) => { if (j.data) setActivos(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => { fetchData() }, [fetchData])

  function openCreate() {
    setEditId(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(a: Activo) {
    setEditId(a.id)
    setForm({
      nome: a.nome,
      tipo: a.tipo,
      combustivel: a.combustivel ?? '',
      matricula: a.matricula ?? '',
      valorAquisicao: a.valorAquisicao,
      dataAquisicao: a.dataAquisicao ? String(a.dataAquisicao).split('T')[0] : '',
      taxaDepreciacaoAnual: a.taxaDepreciacaoAnual,
      alienadoEm: a.alienadoEm ? String(a.alienadoEm).split('T')[0] : '',
      valorAlienacao: a.valorAlienacao ?? '',
      notas: a.notas ?? '',
    })
    setModalOpen(true)
  }

  async function handleSave() {
    const isViatura = form.tipo === 'VIATURA_LIGEIRA' || form.tipo === 'VIATURA_PESADA'
    const payload: Record<string, unknown> = {
      nome: form.nome,
      tipo: form.tipo,
      valorAquisicao: Number(form.valorAquisicao || 0),
      dataAquisicao: form.dataAquisicao,
      taxaDepreciacaoAnual: Number(form.taxaDepreciacaoAnual || taxaDefault(form.tipo)),
    }
    if (isViatura && form.combustivel) payload.combustivel = form.combustivel
    if (isViatura && form.matricula) payload.matricula = form.matricula
    if (form.notas) payload.notas = form.notas
    if (editId) {
      // PUT supports nullable fields
      if (!isViatura) {
        payload.combustivel = null
        payload.matricula = null
      }
      if (form.alienadoEm) payload.alienadoEm = form.alienadoEm
      else payload.alienadoEm = null
      if (form.valorAlienacao) payload.valorAlienacao = Number(form.valorAlienacao)
      else payload.valorAlienacao = null
      payload.notas = form.notas || null
    }
    const url = editId ? `/api/activos-fixos/${editId}` : '/api/activos-fixos'
    const method = editId ? 'PUT' : 'POST'
    const res = await fetch(url, { method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) })
    if (!res.ok) {
      const j = await res.json().catch(() => ({}))
      alert(j.error || 'Erro ao guardar')
      return
    }
    setModalOpen(false)
    fetchData()
  }

  async function handleDelete() {
    if (!deleteId) return
    await fetch(`/api/activos-fixos/${deleteId}`, { method: 'DELETE' })
    setDeleteId(null)
    fetchData()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  const total = activos.reduce((s, a) => s + Number(a.valorAquisicao || 0), 0)
  const activosAtivos = activos.filter((a) => !a.alienadoEm)
  const totalAtivos = activosAtivos.reduce((s, a) => s + Number(a.valorAquisicao || 0), 0)

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-3 gap-3">
        <Card>
          <div className="text-[11px] uppercase tracking-wide text-gray-400">Total adquirido</div>
          <div className="text-xl font-semibold mt-1">{formatCurrency(total)}</div>
          <div className="text-[11px] text-gray-400">{activos.length} activos</div>
        </Card>
        <Card>
          <div className="text-[11px] uppercase tracking-wide text-gray-400">Em uso</div>
          <div className="text-xl font-semibold mt-1">{formatCurrency(totalAtivos)}</div>
          <div className="text-[11px] text-gray-400">{activosAtivos.length} activos</div>
        </Card>
        <Card>
          <div className="text-[11px] uppercase tracking-wide text-gray-400">Alienados</div>
          <div className="text-xl font-semibold mt-1">{activos.length - activosAtivos.length}</div>
          <div className="text-[11px] text-gray-400">activos</div>
        </Card>
      </div>

      <div className="flex items-center justify-between">
        <h2 className="text-sm font-medium text-gray-700">Activos fixos (viaturas + equipamento)</h2>
        {canEdit && <Button onClick={openCreate}>Adicionar activo</Button>}
      </div>

      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              <Th>Nome</Th>
              <Th>Tipo</Th>
              <Th>Combustivel</Th>
              <Th>Matricula</Th>
              <Th className="text-right">Aquisicao</Th>
              <Th>Data</Th>
              <Th className="text-right">Taxa</Th>
              <Th>Estado</Th>
              {canEdit && <Th>Accoes</Th>}
            </tr>
          </thead>
          <tbody>
            {activos.map((a) => {
              const dataAq = new Date(a.dataAquisicao).toLocaleDateString('pt-PT')
              const isViatura = a.tipo === 'VIATURA_LIGEIRA' || a.tipo === 'VIATURA_PESADA'
              return (
                <tr key={a.id} className="hover:bg-gray-50">
                  <Td className="font-medium">{a.nome}</Td>
                  <Td>{TIPO_LABEL[a.tipo]}</Td>
                  <Td>{isViatura && a.combustivel ? COMB_LABEL[a.combustivel] : <span className="text-gray-300">—</span>}</Td>
                  <Td className="font-mono text-[11px]">{a.matricula || <span className="text-gray-300">—</span>}</Td>
                  <Td className="text-right font-mono">{formatCurrency(Number(a.valorAquisicao))}</Td>
                  <Td>{dataAq}</Td>
                  <Td className="text-right">{Number(a.taxaDepreciacaoAnual)}%</Td>
                  <Td>
                    {a.alienadoEm
                      ? <Badge variant="gray">Alienado</Badge>
                      : <Badge variant="green">Em uso</Badge>}
                  </Td>
                  {canEdit && (
                    <Td>
                      <div className="flex items-center gap-2">
                        <button onClick={() => openEdit(a)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                        <button onClick={() => setDeleteId(a.id)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                      </div>
                    </Td>
                  )}
                </tr>
              )
            })}
            {activos.length === 0 && (
              <tr><Td colSpan={canEdit ? 9 : 8} className="text-center text-gray-400">Sem activos fixos registados</Td></tr>
            )}
          </tbody>
        </Table>
      </Card>

      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editId ? 'Editar activo fixo' : 'Adicionar activo fixo'}
        className="max-w-xl"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setModalOpen(false)}>Cancelar</Button>
            <Button onClick={handleSave}>{editId ? 'Guardar' : 'Criar'}</Button>
          </div>
        }
      >
        <div className="space-y-3">
          <Input label="Nome / Descricao" value={form.nome} onChange={(e) => setForm({ ...form, nome: e.target.value })} placeholder="Ex: Renault Clio 2024" />
          <div className="grid grid-cols-2 gap-3">
            <Select
              label="Tipo"
              options={TIPO_OPTIONS}
              value={form.tipo}
              onChange={(e) => {
                const t = e.target.value
                setForm({ ...form, tipo: t, taxaDepreciacaoAnual: taxaDefault(t) })
              }}
            />
            {(form.tipo === 'VIATURA_LIGEIRA' || form.tipo === 'VIATURA_PESADA') ? (
              <Select label="Combustivel" options={COMBUSTIVEL_OPTIONS} value={form.combustivel} onChange={(e) => setForm({ ...form, combustivel: e.target.value })} />
            ) : <div />}
          </div>
          {(form.tipo === 'VIATURA_LIGEIRA' || form.tipo === 'VIATURA_PESADA') && (
            <Input label="Matricula" value={form.matricula} onChange={(e) => setForm({ ...form, matricula: e.target.value })} placeholder="AA-00-AA" />
          )}
          <div className="grid grid-cols-2 gap-3">
            <Input label="Valor de aquisicao (EUR)" type="number" step="0.01" value={form.valorAquisicao} onChange={(e) => setForm({ ...form, valorAquisicao: e.target.value })} />
            <Input label="Data de aquisicao" type="date" value={form.dataAquisicao} onChange={(e) => setForm({ ...form, dataAquisicao: e.target.value })} />
          </div>
          <Input label="Taxa de depreciacao anual (%)" type="number" step="0.01" value={form.taxaDepreciacaoAnual} onChange={(e) => setForm({ ...form, taxaDepreciacaoAnual: e.target.value })} />
          {editId && (
            <div className="pt-3 border-t border-gray-200">
              <h4 className="text-xs font-semibold mb-2 text-gray-600 uppercase tracking-wide">Alienacao (se aplicavel)</h4>
              <div className="grid grid-cols-2 gap-3">
                <Input label="Data de alienacao" type="date" value={form.alienadoEm} onChange={(e) => setForm({ ...form, alienadoEm: e.target.value })} />
                <Input label="Valor de alienacao (EUR)" type="number" step="0.01" value={form.valorAlienacao} onChange={(e) => setForm({ ...form, valorAlienacao: e.target.value })} />
              </div>
            </div>
          )}
          <div>
            <label className="block text-sm font-medium mb-1 text-gray-700">Notas</label>
            <textarea
              value={form.notas}
              onChange={(e) => setForm({ ...form, notas: e.target.value })}
              rows={3}
              className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
            />
          </div>
        </div>
      </Modal>

      <Modal
        open={!!deleteId}
        onClose={() => setDeleteId(null)}
        title="Confirmar remocao"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setDeleteId(null)}>Cancelar</Button>
            <Button variant="danger" onClick={handleDelete}>Remover</Button>
          </div>
        }
      >
        <p className="text-sm text-gray-600">Remover este activo? Esta accao nao pode ser revertida.</p>
      </Modal>
    </div>
  )
}
