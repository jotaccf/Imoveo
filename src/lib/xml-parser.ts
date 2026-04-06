import { XMLParser } from 'fast-xml-parser'
import { z } from 'zod'

const faturaSchema = z.object({
  nifEmitente: z.string().min(1),
  nifDestinatario: z.string().optional(),
  nomeEmitente: z.string().optional(),
  serieDoc: z.string().min(1),
  numeroDoc: z.string().min(1),
  dataFatura: z.coerce.date(),
  totalSemIva: z.coerce.number(),
  totalIva: z.coerce.number(),
  totalComIva: z.coerce.number(),
  tipoDocumento: z.string().optional(),
})

export type FaturaParsed = z.infer<typeof faturaSchema>

function separarNumDoc(numDoc: string): { serieDoc: string; numeroDoc: string } {
  const lastSlash = numDoc.lastIndexOf('/')
  if (lastSlash === -1) {
    return { serieDoc: '', numeroDoc: numDoc }
  }
  return {
    serieDoc: numDoc.substring(0, lastSlash).trim(),
    numeroDoc: numDoc.substring(lastSlash + 1).trim(),
  }
}

export function parseXmlEFatura(buffer: Buffer, tipo: 'EMITIDAS' | 'RECEBIDAS'): FaturaParsed[] {
  const parser = new XMLParser({
    ignoreAttributes: false,
    isArray: (name) => name === 'Invoice' || name === 'Line',
  })

  const xml = parser.parse(buffer.toString('utf-8'))

  // Navigate SAFT-PT structure
  const auditFile = xml['AuditFile'] || xml['n1:AuditFile'] || xml
  const sourceDocuments = auditFile?.SourceDocuments
  const salesInvoices = sourceDocuments?.SalesInvoices
  const invoices = salesInvoices?.Invoice || []

  if (!Array.isArray(invoices)) {
    if (invoices && typeof invoices === 'object') {
      return parseSingleInvoice(invoices, tipo)
    }
    return []
  }

  const faturas: FaturaParsed[] = []

  for (const inv of invoices) {
    try {
      const parsed = parseSingleInvoice(inv, tipo)
      faturas.push(...parsed)
    } catch {
      // Skip invalid invoices
    }
  }

  return faturas
}

function parseSingleInvoice(inv: Record<string, unknown>, tipo: 'EMITIDAS' | 'RECEBIDAS'): FaturaParsed[] {
  const numDoc = String(inv['InvoiceNo'] || '')
  const { serieDoc, numeroDoc } = separarNumDoc(numDoc)

  const nifEmitente = tipo === 'EMITIDAS'
    ? String((inv as Record<string, unknown>)['CustomerTaxID'] || (inv as Record<string, Record<string, unknown>>)['DocumentTotals']?.['CustomerID'] || '')
    : String((inv as Record<string, unknown>)['SupplierTaxID'] || '')

  const nifDestinatario = tipo === 'EMITIDAS'
    ? undefined
    : String((inv as Record<string, unknown>)['CustomerTaxID'] || '')

  const totals = (inv as Record<string, Record<string, unknown>>)['DocumentTotals'] || {}

  const raw = {
    nifEmitente: nifEmitente || String(inv['TaxRegistrationNumber'] || ''),
    nifDestinatario: nifDestinatario || undefined,
    nomeEmitente: String(inv['SupplierName'] || inv['CustomerName'] || '') || undefined,
    serieDoc,
    numeroDoc,
    dataFatura: String(inv['InvoiceDate'] || ''),
    totalSemIva: Number(totals['NetTotal'] || 0),
    totalIva: Number(totals['TaxPayable'] || 0),
    totalComIva: Number(totals['GrossTotal'] || 0),
    tipoDocumento: String(inv['InvoiceType'] || inv['MovementType'] || '') || undefined,
  }

  const result = faturaSchema.safeParse(raw)
  if (!result.success) {
    throw new Error(`Fatura invalida: ${result.error.message}`)
  }

  return [result.data]
}

export { separarNumDoc }
