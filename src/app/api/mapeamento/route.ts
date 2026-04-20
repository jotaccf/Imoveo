import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  nifEntidade: z.string().min(1),
  nomeEntidade: z.string().min(1),
  imovelId: z.string().optional(), // opcional para regras so rubrica
  rubricaId: z.string().min(1),
})

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'mapeamento:ver')

    const maps = await prisma.nifImovelMap.findMany({
      where: { ativo: true },
      include: { imovel: true, rubrica: true, entidade: true },
      orderBy: { criadoEm: 'desc' },
    })

    return Response.json({ data: maps })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'mapeamento:editar')

    const body = await req.json()
    const parsed = createSchema.safeParse(body)
    if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 })

    // Upsert entidade
    await prisma.entidade.upsert({
      where: { nif: parsed.data.nifEntidade },
      update: { nome: parsed.data.nomeEntidade },
      create: { nif: parsed.data.nifEntidade, nome: parsed.data.nomeEntidade },
    })

    const map = await prisma.nifImovelMap.create({
      data: {
        nifEntidade: parsed.data.nifEntidade,
        imovelId: parsed.data.imovelId || null,
        rubricaId: parsed.data.rubricaId,
      },
    })

    // Aplicar regra a faturas pendentes existentes com o mesmo NIF
    const nif = parsed.data.nifEntidade
    const pendentes = await prisma.fatura.findMany({
      where: {
        classificacoes: { none: {} },
        OR: [
          { nifEmitente: nif },
          { nifDestinatario: nif },
        ],
      },
    })

    let aplicadas = 0
    if (parsed.data.imovelId) {
      // Regra completa — classificar automaticamente
      for (const f of pendentes) {
        await prisma.faturaClassificacao.create({
          data: {
            faturaId: f.id,
            imovelId: parsed.data.imovelId,
            rubricaId: parsed.data.rubricaId,
            origem: 'AUTOMATICA',
            confirmado: true,
          },
        })
        aplicadas++
      }
    } else {
      // Regra so rubrica — pre-preencher rubrica sugerida
      for (const f of pendentes) {
        await prisma.fatura.update({
          where: { id: f.id },
          data: { rubricaSugeridaId: parsed.data.rubricaId },
        })
        aplicadas++
      }
    }

    return Response.json({
      data: map,
      aplicadas,
      message: aplicadas > 0 ? `Regra criada e aplicada a ${aplicadas} fatura${aplicadas > 1 ? 's' : ''} pendente${aplicadas > 1 ? 's' : ''}` : 'Regra criada',
    }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
