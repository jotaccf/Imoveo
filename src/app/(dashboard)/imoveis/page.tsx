'use client'

import { Fragment, useEffect, useState, useCallback, useRef } from 'react'
import { useSession } from 'next-auth/react'
import Link from 'next/link'
import { ChevronDown, ChevronRight, ArrowUp, ArrowDown, Upload, Trash2, FileText, Image } from 'lucide-react'
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
  letraQuarto: string | null
  tipoQuarto: string | null
  casaBanho: string | null
  mobilia: string | null
  numeroAnexo: string | null
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
  // Contrato fields
  fracaoAutonoma: string | null
  andar: string | null
  freguesia: string | null
  concelho: string | null
  artigoMatricial: string | null
  descricaoRP: string | null
  licencaUtilizacao: string | null
  dataLicenca: string | null
  entidadeLicenca: string | null
  dataContratoArrendamento: string | null
  modeloDespesas: string
  incluirSubtracaoCaucao: boolean
  // Proprietarios fields
  incluirProprietarios: boolean
  nomeProprietario1: string | null
  ccProprietario1: string | null
  nomeProprietario2: string | null
  nifProprietario2: string | null
  ccProprietario2: string | null
  regimeCasamento: string | null
  moradaProprietarios: string | null
  // Equipamentos
  equipamentos: string | null
  // Planta
  plantaPath: string | null
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

const MODELO_DESPESAS_OPTIONS = [
  { value: 'INCLUIDO', label: 'Incluido' },
  { value: 'INDIVIDUAL', label: 'Individual' },
]

type TabKey = 'geral' | 'contrato' | 'proprietarios' | 'equipamentos'

const emptyForm = {
  codigo: '', nome: '', tipo: 'APARTAMENTO', localizacao: '', morada: '', nifProprietario: '', estado: 'ACTIVO', valorPatrimonial: '', areaMt2: '',
  fracaoAutonoma: '', andar: '', freguesia: '', concelho: '', artigoMatricial: '', descricaoRP: '',
  licencaUtilizacao: '', dataLicenca: '', entidadeLicenca: '',
  dataContratoArrendamento: '', modeloDespesas: 'INCLUIDO', incluirSubtracaoCaucao: false,
  incluirProprietarios: true, nomeProprietario1: '', ccProprietario1: '',
  nomeProprietario2: '', nifProprietario2: '', ccProprietario2: '',
  regimeCasamento: '', moradaProprietarios: '',
  equipamentos: '',
}
const TIPO_QUARTO_OPTIONS = [
  { value: '', label: 'Selecionar...' },
  { value: 'Suite', label: 'Suite' },
  { value: 'Quarto Privado', label: 'Quarto Privado' },
  { value: 'Quarto Partilhado', label: 'Quarto Partilhado' },
]
const CASA_BANHO_OPTIONS = [
  { value: '', label: 'Selecionar...' },
  { value: 'Privativa', label: 'Privativa' },
  { value: 'Partilhada', label: 'Partilhada' },
]
const emptyFracaoForm = { nome: '', renda: '', nifInquilino: '', estado: 'VAGO', dataEntradaMercado: '', letraQuarto: '', tipoQuarto: '', casaBanho: '', mobilia: '', numeroAnexo: '' }

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
  const [activeTab, setActiveTab] = useState<TabKey>('geral')
  const [loading, setLoading] = useState(true)
  const [expandedIds, setExpandedIds] = useState<Set<string>>(new Set())
  const [fracaoModal, setFracaoModal] = useState(false)
  const [fracaoForm, setFracaoForm] = useState(emptyFracaoForm)
  const [editFracaoId, setEditFracaoId] = useState<string | null>(null)
  const [fracaoImovelId, setFracaoImovelId] = useState<string | null>(null)
  const [plantaUploading, setPlantaUploading] = useState(false)
  const plantaInputRef = useRef<HTMLInputElement>(null)

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

  function openCreate() { setEditId(null); setForm(emptyForm); setActiveTab('geral'); setModalOpen(true) }

  function openEdit(im: Imovel) {
    setEditId(im.id)
    setForm({
      codigo: im.codigo, nome: im.nome, tipo: im.tipo, localizacao: im.localizacao,
      morada: im.morada ?? '', nifProprietario: im.nifProprietario ?? '',
      estado: im.estado, valorPatrimonial: im.valorPatrimonial ?? '', areaMt2: im.areaMt2 ?? '',
      fracaoAutonoma: im.fracaoAutonoma ?? '', andar: im.andar ?? '',
      freguesia: im.freguesia ?? '', concelho: im.concelho ?? '',
      artigoMatricial: im.artigoMatricial ?? '', descricaoRP: im.descricaoRP ?? '',
      licencaUtilizacao: im.licencaUtilizacao ?? '', dataLicenca: im.dataLicenca ?? '',
      entidadeLicenca: im.entidadeLicenca ?? '',
      dataContratoArrendamento: im.dataContratoArrendamento ? String(im.dataContratoArrendamento).split('T')[0] : '',
      modeloDespesas: im.modeloDespesas ?? 'INCLUIDO',
      incluirSubtracaoCaucao: im.incluirSubtracaoCaucao ?? false,
      incluirProprietarios: im.incluirProprietarios ?? true,
      nomeProprietario1: im.nomeProprietario1 ?? '', ccProprietario1: im.ccProprietario1 ?? '',
      nomeProprietario2: im.nomeProprietario2 ?? '', nifProprietario2: im.nifProprietario2 ?? '',
      ccProprietario2: im.ccProprietario2 ?? '',
      regimeCasamento: im.regimeCasamento ?? '', moradaProprietarios: im.moradaProprietarios ?? '',
      equipamentos: im.equipamentos ?? '',
    })
    setActiveTab('geral')
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
    setFracaoForm({ nome: f.nome, renda: f.renda, nifInquilino: f.nifInquilino ?? '', estado: f.estado, dataEntradaMercado: f.dataEntradaMercado ? String(f.dataEntradaMercado).split('T')[0] : '', letraQuarto: f.letraQuarto ?? '', tipoQuarto: f.tipoQuarto ?? '', casaBanho: f.casaBanho ?? '', mobilia: f.mobilia ?? '', numeroAnexo: f.numeroAnexo ?? '' })
    setFracaoModal(true)
  }

  async function handleSaveFracao() {
    if (!fracaoImovelId) return
    const payload = { imovelId: fracaoImovelId, nome: fracaoForm.nome, renda: fracaoForm.renda, nifInquilino: fracaoForm.nifInquilino || null, estado: fracaoForm.estado, dataEntradaMercado: fracaoForm.dataEntradaMercado || null, letraQuarto: fracaoForm.letraQuarto || null, tipoQuarto: fracaoForm.tipoQuarto || null, casaBanho: fracaoForm.casaBanho || null, mobilia: fracaoForm.mobilia || null, numeroAnexo: fracaoForm.numeroAnexo || null }
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

  async function handlePlantaUpload(file: File) {
    if (!editId) return
    setPlantaUploading(true)
    try {
      const fd = new FormData()
      fd.append('file', file)
      const res = await fetch(`/api/imoveis/${editId}/planta`, { method: 'POST', body: fd })
      if (res.ok) fetchData()
    } catch { /* */ }
    finally { setPlantaUploading(false) }
  }

  async function handlePlantaDelete() {
    if (!editId) return
    if (!confirm('Remover planta deste imovel?')) return
    await fetch(`/api/imoveis/${editId}/planta`, { method: 'DELETE' })
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
      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editId ? 'Editar imovel' : 'Adicionar imovel'} className="max-w-2xl"
        footer={<div className="flex gap-2 ml-auto"><Button variant="ghost" onClick={() => setModalOpen(false)}>Cancelar</Button><Button onClick={handleSave}>{editId ? 'Guardar' : 'Criar'}</Button></div>}>
        {/* Tabs */}
        <div style={{ display: 'flex', gap: '4px', marginBottom: '16px', borderBottom: '1px solid #e5e7eb', paddingBottom: '0' }}>
          {([['geral', 'Geral'], ['contrato', 'Contrato'], ['proprietarios', 'Proprietarios'], ['equipamentos', 'Equipamentos']] as const).map(([key, label]) => (
            <button
              key={key}
              onClick={() => setActiveTab(key)}
              style={{
                padding: '8px 16px',
                fontSize: '13px',
                fontWeight: activeTab === key ? 600 : 400,
                color: activeTab === key ? '#1D9E75' : '#6b7280',
                borderBottom: activeTab === key ? '2px solid #1D9E75' : '2px solid transparent',
                background: 'none',
                cursor: 'pointer',
                marginBottom: '-1px',
                transition: 'color 0.15s, border-color 0.15s',
              }}
            >
              {label}
            </button>
          ))}
        </div>

        {/* Tab: Geral */}
        {activeTab === 'geral' && (
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
        )}

        {/* Tab: Contrato */}
        {activeTab === 'contrato' && (
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <Input label="Fracao autonoma" value={form.fracaoAutonoma} onChange={(e) => setForm({ ...form, fracaoAutonoma: e.target.value })} />
              <Input label="Andar" value={form.andar} onChange={(e) => setForm({ ...form, andar: e.target.value })} />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Freguesia" value={form.freguesia} onChange={(e) => setForm({ ...form, freguesia: e.target.value })} />
              <Input label="Concelho" value={form.concelho} onChange={(e) => setForm({ ...form, concelho: e.target.value })} />
            </div>
            <Input label="Artigo matricial" value={form.artigoMatricial} onChange={(e) => setForm({ ...form, artigoMatricial: e.target.value })} />
            <Input label="Descricao do registo predial" value={form.descricaoRP} onChange={(e) => setForm({ ...form, descricaoRP: e.target.value })} />
            <Input label="Data do contrato de arrendamento" type="date" value={form.dataContratoArrendamento} onChange={(e) => setForm({ ...form, dataContratoArrendamento: e.target.value })} />
            <div className="grid grid-cols-2 gap-3">
              <Input label="Licenca de utilizacao" value={form.licencaUtilizacao} onChange={(e) => setForm({ ...form, licencaUtilizacao: e.target.value })} />
              <Input label="Data da licenca" value={form.dataLicenca} onChange={(e) => setForm({ ...form, dataLicenca: e.target.value })} />
            </div>
            <Input label="Entidade da licenca" value={form.entidadeLicenca} onChange={(e) => setForm({ ...form, entidadeLicenca: e.target.value })} />
            <Select label="Modelo de despesas" options={MODELO_DESPESAS_OPTIONS} value={form.modeloDespesas} onChange={(e) => setForm({ ...form, modeloDespesas: e.target.value })} />
            <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
              <input
                type="checkbox"
                checked={form.incluirSubtracaoCaucao}
                onChange={(e) => setForm({ ...form, incluirSubtracaoCaucao: e.target.checked })}
                className="rounded border-gray-300"
                style={{ accentColor: '#1D9E75' }}
              />
              Incluir subtracao de caucao
            </label>
          </div>
        )}

        {/* Tab: Proprietarios */}
        {activeTab === 'proprietarios' && (
          <div className="space-y-3">
            <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
              <input
                type="checkbox"
                checked={form.incluirProprietarios}
                onChange={(e) => setForm({ ...form, incluirProprietarios: e.target.checked })}
                className="rounded border-gray-300"
                style={{ accentColor: '#1D9E75' }}
              />
              Incluir proprietarios no contrato
            </label>
            <div className="border-t border-gray-100 pt-3">
              <p className="text-[11px] font-medium text-gray-400 uppercase tracking-wide mb-2">Proprietario 1</p>
              <div className="grid grid-cols-2 gap-3">
                <Input label="Nome" value={form.nomeProprietario1} onChange={(e) => setForm({ ...form, nomeProprietario1: e.target.value })} />
                <Input label="CC" value={form.ccProprietario1} onChange={(e) => setForm({ ...form, ccProprietario1: e.target.value })} />
              </div>
            </div>
            <div className="border-t border-gray-100 pt-3">
              <p className="text-[11px] font-medium text-gray-400 uppercase tracking-wide mb-2">Proprietario 2</p>
              <div className="grid grid-cols-2 gap-3">
                <Input label="Nome" value={form.nomeProprietario2} onChange={(e) => setForm({ ...form, nomeProprietario2: e.target.value })} />
                <Input label="NIF" value={form.nifProprietario2} onChange={(e) => setForm({ ...form, nifProprietario2: e.target.value })} />
              </div>
              <div className="mt-3">
                <Input label="CC" value={form.ccProprietario2} onChange={(e) => setForm({ ...form, ccProprietario2: e.target.value })} />
              </div>
            </div>
            <Input label="Regime de casamento" value={form.regimeCasamento} onChange={(e) => setForm({ ...form, regimeCasamento: e.target.value })} />
            <Input label="Morada dos proprietarios" value={form.moradaProprietarios} onChange={(e) => setForm({ ...form, moradaProprietarios: e.target.value })} />
          </div>
        )}

        {/* Tab: Equipamentos */}
        {activeTab === 'equipamentos' && (
          <div className="space-y-3">
            <label className="block text-sm font-medium text-gray-700">Equipamentos</label>
            <textarea
              value={form.equipamentos}
              onChange={(e) => setForm({ ...form, equipamentos: e.target.value })}
              rows={8}
              className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
              placeholder="Lista de equipamentos incluidos no imovel..."
              style={{ resize: 'vertical' }}
            />

            {/* Planta */}
            {editId && (
              <div className="pt-3 border-t border-gray-200">
                <h4 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>Planta</h4>
                {(() => {
                  const currentImovel = imoveis.find((im) => im.id === editId)
                  const hasPlanta = !!currentImovel?.plantaPath
                  const isImage = hasPlanta && (currentImovel!.plantaPath!.endsWith('.jpg') || currentImovel!.plantaPath!.endsWith('.jpeg') || currentImovel!.plantaPath!.endsWith('.png'))
                  return (
                    <div className="space-y-2">
                      {hasPlanta ? (
                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                          {isImage ? <Image size={20} className="text-brand-primary" /> : <FileText size={20} className="text-brand-primary" />}
                          <a
                            href={`/api/imoveis/${editId}/planta`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-sm text-[#0C447C] hover:underline flex-1"
                          >
                            Ver planta
                          </a>
                          <button
                            onClick={handlePlantaDelete}
                            className="p-1.5 rounded hover:bg-red-50 text-[#A32D2D] transition-colors"
                            title="Remover planta"
                          >
                            <Trash2 size={16} />
                          </button>
                        </div>
                      ) : (
                        <p className="text-[12px] text-gray-400">Sem planta carregada</p>
                      )}
                      <input
                        ref={plantaInputRef}
                        type="file"
                        accept=".pdf,.jpg,.jpeg,.png"
                        className="hidden"
                        onChange={(e) => {
                          const f = e.target.files?.[0]
                          if (f) handlePlantaUpload(f)
                          e.target.value = ''
                        }}
                      />
                      <button
                        onClick={() => plantaInputRef.current?.click()}
                        disabled={plantaUploading}
                        className="flex items-center gap-2 px-3 py-2 text-sm rounded-lg border border-dashed border-gray-300 hover:border-brand-primary hover:bg-brand-light/20 transition-colors disabled:opacity-50"
                      >
                        <Upload size={16} className="text-gray-400" />
                        {plantaUploading ? 'A carregar...' : hasPlanta ? 'Substituir planta' : 'Carregar planta'}
                      </button>
                      <p className="text-[10px] text-gray-400">PDF, JPG ou PNG (max 10MB)</p>
                    </div>
                  )
                })()}
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* Create / Edit Fracao Modal */}
      <Modal open={fracaoModal} onClose={() => setFracaoModal(false)} title={editFracaoId ? 'Editar quarto' : 'Adicionar quarto'}
        footer={<div className="flex gap-2 ml-auto"><Button variant="ghost" onClick={() => setFracaoModal(false)}>Cancelar</Button><Button onClick={handleSaveFracao}>{editFracaoId ? 'Guardar' : 'Criar'}</Button></div>}>
        <div className="space-y-3">
          <Input label="Nome" value={fracaoForm.nome} onChange={(e) => setFracaoForm({ ...fracaoForm, nome: e.target.value })} />
          <div className="grid grid-cols-2 gap-3">
            <Input label="Renda (EUR)" type="number" value={fracaoForm.renda} onChange={(e) => setFracaoForm({ ...fracaoForm, renda: e.target.value })} />
            <Select label="Estado" options={FRACAO_ESTADO_OPTIONS} value={fracaoForm.estado} onChange={(e) => setFracaoForm({ ...fracaoForm, estado: e.target.value })} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Input label="NIF Inquilino" value={fracaoForm.nifInquilino} onChange={(e) => setFracaoForm({ ...fracaoForm, nifInquilino: e.target.value })} />
            <Input label="Data entrada no mercado" type="date" value={fracaoForm.dataEntradaMercado} onChange={(e) => setFracaoForm({ ...fracaoForm, dataEntradaMercado: e.target.value })} />
          </div>

          {/* Detalhes para Contrato */}
          <div className="pt-3 border-t border-gray-200">
            <h4 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>Detalhes para Contrato</h4>
            <div className="grid grid-cols-3 gap-3">
              <Input label="Letra do quarto" value={fracaoForm.letraQuarto} onChange={(e) => setFracaoForm({ ...fracaoForm, letraQuarto: e.target.value })} placeholder="A" />
              <Select label="Tipo quarto" options={TIPO_QUARTO_OPTIONS} value={fracaoForm.tipoQuarto} onChange={(e) => setFracaoForm({ ...fracaoForm, tipoQuarto: e.target.value })} />
              <Select label="Casa de banho" options={CASA_BANHO_OPTIONS} value={fracaoForm.casaBanho} onChange={(e) => setFracaoForm({ ...fracaoForm, casaBanho: e.target.value })} />
            </div>
            <div className="grid grid-cols-2 gap-3 mt-3">
              <Input label="Numero anexo (planta)" value={fracaoForm.numeroAnexo} onChange={(e) => setFracaoForm({ ...fracaoForm, numeroAnexo: e.target.value })} placeholder="I" />
              <div />
            </div>
            <div className="mt-3">
              <label className="block text-sm font-medium mb-1" style={{ color: '#374151' }}>Mobilia incluida</label>
              <textarea
                className="w-full rounded-md border px-3 py-2 text-sm"
                style={{ borderColor: '#D1D5DB' }}
                rows={3}
                value={fracaoForm.mobilia}
                onChange={(e) => setFracaoForm({ ...fracaoForm, mobilia: e.target.value })}
                placeholder="cama, secretaria, cadeira, guarda fatos, candeeiro"
              />
            </div>
          </div>
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
