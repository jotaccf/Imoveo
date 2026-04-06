import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'lancamentos:editar')

    const { id } = await params
    const body = await req.json()

    // Filtrar apenas campos editaveis
    const data: Record<string, unknown> = {}
    if (body.tipoDoc !== undefined) data.tipoDoc = body.tipoDoc
    if (body.numeroDoc !== undefined) data.numeroDoc = body.numeroDoc || null
    if (body.fornecedor !== undefined) data.fornecedor = body.fornecedor
    if (body.nifFornecedor !== undefined) data.nifFornecedor = body.nifFornecedor || null
    if (body.imovelId !== undefined) data.imovelId = body.imovelId
    if (body.rubricaId !== undefined) data.rubricaId = body.rubricaId
    if (body.dataDoc !== undefined) data.dataDoc = new Date(body.dataDoc)
    if (body.valorSemIva !== undefined) data.valorSemIva = Number(body.valorSemIva)
    if (body.taxaIva !== undefined) data.taxaIva = Number(body.taxaIva)
    if (body.totalComIva !== undefined) data.totalComIva = Number(body.totalComIva)
    if (body.retencaoFonte !== undefined) data.retencaoFonte = Number(body.retencaoFonte)
    if (body.valorRetencao !== undefined) data.valorRetencao = Number(body.valorRetencao)
    if (body.recorrente !== undefined) data.recorrente = body.recorrente
    if (body.periodicidade !== undefined) data.periodicidade = body.periodicidade || null
    if (body.dataFim !== undefined) data.dataFim = body.dataFim ? new Date(body.dataFim) : null
    if (body.notas !== undefined) data.notas = body.notas || null

    const lancamento = await prisma.lancamentoManual.update({ where: { id }, data })
    return Response.json({ data: lancamento })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'lancamentos:remover')

    const { id } = await params
    await prisma.lancamentoManual.delete({ where: { id } })
    return Response.json({ message: 'Lancamento removido' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
