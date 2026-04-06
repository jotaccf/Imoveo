import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:ver')

    const { searchParams } = req.nextUrl
    const estado = searchParams.get('estado')
    const imovelId = searchParams.get('imovelId')

    const where: Record<string, unknown> = {}
    if (estado) where.estado = estado
    if (imovelId) where.imovelId = imovelId

    const contratos = await prisma.contrato.findMany({
      where,
      include: {
        fracao: { select: { id: true, nome: true } },
        imovel: { select: { id: true, codigo: true, nome: true } },
      },
      orderBy: [{ estado: 'asc' }, { dataFim: 'asc' }],
    })

    return Response.json({ data: contratos })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const body = await req.json()
    const { fracaoId, imovelId, nomeInquilino, nifInquilino, contacto, genero, nacionalidade, tipoDocumento, numDocumento, validadeDocumento, estadoCivil, naturalidade, moradaInquilino, usarMoradaImovel, localAssinatura, dataAssinatura, nomeFiador, nifFiador, contactoFiador, parentesco, valorRenda, dataInicio, dataFim, renovacaoAuto, periodoRenovacao, caucao, notas } = body

    if (!fracaoId || !imovelId || !nomeInquilino || !valorRenda || !dataInicio) {
      return Response.json({ error: 'Campos obrigatorios em falta' }, { status: 400 })
    }

    // Verificar se a fracao ja tem contrato ativo
    const existente = await prisma.contrato.findFirst({
      where: { fracaoId, estado: 'ATIVO' },
    })
    if (existente) {
      return Response.json({ error: 'Esta fracao ja tem um contrato ativo' }, { status: 409 })
    }

    const contrato = await prisma.contrato.create({
      data: {
        fracaoId,
        imovelId,
        nomeInquilino,
        nifInquilino: nifInquilino || null,
        contacto: contacto || null,
        genero: genero || null,
        nacionalidade: nacionalidade || null,
        tipoDocumento: tipoDocumento || null,
        numDocumento: numDocumento || null,
        validadeDocumento: validadeDocumento ? new Date(validadeDocumento) : null,
        estadoCivil: estadoCivil || null,
        naturalidade: naturalidade || null,
        moradaInquilino: moradaInquilino || null,
        usarMoradaImovel: usarMoradaImovel ?? true,
        localAssinatura: localAssinatura || null,
        dataAssinatura: dataAssinatura ? new Date(dataAssinatura) : null,
        nomeFiador: nomeFiador || null,
        nifFiador: nifFiador || null,
        contactoFiador: contactoFiador || null,
        parentesco: parentesco || null,
        valorRenda: Number(valorRenda),
        dataInicio: new Date(dataInicio),
        dataFim: dataFim ? new Date(dataFim) : null,
        renovacaoAuto: renovacaoAuto ?? true,
        periodoRenovacao: periodoRenovacao || 12,
        caucao: caucao ? Number(caucao) : null,
        notas: notas || null,
      },
    })

    return Response.json({ data: contrato }, { status: 201 })
  } catch (e) {
    console.error('[contratos/POST] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao criar contrato', details: String(e) }, { status: 500 })
  }
}

export async function PUT(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const body = await req.json()
    const { id, ...data } = body

    if (!id) return Response.json({ error: 'ID obrigatorio' }, { status: 400 })

    const updateData: Record<string, unknown> = {}
    if (data.nomeInquilino !== undefined) updateData.nomeInquilino = data.nomeInquilino
    if (data.nifInquilino !== undefined) updateData.nifInquilino = data.nifInquilino || null
    if (data.contacto !== undefined) updateData.contacto = data.contacto || null
    if (data.nomeFiador !== undefined) updateData.nomeFiador = data.nomeFiador || null
    if (data.nifFiador !== undefined) updateData.nifFiador = data.nifFiador || null
    if (data.contactoFiador !== undefined) updateData.contactoFiador = data.contactoFiador || null
    if (data.parentesco !== undefined) updateData.parentesco = data.parentesco || null
    if (data.genero !== undefined) updateData.genero = data.genero || null
    if (data.nacionalidade !== undefined) updateData.nacionalidade = data.nacionalidade || null
    if (data.tipoDocumento !== undefined) updateData.tipoDocumento = data.tipoDocumento || null
    if (data.numDocumento !== undefined) updateData.numDocumento = data.numDocumento || null
    if (data.validadeDocumento !== undefined) updateData.validadeDocumento = data.validadeDocumento ? new Date(data.validadeDocumento) : null
    if (data.estadoCivil !== undefined) updateData.estadoCivil = data.estadoCivil || null
    if (data.naturalidade !== undefined) updateData.naturalidade = data.naturalidade || null
    if (data.moradaInquilino !== undefined) updateData.moradaInquilino = data.moradaInquilino || null
    if (data.usarMoradaImovel !== undefined) updateData.usarMoradaImovel = data.usarMoradaImovel
    if (data.localAssinatura !== undefined) updateData.localAssinatura = data.localAssinatura || null
    if (data.dataAssinatura !== undefined) updateData.dataAssinatura = data.dataAssinatura ? new Date(data.dataAssinatura) : null
    if (data.valorRenda !== undefined) updateData.valorRenda = Number(data.valorRenda)
    if (data.dataInicio !== undefined) updateData.dataInicio = new Date(data.dataInicio)
    if (data.dataFim !== undefined) updateData.dataFim = data.dataFim ? new Date(data.dataFim) : null
    if (data.renovacaoAuto !== undefined) updateData.renovacaoAuto = data.renovacaoAuto
    if (data.periodoRenovacao !== undefined) updateData.periodoRenovacao = data.periodoRenovacao
    if (data.caucao !== undefined) updateData.caucao = data.caucao ? Number(data.caucao) : null
    if (data.notas !== undefined) updateData.notas = data.notas || null
    if (data.estado !== undefined) updateData.estado = data.estado
    if (data.comunicadoAT !== undefined) {
      updateData.comunicadoAT = data.comunicadoAT
      updateData.dataComunicacaoAT = data.comunicadoAT ? new Date() : null
    }
    if (data.fracaoId !== undefined) updateData.fracaoId = data.fracaoId
    if (data.imovelId !== undefined) updateData.imovelId = data.imovelId

    const contrato = await prisma.contrato.update({ where: { id }, data: updateData })
    return Response.json({ data: contrato })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao atualizar contrato', details: String(e) }, { status: 500 })
  }
}

export async function DELETE(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { id } = await req.json()
    if (!id) return Response.json({ error: 'ID obrigatorio' }, { status: 400 })

    await prisma.contrato.delete({ where: { id } })
    return Response.json({ message: 'Contrato eliminado' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao eliminar contrato' }, { status: 500 })
  }
}
