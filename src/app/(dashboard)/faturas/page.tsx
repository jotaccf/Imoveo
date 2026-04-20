'use client'

import { useEffect, useState, useCallback } from 'react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Badge } from '@/components/ui/Badge'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Modal } from '@/components/ui/Modal'
import { Pagination } from '@/components/ui/Pagination'
import { formatCurrency, formatDate } from '@/lib/utils'
import { Plus, Trash2 } from 'lucide-react'

interface Classificacao {
  id: string
  imovel: { id: string; nome: string; codigo: string }
  rubrica: { id: string; nome: string; tipo: string }
  origem: string
  confirmado: boolean
  valorAtribuido: string | null
  fracaoId: string | null
}

interface Fatura {
  id: string
  nifEmitente: string
  nifDestinatario: string | null
  nomeEmitente: string | null
  serieDoc: string
  numeroDoc: string
  dataFatura: string
  totalSemIva: string
  totalIva: string
  totalComIva: string
  tipoDocumento: string | null
  classificacoes: Classificacao[]
  importacao: { periodo: string; tipoFicheiro: string }
}

interface Option { id: string; nome: string; codigo?: string; tipo?: string }
interface FracaoOption { id: string; nome: string; imovelId: string }

interface EditLinha {
  imovelId: string
  rubricaId: string
  fracaoId: string
  valor: string
}

export default function FaturasPage() {
  const [faturas, setFaturas] = useState<Fatura[]>([])
  const [imoveis, setImoveis] = useState<Option[]>([])
  const [rubricas, setRubricas] = useState<Option[]>([])
  const [search, setSearch] = useState('')
  const [filterImovel, setFilterImovel] = useState('')
  const [filterRubrica, setFilterRubrica] = useState('')
  const [dataDe, setDataDe] = useState('')
  const [dataAte, setDataAte] = useState('')
  const [filterTipo, setFilterTipo] = useState<'TODAS' | 'RECEITA' | 'GASTO'>('TODAS')
  const [page, setPage] = useState(1)
  const [limit, setLimit] = useState(50)
  const [pagination, setPagination] = useState({ page: 1, limit: 50, total: 0, totalPages: 0 })
  const [serverTotais, setServerTotais] = useState({ totalSemIva: 0, totalIva: 0, totalComIva: 0 })
  const [loading, setLoading] = useState(true)
  const [fracoes, setFracoes] = useState<FracaoOption[]>([])
  const [selected, setSelected] = useState<Set<string>>(new Set())
  const [batchAnulando, setBatchAnulando] = useState(false)
  const [editFatura, setEditFatura] = useState<Fatura | null>(null)
  const [editLinhas, setEditLinhas] = useState<EditLinha[]>([])
  const [editSaving, setEditSaving] = useState(false)
  const [editCriarRegra, setEditCriarRegra] = useState(false)

  const fetchData = useCallback(() => {
    const params = new URLSearchParams()
    if (search) params.set('search', search)
    if (filterImovel) params.set('imovelId', filterImovel)
    if (filterRubrica) params.set('rubricaId', filterRubrica)
    if (dataDe) params.set('dataDe', dataDe)
    if (dataAte) params.set('dataAte', dataAte)
    params.set('page', String(page))
    params.set('limit', String(limit))

    fetch(`/api/faturas?${params}`)
      .then((r) => r.json())
      .then((j) => {
        if (j.data) setFaturas(j.data)
        setPagination(j.pagination || { page: 1, limit: 100, total: 0, totalPages: 0 })
        setServerTotais(j.totais || { totalSemIva: 0, totalIva: 0, totalComIva: 0 })
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
        setFracoes(j.data.fracoes || [])
      }
    }).catch(() => {})
  }, [])

  // Reset page when filters change
  function resetPage() { setPage(1) }

  function handleExport() {
    const params = new URLSearchParams()
    if (dataDe) params.set('dataDe', dataDe)
    if (dataAte) params.set('dataAte', dataAte)
    window.open(`/api/faturas/exportar?${params}`, '_blank')
  }

  function clearDates() {
    setDataDe('')
    setDataAte('')
  }

  function toggleSelect(id: string) {
    setSelected((prev) => {
      const next = new Set(prev)
      next.has(id) ? next.delete(id) : next.add(id)
      return next
    })
  }

  function toggleSelectAll() {
    if (selected.size === filtered.length) {
      setSelected(new Set())
    } else {
      setSelected(new Set(filtered.map((f) => f.id)))
    }
  }

  async function handleAnular(id: string) {
    if (!confirm('Remover classificacao desta fatura? Voltara para pendentes.')) return
    await fetch(`/api/faturas/${id}/classificar`, { method: 'DELETE' })
    setFaturas((prev) => prev.filter((f) => f.id !== id))
    setSelected((prev) => { const next = new Set(prev); next.delete(id); return next })
  }

  async function handleBatchAnular() {
    if (selected.size === 0) return
    if (!confirm(`Remover classificacao de ${selected.size} fatura${selected.size > 1 ? 's' : ''}? Voltarao para pendentes.`)) return
    setBatchAnulando(true)
    const ids = Array.from(selected)
    await Promise.all(ids.map((id) => fetch(`/api/faturas/${id}/classificar`, { method: 'DELETE' })))
    setFaturas((prev) => prev.filter((f) => !ids.includes(f.id)))
    setSelected(new Set())
    setBatchAnulando(false)
  }

  function openEdit(f: Fatura) {
    setEditLinhas(
      f.classificacoes.length > 0
        ? f.classificacoes.map((c) => ({
            imovelId: c.imovel?.id ?? '',
            rubricaId: c.rubrica?.id ?? '',
            fracaoId: c.fracaoId ?? '',
            valor: c.valorAtribuido ? String(Number(c.valorAtribuido)) : '',
          }))
        : [{ imovelId: '', rubricaId: '', fracaoId: '', valor: '' }]
    )
    setEditCriarRegra(false)
    setEditFatura(f)
  }

  async function handleSaveEdit() {
    if (!editFatura) return
    setEditSaving(true)
    const linhas = editLinhas
      .filter((l) => l.imovelId && l.rubricaId)
      .map((l) => ({
        imovelId: l.imovelId,
        rubricaId: l.rubricaId,
        fracaoId: l.fracaoId || undefined,
        valor: l.valor ? parseFloat(l.valor) : undefined,
      }))
    if (linhas.length === 0) { setEditSaving(false); return }

    // Guardar classificacao
    await fetch(`/api/faturas/${editFatura.id}/classificar`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ linhas }),
    })

    // Criar/actualizar regra com percentagens calculadas dos valores
    if (editCriarRegra && linhas.length > 0) {
      const total = Number(editFatura.totalComIva)
      const nif = editFatura.nifEmitente
      const nomeEntidade = editFatura.nomeEmitente || nif
      const rubricaId = linhas[0].rubricaId

      if (linhas.length === 1) {
        // Regra simples: 1 imovel
        await fetch('/api/distribuicao', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            nifEntidade: nif,
            nomeEntidade,
            rubricaId,
            tipo: 'IGUAL',
            linhas: [{ imovelId: linhas[0].imovelId }],
          }),
        })
      } else {
        // Distribuicao: calcular percentagens dos valores
        const linhasComPct = linhas.map((l) => ({
          imovelId: l.imovelId,
          percentagem: total > 0 ? Math.round(((l.valor || 0) / total) * 10000) / 100 : 100 / linhas.length,
        }))
        await fetch('/api/distribuicao', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            nifEntidade: nif,
            nomeEntidade,
            rubricaId,
            tipo: 'PERCENTAGEM',
            linhas: linhasComPct,
          }),
        })
      }
    }

    setEditFatura(null)
    setEditSaving(false)
    fetchData()
  }

  // Quick date presets
  const now = new Date()
  const presets = [
    { label: 'Este mes', de: `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`, ate: '' },
    { label: 'Mes anterior', de: (() => { const d = new Date(now.getFullYear(), now.getMonth() - 1, 1); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-01` })(), ate: (() => { const d = new Date(now.getFullYear(), now.getMonth(), 0); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}` })() },
    { label: 'Este ano', de: `${now.getFullYear()}-01-01`, ate: '' },
    { label: 'Ano anterior', de: `${now.getFullYear() - 1}-01-01`, ate: `${now.getFullYear() - 1}-12-31` },
  ]

  const filtered = faturas.filter((f) => {
    if (filterTipo === 'RECEITA') return f.classificacoes?.[0]?.rubrica?.tipo === 'RECEITA'
    if (filterTipo === 'GASTO') return f.classificacoes?.[0]?.rubrica?.tipo === 'GASTO'
    return true
  })

  const countReceitas = faturas.filter((f) => f.classificacoes?.[0]?.rubrica?.tipo === 'RECEITA').length
  const countGastos = faturas.filter((f) => f.classificacoes?.[0]?.rubrica?.tipo === 'GASTO').length

  const totalSemIva = filterTipo === 'TODAS' ? serverTotais.totalSemIva : filtered.reduce((s, f) => s + Number(f.totalSemIva), 0)
  const totalIva = filterTipo === 'TODAS' ? serverTotais.totalIva : filtered.reduce((s, f) => s + Number(f.totalIva), 0)
  const totalComIva = filterTipo === 'TODAS' ? serverTotais.totalComIva : filtered.reduce((s, f) => s + Number(f.totalComIva), 0)

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      {/* Filters row 1 */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="flex-1 min-w-[200px] max-w-xs">
          <Input placeholder="Pesquisar NIF, nome, doc..." value={search} onChange={(e) => { setSearch(e.target.value); resetPage() }} />
        </div>
        <div className="w-48">
          <Select
            options={imoveis.map((i) => ({ value: i.id, label: `${i.codigo || ''} - ${i.nome}` }))}
            value={filterImovel}
            onChange={(e) => { setFilterImovel(e.target.value); resetPage() }}
          />
        </div>
        <div className="w-44">
          <Select
            options={rubricas.map((r) => ({ value: r.id, label: r.nome }))}
            value={filterRubrica}
            onChange={(e) => { setFilterRubrica(e.target.value); resetPage() }}
          />
        </div>
        {selected.size > 0 && (
          <Button variant="secondary" onClick={handleBatchAnular} disabled={batchAnulando}>
            {batchAnulando ? 'A anular...' : `Anular selecionadas (${selected.size})`}
          </Button>
        )}
        <Button variant="secondary" onClick={handleExport}>Exportar CSV</Button>
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

      {/* Tipo filter */}
      <div className="flex gap-2">
        {([
          { id: 'TODAS' as const, label: 'Todas', count: pagination.total },
          { id: 'RECEITA' as const, label: 'Receitas', count: countReceitas },
          { id: 'GASTO' as const, label: 'Despesas', count: countGastos },
        ]).map((t) => (
          <button
            key={t.id}
            onClick={() => setFilterTipo(t.id)}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
              filterTipo === t.id ? 'bg-brand-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {t.label} ({t.count})
          </button>
        ))}
      </div>

      {/* Date range */}
      <Card className="p-3">
        <div className="flex items-center gap-3 flex-wrap">
          <div className="flex items-center gap-2">
            <div className="w-36">
              <label className="block text-[10px] font-medium text-[#6B7280] mb-0.5">DE</label>
              <input
                type="date"
                value={dataDe}
                onChange={(e) => { setDataDe(e.target.value); resetPage() }}
                className="w-full px-2.5 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
              />
            </div>
            <span className="text-gray-400 mt-4">—</span>
            <div className="w-36">
              <label className="block text-[10px] font-medium text-[#6B7280] mb-0.5">ATE</label>
              <input
                type="date"
                value={dataAte}
                onChange={(e) => { setDataAte(e.target.value); resetPage() }}
                className="w-full px-2.5 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
              />
            </div>
            {(dataDe || dataAte) && (
              <button onClick={clearDates} className="mt-4 text-[11px] text-gray-400 hover:text-gray-600">Limpar</button>
            )}
          </div>
          <div className="flex items-center gap-1.5 mt-4">
            {presets.map((p) => (
              <button
                key={p.label}
                onClick={() => { setDataDe(p.de); setDataAte(p.ate); resetPage() }}
                className={`px-2.5 py-1 rounded text-[11px] font-medium transition-colors ${
                  dataDe === p.de && dataAte === p.ate
                    ? 'bg-brand-primary text-white'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                {p.label}
              </button>
            ))}
          </div>
        </div>
      </Card>

      {/* Summary */}
      {filtered.length > 0 && (
        <div className="flex items-center gap-4 text-[12px] px-1">
          <span className="text-gray-500">{filterTipo === 'TODAS' ? pagination.total : filtered.length} faturas</span>
          <span className="text-gray-400">|</span>
          <span className="text-gray-500">Base: <strong>{formatCurrency(totalSemIva)}</strong></span>
          <span className="text-gray-500">IVA: <strong>{formatCurrency(totalIva)}</strong></span>
          <span className="font-medium" style={{ color: '#0D1B1A' }}>Total: <strong>{formatCurrency(totalComIva)}</strong></span>
        </div>
      )}

      {/* Table */}
      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              <Th>
                <input
                  type="checkbox"
                  checked={filtered.length > 0 && selected.size === filtered.length}
                  onChange={toggleSelectAll}
                  className="rounded"
                />
              </Th>
              <Th>NIF</Th>
              <Th>Nome</Th>
              <Th>Tipo</Th>
              <Th>Doc</Th>
              <Th>Data</Th>
              <Th className="text-right">S/ IVA</Th>
              <Th className="text-right">IVA</Th>
              <Th className="text-right">Total</Th>
              <Th>Imovel</Th>
              <Th>Rubrica</Th>
              <Th>Origem</Th>
              <Th>Accoes</Th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((f) => (
              <tr key={f.id} className={selected.has(f.id) ? 'bg-blue-50' : ''}>
                <Td>
                  <input
                    type="checkbox"
                    checked={selected.has(f.id)}
                    onChange={() => toggleSelect(f.id)}
                    className="rounded"
                  />
                </Td>
                <Td>
                  {(() => {
                    const isReceita = f.classificacoes?.[0]?.rubrica?.tipo === 'RECEITA'
                    const nif = isReceita ? (f.nifDestinatario || f.nifEmitente) : f.nifEmitente
                    if (!nif || nif === 'EMITIDA') return <span className="text-[11px] text-gray-400 italic">Sem NIF</span>
                    return <span className="font-mono text-[11px]">{nif}</span>
                  })()}
                </Td>
                <Td className="text-[12px]">{f.nomeEmitente ?? '—'}</Td>
                <Td><Badge variant="gray">{f.tipoDocumento || '—'}</Badge></Td>
                <Td className="text-[11px] font-mono">{f.serieDoc}/{f.numeroDoc}</Td>
                <Td>{formatDate(f.dataFatura)}</Td>
                <Td className="text-right text-[12px]">{formatCurrency(Number(f.totalSemIva))}</Td>
                <Td className="text-right text-[12px] text-gray-400">{formatCurrency(Number(f.totalIva))}</Td>
                <Td className="text-right font-medium">{formatCurrency(Number(f.totalComIva))}</Td>
                <Td className="text-[12px]">
                  {f.classificacoes.length > 1 ? (
                    <div className="flex flex-wrap gap-1">
                      {f.classificacoes.map((c, i) => (
                        <span key={i} className="text-[11px] px-1.5 py-0.5 bg-gray-100 rounded">
                          {c.imovel?.codigo}
                          {c.valorAtribuido ? ` ${formatCurrency(Number(c.valorAtribuido))}` : ''}
                        </span>
                      ))}
                    </div>
                  ) : f.classificacoes?.[0]?.imovel ? (
                    f.classificacoes[0].imovel.codigo
                  ) : '—'}
                </Td>
                <Td>
                  {f.classificacoes?.[0]?.rubrica ? (
                    <Badge variant={f.classificacoes[0].rubrica.tipo === 'RECEITA' ? 'teal' : 'blue'}>
                      {f.classificacoes[0].rubrica.nome}
                    </Badge>
                  ) : '—'}
                </Td>
                <Td>
                  <Badge variant={f.classificacoes?.[0]?.origem === 'AUTOMATICA' ? 'green' : 'purple'}>
                    {f.classificacoes?.[0]?.origem === 'AUTOMATICA' ? 'Auto' : 'Manual'}
                  </Badge>
                </Td>
                <Td>
                  <div className="flex items-center gap-2">
                    <button onClick={() => openEdit(f)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                    <button onClick={() => handleAnular(f.id)} className="text-[12px] text-[#A32D2D] hover:underline">Anular</button>
                  </div>
                </Td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr><Td colSpan={13} className="text-center text-gray-400">Sem faturas encontradas</Td></tr>
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

      {/* Modal: Editar classificacao */}
      <Modal
        open={!!editFatura}
        onClose={() => setEditFatura(null)}
        title="Editar classificacao"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setEditFatura(null)}>Cancelar</Button>
            <Button onClick={handleSaveEdit} disabled={editSaving}>{editSaving ? 'A guardar...' : 'Guardar'}</Button>
          </div>
        }
      >
        {editFatura && (() => {
          const total = Number(editFatura.totalComIva)
          const soma = editLinhas.reduce((s, l) => s + (parseFloat(l.valor) || 0), 0)
          const restante = Math.round((total - soma) * 100) / 100

          return (
            <div className="space-y-3">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                <div className="text-sm text-gray-600">
                  <span className="font-medium">{editFatura.nomeEmitente}</span>
                  <span className="ml-2 font-mono text-gray-400 text-[11px]">{editFatura.serieDoc}/{editFatura.numeroDoc}</span>
                </div>
                <span className="font-semibold text-sm">{formatCurrency(total)}</span>
              </div>

              {editLinhas.length > 1 && (
                <div className={`flex items-center justify-between px-3 py-2 rounded-lg text-xs font-medium ${
                  Math.abs(restante) < 0.01
                    ? 'bg-green-50 text-green-700'
                    : 'bg-amber-50 text-amber-700'
                }`}>
                  <span>Distribuido: {formatCurrency(soma)}</span>
                  {Math.abs(restante) < 0.01
                    ? <span>Soma correcta</span>
                    : <span>Falta: {formatCurrency(restante)}</span>
                  }
                </div>
              )}

              {editLinhas.map((linha, i) => (
                <div key={i} className="space-y-2 p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-medium text-gray-500">LINHA {i + 1}</span>
                    {editLinhas.length > 1 && (
                      <button
                        onClick={() => setEditLinhas((prev) => prev.filter((_, j) => j !== i))}
                        className="text-[#A32D2D] hover:bg-red-50 p-0.5 rounded"
                      >
                        <Trash2 size={13} />
                      </button>
                    )}
                  </div>
                  <Select
                    label="Imovel"
                    options={imoveis.map((im) => ({ value: im.id, label: `${im.codigo || ''} - ${im.nome}` }))}
                    value={linha.imovelId}
                    onChange={(e) => setEditLinhas((prev) => prev.map((l, j) => j === i ? { ...l, imovelId: e.target.value, fracaoId: '' } : l))}
                  />
                  {(() => {
                    const rubrica = rubricas.find((r) => r.id === linha.rubricaId)
                    if (rubrica?.tipo !== 'RECEITA') return null
                    const imovelFracoes = linha.imovelId ? fracoes.filter((fr) => fr.imovelId === linha.imovelId) : []
                    if (imovelFracoes.length === 0) return null
                    return (
                      <Select
                        label="Fracao (opcional)"
                        options={[{ value: '', label: '— Nenhuma —' }, ...imovelFracoes.map((fr) => ({ value: fr.id, label: fr.nome }))]}
                        value={linha.fracaoId}
                        onChange={(e) => setEditLinhas((prev) => prev.map((l, j) => j === i ? { ...l, fracaoId: e.target.value } : l))}
                      />
                    )
                  })()}
                  <Select
                    label="Rubrica"
                    options={rubricas.map((r) => ({ value: r.id, label: r.nome }))}
                    value={linha.rubricaId}
                    onChange={(e) => setEditLinhas((prev) => prev.map((l, j) => j === i ? { ...l, rubricaId: e.target.value } : l))}
                  />
                  {editLinhas.length > 1 && (
                    <div>
                      <label className="block text-[10px] font-medium text-[#6B7280] mb-1">VALOR ATRIBUIDO</label>
                      <input
                        type="text"
                        inputMode="decimal"
                        value={linha.valor}
                        onChange={(e) => setEditLinhas((prev) => prev.map((l, j) => j === i ? { ...l, valor: e.target.value } : l))}
                        className="w-full px-2.5 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
                        placeholder="0.00"
                      />
                    </div>
                  )}
                </div>
              ))}
              <div className="flex items-center gap-3">
                <button
                  onClick={() => setEditLinhas((prev) => [...prev, { imovelId: '', rubricaId: prev[0]?.rubricaId ?? '', fracaoId: '', valor: '' }])}
                  className="flex items-center gap-1 text-[12px] text-brand-primary hover:underline"
                >
                  <Plus size={13} /> Adicionar linha
                </button>
                {editLinhas.length > 1 && (
                  <button
                    onClick={() => {
                      const n = editLinhas.length
                      setEditLinhas((prev) => prev.map((l, i) => {
                        if (i === n - 1) {
                          const somaAnt = prev.slice(0, i).reduce((s) => s + Math.round(total / n * 100) / 100, 0)
                          return { ...l, valor: String(Math.round((total - somaAnt) * 100) / 100) }
                        }
                        return { ...l, valor: String(Math.round(total / n * 100) / 100) }
                      }))
                    }}
                    className="text-[12px] text-brand-primary hover:underline"
                  >
                    Dividir igualmente
                  </button>
                )}
              </div>

              {/* Guardar como regra */}
              <label className="flex items-center gap-2 pt-2 border-t border-gray-100 cursor-pointer">
                <input
                  type="checkbox"
                  checked={editCriarRegra}
                  onChange={(e) => setEditCriarRegra(e.target.checked)}
                  className="rounded border-gray-300"
                />
                <span className="text-[12px] text-gray-600">
                  Usar esta distribuicao para futuras faturas deste NIF
                </span>
              </label>
            </div>
          )
        })()}
      </Modal>
    </div>
  )
}
