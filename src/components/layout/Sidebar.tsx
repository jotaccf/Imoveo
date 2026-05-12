'use client'

import { usePathname } from 'next/navigation'
import { useSession } from 'next-auth/react'
import Link from 'next/link'
import { useEffect, useState } from 'react'
import {
  LayoutDashboard,
  Building2,
  Upload,
  FileText,
  AlertCircle,
  BarChart3,
  Link2,
  Users,
  TrendingUp,
  PieChart,
  Calculator,
  Settings,
  Database,
  FileSignature,
  ClipboardList,
  Bell,
  Car,
  ChevronLeft,
  ChevronRight,
  ChevronDown,
} from 'lucide-react'
import { ImoveoIcon } from '@/components/ui/ImoveoIcon'
import { hasPermission, type Role } from '@/lib/permissions'

interface MenuItem {
  label: string
  href: string
  icon: React.ReactNode
  permission?: Parameters<typeof hasPermission>[1]
}

interface MenuSection {
  title: string
  key: string
  items: MenuItem[]
}

interface SidebarProps {
  collapsed: boolean
  onToggle: () => void
}

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const pathname = usePathname()
  const { data: session } = useSession()
  const [pendentesCount, setPendentesCount] = useState<number>(0)
  const [alertasCount, setAlertasCount] = useState<number>(0)
  const [appVersion, setAppVersion] = useState<string>('')

  // Seccoes colapsaveis — persistir em localStorage
  const [openSections, setOpenSections] = useState<Record<string, boolean>>({})

  useEffect(() => {
    try {
      const saved = localStorage.getItem('imoveo-sidebar-sections')
      if (saved) setOpenSections(JSON.parse(saved))
    } catch { /* ignore */ }
  }, [])

  function toggleSection(key: string) {
    setOpenSections((prev) => {
      const isOpen = prev[key] !== false
      const next = { ...prev, [key]: !isOpen }
      localStorage.setItem('imoveo-sidebar-sections', JSON.stringify(next))
      return next
    })
  }

  function isSectionOpen(key: string): boolean {
    return openSections[key] !== false
  }

  const role = (session?.user as { role?: Role } | undefined)?.role

  useEffect(() => {
    fetch('/api/faturas/pendentes')
      .then((res) => res.json())
      .then((data) => {
        if (typeof data.count === 'number') setPendentesCount(data.count)
      })
      .catch(() => {})
    fetch('/api/alertas')
      .then((res) => res.json())
      .then((data) => {
        if (data.data?.alertas) setAlertasCount(data.data.alertas.length)
      })
      .catch(() => {})
    fetch('/api/admin/version')
      .then((res) => res.json())
      .then((data) => {
        if (data.data?.currentVersion) setAppVersion(data.data.currentVersion)
      })
      .catch(() => {})
  }, [])

  const sections: MenuSection[] = [
    {
      title: 'PRINCIPAL',
      key: 'principal',
      items: [
        { label: 'Dashboard', href: '/dashboard', icon: <LayoutDashboard size={16} /> },
        { label: 'Imoveis', href: '/imoveis', icon: <Building2 size={16} />, permission: 'imoveis:ver' },
        { label: 'Activos fixos', href: '/activos-fixos', icon: <Car size={16} />, permission: 'imoveis:ver' },
        { label: 'Contratos', href: '/contratos', icon: <FileSignature size={16} />, permission: 'imoveis:ver' },
        { label: 'Dashboard Contratos', href: '/contratos/dashboard', icon: <ClipboardList size={16} />, permission: 'imoveis:ver' },
      ],
    },
    {
      title: 'FATURAS',
      key: 'faturas',
      items: [
        { label: 'Importar CSV', href: '/importar', icon: <Upload size={16} /> },
        { label: 'Lancamentos manuais', href: '/lancamentos', icon: <FileText size={16} /> },
        { label: 'Pendentes', href: '/pendentes', icon: <AlertCircle size={16} /> },
        { label: 'Faturas classificadas', href: '/faturas', icon: <FileText size={16} />, permission: 'faturas:ver' },
      ],
    },
    {
      title: 'ANALISE',
      key: 'analise',
      items: [
        { label: 'Analise Financeira', href: '/analise', icon: <TrendingUp size={16} />, permission: 'resultados:ver' },
        { label: 'Custos Operacionais', href: '/custos', icon: <PieChart size={16} />, permission: 'resultados:ver' },
        { label: 'Previsao IRC', href: '/irc', icon: <Calculator size={16} />, permission: 'resultados:ver' },
        { label: 'Calculadora', href: '/calculadora', icon: <Calculator size={16} />, permission: 'resultados:ver' },
        { label: 'Alertas', href: '/alertas', icon: <Bell size={16} />, permission: 'resultados:ver' },
        { label: 'Resultados', href: '/resultados', icon: <BarChart3 size={16} />, permission: 'resultados:ver' },
        { label: 'Mapeamento NIF', href: '/mapeamento', icon: <Link2 size={16} />, permission: 'mapeamento:ver' },
      ],
    },
    {
      title: 'ADMINISTRACAO',
      key: 'admin',
      items: [
        { label: 'Configuracoes', href: '/configuracoes', icon: <Settings size={16} />, permission: 'utilizadores:ver' },
        { label: 'Backups', href: '/backups', icon: <Database size={16} />, permission: 'utilizadores:ver' },
        { label: 'Utilizadores', href: '/utilizadores', icon: <Users size={16} />, permission: 'utilizadores:ver' },
      ],
    },
  ]

  function isVisible(item: MenuItem): boolean {
    if (!item.permission) return true
    if (!role) return false
    return hasPermission(role, item.permission)
  }

  return (
    <aside
      className="fixed left-0 top-0 h-screen flex flex-col transition-all duration-200"
      style={{ width: collapsed ? 56 : 210, backgroundColor: '#0D1B1A' }}
    >
      {/* Header */}
      <div className="px-3 py-4" style={{ borderBottom: '1px solid #1a2e2c' }}>
        <div className="flex items-center gap-2">
          <ImoveoIcon size={28} />
          {!collapsed && (
            <div className="flex-1">
              <div className="text-white text-sm font-semibold leading-tight">imoveo</div>
              <div className="text-[10px] leading-tight" style={{ color: '#5DCAA5' }}>
                gestao patrimonial
              </div>
            </div>
          )}
          <button
            onClick={onToggle}
            className="p-1 rounded transition-colors hover:bg-[#1a3830]"
            style={{ color: '#4B5563' }}
            title={collapsed ? 'Expandir menu' : 'Colapsar menu'}
          >
            {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
          </button>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-3">
        {sections.map((section) => {
          const visibleItems = section.items.filter(isVisible)
          if (visibleItems.length === 0) return null
          const open = isSectionOpen(section.key)
          // Se secção está fechada mas tem item activo, manter indicação
          const hasActive = visibleItems.some((item) => pathname === item.href)

          return (
            <div key={section.key} className="mb-1">
              {/* Section title — clicavel para colapsar */}
              {!collapsed ? (
                <button
                  onClick={() => toggleSection(section.key)}
                  className="w-full flex items-center justify-between px-4 pb-1 pt-2 group"
                >
                  <span
                    className="text-[10px] uppercase font-medium"
                    style={{ letterSpacing: '0.05em', color: hasActive && !open ? '#5DCAA5' : '#4B5563' }}
                  >
                    {section.title}
                  </span>
                  <ChevronDown
                    size={12}
                    className="transition-transform duration-150 opacity-0 group-hover:opacity-100"
                    style={{ color: '#4B5563', transform: open ? 'rotate(0deg)' : 'rotate(-90deg)' }}
                  />
                </button>
              ) : (
                <div className="mx-auto my-2 w-6 border-t" style={{ borderColor: '#1a2e2c' }} />
              )}

              {/* Items */}
              {(collapsed || open) && visibleItems.map((item) => {
                const active = pathname === item.href
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    title={collapsed ? item.label : undefined}
                    className="flex items-center gap-2.5 mx-2 rounded-md transition-colors"
                    style={{
                      padding: collapsed ? '7px 0' : '7px 16px',
                      justifyContent: collapsed ? 'center' : undefined,
                      color: active ? '#ffffff' : '#9CA3AF',
                      backgroundColor: active ? '#1a3830' : undefined,
                      borderLeft: collapsed ? undefined : active ? '2px solid #1D9E75' : '2px solid transparent',
                      fontWeight: active ? 500 : 400,
                      fontSize: 13,
                    }}
                    onMouseEnter={(e) => {
                      if (!active) e.currentTarget.style.backgroundColor = '#111E1D'
                    }}
                    onMouseLeave={(e) => {
                      if (!active) e.currentTarget.style.backgroundColor = ''
                    }}
                  >
                    {item.icon}
                    {!collapsed && (
                      <>
                        <span className="flex-1 truncate">{item.label}</span>
                        {item.href === '/pendentes' && pendentesCount > 0 && (
                          <span
                            className="text-[10px] font-medium text-white rounded-full min-w-4.5 h-4.5 flex items-center justify-center px-1"
                            style={{ backgroundColor: '#DC2626' }}
                          >
                            {pendentesCount}
                          </span>
                        )}
                        {item.href === '/alertas' && alertasCount > 0 && (
                          <span
                            className="text-[10px] font-medium text-white rounded-full min-w-4.5 h-4.5 flex items-center justify-center px-1"
                            style={{ backgroundColor: '#DC2626' }}
                          >
                            {alertasCount}
                          </span>
                        )}
                      </>
                    )}
                  </Link>
                )
              })}
            </div>
          )
        })}
      </nav>

      {/* Footer */}
      {!collapsed && (
        <div
          className="px-4 py-3 text-[11px]"
          style={{ color: '#4B5563', borderTop: '1px solid #1a2e2c' }}
        >
          <div>Periodo: {new Date().getFullYear()}</div>
          {appVersion && <div style={{ color: '#3d5a56' }}>v{appVersion}</div>}
        </div>
      )}
    </aside>
  )
}
