import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:ver')

    const now = new Date()

    const [contratos, totalFracoes] = await Promise.all([
      prisma.contrato.findMany({
        include: {
          fracao: { select: { id: true, nome: true } },
          imovel: { select: { id: true, codigo: true, nome: true } },
        },
      }),
      prisma.fracao.count(),
    ])

    // Counts by state
    const byEstado = { ATIVO: 0, EXPIRADO: 0, TERMINADO: 0 }
    for (const c of contratos) {
      if (c.estado in byEstado) byEstado[c.estado as keyof typeof byEstado]++
    }

    // Active contracts
    const ativos = contratos.filter((c) => c.estado === 'ATIVO')

    // Total monthly revenue from active contracts
    const receitaMensal = ativos.reduce((sum, c) => sum + Number(c.valorRenda), 0)

    // Average duration (months) of active contracts
    let duracaoMedia = 0
    if (ativos.length > 0) {
      const totalMeses = ativos.reduce((sum, c) => {
        const inicio = new Date(c.dataInicio)
        const fim = c.dataFim ? new Date(c.dataFim) : now
        const meses = (fim.getFullYear() - inicio.getFullYear()) * 12 + (fim.getMonth() - inicio.getMonth())
        return sum + Math.max(meses, 1)
      }, 0)
      duracaoMedia = Math.round(totalMeses / ativos.length)
    }

    // Expiring in 30/60/90 days
    const expiring30: typeof contratos = []
    const expiring60: typeof contratos = []
    const expiring90: typeof contratos = []

    for (const c of ativos) {
      if (!c.dataFim) continue
      const diff = Math.ceil((new Date(c.dataFim).getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
      if (diff >= 0 && diff <= 90) {
        const item = { ...c, diasRestantes: diff }
        if (diff <= 30) expiring30.push(item)
        if (diff <= 60) expiring60.push(item)
        expiring90.push(item)
      }
    }

    // Sort expiring90 by days remaining ascending
    const upcoming = expiring90
      .map((c) => ({
        id: c.id,
        imovel: c.imovel.nome,
        fracao: c.fracao.nome,
        inquilino: c.nomeInquilino,
        dataFim: c.dataFim,
        diasRestantes: c.dataFim
          ? Math.ceil((new Date(c.dataFim).getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
          : null,
        renovacaoAuto: c.renovacaoAuto,
      }))
      .sort((a, b) => (a.diasRestantes ?? 999) - (b.diasRestantes ?? 999))

    // Monthly revenue projection (next 12 months)
    const projecaoMensal: { mes: string; receita: number }[] = []
    for (let i = 0; i < 12; i++) {
      const target = new Date(now.getFullYear(), now.getMonth() + i, 1)
      const targetEnd = new Date(now.getFullYear(), now.getMonth() + i + 1, 0)
      const mesLabel = target.toLocaleDateString('pt-PT', { month: 'short', year: '2-digit' })

      let receita = 0
      for (const c of ativos) {
        const inicio = new Date(c.dataInicio)
        const fim = c.dataFim ? new Date(c.dataFim) : null
        if (inicio <= targetEnd && (!fim || fim >= target)) {
          receita += Number(c.valorRenda)
        }
      }
      projecaoMensal.push({ mes: mesLabel, receita: Math.round(receita * 100) / 100 })
    }

    // Properties coverage
    const fracoesComContrato = new Set(ativos.map((c) => c.fracaoId)).size

    // Contracts needing attention
    const atencao: {
      id: string
      imovel: string
      fracao: string
      inquilino: string
      motivo: string
      estado: string
    }[] = []

    for (const c of contratos) {
      // Expired but still ATIVO
      if (c.estado === 'ATIVO' && c.dataFim && new Date(c.dataFim) < now) {
        atencao.push({
          id: c.id,
          imovel: c.imovel.nome,
          fracao: c.fracao.nome,
          inquilino: c.nomeInquilino,
          motivo: 'Expirado mas estado ATIVO',
          estado: c.estado,
        })
      }
      // Not communicated to AT
      if (c.estado === 'ATIVO' && !c.comunicadoAT) {
        atencao.push({
          id: c.id,
          imovel: c.imovel.nome,
          fracao: c.fracao.nome,
          inquilino: c.nomeInquilino,
          motivo: 'Nao comunicado a AT',
          estado: c.estado,
        })
      }
    }

    return Response.json({
      data: {
        byEstado,
        receitaMensal,
        duracaoMedia,
        expiring: { d30: expiring30.length, d60: expiring60.length, d90: expiring90.length },
        upcoming,
        projecaoMensal,
        cobertura: { comContrato: fracoesComContrato, total: totalFracoes },
        atencao,
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado'))
      return Response.json({ error: (e as Error).message }, { status: 403 })
    console.error('[contratos/dashboard] Error:', e)
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
