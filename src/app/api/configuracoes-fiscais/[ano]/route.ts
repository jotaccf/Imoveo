import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ ano: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const { ano } = await params
    await prisma.configuracaoFiscal.delete({ where: { ano: Number(ano) } })
    return Response.json({ ok: true })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
