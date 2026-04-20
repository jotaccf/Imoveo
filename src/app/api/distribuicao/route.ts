import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { z } from 'zod'

const createSchema = z.object({
  nifEntidade: z.string().min(1),
  nomeEntidade: z.string().min(1),
  rubricaId: z.string().min(1),
  tipo: z.enum(['IGUAL', 'PERCENTAGEM', 'MANUAL']),
  nome: z.string().optional(),
  linhas: z.array(z.object({
    imovelId: z.string().min(1),
    fracaoId: z.string().optional(),
    percentagem: z.number().optional(),
  })).min(1),
})

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'mapeamento:ver')

    const templates = await prisma.distribuicaoTemplate.findMany({
      where: { ativo: true },
      include: {
        entidade: true,
        rubrica: true,
        linhas: { include: { imovel: true, fracao: true }, orderBy: { ordem: 'asc' } },
      },
      orderBy: { criadoEm: 'desc' },
    })

    return Response.json({ data: templates })
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

    const { nifEntidade, nomeEntidade, rubricaId, tipo, nome, linhas } = parsed.data

    // Garantir entidade existe
    await prisma.entidade.upsert({
      where: { nif: nifEntidade },
      update: {},
      create: { nif: nifEntidade, nome: nomeEntidade, tipo: 'FORNECEDOR' },
    })

    // Desactivar template anterior se existir
    await prisma.distribuicaoTemplate.updateMany({
      where: { nifEntidade },
      data: { ativo: false },
    })

    // Criar novo template
    const template = await prisma.distribuicaoTemplate.create({
      data: {
        nifEntidade,
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

    // Aplicar template a faturas pendentes existentes com o mesmo NIF
    const pendentes = await prisma.fatura.findMany({
      where: {
        classificacoes: { none: {} },
        OR: [
          { nifEmitente: nifEntidade },
          { nifDestinatario: nifEntidade },
        ],
      },
    })

    let aplicadas = 0
    for (const fatura of pendentes) {
      const total = Number(fatura.totalComIva)
      for (let i = 0; i < template.linhas.length; i++) {
        const linha = template.linhas[i]
        let pct: number
        if (tipo === 'IGUAL') {
          pct = 100 / template.linhas.length
        } else {
          pct = Number(linha.percentagem || 0)
        }
        let valor: number
        if (i === template.linhas.length - 1) {
          const somaAnt = template.linhas.slice(0, i).reduce((s, l) => {
            const p = tipo === 'IGUAL' ? 100 / template.linhas.length : Number(l.percentagem || 0)
            return s + Math.round(total * p) / 100
          }, 0)
          valor = Math.round((total - somaAnt) * 100) / 100
        } else {
          valor = Math.round(total * pct) / 100
        }
        await prisma.faturaClassificacao.create({
          data: {
            faturaId: fatura.id,
            imovelId: linha.imovelId,
            rubricaId: template.rubricaId,
            fracaoId: linha.fracaoId,
            origem: 'AUTOMATICA',
            confirmado: false,
            valorAtribuido: valor,
            percentagem: pct,
          },
        })
      }
      aplicadas++
    }

    return Response.json({
      data: template,
      aplicadas,
      message: aplicadas > 0 ? `Template criado e aplicado a ${aplicadas} fatura${aplicadas > 1 ? 's' : ''} pendente${aplicadas > 1 ? 's' : ''}` : 'Template criado',
    }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
