import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const updateSchema = z.object({
  nome: z.string().min(1).optional(),
  tipo: z.enum(['VIATURA_LIGEIRA', 'VIATURA_PESADA', 'EQUIPAMENTO', 'OUTRO']).optional(),
  combustivel: z.enum(['COMBUSTAO', 'HIBRIDO_PLUG_IN', 'GPL_GNV', 'ELECTRICO']).nullable().optional(),
  matricula: z.string().nullable().optional(),
  valorAquisicao: z.number().min(0).optional(),
  dataAquisicao: z.string().optional(),
  taxaDepreciacaoAnual: z.number().min(0).max(100).optional(),
  alienadoEm: z.string().nullable().optional(),
  valorAlienacao: z.number().nullable().optional(),
  notas: z.string().nullable().optional(),
})

export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const { id } = await params
    const body = await req.json()
    const parsed = updateSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 })

    const d = parsed.data
    const updateData: Record<string, unknown> = {}
    if (d.nome !== undefined) updateData.nome = d.nome
    if (d.tipo !== undefined) updateData.tipo = d.tipo
    if (d.combustivel !== undefined) updateData.combustivel = d.combustivel
    if (d.matricula !== undefined) updateData.matricula = d.matricula
    if (d.valorAquisicao !== undefined) updateData.valorAquisicao = d.valorAquisicao
    if (d.dataAquisicao !== undefined) updateData.dataAquisicao = new Date(d.dataAquisicao)
    if (d.taxaDepreciacaoAnual !== undefined) updateData.taxaDepreciacaoAnual = d.taxaDepreciacaoAnual
    if (d.alienadoEm !== undefined) updateData.alienadoEm = d.alienadoEm ? new Date(d.alienadoEm) : null
    if (d.valorAlienacao !== undefined) updateData.valorAlienacao = d.valorAlienacao
    if (d.notas !== undefined) updateData.notas = d.notas

    const activo = await prisma.activoFixo.update({ where: { id }, data: updateData })
    return Response.json({ data: activo })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const { id } = await params
    await prisma.activoFixo.delete({ where: { id } })
    return Response.json({ ok: true })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
