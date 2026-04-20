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
  })),
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

    // Remover template anterior se existir (cascade apaga linhas)
    await prisma.distribuicaoTemplate.deleteMany({ where: { nifEntidade } })

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
        OR: [
          { nifEmitente: nifEntidade },
          { nifDestinatario: nifEntidade },
        ],
        classificacoes: {
          none: { confirmado: true },
        },
      },
    })

    let aplicadas = 0
    const n = template.linhas.length

    if (n === 0) {
      // Sem linhas = so sugerir rubrica
      for (const fatura of pendentes) {
        await prisma.fatura.update({
          where: { id: fatura.id },
          data: { rubricaSugeridaId: rubricaId },
        })
        aplicadas++
      }
    } else {
      // Com linhas = classificar automaticamente
      for (const fatura of pendentes) {
        await prisma.faturaClassificacao.deleteMany({
          where: { faturaId: fatura.id },
        })
        const total = Number(fatura.totalComIva)
        for (let i = 0; i < n; i++) {
          const linha = template.linhas[i]
          const pct = tipo === 'PERCENTAGEM'
            ? Number(linha.percentagem || 0)
            : 100 / n
          let valor: number
          if (i === n - 1) {
            const somaAnt = template.linhas.slice(0, i).reduce((s, _, j) => {
              const p = tipo === 'PERCENTAGEM' ? Number(template.linhas[j].percentagem || 0) : 100 / n
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
              confirmado: true,
              valorAtribuido: valor,
              percentagem: pct,
            },
          })
        }
        aplicadas++
      }
    }

    return Response.json({
      data: template,
      aplicadas,
      message: aplicadas > 0 ? `Regra criada e aplicada a ${aplicadas} fatura${aplicadas > 1 ? 's' : ''} pendente${aplicadas > 1 ? 's' : ''}` : 'Regra criada',
    }, { status: 201 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
