'use client'

import { useEffect, useState, Fragment } from 'react'
import { useSession } from 'next-auth/react'
import Link from 'next/link'
import { ChevronDown, ChevronRight, LayoutGrid, List } from 'lucide-react'
import { KpiCard } from '@/components/ui/KpiCard'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { formatCurrency, formatDate } from '@/lib/utils'
import type { Role } from '@/lib/permissions'
import {
  ResponsiveContainer, ComposedChart, Bar, Line,
  XAxis, YAxis, Tooltip, CartesianGrid, Legend,
  BarChart,
} from 'recharts'

const MESES = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiData = any

export default function DashboardPage() {
  const { data: session } = useSession()
  const role = (session?.user as { role?: Role } | undefined)?.role
  const nome = (session?.user as { nome?: string } | undefined)?.nome ?? ''

  const [analise, setAnalise] = useState<ApiData>(null)
  const [pendentes, setPendentes] = useState<ApiData[]>([])
  const [loading, setLoading] = useState(true)
  const [vista, setVista] = useState<'detalhada' | 'simples'>('detalhada')
  const [expandedId, setExpandedId] = useState<string | null>(null)
  const [ano, setAno] = useState(new Date().getFullYear())
  const [anosDisponiveis, setAnosDisponiveis] = useState<number[]>([new Date().getFullYear()])

  const isFinancial = role === 'ADMIN' || role === 'GESTOR'

  // Detect available years from data
  useEffect(() => {
    fetch('/api/anos')
      .then((r) => r.json())
      .then((j) => { if (j.data) setAnosDisponiveis(j.data) })
      .catch(() => {})
  }, [])

  useEffect(() => {
    setLoading(true)
    const promises: Promise<void>[] = []

    if (isFinancial) {
      promises.push(
        fetch(`/api/analise?ano=${ano}`)
          .then((r) => r.json())
          .then((j) => { if (j.data) setAnalise(j.data) })
          .catch(() => {})
      )
    }

    promises.push(
      fetch(`/api/faturas/pendentes?ano=${ano}`)
        .then((r) => r.json())
        .then((j) => { if (j.data) setPendentes(j.data) })
        .catch(() => {})
    )

    Promise.all(promises).finally(() => setLoading(false))
  }, [isFinancial, ano])

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>

  // OPERADOR view
  if (!isFinancial) {
    return (
      <div className="space-y-5">
        <h2 className="text-lg font-medium" style={{ color: '#0D1B1A' }}>Boas-vindas, {nome}.</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-2xl">
          <Link href="/pendentes">
            <Card className="hover:border-brand-primary transition-colors cursor-pointer">
              <div className="text-[11px] font-medium text-[#6B7280] mb-1">Faturas pendentes</div>
              <div className="text-xl font-medium" style={{ color: '#633806' }}>{pendentes.length}</div>
              <div className="text-[11px] text-[#9CA3AF] mt-1">Por classificar</div>
            </Card>
          </Link>
          <Link href="/importar">
            <Card className="hover:border-brand-primary transition-colors cursor-pointer">
              <div className="text-[11px] font-medium text-[#6B7280] mb-1">Importar</div>
              <div className="text-xl font-medium" style={{ color: '#0D1B1A' }}>CSV</div>
              <div className="text-[11px] text-[#9CA3AF] mt-1">Importar ficheiro e-Fatura</div>
            </Card>
          </Link>
          <Link href="/lancamentos">
            <Card className="hover:border-brand-primary transition-colors cursor-pointer">
              <div className="text-[11px] font-medium text-[#6B7280] mb-1">Lancamentos</div>
              <div className="text-xl font-medium" style={{ color: '#0D1B1A' }}>Novo</div>
              <div className="text-[11px] text-[#9CA3AF] mt-1">Criar lancamento manual</div>
            </Card>
          </Link>
        </div>
      </div>
    )
  }

  // ADMIN / GESTOR — data
  const g = analise?.global || {}
  const irc = analise?.irc || {}
  const imoveis: ApiData[] = analise?.imoveis || []
  const evolucao = (analise?.evolucaoMensal || []).map((m: ApiData, i: number) => ({
    mes: MESES[i] || `M${i + 1}`,
    receita: m.receita || 0,
    custos: m.custos || 0,
    resultado: m.resultado || 0,
  }))

  // Separar imoveis reais de centros de custo
  const CENTROS_CUSTO = ['GERAL', 'PESSOAL']
  const imoveisReais = imoveis.filter((im: ApiData) => !CENTROS_CUSTO.includes(im.tipo))
  const centrosCusto = imoveis.filter((im: ApiData) => CENTROS_CUSTO.includes(im.tipo))

  // Occupancy (só imóveis reais)
  const totalFracoes = imoveisReais.reduce((s: number, im: ApiData) => s + (im.ocupacao?.total || 0), 0)
  const totalMesesOcupados = imoveisReais.reduce((s: number, im: ApiData) => s + (im.ocupacao?.ocupados || 0), 0)
  const totalMesesPossiveis = imoveisReais.reduce((s: number, im: ApiData) => s + (im.ocupacao?.totalMeses || 0), 0)
  const taxaOcupacao = totalMesesPossiveis > 0 ? Math.round((totalMesesOcupados / totalMesesPossiveis) * 100) : 0

  // Rentabilidade por imovel (sorted worst to best, só reais)
  const rentabilidade = [...imoveisReais]
    .filter((im: ApiData) => (im.receita || 0) > 0 || (im.custoTotal || 0) > 0)
    .sort((a: ApiData, b: ApiData) => (a.resultadoLiquidoPct || 0) - (b.resultadoLiquidoPct || 0))
    .map((im: ApiData) => ({
      nome: im.nome,
      margem: im.resultadoLiquidoPct || 0,
      fill: (im.resultadoLiquidoPct || 0) >= 0 ? '#1D9E75' : '#E24B4A',
    }))

  // Pendentes por atraso
  const pendentesUrgentes = pendentes.slice(0, 5)

  // =================== VISTA SIMPLES (original) ===================
  if (vista === 'simples') {
    return (
      <div className="space-y-5">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <h2 className="text-sm font-medium" style={{ color: '#0D1B1A' }}>Dashboard</h2>
            <div className="flex items-center gap-1">
              {anosDisponiveis.map((y) => (
                <button key={y} onClick={() => setAno(y)}
                  className={`px-2.5 py-1 rounded text-[11px] font-medium transition-colors ${ano === y ? 'bg-brand-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
                  {y}
                </button>
              ))}
            </div>
          </div>
          <button onClick={() => setVista('detalhada')} className="flex items-center gap-1.5 text-[11px] text-brand-primary hover:underline">
            <LayoutGrid size={14} /> Vista detalhada
          </button>
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Receita total" value={formatCurrency(g.receitaTotal || 0)} color="green" />
          <KpiCard label="Gastos totais" value={formatCurrency(g.custoTotal || 0)} color="red" />
          <KpiCard label="Resultado liquido" value={formatCurrency(g.resultadoLiquido || 0)} color={(g.resultadoLiquido || 0) >= 0 ? 'green' : 'red'} />
          <KpiCard label="Pendentes" value={String(pendentes.length)} color="amber" sub="faturas por classificar" />
        </div>

        <Card>
          <h3 className="text-[13px] font-medium mb-3" style={{ color: '#0D1B1A' }}>Resultados por imovel</h3>
          <table className="w-full text-left text-[13px]">
            <thead>
              <tr>
                <th className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100">Imovel</th>
                <th className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Receita</th>
                <th className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Gastos</th>
                <th className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Resultado</th>
              </tr>
            </thead>
            <tbody>
              {imoveis.filter((im: ApiData) => (im.receita || 0) > 0 || (im.custoTotal || 0) > 0).map((im: ApiData) => (
                <tr key={im.id}>
                  <td className="px-3 py-2.5 border-b border-gray-50 font-medium">{im.nome}</td>
                  <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#0F6E56' }}>{formatCurrency(im.receita || 0)}</td>
                  <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#A32D2D' }}>{formatCurrency(im.custoTotal || 0)}</td>
                  <td className="px-3 py-2.5 border-b border-gray-50 text-right font-medium" style={{ color: (im.resultadoLiquido || 0) >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(im.resultadoLiquido || 0)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      </div>
    )
  }

  // =================== VISTA DETALHADA (nova) ===================
  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <h2 className="text-sm font-medium" style={{ color: '#0D1B1A' }}>Dashboard</h2>
          <div className="flex items-center gap-1">
            {anosDisponiveis.map((y) => (
              <button
                key={y}
                onClick={() => setAno(y)}
                className={`px-2.5 py-1 rounded text-[11px] font-medium transition-colors ${
                  ano === y ? 'bg-brand-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                {y}
              </button>
            ))}
          </div>
        </div>
        <button onClick={() => setVista('simples')} className="flex items-center gap-1.5 text-[11px] text-brand-primary hover:underline">
          <List size={14} /> Vista simples
        </button>
      </div>

      {/* 6 KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        <KpiCard label="Receita mensal" value={formatCurrency((g.receitaTotal || 0) / Math.max(new Date().getMonth() + 1, 1))} color="green" sub={`Total: ${formatCurrency(g.receitaTotal || 0)}`} />
        <KpiCard label="Gastos mensais" value={formatCurrency((g.custoTotal || 0) / Math.max(new Date().getMonth() + 1, 1))} color="red" sub={`Total: ${formatCurrency(g.custoTotal || 0)}`} />
        <KpiCard label="Resultado liquido" value={formatCurrency(g.resultadoLiquido || 0)} color={(g.resultadoLiquido || 0) >= 0 ? 'green' : 'red'} sub={`Margem: ${(g.margemBrutaPct || 0).toFixed(1)}%`} />
        <KpiCard label="Taxa ocupacao" value={`${taxaOcupacao}%`} color={taxaOcupacao > 80 ? 'green' : taxaOcupacao > 50 ? 'amber' : 'red'} sub={`${totalMesesOcupados}/${totalMesesPossiveis} meses·quarto`} />
        <KpiCard label="Pendentes" value={String(pendentes.length)} color={pendentes.length > 0 ? 'amber' : 'green'} sub="faturas por classificar" />
        <KpiCard label="IRC estimado" value={formatCurrency(irc.ircTotal || 0)} color="amber" sub={`Taxa: ${(irc.taxaEfetiva || 0).toFixed(1)}%`} />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
        {/* Receita vs Gastos — 60% */}
        <Card className="lg:col-span-3">
          <h3 className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wide mb-3">Receita vs Gastos</h3>
          <div style={{ width: '100%', height: 280 }}>
            <ResponsiveContainer width="100%" height="100%">
              <ComposedChart data={evolucao}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="mes" tick={{ fontSize: 10, fill: '#6B7280' }} />
                <YAxis tick={{ fontSize: 10, fill: '#6B7280' }} tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Legend wrapperStyle={{ fontSize: 11 }} />
                <Bar dataKey="receita" name="Receita" fill="#1D9E75" radius={[3, 3, 0, 0]} />
                <Bar dataKey="custos" name="Custos" fill="#D1D5DB" radius={[3, 3, 0, 0]} />
                <Line type="monotone" dataKey="resultado" name="Resultado" stroke="#0C447C" strokeWidth={2} dot={{ r: 2 }} />
              </ComposedChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Rentabilidade por Imovel — 40% */}
        <Card className="lg:col-span-2">
          <h3 className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wide mb-3">Rentabilidade por imovel</h3>
          {rentabilidade.length > 0 ? (
            <div style={{ width: '100%', height: 280 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={rentabilidade} layout="vertical" margin={{ left: 60 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                  <XAxis type="number" tick={{ fontSize: 10, fill: '#6B7280' }} tickFormatter={(v: number) => `${v}%`} />
                  <YAxis type="category" dataKey="nome" tick={{ fontSize: 10, fill: '#6B7280' }} width={55} />
                  <Tooltip formatter={(value) => `${Number(value).toFixed(1)}%`} />
                  <Bar dataKey="margem" name="Margem %" radius={[0, 3, 3, 0]}>
                    {rentabilidade.map((entry: { fill: string }, i: number) => (
                      <rect key={i} fill={entry.fill} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <div className="h-[280px] flex items-center justify-center text-[12px] text-gray-400">Sem dados</div>
          )}
        </Card>
      </div>

      {/* Quick action panels */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Faturas por classificar */}
        <Card>
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wide">Faturas por classificar</h3>
            <Badge variant={pendentes.length > 0 ? 'amber' : 'green'}>{pendentes.length}</Badge>
          </div>
          {pendentesUrgentes.length > 0 ? (
            <div className="space-y-2">
              {pendentesUrgentes.map((p: ApiData) => (
                <div key={p.id} className="flex items-center justify-between text-[12px]">
                  <span className="truncate flex-1" style={{ color: '#0D1B1A' }}>{p.nomeEmitente || p.nifEmitente}</span>
                  <span className="font-medium ml-2">{formatCurrency(Number(p.totalComIva))}</span>
                </div>
              ))}
              {pendentes.length > 5 && (
                <div className="text-[11px] text-gray-400">+{pendentes.length - 5} mais</div>
              )}
            </div>
          ) : (
            <div className="text-[12px] text-gray-400">Tudo classificado</div>
          )}
          <Link href="/pendentes" className="block mt-3 text-[11px] text-brand-primary hover:underline">
            {pendentes.length > 0 ? 'Classificar agora →' : 'Ver pendentes →'}
          </Link>
        </Card>

        {/* Retenções na fonte */}
        <Card>
          <h3 className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wide mb-3">Retencoes na fonte</h3>
          <div className="space-y-2 text-[12px]">
            <div className="flex justify-between">
              <span style={{ color: '#6B7280' }}>Rendas pagas (bruto)</span>
              <span className="font-medium">{formatCurrency(g.rendaPagaTotal || 0)}</span>
            </div>
            <div className="flex justify-between">
              <span style={{ color: '#6B7280' }}>Retencao 25%</span>
              <span className="font-medium" style={{ color: '#633806' }}>{formatCurrency((g.rendaPagaTotal || 0) * 0.25)}</span>
            </div>
            <div className="flex justify-between pt-2 border-t border-gray-100">
              <span style={{ color: '#6B7280' }}>A entregar a AT</span>
              <span className="font-medium">{formatCurrency((g.rendaPagaTotal || 0) * 0.25)}</span>
            </div>
          </div>
          <Link href="/irc" className="block mt-3 text-[11px] text-brand-primary hover:underline">Ver previsao IRC →</Link>
        </Card>

        {/* Acções rápidas */}
        <Card>
          <h3 className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wide mb-3">Acoes rapidas</h3>
          <div className="space-y-2">
            <Link href="/importar" className="block px-3 py-2 rounded-lg bg-gray-50 hover:bg-brand-light text-[12px] font-medium transition-colors" style={{ color: '#0D1B1A' }}>
              Importar CSV e-Fatura
            </Link>
            <Link href="/lancamentos" className="block px-3 py-2 rounded-lg bg-gray-50 hover:bg-brand-light text-[12px] font-medium transition-colors" style={{ color: '#0D1B1A' }}>
              Novo lancamento manual
            </Link>
            <Link href="/analise" className="block px-3 py-2 rounded-lg bg-gray-50 hover:bg-brand-light text-[12px] font-medium transition-colors" style={{ color: '#0D1B1A' }}>
              Analise financeira
            </Link>
          </div>
        </Card>
      </div>

      {/* Resumo por Imovel — expandível */}
      <Card className="p-0">
        <div className="px-5 pt-4 pb-2">
          <h3 className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wide">Resumo por imovel</h3>
        </div>
        <table className="w-full text-left text-[13px]">
          <thead>
            <tr>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100 w-6" />
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100">Imovel</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100">Quartos</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100">Ocupacao</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Receita</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Gastos</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Resultado</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Margem</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100 text-right">Potencial 100%</th>
              <th className="px-3 py-2 text-[10px] font-medium text-[#6B7280] border-b border-gray-100 text-right">% Potencial</th>
            </tr>
          </thead>
          <tbody>
            {/* Centros de custo (sem ocupação/potencial) */}
            {centrosCusto.filter((cc: ApiData) => (cc.custoTotal || 0) > 0).map((cc: ApiData) => (
              <tr key={cc.id} className="hover:bg-gray-50">
                <td className="px-2 py-2.5 border-b border-gray-50"><span className="w-3.5 inline-block" /></td>
                <td className="px-3 py-2.5 border-b border-gray-50 font-medium text-gray-500">{cc.nome}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-gray-400">—</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-gray-400">—</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#6B7280' }}>{formatCurrency(cc.receita || 0)}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#A32D2D' }}>{formatCurrency(cc.custoTotal || 0)}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right font-medium" style={{ color: '#A32D2D' }}>{formatCurrency(cc.resultadoLiquido || 0)}</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right text-gray-400">—</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right text-gray-400">—</td>
                <td className="px-3 py-2.5 border-b border-gray-50 text-right text-gray-400">—</td>
              </tr>
            ))}
            {/* Imoveis reais */}
            {imoveisReais.map((im: ApiData) => {
              const hasFracoes = (im.fracoes?.length || 0) > 0
              const isExpanded = expandedId === im.id
              return (
                <Fragment key={im.id}>
                  <tr className={`${isExpanded ? 'bg-[#F4FAF8]' : 'hover:bg-gray-50'} ${hasFracoes ? 'cursor-pointer' : ''}`}
                    onClick={() => hasFracoes && setExpandedId(isExpanded ? null : im.id)}>
                    <td className="px-2 py-2.5 border-b border-gray-50">
                      {hasFracoes ? (
                        isExpanded ? <ChevronDown size={14} className="text-brand-primary" /> : <ChevronRight size={14} className="text-gray-400" />
                      ) : <span className="w-3.5 inline-block" />}
                    </td>
                    <td className="px-3 py-2.5 border-b border-gray-50 font-medium" style={{ color: '#0D1B1A' }}>{im.nome}</td>
                    <td className="px-3 py-2.5 border-b border-gray-50">
                      {im.ocupacao ? `${im.ocupacao.total}` : '—'}
                    </td>
                    <td className="px-3 py-2.5 border-b border-gray-50">
                      {im.ocupacao ? (
                        <Badge variant={im.ocupacao.pct >= 90 ? 'green' : im.ocupacao.pct > 0 ? 'amber' : 'red'}>
                          {Number(im.ocupacao.pct).toFixed(0)}%
                        </Badge>
                      ) : '—'}
                    </td>
                    <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#0F6E56' }}>{formatCurrency(im.receita || 0)}</td>
                    <td className="px-3 py-2.5 border-b border-gray-50 text-right" style={{ color: '#A32D2D' }}>{formatCurrency(im.custoTotal || 0)}</td>
                    <td className="px-3 py-2.5 border-b border-gray-50 text-right font-medium" style={{ color: (im.resultadoLiquido || 0) >= 0 ? '#0F6E56' : '#A32D2D' }}>
                      {formatCurrency(im.resultadoLiquido || 0)}
                    </td>
                    <td className="px-3 py-2.5 border-b border-gray-50 text-right">
                      <span style={{ color: (im.resultadoLiquidoPct || 0) > 20 ? '#0F6E56' : (im.resultadoLiquidoPct || 0) > 10 ? '#633806' : '#A32D2D' }}>
                        {(im.resultadoLiquidoPct || 0).toFixed(1)}%
                      </span>
                    </td>
                    {(() => {
                      const potencialAnual = im.potencialAnual || 0
                      const pctPotencial = im.pctPotencial || 0
                      return (
                        <>
                          <td className="px-3 py-2.5 border-b border-gray-50 text-right text-[12px]" style={{ color: '#6B7280' }}>
                            {potencialAnual > 0 ? formatCurrency(potencialAnual) : '—'}
                          </td>
                          <td className="px-3 py-2.5 border-b border-gray-50 text-right">
                            {potencialAnual > 0 ? (
                              <span className="font-medium" style={{ color: pctPotencial >= 90 ? '#0F6E56' : pctPotencial >= 70 ? '#633806' : '#A32D2D' }}>
                                {pctPotencial.toFixed(0)}%
                              </span>
                            ) : '—'}
                          </td>
                        </>
                      )
                    })()}
                  </tr>
                  {isExpanded && hasFracoes && (
                    <tr>
                      <td colSpan={10} className="bg-[#FAFBFC] px-8 py-2 border-b border-gray-100">
                        <table className="w-full text-[12px]">
                          <thead>
                            <tr>
                              <th className="text-[10px] font-medium text-gray-400 pb-1 text-left">Quarto</th>
                              <th className="text-[10px] font-medium text-gray-400 pb-1 text-left">Inquilino</th>
                              <th className="text-[10px] font-medium text-gray-400 pb-1 text-right">Renda</th>
                              <th className="text-[10px] font-medium text-gray-400 pb-1 text-left">Estado</th>
                            </tr>
                          </thead>
                          <tbody>
                            {(im.fracoes || []).map((f: ApiData) => (
                              <tr key={f.id} className="border-t border-gray-100">
                                <td className="py-1 font-medium">{f.nome}</td>
                                <td className="py-1 font-mono text-[11px] text-gray-500">{f.nifInquilino || '—'}</td>
                                <td className="py-1 text-right font-mono">{formatCurrency(Number(f.renda))}</td>
                                <td className="py-1">
                                  <Badge variant={f.estado === 'OCUPADO' ? 'green' : f.estado === 'VAGO' ? 'red' : 'amber'}>
                                    {f.estado}
                                  </Badge>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  )}
                </Fragment>
              )
            })}
            {/* Totais */}
            <tr className="border-t-2 border-brand-black">
              <td className="px-2 py-2.5" />
              <td className="px-3 py-2.5 font-bold" style={{ color: '#0D1B1A' }}>TOTAIS</td>
              <td className="px-3 py-2.5 font-bold">{totalFracoes}</td>
              <td className="px-3 py-2.5"><Badge variant={taxaOcupacao === 100 ? 'green' : 'amber'}>{taxaOcupacao}%</Badge></td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: '#0F6E56' }}>{formatCurrency(g.receitaTotal || 0)}</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: '#A32D2D' }}>{formatCurrency(g.custoTotal || 0)}</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: (g.resultadoLiquido || 0) >= 0 ? '#0F6E56' : '#A32D2D' }}>{formatCurrency(g.resultadoLiquido || 0)}</td>
              <td className="px-3 py-2.5 text-right font-bold" style={{ color: (g.margemBrutaPct || 0) > 20 ? '#0F6E56' : '#633806' }}>{(g.margemBrutaPct || 0).toFixed(1)}%</td>
              {(() => {
                const potencialAnualTotal = imoveisReais.reduce((s: number, im: ApiData) => s + (im.potencialAnual || 0), 0)
                const pctTotal = potencialAnualTotal > 0 ? Math.min(((g.receitaTotal || 0) / potencialAnualTotal) * 100, 100) : 0
                return (
                  <>
                    <td className="px-3 py-2.5 text-right font-bold" style={{ color: '#6B7280' }}>{potencialAnualTotal > 0 ? formatCurrency(potencialAnualTotal) : '—'}</td>
                    <td className="px-3 py-2.5 text-right font-bold" style={{ color: pctTotal >= 90 ? '#0F6E56' : pctTotal >= 70 ? '#633806' : '#A32D2D' }}>{potencialAnualTotal > 0 ? `${pctTotal.toFixed(0)}%` : '—'}</td>
                  </>
                )
              })()}
            </tr>
          </tbody>
        </table>
      </Card>
    </div>
  )
}
