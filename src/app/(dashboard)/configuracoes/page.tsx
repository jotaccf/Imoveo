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

      {/* Configuracoes Fiscais por Ano */}
      <CollapsibleSection title="Configuracoes Fiscais" subtitle="Taxas de IRC, derrama, retencao e reporte de prejuizos por ano fiscal" defaultOpen={true}>
        <ConfigFiscaisAno />
      </CollapsibleSection>

      {/* Rubricas e dedutibilidade fiscal */}
      <CollapsibleSection title="Rubricas — dedutibilidade fiscal" subtitle="Marca quais rubricas sao acrescidas ao lucro tributavel (multas, IRC, donativos, ofertas excessivas, etc.)">
        <RubricasDedutibilidade />
      </CollapsibleSection>
    </div>
  )
}

// ============================================================
//  Configuracoes Fiscais por Ano
// ============================================================

interface ConfigFiscal {
  ano: number
  taxaIrcPme: string
  taxaIrcNormal: string
  limitePme: string
  derramaMunicipal: string
  taxaRetencao: string
  reportePrejuizoPct: string
  regimePme: boolean
  // TA
  taTaxaComBaixa?: string; taTaxaComMedia?: string; taTaxaComAlta?: string
  taTaxaHibBaixa?: string; taTaxaHibMedia?: string; taTaxaHibAlta?: string
  taTaxaGplBaixa?: string; taTaxaGplMedia?: string; taTaxaGplAlta?: string
  taTaxaElectrica?: string
  taLimiteElectricoIsento?: string
  taLimiteViaturaBaixa?: string; taLimiteViaturaAlta?: string
  limiteDeducaoCombustao?: string; limiteDeducaoGpl?: string
  limiteDeducaoHibrido?: string; limiteDeducaoElectrico?: string
  taTaxaRepresentacao?: string; taTaxaNaoDocumentadas?: string
  taAgravamentoPrejuizoPp?: string
}

const emptyFiscalForm = {
  ano: new Date().getFullYear(),
  taxaIrcPme: 15,
  taxaIrcNormal: 19,
  limitePme: 50000,
  derramaMunicipal: 1.5,
  taxaRetencao: 25,
  reportePrejuizoPct: 65,
  regimePme: true,
  // Tributacao Autonoma — defaults OE 2026
  taTaxaComBaixa: 10, taTaxaComMedia: 27.5, taTaxaComAlta: 35,
  taTaxaHibBaixa: 5, taTaxaHibMedia: 10, taTaxaHibAlta: 17.5,
  taTaxaGplBaixa: 7.5, taTaxaGplMedia: 15, taTaxaGplAlta: 27.5,
  taTaxaElectrica: 10,
  taLimiteElectricoIsento: 62500,
  taLimiteViaturaBaixa: 27500, taLimiteViaturaAlta: 35000,
  limiteDeducaoCombustao: 30000, limiteDeducaoGpl: 37500,
  limiteDeducaoHibrido: 50000, limiteDeducaoElectrico: 62500,
  taTaxaRepresentacao: 10, taTaxaNaoDocumentadas: 50,
  taAgravamentoPrejuizoPp: 10,
}

function ConfigFiscaisAno() {
  const [configs, setConfigs] = useState<ConfigFiscal[]>([])
  const [loading, setLoading] = useState(true)
  const [editingAno, setEditingAno] = useState<number | null>(null)
  const [creating, setCreating] = useState(false)
  const [form, setForm] = useState(emptyFiscalForm)
  const [saving, setSaving] = useState(false)

  function fetchConfigs() {
    setLoading(true)
    fetch('/api/configuracoes-fiscais')
      .then((r) => r.json())
      .then((j) => { if (j.data) setConfigs(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetchConfigs() }, [])

  function configToForm(c: ConfigFiscal | null): typeof emptyFiscalForm {
    const n = (v: string | undefined, fallback: number) => v !== undefined ? Number(v) : fallback
    return {
      ano: c?.ano ?? new Date().getFullYear(),
      taxaIrcPme: c ? Number(c.taxaIrcPme) : emptyFiscalForm.taxaIrcPme,
      taxaIrcNormal: c ? Number(c.taxaIrcNormal) : emptyFiscalForm.taxaIrcNormal,
      limitePme: c ? Number(c.limitePme) : emptyFiscalForm.limitePme,
      derramaMunicipal: c ? Number(c.derramaMunicipal) : emptyFiscalForm.derramaMunicipal,
      taxaRetencao: c ? Number(c.taxaRetencao) : emptyFiscalForm.taxaRetencao,
      reportePrejuizoPct: c ? Number(c.reportePrejuizoPct) : emptyFiscalForm.reportePrejuizoPct,
      regimePme: c ? c.regimePme : emptyFiscalForm.regimePme,
      taTaxaComBaixa: n(c?.taTaxaComBaixa, emptyFiscalForm.taTaxaComBaixa),
      taTaxaComMedia: n(c?.taTaxaComMedia, emptyFiscalForm.taTaxaComMedia),
      taTaxaComAlta: n(c?.taTaxaComAlta, emptyFiscalForm.taTaxaComAlta),
      taTaxaHibBaixa: n(c?.taTaxaHibBaixa, emptyFiscalForm.taTaxaHibBaixa),
      taTaxaHibMedia: n(c?.taTaxaHibMedia, emptyFiscalForm.taTaxaHibMedia),
      taTaxaHibAlta: n(c?.taTaxaHibAlta, emptyFiscalForm.taTaxaHibAlta),
      taTaxaGplBaixa: n(c?.taTaxaGplBaixa, emptyFiscalForm.taTaxaGplBaixa),
      taTaxaGplMedia: n(c?.taTaxaGplMedia, emptyFiscalForm.taTaxaGplMedia),
      taTaxaGplAlta: n(c?.taTaxaGplAlta, emptyFiscalForm.taTaxaGplAlta),
      taTaxaElectrica: n(c?.taTaxaElectrica, emptyFiscalForm.taTaxaElectrica),
      taLimiteElectricoIsento: n(c?.taLimiteElectricoIsento, emptyFiscalForm.taLimiteElectricoIsento),
      taLimiteViaturaBaixa: n(c?.taLimiteViaturaBaixa, emptyFiscalForm.taLimiteViaturaBaixa),
      taLimiteViaturaAlta: n(c?.taLimiteViaturaAlta, emptyFiscalForm.taLimiteViaturaAlta),
      limiteDeducaoCombustao: n(c?.limiteDeducaoCombustao, emptyFiscalForm.limiteDeducaoCombustao),
      limiteDeducaoGpl: n(c?.limiteDeducaoGpl, emptyFiscalForm.limiteDeducaoGpl),
      limiteDeducaoHibrido: n(c?.limiteDeducaoHibrido, emptyFiscalForm.limiteDeducaoHibrido),
      limiteDeducaoElectrico: n(c?.limiteDeducaoElectrico, emptyFiscalForm.limiteDeducaoElectrico),
      taTaxaRepresentacao: n(c?.taTaxaRepresentacao, emptyFiscalForm.taTaxaRepresentacao),
      taTaxaNaoDocumentadas: n(c?.taTaxaNaoDocumentadas, emptyFiscalForm.taTaxaNaoDocumentadas),
      taAgravamentoPrejuizoPp: n(c?.taAgravamentoPrejuizoPp, emptyFiscalForm.taAgravamentoPrejuizoPp),
    }
  }

  function startEdit(c: ConfigFiscal) {
    setForm(configToForm(c))
    setEditingAno(c.ano)
    setCreating(false)
  }

  function startCreate() {
    const ultimaConfig = configs[0]
    const base = configToForm(ultimaConfig ?? null)
    base.ano = (ultimaConfig?.ano ?? new Date().getFullYear()) + 1
    setForm(base)
    setCreating(true)
    setEditingAno(null)
  }

  async function handleSave() {
    setSaving(true)
    await fetch('/api/configuracoes-fiscais', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    })
    setSaving(false)
    setEditingAno(null)
    setCreating(false)
    fetchConfigs()
  }

  async function handleDelete(ano: number) {
    if (!confirm(`Remover configuracao fiscal para ${ano}?`)) return
    await fetch(`/api/configuracoes-fiscais/${ano}`, { method: 'DELETE' })
    fetchConfigs()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <Button onClick={startCreate}>Adicionar ano</Button>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="text-[11px] uppercase" style={{ color: '#6B7280' }}>
            <tr className="border-b border-gray-100">
              <th className="text-left py-2 px-3">Ano</th>
              <th className="text-right py-2 px-3">IRC PME %</th>
              <th className="text-right py-2 px-3">IRC Normal %</th>
              <th className="text-right py-2 px-3">Limite PME €</th>
              <th className="text-right py-2 px-3">Derrama %</th>
              <th className="text-right py-2 px-3">Retencao %</th>
              <th className="text-right py-2 px-3">Prejuizos %</th>
              <th className="py-2 px-3"></th>
            </tr>
          </thead>
          <tbody>
            {configs.map((c) => (
              <tr key={c.ano} className="border-b border-gray-50">
                <td className="py-2 px-3 font-medium">{c.ano}</td>
                <td className="py-2 px-3 text-right">{Number(c.taxaIrcPme).toFixed(2)}</td>
                <td className="py-2 px-3 text-right">{Number(c.taxaIrcNormal).toFixed(2)}</td>
                <td className="py-2 px-3 text-right">{Number(c.limitePme).toLocaleString('pt-PT')}</td>
                <td className="py-2 px-3 text-right">{Number(c.derramaMunicipal).toFixed(2)}</td>
                <td className="py-2 px-3 text-right">{Number(c.taxaRetencao).toFixed(2)}</td>
                <td className="py-2 px-3 text-right">{Number(c.reportePrejuizoPct).toFixed(0)}</td>
                <td className="py-2 px-3 text-right">
                  <button onClick={() => startEdit(c)} className="text-[12px] text-brand-primary hover:underline mr-3">Editar</button>
                  <button onClick={() => handleDelete(c.ano)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                </td>
              </tr>
            ))}
            {configs.length === 0 && (
              <tr><td colSpan={8} className="text-center py-4 text-gray-400">Sem configuracoes</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {(editingAno !== null || creating) && (
        <Card className="bg-gray-50">
          <h3 className="text-sm font-semibold mb-3" style={{ color: '#0D1B1A' }}>
            {creating ? 'Nova configuracao' : `Editar configuracao ${editingAno}`}
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            <Input label="Ano" type="number" value={form.ano} disabled={!creating} onChange={(e) => setForm({ ...form, ano: parseInt(e.target.value) || 0 })} />
            <Input label="Taxa IRC PME (%)" type="number" step="0.01" value={form.taxaIrcPme} onChange={(e) => setForm({ ...form, taxaIrcPme: parseFloat(e.target.value) || 0 })} />
            <Input label="Taxa IRC Normal (%)" type="number" step="0.01" value={form.taxaIrcNormal} onChange={(e) => setForm({ ...form, taxaIrcNormal: parseFloat(e.target.value) || 0 })} />
            <Input label="Limite PME (€)" type="number" step="100" value={form.limitePme} onChange={(e) => setForm({ ...form, limitePme: parseFloat(e.target.value) || 0 })} />
            <Input label="Derrama Municipal (%)" type="number" step="0.01" value={form.derramaMunicipal} onChange={(e) => setForm({ ...form, derramaMunicipal: parseFloat(e.target.value) || 0 })} />
            <Input label="Taxa Retencao (%)" type="number" step="0.01" value={form.taxaRetencao} onChange={(e) => setForm({ ...form, taxaRetencao: parseFloat(e.target.value) || 0 })} />
            <Input label="Reporte Prejuizos (%)" type="number" step="0.01" value={form.reportePrejuizoPct} onChange={(e) => setForm({ ...form, reportePrejuizoPct: parseFloat(e.target.value) || 0 })} />
            <label className="flex items-center gap-2 cursor-pointer self-end pb-2">
              <input type="checkbox" checked={form.regimePme} onChange={(e) => setForm({ ...form, regimePme: e.target.checked })} className="w-4 h-4 rounded accent-brand-primary" />
              <span className="text-sm">Regime PME</span>
            </label>
          </div>

          <h4 className="text-xs font-semibold mt-5 mb-2 uppercase tracking-wide text-gray-600">Tributacao Autonoma (viaturas)</h4>
          <p className="text-[11px] text-gray-500 mb-2">Tier por valor de aquisicao: Baixa &lt; {form.taLimiteViaturaBaixa.toLocaleString('pt-PT')} | Media &lt; {form.taLimiteViaturaAlta.toLocaleString('pt-PT')} | Alta &ge; {form.taLimiteViaturaAlta.toLocaleString('pt-PT')}</p>
          <div className="grid grid-cols-3 gap-2">
            <Input label="Combustao Baixa %" type="number" step="0.01" value={form.taTaxaComBaixa} onChange={(e) => setForm({ ...form, taTaxaComBaixa: parseFloat(e.target.value) || 0 })} />
            <Input label="Combustao Media %" type="number" step="0.01" value={form.taTaxaComMedia} onChange={(e) => setForm({ ...form, taTaxaComMedia: parseFloat(e.target.value) || 0 })} />
            <Input label="Combustao Alta %" type="number" step="0.01" value={form.taTaxaComAlta} onChange={(e) => setForm({ ...form, taTaxaComAlta: parseFloat(e.target.value) || 0 })} />
            <Input label="Hibrido PI Baixa %" type="number" step="0.01" value={form.taTaxaHibBaixa} onChange={(e) => setForm({ ...form, taTaxaHibBaixa: parseFloat(e.target.value) || 0 })} />
            <Input label="Hibrido PI Media %" type="number" step="0.01" value={form.taTaxaHibMedia} onChange={(e) => setForm({ ...form, taTaxaHibMedia: parseFloat(e.target.value) || 0 })} />
            <Input label="Hibrido PI Alta %" type="number" step="0.01" value={form.taTaxaHibAlta} onChange={(e) => setForm({ ...form, taTaxaHibAlta: parseFloat(e.target.value) || 0 })} />
            <Input label="GPL/GNV Baixa %" type="number" step="0.01" value={form.taTaxaGplBaixa} onChange={(e) => setForm({ ...form, taTaxaGplBaixa: parseFloat(e.target.value) || 0 })} />
            <Input label="GPL/GNV Media %" type="number" step="0.01" value={form.taTaxaGplMedia} onChange={(e) => setForm({ ...form, taTaxaGplMedia: parseFloat(e.target.value) || 0 })} />
            <Input label="GPL/GNV Alta %" type="number" step="0.01" value={form.taTaxaGplAlta} onChange={(e) => setForm({ ...form, taTaxaGplAlta: parseFloat(e.target.value) || 0 })} />
            <Input label="Electrico (acima isento) %" type="number" step="0.01" value={form.taTaxaElectrica} onChange={(e) => setForm({ ...form, taTaxaElectrica: parseFloat(e.target.value) || 0 })} />
            <Input label="Limite Electrico Isento €" type="number" step="100" value={form.taLimiteElectricoIsento} onChange={(e) => setForm({ ...form, taLimiteElectricoIsento: parseFloat(e.target.value) || 0 })} />
            <div />
            <Input label="Tier Baixa < €" type="number" step="100" value={form.taLimiteViaturaBaixa} onChange={(e) => setForm({ ...form, taLimiteViaturaBaixa: parseFloat(e.target.value) || 0 })} />
            <Input label="Tier Alta >= €" type="number" step="100" value={form.taLimiteViaturaAlta} onChange={(e) => setForm({ ...form, taLimiteViaturaAlta: parseFloat(e.target.value) || 0 })} />
          </div>

          <h4 className="text-xs font-semibold mt-5 mb-2 uppercase tracking-wide text-gray-600">Limites de dedutibilidade (art. 34.º CIRC)</h4>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
            <Input label="Combustao €" type="number" step="100" value={form.limiteDeducaoCombustao} onChange={(e) => setForm({ ...form, limiteDeducaoCombustao: parseFloat(e.target.value) || 0 })} />
            <Input label="GPL/GNV €" type="number" step="100" value={form.limiteDeducaoGpl} onChange={(e) => setForm({ ...form, limiteDeducaoGpl: parseFloat(e.target.value) || 0 })} />
            <Input label="Hibrido €" type="number" step="100" value={form.limiteDeducaoHibrido} onChange={(e) => setForm({ ...form, limiteDeducaoHibrido: parseFloat(e.target.value) || 0 })} />
            <Input label="Electrico €" type="number" step="100" value={form.limiteDeducaoElectrico} onChange={(e) => setForm({ ...form, limiteDeducaoElectrico: parseFloat(e.target.value) || 0 })} />
          </div>

          <h4 className="text-xs font-semibold mt-5 mb-2 uppercase tracking-wide text-gray-600">Outras tributacoes autonomas</h4>
          <div className="grid grid-cols-3 gap-2">
            <Input label="Representacao %" type="number" step="0.01" value={form.taTaxaRepresentacao} onChange={(e) => setForm({ ...form, taTaxaRepresentacao: parseFloat(e.target.value) || 0 })} />
            <Input label="Nao documentadas %" type="number" step="0.01" value={form.taTaxaNaoDocumentadas} onChange={(e) => setForm({ ...form, taTaxaNaoDocumentadas: parseFloat(e.target.value) || 0 })} />
            <Input label="Agravamento prejuizo %" type="number" step="0.01" value={form.taAgravamentoPrejuizoPp} onChange={(e) => setForm({ ...form, taAgravamentoPrejuizoPp: parseFloat(e.target.value) || 0 })} />
          </div>

          <div className="mt-4 flex gap-2">
            <Button onClick={handleSave} disabled={saving}>{saving ? 'A guardar...' : 'Guardar'}</Button>
            <Button variant="ghost" onClick={() => { setEditingAno(null); setCreating(false) }}>Cancelar</Button>
          </div>
        </Card>
      )}

      <p className="text-[11px]" style={{ color: '#9CA3AF' }}>
        As taxas aplicam-se ao ano correspondente. Se um ano nao tiver configuracao, e usado o ano anterior mais proximo.
        Reporte de Prejuizos: percentagem maxima do lucro tributavel que pode ser deduzida por prejuizos de anos anteriores (Art. 52.º CIRC, default 65%).
      </p>
    </div>
  )
}

// ============================================================
//  Rubricas — dedutibilidade fiscal
// ============================================================

interface Rubrica {
  id: string
  codigo: string
  nome: string
  tipo: 'RECEITA' | 'GASTO'
  dedutivel: boolean
}

function RubricasDedutibilidade() {
  const [rubricas, setRubricas] = useState<Rubrica[]>([])
  const [loading, setLoading] = useState(true)

  function fetchRubricas() {
    setLoading(true)
    fetch('/api/rubricas')
      .then((r) => r.json())
      .then((j) => { if (j.data) setRubricas(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetchRubricas() }, [])

  async function toggleDedutivel(r: Rubrica) {
    // Optimistic update
    setRubricas((prev) => prev.map((x) => x.id === r.id ? { ...x, dedutivel: !x.dedutivel } : x))
    const res = await fetch(`/api/rubricas/${r.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dedutivel: !r.dedutivel }),
    })
    if (!res.ok) fetchRubricas()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  const gastos = rubricas.filter((r) => r.tipo === 'GASTO')
  const naoDedutiveis = gastos.filter((r) => !r.dedutivel)

  return (
    <div className="space-y-3">
      <p className="text-[12px] text-gray-500">
        Rubricas marcadas como <span className="font-medium text-[#A32D2D]">nao dedutiveis</span> sao automaticamente acrescidas ao lucro tributavel no calculo do IRC.
        Exemplos tipicos: multas, IRC pago, donativos, ofertas excessivas.
      </p>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="text-[11px] uppercase" style={{ color: '#6B7280' }}>
            <tr className="border-b border-gray-100">
              <th className="text-left py-2 px-3">Codigo</th>
              <th className="text-left py-2 px-3">Nome</th>
              <th className="text-center py-2 px-3">Dedutivel</th>
            </tr>
          </thead>
          <tbody>
            {gastos.map((r) => (
              <tr key={r.id} className="border-b border-gray-50">
                <td className="py-2 px-3 font-mono text-[11px]">{r.codigo}</td>
                <td className="py-2 px-3">{r.nome}</td>
                <td className="py-2 px-3 text-center">
                  <label className="inline-flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={r.dedutivel ?? true}
                      onChange={() => toggleDedutivel(r)}
                      className="w-4 h-4 rounded accent-brand-primary"
                    />
                    <span className={`text-[11px] ${(r.dedutivel ?? true) ? 'text-[#0F6E56]' : 'text-[#A32D2D]'}`}>
                      {(r.dedutivel ?? true) ? 'Dedutivel' : 'Nao dedutivel'}
                    </span>
                  </label>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {naoDedutiveis.length > 0 && (
        <p className="text-[11px] text-gray-500 pt-1">
          {naoDedutiveis.length} rubrica{naoDedutiveis.length !== 1 ? 's' : ''} marcadas como nao dedutiveis: {naoDedutiveis.map((r) => r.codigo).join(', ')}
        </p>
      )}
    </div>
  )
}
