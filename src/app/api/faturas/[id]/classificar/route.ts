import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const schema = z.object({
  imovelId: z.string().min(1),
  rubricaId: z.string().min(1),
  fracaoId: z.string().optional(),
  criarRegra: z.boolean().optional(),
  nifRegra: z.string().optional(),
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

    console.log('[classificar] id:', id, 'body:', JSON.stringify(parsed.data))

    const fatura = await prisma.fatura.findUnique({ where: { id } })
    if (!fatura) return Response.json({ error: 'Fatura nao encontrada' }, { status: 404 })

    const classificacao = await prisma.faturaClassificacao.create({
      data: {
        faturaId: id,
        imovelId: parsed.data.imovelId,
        rubricaId: parsed.data.rubricaId,
        fracaoId: parsed.data.fracaoId || null,
        origem: 'MANUAL',
        confirmado: true,
      },
    })

    // Criar regra automatica se solicitado (DistribuicaoTemplate unificado)
    if (parsed.data.criarRegra) {
      const nifParaRegra = parsed.data.nifRegra || fatura.nifDestinatario || fatura.nifEmitente

      // Garantir entidade existe
      await prisma.entidade.upsert({
        where: { nif: nifParaRegra },
        update: {},
        create: {
          nif: nifParaRegra,
          nome: fatura.nomeEmitente || nifParaRegra,
          tipo: parsed.data.nifRegra ? 'INQUILINO' : 'FORNECEDOR',
        },
      })

      // Criar/substituir template unificado para este NIF
      await prisma.distribuicaoTemplate.deleteMany({ where: { nifEntidade: nifParaRegra } })
      await prisma.distribuicaoTemplate.create({
        data: {
          nifEntidade: nifParaRegra,
          rubricaId: parsed.data.rubricaId,
          tipo: 'IGUAL',
          linhas: {
            create: [{
              imovelId: parsed.data.imovelId,
              fracaoId: parsed.data.fracaoId || null,
              ordem: 0,
            }],
          },
        },
      })

      // Aplicar regra a todas as faturas pendentes com o mesmo NIF
      const isEmitida = !!parsed.data.nifRegra
      const pendentes = await prisma.fatura.findMany({
        where: {
          classificacoes: { none: {} },
          id: { not: id },
          ...(isEmitida
            ? { nifDestinatario: nifParaRegra }
            : { nifEmitente: nifParaRegra }
          ),
        },
      })

      let autoClassificadas = 0
      for (const fp of pendentes) {
        try {
          await prisma.faturaClassificacao.create({
            data: {
              faturaId: fp.id,
              imovelId: parsed.data.imovelId,
              rubricaId: parsed.data.rubricaId,
              fracaoId: parsed.data.fracaoId || null,
              origem: 'AUTOMATICA',
              confirmado: true,
            },
          })
          autoClassificadas++
        } catch {
          // Skip if already classified
        }
      }

      return Response.json({
        data: classificacao,
        message: autoClassificadas > 0
          ? `Regra criada e aplicada a ${autoClassificadas} fatura${autoClassificadas > 1 ? 's' : ''} pendente${autoClassificadas > 1 ? 's' : ''}`
          : 'Regra criada',
        autoClassificadas,
      })
    }

    return Response.json({ data: classificacao })
  } catch (e) {
    console.error('[classificar] ERROR:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}

// PUT — substituir classificacoes existentes (editar)
const putSchema = z.object({
  linhas: z.array(z.object({
    imovelId: z.string().min(1),
    rubricaId: z.string().min(1),
    fracaoId: z.string().optional(),
    valor: z.number().optional(),
  })).min(1),
})

export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'pendentes:classificar')

    const { id } = await params
    const body = await req.json()
    const parsed = putSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 })

    const fatura = await prisma.fatura.findUnique({ where: { id } })
    if (!fatura) return Response.json({ error: 'Fatura nao encontrada' }, { status: 404 })

    // Apagar classificacoes existentes
    await prisma.faturaClassificacao.deleteMany({ where: { faturaId: id } })

    // Criar novas
    await prisma.faturaClassificacao.createMany({
      data: parsed.data.linhas.map((l) => ({
        faturaId: id,
        imovelId: l.imovelId,
        rubricaId: l.rubricaId,
        fracaoId: l.fracaoId || null,
        valorAtribuido: l.valor ?? null,
        origem: 'MANUAL',
        confirmado: true,
      })),
    })

    return Response.json({ ok: true })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

// DELETE — anular classificacao (volta a pendentes)
export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'pendentes:classificar')

    const { id } = await params
    await prisma.faturaClassificacao.deleteMany({ where: { faturaId: id } })
    await prisma.fatura.update({ where: { id }, data: { rubricaSugeridaId: null } })

    return Response.json({ ok: true })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
