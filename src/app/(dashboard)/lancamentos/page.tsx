'use client'

import { useEffect, useState, useCallback } from 'react'
import { useSession } from 'next-auth/react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Badge } from '@/components/ui/Badge'
import { Card } from '@/components/ui/Card'
import { KpiCard } from '@/components/ui/KpiCard'
import { Table, Th, Td } from '@/components/ui/Table'
import { Modal } from '@/components/ui/Modal'
import { Pagination } from '@/components/ui/Pagination'
import { formatCurrency, formatDate } from '@/lib/utils'
import { hasPermission, type Role } from '@/lib/permissions'

interface Lancamento {
  id: string
  tipoDoc: string
  numeroDoc: string | null
  fornecedor: string
  nifFornecedor: string | null
  imovelId: string
  rubricaId: string
  dataDoc: string
  valorSemIva: string
  taxaIva: number
  retencaoFonte: number
  valorRetencao: string | null
  totalComIva: string
  recorrente: boolean
  periodicidade: string | null
  dataFim: string | null
  notas: string | null
  imovel: { id: string; nome: string; codigo: string }
  rubrica: { id: string; nome: string; tipo: string }
}

interface ImovelOption { id: string; nome: string; codigo: string }
interface RubricaOption { id: string; nome: string; codigo: string; tipo: string }

const TIPO_DOC_OPTIONS = [
  { value: 'RECIBO_VERDE', label: 'Recibo Verde' },
  { value: 'CONTRATO_RENDA', label: 'Contrato Renda' },
  { value: 'FATURA_PAPEL', label: 'Fatura Papel' },
  { value: 'OUTRO', label: 'Outro' },
]

const PERIODICIDADE_OPTIONS = [
  { value: 'MENSAL', label: 'Mensal' },
  { value: 'TRIMESTRAL', label: 'Trimestral' },
  { value: 'ANUAL', label: 'Anual' },
]

const IVA_OPTIONS = [
  { value: '23', label: '23% (normal)' },
  { value: '13', label: '13% (intermedia)' },
  { value: '6', label: '6% (reduzida)' },
  { value: '0', label: 'Isento' },
]

const RETENCAO_OPTIONS = [
  { value: '0', label: '0% (sem retencao)' },
  { value: '11.5', label: '11,5% (taxa reduzida)' },
  { value: '25', label: '25% (taxa geral)' },
]

// Auto-fill defaults por tipo de documento
const TIPO_DEFAULTS: Record<string, { taxaIva: string; retencaoFonte: string }> = {
  RECIBO_VERDE:   { taxaIva: '23', retencaoFonte: '25' },
  CONTRATO_RENDA: { taxaIva: '0',  retencaoFonte: '25' },
  FATURA_PAPEL:   { taxaIva: '23', retencaoFonte: '0' },
  OUTRO:          { taxaIva: '23', retencaoFonte: '0' },
}

const MESES_NOMES = ['Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro']

interface LancamentoForm {
  tipoDoc: string
  numeroDoc: string
  fornecedor: string
  nifFornecedor: string
  imovelId: string
  rubricaId: string
  dataDoc: string
  valorSemIva: string
  taxaIva: string
  totalComIva: string
  retencaoFonte: string
  recorrente: boolean
  periodicidade: string
  dataFim: string
  notas: string
  mesesSelecionados: string[]
  mesesDocs: Record<string, { doc?: string; data?: string }>
}

const emptyForm: LancamentoForm = {
  tipoDoc: 'RECIBO_VERDE', numeroDoc: '', fornecedor: '', nifFornecedor: '',
  imovelId: '', rubricaId: '', dataDoc: '', valorSemIva: '', taxaIva: '23',
  totalComIva: '', retencaoFonte: '25', recorrente: false, periodicidade: '', dataFim: '', notas: '',
  mesesSelecionados: [], mesesDocs: {},
}

export default function LancamentosPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role

  const [lancamentos, setLancamentos] = useState<Lancamento[]>([])
  const [imoveis, setImoveis] = useState<ImovelOption[]>([])
  const [rubricas, setRubricas] = useState<RubricaOption[]>([])
  const [search, setSearch] = useState('')
  const [filterImovel, setFilterImovel] = useState('')
  const [filterRubrica, setFilterRubrica] = useState('')
  const [dataDe, setDataDe] = useState('')
  const [dataAte, setDataAte] = useState('')
  const [page, setPage] = useState(1)
  const [limit, setLimit] = useState(50)
  const [pagination, setPagination] = useState({ page: 1, limit: 50, total: 0, totalPages: 0 })
  const [modalOpen, setModalOpen] = useState(false)
  const [editId, setEditId] = useState<string | null>(null)
  const [form, setForm] = useState<LancamentoForm>(emptyForm)
  const [loading, setLoading] = useState(true)

  function resetPage() { setPage(1) }

  const canCreate = role ? hasPermission(role, 'lancamentos:criar') : false
  const canEdit = role ? hasPermission(role, 'lancamentos:editar') : false
  const canDelete = role ? hasPermission(role, 'lancamentos:remover') : false

  const fetchData = useCallback(() => {
    const params = new URLSearchParams()
    if (search) params.set('search', search)
    if (filterImovel) params.set('imovelId', filterImovel)
    if (filterRubrica) params.set('rubricaId', filterRubrica)
    if (dataDe) params.set('dataDe', dataDe)
    if (dataAte) params.set('dataAte', dataAte)
    params.set('page', String(page))
    params.set('limit', String(limit))

    fetch(`/api/lancamentos?${params}`)
      .then((r) => r.json())
      .then((j) => {
        if (j.data) setLancamentos(j.data)
        setPagination(j.pagination || { page: 1, limit: 100, total: 0, totalPages: 0 })
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [search, filterImovel, filterRubrica, dataDe, dataAte, page, limit])

  useEffect(() => { fetchData() }, [fetchData])

  useEffect(() => {
    fetch('/api/opcoes').then((r) => r.json()).then((j) => {
      if (j.data) {
        setImoveis(j.data.imoveis)
        setRubricas(j.data.rubricas)
        // Pré-seleccionar "Rendas e Alugueres" como rubrica default
        const rda = j.data.rubricas.find((r: RubricaOption) => r.codigo === 'RDA')
        if (rda) setForm((prev) => ({ ...prev, rubricaId: prev.rubricaId || rda.id }))
      }
    }).catch(() => {})
  }, [])

  // KPI calculations
  const totalValor = lancamentos.reduce((s, l) => s + Number(l.totalComIva), 0)
  const recorrentes = lancamentos.filter((l) => l.recorrente).length
  const receitas = lancamentos.filter((l) => l.rubrica.tipo === 'RECEITA').reduce((s, l) => s + Number(l.totalComIva), 0)
  const gastos = lancamentos.filter((l) => l.rubrica.tipo === 'GASTO').reduce((s, l) => s + Number(l.totalComIva), 0)

  function openCreate() {
    setEditId(null)
    const rda = rubricas.find((r) => r.codigo === 'RDA')
    setForm({ ...emptyForm, rubricaId: rda?.id || '' })
    setModalOpen(true)
  }

  function openEdit(l: Lancamento) {
    setEditId(l.id)
    setForm({
      tipoDoc: l.tipoDoc,
      numeroDoc: l.numeroDoc ?? '',
      fornecedor: l.fornecedor,
      nifFornecedor: l.nifFornecedor ?? '',
      imovelId: l.imovelId,
      rubricaId: l.rubricaId,
      dataDoc: l.dataDoc.split('T')[0],
      valorSemIva: String(l.valorSemIva),
      taxaIva: String(l.taxaIva),
      retencaoFonte: String(l.retencaoFonte ?? 0),
      totalComIva: String(l.totalComIva),
      recorrente: l.recorrente,
      periodicidade: l.periodicidade ?? '',
      dataFim: l.dataFim ? l.dataFim.split('T')[0] : '',
      notas: l.notas ?? '',
      mesesSelecionados: [],
      mesesDocs: {},
    })
    setModalOpen(true)
  }

  async function handleSave() {
    // Validacao campos obrigatorios
    const erros: string[] = []
    if (!form.imovelId) erros.push('Imovel')
    if (!form.valorSemIva || Number(form.valorSemIva) === 0) erros.push('Valor')
    if (!form.fornecedor) erros.push('Fornecedor')
    if (!form.nifFornecedor) erros.push('NIF')
    if (erros.length > 0) {
      alert(`Campos obrigatorios em falta: ${erros.join(', ')}`)
      return
    }

    const meses = (form.mesesSelecionados || []) as string[]
    const mesesDocs = (form.mesesDocs || {}) as Record<string, { doc?: string; data?: string }>
    const ano = form.dataDoc ? new Date(String(form.dataDoc)).getFullYear() : new Date().getFullYear()

    function buildPayload(numDoc?: string, dataDoc?: string) {
      return {
        tipoDoc: form.tipoDoc,
        fornecedor: form.fornecedor,
        nifFornecedor: form.nifFornecedor || undefined,
        imovelId: form.imovelId,
        rubricaId: form.rubricaId,
        dataDoc: dataDoc || form.dataDoc,
        valorSemIva: Number(form.valorSemIva),
        taxaIva: Number(form.taxaIva),
        totalComIva: Number(form.totalComIva),
        retencaoFonte: Number(form.retencaoFonte),
        valorRetencao: Number(form.valorSemIva) * Number(form.retencaoFonte) / 100,
        notas: form.notas || undefined,
        numeroDoc: numDoc || form.numeroDoc || undefined,
        recorrente: false,
      }
    }

    if (editId) {
      await fetch(`/api/lancamentos/${editId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(buildPayload(String(form.numeroDoc), String(form.dataDoc))),
      })
    } else if (form.recorrente && meses.length > 0) {
      // Criar um lancamento por cada mes seleccionado
      for (const m of meses.sort((a, b) => Number(a) - Number(b))) {
        const mesInfo = mesesDocs[m] || {}
        const dataDefault = `${ano}-${String(Number(m) + 1).padStart(2, '0')}-01`
        const payload = buildPayload(mesInfo.doc, mesInfo.data || dataDefault)
        await fetch('/api/lancamentos', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        })
      }
    } else {
      await fetch('/api/lancamentos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(buildPayload(String(form.numeroDoc), String(form.dataDoc))),
      })
    }
    setModalOpen(false)
    fetchData()
  }

  async function handleDelete(id: string) {
    if (!confirm('Tem a certeza?')) return
    await fetch(`/api/lancamentos/${id}`, { method: 'DELETE' })
    fetchData()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      {/* KPI cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Total lancamentos" value={String(pagination.total || lancamentos.length)} />
        <KpiCard label="Receitas" value={formatCurrency(receitas)} color="green" />
        <KpiCard label="Gastos" value={formatCurrency(gastos)} color="red" />
        <KpiCard label="Recorrentes" value={String(recorrentes)} color="amber" />
      </div>

      {/* Filter bar */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="flex-1 min-w-50 max-w-xs">
          <Input placeholder="Pesquisar..." value={search} onChange={(e) => { setSearch(e.target.value); resetPage() }} />
        </div>
        <div className="w-48">
          <Select
            options={imoveis.map((i) => ({ value: i.id, label: `${i.codigo} - ${i.nome}` }))}
            value={filterImovel}
            onChange={(e) => { setFilterImovel(e.target.value); resetPage() }}
          />
        </div>
        <div className="w-48">
          <Select
            options={rubricas.map((r) => ({ value: r.id, label: r.nome }))}
            value={filterRubrica}
            onChange={(e) => { setFilterRubrica(e.target.value); resetPage() }}
          />
        </div>
        {canCreate && <Button onClick={openCreate}>Novo lancamento</Button>}
        <div className="ml-auto">
          <select
            value={limit}
            onChange={(e) => { setLimit(Number(e.target.value)); setPage(1) }}
            className="text-[11px] border border-gray-200 rounded px-2 py-1.5 bg-white text-[#6B7280] focus:outline-none focus:border-brand-primary"
          >
            {[25, 50, 100, 200].map((l) => (
              <option key={l} value={l}>{l} / página</option>
            ))}
          </select>
        </div>
      </div>

      {/* Date range */}
      <Card className="p-3">
        <div className="flex items-center gap-3 flex-wrap">
          <div className="flex items-center gap-2">
            <div className="w-36">
              <label className="block text-[10px] font-medium text-[#6B7280] mb-0.5">DE</label>
              <input type="date" value={dataDe} onChange={(e) => { setDataDe(e.target.value); resetPage() }}
                className="w-full px-2.5 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary" />
            </div>
            <span className="text-gray-400 mt-4">—</span>
            <div className="w-36">
              <label className="block text-[10px] font-medium text-[#6B7280] mb-0.5">ATE</label>
              <input type="date" value={dataAte} onChange={(e) => { setDataAte(e.target.value); resetPage() }}
                className="w-full px-2.5 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary" />
            </div>
            {(dataDe || dataAte) && (
              <button onClick={() => { setDataDe(''); setDataAte(''); resetPage() }} className="mt-4 text-[11px] text-gray-400 hover:text-gray-600">Limpar</button>
            )}
          </div>
          <div className="flex items-center gap-1.5 mt-4">
            {[
              { label: 'Este mes', de: `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, '0')}-01`, ate: '' },
              { label: 'Mes anterior', de: (() => { const d = new Date(new Date().getFullYear(), new Date().getMonth() - 1, 1); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-01` })(), ate: (() => { const d = new Date(new Date().getFullYear(), new Date().getMonth(), 0); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}` })() },
              { label: 'Este ano', de: `${new Date().getFullYear()}-01-01`, ate: '' },
              { label: 'Ano anterior', de: `${new Date().getFullYear() - 1}-01-01`, ate: `${new Date().getFullYear() - 1}-12-31` },
            ].map((p) => (
              <button key={p.label} onClick={() => { setDataDe(p.de); setDataAte(p.ate); resetPage() }}
                className={`px-2.5 py-1 rounded text-[11px] font-medium transition-colors ${dataDe === p.de && dataAte === p.ate ? 'bg-brand-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
                {p.label}
              </button>
            ))}
          </div>
        </div>
      </Card>

      {/* Table */}
      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              <Th>Data</Th>
              <Th>Tipo doc</Th>
              <Th>Fornecedor</Th>
              <Th>Imovel</Th>
              <Th>Rubrica</Th>
              <Th className="text-right">Valor s/ IVA</Th>
              <Th className="text-right">Total c/ IVA</Th>
              <Th>Recorrente</Th>
              {(canEdit || canDelete) && <Th>Accoes</Th>}
            </tr>
          </thead>
          <tbody>
            {lancamentos.map((l) => (
              <tr key={l.id}>
                <Td>{formatDate(l.dataDoc)}</Td>
                <Td><Badge variant="gray">{l.tipoDoc.replace('_', ' ')}</Badge></Td>
                <Td>
                  <div className="font-medium">{l.fornecedor}</div>
                  {l.nifFornecedor && <div className="text-[11px] text-gray-400 font-mono">{l.nifFornecedor}</div>}
                </Td>
                <Td>{l.imovel.nome}</Td>
                <Td>
                  <Badge variant={l.rubrica.tipo === 'RECEITA' ? 'teal' : 'red'}>{l.rubrica.nome}</Badge>
                </Td>
                <Td className="text-right">{formatCurrency(Number(l.valorSemIva))}</Td>
                <Td className="text-right font-medium">{formatCurrency(Number(l.totalComIva))}</Td>
                <Td>
                  {l.recorrente ? (
                    <Badge variant="amber">{l.periodicidade ?? 'Sim'}</Badge>
                  ) : (
                    <span className="text-[11px] text-gray-400">-</span>
                  )}
                </Td>
                {(canEdit || canDelete) && (
                  <Td>
                    <div className="flex items-center gap-2">
                      {canEdit && (
                        <button onClick={() => openEdit(l)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                      )}
                      {canDelete && (
                        <button onClick={() => handleDelete(l.id)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                      )}
                    </div>
                  </Td>
                )}
              </tr>
            ))}
            {lancamentos.length === 0 && (
              <tr><Td colSpan={9} className="text-center text-gray-400">Sem lancamentos</Td></tr>
            )}
          </tbody>
        </Table>
      </Card>

      <Pagination
        page={pagination.page}
        totalPages={pagination.totalPages}
        total={pagination.total}
        limit={pagination.limit}
        onPageChange={setPage}
        onLimitChange={(l) => { setLimit(l); setPage(1) }}
      />

      {/* Create / Edit Modal */}
      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editId ? 'Editar lancamento' : 'Novo lancamento'}
        className="max-w-2xl"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setModalOpen(false)}>Cancelar</Button>
            <Button onClick={handleSave}>{editId ? 'Guardar' : 'Criar'}</Button>
          </div>
        }
      >
        <div className="space-y-4">
          {/* Identificacao */}
          <div>
            <h4 className="text-[11px] font-medium text-[#6B7280] uppercase mb-2">Identificacao</h4>
            <div className="grid grid-cols-2 gap-3">
              <Select label="Tipo documento" options={TIPO_DOC_OPTIONS} value={form.tipoDoc} onChange={(e) => {
                const tipo = e.target.value
                const defaults = TIPO_DEFAULTS[tipo] || TIPO_DEFAULTS.OUTRO
                setForm({ ...form, tipoDoc: tipo, taxaIva: defaults.taxaIva, retencaoFonte: defaults.retencaoFonte })
              }} />
              <Input label="Numero documento" value={form.numeroDoc} onChange={(e) => setForm({ ...form, numeroDoc: e.target.value })} />
              <Input label="Fornecedor *" value={form.fornecedor} onChange={(e) => setForm({ ...form, fornecedor: e.target.value })} required />
              <Input label="NIF Fornecedor *" value={form.nifFornecedor} onChange={(e) => setForm({ ...form, nifFornecedor: e.target.value })} required />
            </div>
          </div>

          {/* Associacao */}
          <div>
            <h4 className="text-[11px] font-medium text-[#6B7280] uppercase mb-2">Associacao</h4>
            <div className="grid grid-cols-2 gap-3">
              <Select label="Imovel *" options={imoveis.map((i) => ({ value: i.id, label: `${i.codigo} - ${i.nome}` }))} value={form.imovelId} onChange={(e) => setForm({ ...form, imovelId: e.target.value })} />
              <Select label="Rubrica" options={rubricas.map((r) => ({ value: r.id, label: r.nome }))} value={form.rubricaId} onChange={(e) => setForm({ ...form, rubricaId: e.target.value })} />
            </div>
          </div>

          {/* Valores */}
          <div>
            <h4 className="text-[11px] font-medium text-[#6B7280] uppercase mb-2">Valores</h4>
            <div className="grid grid-cols-3 gap-3">
              <Input label="Data" type="date" value={form.dataDoc} onChange={(e) => setForm({ ...form, dataDoc: e.target.value })} />
              <Input label="Valor s/ IVA *" type="number" step="0.01" value={form.valorSemIva} onChange={(e) => {
                const val = e.target.value
                const iva = Number(form.taxaIva)
                const total = iva > 0 ? (Number(val) * (1 + iva / 100)).toFixed(2) : val
                setForm({ ...form, valorSemIva: val, totalComIva: total })
              }} />
              <Select label="Taxa IVA" options={IVA_OPTIONS} value={form.taxaIva} onChange={(e) => {
                const iva = Number(e.target.value)
                const total = iva > 0 ? (Number(form.valorSemIva) * (1 + iva / 100)).toFixed(2) : form.valorSemIva
                setForm({ ...form, taxaIva: e.target.value, totalComIva: total })
              }} />
              <Input label="Total c/ IVA" type="number" step="0.01" value={form.totalComIva} onChange={(e) => setForm({ ...form, totalComIva: e.target.value })} />
              <Select label="Retencao na fonte" options={RETENCAO_OPTIONS} value={form.retencaoFonte} onChange={(e) => setForm({ ...form, retencaoFonte: e.target.value })} />
              {Number(form.retencaoFonte) > 0 && Number(form.valorSemIva) > 0 && (
                <div className="col-span-3 text-[12px] px-1" style={{ color: '#633806' }}>
                  Retencao {form.retencaoFonte}%: <strong>{formatCurrency(Number(form.valorSemIva) * Number(form.retencaoFonte) / 100)}</strong>
                  {' '}— Valor a pagar ao fornecedor: <strong>{formatCurrency(Number(form.totalComIva) - Number(form.valorSemIva) * Number(form.retencaoFonte) / 100)}</strong>
                </div>
              )}
            </div>
          </div>

          {/* Lancamento multi-mes */}
          {!editId && (
            <div>
              <h4 className="text-[11px] font-medium text-[#6B7280] uppercase mb-2">Lancar em multiplos meses</h4>
              <label className="flex items-center gap-2 text-sm mb-3">
                <input type="checkbox" checked={form.recorrente} onChange={(e) => setForm({ ...form, recorrente: e.target.checked })} className="rounded" />
                Criar lancamentos para varios meses
              </label>
              {form.recorrente && (
                <div className="space-y-2">
                  <div className="grid grid-cols-4 gap-2">
                    {MESES_NOMES.map((nome, i) => {
                      const key = String(i)
                      const checked = (form.mesesSelecionados || []).includes(key)
                      return (
                        <label key={i} className="flex items-center gap-1.5 text-[12px]">
                          <input
                            type="checkbox"
                            checked={checked}
                            onChange={(e) => {
                              const sel = form.mesesSelecionados || []
                              setForm({ ...form, mesesSelecionados: e.target.checked ? [...sel, key] : sel.filter((m: string) => m !== key) })
                            }}
                            className="rounded"
                          />
                          {nome}
                        </label>
                      )
                    })}
                  </div>
                  <div className="flex gap-2 mt-2">
                    <button type="button" className="text-[11px] text-brand-primary hover:underline" onClick={() => setForm({ ...form, mesesSelecionados: MESES_NOMES.map((_, i) => String(i)) })}>Seleccionar todos</button>
                    <button type="button" className="text-[11px] text-gray-500 hover:underline" onClick={() => setForm({ ...form, mesesSelecionados: [] })}>Limpar</button>
                  </div>
                  {(form.mesesSelecionados || []).length > 0 && (
                    <div className="mt-3 space-y-2 border-t border-gray-100 pt-3">
                      <div className="text-[11px] font-medium text-[#6B7280] mb-1">Nr. documento e data por mes:</div>
                      <div className="max-h-48 overflow-y-auto space-y-1.5">
                        {(form.mesesSelecionados || []).sort((a: string, b: string) => Number(a) - Number(b)).map((m: string) => (
                          <div key={m} className="grid grid-cols-3 gap-2 items-center">
                            <span className="text-[12px] font-medium">{MESES_NOMES[Number(m)]}</span>
                            <input
                              type="text"
                              placeholder="Nr. documento"
                              value={(form.mesesDocs || {})[m]?.doc || ''}
                              onChange={(e) => {
                                const docs = { ...(form.mesesDocs || {}) }
                                docs[m] = { ...(docs[m] || {}), doc: e.target.value }
                                setForm({ ...form, mesesDocs: docs })
                              }}
                              className="px-2 py-1 border border-gray-200 rounded text-[12px] focus:outline-none focus:border-brand-primary"
                            />
                            <input
                              type="date"
                              value={(form.mesesDocs || {})[m]?.data || ''}
                              onChange={(e) => {
                                const docs = { ...(form.mesesDocs || {}) }
                                docs[m] = { ...(docs[m] || {}), data: e.target.value }
                                setForm({ ...form, mesesDocs: docs })
                              }}
                              className="px-2 py-1 border border-gray-200 rounded text-[12px] focus:outline-none focus:border-brand-primary"
                            />
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                  {(form.mesesSelecionados || []).length > 0 && (
                    <div className="mt-2 text-[11px] px-1" style={{ color: '#085041', background: '#E1F5EE', borderRadius: 6, padding: '6px 10px' }}>
                      Serao criados <strong>{(form.mesesSelecionados || []).length}</strong> lancamentos de {formatCurrency(Number(form.totalComIva))} cada
                      {Number(form.retencaoFonte) > 0 && <> (retencao {form.retencaoFonte}% em cada)</>}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          {/* Notas */}
          <div>
            <h4 className="text-[11px] font-medium text-[#6B7280] uppercase mb-2">Notas</h4>
            <textarea
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary resize-none"
              rows={3}
              value={form.notas}
              onChange={(e) => setForm({ ...form, notas: e.target.value })}
            />
          </div>
        </div>
      </Modal>
    </div>
  )
}
