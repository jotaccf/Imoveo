import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { readFileSync, existsSync } from 'fs'

const isWindows = process.platform === 'win32'
const UPDATE_FLAG = isWindows ? '' : '/opt/imoveo/UPDATE_REQUESTED'
const UPDATE_LOG = isWindows ? '' : '/opt/backups/imoveo/update.log'

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const pending = UPDATE_FLAG ? existsSync(UPDATE_FLAG) : false

    let logs = ''
    if (UPDATE_LOG && existsSync(UPDATE_LOG)) {
      const content = readFileSync(UPDATE_LOG, 'utf-8')
      const lines = content.split('\n')
      // Ultimas 50 linhas
      logs = lines.slice(-50).join('\n')
    }

    // Verificar se o update terminou (ultima linha contem "concluida")
    const completed = logs.includes('actualizacao concluida') || logs.includes('Update watcher: actualizacao concluida')

    // Extrair ultima timestamp do log
    const lastLine = logs.trim().split('\n').pop() || ''

    return Response.json({
      data: {
        pending,
        completed,
        logs,
        lastLine,
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
