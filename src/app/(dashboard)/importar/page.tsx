'use client'

import { useState } from 'react'
import { UploadZone } from '@/components/ui/UploadZone'
import { KpiCard } from '@/components/ui/KpiCard'
import { Card } from '@/components/ui/Card'
import { Table, Th, Td } from '@/components/ui/Table'
import { Badge } from '@/components/ui/Badge'
import type { RelatorioImportacao } from '@/types'

interface HistoryEntry {
  id: string
  filename: string
  periodo: string
  tipoFicheiro: string
  totalFaturas: number
  novas: number
  duplicadas: number
}

export default function ImportarPage() {
  const [relatorio, setRelatorio] = useState<RelatorioImportacao | null>(null)
  const [history, setHistory] = useState<HistoryEntry[]>([])

  async function handleUpload(file: File) {
    const formData = new FormData()
    formData.append('file', file)

    const res = await fetch('/api/faturas/importar', { method: 'POST', body: formData })
    const json = await res.json()

    if (!res.ok) {
      alert(json.error || 'Erro ao importar')
      throw new Error(json.error)
    }

    setRelatorio(json.data)

    if (json.data && !json.data.ficheiroDuplicado) {
      setHistory((prev) => [
        {
          id: json.data.importacaoId ?? Date.now().toString(),
          filename: file.name,
          periodo: json.data.periodo || '—',
          tipoFicheiro: json.data.tipoFicheiro || 'RECEBIDAS',
          totalFaturas: json.data.totalFaturas,
          novas: json.data.novas,
          duplicadas: json.data.duplicadas,
        },
        ...prev,
      ])
    }
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
      {/* Left column */}
      <div className="space-y-4">
        <Card>
          <h3 className="text-[13px] font-medium mb-3" style={{ color: '#0D1B1A' }}>Importar ficheiro e-Fatura</h3>
          <UploadZone onUpload={handleUpload} accept=".csv,.xml" />
        </Card>

        {relatorio && (
          <div className="space-y-3">
            {relatorio.ficheiroDuplicado && (
              <div className="rounded-lg bg-[#FAEEDA] px-4 py-3 text-sm text-[#633806]">
                Este ficheiro ja foi importado anteriormente.
              </div>
            )}

            {!relatorio.ficheiroDuplicado && (
              <>
                <div className="rounded-lg bg-brand-light px-4 py-2 text-sm text-[#085041] flex items-center gap-3">
                  <Badge variant={relatorio.tipoFicheiro === 'EMITIDAS' ? 'teal' : 'blue'}>
                    {relatorio.tipoFicheiro === 'EMITIDAS' ? 'Emitidas' : 'Recebidas'}
                  </Badge>
                  <span>Periodo: <strong>{relatorio.periodo}</strong></span>
                </div>
                <div className="grid grid-cols-3 gap-3">
                  <KpiCard label="Novas" value={String(relatorio.novas)} color="green" />
                  <KpiCard label="Duplicadas" value={String(relatorio.duplicadas)} color="amber" />
                  <KpiCard label="Pendentes" value={String(relatorio.pendentes)} color="red" />
                </div>
              </>
            )}
          </div>
        )}
      </div>

      {/* Right column: history */}
      <Card>
        <h3 className="text-[13px] font-medium mb-3" style={{ color: '#0D1B1A' }}>Historico de importacoes</h3>

        {history.length === 0 ? (
          <p className="text-sm text-gray-400">Nenhuma importacao nesta sessao.</p>
        ) : (
          <Table>
            <thead>
              <tr>
                <Th>Ficheiro</Th>
                <Th>Tipo</Th>
                <Th>Periodo</Th>
                <Th className="text-right">Total</Th>
                <Th className="text-right">Novas</Th>
              </tr>
            </thead>
            <tbody>
              {history.map((h) => (
                <tr key={h.id}>
                  <Td className="font-medium text-[12px]">{h.filename}</Td>
                  <Td>
                    <Badge variant={h.tipoFicheiro === 'EMITIDAS' ? 'teal' : 'blue'}>
                      {h.tipoFicheiro === 'EMITIDAS' ? 'Emitidas' : 'Recebidas'}
                    </Badge>
                  </Td>
                  <Td>{h.periodo}</Td>
                  <Td className="text-right">{h.totalFaturas}</Td>
                  <Td className="text-right">{h.novas}</Td>
                </tr>
              ))}
            </tbody>
          </Table>
        )}
      </Card>
    </div>
  )
}
