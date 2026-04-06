import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'faturas:ver')

    const { searchParams } = req.nextUrl
    const imovelId = searchParams.get('imovelId')
    const rubricaId = searchParams.get('rubricaId')
    const periodo = searchParams.get('periodo')
    const dataDe = searchParams.get('dataDe')
    const dataAte = searchParams.get('dataAte')
    const search = searchParams.get('search')
    const page = Math.max(Number(searchParams.get('page')) || 1, 1)
    const limit = Math.min(Math.max(Number(searchParams.get('limit')) || 100, 10), 500)

    const where: Record<string, unknown> = { classificacao: { isNot: null } }

    if (imovelId || rubricaId) {
      where.classificacao = {}
      if (imovelId) (where.classificacao as Record<string, unknown>).imovelId = imovelId
      if (rubricaId) (where.classificacao as Record<string, unknown>).rubricaId = rubricaId
    }

    if (dataDe || dataAte) {
      const dateFilter: Record<string, Date> = {}
      if (dataDe) dateFilter.gte = new Date(dataDe)
      if (dataAte) dateFilter.lte = new Date(dataAte + 'T23:59:59')
      where.dataFatura = dateFilter
    } else if (periodo) {
      const [year, month] = periodo.split('-').map(Number)
      const start = new Date(year, (month || 1) - 1, 1)
      const end = month ? new Date(year, month, 1) : new Date(year + 1, 0, 1)
      where.dataFatura = { gte: start, lt: end }
    }

    if (search) {
      where.OR = [
        { nifEmitente: { contains: search } },
        { nomeEmitente: { contains: search, mode: 'insensitive' } },
        { serieDoc: { contains: search } },
        { numeroDoc: { contains: search } },
      ]
    }

    const [faturas, total] = await Promise.all([
      prisma.fatura.findMany({
        where,
        include: { classificacao: { include: { imovel: true, rubrica: true } }, importacao: true },
        orderBy: { dataFatura: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.fatura.count({ where }),
    ])

    // Totais agregados (para o sumario)
    const totais = await prisma.fatura.aggregate({
      where,
      _sum: { totalSemIva: true, totalIva: true, totalComIva: true },
    })

    return Response.json({
      data: faturas,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
      totais: {
        totalSemIva: Number(totais._sum.totalSemIva || 0),
        totalIva: Number(totais._sum.totalIva || 0),
        totalComIva: Number(totais._sum.totalComIva || 0),
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
