'use client'

import { useEffect, useState } from 'react'
import { useSession } from 'next-auth/react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Modal } from '@/components/ui/Modal'
import type { Role } from '@/lib/permissions'
import { hasPermission } from '@/lib/permissions'

interface Backup {
  filename: string
  size: number
  sizeFormatted: string
  createdAt: string
}

export default function BackupsPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role
  const canManage = role ? hasPermission(role, 'utilizadores:editar') : false

  const [backups, setBackups] = useState<Backup[]>([])
  const [loading, setLoading] = useState(true)
  const [creating, setCreating] = useState(false)
  const [restoreFile, setRestoreFile] = useState<string | null>(null)
  const [deleteFile, setDeleteFile] = useState<string | null>(null)
  const [message, setMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null)

  function fetchBackups() {
    fetch('/api/backups')
      .then((r) => r.json())
      .then((j) => { if (j.data) setBackups(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetchBackups() }, [])

  function showMessage(text: string, type: 'success' | 'error') {
    setMessage({ text, type })
    setTimeout(() => setMessage(null), 5000)
  }

  async function handleCreate() {
    setCreating(true)
    const res = await fetch('/api/backups', { method: 'POST' })
    const json = await res.json()
    setCreating(false)
    if (res.ok) {
      showMessage(json.message || 'Backup criado com sucesso', 'success')
      if (json.data) setBackups(json.data)
    } else {
      showMessage(json.error || 'Erro ao criar backup', 'error')
    }
  }

  async function handleRestore() {
    if (!restoreFile) return
    const res = await fetch('/api/backups', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ filename: restoreFile }),
    })
    const json = await res.json()
    setRestoreFile(null)
    if (res.ok) {
      showMessage(json.message || 'Backup restaurado com sucesso', 'success')
    } else {
      showMessage(json.error || 'Erro ao restaurar backup', 'error')
    }
  }

  async function handleDelete() {
    if (!deleteFile) return
    const res = await fetch('/api/backups', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ filename: deleteFile }),
    })
    const json = await res.json()
    setDeleteFile(null)
    if (res.ok) {
      showMessage(json.message || 'Backup eliminado', 'success')
      if (json.data) setBackups(json.data)
    } else {
      showMessage(json.error || 'Erro ao eliminar backup', 'error')
    }
  }

  function formatDate(iso: string) {
    return new Intl.DateTimeFormat('pt-PT', {
      dateStyle: 'medium',
      timeStyle: 'short',
    }).format(new Date(iso))
  }

  function isAutomatic(filename: string) {
    return !filename.includes('manual')
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-sm font-medium" style={{ color: '#0D1B1A' }}>Backups da base de dados</h2>
          <p className="text-[11px] text-[#9CA3AF] mt-0.5">
            Backups automaticos diarios as 02:00. Retencao: 30 dias.
          </p>
        </div>
        {canManage && (
          <Button onClick={handleCreate} disabled={creating}>
            {creating ? 'A criar...' : 'Criar backup agora'}
          </Button>
        )}
      </div>

      {/* Message */}
      {message && (
        <div className={`rounded-lg px-4 py-3 text-sm ${
          message.type === 'success' ? 'bg-[#E1F5EE] text-[#085041]' : 'bg-[#FCEBEB] text-[#791F1F]'
        }`}>
          {message.text}
        </div>
      )}

      {/* Info cards */}
      <div className="grid grid-cols-3 gap-3">
        <Card className="p-3">
          <div className="text-[11px] text-[#6B7280] mb-1">Total de backups</div>
          <div className="text-xl font-medium" style={{ color: '#0D1B1A' }}>{backups.length}</div>
        </Card>
        <Card className="p-3">
          <div className="text-[11px] text-[#6B7280] mb-1">Ultimo backup</div>
          <div className="text-sm font-medium" style={{ color: '#0D1B1A' }}>
            {backups.length > 0 ? formatDate(backups[0].createdAt) : '—'}
          </div>
        </Card>
        <Card className="p-3">
          <div className="text-[11px] text-[#6B7280] mb-1">Espaco utilizado</div>
          <div className="text-sm font-medium" style={{ color: '#0D1B1A' }}>
            {backups.length > 0
              ? `${(backups.reduce((s, b) => s + b.size, 0) / 1048576).toFixed(1)} MB`
              : '0 MB'}
          </div>
        </Card>
      </div>

      {/* Backup list */}
      <Card className="p-0">
        <table className="w-full text-left text-[13px]">
          <thead>
            <tr>
              <th className="px-4 py-2.5 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">Ficheiro</th>
              <th className="px-4 py-2.5 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">Tipo</th>
              <th className="px-4 py-2.5 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">Data</th>
              <th className="px-4 py-2.5 text-[11px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Tamanho</th>
              {canManage && <th className="px-4 py-2.5 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">Accoes</th>}
            </tr>
          </thead>
          <tbody>
            {backups.map((b) => (
              <tr key={b.filename} className="hover:bg-gray-50">
                <td className="px-4 py-2.5 border-b border-gray-50">
                  <span className="font-mono text-[11px]">{b.filename}</span>
                </td>
                <td className="px-4 py-2.5 border-b border-gray-50">
                  <Badge variant={isAutomatic(b.filename) ? 'blue' : 'teal'}>
                    {isAutomatic(b.filename) ? 'Automatico' : 'Manual'}
                  </Badge>
                </td>
                <td className="px-4 py-2.5 border-b border-gray-50">
                  {formatDate(b.createdAt)}
                </td>
                <td className="px-4 py-2.5 border-b border-gray-50 text-right text-[12px] text-[#6B7280]">
                  {b.sizeFormatted}
                </td>
                {canManage && (
                  <td className="px-4 py-2.5 border-b border-gray-50">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => setRestoreFile(b.filename)}
                        className="text-[11px] text-brand-primary hover:underline"
                      >
                        Restaurar
                      </button>
                      <button
                        onClick={() => setDeleteFile(b.filename)}
                        className="text-[11px] text-[#A32D2D] hover:underline"
                      >
                        Eliminar
                      </button>
                    </div>
                  </td>
                )}
              </tr>
            ))}
            {backups.length === 0 && (
              <tr>
                <td colSpan={canManage ? 5 : 4} className="px-4 py-6 text-center text-[#9CA3AF]">
                  Nenhum backup encontrado
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </Card>

      {/* Info */}
      <div className="rounded-xl p-4 border" style={{ background: '#E6F1FB', borderColor: '#B5D4F4' }}>
        <div className="text-[11px] font-medium uppercase tracking-wider mb-2" style={{ color: '#0C447C' }}>Informacao</div>
        <div className="text-[12px] leading-relaxed" style={{ color: '#0C447C' }}>
          <p className="mb-1"><strong>Backups automaticos:</strong> executados diariamente as 02:00. Os ultimos 30 dias sao mantidos.</p>
          <p className="mb-1"><strong>Restaurar:</strong> repoe a base de dados ao estado do backup seleccionado. Os dados actuais serao substituidos.</p>
          <p><strong>Localizacao no servidor:</strong> <code className="bg-white/50 px-1 rounded">/opt/backups/imoveo/</code></p>
        </div>
      </div>

      {/* Restore confirmation */}
      <Modal
        open={!!restoreFile}
        onClose={() => setRestoreFile(null)}
        title="Restaurar backup"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setRestoreFile(null)}>Cancelar</Button>
            <Button variant="danger" onClick={handleRestore}>Sim, restaurar</Button>
          </div>
        }
      >
        <div className="text-sm text-gray-600">
          <p className="mb-2">Tem a certeza que pretende restaurar este backup?</p>
          <p className="font-mono text-[12px] bg-gray-50 px-3 py-2 rounded">{restoreFile}</p>
          <p className="mt-3 text-[#A32D2D] text-[12px] font-medium">
            Atencao: todos os dados actuais serao substituidos pelos dados do backup.
          </p>
        </div>
      </Modal>

      {/* Delete confirmation */}
      <Modal
        open={!!deleteFile}
        onClose={() => setDeleteFile(null)}
        title="Eliminar backup"
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setDeleteFile(null)}>Cancelar</Button>
            <Button variant="danger" onClick={handleDelete}>Sim, eliminar</Button>
          </div>
        }
      >
        <div className="text-sm text-gray-600">
          <p className="mb-2">Tem a certeza que pretende eliminar este backup?</p>
          <p className="font-mono text-[12px] bg-gray-50 px-3 py-2 rounded">{deleteFile}</p>
          <p className="mt-3 text-[#A32D2D] text-[12px]">Esta accao e irreversivel.</p>
        </div>
      </Modal>
    </div>
  )
}
