import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  ano: z.number().int().min(2000).max(2100),
  prestacao: z.number().int().min(1).max(3),
  valor: z.number().min(0),
  dataPagamento: z.string(),
  notas: z.string().optional(),
})

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const { searchParams } = req.nextUrl
    const ano = searchParams.get('ano')
    const where = ano ? { ano: Number(ano) } : {}

    const pagamentos = await prisma.pagamentoConta.findMany({
      where,
      orderBy: [{ ano: 'desc' }, { prestacao: 'asc' }],
    })
    return Response.json({ data: pagamentos })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const body = await req.json()
    const parsed = createSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 })

    const d = parsed.data
    const pagamento = await prisma.pagamentoConta.upsert({
      where: { ano_prestacao: { ano: d.ano, prestacao: d.prestacao } },
      update: { valor: d.valor, dataPagamento: new Date(d.dataPagamento), notas: d.notas || null },
      create: { ano: d.ano, prestacao: d.prestacao, valor: d.valor, dataPagamento: new Date(d.dataPagamento), notas: d.notas || null },
    })
    return Response.json({ data: pagamento })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
