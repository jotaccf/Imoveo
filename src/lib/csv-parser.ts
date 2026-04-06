import Papa from 'papaparse'
import { z } from 'zod'

const faturaSchema = z.object({
  nifEmitente: z.string().min(1),
  nifDestinatario: z.string().optional(),
  nomeEmitente: z.string().optional(),
  serieDoc: z.string().min(1),
  numeroDoc: z.string().min(1),
  tipoDocumento: z.string().optional(),
  dataFatura: z.coerce.date(),
  totalComIva: z.coerce.number(),
  totalIva: z.coerce.number(),
  totalSemIva: z.coerce.number(),
  situacao: z.string().optional(),
})

export type FaturaParsed = z.infer<typeof faturaSchema>

function parseValorPT(valor: string): number {
  // "1.239,68 €" -> 1239.68
  if (!valor || valor.trim() === '') return 0
  return Number(valor.replace(/[^\d,\-]/g, '').replace(/\./g, '').replace(',', '.'))
}

function parseEmitente(emitente: string): { nif: string; nome: string } {
  // "501293710 - Jocel Lda"
  const match = emitente.match(/^(\d+)\s*-\s*(.+)$/)
  if (match) return { nif: match[1].trim(), nome: match[2].trim() }
  return { nif: emitente.trim(), nome: '' }
}

function parseNumFatura(numFatura: string): { serieDoc: string; numeroDoc: string } {
  // "FT FA.2026/461 / J6NTT56K-461" -> serie="FT FA.2026", numero="461"
  // Remove ATCUD part (after " / " with pattern like XXXXXXXX-NNN)
  let doc = numFatura
  const atcudMatch = doc.match(/\s*\/\s*[A-Z0-9]{8}-\d+$/)
  if (atcudMatch) {
    doc = doc.substring(0, doc.length - atcudMatch[0].length).trim()
  }

  // Separate by last "/"
  const lastSlash = doc.lastIndexOf('/')
  if (lastSlash === -1) return { serieDoc: '', numeroDoc: doc.trim() }
  return {
    serieDoc: doc.substring(0, lastSlash).trim(),
    numeroDoc: doc.substring(lastSlash + 1).trim(),
  }
}

type CsvFormat = 'RECEBIDAS' | 'EMITIDAS'

function detectFormat(headers: string[]): CsvFormat {
  // Emitidas: has "NIF Adquirente" and "Nº Documento / ATCUD"
  // Recebidas: has "Emitente" and "Nº Fatura / ATCUD"
  if (headers.some((h) => h.includes('NIF Adquirente') || h.includes('Documento'))) {
    return 'EMITIDAS'
  }
  return 'RECEBIDAS'
}

function getField(row: Record<string, string>, ...keys: string[]): string {
  for (const k of keys) {
    if (row[k] !== undefined && row[k] !== '') return row[k]
  }
  return ''
}

export function parseCsvEFatura(buffer: Buffer): FaturaParsed[] {
  const text = buffer.toString('utf-8')
  const result = Papa.parse(text, {
    header: true,
    delimiter: ';',
    skipEmptyLines: true,
  })

  if (result.errors.length > 0 && result.data.length === 0) {
    throw new Error(`Erro ao processar CSV: ${result.errors[0]?.message}`)
  }

  const headers = result.meta.fields || []
  const format = detectFormat(headers)

  const faturas: FaturaParsed[] = []

  for (const row of result.data as Record<string, string>[]) {
    try {
      // Ignorar documentos anulados
      const situacao = getField(row, 'Situação', 'Situa\u00e7\u00e3o')
      if (situacao.toLowerCase().includes('anulado')) continue

      let nifEmitente = ''
      let nifDestinatario: string | undefined
      let nomeEmitente: string | undefined
      let numDocRaw = ''

      if (format === 'RECEBIDAS') {
        // Recebidas: "Emitente" = "NIF - Nome", "Nº Fatura / ATCUD"
        const emitente = parseEmitente(getField(row, 'Emitente'))
        nifEmitente = emitente.nif
        nomeEmitente = emitente.nome || undefined
        numDocRaw = getField(row, 'Nº Fatura / ATCUD', 'N\u00ba Fatura / ATCUD')
      } else {
        // Emitidas: "NIF Adquirente", "Nº Documento / ATCUD"
        nifDestinatario = getField(row, 'NIF Adquirente').trim() || undefined
        numDocRaw = getField(row, 'Nº Documento / ATCUD', 'N\u00ba Documento / ATCUD')
        // Para emitidas, o NIF emitente somos nós — usar a serie do doc como identificador unico
        // (o NIF da empresa não consta no CSV de emitidas)
        nifEmitente = 'EMITIDA' // emitidas não têm NIF emitente no CSV
      }

      const numDoc = parseNumFatura(numDocRaw)

      const tipoDoc = getField(row, 'Tipo', 'Tipo do Documento')
      const isNotaCredito = tipoDoc.toLowerCase().includes('cr\u00e9dito') || tipoDoc.toLowerCase().includes('credito')
      const sinal = isNotaCredito ? -1 : 1

      const raw = {
        nifEmitente,
        nifDestinatario,
        nomeEmitente,
        serieDoc: numDoc.serieDoc,
        numeroDoc: numDoc.numeroDoc,
        tipoDocumento: tipoDoc || undefined,
        dataFatura: getField(row, 'Data Emissão', 'Data Emiss\u00e3o'),
        totalComIva: parseValorPT(getField(row, 'Total')) * sinal,
        totalIva: parseValorPT(getField(row, 'IVA')) * sinal,
        totalSemIva: parseValorPT(getField(row, 'Base Tributável', 'Base Tribut\u00e1vel')) * sinal,
        situacao: getField(row, 'Situação', 'Situa\u00e7\u00e3o') || undefined,
      }

      const parsed = faturaSchema.safeParse(raw)
      if (parsed.success) {
        faturas.push(parsed.data)
      }
    } catch {
      // Skip invalid rows
    }
  }

  return faturas
}

export { parseEmitente, parseNumFatura, parseValorPT, detectFormat }
