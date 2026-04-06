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

    // Criar regra automatica se solicitado
    if (parsed.data.criarRegra) {
      // Para emitidas: usar o NIF do inquilino (nifRegra ou nifDestinatario)
      // Para recebidas: usar o NIF do emitente (fornecedor)
      const nifParaRegra = parsed.data.nifRegra || fatura.nifDestinatario || fatura.nifEmitente

      // Criar entidade PRIMEIRO (foreign key obriga)
      await prisma.entidade.upsert({
        where: { nif: nifParaRegra },
        update: {},
        create: {
          nif: nifParaRegra,
          nome: fatura.nomeEmitente || nifParaRegra,
          tipo: parsed.data.nifRegra ? 'INQUILINO' : 'FORNECEDOR',
        },
      })

      // Depois criar o mapeamento NIF -> imovel
      await prisma.nifImovelMap.upsert({
        where: { nifEntidade_imovelId: { nifEntidade: nifParaRegra, imovelId: parsed.data.imovelId } },
        update: { rubricaId: parsed.data.rubricaId, fracaoId: parsed.data.fracaoId || null, ativo: true },
        create: {
          nifEntidade: nifParaRegra,
          imovelId: parsed.data.imovelId,
          rubricaId: parsed.data.rubricaId,
          fracaoId: parsed.data.fracaoId || null,
        },
      })

      // Aplicar regra a todas as faturas pendentes com o mesmo NIF
      const isEmitida = !!parsed.data.nifRegra
      const pendentes = await prisma.fatura.findMany({
        where: {
          classificacao: null,
          id: { not: id }, // excluir a fatura que acabamos de classificar
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
