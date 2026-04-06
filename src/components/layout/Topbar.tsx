'use client'

import { usePathname } from 'next/navigation'
import { useSession, signOut } from 'next-auth/react'
import { useState } from 'react'
import type { Role } from '@/lib/permissions'

const PATHNAME_TITLES: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/imoveis': 'Imoveis',
  '/importar': 'Importar XML',
  '/lancamentos': 'Lancamentos Manuais',
  '/pendentes': 'Faturas Pendentes',
  '/faturas': 'Faturas',
  '/resultados': 'Resultados',
  '/mapeamento': 'Mapeamento NIF',
  '/utilizadores': 'Utilizadores',
}

const ROLE_COLORS: Record<Role, { bg: string; text: string }> = {
  ADMIN: { bg: '#EEEDFE', text: '#3C3489' },
  GESTOR: { bg: '#E1F5EE', text: '#085041' },
  OPERADOR: { bg: '#E6F1FB', text: '#0C447C' },
}

function getInitials(name: string | undefined | null): string {
  if (!name) return '?'
  return name
    .split(' ')
    .filter(Boolean)
    .map((p) => p[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()
}

export function Topbar() {
  const pathname = usePathname()
  const { data: session } = useSession()
  const [showTooltip, setShowTooltip] = useState(false)

  const user = session?.user as { name?: string | null; role?: Role } | undefined
  const role = user?.role ?? 'OPERADOR'
  const name = user?.name ?? ''
  const colors = ROLE_COLORS[role]
  const title = PATHNAME_TITLES[pathname] ?? ''

  return (
    <header
      className="flex items-center justify-between px-5"
      style={{
        height: 48,
        backgroundColor: '#ffffff',
        borderBottom: '0.5px solid #E5E7EB',
      }}
    >
      {/* Page title */}
      <h1 className="font-medium text-gray-900" style={{ fontSize: 15 }}>
        {title}
      </h1>

      {/* Right side */}
      <div className="flex items-center gap-3">
        {/* Avatar with tooltip */}
        <div
          className="relative"
          onMouseEnter={() => setShowTooltip(true)}
          onMouseLeave={() => setShowTooltip(false)}
        >
          <div
            className="flex items-center justify-center rounded-full text-xs font-semibold select-none"
            style={{
              width: 32,
              height: 32,
              backgroundColor: colors.bg,
              color: colors.text,
            }}
          >
            {getInitials(name)}
          </div>

          {showTooltip && (
            <div
              className="absolute right-0 top-full mt-1 rounded-md px-3 py-1.5 text-xs shadow-md whitespace-nowrap z-50"
              style={{ backgroundColor: '#1F2937', color: '#ffffff' }}
            >
              {name} &middot; {role}
            </div>
          )}
        </div>

        {/* Sign out */}
        <button
          onClick={() => signOut({ callbackUrl: '/login' })}
          className="text-xs text-gray-500 hover:text-gray-700 transition-colors"
        >
          Sair
        </button>
      </div>
    </header>
  )
}
