import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { writeFileSync, readFileSync, existsSync, mkdirSync, unlinkSync } from 'fs'
import { join } from 'path'

const MAX_SIZE = 10 * 1024 * 1024 // 10MB

export async function POST(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { id } = await params
    const contrato = await prisma.contrato.findUnique({ where: { id } })
    if (!contrato) return Response.json({ error: 'Contrato nao encontrado' }, { status: 404 })

    const formData = await req.formData()
    const file = formData.get('file') as File | null
    if (!file) return Response.json({ error: 'Ficheiro em falta' }, { status: 400 })

    if (file.size > MAX_SIZE) {
      return Response.json({ error: 'Ficheiro demasiado grande (max 10MB)' }, { status: 400 })
    }

    if (!file.name.toLowerCase().endsWith('.pdf')) {
      return Response.json({ error: 'Apenas ficheiros PDF sao aceites' }, { status: 400 })
    }

    // Remover ficheiro anterior se existir
    if (contrato.contratoAssinadoPath) {
      const oldPath = join(process.cwd(), contrato.contratoAssinadoPath)
      try { if (existsSync(oldPath)) unlinkSync(oldPath) } catch { /* */ }
    }

    const dir = join(process.cwd(), 'uploads', 'contratos')
    try { mkdirSync(dir, { recursive: true }) } catch { /* */ }

    const filename = `${id}_assinado.pdf`
    const filePath = join(dir, filename)
    const buffer = Buffer.from(await file.arrayBuffer())
    writeFileSync(filePath, buffer)

    const relativePath = `uploads/contratos/${filename}`
    await prisma.contrato.update({
      where: { id },
      data: { contratoAssinadoPath: relativePath },
    })

    return Response.json({ data: { contratoAssinadoPath: relativePath } })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    console.error('[assinado/POST]', e)
    return Response.json({ error: 'Erro ao carregar contrato assinado' }, { status: 500 })
  }
}

export async function GET(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })

    const { id } = await params
    const contrato = await prisma.contrato.findUnique({
      where: { id },
      select: { contratoAssinadoPath: true, nomeInquilino: true },
    })
    if (!contrato?.contratoAssinadoPath) return Response.json({ error: 'Sem contrato assinado' }, { status: 404 })

    const fullPath = join(process.cwd(), contrato.contratoAssinadoPath)
    if (!existsSync(fullPath)) return Response.json({ error: 'Ficheiro nao encontrado' }, { status: 404 })

    const fileBuffer = readFileSync(fullPath)
    const safeName = contrato.nomeInquilino.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_-]/g, '')

    return new Response(fileBuffer, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': `inline; filename="Contrato_Assinado_${safeName}.pdf"`,
      },
    })
  } catch (e) {
    console.error('[assinado/GET]', e)
    return Response.json({ error: 'Erro ao servir contrato assinado' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { id } = await params
    const contrato = await prisma.contrato.findUnique({
      where: { id },
      select: { contratoAssinadoPath: true },
    })
    if (!contrato) return Response.json({ error: 'Contrato nao encontrado' }, { status: 404 })

    if (contrato.contratoAssinadoPath) {
      const fullPath = join(process.cwd(), contrato.contratoAssinadoPath)
      try { if (existsSync(fullPath)) unlinkSync(fullPath) } catch { /* */ }
    }

    await prisma.contrato.update({
      where: { id },
      data: { contratoAssinadoPath: null },
    })

    return Response.json({ message: 'Contrato assinado removido' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    console.error('[assinado/DELETE]', e)
    return Response.json({ error: 'Erro ao remover contrato assinado' }, { status: 500 })
  }
}
