'use client'

import { useEffect, useState, useCallback } from 'react'
import { Button } from '@/components/ui/Button'
import { Select } from '@/components/ui/Select'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Badge } from '@/components/ui/Badge'
import { Modal } from '@/components/ui/Modal'
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
  totalComIva: string
  importacao?: { tipoFicheiro: string }
}

interface ImovelOption { id: string; nome: string; codigo: string; tipo: string }
interface RubricaOption { id: string; nome: string; codigo: string; tipo: string }
interface FracaoOption { id: string; nome: string; imovelId: string; renda: string; estado: string }

interface RowState {
  imovelId: string
  rubricaId: string
  fracaoId: string
}

export default function PendentesPage() {
  const [faturas, setFaturas] = useState<Fatura[]>([])
  const [imoveis, setImoveis] = useState<ImovelOption[]>([])
  const [fracoes, setFracoes] = useState<FracaoOption[]>([])
  const [rubricas, setRubricas] = useState<RubricaOption[]>([])
  const [rowStates, setRowStates] = useState<Record<string, RowState>>({})
  const [saving, setSaving] = useState<string | null>(null)
  const [confirmId, setConfirmId] = useState<string | null>(null)
  const [filter, setFilter] = useState<'TODAS' | 'RECEITAS' | 'DESPESAS'>('TODAS')
  const [search, setSearch] = useState('')
  const [dataDe, setDataDe] = useState('')
  const [dataAte, setDataAte] = useState('')
  const [page, setPage] = useState(1)
  const [limit, setLimit] = useState(50)
  const [pagination, setPagination] = useState({ page: 1, limit: 50, total: 0, totalPages: 0 })
  const [contagem, setContagem] = useState({ total: 0, receitas: 0, despesas: 0 })
  const [loading, setLoading] = useState(true)

  const fetchPendentes = useCallback(() => {
    const params = new URLSearchParams()
    params.set('page', String(page))
    params.set('limit', String(limit))
    if (filter === 'RECEITAS') params.set('tipo', 'EMITIDAS')
    if (filter === 'DESPESAS') params.set('tipo', 'RECEBIDAS')
    if (search) params.set('search', search)
    if (dataDe) params.set('dataDe', dataDe)
    if (dataAte) params.set('dataAte', dataAte)

    fetch(`/api/faturas/pendentes?${params}`)
      .then((r) => r.json())
      .then((j) => {
        if (j.data) setFaturas(j.data)
        setPagination(j.pagination || { page: 1, limit: 50, total: 0, totalPages: 0 })
        if (j.contagem) setContagem(j.contagem)
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [page, limit, filter, search, dataDe, dataAte])

  useEffect(() => { fetchPendentes() }, [fetchPendentes])

  useEffect(() => {
    fetch('/api/opcoes').then((r) => r.json()).then((j) => {
      if (j.data) {
        setImoveis(j.data.imoveis)
        setRubricas(j.data.rubricas)
        setFracoes(j.data.fracoes || [])
      }
    }).catch(() => {})
  }, [])

  function isEmitida(f: Fatura) {
    return f.importacao?.tipoFicheiro === 'EMITIDAS'
  }

  function updateRow(faturaId: string, field: keyof RowState, value: string) {
    setRowStates((prev) => ({
      ...prev,
      [faturaId]: { ...(prev[faturaId] ?? { imovelId: '', rubricaId: '', fracaoId: '' }), [field]: value },
    }))
  }

  function handleSave(faturaId: string) {
    const f = faturas.find((x) => x.id === faturaId)
    const state = rowStates[faturaId]
    if (!state?.imovelId) {
      alert('Seleccione o imovel.')
      return
    }
    // Para recebidas, rubrica é obrigatória
    if (f && !isEmitida(f) && !state?.rubricaId) {
      alert('Seleccione a rubrica.')
      return
    }
    setSaving(faturaId)
    setConfirmId(faturaId)
  }

  async function doClassificar(criarRegra: boolean) {
    if (!confirmId) return
    const f = faturas.find((x) => x.id === confirmId)
    const state = rowStates[confirmId]

    // Usar rubrica seleccionada, com fallback para REC se emitida e sem selecção
    let rubricaId = state.rubricaId
    if (f && isEmitida(f) && !rubricaId) {
      const rec = rubricas.find((r) => r.codigo === 'REC')
      rubricaId = rec?.id || rubricaId
    }

    const res = await fetch(`/api/faturas/${confirmId}/classificar`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        imovelId: state.imovelId,
        rubricaId,
        fracaoId: state.fracaoId || undefined,
        criarRegra,
        nifRegra: f && isEmitida(f) ? f.nifDestinatario : undefined,
      }),
    })

    const json = await res.json()

    setConfirmId(null)
    setSaving(null)

    // Se criou regra e auto-classificou outras faturas, mostrar mensagem e refrescar tudo
    if (json.autoClassificadas > 0) {
      alert(json.message)
      fetchPendentes() // refrescar lista completa
    } else {
      setFaturas((prev) => prev.filter((x) => x.id !== confirmId))
    }
  }

  // Tipo filter is now server-side, only search is client-side
  // Search and tipo filter are now server-side
  const filtered = faturas

  // Contar faturas prontas para classificacao batch (tem imovel + rubrica preenchidos)
  const prontas = filtered.filter((f) => {
    const state = rowStates[f.id]
    if (!state?.imovelId) return false
    if (isEmitida(f)) return true // receitas não precisam de rubrica (é auto)
    return !!state.rubricaId
  })

  const [batchSaving, setBatchSaving] = useState(false)

  async function handleBatchClassificar() {
    if (prontas.length === 0) return
    if (!confirm(`Classificar ${prontas.length} fatura${prontas.length > 1 ? 's' : ''} de uma vez? (sem criar regras)`)) return

    setBatchSaving(true)
    let ok = 0
    for (const f of prontas) {
      const state = rowStates[f.id]
      let rubricaId = state.rubricaId
      if (isEmitida(f) && !rubricaId) {
        const rec = rubricas.find((r) => r.codigo === 'REC')
        rubricaId = rec?.id || rubricaId
      }

      const res = await fetch(`/api/faturas/${f.id}/classificar`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          imovelId: state.imovelId,
          rubricaId,
          fracaoId: state.fracaoId || undefined,
          criarRegra: false,
        }),
      })
      if (res.ok) ok++
    }

    setBatchSaving(false)
    alert(`${ok} fatura${ok > 1 ? 's' : ''} classificada${ok > 1 ? 's' : ''} com sucesso`)
    fetchPendentes()
  }

  const countReceitas = contagem.receitas
  const countDespesas = contagem.despesas

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      {/* Banner */}
      <div className="rounded-lg px-4 py-3 text-sm font-medium" style={{ backgroundColor: '#FAEEDA', color: '#633806' }}>
        {contagem.total} {contagem.total === 1 ? 'fatura pendente' : 'faturas pendentes'} de classificacao
        <span className="ml-2 font-normal">
          ({countReceitas} receitas, {countDespesas} despesas)
        </span>
      </div>

      {/* Filters + Batch */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="flex-1 max-w-xs">
          <input
            type="text"
            placeholder="Pesquisar valor, NIF, nome..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1) }}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
          />
        </div>
        {prontas.length > 0 && (
          <Button onClick={handleBatchClassificar} disabled={batchSaving}>
            {batchSaving ? 'A classificar...' : `Classificar ${prontas.length} seleccionada${prontas.length > 1 ? 's' : ''}`}
          </Button>
        )}
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

      {/* Date range filter */}
      <Card className="p-3">
        <div className="flex items-center gap-3 flex-wrap">
          <div className="flex items-center gap-2">
            <div className="w-36">
              <label className="block text-[10px] font-medium text-[#6B7280] mb-0.5">DE</label>
              <input
                type="date"
                value={dataDe}
                onChange={(e) => { setDataDe(e.target.value); setPage(1) }}
                className="w-full px-2.5 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
              />
            </div>
            <span className="text-gray-400 mt-4">—</span>
            <div className="w-36">
              <label className="block text-[10px] font-medium text-[#6B7280] mb-0.5">ATÉ</label>
              <input
                type="date"
                value={dataAte}
                onChange={(e) => { setDataAte(e.target.value); setPage(1) }}
                className="w-full px-2.5 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
              />
            </div>
            {(dataDe || dataAte) && (
              <button
                onClick={() => { setDataDe(''); setDataAte(''); setPage(1) }}
                className="mt-4 text-[11px] text-gray-400 hover:text-gray-600"
              >
                Limpar
              </button>
            )}
          </div>
          <div className="flex items-center gap-1.5 mt-4">
            {(() => {
              const now = new Date()
              const y = now.getFullYear()
              const m = now.getMonth()
              const presets = [
                { label: 'Este mês', de: `${y}-${String(m + 1).padStart(2, '0')}-01`, ate: '' },
                { label: 'Mês anterior', de: `${m === 0 ? y - 1 : y}-${String(m === 0 ? 12 : m).padStart(2, '0')}-01`, ate: `${m === 0 ? y - 1 : y}-${String(m === 0 ? 12 : m).padStart(2, '0')}-${new Date(m === 0 ? y - 1 : y, m === 0 ? 12 : m, 0).getDate()}` },
                { label: 'Este ano', de: `${y}-01-01`, ate: '' },
                { label: 'Ano anterior', de: `${y - 1}-01-01`, ate: `${y - 1}-12-31` },
              ]
              return presets.map((p) => (
                <button
                  key={p.label}
                  onClick={() => { setDataDe(p.de); setDataAte(p.ate); setPage(1) }}
                  className="px-2 py-1 text-[11px] rounded border border-gray-200 text-gray-500 hover:bg-gray-50"
                >
                  {p.label}
                </button>
              ))
            })()}
          </div>
        </div>
      </Card>

      <div className="flex gap-2">
        {(['TODAS', 'RECEITAS', 'DESPESAS'] as const).map((f) => (
          <button
            key={f}
            onClick={() => { setFilter(f); setPage(1) }}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
              filter === f ? 'bg-brand-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {f === 'TODAS' ? `Todas (${contagem.total})` : f === 'RECEITAS' ? `Receitas (${countReceitas})` : `Despesas (${countDespesas})`}
          </button>
        ))}
      </div>

      {/* Table */}
      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              <Th>Tipo</Th>
              <Th>NIF</Th>
              <Th>Nome</Th>
              <Th>Doc</Th>
              <Th>Data</Th>
              <Th className="text-right">Total c/ IVA</Th>
              <Th>Imovel</Th>
              <Th>Quarto</Th>
              <Th>Rubrica</Th>
              <Th />
            </tr>
          </thead>
          <tbody>
            {filtered.map((f) => {
              const emitida = isEmitida(f)
              return (
                <tr key={f.id}>
                  <Td>
                    <Badge variant={emitida ? 'green' : 'red'}>
                      {emitida ? 'Receita' : 'Despesa'}
                    </Badge>
                  </Td>
                  <Td>
                    {(() => {
                      const nif = emitida ? f.nifDestinatario : f.nifEmitente
                      if (!nif || nif === 'EMITIDA') return <span className="text-[11px] text-gray-400 italic">Sem NIF</span>
                      return <span className="font-mono text-[11px]">{nif}</span>
                    })()}
                  </Td>
                  <Td className="text-[12px]">{f.nomeEmitente ?? '—'}</Td>
                  <Td className="text-[11px]">{f.serieDoc}/{f.numeroDoc}</Td>
                  <Td>{formatDate(f.dataFatura)}</Td>
                  <Td className={`text-right font-medium ${emitida ? 'text-[#0F6E56]' : ''}`}>
                    {formatCurrency(Number(f.totalComIva))}
                  </Td>
                  <Td>
                    <Select
                      options={imoveis.map((i) => ({ value: i.id, label: `${i.codigo} - ${i.nome}` }))}
                      value={rowStates[f.id]?.imovelId ?? ''}
                      onChange={(e) => updateRow(f.id, 'imovelId', e.target.value)}
                      className="min-w-[160px]"
                    />
                  </Td>
                  <Td>
                    {(() => {
                      const selectedImovelId = rowStates[f.id]?.imovelId
                      const imovelFracoes = selectedImovelId
                        ? fracoes.filter((fr) => fr.imovelId === selectedImovelId)
                        : []
                      if (imovelFracoes.length === 0) return <span className="text-[11px] text-gray-400">—</span>
                      return (
                        <Select
                          options={imovelFracoes.map((fr) => ({ value: fr.id, label: fr.nome }))}
                          value={rowStates[f.id]?.fracaoId ?? ''}
                          onChange={(e) => updateRow(f.id, 'fracaoId', e.target.value)}
                          className="min-w-[120px]"
                        />
                      )
                    })()}
                  </Td>
                  <Td>
                    {emitida ? (
                      <Select
                        options={rubricas.filter((r) => r.tipo === 'RECEITA').map((r) => ({ value: r.id, label: r.nome }))}
                        value={rowStates[f.id]?.rubricaId ?? (rubricas.find((r) => r.codigo === 'REC')?.id || '')}
                        onChange={(e) => updateRow(f.id, 'rubricaId', e.target.value)}
                        className="min-w-[140px]"
                      />
                    ) : (
                      <Select
                        options={rubricas.filter((r) => r.tipo === 'GASTO').map((r) => ({ value: r.id, label: r.nome }))}
                        value={rowStates[f.id]?.rubricaId ?? ''}
                        onChange={(e) => updateRow(f.id, 'rubricaId', e.target.value)}
                        className="min-w-[140px]"
                      />
                    )}
                  </Td>
                  <Td>
                    <Button
                      onClick={() => handleSave(f.id)}
                      disabled={saving === f.id}
                      className="text-[12px] px-3 py-1.5"
                    >
                      Guardar
                    </Button>
                  </Td>
                </tr>
              )
            })}
            {filtered.length === 0 && (
              <tr><Td colSpan={9} className="text-center text-gray-400">
                {faturas.length === 0 ? 'Todas as faturas estao classificadas' : 'Nenhuma fatura neste filtro'}
              </Td></tr>
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

      {/* Confirmation dialog */}
      <Modal
        open={!!confirmId}
        onClose={() => { setConfirmId(null); setSaving(null) }}
        title="Criar regra automatica?"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => doClassificar(false)}>Nao, so classificar</Button>
            <Button onClick={() => doClassificar(true)}>Sim, criar regra</Button>
          </div>
        }
      >
        <p className="text-sm text-gray-600">
          {confirmId && isEmitida(faturas.find((f) => f.id === confirmId)!)
            ? 'Criar regra para que futuras faturas deste inquilino (NIF) sejam automaticamente associadas a este imovel como receita?'
            : 'Criar regra para que futuras faturas deste fornecedor (NIF) sejam automaticamente classificadas com o mesmo imovel e rubrica?'
          }
        </p>
      </Modal>
    </div>
  )
}
