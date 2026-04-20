import { createHash } from 'crypto'
import { prisma } from '@/lib/prisma'
import { parseCsvEFatura, detectFormat } from '@/lib/csv-parser'
import { parseXmlEFatura } from '@/lib/xml-parser'
import { classificarFatura } from '@/lib/classificacao'
import type { RelatorioImportacao } from '@/types'

export function hashFicheiro(buffer: Buffer): string {
  return createHash('sha256').update(buffer).digest('hex')
}

export function hashFatura(nifEmitente: string, serieDoc: string, numeroDoc: string): string {
  return createHash('sha256')
    .update(`${nifEmitente}|${serieDoc}|${numeroDoc}`)
    .digest('hex')
}

function detectarPeriodo(datas: Date[]): string {
  if (datas.length === 0) return new Date().toISOString().slice(0, 7)

  let min = datas[0], max = datas[0]
  for (const d of datas) {
    if (d < min) min = d
    if (d > max) max = d
  }

  const minMonth = `${min.getFullYear()}-${String(min.getMonth() + 1).padStart(2, '0')}`
  const maxMonth = `${max.getFullYear()}-${String(max.getMonth() + 1).padStart(2, '0')}`

  if (minMonth === maxMonth) return minMonth
  return `${minMonth} a ${maxMonth}`
}

function detectarTipoCSV(buffer: Buffer): 'EMITIDAS' | 'RECEBIDAS' {
  // Read first line to detect format
  const firstLine = buffer.toString('utf-8').split('\n')[0] || ''
  const headers = firstLine.split(';').map((h) => h.replace(/"/g, '').trim())
  return detectFormat(headers)
}

export async function processarImportacao(
  buffer: Buffer,
  filename: string,
): Promise<RelatorioImportacao> {
  // Nivel 1 — Verificar ficheiro duplicado
  const fileHash = hashFicheiro(buffer)
  const existente = await prisma.importacao.findUnique({
    where: { hashFicheiro: fileHash },
  })

  if (existente) {
    return {
      ficheiroDuplicado: true,
      importacaoId: existente.id,
      totalFaturas: existente.totalFaturas,
      novas: 0,
      duplicadas: existente.totalFaturas,
      pendentes: 0,
    }
  }

  // Parse ficheiro — detectar formato automaticamente
  const isCSV = filename.toLowerCase().endsWith('.csv')
  const tipoFicheiro = isCSV ? detectarTipoCSV(buffer) : 'RECEBIDAS'
  const faturasParsed = isCSV
    ? parseCsvEFatura(buffer)
    : parseXmlEFatura(buffer, tipoFicheiro)
  const totalFaturas = faturasParsed.length

  // Detectar periodo automaticamente a partir das datas
  const periodo = detectarPeriodo(faturasParsed.map((f) => new Date(f.dataFatura)))

  let novas = 0
  let duplicadas = 0
  let pendentes = 0

  // Criar importacao
  const importacao = await prisma.importacao.create({
    data: {
      filename,
      hashFicheiro: fileHash,
      periodo,
      tipoFicheiro,
      totalFaturas,
    },
  })

  // Nivel 2 — Inserir faturas com deduplicacao
  for (const fp of faturasParsed) {
    const fatHash = hashFatura(fp.nifEmitente, fp.serieDoc, fp.numeroDoc)

    try {
      const fatura = await prisma.fatura.create({
        data: {
          hashFatura: fatHash,
          nifEmitente: fp.nifEmitente,
          serieDoc: fp.serieDoc,
          numeroDoc: fp.numeroDoc,
          nifDestinatario: fp.nifDestinatario,
          nomeEmitente: fp.nomeEmitente,
          dataFatura: fp.dataFatura,
          totalSemIva: fp.totalSemIva,
          totalIva: fp.totalIva,
          totalComIva: fp.totalComIva,
          tipoDocumento: fp.tipoDocumento,
          importacaoId: importacao.id,
        },
      })

      novas++

      // Tentar classificacao automatica
      // Para emitidas: procurar pelo NIF do adquirente (inquilino), rubrica é sempre "Receita"
      // Para recebidas: procurar pelo NIF do emitente (fornecedor)
      const nifParaClassificar = tipoFicheiro === 'EMITIDAS' && fp.nifDestinatario
        ? fp.nifDestinatario
        : fp.nifEmitente
      const result = await classificarFatura(fatura.id, nifParaClassificar, tipoFicheiro === 'EMITIDAS')
      // FULL = classificada, TEMPLATE/PARTIAL = precisa confirmacao, false = sem regra
      if (result !== 'FULL') {
        pendentes++
      }
    } catch {
      // Duplicate — skip
      duplicadas++
    }
  }

  // Actualizar contadores na importacao
  await prisma.importacao.update({
    where: { id: importacao.id },
    data: { novas, duplicadas, pendentes },
  })

  return {
    ficheiroDuplicado: false,
    importacaoId: importacao.id,
    totalFaturas,
    novas,
    duplicadas,
    pendentes,
    periodo,
    tipoFicheiro,
  }
}
