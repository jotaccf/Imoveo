import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const schema = z.object({
  linhas: z.array(z.object({
    classificacaoId: z.string(),
    valor: z.number(),
  })).min(1),
})

export async function POST(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'pendentes:classificar')

    const { id } = await params
    const body = await req.json()
    const parsed = schema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 })

    const fatura = await prisma.fatura.findUnique({ where: { id } })
    if (!fatura) return Response.json({ error: 'Fatura nao encontrada' }, { status: 404 })

    await Promise.all(
      parsed.data.linhas.map((linha) =>
        prisma.faturaClassificacao.update({
          where: { id: linha.classificacaoId },
          data: { confirmado: true, valorAtribuido: linha.valor },
        })
      )
    )

    return Response.json({ ok: true })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
