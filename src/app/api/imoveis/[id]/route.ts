import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

// Codigos de centros de custo protegidos (nao editaveis/apagaveis)
const CODIGOS_PROTEGIDOS = ['CC-GERAL', 'CC-PESSOAL']

// Tipos de imovel que admitem quartos / fracoes
const TIPOS_COM_QUARTOS = ['APARTAMENTO', 'MORADIA', 'OUTRO']

export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { id } = await params
    const imovel = await prisma.imovel.findUnique({ where: { id }, include: { fracoes: true } })
    if (!imovel) return Response.json({ error: 'Nao encontrado' }, { status: 404 })
    if (CODIGOS_PROTEGIDOS.includes(imovel.codigo)) {
      return Response.json({ error: 'Este centro de custo nao pode ser editado' }, { status: 403 })
    }

    const body = await req.json()

    // Se muda para tipo sem quartos e tem fracoes associadas, bloquear com mensagem clara.
    if (body.tipo !== undefined && body.tipo !== imovel.tipo && !TIPOS_COM_QUARTOS.includes(body.tipo) && imovel.fracoes.length > 0) {
      return Response.json({
        error: `Imovel tem ${imovel.fracoes.length} quarto(s) associado(s). Remove primeiro os quartos antes de mudar para o tipo ${body.tipo}.`,
      }, { status: 409 })
    }
    const data: Record<string, unknown> = {}
    if (body.codigo !== undefined) data.codigo = body.codigo
    if (body.nome !== undefined) data.nome = body.nome
    if (body.tipo !== undefined) data.tipo = body.tipo
    if (body.localizacao !== undefined) data.localizacao = body.localizacao
    if (body.morada !== undefined) data.morada = body.morada || null
    if (body.nifProprietario !== undefined) data.nifProprietario = body.nifProprietario || null
    if (body.estado !== undefined) data.estado = body.estado
    if (body.valorPatrimonial !== undefined) data.valorPatrimonial = body.valorPatrimonial ? Number(body.valorPatrimonial) : null
    if (body.areaMt2 !== undefined) data.areaMt2 = body.areaMt2 ? Number(body.areaMt2) : null
    // Contrato fields (optional strings -> null if empty)
    const optionalStrings = ['fracaoAutonoma', 'andar', 'freguesia', 'concelho', 'artigoMatricial', 'descricaoRP', 'licencaUtilizacao', 'dataLicenca', 'entidadeLicenca', 'nomeProprietario1', 'ccProprietario1', 'nomeProprietario2', 'nifProprietario2', 'ccProprietario2', 'regimeCasamento', 'moradaProprietarios', 'equipamentos'] as const
    for (const key of optionalStrings) {
      if (body[key] !== undefined) data[key] = body[key] || null
    }
    // Required string with default
    if (body.modeloDespesas !== undefined) data.modeloDespesas = body.modeloDespesas
    // Boolean fields
    if (body.incluirSubtracaoCaucao !== undefined) data.incluirSubtracaoCaucao = body.incluirSubtracaoCaucao
    if (body.incluirProprietarios !== undefined) data.incluirProprietarios = body.incluirProprietarios
    // DateTime field
    if (body.dataContratoArrendamento !== undefined) data.dataContratoArrendamento = body.dataContratoArrendamento ? new Date(body.dataContratoArrendamento) : null
    // Tipo propriedade + depreciacao
    if (body.tipoPropriedade !== undefined) data.tipoPropriedade = body.tipoPropriedade
    if (body.valorAquisicao !== undefined) data.valorAquisicao = body.valorAquisicao ? Number(body.valorAquisicao) : null
    if (body.dataAquisicao !== undefined) data.dataAquisicao = body.dataAquisicao ? new Date(body.dataAquisicao) : null
    if (body.taxaDepreciacaoAnual !== undefined) data.taxaDepreciacaoAnual = body.taxaDepreciacaoAnual ? Number(body.taxaDepreciacaoAnual) : null

    const updated = await prisma.imovel.update({ where: { id }, data })
    return Response.json({ data: updated })
  } catch (e) {
    console.error('[/api/imoveis/[id]] PUT error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:remover')

    const { id } = await params
    const imovel = await prisma.imovel.findUnique({ where: { id } })
    if (!imovel) return Response.json({ error: 'Nao encontrado' }, { status: 404 })
    if (CODIGOS_PROTEGIDOS.includes(imovel.codigo)) {
      return Response.json({ error: 'Este centro de custo nao pode ser removido' }, { status: 403 })
    }

    await prisma.imovel.update({ where: { id }, data: { ativo: false } })
    return Response.json({ message: 'Imovel desactivado' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
