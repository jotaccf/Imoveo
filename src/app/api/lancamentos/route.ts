import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  tipoDoc: z.enum(['RECIBO_VERDE', 'CONTRATO_RENDA', 'FATURA_PAPEL', 'OUTRO']),
  numeroDoc: z.string().optional(),
  fornecedor: z.string().min(1),
  nifFornecedor: z.string().optional(),
  imovelId: z.string().min(1),
  rubricaId: z.string().min(1),
  dataDoc: z.coerce.date(),
  valorSemIva: z.coerce.number(),
  taxaIva: z.coerce.number().min(0).max(100),
  totalComIva: z.coerce.number(),
  retencaoFonte: z.coerce.number().min(0).max(100).optional(),
  valorRetencao: z.coerce.number().optional(),
  recorrente: z.boolean().optional(),
  periodicidade: z.enum(['MENSAL', 'TRIMESTRAL', 'ANUAL']).optional(),
  dataFim: z.coerce.date().optional(),
  notas: z.string().optional(),
})

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'lancamentos:ver')

    const { searchParams } = req.nextUrl
    const imovelId = searchParams.get('imovelId')
    const rubricaId = searchParams.get('rubricaId')
    const search = searchParams.get('search')
    const dataDe = searchParams.get('dataDe')
    const dataAte = searchParams.get('dataAte')

    const where: Record<string, unknown> = {}
    if (imovelId) where.imovelId = imovelId
    if (rubricaId) where.rubricaId = rubricaId
    if (dataDe || dataAte) {
      const dateFilter: Record<string, Date> = {}
      if (dataDe) dateFilter.gte = new Date(dataDe)
      if (dataAte) dateFilter.lte = new Date(dataAte + 'T23:59:59')
      where.dataDoc = dateFilter
    }
    if (search) {
      where.OR = [
        { fornecedor: { contains: search, mode: 'insensitive' } },
        { nifFornecedor: { contains: search } },
        { numeroDoc: { contains: search } },
      ]
    }

    const page = Math.max(Number(searchParams.get('page')) || 1, 1)
    const limit = Math.min(Math.max(Number(searchParams.get('limit')) || 100, 10), 500)

    const [lancamentos, total] = await Promise.all([
      prisma.lancamentoManual.findMany({
        where,
        include: { imovel: true, rubrica: true },
        orderBy: { dataDoc: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.lancamentoManual.count({ where }),
    ])

    return Response.json({
      data: lancamentos,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'lancamentos:criar')

    const body = await req.json()
    const parsed = createSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos', message: parsed.error.message }, { status: 400 })

    const lancamento = await prisma.lancamentoManual.create({ data: parsed.data })
    return Response.json({ data: lancamento }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
