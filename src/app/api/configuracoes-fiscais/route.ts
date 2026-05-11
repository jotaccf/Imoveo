import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const upsertSchema = z.object({
  ano: z.number().int().min(2000).max(2100),
  taxaIrcPme: z.number().min(0).max(100),
  taxaIrcNormal: z.number().min(0).max(100),
  limitePme: z.number().min(0),
  derramaMunicipal: z.number().min(0).max(100),
  taxaRetencao: z.number().min(0).max(100),
  reportePrejuizoPct: z.number().min(0).max(100).optional(),
  regimePme: z.boolean().optional(),
})

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const configs = await prisma.configuracaoFiscal.findMany({
      orderBy: { ano: 'desc' },
    })
    return Response.json({ data: configs })
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
    const parsed = upsertSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 })

    const { ano, ...data } = parsed.data
    const config = await prisma.configuracaoFiscal.upsert({
      where: { ano },
      update: data,
      create: { ano, ...data },
    })

    return Response.json({ data: config })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
