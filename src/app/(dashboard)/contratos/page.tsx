'use client'

import { useEffect, useState, useCallback } from 'react'
import { useSession } from 'next-auth/react'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Badge } from '@/components/ui/Badge'
import { Table, Th, Td } from '@/components/ui/Table'
import { Modal } from '@/components/ui/Modal'
import { KpiCard } from '@/components/ui/KpiCard'
import { hasPermission, type Role } from '@/lib/permissions'
import { formatCurrency } from '@/lib/utils'

interface Fracao {
  id: string
  nome: string
}

interface ImovelRef {
  id: string
  codigo: string
  nome: string
}

interface Contrato {
  id: string
  fracaoId: string
  imovelId: string
  nomeInquilino: string
  nifInquilino: string | null
  contacto: string | null
  nomeFiador: string | null
  nifFiador: string | null
  contactoFiador: string | null
  parentesco: string | null
  valorRenda: string
  dataInicio: string
  dataFim: string | null
  renovacaoAuto: boolean
  periodoRenovacao: number
  caucao: string | null
  notas: string | null
  comunicadoAT: boolean
  dataComunicacaoAT: string | null
  estado: string
  fracao: Fracao
  imovel: ImovelRef
}

interface ImovelWithFracoes {
  id: string
  codigo: string
  nome: string
  fracoes: Fracao[]
}

const ESTADO_BADGE: Record<string, 'green' | 'red' | 'amber'> = {
  ATIVO: 'green', EXPIRADO: 'red', TERMINADO: 'amber',
}

const ESTADO_OPTIONS = [
  { value: '', label: 'Todos' },
  { value: 'ATIVO', label: 'Ativo' },
  { value: 'EXPIRADO', label: 'Expirado' },
  { value: 'TERMINADO', label: 'Terminado' },
]

function formatDate(d: string | null) {
  if (!d) return '-'
  return new Intl.DateTimeFormat('pt-PT').format(new Date(d))
}

function diasAteExpiracao(dataFim: string | null): number | null {
  if (!dataFim) return null
  const diff = new Date(dataFim).getTime() - Date.now()
  return Math.ceil(diff / (1000 * 60 * 60 * 24))
}

const PARENTESCO_OPTIONS = [
  { value: '', label: 'Selecionar...' },
  { value: 'Pai', label: 'Pai' },
  { value: 'Mae', label: 'Mae' },
  { value: 'Tutor', label: 'Tutor Legal' },
  { value: 'Outro', label: 'Outro' },
]

const emptyForm = {
  imovelId: '',
  fracaoId: '',
  nomeInquilino: '',
  nifInquilino: '',
  contacto: '',
  nomeFiador: '',
  nifFiador: '',
  contactoFiador: '',
  parentesco: '',
  valorRenda: '',
  dataInicio: '',
  dataFim: '',
  renovacaoAuto: true,
  periodoRenovacao: 12,
  caucao: '',
  notas: '',
}

export default function ContratosPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role
  const canEdit = role ? hasPermission(role, 'imoveis:editar') : false

  const [contratos, setContratos] = useState<Contrato[]>([])
  const [imoveis, setImoveis] = useState<ImovelWithFracoes[]>([])
  const [loading, setLoading] = useState(true)
  const [filtroEstado, setFiltroEstado] = useState('')
  const [search, setSearch] = useState('')
  const [modalOpen, setModalOpen] = useState(false)
  const [editId, setEditId] = useState<string | null>(null)
  const [form, setForm] = useState(emptyForm)
  const [saving, setSaving] = useState(false)

  const loadContratos = useCallback(() => {
    const params = new URLSearchParams()
    if (filtroEstado) params.set('estado', filtroEstado)
    fetch(`/api/contratos?${params}`)
      .then((r) => r.json())
      .then((j) => { if (j.data) setContratos(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [filtroEstado])

  useEffect(() => { loadContratos() }, [loadContratos])

  useEffect(() => {
    fetch('/api/imoveis')
      .then((r) => r.json())
      .then((j) => { if (j.data) setImoveis(j.data) })
      .catch(() => {})
  }, [])

  const filtered = contratos.filter((c) => {
    if (!search) return true
    const s = search.toLowerCase()
    return c.nomeInquilino.toLowerCase().includes(s)
      || c.imovel.nome.toLowerCase().includes(s)
      || c.fracao.nome.toLowerCase().includes(s)
      || (c.nifInquilino && c.nifInquilino.includes(s))
  })

  // KPIs
  const ativos = contratos.filter((c) => c.estado === 'ATIVO')
  const rendaTotal = ativos.reduce((s, c) => s + Number(c.valorRenda), 0)
  const expirando30 = ativos.filter((c) => {
    const dias = diasAteExpiracao(c.dataFim)
    return dias !== null && dias >= 0 && dias <= 30
  })
  const expirados = contratos.filter((c) => c.estado === 'ATIVO' && c.dataFim && new Date(c.dataFim) < new Date())

  function openNew() {
    setEditId(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(c: Contrato) {
    setEditId(c.id)
    setForm({
      imovelId: c.imovelId,
      fracaoId: c.fracaoId,
      nomeInquilino: c.nomeInquilino,
      nifInquilino: c.nifInquilino || '',
      contacto: c.contacto || '',
      nomeFiador: c.nomeFiador || '',
      nifFiador: c.nifFiador || '',
      contactoFiador: c.contactoFiador || '',
      parentesco: c.parentesco || '',
      valorRenda: String(c.valorRenda),
      dataInicio: c.dataInicio.slice(0, 10),
      dataFim: c.dataFim ? c.dataFim.slice(0, 10) : '',
      renovacaoAuto: c.renovacaoAuto,
      periodoRenovacao: c.periodoRenovacao,
      caucao: c.caucao ? String(c.caucao) : '',
      notas: c.notas || '',
    })
    setModalOpen(true)
  }

  async function handleSave() {
    setSaving(true)
    try {
      const method = editId ? 'PUT' : 'POST'
      const payload = editId ? { id: editId, ...form } : form
      const res = await fetch('/api/contratos', {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })
      if (res.ok) {
        setModalOpen(false)
        loadContratos()
      }
    } catch { /* ignore */ }
    finally { setSaving(false) }
  }

  async function handleDelete(id: string) {
    if (!confirm('Eliminar este contrato?')) return
    await fetch('/api/contratos', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id }),
    })
    loadContratos()
  }

  async function handleTerminar(id: string) {
    if (!confirm('Terminar este contrato?')) return
    await fetch('/api/contratos', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, estado: 'TERMINADO', dataFim: new Date().toISOString().slice(0, 10) }),
    })
    loadContratos()
  }

  async function handleRenovar(c: Contrato) {
    const novaDataInicio = c.dataFim ? new Date(c.dataFim) : new Date()
    const novaDataFim = new Date(novaDataInicio)
    novaDataFim.setMonth(novaDataFim.getMonth() + c.periodoRenovacao)

    // Terminar contrato atual
    await fetch('/api/contratos', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: c.id, estado: 'TERMINADO' }),
    })

    // Criar novo contrato renovado
    await fetch('/api/contratos', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        fracaoId: c.fracaoId,
        imovelId: c.imovelId,
        nomeInquilino: c.nomeInquilino,
        nifInquilino: c.nifInquilino,
        contacto: c.contacto,
        nomeFiador: c.nomeFiador,
        nifFiador: c.nifFiador,
        contactoFiador: c.contactoFiador,
        parentesco: c.parentesco,
        valorRenda: c.valorRenda,
        dataInicio: novaDataInicio.toISOString().slice(0, 10),
        dataFim: novaDataFim.toISOString().slice(0, 10),
        renovacaoAuto: c.renovacaoAuto,
        periodoRenovacao: c.periodoRenovacao,
        caucao: c.caucao,
        notas: c.notas,
      }),
    })
    loadContratos()
  }

  const selectedImovel = imoveis.find((im) => im.id === form.imovelId)
  const fracaoOptions = selectedImovel?.fracoes?.map((f) => ({ value: f.id, label: f.nome })) || []

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-5">
      {/* KPIs */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <KpiCard label="Contratos Ativos" value={String(ativos.length)} color="green" />
        <KpiCard label="Renda Mensal Total" value={formatCurrency(rendaTotal)} color="green" />
        <KpiCard label="Expira em 30 dias" value={String(expirando30.length)} color={expirando30.length > 0 ? 'amber' : 'green'} />
        <KpiCard label="Expirados" value={String(expirados.length)} color={expirados.length > 0 ? 'red' : 'green'} />
      </div>

      {/* Filtros */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="w-64">
          <Input placeholder="Pesquisar contratos..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <div className="w-40">
          <Select options={ESTADO_OPTIONS} value={filtroEstado} onChange={(e) => setFiltroEstado(e.target.value)} />
        </div>
        {canEdit && <Button onClick={openNew}>Novo Contrato</Button>}
      </div>

      {/* Tabela */}
      <Card className="p-0 overflow-x-auto">
        <Table>
          <thead>
            <tr>
              <Th>Imovel</Th>
              <Th>Fracao</Th>
              <Th>Inquilino</Th>
              <Th>Fiador</Th>
              <Th>Renda</Th>
              <Th>Inicio</Th>
              <Th>Fim</Th>
              <Th>Renovacao</Th>
              <Th>AT</Th>
              <Th>Estado</Th>
              {canEdit && <Th>Acoes</Th>}
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 && (
              <tr><Td colSpan={canEdit ? 11 : 10}><span className="text-gray-400">Nenhum contrato encontrado</span></Td></tr>
            )}
            {filtered.map((c) => {
              const dias = diasAteExpiracao(c.dataFim)
              const expiraSoon = dias !== null && dias >= 0 && dias <= 30
              return (
                <tr key={c.id}>
                  <Td>{c.imovel.nome}</Td>
                  <Td>{c.fracao.nome}</Td>
                  <Td>
                    <span className="font-medium">{c.nomeInquilino}</span>
                    {c.nifInquilino && <div className="text-[10px] text-gray-400">{c.nifInquilino}</div>}
                  </Td>
                  <Td>
                    {c.nomeFiador ? (
                      <>
                        <span className="text-[12px]">{c.nomeFiador}</span>
                        {c.parentesco && <span className="text-[10px] text-gray-400 ml-1">({c.parentesco})</span>}
                      </>
                    ) : '-'}
                  </Td>
                  <Td><span style={{ color: '#0F6E56' }}>{formatCurrency(Number(c.valorRenda))}</span></Td>
                  <Td>{formatDate(c.dataInicio)}</Td>
                  <Td>
                    <span style={{ color: expiraSoon ? '#A32D2D' : undefined, fontWeight: expiraSoon ? 600 : undefined }}>
                      {formatDate(c.dataFim)}
                    </span>
                    {expiraSoon && dias !== null && (
                      <span className="text-[10px] ml-1" style={{ color: '#A32D2D' }}>({dias}d)</span>
                    )}
                  </Td>
                  <Td>{c.renovacaoAuto ? `Auto (${c.periodoRenovacao}m)` : 'Manual'}</Td>
                  <Td>
                    {canEdit ? (
                      <button
                        onClick={async () => {
                          await fetch('/api/contratos', {
                            method: 'PUT',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ id: c.id, comunicadoAT: !c.comunicadoAT }),
                          })
                          loadContratos()
                        }}
                        className="text-[12px] font-medium"
                        style={{ color: c.comunicadoAT ? '#0F6E56' : '#A32D2D' }}
                        title={c.comunicadoAT && c.dataComunicacaoAT ? `Comunicado em ${formatDate(c.dataComunicacaoAT)}` : 'Clicar para marcar como comunicado'}
                      >
                        {c.comunicadoAT ? 'Sim' : 'Nao'}
                      </button>
                    ) : (
                      <span className="text-[12px]" style={{ color: c.comunicadoAT ? '#0F6E56' : '#A32D2D' }}>
                        {c.comunicadoAT ? 'Sim' : 'Nao'}
                      </span>
                    )}
                  </Td>
                  <Td><Badge variant={ESTADO_BADGE[c.estado] || 'gray'}>{c.estado}</Badge></Td>
                  {canEdit && (
                    <Td>
                      <div className="flex gap-2 text-[12px]">
                        <button className="text-[#0C447C] hover:underline" onClick={() => openEdit(c)}>Editar</button>
                        {c.estado === 'ATIVO' && (
                          <>
                            <button className="text-[#1D9E75] hover:underline" onClick={() => handleRenovar(c)}>Renovar</button>
                            <button className="text-[#633806] hover:underline" onClick={() => handleTerminar(c.id)}>Terminar</button>
                          </>
                        )}
                        <button className="text-[#A32D2D] hover:underline" onClick={() => handleDelete(c.id)}>Eliminar</button>
                      </div>
                    </Td>
                  )}
                </tr>
              )
            })}
          </tbody>
        </Table>
      </Card>

      {/* Modal Criar/Editar */}
      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editId ? 'Editar Contrato' : 'Novo Contrato'}>
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <Select
              label="Imovel"
              options={[{ value: '', label: 'Selecionar...' }, ...imoveis.map((im) => ({ value: im.id, label: `${im.codigo} — ${im.nome}` }))]}
              value={form.imovelId}
              onChange={(e) => setForm({ ...form, imovelId: e.target.value, fracaoId: '' })}
            />
            <Select
              label="Fracao"
              options={[{ value: '', label: 'Selecionar...' }, ...fracaoOptions]}
              value={form.fracaoId}
              onChange={(e) => setForm({ ...form, fracaoId: e.target.value })}
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Input label="Nome Inquilino" value={form.nomeInquilino} onChange={(e) => setForm({ ...form, nomeInquilino: e.target.value })} />
            <Input label="NIF Inquilino" value={form.nifInquilino} onChange={(e) => setForm({ ...form, nifInquilino: e.target.value })} />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Input label="Contacto Inquilino" value={form.contacto} onChange={(e) => setForm({ ...form, contacto: e.target.value })} />
            <Input label="Valor Renda (EUR)" type="number" step="0.01" value={form.valorRenda} onChange={(e) => setForm({ ...form, valorRenda: e.target.value })} />
          </div>

          {/* Fiador */}
          <div className="pt-2 border-t border-gray-200">
            <h4 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>Fiador</h4>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Nome do Fiador" value={form.nomeFiador} onChange={(e) => setForm({ ...form, nomeFiador: e.target.value })} />
              <Select
                label="Parentesco"
                options={PARENTESCO_OPTIONS}
                value={form.parentesco}
                onChange={(e) => setForm({ ...form, parentesco: e.target.value })}
              />
            </div>
            <div className="grid grid-cols-2 gap-3 mt-3">
              <Input label="NIF do Fiador" value={form.nifFiador} onChange={(e) => setForm({ ...form, nifFiador: e.target.value })} />
              <Input label="Contacto do Fiador" value={form.contactoFiador} onChange={(e) => setForm({ ...form, contactoFiador: e.target.value })} />
            </div>
          </div>

          {/* Datas */}
          <div className="pt-2 border-t border-gray-200">
            <h4 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>Periodo</h4>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Data Inicio" type="date" value={form.dataInicio} onChange={(e) => setForm({ ...form, dataInicio: e.target.value })} />
              <Input label="Data Fim" type="date" value={form.dataFim} onChange={(e) => setForm({ ...form, dataFim: e.target.value })} />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="flex items-center gap-2 pt-6">
              <input
                type="checkbox"
                checked={form.renovacaoAuto}
                onChange={(e) => setForm({ ...form, renovacaoAuto: e.target.checked })}
                className="w-4 h-4 rounded border-gray-300 accent-[#1D9E75]"
              />
              <span className="text-sm">Renovacao automatica</span>
            </div>
            <Input label="Periodo renovacao (meses)" type="number" value={String(form.periodoRenovacao)} onChange={(e) => setForm({ ...form, periodoRenovacao: parseInt(e.target.value) || 12 })} />
          </div>

          <Input label="Caucao (EUR)" type="number" step="0.01" value={form.caucao} onChange={(e) => setForm({ ...form, caucao: e.target.value })} />

          <div>
            <label className="block text-sm font-medium mb-1" style={{ color: '#374151' }}>Notas</label>
            <textarea
              className="w-full rounded-md border px-3 py-2 text-sm"
              style={{ borderColor: '#D1D5DB' }}
              rows={3}
              value={form.notas}
              onChange={(e) => setForm({ ...form, notas: e.target.value })}
            />
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <Button variant="secondary" onClick={() => setModalOpen(false)}>Cancelar</Button>
            <Button onClick={handleSave} disabled={saving}>{saving ? 'A guardar...' : editId ? 'Guardar' : 'Criar Contrato'}</Button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
