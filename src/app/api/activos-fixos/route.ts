import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  nome: z.string().min(1),
  tipo: z.enum(['VIATURA_LIGEIRA', 'VIATURA_PESADA', 'EQUIPAMENTO', 'OUTRO']),
  combustivel: z.enum(['COMBUSTAO', 'HIBRIDO_PLUG_IN', 'GPL_GNV', 'ELECTRICO']).optional(),
  matricula: z.string().optional(),
  valorAquisicao: z.number().min(0),
  dataAquisicao: z.string(), // ISO date
  taxaDepreciacaoAnual: z.number().min(0).max(100).optional(),
  notas: z.string().optional(),
})

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const activos = await prisma.activoFixo.findMany({
      orderBy: { dataAquisicao: 'desc' },
    })
    return Response.json({ data: activos })
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
    if (!parsed.success) return Response.json({ error: 'Dados invalidos', details: parsed.error.format() }, { status: 400 })

    const d = parsed.data
    const taxaDefault = d.tipo === 'VIATURA_LIGEIRA' ? 25 : d.tipo === 'VIATURA_PESADA' ? 20 : 20

    const activo = await prisma.activoFixo.create({
      data: {
        nome: d.nome,
        tipo: d.tipo,
        combustivel: d.combustivel || null,
        matricula: d.matricula || null,
        valorAquisicao: d.valorAquisicao,
        dataAquisicao: new Date(d.dataAquisicao),
        taxaDepreciacaoAnual: d.taxaDepreciacaoAnual ?? taxaDefault,
        notas: d.notas || null,
      },
    })
    return Response.json({ data: activo }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
