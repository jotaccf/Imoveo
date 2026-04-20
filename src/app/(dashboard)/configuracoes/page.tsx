'use client'

import { useEffect, useState } from 'react'
import { useSession } from 'next-auth/react'
import { ChevronDown, ChevronRight, RefreshCw } from 'lucide-react'
import { Card } from '@/components/ui/Card'
import { Input } from '@/components/ui/Input'
import { Button } from '@/components/ui/Button'
import type { Role } from '@/lib/permissions'

function CollapsibleSection({ title, subtitle, defaultOpen = false, children }: {
  title: string; subtitle?: string; defaultOpen?: boolean; children: React.ReactNode
}) {
  const [open, setOpen] = useState(defaultOpen)
  return (
    <Card>
      <button onClick={() => setOpen(!open)} className="w-full flex items-center gap-2 text-left">
        {open ? <ChevronDown size={16} style={{ color: '#6B7280' }} /> : <ChevronRight size={16} style={{ color: '#6B7280' }} />}
        <div className="flex-1">
          <h2 className="text-base font-semibold" style={{ color: '#0D1B1A' }}>{title}</h2>
          {subtitle && <p className="text-[11px] mt-0.5" style={{ color: '#9CA3AF' }}>{subtitle}</p>}
        </div>
      </button>
      {open && <div className="mt-4">{children}</div>}
    </Card>
  )
}

interface ConfigValues {
  derramaMunicipal: number
  regimePME: boolean
  taxaIrcPME: number
  taxaIrcNormal: number
  limitePME: number
  taxaRetencaoRendas: number
}

const defaultConfig: ConfigValues = {
  derramaMunicipal: 1.5,
  regimePME: true,
  taxaIrcPME: 17,
  taxaIrcNormal: 21,
  limitePME: 50000,
  taxaRetencaoRendas: 25,
}

interface FieldDef {
  key: keyof ConfigValues
  label: string
  description: string
  type: 'number' | 'toggle'
}

const fields: FieldDef[] = [
  { key: 'derramaMunicipal', label: 'Derrama Municipal (%)', description: 'Taxa de derrama municipal aplicada sobre a coleta de IRC', type: 'number' },
  { key: 'regimePME', label: 'Regime PME', description: 'Ativar regime de taxa reduzida para PME', type: 'toggle' },
  { key: 'taxaIrcPME', label: 'Taxa IRC PME (%)', description: 'Taxa reduzida de IRC aplicavel a PME ate ao limite definido', type: 'number' },
  { key: 'taxaIrcNormal', label: 'Taxa IRC Normal (%)', description: 'Taxa normal de IRC aplicavel acima do limite PME', type: 'number' },
  { key: 'limitePME', label: 'Limite PME (€)', description: 'Limite de materia coletavel sujeita a taxa reduzida PME', type: 'number' },
  { key: 'taxaRetencaoRendas', label: 'Taxa Retencao Rendas (%)', description: 'Taxa de retencao na fonte aplicada sobre rendas pagas', type: 'number' },
]

export default function ConfiguracoesPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role
  const [config, setConfig] = useState<ConfigValues>(defaultConfig)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [success, setSuccess] = useState(false)

  // Dados da empresa
  const [empresa, setEmpresa] = useState({
    empresa_nome: '', empresa_forma_juridica: '', empresa_morada: '',
    empresa_nipc: '', empresa_conservatoria: '', empresa_foro: '',
    limite_electricidade: '25',
  })
  const [empresaSaving, setEmpresaSaving] = useState(false)
  const [empresaSuccess, setEmpresaSuccess] = useState(false)

  // Sistema / Versao
  const [versionInfo, setVersionInfo] = useState<{
    currentVersion: string; latestVersion: string; updateAvailable: boolean
    releaseUrl: string; releaseDate: string
  } | null>(null)
  const [versionChecking, setVersionChecking] = useState(false)
  const [lastChecked, setLastChecked] = useState<Date | null>(null)
  const [updating, setUpdating] = useState(false)
  const [updateMessage, setUpdateMessage] = useState<string | null>(null)

  async function checkVersion() {
    setVersionChecking(true)
    setUpdateMessage(null)
    try {
      const res = await fetch('/api/admin/version', { cache: 'no-store' })
      const j = await res.json()
      if (j.data) setVersionInfo(j.data)
      setLastChecked(new Date())
    } catch { setUpdateMessage('Erro ao verificar versao') }
    finally { setVersionChecking(false) }
  }

  async function handleUpdate() {
    if (!confirm('Tem a certeza que pretende actualizar?\n\nO sistema entra em modo de manutencao e todos os utilizadores serao redirecionados.')) return
    setUpdating(true)
    setUpdateMessage(null)
    try {
      const res = await fetch('/api/admin/update', { method: 'POST' })
      const j = await res.json()
      setUpdateMessage(j.message || j.error || 'Update iniciado')
    } catch { setUpdateMessage('Erro ao iniciar actualizacao') }
    finally { setUpdating(false) }
  }

  // Tailscale
  const [tsStatus, setTsStatus] = useState<{
    installed: boolean; connected?: boolean; status: string;
    ip?: string; hostname?: string; version?: string
  } | null>(null)
  const [tsAuthKey, setTsAuthKey] = useState('')
  const [tsConnecting, setTsConnecting] = useState(false)
  const [tsMessage, setTsMessage] = useState<string | null>(null)

  useEffect(() => {
    fetch('/api/configuracoes')
      .then((r) => r.json())
      .then((j) => {
        if (j.data) {
          setConfig({ ...defaultConfig, ...j.data })
          // Preencher empresa a partir das configs
          setEmpresa((prev) => {
            const e = { ...prev }
            for (const k of Object.keys(e) as (keyof typeof e)[]) {
              if (j.data[k] !== undefined) e[k] = String(j.data[k])
            }
            return e
          })
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    fetch('/api/admin/tailscale')
      .then((r) => r.json())
      .then((j) => { if (j.data) setTsStatus(j.data) })
      .catch(() => {})
  }, [])

  if (role !== 'ADMIN') {
    return <div className="text-sm text-gray-400">Acesso restrito a administradores.</div>
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  async function handleTsConnect() {
    if (!tsAuthKey) return
    setTsConnecting(true)
    setTsMessage(null)
    try {
      const res = await fetch('/api/admin/tailscale', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ authKey: tsAuthKey }),
      })
      const j = await res.json()
      if (res.ok) {
        setTsMessage(`Conectado! IP: ${j.ip}`)
        setTsAuthKey('')
        // Refresh status
        fetch('/api/admin/tailscale').then(r => r.json()).then(j => { if (j.data) setTsStatus(j.data) }).catch(() => {})
      } else {
        setTsMessage(`Erro: ${j.error}`)
      }
    } catch (e) { setTsMessage(`Erro: ${e}`) }
    finally { setTsConnecting(false) }
  }

  async function handleTsDisconnect() {
    if (!confirm('Desconectar Tailscale?')) return
    await fetch('/api/admin/tailscale', { method: 'DELETE' }).catch(() => {})
    setTsStatus({ installed: true, connected: false, status: 'Desconectado' })
    setTsMessage(null)
  }

  async function handleSaveEmpresa() {
    setEmpresaSaving(true)
    setEmpresaSuccess(false)
    try {
      const res = await fetch('/api/configuracoes', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ configs: empresa }),
      })
      if (res.ok) setEmpresaSuccess(true)
    } catch { /* ignore */ }
    finally { setEmpresaSaving(false) }
  }

  function handleChange(key: keyof ConfigValues, value: number | boolean) {
    setConfig((prev) => ({ ...prev, [key]: value }))
    setSuccess(false)
  }

  async function handleSave() {
    setSaving(true)
    setSuccess(false)
    try {
      const res = await fetch('/api/configuracoes', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ configs: config }),
      })
      if (res.ok) setSuccess(true)
    } catch {
      // ignore
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="space-y-4">
      {/* Sistema / Actualizacoes */}
      <CollapsibleSection title="Sistema" subtitle="Versao instalada e actualizacoes" defaultOpen={true}>
        <div className="space-y-4">
          {/* Versao actual */}
          <div className="flex items-center justify-between flex-wrap gap-3">
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium" style={{ color: '#0D1B1A' }}>Versao instalada:</span>
              <span className="text-xs font-mono px-2.5 py-0.5 rounded-full" style={{ backgroundColor: '#E1F5EE', color: '#0F6E56' }}>
                v{versionInfo?.currentVersion || '...'}
              </span>
            </div>
            <div className="flex items-center gap-3">
              {lastChecked && (
                <span className="text-[11px]" style={{ color: '#9CA3AF' }}>
                  Verificado: {lastChecked.toLocaleTimeString('pt-PT', { hour: '2-digit', minute: '2-digit' })}
                </span>
              )}
              <button
                onClick={checkVersion}
                disabled={versionChecking}
                className="flex items-center gap-1.5 text-[12px] px-3 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors disabled:opacity-50"
                style={{ color: '#6B7280' }}
              >
                <RefreshCw size={13} className={versionChecking ? 'animate-spin' : ''} />
                {versionChecking ? 'A verificar...' : 'Verificar actualizacoes'}
              </button>
            </div>
          </div>

          {/* Resultado da verificacao */}
          {versionInfo && (
            <div className="rounded-lg px-4 py-3 text-sm" style={{
              backgroundColor: versionInfo.updateAvailable ? '#FAEEDA' : '#E1F5EE',
              color: versionInfo.updateAvailable ? '#633806' : '#0F6E56',
            }}>
              {versionInfo.updateAvailable ? (
                <div className="flex items-center justify-between flex-wrap gap-3">
                  <div>
                    <span className="font-medium">Nova versao disponivel: v{versionInfo.latestVersion}</span>
                    {versionInfo.releaseDate && (
                      <span className="ml-2 text-[12px] opacity-75">
                        ({new Date(versionInfo.releaseDate).toLocaleDateString('pt-PT')})
                      </span>
                    )}
                  </div>
                  <Button onClick={handleUpdate} disabled={updating}>
                    {updating ? 'A actualizar...' : 'Actualizar agora'}
                  </Button>
                </div>
              ) : (
                <span>Sistema actualizado — v{versionInfo.currentVersion} e a versao mais recente</span>
              )}
            </div>
          )}

          {/* Mensagem de feedback */}
          {updateMessage && (
            <div className="rounded-lg px-4 py-3 text-[12px]" style={{
              backgroundColor: updateMessage.includes('Erro') ? '#FCEBEB' : '#E1F5EE',
              color: updateMessage.includes('Erro') ? '#A32D2D' : '#0F6E56',
            }}>
              {updateMessage}
            </div>
          )}
        </div>
      </CollapsibleSection>

      {/* Dados da Empresa */}
      <CollapsibleSection title="Dados da Empresa" subtitle="Utilizados na geracao de contratos PDF (Primeira Outorgante)" defaultOpen={false}>
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <Input label="Denominacao social" value={empresa.empresa_nome} onChange={(e) => setEmpresa({ ...empresa, empresa_nome: e.target.value })} placeholder="EXPOENTE HISTORICO - UNIPESSOAL, LDA." />
            <Input label="Forma juridica" value={empresa.empresa_forma_juridica} onChange={(e) => setEmpresa({ ...empresa, empresa_forma_juridica: e.target.value })} placeholder="sociedade unipessoal por quotas" />
          </div>
          <Input label="Morada sede" value={empresa.empresa_morada} onChange={(e) => setEmpresa({ ...empresa, empresa_morada: e.target.value })} placeholder="Rua do Paco, 694, 4765-597 Guimaraes" />
          <div className="grid grid-cols-3 gap-3">
            <Input label="NIPC" value={empresa.empresa_nipc} onChange={(e) => setEmpresa({ ...empresa, empresa_nipc: e.target.value })} placeholder="515979503" />
            <Input label="Conservatoria RC" value={empresa.empresa_conservatoria} onChange={(e) => setEmpresa({ ...empresa, empresa_conservatoria: e.target.value })} placeholder="Conservatoria do Registo Comercial" />
            <Input label="Foro competente" value={empresa.empresa_foro} onChange={(e) => setEmpresa({ ...empresa, empresa_foro: e.target.value })} placeholder="Guimaraes" />
          </div>
          <div className="max-w-xs">
            <Input label="Limite electricidade/quarto (EUR)" type="number" value={empresa.limite_electricidade} onChange={(e) => setEmpresa({ ...empresa, limite_electricidade: e.target.value })} />
          </div>
        </div>

        <div className="mt-4 flex items-center gap-3">
          <Button onClick={handleSaveEmpresa} disabled={empresaSaving}>
            {empresaSaving ? 'A guardar...' : 'Guardar dados empresa'}
          </Button>
          {empresaSuccess && (
            <span className="text-sm" style={{ color: '#0F6E56' }}>Dados da empresa guardados.</span>
          )}
        </div>
      </CollapsibleSection>

      {/* Tailscale VPN */}
      {tsStatus && (
        <CollapsibleSection title="Tailscale VPN" subtitle="Acesso remoto seguro ao servidor via Tailscale" defaultOpen={false}>

          {/* Estado */}
          <div className="flex items-center gap-3 mb-4">
            <div className="w-3 h-3 rounded-full" style={{ backgroundColor: tsStatus.connected ? '#1D9E75' : '#A32D2D' }} />
            <span className="text-sm font-medium" style={{ color: tsStatus.connected ? '#0F6E56' : '#A32D2D' }}>
              {tsStatus.status}
            </span>
            {tsStatus.ip && <span className="text-[12px]" style={{ color: '#6B7280' }}>IP: {tsStatus.ip}</span>}
            {tsStatus.hostname && <span className="text-[12px]" style={{ color: '#6B7280' }}>Host: {tsStatus.hostname}</span>}
            {tsStatus.version && <span className="text-[12px]" style={{ color: '#9CA3AF' }}>v{tsStatus.version}</span>}
          </div>

          {!tsStatus.installed ? (
            <div className="text-[12px] px-3 py-2 rounded" style={{ backgroundColor: '#FAEEDA', color: '#633806' }}>
              Tailscale nao instalado. Execute no servidor: <code className="font-mono">curl -fsSL https://tailscale.com/install.sh | sh</code>
            </div>
          ) : !tsStatus.connected ? (
            <div className="space-y-3">
              <div className="text-[12px]" style={{ color: '#6B7280' }}>
                1. Aceda a <a href="https://login.tailscale.com/admin/settings/keys" target="_blank" rel="noopener noreferrer" className="underline" style={{ color: '#0C447C' }}>login.tailscale.com/admin/settings/keys</a><br />
                2. Gere um auth key (single-use)<br />
                3. Cole abaixo e clique Conectar
              </div>
              <div className="flex gap-2 max-w-lg">
                <Input
                  placeholder="tskey-auth-..."
                  value={tsAuthKey}
                  onChange={(e) => setTsAuthKey(e.target.value)}
                />
                <Button onClick={handleTsConnect} disabled={tsConnecting || !tsAuthKey}>
                  {tsConnecting ? 'A conectar...' : 'Conectar'}
                </Button>
              </div>
            </div>
          ) : (
            <Button variant="secondary" onClick={handleTsDisconnect}>
              Desconectar
            </Button>
          )}

          {tsMessage && (
            <div className="mt-3 text-[12px] px-3 py-2 rounded" style={{
              backgroundColor: tsMessage.startsWith('Conectado') ? '#E1F5EE' : '#FCEBEB',
              color: tsMessage.startsWith('Conectado') ? '#0F6E56' : '#A32D2D',
            }}>
              {tsMessage}
            </div>
          )}
        </CollapsibleSection>
      )}

      {/* Configuracoes Fiscais */}
      <CollapsibleSection title="Configuracoes Fiscais" defaultOpen={true}>
        <div className="space-y-5">
          {fields.map((field) => (
            <div key={field.key}>
              {field.type === 'toggle' ? (
                <div className="flex items-center gap-3">
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={String(config[field.key]) === 'true'}
                      onChange={(e) => handleChange(field.key, e.target.checked)}
                      className="w-4 h-4 rounded border-gray-300 accent-brand-primary"
                    />
                    <span className="text-sm font-medium" style={{ color: '#0D1B1A' }}>
                      {field.label}
                    </span>
                  </label>
                  <div className="text-[11px]" style={{ color: '#9CA3AF' }}>
                    {field.description}
                  </div>
                </div>
              ) : (
                <div className="max-w-xs">
                  <Input
                    label={field.label}
                    type="number"
                    step="0.01"
                    value={config[field.key] as number}
                    onChange={(e) => handleChange(field.key, parseFloat(e.target.value) || 0)}
                  />
                  <div className="text-[11px] mt-1" style={{ color: '#9CA3AF' }}>
                    {field.description}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>

        <div className="mt-6 flex items-center gap-3">
          <Button onClick={handleSave} disabled={saving}>
            {saving ? 'A guardar...' : 'Guardar configuracoes'}
          </Button>
          {success && (
            <span className="text-sm" style={{ color: '#0F6E56' }}>
              Configuracoes guardadas com sucesso.
            </span>
          )}
        </div>
      </CollapsibleSection>
    </div>
  )
}
