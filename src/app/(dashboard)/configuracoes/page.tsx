'use client'

import { useEffect, useState } from 'react'
import { useSession } from 'next-auth/react'
import { Card } from '@/components/ui/Card'
import { Input } from '@/components/ui/Input'
import { Button } from '@/components/ui/Button'
import type { Role } from '@/lib/permissions'

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

  if (role !== 'ADMIN') {
    return <div className="text-sm text-gray-400">Acesso restrito a administradores.</div>
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

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
      {/* Dados da Empresa */}
      <Card>
        <h2 className="text-base font-semibold mb-1" style={{ color: '#0D1B1A' }}>
          Dados da Empresa
        </h2>
        <p className="text-[11px] mb-4" style={{ color: '#9CA3AF' }}>
          Utilizados na geracao de contratos PDF (Primeira Outorgante)
        </p>

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
      </Card>

      {/* Configuracoes Fiscais */}
      <Card>
        <h2 className="text-base font-semibold mb-4" style={{ color: '#0D1B1A' }}>
          Configuracoes Fiscais
        </h2>

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
                      className="w-4 h-4 rounded border-gray-300 accent-[#1D9E75]"
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
      </Card>
    </div>
  )
}
