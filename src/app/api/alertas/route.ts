import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

// ---------- helpers ----------

function toNum(v: unknown): number {
  if (v === null || v === undefined) return 0
  return Number(v)
}

function pct(numerator: number, denominator: number): number {
  return denominator !== 0 ? (numerator / denominator) * 100 : 0
}

function cfgNum(configs: Record<string, string>, key: string, fallback: number): number {
  const v = configs[key]
  return v !== undefined ? Number(v) : fallback
}

// ---------- threshold keys & defaults ----------

const THRESHOLD_KEYS = {
  alerta_yield_min: 5,
  alerta_ocupacao_min: 70,
  alerta_racio_min: 1.2,
  alerta_margem_min: 10,
} as const

type ThresholdKey = keyof typeof THRESHOLD_KEYS

interface Alerta {
  imovelId: string
  imovelNome: string
  tipo: 'Yield' | 'Ocupacao' | 'Racio Cobertura' | 'Margem'
  valor: number
  threshold: number
  severidade: 'critico' | 'aviso'
}

// ---------- GET ----------

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const ano = new Date().getFullYear()
    const dateStart = new Date(ano, 0, 1)
    const dateEnd = new Date(ano + 1, 0, 1)
    const dateStartExpanded = new Date(ano - 1, 11, 1)

    // 1. Load configurations
    const configRows = await prisma.configuracao.findMany()
    const configMap: Record<string, string> = {}
    for (const r of configRows) configMap[r.chave] = r.valor

    const thresholds = {
      alerta_yield_min: cfgNum(configMap, 'alerta_yield_min', THRESHOLD_KEYS.alerta_yield_min),
      alerta_ocupacao_min: cfgNum(configMap, 'alerta_ocupacao_min', THRESHOLD_KEYS.alerta_ocupacao_min),
      alerta_racio_min: cfgNum(configMap, 'alerta_racio_min', THRESHOLD_KEYS.alerta_racio_min),
      alerta_margem_min: cfgNum(configMap, 'alerta_margem_min', THRESHOLD_KEYS.alerta_margem_min),
    }

    // 2. Load active properties with fracoes
    const imoveisDb = await prisma.imovel.findMany({
      where: { ativo: true },
      include: {
        fracoes: { select: { id: true, nome: true, renda: true, estado: true, nifInquilino: true, dataEntradaMercado: true }, orderBy: { nome: 'asc' } },
      },
      orderBy: { codigo: 'asc' },
    })

    // 3. Load rubricas
    const rubricas = await prisma.rubrica.findMany()
    const rubricaMap = new Map(rubricas.map((r) => [r.id, r]))
    const rdaRubrica = rubricas.find((r) => r.codigo === 'RDA')
    const rdaRubricaId = rdaRubrica?.id ?? ''

    // 4. Load classified invoices in period
    const faturaClassificacoes = await prisma.faturaClassificacao.findMany({
      where: {
        confirmado: true,
        fatura: { dataFatura: { gte: dateStartExpanded, lt: dateEnd } },
      },
      include: { fatura: true },
    })

    // 5. Load manual entries in period
    const lancamentos = await prisma.lancamentoManual.findMany({
      where: { dataDoc: { gte: dateStartExpanded, lt: dateEnd } },
    })

    // ---------- Calculate per-property metrics ----------

    const alertas: Alerta[] = []

    for (const im of imoveisDb) {
      let receita = 0
      let rendaPaga = 0
      let custosOperacionais = 0

      // -- FaturaClassificacao --
      for (const fc of faturaClassificacoes) {
        if (fc.imovelId !== im.id) continue
        const rub = rubricaMap.get(fc.rubricaId)
        if (!rub) continue
        const valor = fc.valorAtribuido ? toNum(fc.valorAtribuido) : toNum(fc.fatura.totalComIva)
        const dataFatura = new Date(fc.fatura.dataFatura)
        const faturaAno = dataFatura.getFullYear()
        const mesIdx = dataFatura.getMonth()

        if (rub.tipo === 'RECEITA') {
          if (faturaAno === ano && mesIdx === 11) continue
          if (faturaAno === ano - 1 && mesIdx === 11) {
            receita += valor
          } else if (faturaAno === ano) {
            receita += valor
          }
        } else {
          if (faturaAno !== ano) continue
          if (fc.rubricaId === rdaRubricaId) {
            rendaPaga += valor
          } else {
            custosOperacionais += valor
          }
        }
      }

      // -- LancamentoManual --
      for (const lm of lancamentos) {
        if (lm.imovelId !== im.id) continue
        const rub = rubricaMap.get(lm.rubricaId)
        if (!rub) continue
        const valor = toNum(lm.totalComIva)
        const dataDoc = new Date(lm.dataDoc)
        const lmAno = dataDoc.getFullYear()
        const mesIdx = dataDoc.getMonth()

        if (rub.tipo === 'RECEITA') {
          if (lmAno === ano && mesIdx === 11) continue
          if (lmAno === ano - 1 && mesIdx === 11) {
            receita += valor
          } else if (lmAno === ano) {
            receita += valor
          }
        } else {
          if (lmAno !== ano) continue
          if (lm.rubricaId === rdaRubricaId) {
            rendaPaga += valor
          } else {
            custosOperacionais += valor
          }
        }
      }

      const custoTotal = rendaPaga + custosOperacionais
      const margemBruta = receita - rendaPaga
      const valorPatrimonial = im.valorPatrimonial !== null ? toNum(im.valorPatrimonial) : null

      // Occupancy
      const receitaPorFracao = new Map<string, { total: number; count: number }>()
      for (const fc of faturaClassificacoes) {
        if (fc.imovelId !== im.id || !fc.fracaoId) continue
        const rub = rubricaMap.get(fc.rubricaId)
        if (!rub || rub.tipo !== 'RECEITA') continue
        const entry = receitaPorFracao.get(fc.fracaoId) || { total: 0, count: 0 }
        entry.total += fc.valorAtribuido ? toNum(fc.valorAtribuido) : toNum(fc.fatura.totalComIva)
        entry.count += 1
        receitaPorFracao.set(fc.fracaoId, entry)
      }
      for (const lm of lancamentos) {
        if (lm.imovelId !== im.id || !lm.fracaoId) continue
        const rub = rubricaMap.get(lm.rubricaId)
        if (!rub || rub.tipo !== 'RECEITA') continue
        const entry = receitaPorFracao.get(lm.fracaoId) || { total: 0, count: 0 }
        entry.total += toNum(lm.totalComIva)
        entry.count += 1
        receitaPorFracao.set(lm.fracaoId, entry)
      }

      const now = new Date()
      const mesesRef = ano < now.getFullYear() ? 12 : Math.max(now.getMonth(), 1)

      let totalMesesPossiveis = 0
      let totalMesesOcupados = 0
      for (const f of im.fracoes) {
        let mesesDisponiveis = mesesRef
        const entradaMercado = f.dataEntradaMercado ? new Date(f.dataEntradaMercado) : null
        if (entradaMercado && entradaMercado.getFullYear() <= ano) {
          if (entradaMercado.getFullYear() === ano) {
            mesesDisponiveis = Math.max(mesesRef - entradaMercado.getMonth(), 0)
          }
        }
        const recData = receitaPorFracao.get(f.id)
        const mesesOcupado = Math.min(recData?.count || 0, mesesDisponiveis)
        totalMesesPossiveis += mesesDisponiveis
        totalMesesOcupados += mesesOcupado
      }

      const ocupacaoPct = totalMesesPossiveis > 0 ? pct(totalMesesOcupados, totalMesesPossiveis) : null
      const yieldBruta = valorPatrimonial ? (receita / valorPatrimonial) * 100 : null
      const ratiCobertura = rendaPaga !== 0 ? receita / rendaPaga : 0
      const margemBrutaPct = pct(margemBruta, receita)

      // Check thresholds and generate alerts
      function addAlert(tipo: Alerta['tipo'], valor: number | null, threshold: number) {
        if (valor === null) return
        if (valor < threshold) {
          const severidade: Alerta['severidade'] = valor < threshold * 0.7 ? 'critico' : 'aviso'
          alertas.push({
            imovelId: im.id,
            imovelNome: im.nome,
            tipo,
            valor: Math.round(valor * 100) / 100,
            threshold,
            severidade,
          })
        }
      }

      addAlert('Yield', yieldBruta, thresholds.alerta_yield_min)
      addAlert('Ocupacao', ocupacaoPct, thresholds.alerta_ocupacao_min)
      addAlert('Racio Cobertura', ratiCobertura > 0 ? ratiCobertura : null, thresholds.alerta_racio_min)
      addAlert('Margem', receita > 0 ? margemBrutaPct : null, thresholds.alerta_margem_min)
    }

    // Sort: critico first
    alertas.sort((a, b) => (a.severidade === 'critico' ? 0 : 1) - (b.severidade === 'critico' ? 0 : 1))

    return Response.json({ data: { thresholds, alertas } })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

// ---------- PUT ----------

export async function PUT(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const body = await req.json()
    const validKeys = Object.keys(THRESHOLD_KEYS) as ThresholdKey[]

    for (const key of validKeys) {
      if (body[key] !== undefined) {
        const valor = String(body[key])
        await prisma.configuracao.upsert({
          where: { chave: key },
          update: { valor },
          create: { chave: key, valor },
        })
      }
    }

    return Response.json({ ok: true })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
