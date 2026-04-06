import { hasPermission, requirePermission, PERMISSIONS, type Role, type Permission } from '@/lib/permissions'

describe('permissions', () => {
  const allPermissions = Object.keys(PERMISSIONS) as Permission[]

  describe('ADMIN has access to all resources', () => {
    test.each(allPermissions)('ADMIN has permission: %s', (perm) => {
      expect(hasPermission('ADMIN', perm)).toBe(true)
    })
  })

  describe('GESTOR restrictions', () => {
    test('GESTOR cannot criar imoveis', () => {
      expect(hasPermission('GESTOR', 'imoveis:criar')).toBe(false)
    })

    test('GESTOR cannot editar imoveis', () => {
      expect(hasPermission('GESTOR', 'imoveis:editar')).toBe(false)
    })

    test('GESTOR cannot remover imoveis', () => {
      expect(hasPermission('GESTOR', 'imoveis:remover')).toBe(false)
    })

    test('GESTOR cannot ver utilizadores', () => {
      expect(hasPermission('GESTOR', 'utilizadores:ver')).toBe(false)
    })

    test('GESTOR cannot criar utilizadores', () => {
      expect(hasPermission('GESTOR', 'utilizadores:criar')).toBe(false)
    })

    test('GESTOR cannot editar utilizadores', () => {
      expect(hasPermission('GESTOR', 'utilizadores:editar')).toBe(false)
    })

    test('GESTOR cannot remover utilizadores', () => {
      expect(hasPermission('GESTOR', 'utilizadores:remover')).toBe(false)
    })

    test('GESTOR can ver imoveis', () => {
      expect(hasPermission('GESTOR', 'imoveis:ver')).toBe(true)
    })

    test('GESTOR can importar XML', () => {
      expect(hasPermission('GESTOR', 'xml:importar')).toBe(true)
    })

    test('GESTOR can ver resultados', () => {
      expect(hasPermission('GESTOR', 'resultados:ver')).toBe(true)
    })
  })

  describe('OPERADOR restrictions', () => {
    test('OPERADOR cannot ver resultados', () => {
      expect(hasPermission('OPERADOR', 'resultados:ver')).toBe(false)
    })

    test('OPERADOR cannot exportar resultados', () => {
      expect(hasPermission('OPERADOR', 'resultados:exportar')).toBe(false)
    })

    test('OPERADOR can importar XML', () => {
      expect(hasPermission('OPERADOR', 'xml:importar')).toBe(true)
    })

    test('OPERADOR can criar lancamentos', () => {
      expect(hasPermission('OPERADOR', 'lancamentos:criar')).toBe(true)
    })

    test('OPERADOR can ver lancamentos', () => {
      expect(hasPermission('OPERADOR', 'lancamentos:ver')).toBe(true)
    })

    test('OPERADOR can classificar pendentes', () => {
      expect(hasPermission('OPERADOR', 'pendentes:classificar')).toBe(true)
    })

    test('OPERADOR cannot ver imoveis', () => {
      expect(hasPermission('OPERADOR', 'imoveis:ver')).toBe(false)
    })

    test('OPERADOR cannot editar lancamentos', () => {
      expect(hasPermission('OPERADOR', 'lancamentos:editar')).toBe(false)
    })

    test('OPERADOR cannot ver faturas', () => {
      expect(hasPermission('OPERADOR', 'faturas:ver')).toBe(false)
    })

    test('OPERADOR can ver dashboard basico', () => {
      expect(hasPermission('OPERADOR', 'dashboard:basico')).toBe(true)
    })

    test('OPERADOR cannot ver dashboard completo', () => {
      expect(hasPermission('OPERADOR', 'dashboard:completo')).toBe(false)
    })
  })

  describe('hasPermission edge cases', () => {
    test('returns boolean true, not truthy', () => {
      const result = hasPermission('ADMIN', 'imoveis:ver')
      expect(result).toBe(true)
      expect(typeof result).toBe('boolean')
    })

    test('returns boolean false, not falsy', () => {
      const result = hasPermission('OPERADOR', 'imoveis:ver')
      expect(result).toBe(false)
      expect(typeof result).toBe('boolean')
    })
  })

  describe('requirePermission', () => {
    test('does not throw when role has permission', () => {
      expect(() => requirePermission('ADMIN', 'imoveis:criar')).not.toThrow()
    })

    test('throws when role lacks permission', () => {
      expect(() => requirePermission('OPERADOR', 'imoveis:ver')).toThrow('Acesso negado')
    })

    test('error message includes the permission name', () => {
      expect(() => requirePermission('GESTOR', 'utilizadores:ver')).toThrow('utilizadores:ver')
    })
  })
})
