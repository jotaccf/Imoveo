import { hashFicheiro, hashFatura } from '@/lib/deduplicacao'

describe('deduplicacao', () => {
  describe('hashFicheiro', () => {
    test('produces consistent output for the same input', () => {
      const buffer = Buffer.from('conteudo do ficheiro de teste')
      const hash1 = hashFicheiro(buffer)
      const hash2 = hashFicheiro(buffer)
      expect(hash1).toBe(hash2)
    })

    test('produces different output for different input', () => {
      const buffer1 = Buffer.from('ficheiro A')
      const buffer2 = Buffer.from('ficheiro B')
      expect(hashFicheiro(buffer1)).not.toBe(hashFicheiro(buffer2))
    })

    test('returns a 64-character hex string (SHA-256)', () => {
      const buffer = Buffer.from('qualquer conteudo')
      const hash = hashFicheiro(buffer)
      expect(hash).toMatch(/^[a-f0-9]{64}$/)
    })

    test('handles empty buffer', () => {
      const buffer = Buffer.from('')
      const hash = hashFicheiro(buffer)
      expect(hash).toMatch(/^[a-f0-9]{64}$/)
    })
  })

  describe('hashFatura', () => {
    test('is deterministic - same inputs produce same hash', () => {
      const hash1 = hashFatura('123456789', 'FT 2024', '001')
      const hash2 = hashFatura('123456789', 'FT 2024', '001')
      expect(hash1).toBe(hash2)
    })

    test('produces different hashes for different NIF', () => {
      const hash1 = hashFatura('123456789', 'FT 2024', '001')
      const hash2 = hashFatura('987654321', 'FT 2024', '001')
      expect(hash1).not.toBe(hash2)
    })

    test('produces different hashes for different serie', () => {
      const hash1 = hashFatura('123456789', 'FT 2024', '001')
      const hash2 = hashFatura('123456789', 'FT 2025', '001')
      expect(hash1).not.toBe(hash2)
    })

    test('produces different hashes for different numero', () => {
      const hash1 = hashFatura('123456789', 'FT 2024', '001')
      const hash2 = hashFatura('123456789', 'FT 2024', '002')
      expect(hash1).not.toBe(hash2)
    })

    test('returns a 64-character hex string (SHA-256)', () => {
      const hash = hashFatura('123456789', 'FT 2024', '001')
      expect(hash).toMatch(/^[a-f0-9]{64}$/)
    })
  })
})
