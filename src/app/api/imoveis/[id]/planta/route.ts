import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { writeFileSync, readFileSync, existsSync, mkdirSync, unlinkSync } from 'fs'
import { join, extname } from 'path'

const ALLOWED_EXTENSIONS = ['.pdf', '.jpg', '.jpeg', '.png']
const MAX_SIZE = 10 * 1024 * 1024 // 10MB

const CONTENT_TYPES: Record<string, string> = {
  '.pdf': 'application/pdf',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
}

export async function POST(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { id } = await params
    const imovel = await prisma.imovel.findUnique({ where: { id } })
    if (!imovel) return Response.json({ error: 'Imovel nao encontrado' }, { status: 404 })

    const formData = await req.formData()
    const file = formData.get('file') as File | null
    if (!file) return Response.json({ error: 'Ficheiro em falta' }, { status: 400 })

    if (file.size > MAX_SIZE) {
      return Response.json({ error: 'Ficheiro demasiado grande (max 10MB)' }, { status: 400 })
    }

    const ext = extname(file.name).toLowerCase()
    if (!ALLOWED_EXTENSIONS.includes(ext)) {
      return Response.json({ error: 'Formato nao suportado. Use PDF, JPG ou PNG.' }, { status: 400 })
    }

    // Remover ficheiro anterior se existir
    if (imovel.plantaPath) {
      const oldPath = join(process.cwd(), imovel.plantaPath)
      try { if (existsSync(oldPath)) unlinkSync(oldPath) } catch { /* */ }
    }

    const dir = join(process.cwd(), 'uploads', 'plantas')
    try { mkdirSync(dir, { recursive: true }) } catch { /* */ }

    const filename = `${id}${ext}`
    const filePath = join(dir, filename)
    const buffer = Buffer.from(await file.arrayBuffer())
    writeFileSync(filePath, buffer)

    const relativePath = `uploads/plantas/${filename}`
    await prisma.imovel.update({
      where: { id },
      data: { plantaPath: relativePath },
    })

    return Response.json({ data: { plantaPath: relativePath } })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    console.error('[planta/POST]', e)
    return Response.json({ error: 'Erro ao carregar planta' }, { status: 500 })
  }
}

export async function GET(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })

    const { id } = await params
    const imovel = await prisma.imovel.findUnique({ where: { id }, select: { plantaPath: true } })
    if (!imovel?.plantaPath) return Response.json({ error: 'Sem planta' }, { status: 404 })

    const fullPath = join(process.cwd(), imovel.plantaPath)
    if (!existsSync(fullPath)) return Response.json({ error: 'Ficheiro nao encontrado' }, { status: 404 })

    const ext = extname(fullPath).toLowerCase()
    const contentType = CONTENT_TYPES[ext] || 'application/octet-stream'
    const fileBuffer = readFileSync(fullPath)

    return new Response(fileBuffer, {
      headers: {
        'Content-Type': contentType,
        'Content-Disposition': `inline; filename="planta_${id}${ext}"`,
      },
    })
  } catch (e) {
    console.error('[planta/GET]', e)
    return Response.json({ error: 'Erro ao servir planta' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:editar')

    const { id } = await params
    const imovel = await prisma.imovel.findUnique({ where: { id }, select: { plantaPath: true } })
    if (!imovel) return Response.json({ error: 'Imovel nao encontrado' }, { status: 404 })

    if (imovel.plantaPath) {
      const fullPath = join(process.cwd(), imovel.plantaPath)
      try { if (existsSync(fullPath)) unlinkSync(fullPath) } catch { /* */ }
    }

    await prisma.imovel.update({
      where: { id },
      data: { plantaPath: null },
    })

    return Response.json({ message: 'Planta removida' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    console.error('[planta/DELETE]', e)
    return Response.json({ error: 'Erro ao remover planta' }, { status: 500 })
  }
}
