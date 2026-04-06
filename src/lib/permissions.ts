export type Role = 'ADMIN' | 'GESTOR' | 'OPERADOR'

export const PERMISSIONS = {
  'imoveis:ver':              ['ADMIN', 'GESTOR'],
  'imoveis:criar':            ['ADMIN'],
  'imoveis:editar':           ['ADMIN'],
  'imoveis:remover':          ['ADMIN'],
  'xml:importar':             ['ADMIN', 'GESTOR', 'OPERADOR'],
  'xml:historico':            ['ADMIN', 'GESTOR'],
  'faturas:ver':              ['ADMIN', 'GESTOR'],
  'faturas:exportar':         ['ADMIN', 'GESTOR'],
  'pendentes:ver':            ['ADMIN', 'GESTOR', 'OPERADOR'],
  'pendentes:classificar':    ['ADMIN', 'GESTOR', 'OPERADOR'],
  'lancamentos:ver':          ['ADMIN', 'GESTOR', 'OPERADOR'],
  'lancamentos:criar':        ['ADMIN', 'GESTOR', 'OPERADOR'],
  'lancamentos:editar':       ['ADMIN', 'GESTOR'],
  'lancamentos:remover':      ['ADMIN'],
  'resultados:ver':           ['ADMIN', 'GESTOR'],
  'resultados:exportar':      ['ADMIN', 'GESTOR'],
  'mapeamento:ver':           ['ADMIN', 'GESTOR'],
  'mapeamento:editar':        ['ADMIN'],
  'utilizadores:ver':         ['ADMIN'],
  'utilizadores:criar':       ['ADMIN'],
  'utilizadores:editar':      ['ADMIN'],
  'utilizadores:remover':     ['ADMIN'],
  'dashboard:completo':       ['ADMIN', 'GESTOR'],
  'dashboard:basico':         ['ADMIN', 'GESTOR', 'OPERADOR'],
} as const

export type Permission = keyof typeof PERMISSIONS

export function hasPermission(role: Role, permission: Permission): boolean {
  return (PERMISSIONS[permission] as readonly string[]).includes(role)
}

export function requirePermission(role: Role, permission: Permission): void {
  if (!hasPermission(role, permission)) {
    throw new Error(`Acesso negado: permissao ${permission} requer um dos roles: ${PERMISSIONS[permission].join(', ')}`)
  }
}
