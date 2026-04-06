import { prisma } from '@/lib/prisma'

export async function GET() {
  try {
    const imoveis = await prisma.imovel.findMany({
      where: { ativo: true },
      select: { id: true, nome: true, codigo: true, tipo: true },
      orderBy: { codigo: 'asc' },
    })

    const rubricas = await prisma.rubrica.findMany({
      select: { id: true, nome: true, codigo: true, tipo: true },
      orderBy: { ordem: 'asc' },
    })

    const fracoes = await prisma.fracao.findMany({
      select: { id: true, nome: true, imovelId: true, renda: true, estado: true, nifInquilino: true },
      orderBy: { nome: 'asc' },
    })

    return Response.json({ data: { imoveis, rubricas, fracoes } })
  } catch (e) {
    console.error('[/api/opcoes] Error:', e)
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
