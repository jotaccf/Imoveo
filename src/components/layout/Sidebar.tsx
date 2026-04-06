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
  items: MenuItem[]
}

export function Sidebar() {
  const pathname = usePathname()
  const { data: session } = useSession()
  const [pendentesCount, setPendentesCount] = useState<number>(0)

  const role = (session?.user as { role?: Role } | undefined)?.role

  useEffect(() => {
    fetch('/api/faturas/pendentes')
      .then((res) => res.json())
      .then((data) => {
        if (typeof data.count === 'number') setPendentesCount(data.count)
      })
      .catch(() => {})
  }, [])

  const sections: MenuSection[] = [
    {
      title: 'PRINCIPAL',
      items: [
        { label: 'Dashboard', href: '/dashboard', icon: <LayoutDashboard size={16} /> },
        { label: 'Imoveis', href: '/imoveis', icon: <Building2 size={16} />, permission: 'imoveis:ver' },
      ],
    },
    {
      title: 'FATURAS',
      items: [
        { label: 'Importar CSV', href: '/importar', icon: <Upload size={16} /> },
        { label: 'Lancamentos manuais', href: '/lancamentos', icon: <FileText size={16} /> },
        { label: 'Pendentes', href: '/pendentes', icon: <AlertCircle size={16} /> },
        { label: 'Faturas classificadas', href: '/faturas', icon: <FileText size={16} />, permission: 'faturas:ver' },
      ],
    },
    {
      title: 'ANALISE',
      items: [
        { label: 'Analise Financeira', href: '/analise', icon: <TrendingUp size={16} />, permission: 'resultados:ver' },
        { label: 'Custos Operacionais', href: '/custos', icon: <PieChart size={16} />, permission: 'resultados:ver' },
        { label: 'Previsao IRC', href: '/irc', icon: <Calculator size={16} />, permission: 'resultados:ver' },
        { label: 'Calculadora', href: '/calculadora', icon: <Calculator size={16} />, permission: 'resultados:ver' },
        { label: 'Resultados', href: '/resultados', icon: <BarChart3 size={16} />, permission: 'resultados:ver' },
        { label: 'Mapeamento NIF', href: '/mapeamento', icon: <Link2 size={16} />, permission: 'mapeamento:ver' },
      ],
    },
    {
      title: 'ADMINISTRACAO',
      items: [
        { label: 'Configuracoes', href: '/configuracoes', icon: <Settings size={16} />, permission: 'utilizadores:ver' },
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
      className="fixed left-0 top-0 h-screen flex flex-col"
      style={{ width: 210, backgroundColor: '#0D1B1A' }}
    >
      {/* Header */}
      <div className="px-4 py-4" style={{ borderBottom: '1px solid #1a2e2c' }}>
        <div className="flex items-center gap-2">
          <ImoveoIcon size={28} />
          <div>
            <div className="text-white text-sm font-semibold leading-tight">imoveo</div>
            <div className="text-[10px] leading-tight" style={{ color: '#5DCAA5' }}>
              gestao patrimonial
            </div>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-3">
        {sections.map((section) => {
          const visibleItems = section.items.filter(isVisible)
          if (visibleItems.length === 0) return null

          return (
            <div key={section.title} className="mb-3">
              <div
                className="px-4 pb-1 text-[10px] uppercase font-medium"
                style={{ letterSpacing: '0.05em', color: '#4B5563' }}
              >
                {section.title}
              </div>

              {visibleItems.map((item) => {
                const active = pathname === item.href
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className="flex items-center gap-2.5 mx-2 rounded-md transition-colors"
                    style={{
                      padding: '7px 16px',
                      color: active ? '#ffffff' : '#9CA3AF',
                      backgroundColor: active ? '#1a3830' : undefined,
                      borderLeft: active ? '2px solid #1D9E75' : '2px solid transparent',
                      fontWeight: active ? 500 : 400,
                      fontSize: 13,
                    }}
                    onMouseEnter={(e) => {
                      if (!active) {
                        e.currentTarget.style.backgroundColor = '#111E1D'
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (!active) {
                        e.currentTarget.style.backgroundColor = ''
                      }
                    }}
                  >
                    {item.icon}
                    <span className="flex-1">{item.label}</span>
                    {item.href === '/pendentes' && pendentesCount > 0 && (
                      <span
                        className="text-[10px] font-medium text-white rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1"
                        style={{ backgroundColor: '#DC2626' }}
                      >
                        {pendentesCount}
                      </span>
                    )}
                  </Link>
                )
              })}
            </div>
          )
        })}
      </nav>

      {/* Footer */}
      <div
        className="px-4 py-3 text-[11px]"
        style={{ color: '#4B5563', borderTop: '1px solid #1a2e2c' }}
      >
        Periodo: {new Date().getFullYear()}
      </div>
    </aside>
  )
}
