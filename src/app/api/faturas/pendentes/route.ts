import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'pendentes:ver')

    const { searchParams } = req.nextUrl
    const dataDe = searchParams.get('dataDe')
    const dataAte = searchParams.get('dataAte')
    const tipo = searchParams.get('tipo') // 'EMITIDAS' | 'RECEBIDAS' | null
    const search = searchParams.get('search')
    const page = Math.max(Number(searchParams.get('page')) || 1, 1)
    const limit = Math.min(Math.max(Number(searchParams.get('limit')) || 50, 10), 500)

    const baseWhere: Record<string, unknown> = {
      OR: [
        { classificacoes: { none: {} } },
        { classificacoes: { every: { confirmado: false } } },
      ],
    }

    if (dataDe || dataAte) {
      const dateFilter: Record<string, Date> = {}
      if (dataDe) dateFilter.gte = new Date(dataDe)
      if (dataAte) dateFilter.lte = new Date(dataAte + 'T23:59:59')
      baseWhere.dataFatura = dateFilter
    }

    // Where with tipo + search filters
    const where = { ...baseWhere }
    if (tipo) {
      where.importacao = { tipoFicheiro: tipo }
    }
    if (search) {
      where.OR = [
        { nifEmitente: { contains: search } },
        { nifDestinatario: { contains: search } },
        { nomeEmitente: { contains: search, mode: 'insensitive' } },
        { serieDoc: { contains: search } },
        { numeroDoc: { contains: search } },
      ]
    }

    // Count by tipo (always on full set, ignoring tipo filter)
    const [countEmitidas, countRecebidas] = await Promise.all([
      prisma.fatura.count({ where: { ...baseWhere, importacao: { tipoFicheiro: 'EMITIDAS' } } }),
      prisma.fatura.count({ where: { ...baseWhere, importacao: { tipoFicheiro: 'RECEBIDAS' } } }),
    ])

    const [pendentes, total] = await Promise.all([
      prisma.fatura.findMany({
        where,
        include: {
          importacao: { select: { tipoFicheiro: true } },
          rubricaSugerida: true,
          classificacoes: { where: { confirmado: false }, include: { imovel: true, rubrica: true } },
        },
        orderBy: { dataFatura: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.fatura.count({ where }),
    ])

    return Response.json({
      data: pendentes,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
      contagem: {
        total: countEmitidas + countRecebidas,
        receitas: countEmitidas,
        despesas: countRecebidas,
      },
    })
  } catch (e) {
    console.error('[pendentes] ERROR:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
