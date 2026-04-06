import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  codigo: z.string().min(1),
  nome: z.string().min(1),
  tipo: z.enum(['APARTAMENTO', 'MORADIA', 'LOJA', 'ESCRITORIO', 'OUTRO', 'GERAL', 'PESSOAL']),
  morada: z.string().optional(),
  localizacao: z.string().min(1),
  nifProprietario: z.string().optional(),
  estado: z.enum(['ACTIVO', 'VAGO', 'EM_OBRAS', 'INACTIVO']).optional(),
})

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:ver')

    const imoveis = await prisma.imovel.findMany({
      where: { ativo: true },
      include: { fracoes: { orderBy: { nome: 'asc' } } },
      orderBy: { ordem: 'asc' },
    })

    return Response.json({ data: imoveis })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:criar')

    const body = await req.json()
    const parsed = createSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos', message: parsed.error.message }, { status: 400 })

    const existing = await prisma.imovel.findUnique({ where: { codigo: parsed.data.codigo } })
    if (existing) return Response.json({ error: 'Imovel com este codigo ja existe' }, { status: 409 })

    const imovel = await prisma.imovel.create({ data: parsed.data })
    return Response.json({ data: imovel }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
