'use client'

import { useEffect, useState, useCallback } from 'react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Badge } from '@/components/ui/Badge'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Modal } from '@/components/ui/Modal'
import { formatDate } from '@/lib/utils'

interface Utilizador {
  id: string
  nome: string
  email: string
  role: string
  ativo: boolean
  criadoEm: string
  ultimoLogin: string | null
}

const ROLE_BADGE: Record<string, 'purple' | 'teal' | 'blue'> = {
  ADMIN: 'purple',
  GESTOR: 'teal',
  OPERADOR: 'blue',
}

const ROLE_OPTIONS = [
  { value: 'ADMIN', label: 'Admin' },
  { value: 'GESTOR', label: 'Gestor' },
  { value: 'OPERADOR', label: 'Operador' },
]

const ESTADO_OPTIONS = [
  { value: 'true', label: 'Activo' },
  { value: 'false', label: 'Inactivo' },
]

function getInitials(name: string): string {
  return name.split(' ').filter(Boolean).map((p) => p[0]).slice(0, 2).join('').toUpperCase()
}

export default function UtilizadoresPage() {
  const [users, setUsers] = useState<Utilizador[]>([])
  const [modalMode, setModalMode] = useState<'create' | 'edit' | null>(null)
  const [editUser, setEditUser] = useState<Utilizador | null>(null)
  const [createForm, setCreateForm] = useState({ nome: '', email: '', password: '', role: 'OPERADOR' })
  const [editForm, setEditForm] = useState({ nome: '', role: '', ativo: 'true', password: '' })
  const [loading, setLoading] = useState(true)

  const fetchData = useCallback(() => {
    fetch('/api/utilizadores')
      .then((r) => r.json())
      .then((j) => { if (j.data) setUsers(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => { fetchData() }, [fetchData])

  function openCreate() {
    setModalMode('create')
    setCreateForm({ nome: '', email: '', password: '', role: 'OPERADOR' })
  }

  function openEdit(u: Utilizador) {
    setModalMode('edit')
    setEditUser(u)
    setEditForm({ nome: u.nome, role: u.role, ativo: String(u.ativo), password: '' })
  }

  async function handleCreate() {
    const res = await fetch('/api/utilizadores', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(createForm),
    })
    if (res.ok) {
      setModalMode(null)
      fetchData()
    } else {
      const j = await res.json()
      alert(j.error || 'Erro ao criar utilizador')
    }
  }

  async function handleEdit() {
    if (!editUser) return
    const payload: Record<string, unknown> = {
      nome: editForm.nome,
      role: editForm.role,
      ativo: editForm.ativo === 'true',
    }
    if (editForm.password) payload.password = editForm.password

    await fetch(`/api/utilizadores/${editUser.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
    setModalMode(null)
    fetchData()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div />
        <Button onClick={openCreate}>Novo utilizador</Button>
      </div>

      <Card className="p-0">
        <Table>
          <thead>
            <tr>
              <Th />
              <Th>Nome</Th>
              <Th>Email</Th>
              <Th>Role</Th>
              <Th>Estado</Th>
              <Th>Ultimo login</Th>
              <Th>Accoes</Th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr key={u.id}>
                <Td>
                  <div
                    className="flex items-center justify-center rounded-full text-[10px] font-semibold select-none"
                    style={{
                      width: 28,
                      height: 28,
                      backgroundColor: ROLE_BADGE[u.role] === 'purple' ? '#EEEDFE' : ROLE_BADGE[u.role] === 'teal' ? '#E1F5EE' : '#E6F1FB',
                      color: ROLE_BADGE[u.role] === 'purple' ? '#3C3489' : ROLE_BADGE[u.role] === 'teal' ? '#085041' : '#0C447C',
                    }}
                  >
                    {getInitials(u.nome)}
                  </div>
                </Td>
                <Td className="font-medium">{u.nome}</Td>
                <Td>{u.email}</Td>
                <Td><Badge variant={ROLE_BADGE[u.role] ?? 'gray'}>{u.role}</Badge></Td>
                <Td><Badge variant={u.ativo ? 'green' : 'gray'}>{u.ativo ? 'Activo' : 'Inactivo'}</Badge></Td>
                <Td>{u.ultimoLogin ? formatDate(u.ultimoLogin) : '-'}</Td>
                <Td>
                  <button onClick={() => openEdit(u)} className="text-[12px] text-[#1D9E75] hover:underline">
                    Editar
                  </button>
                </Td>
              </tr>
            ))}
            {users.length === 0 && (
              <tr><Td colSpan={7} className="text-center text-gray-400">Sem utilizadores</Td></tr>
            )}
          </tbody>
        </Table>
      </Card>

      {/* Create modal */}
      <Modal
        open={modalMode === 'create'}
        onClose={() => setModalMode(null)}
        title="Novo utilizador"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setModalMode(null)}>Cancelar</Button>
            <Button onClick={handleCreate}>Criar</Button>
          </div>
        }
      >
        <div className="space-y-3">
          <Input label="Nome" value={createForm.nome} onChange={(e) => setCreateForm({ ...createForm, nome: e.target.value })} />
          <Input label="Email" type="email" value={createForm.email} onChange={(e) => setCreateForm({ ...createForm, email: e.target.value })} />
          <Input label="Password" type="password" value={createForm.password} onChange={(e) => setCreateForm({ ...createForm, password: e.target.value })} />
          <Select label="Role" options={ROLE_OPTIONS} value={createForm.role} onChange={(e) => setCreateForm({ ...createForm, role: e.target.value })} />
        </div>
      </Modal>

      {/* Edit modal */}
      <Modal
        open={modalMode === 'edit'}
        onClose={() => setModalMode(null)}
        title="Editar utilizador"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setModalMode(null)}>Cancelar</Button>
            <Button onClick={handleEdit}>Guardar</Button>
          </div>
        }
      >
        <div className="space-y-3">
          <Input label="Nome" value={editForm.nome} onChange={(e) => setEditForm({ ...editForm, nome: e.target.value })} />
          <Select label="Role" options={ROLE_OPTIONS} value={editForm.role} onChange={(e) => setEditForm({ ...editForm, role: e.target.value })} />
          <Select label="Estado" options={ESTADO_OPTIONS} value={editForm.ativo} onChange={(e) => setEditForm({ ...editForm, ativo: e.target.value })} />
          <Input label="Nova password (deixar vazio para manter)" type="password" value={editForm.password} onChange={(e) => setEditForm({ ...editForm, password: e.target.value })} />
        </div>
      </Modal>
    </div>
  )
}
