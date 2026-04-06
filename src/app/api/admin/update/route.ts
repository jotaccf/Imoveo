import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { spawn } from 'child_process'

export async function POST() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    // Lançar update como processo independente (sobrevive ao restart do container)
    const updateScript = '/opt/imoveo/update.sh'
    const child = spawn('bash', [updateScript], {
      detached: true,
      stdio: 'ignore',
      cwd: '/opt/imoveo',
    })
    child.unref()

    // Responder imediatamente — o update corre em background
    return Response.json({
      message: 'Actualizacao iniciada. A aplicacao ira reiniciar em breve.',
    }, { status: 202 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao iniciar actualizacao' }, { status: 500 })
  }
}
