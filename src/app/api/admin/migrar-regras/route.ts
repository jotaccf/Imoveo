import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function POST() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    // Buscar todos os NifImovelMap activos
    const maps = await prisma.nifImovelMap.findMany({
      where: { ativo: true },
      include: { entidade: true },
    })

    let migrados = 0
    let ignorados = 0

    for (const map of maps) {
      // Verificar se ja existe template para este NIF
      const existing = await prisma.distribuicaoTemplate.findUnique({
        where: { nifEntidade: map.nifEntidade },
      })

      if (existing) {
        ignorados++
        continue
      }

      // Garantir entidade existe
      if (!map.entidade) {
        await prisma.entidade.upsert({
          where: { nif: map.nifEntidade },
          update: {},
          create: { nif: map.nifEntidade, nome: map.nifEntidade, tipo: 'FORNECEDOR' },
        })
      }

      // Criar template
      await prisma.distribuicaoTemplate.create({
        data: {
          nifEntidade: map.nifEntidade,
          rubricaId: map.rubricaId,
          tipo: 'IGUAL',
          linhas: map.imovelId ? {
            create: [{
              imovelId: map.imovelId,
              fracaoId: map.fracaoId || null,
              ordem: 0,
            }],
          } : undefined,
        },
      })
      migrados++
    }

    return Response.json({
      ok: true,
      total: maps.length,
      migrados,
      ignorados,
      message: `${migrados} regra${migrados !== 1 ? 's' : ''} migrada${migrados !== 1 ? 's' : ''}, ${ignorados} ignorada${ignorados !== 1 ? 's' : ''} (ja existiam)`,
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno', details: String(e) }, { status: 500 })
  }
}
