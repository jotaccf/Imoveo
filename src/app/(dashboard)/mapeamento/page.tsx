'use client'

import { useEffect, useState, useCallback } from 'react'
import { useSession } from 'next-auth/react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Badge } from '@/components/ui/Badge'
import { Modal } from '@/components/ui/Modal'
import { hasPermission, type Role } from '@/lib/permissions'
import { Trash2, Plus } from 'lucide-react'

interface NifMap {
  id: string
  nifEntidade: string
  imovelId: string | null
  rubricaId: string
  entidade: { nif: string; nome: string } | null
  imovel: { id: string; nome: string; codigo: string } | null
  rubrica: { id: string; nome: string }
}

interface Template {
  id: string
  nifEntidade: string
  rubricaId: string
  tipo: 'IGUAL' | 'PERCENTAGEM' | 'MANUAL'
  nome: string | null
  entidade: { nif: string; nome: string }
  rubrica: { id: string; nome: string }
  linhas: { id: string; imovelId: string; percentagem: string | null; imovel: { id: string; nome: string; codigo: string } }[]
}

interface ImovelOption { id: string; nome: string; codigo: string }
interface RubricaOption { id: string; nome: string }

type Tab = 'regras' | 'templates'

const emptyRuleForm = { nifEntidade: '', nomeEntidade: '', imovelId: '', rubricaId: '' }

interface TemplateLinhaForm { imovelId: string; percentagem: number }
interface TemplateForm {
  nifEntidade: string
  nomeEntidade: string
  rubricaId: string
  tipo: 'IGUAL' | 'PERCENTAGEM' | 'MANUAL'
  nome: string
  linhas: TemplateLinhaForm[]
}
const emptyTemplateForm: TemplateForm = { nifEntidade: '', nomeEntidade: '', rubricaId: '', tipo: 'IGUAL', nome: '', linhas: [{ imovelId: '', percentagem: 0 }] }

export default function MapeamentoPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role

  const [tab, setTab] = useState<Tab>('regras')
  const [maps, setMaps] = useState<NifMap[]>([])
  const [templates, setTemplates] = useState<Template[]>([])
  const [imoveis, setImoveis] = useState<ImovelOption[]>([])
  const [rubricas, setRubricas] = useState<RubricaOption[]>([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)

  // Rule modal
  const [ruleModalOpen, setRuleModalOpen] = useState(false)
  const [ruleEditId, setRuleEditId] = useState<string | null>(null)
  const [ruleForm, setRuleForm] = useState(emptyRuleForm)

  // Template modal
  const [templateModalOpen, setTemplateModalOpen] = useState(false)
  const [templateEditId, setTemplateEditId] = useState<string | null>(null)
  const [templateForm, setTemplateForm] = useState<TemplateForm>(emptyTemplateForm)

  const canEdit = role ? hasPermission(role, 'mapeamento:editar') : false

  const fetchData = useCallback(() => {
    Promise.all([
      fetch('/api/mapeamento').then((r) => r.json()),
      fetch('/api/distribuicao').then((r) => r.json()),
    ]).then(([mRes, dRes]) => {
      if (mRes.data) setMaps(mRes.data)
      if (dRes.data) setTemplates(dRes.data)
    }).catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => { fetchData() }, [fetchData])

  useEffect(() => {
    fetch('/api/opcoes').then((r) => r.json()).then((j) => {
      if (j.data) {
        setImoveis(j.data.imoveis)
        setRubricas(j.data.rubricas)
      }
    }).catch(() => {})
  }, [])

  // ── Regras ──

  async function handleRemoveRule(id: string) {
    if (!confirm('Remover este mapeamento?')) return
    await fetch(`/api/mapeamento/${id}`, { method: 'DELETE' })
    fetchData()
  }

  function openCreateRule() {
    setRuleEditId(null)
    setRuleForm(emptyRuleForm)
    setRuleModalOpen(true)
  }

  function openEditRule(m: NifMap) {
    setRuleEditId(m.id)
    setRuleForm({
      nifEntidade: m.nifEntidade,
      nomeEntidade: m.entidade?.nome ?? '',
      imovelId: m.imovelId ?? '',
      rubricaId: m.rubricaId,
    })
    setRuleModalOpen(true)
  }

  async function handleSaveRule() {
    if (ruleEditId) {
      await fetch(`/api/mapeamento/${ruleEditId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ imovelId: ruleForm.imovelId || undefined, rubricaId: ruleForm.rubricaId }),
      })
    } else {
      await fetch('/api/mapeamento', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...ruleForm, imovelId: ruleForm.imovelId || undefined }),
      })
    }
    setRuleModalOpen(false)
    fetchData()
  }

  // ── Templates ──

  function openCreateTemplate() {
    setTemplateEditId(null)
    setTemplateForm(emptyTemplateForm)
    setTemplateModalOpen(true)
  }

  function openEditTemplate(t: Template) {
    setTemplateEditId(t.id)
    setTemplateForm({
      nifEntidade: t.nifEntidade,
      nomeEntidade: t.entidade.nome,
      rubricaId: t.rubricaId,
      tipo: t.tipo,
      nome: t.nome || '',
      linhas: t.linhas.map((l) => ({ imovelId: l.imovelId, percentagem: l.percentagem ? Number(l.percentagem) : 0 })),
    })
    setTemplateModalOpen(true)
  }

  async function handleSaveTemplate() {
    const payload = {
      nifEntidade: templateForm.nifEntidade,
      nomeEntidade: templateForm.nomeEntidade,
      rubricaId: templateForm.rubricaId,
      tipo: templateForm.tipo,
      nome: templateForm.nome || undefined,
      linhas: templateForm.linhas.filter((l) => l.imovelId),
    }
    if (templateEditId) {
      await fetch(`/api/distribuicao/${templateEditId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })
    } else {
      await fetch('/api/distribuicao', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })
    }
    setTemplateModalOpen(false)
    fetchData()
  }

  async function handleRemoveTemplate(id: string) {
    if (!confirm('Remover este template?')) return
    await fetch(`/api/distribuicao/${id}`, { method: 'DELETE' })
    fetchData()
  }

  function addTemplateLine() {
    setTemplateForm((prev) => ({ ...prev, linhas: [...prev.linhas, { imovelId: '', percentagem: 0 }] }))
  }

  function removeTemplateLine(i: number) {
    setTemplateForm((prev) => ({ ...prev, linhas: prev.linhas.filter((_, j) => j !== i) }))
  }

  function updateTemplateLine(i: number, field: keyof TemplateLinhaForm, value: string | number) {
    setTemplateForm((prev) => ({
      ...prev,
      linhas: prev.linhas.map((l, j) => j === i ? { ...l, [field]: value } : l),
    }))
  }

  // ── Filtro ──

  const filteredMaps = maps.filter((m) =>
    !search ||
    m.nifEntidade.includes(search) ||
    (m.entidade?.nome ?? '').toLowerCase().includes(search.toLowerCase()) ||
    (m.imovel?.nome ?? '').toLowerCase().includes(search.toLowerCase())
  )

  const filteredTemplates = templates.filter((t) =>
    !search ||
    t.nifEntidade.includes(search) ||
    t.entidade.nome.toLowerCase().includes(search.toLowerCase()) ||
    (t.nome ?? '').toLowerCase().includes(search.toLowerCase())
  )

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  return (
    <div className="space-y-4">
      {/* Tabs */}
      <div className="flex gap-2">
        {(['regras', 'templates'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              tab === t ? 'bg-brand-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {t === 'regras' ? `Regras NIF (${maps.length})` : `Templates Distribuicao (${templates.length})`}
          </button>
        ))}
      </div>

      {/* Search and actions */}
      <div className="flex items-center gap-3">
        <div className="flex-1 max-w-xs">
          <Input placeholder="Pesquisar NIF, nome..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        {canEdit && tab === 'regras' && <Button onClick={openCreateRule}>Adicionar regra</Button>}
        {canEdit && tab === 'templates' && <Button onClick={openCreateTemplate}>Adicionar template</Button>}
      </div>

      {/* ── TAB: Regras ── */}
      {tab === 'regras' && (
        <Card className="p-0">
          <Table>
            <thead>
              <tr>
                <Th>NIF</Th>
                <Th>Nome</Th>
                <Th>Tipo</Th>
                <Th>Imovel</Th>
                <Th>Rubrica</Th>
                {canEdit && <Th>Accoes</Th>}
              </tr>
            </thead>
            <tbody>
              {filteredMaps.map((m) => (
                <tr key={m.id}>
                  <Td><span className="font-mono text-[11px]">{m.nifEntidade}</span></Td>
                  <Td>{m.entidade?.nome ?? '-'}</Td>
                  <Td>
                    <Badge variant={m.imovelId ? 'green' : 'blue'}>
                      {m.imovelId ? 'Completa' : 'So rubrica'}
                    </Badge>
                  </Td>
                  <Td>{m.imovel ? `${m.imovel.codigo} - ${m.imovel.nome}` : <span className="text-[11px] text-gray-400 italic">Qualquer imovel</span>}</Td>
                  <Td>{m.rubrica.nome}</Td>
                  {canEdit && (
                    <Td>
                      <div className="flex items-center gap-2">
                        <button onClick={() => openEditRule(m)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                        <button onClick={() => handleRemoveRule(m.id)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                      </div>
                    </Td>
                  )}
                </tr>
              ))}
              {filteredMaps.length === 0 && (
                <tr><Td colSpan={6} className="text-center text-gray-400">Sem regras encontradas</Td></tr>
              )}
            </tbody>
          </Table>
        </Card>
      )}

      {/* ── TAB: Templates ── */}
      {tab === 'templates' && (
        <Card className="p-0">
          <Table>
            <thead>
              <tr>
                <Th>NIF</Th>
                <Th>Nome</Th>
                <Th>Rubrica</Th>
                <Th>Tipo</Th>
                <Th>Imoveis</Th>
                {canEdit && <Th>Accoes</Th>}
              </tr>
            </thead>
            <tbody>
              {filteredTemplates.map((t) => (
                <tr key={t.id}>
                  <Td><span className="font-mono text-[11px]">{t.nifEntidade}</span></Td>
                  <Td>{t.entidade.nome}</Td>
                  <Td>{t.rubrica.nome}</Td>
                  <Td>
                    <Badge variant={t.tipo === 'IGUAL' ? 'blue' : t.tipo === 'PERCENTAGEM' ? 'teal' : 'purple'}>
                      {t.tipo === 'IGUAL' ? 'Igual' : t.tipo === 'PERCENTAGEM' ? 'Percentagem' : 'Manual'}
                    </Badge>
                  </Td>
                  <Td>
                    <div className="flex flex-wrap gap-1">
                      {t.linhas.map((l) => (
                        <span key={l.id} className="text-[11px] px-1.5 py-0.5 bg-gray-100 rounded">
                          {l.imovel.codigo}
                          {t.tipo === 'PERCENTAGEM' && l.percentagem && ` (${l.percentagem}%)`}
                        </span>
                      ))}
                    </div>
                  </Td>
                  {canEdit && (
                    <Td>
                      <div className="flex items-center gap-2">
                        <button onClick={() => openEditTemplate(t)} className="text-[12px] text-brand-primary hover:underline">Editar</button>
                        <button onClick={() => handleRemoveTemplate(t.id)} className="text-[12px] text-[#A32D2D] hover:underline">Remover</button>
                      </div>
                    </Td>
                  )}
                </tr>
              ))}
              {filteredTemplates.length === 0 && (
                <tr><Td colSpan={6} className="text-center text-gray-400">Sem templates encontrados</Td></tr>
              )}
            </tbody>
          </Table>
        </Card>
      )}

      {/* ── Modal Regra ── */}
      <Modal
        open={ruleModalOpen}
        onClose={() => setRuleModalOpen(false)}
        title={ruleEditId ? 'Editar regra' : 'Adicionar regra'}
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setRuleModalOpen(false)}>Cancelar</Button>
            <Button onClick={handleSaveRule}>{ruleEditId ? 'Guardar' : 'Criar'}</Button>
          </div>
        }
      >
        <div className="space-y-3">
          <Input label="NIF Entidade" value={ruleForm.nifEntidade} onChange={(e) => setRuleForm({ ...ruleForm, nifEntidade: e.target.value })} disabled={!!ruleEditId} />
          <Input label="Nome Entidade" value={ruleForm.nomeEntidade} onChange={(e) => setRuleForm({ ...ruleForm, nomeEntidade: e.target.value })} disabled={!!ruleEditId} />
          <Select
            label="Imovel (vazio = so rubrica)"
            options={[{ value: '', label: '— Qualquer imovel (so rubrica) —' }, ...imoveis.map((i) => ({ value: i.id, label: `${i.codigo} - ${i.nome}` }))]}
            value={ruleForm.imovelId}
            onChange={(e) => setRuleForm({ ...ruleForm, imovelId: e.target.value })}
          />
          <Select
            label="Rubrica"
            options={rubricas.map((r) => ({ value: r.id, label: r.nome }))}
            value={ruleForm.rubricaId}
            onChange={(e) => setRuleForm({ ...ruleForm, rubricaId: e.target.value })}
          />
        </div>
      </Modal>

      {/* ── Modal Template ── */}
      <Modal
        open={templateModalOpen}
        onClose={() => setTemplateModalOpen(false)}
        title={templateEditId ? 'Editar template distribuicao' : 'Criar template distribuicao'}
        footer={
          <div className="flex gap-2 ml-auto">
            <Button variant="ghost" onClick={() => setTemplateModalOpen(false)}>Cancelar</Button>
            <Button onClick={handleSaveTemplate}>{templateEditId ? 'Guardar' : 'Criar'}</Button>
          </div>
        }
      >
        <div className="space-y-3">
          <Input label="NIF Entidade" value={templateForm.nifEntidade} onChange={(e) => setTemplateForm({ ...templateForm, nifEntidade: e.target.value })} disabled={!!templateEditId} />
          <Input label="Nome Entidade" value={templateForm.nomeEntidade} onChange={(e) => setTemplateForm({ ...templateForm, nomeEntidade: e.target.value })} disabled={!!templateEditId} />
          <Input label="Nome do template (opcional)" placeholder="Ex: Vodafone mensal" value={templateForm.nome} onChange={(e) => setTemplateForm({ ...templateForm, nome: e.target.value })} />
          <Select
            label="Rubrica"
            options={rubricas.map((r) => ({ value: r.id, label: r.nome }))}
            value={templateForm.rubricaId}
            onChange={(e) => setTemplateForm({ ...templateForm, rubricaId: e.target.value })}
          />
          <Select
            label="Tipo de distribuicao"
            options={[
              { value: 'IGUAL', label: 'Igual (dividir igualmente)' },
              { value: 'PERCENTAGEM', label: 'Percentagem (definir %)' },
              { value: 'MANUAL', label: 'Manual (definir valor cada vez)' },
            ]}
            value={templateForm.tipo}
            onChange={(e) => setTemplateForm({ ...templateForm, tipo: e.target.value as 'IGUAL' | 'PERCENTAGEM' | 'MANUAL' })}
          />

          {/* Linhas */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <label className="text-[11px] font-medium text-[#6B7280]">IMOVEIS</label>
              <button onClick={addTemplateLine} className="flex items-center gap-1 text-[11px] text-brand-primary hover:underline">
                <Plus size={12} /> Adicionar imovel
              </button>
            </div>
            <div className="space-y-2">
              {templateForm.linhas.map((linha, i) => (
                <div key={i} className="flex items-center gap-2">
                  <Select
                    options={imoveis.map((im) => ({ value: im.id, label: `${im.codigo} - ${im.nome}` }))}
                    value={linha.imovelId}
                    onChange={(e) => updateTemplateLine(i, 'imovelId', e.target.value)}
                    className="flex-1"
                  />
                  {templateForm.tipo === 'PERCENTAGEM' && (
                    <input
                      type="number"
                      min="0" max="100" step="0.01"
                      value={linha.percentagem || ''}
                      onChange={(e) => updateTemplateLine(i, 'percentagem', parseFloat(e.target.value) || 0)}
                      placeholder="%"
                      className="w-20 px-2 py-1.5 border border-gray-200 rounded-lg text-sm text-center focus:outline-none focus:border-brand-primary"
                    />
                  )}
                  {templateForm.linhas.length > 1 && (
                    <button onClick={() => removeTemplateLine(i)} className="text-[#A32D2D] hover:bg-red-50 p-1 rounded">
                      <Trash2 size={14} />
                    </button>
                  )}
                </div>
              ))}
            </div>
            {templateForm.tipo === 'IGUAL' && templateForm.linhas.filter((l) => l.imovelId).length > 0 && (
              <div className="text-[11px] text-gray-400 mt-1">
                Cada imovel recebe {(100 / templateForm.linhas.filter((l) => l.imovelId).length).toFixed(1)}% do valor
              </div>
            )}
          </div>
        </div>
      </Modal>
    </div>
  )
}
