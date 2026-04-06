'use client'

import { Fragment, useEffect, useState, useCallback } from 'react'
import { useSession } from 'next-auth/react'
import Link from 'next/link'
import { ChevronDown, ChevronRight, ArrowUp, ArrowDown } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Badge } from '@/components/ui/Badge'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Modal } from '@/components/ui/Modal'
import { hasPermission, type Role } from '@/lib/permissions'
import { formatCurrency } from '@/lib/utils'

interface Fracao {
  id: string
  nome: string
  renda: string
  nifInquilino: string | null
  dataEntradaMercado: string | null
  estado: string
}

interface Imovel {
  id: string
  codigo: string
  nome: string
  tipo: string
  morada: string | null
  localizacao: string
  nifProprietario: string | null
  valorPatrimonial: string | null
  areaMt2: string | null
  estado: string
  fracoes?: Fracao[]
}

const ESTADO_BADGE: Record<string, 'green' | 'red' | 'amber' | 'gray'> = {
  ACTIVO: 'green', VAGO: 'red', EM_OBRAS: 'amber', INACTIVO: 'gray',
}

const FRACAO_ESTADO_BADGE: Record<string, 'green' | 'red' | 'amber'> = {
  OCUPADO: 'green', VAGO: 'red', EM_OBRAS: 'amber',
}

const TIPO_OPTIONS = [
  { value: 'APARTAMENTO', label: 'Apartamento' },
  { value: 'MORADIA', label: 'Moradia' },
  { value: 'LOJA', label: 'Loja' },
  { value: 'ESCRITORIO', label: 'Escritorio' },
  { value: 'OUTRO', label: 'Outro' },
]

const ESTADO_OPTIONS = [
  { value: 'ACTIVO', label: 'Activo' },
  { value: 'VAGO', label: 'Vago' },
  { value: 'EM_OBRAS', label: 'Em obras' },
  { value: 'INACTIVO', label: 'Inactivo' },
]

const FRACAO_ESTADO_OPTIONS = [
  { value: 'OCUPADO', label: 'Ocupado' },
  { value: 'VAGO', label: 'Vago' },
  { value: 'EM_OBRAS', label: 'Em obras' },
]

const TIPOS_COM_QUARTOS = ['APARTAMENTO', 'MORADIA', 'OUTRO']

const emptyForm = { codigo: '', nome: '', tipo: 'APARTAMENTO', localizacao: '', morada: '', nifProprietario: '', estado: 'ACTIVO', valorPatrimonial: '', areaMt2: '' }
const emptyFracaoForm = { nome: '', renda: '', nifInquilino: '', estado: 'VAGO', dataEntradaMercado: '' }

export default function ImoveisPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role

  const [imoveis, setImoveis] = useState<Imovel[]>([])
  const [search, setSearch] = useState('')
  const [showCentrosCusto, setShowCentrosCusto] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [editId, setEditId] = useState<string | null>(null)
  const [form, setForm] = useState(emptyForm)
  const [deleteId, setDeleteId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [expandedIds, setExpandedIds] = useState<Set<string>>(new Set())
  const [fracaoModal, setFracaoModal] = useState(false)
  const [fracaoForm, setFracaoForm] = useState(emptyFracaoForm)
  const [editFracaoId, setEditFracaoId] = useState<string | null>(null)
  const [fracaoImovelId, setFracaoImovelId] = useState<string | null>(null)

  const canCreate = role ? hasPermission(role, 'imoveis:criar') : false
  const canEdit = role ? hasPermission(role, 'imoveis:editar') : false
  const canDelete = role ? hasPermission(role, 'imoveis:remover') : false

  const fetchData = useCallback(() => {
    fetch('/api/imoveis')
      .then((r) => r.json())
      .then((j) => { if (j.data) setImoveis(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => { fetchData() }, [fetchData])

  const CENTROS_CUSTO_TIPOS = ['GERAL', 'PESSOAL']
  const centrosCusto = imoveis.filter((i) => CENTROS_CUSTO_TIPOS.includes(i.tipo))
  const imoveisReais = imoveis.filter((i) => !CENTROS_CUSTO_TIPOS.includes(i.tipo))

  const filtered = imoveisReais.filter((i) =>
    !search || i.nome.toLowerCase().includes(search.toLowerCase()) ||
    i.codigo.toLowerCase().includes(search.toLowerCase()) ||
    i.localizacao.toLowerCase().includes(search.toLowerCase())
  )

  async function moveImovel(id: string, direction: 'up' | 'down') {
    const idx = filtered.findIndex((im) => im.id === id)
    if (idx === -1) return
    if (direction === 'up' && idx === 0) return
    if (direction === 'down' && idx === filtered.length - 1) return

    const newIdx = direction === 'up' ? idx - 1 : idx + 1
    const reordered = [...filtered]
    const temp = reordered[idx]
    reordered[idx] = reordered[newIdx]
    reordered[newIdx] = temp

    await fetch('/api/imoveis/reordenar', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ids: reordered.map((im) => im.id) }),
    })
    fetchData()
  }

  function toggleExpand(id: string) {
    setExpandedIds((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  function openCreate() { setEditId(null); setForm(emptyForm); setModalOpen(true) }

  function openEdit(im: Imovel) {
    setEditId(im.id)
    setForm({ codigo: im.codigo, nome: im.nome, tipo: im.tipo, localizacao: im.localizacao, morada: im.morada ?? '', nifProprietario: im.nifProprietario ?? '', estado: im.estado, valorPatrimonial: im.valorPatrimonial ?? '', areaMt2: im.areaMt2 ?? '' })
    setModalOpen(true)
  }

  async function handleSave() {
    if (editId) {
      await fetch(`/api/imoveis/${editId}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(form) })
    } else {
      await fetch('/api/imoveis', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(form) })
    }
    setModalOpen(false)
    fetchData()
  }

  async function handleDelete() {
    if (!deleteId) return
    await fetch(`/api/imoveis/${deleteId}`, { method: 'DELETE' })
    setDeleteId(null)
    fetchData()
  }

  function openCreateFracao(imovelId: string) {
    setFracaoImovelId(imovelId)
    setEditFracaoId(null)
    setFracaoForm(emptyFracaoForm)
    setFracaoModal(true)
  }

  function openEditFracao(imovelId: string, f: Fracao) {
    setFracaoImovelId(imovelId)
    setEditFracaoId(f.id)
    setFracaoForm({ nome: f.nome, renda: f.renda, nifInquilino: f.nifInquilino ?? '', estado: f.estado, dataEntradaMercado: f.dataEntradaMercado ? String(f.dataEntradaMercado).split('T')[0] : '' })
    setFracaoModal(true)
  }

  async function handleSaveFracao() {
    if (!fracaoImovelId) return
    const payload = { imovelId: fracaoImovelId, nome: fracaoForm.nome, renda: fracaoForm.renda, nifInquilino: fracaoForm.nifInquilino || null, estado: fracaoForm.estado, dataEntradaMercado: fracaoForm.dataEntradaMercado || null }
    if (editFracaoId) {
      await fetch(`/api/fracoes/${editFracaoId}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) })
    } else {
      await fetch('/api/fracoes', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) })
    }
    setFracaoModal(false)
    fetchData()
  }

  async function handleDeleteFracao(fracaoId: string) {
    await fetch(`/api/fracoes/${fracaoId}`, { method: 'DELETE' })
    fetchData()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  const colCount = 6 + (canEdit || canDelete ? 1 : 0) + (canEdit ? 1 : 0)

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="flex-1 max-w-xs">
          <Input placeholder="Pesquisar imoveis..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        {canCreate && <Button onClick={openCreate}>Adicionar imovel</Button>}
      </div>

      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              {canEdit && <Th className="w-8" />}
              <Th className="w-8" />
              <Th>Codigo</Th>
              <Th>Designacao</Th>
              <Th>Tipo</Th>
              <Th>Localizacao</Th>
              <Th>Estado</Th>
              {(canEdit || canDelete) && <Th>Accoes</Th>}
            </tr>
          </thead>
          <tbody>
            {filtered.map((im, idx) => {
              const hasQuartos = TIPOS_COM_QUARTOS.includes(im.tipo)
              const hasFracoes = (im.fracoes?.length ?? 0) > 0
              const isExpanded = expandedIds.has(im.id)
              const showToggle = hasQuartos

              return (
                <Fragment key={im.id}>
                  <tr className="hover:bg-gray-50">
                    {canEdit && (
                      <Td className="w-8 px-1">
                        <div className="flex flex-col gap-0.5">
                          <button
                            onClick={() => moveImovel(im.id, 'up')}
                            disabled={idx === 0}
                            className="p-0.5 rounded hover:bg-gray-200 disabled:opacity-20 text-gray-400 hover:text-gray-600"
                          >
                            <ArrowUp size={12} />
                          </button>
                          <button
                            onClick={() => moveImovel(im.id, 'down')}
                            disabled={idx === filtered.length - 1}
                            className="p-0.5 rounded hover:bg-gray-200 disabled:opacity-20 text-gray-400 hover:text-gray-600"
                          >
                            <ArrowDown size={12} />
                          </button>
                        </div>
                      </Td>
                    )}
                    <Td className="w-8 px-2">
                      {showToggle ? (
                        <div className="flex items-center gap-1.5">
                          <button
                            onClick={() => toggleExpand(im.id)}
                            className="p-0.5 rounded hover:bg-gray-200 transition-colors"
                          >
                            {isExpanded
                              ? <ChevronDown size={16} className="text-brand-primary" />
                              : <ChevronRight size={16} className={hasFracoes ? 'text-brand-primary' : 'text-gray-400'} />
                            }
                          </button>
                          {hasFracoes && (() => {
                            const total = im.fracoes!.length
                            const ocupados = im.fracoes!.filter((f) => f.estado === 'OCUPADO').length
                            const pct = Math.round((ocupados / total) * 100)
                            return (
                              <span className={`text-[10px] font-medium ${pct === 100 ? 'text-[#0F6E56]' : pct === 0 ? 'text-[#A32D2D]' : 'text-[#633806]'}`}>
                                {ocupados}/{total}
                              </span>
                            )
                          })()}
                        </div>
                      ) : (
                        <span className="w-4 inline-block" />
                      )}
                    </Td>
                    <Td><span className="font-mono text-[11px]">{im.codigo}</span></Td>
                    <Td>
                      <span className="font-medium">{im.nome}</span>
                      {hasFracoes && (
                        <span className="ml-2 text-[10px] text-gray-400">
                          {im.fracoes!.length} quarto{im.fracoes!.length > 1 ? 's' : ''}
                        </span>
                      )}
                    </Td>
                    <Td>{im.tipo}</Td>
                    <Td>{im.localizacao}</Td>
                    <Td>
                      <Badge variant={ESTADO_BADGE[im.estado] ?? 'gray'}>{im.estado.replace('_', ' ')}</Badge>
                    </Td>
                    {(canEdit || canDelete) && (
                      <Td>
                        {['CC-GERAL', 'CC-PESSOAL'].includes(im.codigo) ? (
                          <span className="text-[11px] text-gray-400">Protegido</span>
                        ) : (
                          <div className="flex items-center gap-2">
                            <Link href={`/imoveis/${im.id}`} className="text-[12px] text-brand-dark hover:underline">Detalhe</Link>
                            {canEdit && (
                              <button onClick={() => openEdit(im)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                            )}
                            {canDelete && (
                              <button onClick={() => setDeleteId(im.id)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                            )}
                          </div>
                        )}
                      </Td>
                    )}
                  </tr>

                  {/* Quartos colapsável */}
                  {isExpanded && hasQuartos && (
                    <tr>
                      <td colSpan={colCount + 1} className="bg-[#FAFBFC] px-4 py-3 border-b border-gray-100">
                        <div className="ml-6">
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-[11px] font-medium text-gray-500 uppercase tracking-wide">
                              Quartos — {im.nome}
                            </span>
                            {canEdit && (
                              <Button onClick={() => openCreateFracao(im.id)} className="text-[11px] px-2.5 py-1">
                                + Quarto
                              </Button>
                            )}
                          </div>

                          {(im.fracoes?.length ?? 0) === 0 ? (
                            <p className="text-[12px] text-gray-400 py-2">Sem quartos registados</p>
                          ) : (
                            <table className="w-full text-left">
                              <thead>
                                <tr>
                                  <th className="text-[10px] font-medium text-gray-400 pb-1.5 pr-4">Nome</th>
                                  <th className="text-[10px] font-medium text-gray-400 pb-1.5 pr-4">Renda</th>
                                  <th className="text-[10px] font-medium text-gray-400 pb-1.5 pr-4">NIF Inquilino</th>
                                  <th className="text-[10px] font-medium text-gray-400 pb-1.5 pr-4">Estado</th>
                                  {canEdit && <th className="text-[10px] font-medium text-gray-400 pb-1.5">Accoes</th>}
                                </tr>
                              </thead>
                              <tbody>
                                {im.fracoes!.map((f) => (
                                  <tr key={f.id} className="border-t border-gray-100">
                                    <td className="py-1.5 pr-4 text-[12px] font-medium">{f.nome}</td>
                                    <td className="py-1.5 pr-4 text-[12px] font-mono">{formatCurrency(Number(f.renda))}</td>
                                    <td className="py-1.5 pr-4 text-[11px] font-mono text-gray-500">{f.nifInquilino || '—'}</td>
                                    <td className="py-1.5 pr-4">
                                      <Badge variant={FRACAO_ESTADO_BADGE[f.estado] ?? 'gray'}>
                                        {f.estado.replace('_', ' ')}
                                      </Badge>
                                    </td>
                                    {canEdit && (
                                      <td className="py-1.5">
                                        <div className="flex items-center gap-2">
                                          <button onClick={() => openEditFracao(im.id, f)} className="text-[11px] text-brand-primary hover:underline">Editar</button>
                                          <button onClick={() => handleDeleteFracao(f.id)} className="text-[11px] text-[#A32D2D] hover:underline">Remover</button>
                                        </div>
                                      </td>
                                    )}
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          )}
                        </div>
                      </td>
                    </tr>
                  )}
                </Fragment>
              )
            })}
            {filtered.length === 0 && (
              <tr><Td colSpan={colCount + 1} className="text-center text-gray-400">Sem imoveis encontrados</Td></tr>
            )}
          </tbody>
        </Table>
      </Card>

      {/* Centros de Custo — colapsável */}
      {centrosCusto.length > 0 && (
        <Card className="p-0">
          <button
            onClick={() => setShowCentrosCusto(!showCentrosCusto)}
            className="w-full flex items-center justify-between px-5 py-3 hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center gap-2">
              {showCentrosCusto
                ? <ChevronDown size={16} className="text-brand-primary" />
                : <ChevronRight size={16} className="text-gray-400" />
              }
              <span className="text-[13px] font-medium" style={{ color: '#0D1B1A' }}>
                Centros de Custo
              </span>
              <Badge variant="gray">{centrosCusto.length}</Badge>
            </div>
          </button>
          {showCentrosCusto && (
            <Table>
              <thead>
                <tr>
                  <Th>Codigo</Th>
                  <Th>Designacao</Th>
                  <Th>Tipo</Th>
                  <Th>Estado</Th>
                  <Th />
                </tr>
              </thead>
              <tbody>
                {centrosCusto.map((cc) => (
                  <tr key={cc.id} className="hover:bg-gray-50">
                    <Td><span className="font-mono text-[11px]">{cc.codigo}</span></Td>
                    <Td className="font-medium">{cc.nome}</Td>
                    <Td>{cc.tipo}</Td>
                    <Td><Badge variant={ESTADO_BADGE[cc.estado] ?? 'gray'}>{cc.estado}</Badge></Td>
                    <Td><span className="text-[11px] text-gray-400">Protegido</span></Td>
                  </tr>
                ))}
              </tbody>
            </Table>
          )}
        </Card>
      )}

      {/* Create / Edit Imovel Modal */}
      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editId ? 'Editar imovel' : 'Adicionar imovel'}
        footer={<div className="flex gap-2 ml-auto"><Button variant="ghost" onClick={() => setModalOpen(false)}>Cancelar</Button><Button onClick={handleSave}>{editId ? 'Guardar' : 'Criar'}</Button></div>}>
        <div className="space-y-3">
          <Input label="Codigo" value={form.codigo} onChange={(e) => setForm({ ...form, codigo: e.target.value })} />
          <Input label="Nome / Designacao" value={form.nome} onChange={(e) => setForm({ ...form, nome: e.target.value })} />
          <Select label="Tipo" options={TIPO_OPTIONS} value={form.tipo} onChange={(e) => setForm({ ...form, tipo: e.target.value })} />
          <Input label="Localizacao" value={form.localizacao} onChange={(e) => setForm({ ...form, localizacao: e.target.value })} />
          <Input label="Morada" value={form.morada} onChange={(e) => setForm({ ...form, morada: e.target.value })} />
          <Input label="NIF Proprietario" value={form.nifProprietario} onChange={(e) => setForm({ ...form, nifProprietario: e.target.value })} />
          <Select label="Estado" options={ESTADO_OPTIONS} value={form.estado} onChange={(e) => setForm({ ...form, estado: e.target.value })} />
          <Input label="Valor patrimonial / Market value (€)" type="number" step="0.01" value={form.valorPatrimonial} onChange={(e) => setForm({ ...form, valorPatrimonial: e.target.value })} />
          <Input label="Area (m²)" type="number" step="0.01" value={form.areaMt2} onChange={(e) => setForm({ ...form, areaMt2: e.target.value })} />
        </div>
      </Modal>

      {/* Create / Edit Fracao Modal */}
      <Modal open={fracaoModal} onClose={() => setFracaoModal(false)} title={editFracaoId ? 'Editar quarto' : 'Adicionar quarto'}
        footer={<div className="flex gap-2 ml-auto"><Button variant="ghost" onClick={() => setFracaoModal(false)}>Cancelar</Button><Button onClick={handleSaveFracao}>{editFracaoId ? 'Guardar' : 'Criar'}</Button></div>}>
        <div className="space-y-3">
          <Input label="Nome" value={fracaoForm.nome} onChange={(e) => setFracaoForm({ ...fracaoForm, nome: e.target.value })} />
          <Input label="Renda" type="number" value={fracaoForm.renda} onChange={(e) => setFracaoForm({ ...fracaoForm, renda: e.target.value })} />
          <Input label="NIF Inquilino" value={fracaoForm.nifInquilino} onChange={(e) => setFracaoForm({ ...fracaoForm, nifInquilino: e.target.value })} />
          <Select label="Estado" options={FRACAO_ESTADO_OPTIONS} value={fracaoForm.estado} onChange={(e) => setFracaoForm({ ...fracaoForm, estado: e.target.value })} />
          <Input label="Data entrada no mercado" type="date" value={fracaoForm.dataEntradaMercado} onChange={(e) => setFracaoForm({ ...fracaoForm, dataEntradaMercado: e.target.value })} />
        </div>
      </Modal>

      {/* Delete confirmation */}
      <Modal open={!!deleteId} onClose={() => setDeleteId(null)} title="Confirmar remocao"
        footer={<div className="flex gap-2 ml-auto"><Button variant="ghost" onClick={() => setDeleteId(null)}>Cancelar</Button><Button variant="danger" onClick={handleDelete}>Remover</Button></div>}>
        <p className="text-sm text-gray-600">Tem a certeza que pretende desactivar este imovel? Esta accao pode ser revertida.</p>
      </Modal>
    </div>
  )
}
