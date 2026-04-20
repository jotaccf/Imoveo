import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function POST() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    // 1. Remover TODAS as classificacoes automaticas nao confirmadas (lixo do modelo antigo)
    const limpas = await prisma.faturaClassificacao.deleteMany({
      where: { confirmado: false, origem: 'AUTOMATICA' },
    })

    // 2. Remover duplicados restantes (nao confirmados manuais, se existirem)
    const duplicados = await prisma.$queryRaw<{ faturaId: string; imovelId: string; count: bigint }[]>`
      SELECT "faturaId", "imovelId", COUNT(*) as count
      FROM "fatura_classificacao"
      WHERE confirmado = false
      GROUP BY "faturaId", "imovelId"
      HAVING COUNT(*) > 1
    `

    let removidos = 0
    for (const dup of duplicados) {
      const entries = await prisma.faturaClassificacao.findMany({
        where: { faturaId: dup.faturaId, imovelId: dup.imovelId, confirmado: false },
        orderBy: { id: 'desc' },
        select: { id: true },
      })
      const toDelete = entries.slice(1).map((e) => e.id)
      if (toDelete.length > 0) {
        await prisma.faturaClassificacao.deleteMany({ where: { id: { in: toDelete } } })
        removidos += toDelete.length
      }
    }

    return Response.json({
      ok: true,
      automaticasRemovidas: limpas.count,
      duplicadosRemovidos: removidos,
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
