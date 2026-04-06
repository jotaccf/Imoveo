import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  codigo: z.string().min(1),
  nome: z.string().min(1),
  tipo: z.enum(['APARTAMENTO', 'MORADIA', 'LOJA', 'ESCRITORIO', 'OUTRO', 'GERAL', 'PESSOAL']),
  morada: z.string().optional(),
  localizacao: z.string().min(1),
  nifProprietario: z.string().optional(),
  estado: z.enum(['ACTIVO', 'VAGO', 'EM_OBRAS', 'INACTIVO']).optional(),
  // Contrato fields
  fracaoAutonoma: z.string().optional(),
  andar: z.string().optional(),
  freguesia: z.string().optional(),
  concelho: z.string().optional(),
  artigoMatricial: z.string().optional(),
  descricaoRP: z.string().optional(),
  licencaUtilizacao: z.string().optional(),
  dataLicenca: z.string().optional(),
  entidadeLicenca: z.string().optional(),
  dataContratoArrendamento: z.string().optional(),
  modeloDespesas: z.string().optional(),
  incluirSubtracaoCaucao: z.boolean().optional(),
  // Proprietarios fields
  incluirProprietarios: z.boolean().optional(),
  nomeProprietario1: z.string().optional(),
  ccProprietario1: z.string().optional(),
  nomeProprietario2: z.string().optional(),
  nifProprietario2: z.string().optional(),
  ccProprietario2: z.string().optional(),
  regimeCasamento: z.string().optional(),
  moradaProprietarios: z.string().optional(),
  // Equipamentos
  equipamentos: z.string().optional(),
  // Numeric fields passed as strings
  valorPatrimonial: z.string().optional(),
  areaMt2: z.string().optional(),
})

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:ver')

    const imoveis = await prisma.imovel.findMany({
      where: { ativo: true },
      include: { fracoes: { orderBy: { nome: 'asc' } } },
      orderBy: { ordem: 'asc' },
    })

    return Response.json({ data: imoveis })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:criar')

    const body = await req.json()
    const parsed = createSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos', message: parsed.error.message }, { status: 400 })

    const existing = await prisma.imovel.findUnique({ where: { codigo: parsed.data.codigo } })
    if (existing) return Response.json({ error: 'Imovel com este codigo ja existe' }, { status: 409 })

    const { valorPatrimonial, areaMt2, dataContratoArrendamento, ...rest } = parsed.data
    // Convert string fields to proper types
    const createData: Record<string, unknown> = { ...rest }
    if (valorPatrimonial) createData.valorPatrimonial = Number(valorPatrimonial)
    if (areaMt2) createData.areaMt2 = Number(areaMt2)
    if (dataContratoArrendamento) createData.dataContratoArrendamento = new Date(dataContratoArrendamento)
    // Nullify empty optional strings
    const optionalStrings = ['morada', 'nifProprietario', 'fracaoAutonoma', 'andar', 'freguesia', 'concelho', 'artigoMatricial', 'descricaoRP', 'licencaUtilizacao', 'dataLicenca', 'entidadeLicenca', 'nomeProprietario1', 'ccProprietario1', 'nomeProprietario2', 'nifProprietario2', 'ccProprietario2', 'regimeCasamento', 'moradaProprietarios', 'equipamentos'] as const
    for (const key of optionalStrings) {
      if (createData[key] === '') createData[key] = null
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const imovel = await prisma.imovel.create({ data: createData as any })
    return Response.json({ data: imovel }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
