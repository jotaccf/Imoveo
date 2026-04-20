'use client'

import { useState, useEffect } from 'react'
import { useSession, signOut } from 'next-auth/react'
import { Sidebar } from './Sidebar'
import { Topbar } from './Topbar'

export function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession()
  const [collapsed, setCollapsed] = useState(false)

  useEffect(() => {
    try {
      const saved = localStorage.getItem('imoveo-sidebar-collapsed')
      if (saved === 'true') setCollapsed(true)
    } catch { /* ignore */ }
  }, [])

  useEffect(() => {
    localStorage.setItem('imoveo-sidebar-collapsed', String(collapsed))
  }, [collapsed])

  // Sessao invalida apos restart do servidor — forcar logout
  useEffect(() => {
    if (status === 'authenticated' && session?.user && !(session.user as { role?: string }).role) {
      signOut({ callbackUrl: '/login' })
    }
  }, [status, session])

  return (
    <div className="flex h-screen">
      <Sidebar collapsed={collapsed} onToggle={() => setCollapsed(!collapsed)} />

      <div
        className="flex flex-col flex-1 transition-all duration-200"
        style={{ marginLeft: collapsed ? 56 : 210 }}
      >
        <Topbar />
        <main className="flex-1 overflow-y-auto bg-gray-50 p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
