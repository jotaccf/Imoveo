import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { prisma } from '@/lib/prisma'

// ---------- Types ----------

export interface PipelinePorImovel {
  id: string
  nome: string
  totalQuartos: number
  quartosEmRisco: number
  receitaEmRisco: number
}

export interface PipelineContratoCritico {
  contratoId: string
  fracaoNome: string
  imovelNome: string
  dataFim: string
  diasRestantes: number
  renda: number
  inquilino: string | null
  renovacaoAutomatica: boolean
}

export interface PipelineResponse {
  janelaDias: number
  totalQuartos: number
  quartosEmRisco: number
  percentagemEmRisco: number
  receitaEmRisco: number
  porImovel: PipelinePorImovel[]
  contratosCriticos: PipelineContratoCritico[]
}

// ---------- Handler ----------

const JANELA_DIAS = 90

function toNum(v: unknown): number {
  if (v === null || v === undefined) return 0
  return Number(v)
}

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const hoje = new Date()
    hoje.setHours(0, 0, 0, 0)
    const limite = new Date(hoje.getTime() + JANELA_DIAS * 24 * 60 * 60 * 1000)

    // Total de quartos (fracoes de imoveis activos) — GERAL/PESSOAL sao centros de custo
    const imoveisAtivos = await prisma.imovel.findMany({
      where: { ativo: true, tipo: { notIn: ['GERAL', 'PESSOAL'] } },
      include: { fracoes: { select: { id: true } } },
    })
    const totalQuartos = imoveisAtivos.reduce((s, im) => s + im.fracoes.length, 0)

    // Buscar contratos cuja dataFim cai dentro da janela e ainda ATIVOS
    const contratosCandidatos = await prisma.contrato.findMany({
      where: {
        estado: 'ATIVO',
        dataFim: { gte: hoje, lte: limite },
        imovel: { ativo: true, tipo: { notIn: ['GERAL', 'PESSOAL'] } },
      },
      include: {
        fracao: { select: { id: true, nome: true, renda: true } },
        imovel: { select: { id: true, nome: true } },
      },
      orderBy: { dataFim: 'asc' },
    })

    // Buscar todos os contratos para a mesma fracao com dataInicio > contrato.dataFim
    // (i.e. "successor" — quartos que ja tem contrato seguinte nao estao em risco)
    const fracaoIds = Array.from(new Set(contratosCandidatos.map((c) => c.fracaoId)))
    const successoresAll = fracaoIds.length > 0
      ? await prisma.contrato.findMany({
        where: {
          fracaoId: { in: fracaoIds },
          estado: { in: ['ATIVO', 'EXPIRADO'] },
        },
        select: { id: true, fracaoId: true, dataInicio: true },
      })
      : []

    // Map: fracaoId -> lista de dataInicio
    const successoresPorFracao = new Map<string, Date[]>()
    for (const s of successoresAll) {
      const arr = successoresPorFracao.get(s.fracaoId) ?? []
      arr.push(s.dataInicio)
      successoresPorFracao.set(s.fracaoId, arr)
    }

    // Filtrar candidatos: em risco = sem sucessor com dataInicio > contrato.dataFim
    const emRisco = contratosCandidatos.filter((c) => {
      if (!c.dataFim) return false
      const inicios = successoresPorFracao.get(c.fracaoId) ?? []
      const temSucessor = inicios.some((di) => di.getTime() > c.dataFim!.getTime())
      return !temSucessor
    })

    // Agregacao por imovel
    const porImovelMap = new Map<string, PipelinePorImovel>()
    for (const im of imoveisAtivos) {
      porImovelMap.set(im.id, {
        id: im.id,
        nome: im.nome,
        totalQuartos: im.fracoes.length,
        quartosEmRisco: 0,
        receitaEmRisco: 0,
      })
    }
    // Conjunto de fracaoIds em risco — uma fracao so conta 1x mesmo com varios contratos
    const fracaoEmRisco = new Map<string, { imovelId: string; renda: number }>()
    for (const c of emRisco) {
      if (!fracaoEmRisco.has(c.fracaoId)) {
        fracaoEmRisco.set(c.fracaoId, {
          imovelId: c.imovelId,
          renda: toNum(c.fracao.renda),
        })
      }
    }
    for (const { imovelId, renda } of fracaoEmRisco.values()) {
      const e = porImovelMap.get(imovelId)
      if (e) {
        e.quartosEmRisco += 1
        e.receitaEmRisco += renda
      }
    }

    const quartosEmRisco = fracaoEmRisco.size
    const receitaEmRisco = Array.from(fracaoEmRisco.values()).reduce((s, x) => s + x.renda, 0)
    const percentagemEmRisco = totalQuartos > 0 ? (quartosEmRisco / totalQuartos) * 100 : 0

    // Contratos criticos: top 10 ordenados por diasRestantes ASC
    const contratosCriticos: PipelineContratoCritico[] = emRisco
      .map((c) => {
        const dataFim = c.dataFim!
        const diasRestantes = Math.ceil(
          (dataFim.getTime() - hoje.getTime()) / (24 * 60 * 60 * 1000),
        )
        return {
          contratoId: c.id,
          fracaoNome: c.fracao.nome,
          imovelNome: c.imovel.nome,
          dataFim: dataFim.toISOString(),
          diasRestantes,
          renda: toNum(c.fracao.renda),
          inquilino: c.nomeInquilino || null,
          renovacaoAutomatica: c.renovacaoAuto,
        }
      })
      .sort((a, b) => a.diasRestantes - b.diasRestantes)
      .slice(0, 10)

    const response: PipelineResponse = {
      janelaDias: JANELA_DIAS,
      totalQuartos,
      quartosEmRisco,
      percentagemEmRisco,
      receitaEmRisco,
      porImovel: Array.from(porImovelMap.values()),
      contratosCriticos,
    }

    return Response.json(response)
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) {
      return Response.json({ error: (e as Error).message }, { status: 403 })
    }
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
