import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { prisma } from '@/lib/prisma'

// ---------- Types ----------

export interface ConcentracaoTop3Imovel {
  imovelId: string
  nome: string
  receita: number
  percentagem: number
}

export interface ConcentracaoOutros {
  receita: number
  percentagem: number
  numeroImoveis: number
}

export interface ConcentracaoResponse {
  anoLectivoAtual: string
  receitaTotal: number
  top3: ConcentracaoTop3Imovel[]
  outros: ConcentracaoOutros
  top3Percentagem: number
  cr3Risk: 'baixo' | 'medio' | 'alto'
  numeroImoveisTotal: number
}

// ---------- Helpers ----------

function toNum(v: unknown): number {
  if (v === null || v === undefined) return 0
  return Number(v)
}

function getAnoLectivoBoundaries(ref: Date): { start: Date; end: Date; label: string } {
  const m = ref.getMonth()
  const y = ref.getFullYear()
  const startYear = m >= 8 ? y : y - 1
  const start = new Date(startYear, 8, 1)
  const end = new Date(startYear + 1, 8, 1)
  const label = `${startYear}/${String((startYear + 1) % 100).padStart(2, '0')}`
  return { start, end, label }
}

function classifyCr3(top3Pct: number): 'baixo' | 'medio' | 'alto' {
  if (top3Pct < 40) return 'baixo'
  if (top3Pct <= 60) return 'medio'
  return 'alto'
}

// ---------- Handler ----------

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const hoje = new Date()
    const al = getAnoLectivoBoundaries(hoje)

    // GERAL/PESSOAL sao centros de custo (buckets), nao imoveis reais
    const imoveisDb = await prisma.imovel.findMany({
      where: { ativo: true, tipo: { notIn: ['GERAL', 'PESSOAL'] } },
      select: { id: true, nome: true },
      orderBy: { codigo: 'asc' },
    })

    // Receita por imovel: classificacoes confirmadas (RECEITA) + lancamentos manuais (RECEITA)
    const [faturaClassificacoes, lancamentos] = await Promise.all([
      prisma.faturaClassificacao.findMany({
        where: {
          confirmado: true,
          fatura: { dataFatura: { gte: al.start, lt: al.end } },
        },
        include: { fatura: true, rubrica: true },
      }),
      prisma.lancamentoManual.findMany({
        where: { dataDoc: { gte: al.start, lt: al.end } },
        include: { rubrica: true },
      }),
    ])

    const receitaPorImovel = new Map<string, number>()
    for (const im of imoveisDb) receitaPorImovel.set(im.id, 0)

    for (const fc of faturaClassificacoes) {
      if (fc.rubrica.tipo !== 'RECEITA') continue
      const valor = fc.valorAtribuido ? toNum(fc.valorAtribuido) : toNum(fc.fatura.totalComIva)
      receitaPorImovel.set(fc.imovelId, (receitaPorImovel.get(fc.imovelId) ?? 0) + valor)
    }
    for (const lm of lancamentos) {
      if (lm.rubrica.tipo !== 'RECEITA') continue
      const valor = toNum(lm.totalComIva)
      receitaPorImovel.set(lm.imovelId, (receitaPorImovel.get(lm.imovelId) ?? 0) + valor)
    }

    const receitaTotal = Array.from(receitaPorImovel.values()).reduce((s, v) => s + v, 0)

    const ordenado = imoveisDb
      .map((im) => ({
        imovelId: im.id,
        nome: im.nome,
        receita: receitaPorImovel.get(im.id) ?? 0,
      }))
      .sort((a, b) => b.receita - a.receita)

    const top3Raw = ordenado.slice(0, 3)
    const restantes = ordenado.slice(3)

    const top3: ConcentracaoTop3Imovel[] = top3Raw.map((x) => ({
      ...x,
      percentagem: receitaTotal > 0 ? (x.receita / receitaTotal) * 100 : 0,
    }))
    const top3Receita = top3.reduce((s, x) => s + x.receita, 0)
    const outrosReceita = restantes.reduce((s, x) => s + x.receita, 0)
    const top3Percentagem = receitaTotal > 0 ? (top3Receita / receitaTotal) * 100 : 0

    const outros: ConcentracaoOutros = {
      receita: outrosReceita,
      percentagem: receitaTotal > 0 ? (outrosReceita / receitaTotal) * 100 : 0,
      numeroImoveis: restantes.length,
    }

    const response: ConcentracaoResponse = {
      anoLectivoAtual: al.label,
      receitaTotal,
      top3,
      outros,
      top3Percentagem,
      cr3Risk: classifyCr3(top3Percentagem),
      numeroImoveisTotal: imoveisDb.length,
    }

    return Response.json(response)
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) {
      return Response.json({ error: (e as Error).message }, { status: 403 })
    }
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
