'use client'

import { useEffect, useState, useCallback } from 'react'
import { useSession } from 'next-auth/react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Modal } from '@/components/ui/Modal'
import { hasPermission, type Role } from '@/lib/permissions'

interface NifMap {
  id: string
  nifEntidade: string
  imovelId: string
  rubricaId: string
  entidade: { nif: string; nome: string } | null
  imovel: { id: string; nome: string; codigo: string }
  rubrica: { id: string; nome: string }
}

interface ImovelOption { id: string; nome: string; codigo: string }
interface RubricaOption { id: string; nome: string }

const emptyForm = { nifEntidade: '', nomeEntidade: '', imovelId: '', rubricaId: '' }

export default function MapeamentoPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role

  const [maps, setMaps] = useState<NifMap[]>([])
  const [imoveis, setImoveis] = useState<ImovelOption[]>([])
  const [rubricas, setRubricas] = useState<RubricaOption[]>([])
  const [search, setSearch] = useState('')
  const [modalOpen, setModalOpen] = useState(false)
  const [editId, setEditId] = useState<string | null>(null)
  const [form, setForm] = useState(emptyForm)
  const [loading, setLoading] = useState(true)

  const canEdit = role ? hasPermission(role, 'mapeamento:editar') : false

  const fetchData = useCallback(() => {
    fetch('/api/mapeamento')
      .then((r) => r.json())
      .then((j) => { if (j.data) setMaps(j.data) })
      .catch(() => {})
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

  async function handleRemove(id: string) {
    if (!confirm('Tem a certeza que pretende remover este mapeamento?')) return
    await fetch(`/api/mapeamento/${id}`, { method: 'DELETE' })
    fetchData()
  }

  const filtered = maps.filter((m) =>
    !search ||
    m.nifEntidade.includes(search) ||
    (m.entidade?.nome ?? '').toLowerCase().includes(search.toLowerCase()) ||
    m.imovel.nome.toLowerCase().includes(search.toLowerCase())
  )

  function openCreate() {
    setEditId(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(m: NifMap) {
    setEditId(m.id)
    setForm({
      nifEntidade: m.nifEntidade,
      nomeEntidade: m.entidade?.nome ?? '',
      imovelId: m.imovelId,
      rubricaId: m.rubricaId,
    })
    setModalOpen(true)
  }

  async function handleSave() {
    if (editId) {
      await fetch(`/api/mapeamento/${editId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ imovelId: form.imovelId, rubricaId: form.rubricaId }),
      })
    } else {
      await fetch('/api/mapeamento', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
    }
    setModalOpen(false)
    fetchData()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      {/* Search and actions */}
      <div className="flex items-center gap-3">
        <div className="flex-1 max-w-xs">
          <Input placeholder="Pesquisar NIF, nome..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        {canEdit && <Button onClick={openCreate}>Adicionar mapeamento</Button>}
      </div>

      {/* Table */}
      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              <Th>NIF</Th>
              <Th>Nome</Th>
              <Th>Imovel</Th>
              <Th>Rubrica</Th>
              {canEdit && <Th>Accoes</Th>}
            </tr>
          </thead>
          <tbody>
            {filtered.map((m) => (
              <tr key={m.id}>
                <Td><span className="font-mono text-[11px]">{m.nifEntidade}</span></Td>
                <Td>{m.entidade?.nome ?? '-'}</Td>
                <Td>{m.imovel.codigo} - {m.imovel.nome}</Td>
                <Td>{m.rubrica.nome}</Td>
                {canEdit && (
                  <Td>
                    <div className="flex items-center gap-2">
                      <button onClick={() => openEdit(m)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                      <button onClick={() => handleRemove(m.id)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                    </div>
                  </Td>
                )}
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr><Td colSpan={5} className="text-center text-gray-400">Sem mapeamentos encontrados</Td></tr>
            )}
          </tbody>
        </Table>
      </Card>

      {/* Create / Edit Modal */}
      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editId ? 'Editar mapeamento' : 'Adicionar mapeamento'}
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setModalOpen(false)}>Cancelar</Button>
            <Button onClick={handleSave}>{editId ? 'Guardar' : 'Criar'}</Button>
          </div>
        }
      >
        <div className="space-y-3">
          <Input
            label="NIF Entidade"
            value={form.nifEntidade}
            onChange={(e) => setForm({ ...form, nifEntidade: e.target.value })}
            disabled={!!editId}
          />
          <Input
            label="Nome Entidade"
            value={form.nomeEntidade}
            onChange={(e) => setForm({ ...form, nomeEntidade: e.target.value })}
            disabled={!!editId}
          />
          <Select
            label="Imovel"
            options={imoveis.map((i) => ({ value: i.id, label: `${i.codigo} - ${i.nome}` }))}
            value={form.imovelId}
            onChange={(e) => setForm({ ...form, imovelId: e.target.value })}
          />
          <Select
            label="Rubrica"
            options={rubricas.map((r) => ({ value: r.id, label: r.nome }))}
            value={form.rubricaId}
            onChange={(e) => setForm({ ...form, rubricaId: e.target.value })}
          />
        </div>
      </Modal>
    </div>
  )
}
