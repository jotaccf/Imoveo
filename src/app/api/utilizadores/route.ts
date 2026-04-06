import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { hashSync } from 'bcryptjs'
import { z } from 'zod'

const createSchema = z.object({
  nome: z.string().min(1),
  email: z.string().email(),
  password: z.string().min(6),
  role: z.enum(['ADMIN', 'GESTOR', 'OPERADOR']),
})

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const utilizadores = await prisma.utilizador.findMany({
      select: { id: true, nome: true, email: true, role: true, ativo: true, criadoEm: true, ultimoLogin: true },
      orderBy: { criadoEm: 'asc' },
    })

    return Response.json({ data: utilizadores })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:criar')

    const body = await req.json()
    const parsed = createSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos', message: parsed.error.message }, { status: 400 })

    const existing = await prisma.utilizador.findUnique({ where: { email: parsed.data.email } })
    if (existing) return Response.json({ error: 'Email ja registado' }, { status: 409 })

    const passwordHash = hashSync(parsed.data.password, 12)

    const user = await prisma.utilizador.create({
      data: { nome: parsed.data.nome, email: parsed.data.email, passwordHash, role: parsed.data.role },
      select: { id: true, nome: true, email: true, role: true },
    })

    return Response.json({ data: user }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
