import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const updateSchema = z.object({
  rubricaId: z.string().min(1),
  tipo: z.enum(['IGUAL', 'PERCENTAGEM', 'MANUAL']),
  nome: z.string().optional(),
  linhas: z.array(z.object({
    imovelId: z.string().min(1),
    fracaoId: z.string().optional(),
    percentagem: z.number().optional(),
  })).min(1),
})

export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'mapeamento:editar')

    const { id } = await params
    const body = await req.json()
    const parsed = updateSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 })

    const { rubricaId, tipo, nome, linhas } = parsed.data

    // Apagar linhas antigas e recriar
    await prisma.distribuicaoLinha.deleteMany({ where: { templateId: id } })

    const template = await prisma.distribuicaoTemplate.update({
      where: { id },
      data: {
        rubricaId,
        tipo,
        nome: nome || null,
        linhas: {
          create: linhas.map((l, i) => ({
            imovelId: l.imovelId,
            fracaoId: l.fracaoId || null,
            percentagem: tipo === 'PERCENTAGEM' ? l.percentagem : null,
            ordem: i,
          })),
        },
      },
      include: {
        entidade: true,
        rubrica: true,
        linhas: { include: { imovel: true }, orderBy: { ordem: 'asc' } },
      },
    })

    return Response.json({ data: template })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'mapeamento:editar')

    const { id } = await params

    await prisma.distribuicaoTemplate.update({
      where: { id },
      data: { ativo: false },
    })

    return Response.json({ message: 'Template desactivado' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
