'use client'

import { useEffect, useState } from 'react'

const POLL_INTERVAL_MS = 60_000

interface HealthResponse {
  version?: string
}

export function VersionWatcher() {
  const [newVersion, setNewVersion] = useState<string | null>(null)
  const buildVersion = process.env.NEXT_PUBLIC_APP_VERSION

  useEffect(() => {
    if (!buildVersion) return
    let cancelled = false

    async function check() {
      try {
        const r = await fetch('/api/health', { cache: 'no-store' })
        if (!r.ok) return
        const data = (await r.json()) as HealthResponse
        if (cancelled) return
        if (data.version && data.version !== buildVersion) {
          setNewVersion(data.version)
        }
      } catch {
        // ignora falhas de rede — proxima iteracao tenta de novo
      }
    }

    const interval = setInterval(check, POLL_INTERVAL_MS)
    const onFocus = () => check()
    window.addEventListener('focus', onFocus)
    check()

    return () => {
      cancelled = true
      clearInterval(interval)
      window.removeEventListener('focus', onFocus)
    }
  }, [buildVersion])

  if (!newVersion) return null

  return (
    <div
      role="alert"
      style={{
        position: 'fixed',
        bottom: 20,
        right: 20,
        zIndex: 1000,
        backgroundColor: '#0D1B1A',
        color: '#E5E7EB',
        padding: '14px 18px',
        borderRadius: 8,
        boxShadow: '0 8px 24px rgba(0,0,0,0.25)',
        border: '1px solid #1D9E75',
        display: 'flex',
        alignItems: 'center',
        gap: 12,
        fontSize: 13,
        maxWidth: 360,
      }}
    >
      <div style={{ flex: 1 }}>
        <div style={{ fontWeight: 600, marginBottom: 2 }}>Nova versao disponivel</div>
        <div style={{ fontSize: 11, color: '#9CA3AF' }}>
          v{buildVersion} → v{newVersion}
        </div>
      </div>
      <button
        onClick={() => window.location.reload()}
        style={{
          backgroundColor: '#1D9E75',
          color: '#fff',
          border: 'none',
          padding: '6px 12px',
          borderRadius: 4,
          fontSize: 12,
          fontWeight: 500,
          cursor: 'pointer',
        }}
      >
        Actualizar
      </button>
    </div>
  )
}
