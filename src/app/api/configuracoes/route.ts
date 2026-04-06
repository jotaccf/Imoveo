import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const rows = await prisma.configuracao.findMany()
    const configs: Record<string, string> = {}
    for (const row of rows) {
      configs[row.chave] = row.valor
    }

    return Response.json({ data: configs })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

export async function PUT(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const body = await req.json()
    const { configs } = body as { configs: Record<string, string> }

    if (!configs || typeof configs !== 'object') {
      return Response.json({ error: 'Dados invalidos: campo configs obrigatorio' }, { status: 400 })
    }

    const entries = Object.entries(configs)
    if (entries.length === 0) {
      return Response.json({ error: 'Dados invalidos: configs vazio' }, { status: 400 })
    }

    for (const [chave, valor] of entries) {
      await prisma.configuracao.upsert({
        where: { chave },
        update: { valor: String(valor) },
        create: { chave, valor: String(valor) },
      })
    }

    // Return the full updated config set
    const rows = await prisma.configuracao.findMany()
    const updatedConfigs: Record<string, string> = {}
    for (const row of rows) {
      updatedConfigs[row.chave] = row.valor
    }

    return Response.json({ data: updatedConfigs })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
