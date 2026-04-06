'use client'

import { useState, useMemo, useCallback, useEffect } from 'react'
import { Card } from '@/components/ui/Card'
import { Input } from '@/components/ui/Input'
import { KpiCard } from '@/components/ui/KpiCard'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { formatCurrency } from '@/lib/utils'

/* ------------------------------------------------------------------ */
/*  Types                                                              */
/* ------------------------------------------------------------------ */

type TabId = 'calculadora' | 'dscr' | 'breakeven' | 'portfolio'

interface PortfolioImovel {
  id: number
  nome: string
  valor: number
  capital: number
  renda: number
  meses: number
  custos: number
  credito: number
}

/* ------------------------------------------------------------------ */
/*  Helpers                                                            */
/* ------------------------------------------------------------------ */

const fmtPct = (v: number) => v.toFixed(2) + '%'

const colorYb = (v: number): 'green' | 'amber' | 'red' => (v >= 5 ? 'green' : v >= 3 ? 'amber' : 'red')
const colorYl = (v: number): 'green' | 'amber' | 'red' => (v >= 4 ? 'green' : v >= 2 ? 'amber' : 'red')
const colorRoi = (v: number): 'green' | 'amber' | 'red' => (v >= 6 ? 'green' : v >= 3 ? 'amber' : 'red')
const colorCf = (v: number): 'green' | 'red' => (v >= 0 ? 'green' : 'red')
const colorDscr = (v: number): 'green' | 'amber' | 'red' => (v >= 1.25 ? 'green' : v >= 1.0 ? 'amber' : 'red')

const MESES_PT = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

function calcImovel(im: PortfolioImovel) {
  const receita = im.renda * im.meses
  const ca = (im.credito || 0) * 12
  const ct = im.custos + ca
  const cf = receita - ct
  const yb = im.valor > 0 ? (im.renda * 12 / im.valor) * 100 : 0
  const yl = im.valor > 0 ? ((receita - im.custos) / im.valor) * 100 : 0
  const roi = im.capital > 0 ? (cf / im.capital) * 100 : 0
  const pb = cf > 0 ? im.capital / cf : 0
  return { receita, ct, cf_anual: cf, cf_mensal: cf / 12, yb, yl, roi, pb }
}

function ratingImovel(r: ReturnType<typeof calcImovel>) {
  const s = (r.yl >= 4 ? 2 : r.yl >= 2 ? 1 : 0) + (r.cf_mensal >= 0 ? 2 : 0) + (r.roi >= 5 ? 2 : r.roi >= 2 ? 1 : 0)
  if (s >= 5) return { t: 'Excelente', variant: 'green' as const }
  if (s >= 3) return { t: 'Razoavel', variant: 'amber' as const }
  return { t: 'Atencao', variant: 'red' as const }
}

/* ------------------------------------------------------------------ */
/*  Reusable sub-components                                            */
/* ------------------------------------------------------------------ */

function NumInput({ label, value, onChange, step, min, max }: {
  label: string
  value: number
  onChange: (v: number) => void
  step?: number
  min?: number
  max?: number
}) {
  return (
    <Input
      label={label}
      type="number"
      value={value || ''}
      step={step}
      min={min}
      max={max}
      onChange={(e) => onChange(parseFloat(e.target.value) || 0)}
    />
  )
}

function CostBar({ name, value, max, isCredit }: { name: string; value: number; max: number; isCredit?: boolean }) {
  const pct = max > 0 ? Math.round((value / max) * 100) : 0
  return (
    <div className="mb-2">
      <div className="flex justify-between text-[11px] text-[#6B7280] mb-0.5">
        <span>{name}</span>
        <span>{formatCurrency(value)}</span>
      </div>
      <div className="w-full bg-[#F3F4F6] rounded h-2 overflow-hidden">
        <div
          className="h-full rounded transition-all duration-300"
          style={{ width: `${pct}%`, background: isCredit ? '#E24B4A' : '#1D9E75' }}
        />
      </div>
    </div>
  )
}

function VerdictPill({ text, status }: { text: string; status: 'ok' | 'warn' | 'bad' }) {
  const variant = status === 'ok' ? 'teal' : status === 'warn' ? 'amber' : 'red'
  return (
    <div className="mb-1.5">
      <Badge variant={variant} className="px-3 py-1.5 text-[11px]">{text}</Badge>
    </div>
  )
}

/* ------------------------------------------------------------------ */
/*  Main page component                                                */
/* ------------------------------------------------------------------ */

export default function CalculadoraPage() {
  const [tab, setTab] = useState<TabId>('calculadora')

  /* ---- Tab 1: Calculadora state ---- */
  const [valor, setValor] = useState(180000)
  const [capital, setCapital] = useState(54000)
  const [renda, setRenda] = useState(900)
  const [meses, setMeses] = useState(11)
  const [imi, setImi] = useState(420)
  const [seguro, setSeguro] = useState(180)
  const [cond, setCond] = useState(600)
  const [manut, setManut] = useState(500)
  const [gestaoPct, setGestaoPct] = useState(0)
  const [outros, setOutros] = useState(200)
  const [creditoMes, setCreditoMes] = useState(0)

  // Simulador de crédito/leasing
  const [usarSimulador, setUsarSimulador] = useState(false)
  const [montanteCredito, setMontanteCredito] = useState(126000)
  const [prazoAnos, setPrazoAnos] = useState(25)
  const [euriborTipo, setEuriborTipo] = useState<'3m' | '6m' | '12m' | 'fixa'>('12m')
  const [euriborManual, setEuriborManual] = useState(2.5)
  const [spread, setSpread] = useState(1.0)

  const taxaTotal = euriborManual + spread
  const prestacaoSimulada = useMemo(() => {
    if (montanteCredito <= 0 || prazoAnos <= 0 || taxaTotal <= 0) return 0
    const taxaMensal = taxaTotal / 100 / 12
    const nMeses = prazoAnos * 12
    return (montanteCredito * taxaMensal * Math.pow(1 + taxaMensal, nMeses)) / (Math.pow(1 + taxaMensal, nMeses) - 1)
  }, [montanteCredito, prazoAnos, taxaTotal])

  const totalJuros = useMemo(() => {
    return prestacaoSimulada * prazoAnos * 12 - montanteCredito
  }, [prestacaoSimulada, prazoAnos, montanteCredito])

  // Aplicar prestação simulada ao crédito
  useEffect(() => {
    if (usarSimulador) setCreditoMes(Math.round(prestacaoSimulada * 100) / 100)
  }, [usarSimulador, prestacaoSimulada])

  const calc = useMemo(() => {
    const receita = renda * meses
    const gestao = renda * 12 * gestaoPct / 100
    const custos_op = imi + seguro + cond + manut + gestao + outros
    const credito_anual = creditoMes * 12
    const custos_total = custos_op + credito_anual
    const cf_anual = receita - custos_total
    const cf_mensal = cf_anual / 12
    const yb = valor > 0 ? (renda * 12 / valor) * 100 : 0
    const yl = valor > 0 ? ((receita - custos_op) / valor) * 100 : 0
    const roi = capital > 0 ? (cf_anual / capital) * 100 : 0
    const pb_capital = cf_anual > 0 && capital > 0 ? capital / cf_anual : 0
    const investimentoTotal = capital + (usarSimulador ? montanteCredito : creditoMes > 0 ? creditoMes * 12 * prazoAnos : 0)
    const lucroAnualLiquido = receita - custos_op // lucro antes do crédito
    const pb_total = lucroAnualLiquido > 0 && investimentoTotal > 0 ? investimentoTotal / lucroAnualLiquido : 0

    const costItems = [
      { name: 'IMI', value: imi, isCredit: false },
      { name: 'Seguro', value: seguro, isCredit: false },
      { name: 'Condominio', value: cond, isCredit: false },
      { name: 'Manutencao', value: manut, isCredit: false },
      { name: 'Gestao', value: gestao, isCredit: false },
      { name: 'Outros', value: outros, isCredit: false },
      { name: 'Credito', value: credito_anual, isCredit: true },
    ].filter(x => x.value > 0)
    const maxCost = Math.max(...costItems.map(x => x.value), 1)

    const verdicts: { text: string; status: 'ok' | 'warn' | 'bad' }[] = []
    if (yb >= 5) verdicts.push({ text: 'Yield bruta >= 5% — acima da media do mercado', status: 'ok' })
    else if (yb >= 3) verdicts.push({ text: 'Yield bruta entre 3-5% — razoavel', status: 'warn' })
    else verdicts.push({ text: 'Yield bruta < 3% — abaixo do mercado', status: 'bad' })
    if (yl >= 4) verdicts.push({ text: 'Yield liquida >= 4% — muito bom', status: 'ok' })
    else if (yl >= 2) verdicts.push({ text: 'Yield liquida entre 2-4% — aceitavel', status: 'warn' })
    else verdicts.push({ text: 'Yield liquida < 2% — atencao aos custos', status: 'bad' })
    if (cf_mensal > 0) verdicts.push({ text: 'Cash flow positivo — imovel auto-sustentavel', status: 'ok' })
    else verdicts.push({ text: 'Cash flow negativo — requer injeccao mensal', status: 'bad' })

    return { receita, gestao, custos_op, credito_anual, custos_total, cf_anual, cf_mensal, yb, yl, roi, pb_capital, pb_total, investimentoTotal, lucroAnualLiquido, costItems, maxCost, verdicts }
  }, [valor, capital, renda, meses, imi, seguro, cond, manut, gestaoPct, outros, creditoMes, usarSimulador, montanteCredito, prazoAnos])

  /* ---- Tab 2: DSCR state ---- */
  const [dNoi, setDNoi] = useState(9900)
  const [dOp, setDOp] = useState(1900)
  const [dDebt, setDDebt] = useState(6000)
  const [dVal, setDVal] = useState(180000)
  const [dDiv, setDDiv] = useState(126000)

  const dscrCalc = useMemo(() => {
    const noi = dNoi - dOp
    const dscr = dDebt > 0 ? noi / dDebt : 0
    const ltv = dVal > 0 ? (dDiv / dVal) * 100 : 0
    const arrowPct = Math.min((dscr / 2) * 100, 100)
    let dscrLabel = ''
    if (dscr >= 1.25) dscrLabel = 'Excelente cobertura'
    else if (dscr >= 1.0) dscrLabel = 'Margem reduzida'
    else dscrLabel = 'Cobertura insuficiente'
    let ltvLabel = ''
    if (ltv <= 60) ltvLabel = 'LTV baixo — boa almofada'
    else if (ltv <= 80) ltvLabel = 'LTV aceitavel'
    else ltvLabel = 'LTV elevado'
    return { noi, dscr, ltv, arrowPct, dscrLabel, ltvLabel }
  }, [dNoi, dOp, dDebt, dVal, dDiv])

  /* ---- Tab 3: Breakeven state ---- */
  const [bRenda, setBRenda] = useState(900)
  const [bFixos, setBFixos] = useState(1900)
  const [bCredito, setBCredito] = useState(500)
  const [bVar, setBVar] = useState(80)

  const beCalc = useMemo(() => {
    const credito_anual = bCredito * 12
    const custos_total = bFixos + credito_anual
    const rlm = bRenda - bVar
    const be = rlm > 0 ? Math.ceil(custos_total / rlm) : 12
    const be_c = Math.min(be, 12)
    const margem = 12 - be_c
    const scenarios = [4, 6, 8, 9, 10, 11, 12].map(m => {
      const rec = bRenda * m
      const cf = rec - (bFixos + credito_anual + bVar * m)
      return { meses: m, receita: rec, cf, isBreakeven: m === be_c }
    })
    return { custos_total, be_c, margem, scenarios }
  }, [bRenda, bFixos, bCredito, bVar])

  /* ---- Tab 4: Portfolio state — carrega dados reais ---- */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [analiseData, setAnaliseData] = useState<any>(null)
  const [imoveis, setImoveis] = useState<PortfolioImovel[]>([])
  const [nextId, setNextId] = useState(1000)
  const [showAddForm, setShowAddForm] = useState(false)
  const [newImovel, setNewImovel] = useState({ nome: '', valor: 0, capital: 0, renda: 0, meses: 11, custos: 0, credito: 0 })

  // Carregar portfolio real ao abrir a tab
  useEffect(() => {
    if (tab !== 'portfolio' || analiseData) return
    fetch(`/api/analise?ano=${new Date().getFullYear()}`)
      .then(r => r.json())
      .then(j => {
        if (!j.data) return
        setAnaliseData(j.data)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const reais: PortfolioImovel[] = (j.data.imoveis || []).map((im: any, i: number) => {
          const rendaMensal = (im.fracoes || []).reduce((s: number, f: { renda: number }) => s + Number(f.renda || 0), 0)
          const ocupados = (im.fracoes || []).filter((f: { estado: string }) => f.estado === 'OCUPADO').length
          const total = (im.fracoes || []).length
          return {
            id: i + 1,
            nome: im.nome || im.codigo,
            valor: Number(im.valorPatrimonial || 0),
            capital: Number(im.valorPatrimonial || 0) * 0.3, // estimate 30%
            renda: rendaMensal || (im.receita || 0) / 12,
            meses: total > 0 ? Math.round((ocupados / total) * 12) : 11,
            custos: im.custoTotal || 0,
            credito: 0,
          }
        })
        setImoveis(reais)
        setNextId(reais.length + 100)
      })
      .catch(() => {})
  }, [tab, analiseData])

  const addImovel = useCallback(() => {
    if (!newImovel.nome.trim()) return
    setImoveis(prev => [...prev, { ...newImovel, id: nextId }])
    setNextId(prev => prev + 1)
    setNewImovel({ nome: '', valor: 0, capital: 0, renda: 0, meses: 11, custos: 0, credito: 0 })
    setShowAddForm(false)
  }, [newImovel, nextId])

  const removeImovel = useCallback((id: number) => {
    setImoveis(prev => prev.filter(im => im.id !== id))
  }, [])

  const portfolioSummary = useMemo(() => {
    const totalValor = imoveis.reduce((s, im) => s + im.valor, 0)
    const totalRenda = imoveis.reduce((s, im) => s + im.renda, 0)
    const totalCf = imoveis.reduce((s, im) => s + calcImovel(im).cf_mensal, 0)
    const avgYl = imoveis.length > 0 ? imoveis.reduce((s, im) => s + calcImovel(im).yl, 0) / imoveis.length : 0
    return { totalValor, totalRenda, totalCf, avgYl }
  }, [imoveis])

  /* ---- Tab bar ---- */
  const tabs: { id: TabId; label: string }[] = [
    { id: 'calculadora', label: 'Calculadora' },
    { id: 'dscr', label: 'DSCR' },
    { id: 'breakeven', label: 'Ponto de Equilibrio' },
    { id: 'portfolio', label: 'Portfolio' },
  ]

  return (
    <div className="max-w-[1100px] mx-auto">
      {/* Tab bar */}
      <div className="flex border-b border-gray-200 mb-5 bg-white rounded-t-xl overflow-hidden">
        {tabs.map(t => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            className={`px-5 py-2.5 text-xs font-medium transition-all border-b-2 ${
              tab === t.id
                ? 'text-[#0F6E56] border-[#1D9E75] bg-[#F4FAF8]'
                : 'text-gray-500 border-transparent hover:bg-gray-50 hover:text-gray-700'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* ============================================================ */}
      {/*  TAB 1 — Calculadora                                         */}
      {/* ============================================================ */}
      {tab === 'calculadora' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {/* Left: Inputs */}
          <div className="space-y-4">
            <Card>
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Imovel</div>
              <div className="space-y-3">
                <div>
                  <NumInput label="Valor do imovel (EUR)" value={valor} onChange={setValor} step={1000} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Valor de mercado ou de aquisicao do imovel. Usado para calcular yield e ROI.</div>
                </div>
                <div>
                  <NumInput label="Capital proprio investido (EUR)" value={capital} onChange={setCapital} step={1000} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Capital proprio: entrada, caucoes, mobilia, obras. Para subarrendamento: caucao + setup.</div>
                </div>
                <div>
                  <NumInput label="Renda mensal bruta (EUR)" value={renda} onChange={setRenda} step={50} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Valor mensal que cobra ao inquilino. Para quartos, soma de todas as rendas.</div>
                </div>
                <div>
                  <NumInput label="Meses arrendado por ano" value={meses} onChange={setMeses} min={1} max={12} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Previsao de meses com inquilino. 11 = 1 mes de rotacao/vazio por ano.</div>
                </div>
              </div>
            </Card>
            <Card>
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Custos anuais</div>
              <div className="space-y-3">
                <div>
                  <NumInput label="IMI anual (EUR)" value={imi} onChange={setImi} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Imposto Municipal sobre Imoveis. Pago anualmente, consultavel no Portal das Financas.</div>
                </div>
                <div>
                  <NumInput label="Seguro multirriscos (EUR/ano)" value={seguro} onChange={setSeguro} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Seguro obrigatorio se houver credito. Recomendado em todos os casos.</div>
                </div>
                <div>
                  <NumInput label="Condominio (EUR/ano)" value={cond} onChange={setCond} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Quota mensal de condominio x 12 meses. Inclui limpeza, elevador, espacos comuns.</div>
                </div>
                <div>
                  <NumInput label="Manutencao e reparacoes (EUR/ano)" value={manut} onChange={setManut} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Provisao anual para reparacoes. Regra geral: 1-2% do valor do imovel.</div>
                </div>
                <div>
                  <NumInput label="Gestao / agencia (% da renda anual)" value={gestaoPct} onChange={setGestaoPct} min={0} max={100} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Comissao de gestao se usar agencia imobiliaria. Tipicamente 5-10% da renda.</div>
                </div>
                <div>
                  <NumInput label="Outros gastos (EUR/ano)" value={outros} onChange={setOutros} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Certificado energetico, escrituras, registos, deslocacoes, etc.</div>
                </div>
              </div>
            </Card>

            {/* Simulador de crédito/leasing */}
            <Card>
              <div className="flex items-center justify-between mb-3">
                <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider">Credito / Leasing</div>
                <label className="flex items-center gap-2 text-[11px] text-[#6B7280]">
                  <input type="checkbox" checked={usarSimulador} onChange={(e) => setUsarSimulador(e.target.checked)} className="rounded" />
                  Simular prestacao
                </label>
              </div>

              {!usarSimulador ? (
                <div>
                  <NumInput label="Prestacao mensal do credito (EUR)" value={creditoMes} onChange={setCreditoMes} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Introduza manualmente ou active o simulador para calcular automaticamente.</div>
                </div>
              ) : (
                <div className="space-y-3">
                  <div>
                    <NumInput label="Montante do emprestimo (EUR)" value={montanteCredito} onChange={setMontanteCredito} step={1000} />
                    <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Valor total financiado. Tipicamente: valor imovel - capital proprio.</div>
                  </div>
                  <div>
                    <NumInput label="Prazo (anos)" value={prazoAnos} onChange={setPrazoAnos} min={1} max={40} />
                    <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Prazo do emprestimo ou leasing. Habitacao: 25-30 anos. Leasing: 10-20 anos.</div>
                  </div>
                  <div>
                    <div className="text-[11px] font-medium text-[#6B7280] mb-1">Taxa de referencia</div>
                    <div className="flex gap-1.5 mb-2">
                      {([
                        { id: '3m' as const, label: 'Euribor 3M' },
                        { id: '6m' as const, label: 'Euribor 6M' },
                        { id: '12m' as const, label: 'Euribor 12M' },
                        { id: 'fixa' as const, label: 'Taxa fixa' },
                      ]).map((t) => (
                        <button key={t.id} onClick={() => setEuriborTipo(t.id)}
                          className={`px-2.5 py-1 rounded text-[10px] font-medium transition-colors ${euriborTipo === t.id ? 'bg-brand-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
                          {t.label}
                        </button>
                      ))}
                    </div>
                    <div className="text-[10px] text-[#9CA3AF] mb-2 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Euribor: taxa variavel de referencia do BCE. A taxa pode ser consultada em euribor-rates.eu. Introduza o valor actual abaixo.</div>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <NumInput label={euriborTipo === 'fixa' ? 'Taxa fixa (%)' : `Euribor ${euriborTipo.toUpperCase()} (%)`} value={euriborManual} onChange={setEuriborManual} step={0.1} />
                    </div>
                    <div>
                      <NumInput label="Spread (%)" value={spread} onChange={setSpread} step={0.1} />
                      <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Margem do banco. Tipicamente 0.5-2%.</div>
                    </div>
                  </div>

                  {/* Resultado do simulador */}
                  <div className="rounded-lg p-3 mt-2" style={{ background: '#E1F5EE', border: '1px solid #9FE1CB' }}>
                    <div className="grid grid-cols-2 gap-3 text-[12px]">
                      <div>
                        <div className="text-[10px] text-[#085041] mb-0.5">Taxa total (Euribor + Spread)</div>
                        <div className="font-medium text-[#085041]">{taxaTotal.toFixed(2)}%</div>
                      </div>
                      <div>
                        <div className="text-[10px] text-[#085041] mb-0.5">Prestacao mensal</div>
                        <div className="font-bold text-[15px] text-[#085041]">{formatCurrency(prestacaoSimulada)}</div>
                      </div>
                      <div>
                        <div className="text-[10px] text-[#085041] mb-0.5">Total juros ({prazoAnos} anos)</div>
                        <div className="font-medium text-[#633806]">{formatCurrency(totalJuros)}</div>
                      </div>
                      <div>
                        <div className="text-[10px] text-[#085041] mb-0.5">Custo total (capital + juros)</div>
                        <div className="font-medium text-[#085041]">{formatCurrency(montanteCredito + totalJuros)}</div>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </Card>
          </div>

          {/* Right: Results */}
          <div>
            <div className="text-sm font-medium text-[#0D1B1A] mb-3 pb-2 border-b border-gray-200">Resultados</div>

            {/* Top 4 KPIs */}
            <div className="grid grid-cols-2 xl:grid-cols-4 gap-2.5 mb-3">
              <div>
                <KpiCard label="Yield bruta" value={fmtPct(calc.yb)} sub="renda/valor imovel" color={colorYb(calc.yb)} />
                <div className="text-[9px] text-[#9CA3AF] mt-0.5 px-1">ⓘ Renda anual / Valor imovel. Bom: &gt;5%</div>
              </div>
              <div>
                <KpiCard label="Yield liquida" value={fmtPct(calc.yl)} sub="apos custos operacionais" color={colorYl(calc.yl)} />
                <div className="text-[9px] text-[#9CA3AF] mt-0.5 px-1">ⓘ (Renda - Custos) / Valor. Bom: &gt;4%</div>
              </div>
              <div>
                <KpiCard label="ROI" value={fmtPct(calc.roi)} sub="sobre capital proprio" color={colorRoi(calc.roi)} />
                <div className="text-[9px] text-[#9CA3AF] mt-0.5 px-1">ⓘ Cash flow / Capital investido. Bom: &gt;6%</div>
              </div>
              <div>
                <KpiCard label="Payback capital" value={calc.pb_capital > 0 ? calc.pb_capital.toFixed(1) + ' anos' : '--'} sub="capital proprio" color={calc.pb_capital > 0 && calc.pb_capital <= 15 ? 'green' : calc.pb_capital <= 25 ? 'amber' : 'red'} />
                <div className="text-[9px] text-[#9CA3AF] mt-0.5 px-1">ⓘ Anos para recuperar o capital proprio investido</div>
              </div>
            </div>

            {/* Payback total + investimento */}
            {calc.investimentoTotal > 0 && (
              <div className="grid grid-cols-2 gap-2.5 mb-3">
                <div>
                  <KpiCard label="Payback total" value={calc.pb_total > 0 ? calc.pb_total.toFixed(1) + ' anos' : '--'} sub={`Investimento: ${formatCurrency(calc.investimentoTotal)}`} color={calc.pb_total > 0 && calc.pb_total <= 20 ? 'green' : calc.pb_total <= 30 ? 'amber' : 'red'} />
                  <div className="text-[9px] text-[#9CA3AF] mt-0.5 px-1">ⓘ Anos para recuperar capital + credito com o lucro operacional (antes do credito)</div>
                </div>
                <div>
                  <KpiCard label="Investimento total" value={formatCurrency(calc.investimentoTotal)} sub={`Capital: ${formatCurrency(capital)} + Credito: ${formatCurrency(calc.investimentoTotal - capital)}`} />
                  <div className="text-[9px] text-[#9CA3AF] mt-0.5 px-1">ⓘ Soma do capital proprio + montante financiado</div>
                </div>
              </div>
            )}

            {/* 3 KPIs */}
            <div className="grid grid-cols-3 gap-2.5 mb-3">
              <KpiCard label="Receita anual" value={formatCurrency(calc.receita)} />
              <KpiCard label="Custos totais" value={formatCurrency(calc.custos_total)} color="red" />
              <KpiCard label="Cash flow anual" value={(calc.cf_anual >= 0 ? '+' : '') + formatCurrency(calc.cf_anual)} color={colorCf(calc.cf_anual)} />
            </div>

            {/* Big KPI: Cash flow mensal */}
            <div className="rounded-lg p-4 mb-4" style={{ background: '#F3F4F6' }}>
              <div className="text-[11px] font-medium mb-1" style={{ color: '#6B7280' }}>Cash flow mensal medio</div>
              <div className="text-[28px] font-medium" style={{ color: calc.cf_mensal >= 0 ? '#0F6E56' : '#A32D2D' }}>
                {(calc.cf_mensal >= 0 ? '+' : '') + formatCurrency(calc.cf_mensal)}
              </div>
              <div className="text-[11px] mt-0.5" style={{ color: '#9CA3AF' }}>
                {calc.cf_mensal >= 0 ? 'fluxo positivo — o imovel paga-se' : 'fluxo negativo — requer injeccao mensal'}
              </div>
            </div>

            {/* Cost decomposition */}
            <Card className="mb-4">
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Decomposicao dos custos</div>
              {calc.costItems.map(item => (
                <CostBar key={item.name} name={item.name} value={item.value} max={calc.maxCost} isCredit={item.isCredit} />
              ))}
              {calc.costItems.length === 0 && (
                <div className="text-xs text-[#9CA3AF]">Sem custos registados</div>
              )}
            </Card>

            {/* Verdict */}
            <Card>
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Avaliacao</div>
              {calc.verdicts.map((v, i) => (
                <VerdictPill key={i} text={v.text} status={v.status} />
              ))}
            </Card>
          </div>
        </div>
      )}

      {/* ============================================================ */}
      {/*  TAB 2 — DSCR                                                */}
      {/* ============================================================ */}
      {tab === 'dscr' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {/* Left: Inputs */}
          <div className="space-y-4">
            <Card>
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Dados para DSCR</div>
              <div className="space-y-3">
                <NumInput label="Receita operacional anual (EUR)" value={dNoi} onChange={setDNoi} />
                <NumInput label="Custos operacionais anuais (EUR)" value={dOp} onChange={setDOp} />
                <NumInput label="Prestacao anual do credito (EUR)" value={dDebt} onChange={setDDebt} />
                <NumInput label="Valor do imovel (EUR)" value={dVal} onChange={setDVal} />
                <NumInput label="Divida em aberto (EUR)" value={dDiv} onChange={setDDiv} />
              </div>
            </Card>
            <div className="rounded-xl p-4 border" style={{ background: '#E1F5EE', borderColor: '#9FE1CB' }}>
              <div className="text-[11px] font-medium uppercase tracking-wider mb-2" style={{ color: '#085041' }}>O que e o DSCR?</div>
              <p className="text-xs leading-relaxed mb-2" style={{ color: '#085041' }}>
                O <strong>Debt Service Coverage Ratio</strong> mede quantas vezes o rendimento liquido cobre a prestacao do credito.
              </p>
              <p className="text-xs leading-relaxed" style={{ color: '#085041' }}>
                <strong>DSCR = NOI / Servico da divida</strong>
              </p>
              <div className="mt-2.5 text-[11px] leading-loose" style={{ color: '#0F6E56' }}>
                <div>&ge; 1.25 — excelente (banco aprova facilmente)</div>
                <div>1.00 - 1.25 — margem de seguranca reduzida</div>
                <div>&lt; 1.00 — imovel nao cobre a divida</div>
              </div>
            </div>
          </div>

          {/* Right: Results */}
          <div>
            <div className="text-sm font-medium text-[#0D1B1A] mb-3 pb-2 border-b border-gray-200">Resultados DSCR</div>

            <div className="grid grid-cols-3 gap-2.5 mb-4">
              <KpiCard label="NOI (lucro operacional)" value={formatCurrency(dscrCalc.noi)} sub="receita - custos op." color={dscrCalc.noi > 0 ? 'green' : 'red'} />
              <KpiCard label="Servico da divida" value={formatCurrency(dDebt)} sub="prestacoes/ano" color="red" />
              <KpiCard label="DSCR" value={dscrCalc.dscr.toFixed(2) + 'x'} sub={dscrCalc.dscrLabel} color={colorDscr(dscrCalc.dscr)} />
            </div>

            {/* Gauge */}
            <Card className="mb-4">
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Gauge DSCR</div>
              <div className="flex flex-col items-center gap-1.5 py-2">
                <div className="w-full flex justify-between text-[11px] text-[#9CA3AF] mb-1">
                  <span>0.0</span><span>1.0</span><span>1.25</span><span>2.0+</span>
                </div>
                <div className="w-full h-[18px] rounded-full overflow-hidden flex">
                  <div className="basis-1/2 shrink-0" style={{ background: '#FCEBEB' }} />
                  <div className="basis-[12.5%] shrink-0" style={{ background: '#FAEEDA' }} />
                  <div className="basis-[37.5%] shrink-0" style={{ background: '#EAF3DE' }} />
                </div>
                <div className="w-full relative h-3.5">
                  <div
                    className="absolute top-0 w-0.5 h-3.5 rounded-sm transition-all duration-300"
                    style={{ background: '#0D1B1A', left: `${dscrCalc.arrowPct}%` }}
                  />
                </div>
                <Badge
                  variant={dscrCalc.dscr >= 1.25 ? 'teal' : dscrCalc.dscr >= 1.0 ? 'amber' : 'red'}
                  className="px-3 py-1.5 text-[11px]"
                >
                  {dscrCalc.dscr >= 1.25
                    ? `DSCR ${dscrCalc.dscr.toFixed(2)}x — banco aprova facilmente`
                    : dscrCalc.dscr >= 1.0
                    ? `DSCR ${dscrCalc.dscr.toFixed(2)}x — margem reduzida`
                    : `DSCR ${dscrCalc.dscr.toFixed(2)}x — imovel nao cobre a divida`}
                </Badge>
              </div>
            </Card>

            {/* LTV */}
            <Card>
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">LTV — Loan to Value</div>
              <KpiCard
                label="Racio LTV"
                value={fmtPct(dscrCalc.ltv)}
                sub={dscrCalc.ltvLabel}
                color={dscrCalc.ltv <= 60 ? 'green' : dscrCalc.ltv <= 80 ? 'amber' : 'red'}
              />
              <p className="mt-3 text-[11px] text-[#6B7280] leading-relaxed">
                Bancos preferem LTV &le; 80%. Abaixo de 60% indica boa almofada de capital.
              </p>
            </Card>
          </div>
        </div>
      )}

      {/* ============================================================ */}
      {/*  TAB 3 — Ponto de Equilibrio                                 */}
      {/* ============================================================ */}
      {tab === 'breakeven' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {/* Left: Inputs */}
          <div className="space-y-4">
            <Card>
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Dados do imovel</div>
              <div className="space-y-3">
                <div>
                  <NumInput label="Renda mensal (EUR)" value={bRenda} onChange={setBRenda} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Valor mensal que cobra ao inquilino pelo arrendamento do imovel ou quarto.</div>
                </div>
                <div>
                  <NumInput label="Custos fixos anuais (EUR)" value={bFixos} onChange={setBFixos} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Custos que paga independentemente de ter o imovel arrendado: IMI, seguro, condominio, contabilidade, etc.</div>
                </div>
                <div>
                  <NumInput label="Prestacao credito/mes (EUR)" value={bCredito} onChange={setBCredito} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Prestacao mensal do credito habitacao ou emprestimo associado ao imovel. Deixe 0 se nao houver credito.</div>
                </div>
                <div>
                  <NumInput label="Custo variavel por mes arrendado (EUR)" value={bVar} onChange={setBVar} />
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Custos que so existem quando o imovel esta arrendado: agua, luz, gas, limpeza entre inquilinos, desgaste.</div>
                </div>
              </div>
            </Card>
            <div className="rounded-xl p-4 border" style={{ background: '#E6F1FB', borderColor: '#B5D4F4' }}>
              <div className="text-[11px] font-medium uppercase tracking-wider mb-2" style={{ color: '#0C447C' }}>Como interpretar</div>
              <p className="text-xs leading-relaxed" style={{ color: '#0C447C' }}>
                O ponto de equilibrio e o numero minimo de meses arrendados por ano para cobrir todos os custos fixos, variaveis e encargos de credito.
              </p>
              <p className="text-xs leading-relaxed mt-2" style={{ color: '#185FA5' }}>
                Essencial para imoveis de <strong>arrendamento sazonal</strong> ou com risco de periodos de vazio.
              </p>
            </div>
          </div>

          {/* Right: Results */}
          <div>
            <div className="text-sm font-medium text-[#0D1B1A] mb-3 pb-2 border-b border-gray-200">Resultados</div>

            <div className="grid grid-cols-3 gap-2.5 mb-4">
              <div>
                <KpiCard label="Custos totais/ano" value={formatCurrency(beCalc.custos_total)} color="red" />
                <div className="text-[10px] text-[#9CA3AF] mt-1 px-1 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Soma de todos os custos fixos + credito anual. Nao inclui custos variaveis (esses dependem da ocupacao).</div>
              </div>
              <div>
                <KpiCard
                  label="Break-even"
                  value={beCalc.be_c + ' meses'}
                  sub="meses/ano minimos"
                  color={beCalc.be_c <= 6 ? 'green' : beCalc.be_c <= 9 ? 'amber' : 'red'}
                />
                <div className="text-[10px] text-[#9CA3AF] mt-1 px-1 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Numero minimo de meses que precisa de ter o imovel arrendado para cobrir todos os custos. Abaixo deste valor, tem prejuizo.</div>
              </div>
              <div>
                <KpiCard
                  label="Margem de seguranca"
                  value={beCalc.margem + ' meses'}
                  sub="meses de folga"
                  color={beCalc.margem >= 4 ? 'green' : beCalc.margem >= 2 ? 'amber' : 'red'}
                />
                <div className="text-[10px] text-[#9CA3AF] mt-1 px-1 flex items-start gap-1"><span className="text-brand-primary font-bold">ⓘ</span> Meses de folga alem do break-even (12 - break-even). Quanto maior, mais seguro o investimento. Abaixo de 2 meses e arriscado.</div>
              </div>
            </div>

            {/* Calendar grid */}
            <Card className="mb-4">
              <div className="flex items-center gap-2 mb-3">
                <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider">Calendario anual</div>
                <div className="text-[10px] text-[#9CA3AF]">ⓘ Verde escuro = meses necessarios para cobrir custos | Verde claro = meses de lucro</div>
              </div>
              <div className="grid grid-cols-12 gap-1 mb-2.5">
                {MESES_PT.map((m, i) => {
                  const isRequired = i < beCalc.be_c
                  return (
                    <div
                      key={m}
                      className="rounded-[5px] py-1.5 text-center text-[10px] font-medium"
                      style={{
                        background: isRequired ? '#1D9E75' : '#EAF3DE',
                        color: isRequired ? '#fff' : '#27500A',
                        border: isRequired ? 'none' : '0.5px solid #9FE1CB',
                      }}
                    >
                      {m}
                    </div>
                  )
                })}
              </div>
              <div className="flex gap-3 text-[11px] text-[#6B7280]">
                <span className="flex items-center gap-1.5">
                  <span className="w-3 h-3 rounded-sm inline-block" style={{ background: '#1D9E75' }} />
                  Necessario
                </span>
                <span className="flex items-center gap-1.5">
                  <span className="w-3 h-3 rounded-sm inline-block border" style={{ background: '#EAF3DE', borderColor: '#9FE1CB' }} />
                  Margem
                </span>
              </div>
            </Card>

            {/* Scenarios table */}
            <Card>
              <div className="flex items-center gap-2 mb-3">
                <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider">Cenarios de ocupacao</div>
                <div className="text-[10px] text-[#9CA3AF]">ⓘ Simula o resultado para diferentes niveis de ocupacao ao longo do ano</div>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full border-collapse text-xs">
                  <thead>
                    <tr>
                      <th className="py-2 px-2.5 text-left text-[10px] font-medium text-[#9CA3AF] border-b border-gray-100 bg-[#F3F4F6]">Meses arrendado</th>
                      <th className="py-2 px-2.5 text-right text-[10px] font-medium text-[#9CA3AF] border-b border-gray-100 bg-[#F3F4F6]">Receita</th>
                      <th className="py-2 px-2.5 text-right text-[10px] font-medium text-[#9CA3AF] border-b border-gray-100 bg-[#F3F4F6]">Cash flow</th>
                      <th className="py-2 px-2.5 text-left text-[10px] font-medium text-[#9CA3AF] border-b border-gray-100 bg-[#F3F4F6]">Estado</th>
                    </tr>
                  </thead>
                  <tbody>
                    {beCalc.scenarios.map(s => (
                      <tr key={s.meses}>
                        <td className="py-2 px-2.5 border-b border-gray-50">{s.meses} meses</td>
                        <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums">{formatCurrency(s.receita)}</td>
                        <td className={`py-2 px-2.5 border-b border-gray-50 text-right tabular-nums font-medium ${s.cf >= 0 ? 'text-[#0F6E56]' : 'text-[#A32D2D]'}`}>
                          {(s.cf >= 0 ? '+' : '') + formatCurrency(s.cf)}
                        </td>
                        <td className="py-2 px-2.5 border-b border-gray-50">
                          {s.isBreakeven ? (
                            <Badge variant="amber">break-even</Badge>
                          ) : s.cf >= 0 ? (
                            <Badge variant="green">positivo</Badge>
                          ) : (
                            <Badge variant="red">prejuizo</Badge>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </Card>
          </div>
        </div>
      )}

      {/* ============================================================ */}
      {/*  TAB 4 — Portfolio                                           */}
      {/* ============================================================ */}
      {tab === 'portfolio' && (
        <div>
          {/* Add button */}
          <div className="flex items-center gap-3 mb-4">
            <Button onClick={() => setShowAddForm(!showAddForm)}>+ Adicionar imovel</Button>
            <span className="text-[11px] text-[#9CA3AF]">{imoveis.length} imoveis</span>
          </div>

          {/* Add form */}
          {showAddForm && (
            <Card className="mb-4">
              <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-3">Novo imovel</div>
              <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-3">
                <div>
                  <Input
                    label="Nome"
                    type="text"
                    value={newImovel.nome}
                    onChange={e => setNewImovel(prev => ({ ...prev, nome: e.target.value }))}
                    placeholder="Ex: Apt. Lisboa"
                  />
                </div>
                <NumInput label="Valor (EUR)" value={newImovel.valor} onChange={v => setNewImovel(prev => ({ ...prev, valor: v }))} />
                <NumInput label="Capital proprio (EUR)" value={newImovel.capital} onChange={v => setNewImovel(prev => ({ ...prev, capital: v }))} />
                <NumInput label="Renda mensal (EUR)" value={newImovel.renda} onChange={v => setNewImovel(prev => ({ ...prev, renda: v }))} />
                <NumInput label="Meses/ano" value={newImovel.meses} onChange={v => setNewImovel(prev => ({ ...prev, meses: v }))} min={1} max={12} />
                <NumInput label="Custos anuais (EUR)" value={newImovel.custos} onChange={v => setNewImovel(prev => ({ ...prev, custos: v }))} />
                <NumInput label="Credito/mes (EUR)" value={newImovel.credito} onChange={v => setNewImovel(prev => ({ ...prev, credito: v }))} />
              </div>
              <div className="flex gap-2">
                <Button onClick={addImovel}>Adicionar</Button>
                <Button variant="ghost" onClick={() => setShowAddForm(false)}>Cancelar</Button>
              </div>
            </Card>
          )}

          {/* Property cards grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2.5 mb-4">
            {imoveis.map(im => {
              const r = calcImovel(im)
              const rt = ratingImovel(r)
              return (
                <div
                  key={im.id}
                  className="bg-white border border-gray-100 rounded-xl p-3.5 hover:border-[#1D9E75] transition-colors"
                >
                  <div className="flex justify-between items-start mb-2">
                    <span className="font-medium text-[13px] text-[#0D1B1A]">{im.nome}</span>
                    <Badge variant={rt.variant}>{rt.t}</Badge>
                  </div>
                  <div className="grid grid-cols-3 gap-1.5">
                    <div>
                      <div className="text-[10px] text-[#9CA3AF]">Yield liq.</div>
                      <div className="text-[13px] font-medium" style={{ color: r.yl >= 4 ? '#0F6E56' : r.yl >= 2 ? '#854F0B' : '#A32D2D' }}>
                        {fmtPct(r.yl)}
                      </div>
                    </div>
                    <div>
                      <div className="text-[10px] text-[#9CA3AF]">CF/mes</div>
                      <div className="text-[13px] font-medium" style={{ color: r.cf_mensal >= 0 ? '#0F6E56' : '#A32D2D' }}>
                        {(r.cf_mensal >= 0 ? '+' : '') + formatCurrency(r.cf_mensal)}
                      </div>
                    </div>
                    <div>
                      <div className="text-[10px] text-[#9CA3AF]">ROI</div>
                      <div className="text-[13px] font-medium">{fmtPct(r.roi)}</div>
                    </div>
                  </div>
                  <div className="mt-2 text-[11px] text-[#9CA3AF]">
                    {formatCurrency(im.valor)} &middot; {formatCurrency(im.renda)}/mes &middot; {im.meses} meses/ano
                  </div>
                  <button
                    className="mt-2 px-2.5 py-1 rounded-md border border-gray-200 bg-transparent text-[11px] text-[#6B7280] hover:bg-gray-50 transition-colors"
                    onClick={() => removeImovel(im.id)}
                  >
                    Remover
                  </button>
                </div>
              )
            })}
          </div>

          {/* Comparison table */}
          <div className="text-sm font-medium text-[#0D1B1A] mb-3 pb-2 border-b border-gray-200">Comparacao do portfolio</div>
          <div className="overflow-x-auto mb-4">
            <table className="w-full border-collapse text-xs min-w-[700px]">
              <thead>
                <tr>
                  {['Imovel', 'Valor', 'Renda/mes', 'Yield bruta', 'Yield liq.', 'CF/mes', 'ROI', 'Payback', 'Rating'].map(h => (
                    <th key={h} className="py-2 px-2.5 text-left text-[10px] font-medium text-[#9CA3AF] border-b border-gray-100 bg-[#F3F4F6]">
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {imoveis.map(im => {
                  const r = calcImovel(im)
                  const rt = ratingImovel(r)
                  return (
                    <tr key={im.id}>
                      <td className="py-2 px-2.5 border-b border-gray-50 font-medium">{im.nome}</td>
                      <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums text-[11px]">{Math.round(im.valor / 1000)}k EUR</td>
                      <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums">{formatCurrency(im.renda)}</td>
                      <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums" style={{ color: r.yb >= 5 ? '#0F6E56' : r.yb >= 3 ? '#854F0B' : '#A32D2D' }}>
                        {fmtPct(r.yb)}
                      </td>
                      <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums" style={{ color: r.yl >= 4 ? '#0F6E56' : r.yl >= 2 ? '#854F0B' : '#A32D2D' }}>
                        {fmtPct(r.yl)}
                      </td>
                      <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums font-medium" style={{ color: r.cf_mensal >= 0 ? '#0F6E56' : '#A32D2D' }}>
                        {(r.cf_mensal >= 0 ? '+' : '') + formatCurrency(r.cf_mensal)}
                      </td>
                      <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums" style={{ color: r.roi >= 5 ? '#0F6E56' : r.roi >= 2 ? '#854F0B' : '#A32D2D' }}>
                        {fmtPct(r.roi)}
                      </td>
                      <td className="py-2 px-2.5 border-b border-gray-50 text-right tabular-nums">{r.pb > 0 ? r.pb.toFixed(1) + ' a' : '--'}</td>
                      <td className="py-2 px-2.5 border-b border-gray-50">
                        <Badge variant={rt.variant}>{rt.t}</Badge>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>

          {/* Portfolio summary KPIs */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-2.5">
            <KpiCard label="Valor total portfolio" value={formatCurrency(portfolioSummary.totalValor)} />
            <KpiCard label="Receita total/mes" value={formatCurrency(portfolioSummary.totalRenda)} color="green" />
            <KpiCard label="Cash flow total/mes" value={(portfolioSummary.totalCf >= 0 ? '+' : '') + formatCurrency(portfolioSummary.totalCf)} color={colorCf(portfolioSummary.totalCf)} />
            <KpiCard label="Yield media" value={fmtPct(portfolioSummary.avgYl)} />
          </div>
        </div>
      )}

      {/* ============================================================ */}
      {/*  Disclaimer                                                   */}
      {/* ============================================================ */}
      <div className="bg-white border border-gray-100 rounded-xl px-4 py-3 mt-5 text-[11px] text-[#6B7280] leading-relaxed">
        <strong>Aviso:</strong> Esta calculadora e uma ferramenta de apoio a decisao e nao constitui aconselhamento financeiro ou fiscal.
        Os valores apresentados sao estimativas baseadas nos dados introduzidos. Para decisoes de investimento, consulte um TOC ou consultor financeiro certificado.
        Nao inclui impacto de IRS sobre rendimentos prediais nem valorizacao do imovel.
      </div>
    </div>
  )
}
