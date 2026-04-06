import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { writeFileSync, existsSync } from 'fs'
import { debugLog, debugError } from '@/lib/debug-logger'

const isWindows = process.platform === 'win32'
const FLAG_PATH = isWindows ? '' : '/opt/imoveo/UPDATE_REQUESTED'

export async function POST() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const user = (session.user as { nome?: string })?.nome || 'desconhecido'
    debugLog('update', `Update solicitado por ${user}`)

    if (!FLAG_PATH) {
      debugLog('update', 'AVISO: a correr em Windows, flag nao criada')
      return Response.json({ message: 'Update nao disponivel em Windows' }, { status: 400 })
    }

    // Escrever flag que o cron do host detecta e executa o update.sh
    writeFileSync(FLAG_PATH, new Date().toISOString())
    debugLog('update', `Flag criada em ${FLAG_PATH}`)

    // Verificar se o watcher cron esta configurado
    const watcherExists = existsSync('/opt/imoveo/update-watcher.sh')
    if (!watcherExists) {
      debugLog('update', 'AVISO: update-watcher.sh nao encontrado — cron pode nao estar configurado')
    }

    return Response.json({
      message: 'Actualizacao agendada. A aplicacao ira reiniciar em breve.',
      watcherConfigured: watcherExists,
    }, { status: 202 })
  } catch (e) {
    debugError('update', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao iniciar actualizacao', details: String(e) }, { status: 500 })
  }
}
