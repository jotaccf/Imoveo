import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { loadAnaliseData } from '@/lib/analise-data'

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const { searchParams } = req.nextUrl
    const ano = searchParams.get('ano') ? Number(searchParams.get('ano')) : new Date().getFullYear()

    const data = await loadAnaliseData(ano)

    return Response.json({ data })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
