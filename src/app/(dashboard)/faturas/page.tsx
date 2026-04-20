'use client'

import { useEffect, useState, useCallback } from 'react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Badge } from '@/components/ui/Badge'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Pagination } from '@/components/ui/Pagination'
import { formatCurrency, formatDate } from '@/lib/utils'

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
  classificacoes: {
    imovel: { id: string; nome: string; codigo: string }
    rubrica: { id: string; nome: string; tipo: string }
    origem: string
    valorAtribuido: string | null
  }[]
  importacao: { periodo: string; tipoFicheiro: string }
}

interface Option { id: string; nome: string; codigo?: string }

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
            </tr>
          </thead>
          <tbody>
            {filtered.map((f) => (
              <tr key={f.id}>
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
                <Td className="text-[12px]">{f.classificacoes?.[0]?.imovel ? `${f.classificacoes[0].imovel.codigo}` : '—'}</Td>
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
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr><Td colSpan={11} className="text-center text-gray-400">Sem faturas encontradas</Td></tr>
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
    </div>
  )
}
