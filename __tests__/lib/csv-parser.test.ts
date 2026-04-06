import { parseCsvEFatura, parseEmitente, parseNumFatura, parseValorPT } from '@/lib/csv-parser'

describe('csv-parser', () => {
  describe('parseValorPT', () => {
    test('parses "1.239,68 €" to 1239.68', () => {
      expect(parseValorPT('1.239,68 €')).toBeCloseTo(1239.68)
    })

    test('parses "70,29 €" to 70.29', () => {
      expect(parseValorPT('70,29 €')).toBeCloseTo(70.29)
    })

    test('parses "0" to 0', () => {
      expect(parseValorPT('0')).toBe(0)
    })

    test('parses "12.345.678,90 €" to 12345678.90', () => {
      expect(parseValorPT('12.345.678,90 €')).toBeCloseTo(12345678.90)
    })
  })

  describe('parseEmitente', () => {
    test('parses "501293710 - Jocel Lda"', () => {
      const { nif, nome } = parseEmitente('501293710 - Jocel Lda')
      expect(nif).toBe('501293710')
      expect(nome).toBe('Jocel Lda')
    })

    test('parses NIF with long company name', () => {
      const { nif, nome } = parseEmitente('502022892 - Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda')
      expect(nif).toBe('502022892')
      expect(nome).toBe('Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda')
    })

    test('handles plain NIF without name', () => {
      const { nif, nome } = parseEmitente('501293710')
      expect(nif).toBe('501293710')
      expect(nome).toBe('')
    })
  })

  describe('parseNumFatura', () => {
    test('parses "FT FA.2026/461 / J6NTT56K-461"', () => {
      const { serieDoc, numeroDoc } = parseNumFatura('FT FA.2026/461 / J6NTT56K-461')
      expect(serieDoc).toBe('FT FA.2026')
      expect(numeroDoc).toBe('461')
    })

    test('parses "FT 11.1/307 / JFX4SDB2-307"', () => {
      const { serieDoc, numeroDoc } = parseNumFatura('FT 11.1/307 / JFX4SDB2-307')
      expect(serieDoc).toBe('FT 11.1')
      expect(numeroDoc).toBe('307')
    })

    test('parses "FT FT26/013760" (without ATCUD)', () => {
      const { serieDoc, numeroDoc } = parseNumFatura('FT FT26/013760')
      expect(serieDoc).toBe('FT FT26')
      expect(numeroDoc).toBe('013760')
    })

    test('parses "1 2026/28 / J6HD9ZX5-28"', () => {
      const { serieDoc, numeroDoc } = parseNumFatura('1 2026/28 / J6HD9ZX5-28')
      expect(serieDoc).toBe('1 2026')
      expect(numeroDoc).toBe('28')
    })

    test('parses "G 1123-23P/204582 / JFNZHP38-204582"', () => {
      const { serieDoc, numeroDoc } = parseNumFatura('G 1123-23P/204582 / JFNZHP38-204582')
      expect(serieDoc).toBe('G 1123-23P')
      expect(numeroDoc).toBe('204582')
    })
  })

  describe('parseCsvEFatura', () => {
    test('parses a valid e-Fatura CSV', () => {
      const csv = `"Setor";"Emitente";"Nº Fatura / ATCUD";"Tipo";"Data Emissão";"Total";"IVA";"Base Tributável";"Situação";"Comunicação  Emitente";"Comunicação  Adquirente"
"Outros";"501293710 - Jocel Lda";"FT FA.2026/462 / J6NTT56K-462";"Fatura";"2026-01-22";"1.169,68 €";"218,72 €";"950,96 €";"Registado";"X";""
"Outros";"506848558 - Bcm Bricolage S A";"FT 20260085701/000508 / JJC8DNKH-000508";"Fatura";"2026-01-19";"687,87 €";"128,63 €";"559,24 €";"Registado";"X";""`

      const faturas = parseCsvEFatura(Buffer.from(csv))
      expect(faturas).toHaveLength(2)

      expect(faturas[0].nifEmitente).toBe('501293710')
      expect(faturas[0].nomeEmitente).toBe('Jocel Lda')
      expect(faturas[0].serieDoc).toBe('FT FA.2026')
      expect(faturas[0].numeroDoc).toBe('462')
      expect(faturas[0].totalComIva).toBeCloseTo(1169.68)
      expect(faturas[0].totalIva).toBeCloseTo(218.72)
      expect(faturas[0].totalSemIva).toBeCloseTo(950.96)

      expect(faturas[1].nifEmitente).toBe('506848558')
    })

    test('returns empty array for empty CSV', () => {
      const csv = `"Setor";"Emitente";"Nº Fatura / ATCUD";"Tipo";"Data Emissão";"Total";"IVA";"Base Tributável";"Situação";"Comunicação  Emitente";"Comunicação  Adquirente"`
      const faturas = parseCsvEFatura(Buffer.from(csv))
      expect(faturas).toHaveLength(0)
    })
  })
})
