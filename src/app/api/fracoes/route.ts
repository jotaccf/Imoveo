import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  imovelId: z.string().min(1),
  nome: z.string().min(1),
  renda: z.coerce.number().min(0),
  nifInquilino: z.string().nullable().optional(),
  dataEntradaMercado: z.coerce.date().nullable().optional(),
  estado: z.enum(['OCUPADO', 'VAGO', 'EM_OBRAS']).optional(),
  letraQuarto: z.string().nullable().optional(),
  tipoQuarto: z.string().nullable().optional(),
  casaBanho: z.string().nullable().optional(),
  mobilia: z.string().nullable().optional(),
  numeroAnexo: z.string().nullable().optional(),
})

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:ver')

    const { searchParams } = new URL(req.url)
    const imovelId = searchParams.get('imovelId')

    const fracoes = await prisma.fracao.findMany({
      where: imovelId ? { imovelId } : undefined,
      include: { imovel: true },
      orderBy: { nome: 'asc' },
    })

    return Response.json({ data: fracoes })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const body = await req.json()
    const parsed = createSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos', message: parsed.error.message }, { status: 400 })

    const fracao = await prisma.fracao.create({ data: parsed.data })
    return Response.json({ data: fracao }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
