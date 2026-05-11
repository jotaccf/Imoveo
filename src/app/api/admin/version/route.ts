import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { readFileSync } from 'fs'
import { join } from 'path'
import { debugLog } from '@/lib/debug-logger'

function getLocalVersion(): string {
  try {
    const versionFile = join(process.cwd(), 'VERSION')
    return readFileSync(versionFile, 'utf-8').trim()
  } catch {
    return '0.0.0'
  }
}

async function getRemoteVersion(): Promise<{ version: string; date: string } | null> {
  try {
    // Verificar VERSION directamente do repo (nao precisa de GitHub Releases)
    const res = await fetch(
      'https://raw.githubusercontent.com/jotaccf/Imoveo/main/VERSION',
      { next: { revalidate: 30 } } // cache 30s
    )
    if (!res.ok) return null
    const version = (await res.text()).trim()

    // Obter data do ultimo commit para contexto
    const commitRes = await fetch(
      'https://api.github.com/repos/jotaccf/Imoveo/commits/main',
      {
        headers: { Accept: 'application/vnd.github.v3+json' },
        next: { revalidate: 30 },
      }
    )
    const date = commitRes.ok
      ? (await commitRes.json()).commit?.committer?.date || ''
      : ''

    return { version, date }
  } catch {
    return null
  }
}

function isNewer(remote: string, local: string): boolean {
  const r = remote.split('.').map(Number)
  const l = local.split('.').map(Number)
  for (let i = 0; i < 3; i++) {
    if ((r[i] || 0) > (l[i] || 0)) return true
    if ((r[i] || 0) < (l[i] || 0)) return false
  }
  return false
}

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const local = getLocalVersion()
    const remote = await getRemoteVersion()

    const updateAvailable = remote ? isNewer(remote.version, local) : false

    if (updateAvailable) {
      debugLog('version', `Update disponivel: ${local} -> ${remote?.version}`)
    }

    return Response.json({
      data: {
        currentVersion: local,
        latestVersion: remote?.version || local,
        updateAvailable,
        releaseUrl: '',
        releaseDate: remote?.date || '',
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
