import { separarNumDoc, parseXmlEFatura } from '@/lib/xml-parser'

describe('xml-parser', () => {
  describe('separarNumDoc', () => {
    test('"FT 2024/001" -> serie="FT 2024", numero="001"', () => {
      const result = separarNumDoc('FT 2024/001')
      expect(result).toEqual({ serieDoc: 'FT 2024', numeroDoc: '001' })
    })

    test('"A/2024/1" -> serie="A/2024", numero="1"', () => {
      const result = separarNumDoc('A/2024/1')
      expect(result).toEqual({ serieDoc: 'A/2024', numeroDoc: '1' })
    })

    test('"DOC123" (no slash) -> serie="", numero="DOC123"', () => {
      const result = separarNumDoc('DOC123')
      expect(result).toEqual({ serieDoc: '', numeroDoc: 'DOC123' })
    })

    test('handles trailing/leading spaces around slash', () => {
      const result = separarNumDoc('FT 2024 / 001')
      expect(result).toEqual({ serieDoc: 'FT 2024', numeroDoc: '001' })
    })
  })

  describe('parseXmlEFatura', () => {
    const validXml = `<?xml version="1.0"?>
<AuditFile>
  <SourceDocuments>
    <SalesInvoices>
      <Invoice>
        <InvoiceNo>FT 2024/001</InvoiceNo>
        <InvoiceDate>2024-01-15</InvoiceDate>
        <InvoiceType>FT</InvoiceType>
        <CustomerTaxID>123456789</CustomerTaxID>
        <DocumentTotals>
          <NetTotal>100.00</NetTotal>
          <TaxPayable>23.00</TaxPayable>
          <GrossTotal>123.00</GrossTotal>
        </DocumentTotals>
      </Invoice>
    </SalesInvoices>
  </SourceDocuments>
</AuditFile>`

    test('parses a valid SAFT-PT XML structure', () => {
      const buffer = Buffer.from(validXml, 'utf-8')
      const result = parseXmlEFatura(buffer, 'EMITIDAS')

      expect(result).toHaveLength(1)
      expect(result[0]).toMatchObject({
        nifEmitente: '123456789',
        serieDoc: 'FT 2024',
        numeroDoc: '001',
        totalSemIva: 100,
        totalIva: 23,
        totalComIva: 123,
        tipoDocumento: 'FT',
      })
      expect(result[0].dataFatura).toBeInstanceOf(Date)
    })

    test('returns empty array for invalid XML', () => {
      const buffer = Buffer.from('this is not valid xml at all', 'utf-8')
      const result = parseXmlEFatura(buffer, 'EMITIDAS')

      expect(result).toEqual([])
    })

    test('returns empty array for XML without invoices', () => {
      const emptyXml = `<?xml version="1.0"?>
<AuditFile>
  <SourceDocuments>
    <SalesInvoices>
    </SalesInvoices>
  </SourceDocuments>
</AuditFile>`
      const buffer = Buffer.from(emptyXml, 'utf-8')
      const result = parseXmlEFatura(buffer, 'EMITIDAS')

      expect(result).toEqual([])
    })

    test('parses multiple invoices', () => {
      const multiXml = `<?xml version="1.0"?>
<AuditFile>
  <SourceDocuments>
    <SalesInvoices>
      <Invoice>
        <InvoiceNo>FT 2024/001</InvoiceNo>
        <InvoiceDate>2024-01-15</InvoiceDate>
        <InvoiceType>FT</InvoiceType>
        <CustomerTaxID>123456789</CustomerTaxID>
        <DocumentTotals>
          <NetTotal>100.00</NetTotal>
          <TaxPayable>23.00</TaxPayable>
          <GrossTotal>123.00</GrossTotal>
        </DocumentTotals>
      </Invoice>
      <Invoice>
        <InvoiceNo>FT 2024/002</InvoiceNo>
        <InvoiceDate>2024-02-20</InvoiceDate>
        <InvoiceType>FT</InvoiceType>
        <CustomerTaxID>987654321</CustomerTaxID>
        <DocumentTotals>
          <NetTotal>200.00</NetTotal>
          <TaxPayable>46.00</TaxPayable>
          <GrossTotal>246.00</GrossTotal>
        </DocumentTotals>
      </Invoice>
    </SalesInvoices>
  </SourceDocuments>
</AuditFile>`
      const buffer = Buffer.from(multiXml, 'utf-8')
      const result = parseXmlEFatura(buffer, 'EMITIDAS')

      expect(result).toHaveLength(2)
      expect(result[0].numeroDoc).toBe('001')
      expect(result[1].numeroDoc).toBe('002')
      expect(result[1].nifEmitente).toBe('987654321')
    })
  })
})
