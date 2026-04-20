'use client'

import { useEffect, useState, useCallback } from 'react'
import { useSession } from 'next-auth/react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Badge } from '@/components/ui/Badge'
import { Modal } from '@/components/ui/Modal'
import { hasPermission, type Role } from '@/lib/permissions'

interface Regra {
  id: string
  nifEntidade: string
  rubricaId: string
  tipo: 'IGUAL' | 'PERCENTAGEM' | 'MANUAL'
  nome: string | null
  entidade: { nif: string; nome: string }
  rubrica: { id: string; nome: string }
  linhas: { id: string; imovelId: string; percentagem: string | null; imovel: { id: string; nome: string; codigo: string } }[]
}

interface ImovelOption { id: string; nome: string; codigo: string }
interface RubricaOption { id: string; nome: string }

interface RegraForm {
  nifEntidade: string
  nomeEntidade: string
  imovelId: string
  rubricaId: string
}
const emptyForm: RegraForm = { nifEntidade: '', nomeEntidade: '', imovelId: '', rubricaId: '' }

export default function MapeamentoPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role

  const [regras, setRegras] = useState<Regra[]>([])
  const [imoveis, setImoveis] = useState<ImovelOption[]>([])
  const [rubricas, setRubricas] = useState<RubricaOption[]>([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)

  const [modalOpen, setModalOpen] = useState(false)
  const [editId, setEditId] = useState<string | null>(null)
  const [form, setForm] = useState<RegraForm>(emptyForm)

  const canEdit = role ? hasPermission(role, 'mapeamento:editar') : false

  const fetchData = useCallback(() => {
    fetch('/api/distribuicao').then((r) => r.json()).then((j) => {
      if (j.data) setRegras(j.data)
    }).catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => { fetchData() }, [fetchData])

  useEffect(() => {
    fetch('/api/opcoes').then((r) => r.json()).then((j) => {
      if (j.data) {
        setImoveis(j.data.imoveis)
        setRubricas(j.data.rubricas)
      }
    }).catch(() => {})
  }, [])

  function openCreate() {
    setEditId(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(r: Regra) {
    setEditId(r.id)
    setForm({
      nifEntidade: r.nifEntidade,
      nomeEntidade: r.entidade.nome,
      imovelId: r.linhas[0]?.imovelId ?? '',
      rubricaId: r.rubricaId,
    })
    setModalOpen(true)
  }

  async function handleSave() {
    if (!form.rubricaId || !form.nifEntidade) return
    const payload = {
      nifEntidade: form.nifEntidade,
      nomeEntidade: form.nomeEntidade,
      rubricaId: form.rubricaId,
      tipo: 'IGUAL' as const,
      linhas: form.imovelId ? [{ imovelId: form.imovelId }] : [],
    }
    if (editId) {
      await fetch(`/api/distribuicao/${editId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })
    } else {
      await fetch('/api/distribuicao', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })
    }
    setModalOpen(false)
    fetchData()
  }

  async function handleRemove(id: string) {
    if (!confirm('Remover esta regra?')) return
    await fetch(`/api/distribuicao/${id}`, { method: 'DELETE' })
    fetchData()
  }

  const filtered = regras.filter((r) =>
    !search ||
    r.nifEntidade.includes(search) ||
    r.entidade.nome.toLowerCase().includes(search.toLowerCase())
  )

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="flex-1 max-w-xs">
          <Input placeholder="Pesquisar NIF, nome..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        {canEdit && <Button onClick={openCreate}>Adicionar regra</Button>}
      </div>

      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              <Th>NIF</Th>
              <Th>Nome</Th>
              <Th>Rubrica</Th>
              <Th>Imoveis</Th>
              {canEdit && <Th>Accoes</Th>}
            </tr>
          </thead>
          <tbody>
            {filtered.map((r) => (
              <tr key={r.id}>
                <Td><span className="font-mono text-[11px]">{r.nifEntidade}</span></Td>
                <Td>{r.entidade.nome}</Td>
                <Td>{r.rubrica.nome}</Td>
                <Td>
                  {r.linhas.length === 0 ? (
                    <span className="text-[11px] text-gray-400 italic">So rubrica</span>
                  ) : (
                    <div className="flex flex-wrap gap-1">
                      {r.linhas.map((l) => (
                        <span key={l.id} className="text-[11px] px-1.5 py-0.5 bg-gray-100 rounded">
                          {l.imovel.codigo}
                          {r.linhas.length > 1 && l.percentagem && ` (${Number(l.percentagem).toFixed(1)}%)`}
                        </span>
                      ))}
                      {r.linhas.length > 1 && (
                        <Badge variant="teal" className="ml-1">Distribuicao</Badge>
                      )}
                    </div>
                  )}
                </Td>
                {canEdit && (
                  <Td>
                    <div className="flex items-center gap-2">
                      <button onClick={() => openEdit(r)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                      <button onClick={() => handleRemove(r.id)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                    </div>
                  </Td>
                )}
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr><Td colSpan={5} className="text-center text-gray-400">Sem regras encontradas</Td></tr>
            )}
          </tbody>
        </Table>
      </Card>

      {/* Modal: criar/editar regra simples */}
      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editId ? 'Editar regra' : 'Criar regra'}
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setModalOpen(false)}>Cancelar</Button>
            <Button onClick={handleSave}>{editId ? 'Guardar' : 'Criar'}</Button>
          </div>
        }
      >
        <div className="space-y-3">
          <Input label="NIF Entidade" value={form.nifEntidade} onChange={(e) => setForm({ ...form, nifEntidade: e.target.value })} disabled={!!editId} />
          <Input label="Nome Entidade" value={form.nomeEntidade} onChange={(e) => setForm({ ...form, nomeEntidade: e.target.value })} disabled={!!editId} />
          <Select
            label="Imovel (opcional)"
            options={[{ value: '', label: '— Sem imovel (so rubrica) —' }, ...imoveis.map((i) => ({ value: i.id, label: `${i.codigo} - ${i.nome}` }))]}
            value={form.imovelId}
            onChange={(e) => setForm({ ...form, imovelId: e.target.value })}
          />
          <Select
            label="Rubrica"
            options={rubricas.map((r) => ({ value: r.id, label: r.nome }))}
            value={form.rubricaId}
            onChange={(e) => setForm({ ...form, rubricaId: e.target.value })}
          />
          <p className="text-[11px] text-gray-400">
            Para distribuir por varios imoveis, classifique uma fatura e edite-a na pagina de faturas classificadas.
          </p>
        </div>
      </Modal>
    </div>
  )
}
