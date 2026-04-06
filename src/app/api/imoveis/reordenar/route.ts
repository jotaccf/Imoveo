import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function PUT(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { ids } = await req.json() as { ids: string[] }
    if (!Array.isArray(ids)) return Response.json({ error: 'Lista de IDs obrigatoria' }, { status: 400 })

    // Update ordem for each id
    for (let i = 0; i < ids.length; i++) {
      await prisma.imovel.update({ where: { id: ids[i] }, data: { ordem: i } })
    }

    return Response.json({ message: 'Ordem actualizada' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
