'use client'

import { useCallback, useEffect, useMemo, useState } from 'react'
import Link from 'next/link'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { KpiCard } from '@/components/ui/KpiCard'
import { Table, Th, Td } from '@/components/ui/Table'
import { Badge } from '@/components/ui/Badge'
import { formatCurrency } from '@/lib/utils'
import {
  ResponsiveContainer, LineChart, Line,
  XAxis, YAxis, Tooltip, CartesianGrid,
} from 'recharts'

const MESES = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiData = any

export default function IRCPage() {
  const [ano, setAno] = useState(new Date().getFullYear())
  const [years, setYears] = useState<number[]>([new Date().getFullYear()])
  const [raw, setRaw] = useState<ApiData>(null)
  const [loading, setLoading] = useState(true)
  const [pccDraft, setPccDraft] = useState<Record<number, { valor: string; data: string }>>({
    1: { valor: '', data: '' },
    2: { valor: '', data: '' },
    3: { valor: '', data: '' },
  })

  useEffect(() => {
    fetch('/api/anos').then(r => r.json()).then(j => { if (j.data) setYears(j.data) }).catch(() => {})
  }, [])

  const fetchData = useCallback(() => {
    setLoading(true)
    fetch(`/api/analise?ano=${ano}`)
      .then((r) => r.json())
      .then((j) => {
        if (j.data) {
          setRaw(j.data)
          // Hidratar pccDraft com pagamentos existentes
          const next: Record<number, { valor: string; data: string }> = {
            1: { valor: '', data: '' },
            2: { valor: '', data: '' },
            3: { valor: '', data: '' },
          }
          for (const p of j.data.irc?.pagamentosConta || []) {
            next[p.prestacao] = {
              valor: String(p.valor),
              data: p.dataPagamento ? String(p.dataPagamento).split('T')[0] : '',
            }
          }
          setPccDraft(next)
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [ano])

  useEffect(() => { fetchData() }, [fetchData])

  async function savePcc(prestacao: number) {
    const d = pccDraft[prestacao]
    if (!d.valor || !d.data) return
    const res = await fetch('/api/pagamentos-conta', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ano,
        prestacao,
        valor: Number(d.valor),
        dataPagamento: d.data,
      }),
    })
    if (res.ok) fetchData()
  }

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!raw) return <div className="text-sm text-gray-400">Sem dados</div>

  const g = raw.global || {}
  const irc = raw.irc || {}
  const cfg = raw.config || {}
  const evolucao = (raw.evolucaoMensal || []).map((m: ApiData, i: number) => ({
    mes: MESES[i] || `M${i + 1}`,
    ircAcumulado: m.ircAcumulado || 0,
  }))

  const resultadoAI = g.resultadoLiquido || 0
  const resultadoCorr = irc.resultadoAposCorreccoes ?? resultadoAI
  const mc = irc.materiaColetavel || irc.mc || 0
  const limitePme = cfg.limitePme || 50000
  const taxaPme = cfg.taxaIrcPme || 17
  const taxaNormal = cfg.taxaIrcNormal || 21
  const derramaPct = cfg.derramaMunicipal || 1.5
  const taxaRetencao = cfg.taxaRetencao || 25

  const coletaPme = Math.min(mc, limitePme) * (taxaPme / 100)
  const coletaNormal = Math.max(mc - limitePme, 0) * (taxaNormal / 100)
  const coletaSubtotal = irc.coleta || (coletaPme + coletaNormal)
  const derramaValor = irc.derrama || (Math.max(resultadoCorr, 0) * derramaPct / 100)
  const taTotal = irc.tributacaoAutonomaTotal || 0
  const ircTotal = irc.ircTotal || (coletaSubtotal + derramaValor + taTotal)
  const taxaEfetiva = irc.taxaEfetiva || (resultadoAI > 0 ? (ircTotal / resultadoAI) * 100 : 0)

  const rendaPagaTotal = g.rendaPagaTotal || 0
  // IRS retido aos senhorios — substituto tributario, NAO deduz ao IRC
  const retencoesEntregues = irc.retencoesEntreguesTotal ?? (rendaPagaTotal * (taxaRetencao / 100))
  // Retencoes na fonte sofridas pela empresa — DEDUZ ao IRC (art. 90.º CIRC)
  const retencoesSofridas = irc.retencoesSofridasTotal ?? 0
  const pccTotal = irc.pagamentosContaTotal || 0
  const ircAPagar = irc.ircAPagar ?? (ircTotal - retencoesSofridas - pccTotal)

  const depreciacoes: Array<{ origem: string; nome: string; tipo: string; valorAquisicao: number; taxa: number; depreciacaoAceite: number; acrescimo: number; combustivel?: string | null }> = irc.depreciacoes || []
  const taLinhas: Array<{ nome: string; combustivel: string; valorAquisicao: number; tier: string; taxa: number; base: number; valor: number }> = irc.tributacaoAutonoma || []
  const encargosND: Array<{ rubricaCodigo: string; rubricaNome: string; valor: number }> = irc.encargosNaoDedutiveis || []
  const depTotal = irc.depreciacoesTotal || 0
  const acrTotal = irc.acrescimoDepreciacoes || 0
  const ndTotal = irc.acrescimoEncargosNaoDedutiveis || 0

  // Sugestao de PCC: 80% do IRC dividido em 3 (referencial AT)
  const sugestaoPcc = (ircTotal * 0.8) / 3

  return (
    <div className="space-y-5">
      <div className="flex items-center gap-2">
        {years.map((y) => (
          <Button key={y} variant={y === ano ? 'primary' : 'secondary'} onClick={() => setAno(y)}>{y}</Button>
        ))}
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
        <KpiCard label="Resultado Antes Impostos" value={formatCurrency(resultadoAI)} color={resultadoAI >= 0 ? 'green' : 'red'} />
        <KpiCard label="IRC + TA Estimado" value={formatCurrency(ircTotal)} color="amber" sub={`Tributacao autonoma: ${formatCurrency(taTotal)}`} />
        <KpiCard label="Taxa Efectiva" value={`${taxaEfetiva.toFixed(1)}%`} />
        <KpiCard label="Sofridas + PCC" value={formatCurrency(retencoesSofridas + pccTotal)} sub={`Retencoes sofridas: ${formatCurrency(retencoesSofridas)} | PCC: ${formatCurrency(pccTotal)}`} />
        <KpiCard label="IRC a pagar/recuperar" value={formatCurrency(ircAPagar)} color={ircAPagar > 0 ? 'red' : 'green'} sub={ircAPagar > 0 ? 'A liquidar' : 'A recuperar'} />
      </div>

      {/* IRC Calculation Breakdown */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Calculo Detalhado do IRC</h3>
        <div className="space-y-2.5 text-[13px]">
          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>1. Receita total</span>
            <span>{formatCurrency(g.receitaTotal || 0)}</span>
          </div>
          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>2. (-) Custos dedutiveis</span>
            <span style={{ color: '#A32D2D' }}>{formatCurrency(g.custoTotal || 0)}</span>
          </div>
          <div className="flex justify-between pt-1 border-t border-gray-100">
            <span className="font-medium">3. (=) Resultado contabilistico</span>
            <span className="font-medium" style={{ color: resultadoAI >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(resultadoAI)}</span>
          </div>

          {(depTotal > 0 || acrTotal > 0 || ndTotal > 0) && (
            <>
              {depTotal > 0 && (
                <div className="flex justify-between pl-4">
                  <span style={{ color: '#6B7280' }}>(-) Depreciacoes fiscalmente aceites</span>
                  <span style={{ color: '#A32D2D' }}>-{formatCurrency(depTotal)}</span>
                </div>
              )}
              {acrTotal > 0 && (
                <div className="flex justify-between pl-4">
                  <span style={{ color: '#6B7280' }}>(+) Acrescimo por limites (art. 34.º CIRC)</span>
                  <span style={{ color: '#0F6E56' }}>+{formatCurrency(acrTotal)}</span>
                </div>
              )}
              {ndTotal > 0 && (
                <div className="flex justify-between pl-4">
                  <span style={{ color: '#6B7280' }}>(+) Encargos nao dedutiveis (multas, IRC, donativos...)</span>
                  <span style={{ color: '#0F6E56' }}>+{formatCurrency(ndTotal)}</span>
                </div>
              )}
              <div className="flex justify-between pt-1 border-t border-gray-50">
                <span className="font-medium">3a. (=) Lucro tributavel</span>
                <span className="font-medium" style={{ color: resultadoCorr >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(resultadoCorr)}</span>
              </div>
            </>
          )}

          {(irc.prejuizoDisponivel || 0) > 0 && (
            <>
              <div className="flex justify-between pl-4">
                <span style={{ color: '#6B7280' }}>(-) Deducao prejuizos anos anteriores (max 65%)</span>
                <span style={{ color: '#A32D2D' }}>-{formatCurrency(irc.deducaoPrejuizos || 0)}</span>
              </div>
              <div className="flex justify-between pl-4 text-[11px]">
                <span style={{ color: '#9CA3AF' }}>Prejuizos disponiveis: {formatCurrency(irc.prejuizoDisponivel || 0)} | A reportar: {formatCurrency(irc.prejuizoRestante || 0)}</span>
              </div>
              <div className="flex justify-between pt-1 border-t border-gray-50">
                <span className="font-medium">(=) Materia colectavel</span>
                <span className="font-medium">{formatCurrency(mc)}</span>
              </div>
            </>
          )}

          <div className="pt-2"><span className="font-medium">4. Coleta IRC (regime PME):</span></div>
          <div className="flex justify-between pl-4">
            <span style={{ color: '#6B7280' }}>Primeiros {formatCurrency(limitePme)} x {taxaPme}%</span>
            <span>{formatCurrency(coletaPme)}</span>
          </div>
          <div className="flex justify-between pl-4">
            <span style={{ color: '#6B7280' }}>Restante x {taxaNormal}%</span>
            <span>{formatCurrency(coletaNormal)}</span>
          </div>
          <div className="flex justify-between pl-4 pt-1 border-t border-gray-50">
            <span style={{ color: '#6B7280' }}>Subtotal coleta</span>
            <span className="font-medium">{formatCurrency(coletaSubtotal)}</span>
          </div>

          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>5. (+) Derrama municipal ({derramaPct}% sobre lucro tributavel)</span>
            <span>{formatCurrency(derramaValor)}</span>
          </div>

          {taTotal > 0 && (
            <div className="flex justify-between">
              <span style={{ color: '#6B7280' }}>6. (+) Tributacao autonoma (viaturas)</span>
              <span>{formatCurrency(taTotal)}</span>
            </div>
          )}

          <div className="flex justify-between pt-3 border-t-2 border-brand-black">
            <span className="font-bold text-base">7. (=) IRC Total estimado</span>
            <span className="font-bold text-base" style={{ color: '#633806' }}>{formatCurrency(ircTotal)}</span>
          </div>

          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>(-) Retencoes na fonte sofridas pela empresa</span>
            <span style={{ color: '#0F6E56' }}>-{formatCurrency(retencoesSofridas)}</span>
          </div>
          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>(-) Pagamentos por conta</span>
            <span style={{ color: '#0F6E56' }}>-{formatCurrency(pccTotal)}</span>
          </div>
          <div className="flex justify-between pl-4 text-[11px]">
            <span style={{ color: '#9CA3AF' }}>* IRS retido aos senhorios ({formatCurrency(retencoesEntregues)}) e entregue a AT como substituto tributario NAO deduz aqui.</span>
          </div>
          <div className="flex justify-between pt-1 border-t border-gray-100">
            <span className="font-bold">IRC a pagar / (recuperar)</span>
            <span className="font-bold" style={{ color: ircAPagar > 0 ? '#A32D2D' : '#0F6E56' }}>{formatCurrency(ircAPagar)}</span>
          </div>

          <div className="flex justify-between">
            <span style={{ color: '#6B7280' }}>Taxa efectiva</span>
            <span>{taxaEfetiva.toFixed(1)}%</span>
          </div>
        </div>
      </Card>

      {/* Depreciacoes */}
      {depreciacoes.length > 0 && (
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Depreciacoes do exercicio</h3>
          <Table>
            <thead>
              <tr>
                <Th>Activo</Th>
                <Th>Tipo</Th>
                <Th className="text-right">Valor aquisicao</Th>
                <Th className="text-right">Taxa</Th>
                <Th className="text-right">Depreciacao aceite</Th>
                <Th className="text-right">Acrescimo</Th>
              </tr>
            </thead>
            <tbody>
              {depreciacoes.map((d, i) => (
                <tr key={i}>
                  <Td className="font-medium">{d.nome}</Td>
                  <Td>{d.origem === 'IMOVEL' ? 'Imovel' : d.tipo}</Td>
                  <Td className="text-right font-mono">{formatCurrency(d.valorAquisicao)}</Td>
                  <Td className="text-right">{d.taxa}%</Td>
                  <Td className="text-right font-mono">{formatCurrency(d.depreciacaoAceite)}</Td>
                  <Td className="text-right font-mono">{d.acrescimo > 0 ? <span style={{ color: '#A32D2D' }}>{formatCurrency(d.acrescimo)}</span> : <span className="text-gray-300">—</span>}</Td>
                </tr>
              ))}
              <tr className="border-t-2 border-gray-200">
                <Td colSpan={4} className="font-medium text-right">Total</Td>
                <Td className="text-right font-mono font-semibold">{formatCurrency(depTotal)}</Td>
                <Td className="text-right font-mono font-semibold" style={{ color: acrTotal > 0 ? '#A32D2D' : undefined }}>{formatCurrency(acrTotal)}</Td>
              </tr>
            </tbody>
          </Table>
        </Card>
      )}

      {/* Encargos nao dedutiveis */}
      {encargosND.length > 0 && (
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Encargos nao dedutiveis (acrescidos ao lucro tributavel)</h3>
          <Table>
            <thead>
              <tr>
                <Th>Codigo</Th>
                <Th>Rubrica</Th>
                <Th className="text-right">Valor</Th>
              </tr>
            </thead>
            <tbody>
              {encargosND.map((e, i) => (
                <tr key={i}>
                  <Td className="font-mono text-[11px]">{e.rubricaCodigo}</Td>
                  <Td>{e.rubricaNome}</Td>
                  <Td className="text-right font-mono">{formatCurrency(e.valor)}</Td>
                </tr>
              ))}
              <tr className="border-t-2 border-gray-200">
                <Td colSpan={2} className="font-medium text-right">Total</Td>
                <Td className="text-right font-mono font-semibold" style={{ color: '#0F6E56' }}>+{formatCurrency(ndTotal)}</Td>
              </tr>
            </tbody>
          </Table>
          <p className="text-[11px] text-gray-400 mt-2">
            Configura quais rubricas sao nao dedutiveis em <Link href="/configuracoes" className="text-brand-primary hover:underline">Configuracoes &raquo; Rubricas</Link>.
          </p>
        </Card>
      )}

      {/* Simulador What-if */}
      <WhatIfSimulator
        receita={g.receitaTotal || 0}
        custos={g.custoTotal || 0}
        depTotal={depTotal}
        acrTotal={acrTotal}
        ndTotal={ndTotal}
        derramaPct={derramaPct}
        regimePme={!!cfg.regimePme}
        taxaPme={taxaPme}
        taxaNormal={taxaNormal}
        limitePme={limitePme}
        taTotal={taTotal}
        prejuizoDisponivel={irc.prejuizoDisponivel || 0}
        reportePct={65}
      />

      {/* Tributacao Autonoma */}
      {taLinhas.length > 0 && (
        <Card>
          <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Tributacao Autonoma (viaturas)</h3>
          <Table>
            <thead>
              <tr>
                <Th>Viatura</Th>
                <Th>Combustivel</Th>
                <Th>Tier</Th>
                <Th className="text-right">Valor aquisicao</Th>
                <Th className="text-right">Base (encargos)</Th>
                <Th className="text-right">Taxa</Th>
                <Th className="text-right">TA</Th>
              </tr>
            </thead>
            <tbody>
              {taLinhas.map((t, i) => (
                <tr key={i}>
                  <Td className="font-medium">{t.nome}</Td>
                  <Td>{t.combustivel}</Td>
                  <Td><Badge variant={t.tier === 'ELECTRICA_ISENTA' ? 'green' : t.tier === 'ALTA' ? 'red' : 'amber'}>{t.tier}</Badge></Td>
                  <Td className="text-right font-mono">{formatCurrency(t.valorAquisicao)}</Td>
                  <Td className="text-right font-mono">{formatCurrency(t.base)}</Td>
                  <Td className="text-right">{t.taxa}%</Td>
                  <Td className="text-right font-mono">{formatCurrency(t.valor)}</Td>
                </tr>
              ))}
              <tr className="border-t-2 border-gray-200">
                <Td colSpan={6} className="font-medium text-right">Total</Td>
                <Td className="text-right font-mono font-semibold">{formatCurrency(taTotal)}</Td>
              </tr>
            </tbody>
          </Table>
        </Card>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Retencoes na Fonte */}
        <Card>
          <h3 className="text-sm font-semibold mb-1" style={{ color: '#0D1B1A' }}>Retencoes na Fonte</h3>

          {/* Bloco 1 — IRS retido aos senhorios (informativo) */}
          <div className="mt-3 p-3 rounded-md" style={{ backgroundColor: '#FFF8E1', border: '1px solid #F3E1A8' }}>
            <div className="text-[11px] font-medium uppercase tracking-wide mb-2" style={{ color: '#7A5A00' }}>
              IRS retido aos senhorios (substituto tributario)
            </div>
            <div className="space-y-1.5 text-[13px]">
              <div className="flex justify-between">
                <span style={{ color: '#6B7280' }}>Rendas pagas aos senhorios</span>
                <span>{formatCurrency(rendaPagaTotal)}</span>
              </div>
              <div className="flex justify-between">
                <span style={{ color: '#6B7280' }}>Retencao {taxaRetencao}% (art. 101.º CIRS)</span>
                <span>{formatCurrency(retencoesEntregues)}</span>
              </div>
              <div className="flex justify-between pt-1.5 border-t" style={{ borderColor: '#F3E1A8' }}>
                <span className="font-medium">A liquidar/entregar a AT</span>
                <span className="font-medium" style={{ color: '#A32D2D' }}>{formatCurrency(retencoesEntregues)}</span>
              </div>
              <p className="text-[10px] pt-1" style={{ color: '#7A5A00' }}>
                Obrigacao fiscal da empresa enquanto substituto. NAO deduz ao IRC.
              </p>
            </div>
          </div>

          {/* Bloco 2 — Retencoes sofridas pela empresa (deduz IRC) */}
          <div className="mt-3 p-3 rounded-md" style={{ backgroundColor: '#F0F9F4', border: '1px solid #C7E7D3' }}>
            <div className="text-[11px] font-medium uppercase tracking-wide mb-2" style={{ color: '#0F6E56' }}>
              Retencoes sofridas pela empresa (deduz IRC)
            </div>
            <div className="space-y-1.5 text-[13px]">
              <div className="flex justify-between">
                <span style={{ color: '#6B7280' }}>Total registado</span>
                <span className="font-medium">{formatCurrency(retencoesSofridas)}</span>
              </div>
              <p className="text-[10px] pt-1" style={{ color: '#0F6E56' }}>
                Ex: juros bancarios, servicos prestados a outras empresas (art. 90.º n.º 2 CIRC).
                Registo manual ainda nao implementado &mdash; default 0.
              </p>
            </div>
          </div>
        </Card>

        {/* Pagamentos por Conta — interactivo */}
        <Card>
          <h3 className="text-sm font-semibold mb-2" style={{ color: '#0D1B1A' }}>Pagamentos por Conta</h3>
          <p className="text-[11px] text-gray-500 mb-3">Sugestao por prestacao (80% IRC / 3): <span className="font-mono">{formatCurrency(sugestaoPcc)}</span></p>
          <div className="space-y-2">
            {([1, 2, 3] as const).map((prest) => {
              const meses = prest === 1 ? 'Julho' : prest === 2 ? 'Setembro' : 'Dezembro'
              const d = pccDraft[prest]
              const existente = (irc.pagamentosConta || []).find((p: { prestacao: number }) => p.prestacao === prest)
              return (
                <div key={prest} className="grid grid-cols-[80px_1fr_1fr_auto] items-end gap-2">
                  <div className="text-[12px] pb-2 text-gray-600">{prest}.ª — {meses}</div>
                  <Input
                    label="Valor (EUR)"
                    type="number"
                    step="0.01"
                    value={d.valor}
                    onChange={(e) => setPccDraft({ ...pccDraft, [prest]: { ...d, valor: e.target.value } })}
                  />
                  <Input
                    label="Data pagamento"
                    type="date"
                    value={d.data}
                    onChange={(e) => setPccDraft({ ...pccDraft, [prest]: { ...d, data: e.target.value } })}
                  />
                  <Button onClick={() => savePcc(prest)}>{existente ? 'Actualizar' : 'Gravar'}</Button>
                </div>
              )
            })}
            <div className="flex justify-between pt-3 border-t border-gray-100 text-[13px]">
              <span className="font-medium">Total pago no ano</span>
              <span className="font-medium font-mono">{formatCurrency(pccTotal)}</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Evolucao Mensal IRC */}
      <Card>
        <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Evolucao Mensal IRC (acumulado)</h3>
        <div style={{ width: '100%', height: 300 }}>
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={evolucao}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey="mes" tick={{ fontSize: 11, fill: '#6B7280' }} />
              <YAxis tick={{ fontSize: 11, fill: '#6B7280' }} tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`} />
              <Tooltip formatter={(value) => formatCurrency(Number(value))} />
              <Line type="monotone" dataKey="ircAcumulado" name="IRC Acumulado" stroke="#633806" strokeWidth={2} dot={{ r: 3, fill: '#633806' }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </Card>
    </div>
  )
}

// ============================================================
//  Simulador What-if (client-side)
// ============================================================
interface WhatIfProps {
  receita: number
  custos: number
  depTotal: number
  acrTotal: number
  ndTotal: number
  derramaPct: number
  regimePme: boolean
  taxaPme: number
  taxaNormal: number
  limitePme: number
  taTotal: number
  prejuizoDisponivel: number
  reportePct: number
}

function WhatIfSimulator(p: WhatIfProps) {
  const [deltaReceita, setDeltaReceita] = useState(0)
  const [deltaCustos, setDeltaCustos] = useState(0)

  const baseline = useMemo(() => calcIrcLocal(p, 0, 0), [p])
  const sim = useMemo(() => calcIrcLocal(p, deltaReceita, deltaCustos), [p, deltaReceita, deltaCustos])
  const delta = sim.irc - baseline.irc

  return (
    <Card>
      <h3 className="text-sm font-semibold mb-4" style={{ color: '#0D1B1A' }}>Simulador &mdash; e se...?</h3>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div>
          <label className="flex items-center justify-between text-[12px] mb-1">
            <span style={{ color: '#6B7280' }}>Receita varia</span>
            <span className="font-mono font-medium" style={{ color: deltaReceita >= 0 ? '#0F6E56' : '#A32D2D' }}>
              {deltaReceita >= 0 ? '+' : ''}{deltaReceita}%
            </span>
          </label>
          <input
            type="range"
            min={-50}
            max={50}
            step={1}
            value={deltaReceita}
            onChange={(e) => setDeltaReceita(Number(e.target.value))}
            className="w-full"
            style={{ accentColor: '#1D9E75' }}
          />
          <div className="text-[11px] text-gray-400 mt-1">
            Receita simulada: <span className="font-mono">{formatCurrency(p.receita * (1 + deltaReceita / 100))}</span>
          </div>
        </div>
        <div>
          <label className="flex items-center justify-between text-[12px] mb-1">
            <span style={{ color: '#6B7280' }}>Custos variam</span>
            <span className="font-mono font-medium" style={{ color: deltaCustos <= 0 ? '#0F6E56' : '#A32D2D' }}>
              {deltaCustos >= 0 ? '+' : ''}{deltaCustos}%
            </span>
          </label>
          <input
            type="range"
            min={-50}
            max={50}
            step={1}
            value={deltaCustos}
            onChange={(e) => setDeltaCustos(Number(e.target.value))}
            className="w-full"
            style={{ accentColor: '#1D9E75' }}
          />
          <div className="text-[11px] text-gray-400 mt-1">
            Custos simulados: <span className="font-mono">{formatCurrency(p.custos * (1 + deltaCustos / 100))}</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mt-5 pt-4 border-t border-gray-100">
        <div>
          <div className="text-[11px] uppercase tracking-wide text-gray-400">Lucro tributavel</div>
          <div className="text-base font-semibold mt-1 font-mono">{formatCurrency(sim.lt)}</div>
          <div className="text-[11px] text-gray-400">baseline {formatCurrency(baseline.lt)}</div>
        </div>
        <div>
          <div className="text-[11px] uppercase tracking-wide text-gray-400">Coleta + Derrama</div>
          <div className="text-base font-semibold mt-1 font-mono">{formatCurrency(sim.coletaDerrama)}</div>
        </div>
        <div>
          <div className="text-[11px] uppercase tracking-wide text-gray-400">IRC + TA</div>
          <div className="text-base font-semibold mt-1 font-mono" style={{ color: '#633806' }}>{formatCurrency(sim.irc)}</div>
        </div>
        <div>
          <div className="text-[11px] uppercase tracking-wide text-gray-400">Impacto vs. actual</div>
          <div className="text-base font-semibold mt-1 font-mono" style={{ color: delta <= 0 ? '#0F6E56' : '#A32D2D' }}>
            {delta >= 0 ? '+' : ''}{formatCurrency(delta)}
          </div>
        </div>
      </div>

      <div className="flex gap-2 mt-4">
        <Button variant="ghost" onClick={() => { setDeltaReceita(0); setDeltaCustos(0) }}>Reset</Button>
        <Button variant="ghost" onClick={() => { setDeltaReceita(10); setDeltaCustos(0) }}>+10% receita</Button>
        <Button variant="ghost" onClick={() => { setDeltaReceita(0); setDeltaCustos(-10) }}>-10% custos</Button>
        <Button variant="ghost" onClick={() => { setDeltaReceita(-10); setDeltaCustos(10) }}>Cenario adverso</Button>
      </div>
    </Card>
  )
}

function calcIrcLocal(p: WhatIfProps, dRec: number, dCus: number) {
  const receita = p.receita * (1 + dRec / 100)
  const custos = p.custos * (1 + dCus / 100)
  const resultado = receita - custos
  const lt = resultado - p.depTotal + p.acrTotal + p.ndTotal
  const deducaoPrej = lt > 0 ? Math.min(p.prejuizoDisponivel, lt * (p.reportePct / 100)) : 0
  const mc = Math.max(lt - deducaoPrej, 0)
  let coleta = 0
  if (p.regimePme) {
    coleta = Math.min(mc, p.limitePme) * (p.taxaPme / 100) + Math.max(mc - p.limitePme, 0) * (p.taxaNormal / 100)
  } else {
    coleta = mc * (p.taxaNormal / 100)
  }
  const derrama = Math.max(lt, 0) * (p.derramaPct / 100)
  const coletaDerrama = coleta + derrama
  const irc = coletaDerrama + p.taTotal
  return { receita, custos, resultado, lt, mc, coleta, derrama, coletaDerrama, irc }
}
