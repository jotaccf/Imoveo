'use client'

import { usePathname } from 'next/navigation'
import { useSession, signOut } from 'next-auth/react'
import { useState, useEffect } from 'react'
import { hasPermission, type Role } from '@/lib/permissions'

const PATHNAME_TITLES: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/imoveis': 'Imoveis',
  '/importar': 'Importar CSV',
  '/lancamentos': 'Lancamentos Manuais',
  '/pendentes': 'Faturas Pendentes',
  '/faturas': 'Faturas classificadas',
  '/resultados': 'Resultados',
  '/mapeamento': 'Mapeamento NIF',
  '/analise': 'Analise Financeira',
  '/custos': 'Custos Operacionais',
  '/irc': 'Previsao IRC',
  '/calculadora': 'Calculadora Financeira',
  '/configuracoes': 'Configuracoes',
  '/backups': 'Backups',
  '/utilizadores': 'Utilizadores',
}

const ROLE_COLORS: Record<Role, { bg: string; text: string }> = {
  ADMIN: { bg: '#EEEDFE', text: '#3C3489' },
  GESTOR: { bg: '#E1F5EE', text: '#085041' },
  OPERADOR: { bg: '#E6F1FB', text: '#0C447C' },
}

function getInitials(name: string | undefined | null): string {
  if (!name) return '?'
  return name.split(' ').filter(Boolean).map((p) => p[0]).slice(0, 2).join('').toUpperCase()
}

export function Topbar() {
  const pathname = usePathname()
  const { data: session } = useSession()
  const [showTooltip, setShowTooltip] = useState(false)
  const [updateAvailable, setUpdateAvailable] = useState(false)
  const [latestVersion, setLatestVersion] = useState('')
  const [updating, setUpdating] = useState(false)

  const user = session?.user as { name?: string | null; nome?: string; role?: Role } | undefined
  const role = user?.role ?? 'OPERADOR'
  const name = user?.nome || user?.name || ''
  const colors = ROLE_COLORS[role]
  const title = PATHNAME_TITLES[pathname] ?? pathname.replace('/', '').replace(/-/g, ' ')
  const isAdmin = role ? hasPermission(role, 'utilizadores:ver') : false

  // Verificar actualizacoes a cada 30 min (ADMIN only)
  useEffect(() => {
    if (!isAdmin) return
    function checkUpdate() {
      fetch('/api/admin/version')
        .then((r) => r.json())
        .then((j) => {
          if (j.data?.updateAvailable) {
            setUpdateAvailable(true)
            setLatestVersion(j.data.latestVersion)
          }
        })
        .catch(() => {})
    }
    checkUpdate()
    const interval = setInterval(checkUpdate, 30 * 60 * 1000)
    return () => clearInterval(interval)
  }, [isAdmin])

  async function handleUpdate() {
    if (!confirm('Tem a certeza que pretende actualizar? A aplicacao ira reiniciar.')) return
    setUpdating(true)
    await fetch('/api/admin/update', { method: 'POST' }).catch(() => {})
    // Poll health endpoint ate a app voltar
    const poll = setInterval(async () => {
      try {
        const res = await fetch('/api/health')
        if (res.ok) {
          clearInterval(poll)
          window.location.reload()
        }
      } catch { /* app ainda a reiniciar */ }
    }, 5000)
    // Timeout apos 5 min
    setTimeout(() => { clearInterval(poll); setUpdating(false) }, 300000)
  }

  return (
    <header>
      {/* Update banner */}
      {updateAvailable && isAdmin && !updating && (
        <div className="flex items-center justify-between px-5 py-2 text-[12px]" style={{ background: '#E1F5EE', borderBottom: '1px solid #9FE1CB' }}>
          <span style={{ color: '#085041' }}>
            Nova versao disponivel: <strong>v{latestVersion}</strong>
          </span>
          <button
            onClick={handleUpdate}
            className="px-3 py-1 rounded-lg text-[11px] font-medium text-white transition-colors"
            style={{ background: '#1D9E75' }}
          >
            Actualizar agora
          </button>
        </div>
      )}
      {updating && (
        <div className="flex items-center justify-center px-5 py-2 text-[12px]" style={{ background: '#FAEEDA', borderBottom: '1px solid #E5C07B' }}>
          <span style={{ color: '#633806' }}>A actualizar... A aplicacao ira reiniciar em breve. Nao feche esta pagina.</span>
        </div>
      )}

      {/* Main topbar */}
      <div
        className="flex items-center justify-between px-5"
        style={{ height: 48, backgroundColor: '#ffffff', borderBottom: '0.5px solid #E5E7EB' }}
      >
        <h1 className="font-medium text-gray-900" style={{ fontSize: 15 }}>{title}</h1>

        <div className="flex items-center gap-3">
          <div className="relative" onMouseEnter={() => setShowTooltip(true)} onMouseLeave={() => setShowTooltip(false)}>
            <div
              className="flex items-center justify-center rounded-full text-xs font-semibold select-none"
              style={{ width: 32, height: 32, backgroundColor: colors.bg, color: colors.text }}
            >
              {getInitials(name)}
            </div>
            {showTooltip && (
              <div className="absolute right-0 top-full mt-1 rounded-md px-3 py-1.5 text-xs shadow-md whitespace-nowrap z-50" style={{ backgroundColor: '#1F2937', color: '#ffffff' }}>
                {name} &middot; {role}
              </div>
            )}
          </div>
          <button onClick={() => signOut({ callbackUrl: '/login' })} className="text-xs text-gray-500 hover:text-gray-700 transition-colors">
            Sair
          </button>
        </div>
      </div>
    </header>
  )
}
