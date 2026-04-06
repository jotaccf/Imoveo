import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { hashSync } from 'bcryptjs'

export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const { id } = await params
    const body = await req.json()

    const data: Record<string, unknown> = {}
    if (body.nome) data.nome = body.nome
    if (body.role) data.role = body.role
    if (body.ativo !== undefined) data.ativo = body.ativo
    if (body.password) data.passwordHash = hashSync(body.password, 12)

    const user = await prisma.utilizador.update({
      where: { id },
      data,
      select: { id: true, nome: true, email: true, role: true, ativo: true },
    })

    return Response.json({ data: user })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:remover')

    const { id } = await params
    await prisma.utilizador.update({ where: { id }, data: { ativo: false } })
    return Response.json({ message: 'Utilizador desactivado' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
