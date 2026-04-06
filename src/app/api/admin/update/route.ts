import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { writeFileSync } from 'fs'

export async function POST() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    // Escrever flag que o cron do host detecta e executa o update.sh
    // Isto resolve o problema de o container morrer durante o rebuild
    const flagPath = '/opt/imoveo/UPDATE_REQUESTED'
    writeFileSync(flagPath, new Date().toISOString())

    return Response.json({
      message: 'Actualizacao agendada. A aplicacao ira reiniciar em breve.',
    }, { status: 202 })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao iniciar actualizacao' }, { status: 500 })
  }
}
