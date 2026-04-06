import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const updateSchema = z.object({
  nome: z.string().min(1).optional(),
  renda: z.coerce.number().min(0).optional(),
  nifInquilino: z.string().nullable().optional(),
  dataEntradaMercado: z.coerce.date().nullable().optional(),
  estado: z.enum(['OCUPADO', 'VAGO', 'EM_OBRAS']).optional(),
  imovelId: z.string().optional(),
  letraQuarto: z.string().nullable().optional(),
  tipoQuarto: z.string().nullable().optional(),
  casaBanho: z.string().nullable().optional(),
  mobilia: z.string().nullable().optional(),
  numeroAnexo: z.string().nullable().optional(),
})

export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { id } = await params

    const body = await req.json()
    const parsed = updateSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos', message: parsed.error.message }, { status: 400 })

    const fracao = await prisma.fracao.update({
      where: { id },
      data: parsed.data,
    })

    return Response.json({ data: fracao })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function DELETE(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:remover')

    const { id } = await params

    await prisma.fracao.delete({ where: { id } })

    return Response.json({ data: { success: true } })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
