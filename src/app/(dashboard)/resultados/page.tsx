'use client'

import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/Button'
import { Select } from '@/components/ui/Select'
import { Card } from '@/components/ui/Card'
import { formatCurrency } from '@/lib/utils'
import type { ResultadosResponse, ResultadoImovel } from '@/types'

export default function ResultadosPage() {
  const [data, setData] = useState<ResultadosResponse | null>(null)
  const [ano, setAno] = useState(String(new Date().getFullYear()))
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true)
    fetch(`/api/resultados?ano=${ano}`)
      .then((r) => r.json())
      .then((j) => { if (j.data) setData(j.data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [ano])

  function handleExportCSV() {
    window.open(`/api/resultados/exportar?ano=${ano}`, '_blank')
  }

  const yearOptions = Array.from({ length: 5 }, (_, i) => {
    const y = new Date().getFullYear() - i
    return { value: String(y), label: String(y) }
  })

  if (loading) return <div className="text-sm text-gray-400">A carregar...</div>
  if (!data) return <div className="text-sm text-gray-400">Sem dados</div>

  const receitaLinhas = data.linhas.filter((l) => l.rubricaTipo === 'RECEITA')
  const gastoLinhas = data.linhas.filter((l) => l.rubricaTipo === 'GASTO')

  return (
    <div className="space-y-4">
      {/* Controls */}
      <div className="flex items-center gap-3">
        <div className="w-32">
          <Select options={yearOptions} value={ano} onChange={(e) => setAno(e.target.value)} />
        </div>
        <Button variant="secondary" onClick={handleExportCSV}>Exportar CSV</Button>
      </div>

      {/* Pivot table */}
      <Card className="p-0 overflow-x-auto">
        <table className="w-full text-left text-[13px]">
          <thead>
            <tr>
              <th className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100 sticky left-0 bg-white min-w-[180px]">
                Rubrica
              </th>
              {data.imoveis.map((im) => (
                <th key={im.id} className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100 text-right min-w-[110px]">
                  {im.codigo}
                </th>
              ))}
              <th className="px-3 py-2 text-[11px] font-medium text-[#6B7280] border-b border-gray-100 text-right min-w-[110px]">
                TOTAL
              </th>
            </tr>
          </thead>
          <tbody>
            {/* Receita rows */}
            {receitaLinhas.map((linha) => (
              <tr key={linha.rubricaId} style={{ backgroundColor: '#E1F5EE' }}>
                <td className="px-3 py-2 font-medium sticky left-0" style={{ color: '#085041', backgroundColor: '#E1F5EE' }}>
                  {linha.rubricaNome}
                </td>
                {data.imoveis.map((im) => (
                  <td key={im.id} className="px-3 py-2 text-right" style={{ color: '#085041' }}>
                    {formatCurrency(linha.valores[im.id] || 0)}
                  </td>
                ))}
                <td className="px-3 py-2 text-right font-medium" style={{ color: '#085041' }}>
                  {formatCurrency(linha.total)}
                </td>
              </tr>
            ))}

            {/* Total receita */}
            <tr style={{ backgroundColor: '#E1F5EE' }}>
              <td className="px-3 py-2 font-semibold sticky left-0 border-t border-[#085041]/10" style={{ color: '#085041', backgroundColor: '#E1F5EE' }}>
                Total receita
              </td>
              {data.imoveis.map((im) => (
                <td key={im.id} className="px-3 py-2 text-right font-semibold border-t border-[#085041]/10" style={{ color: '#085041' }}>
                  {formatCurrency(data.totaisReceita[im.id] || 0)}
                </td>
              ))}
              <td className="px-3 py-2 text-right font-semibold border-t border-[#085041]/10" style={{ color: '#085041' }}>
                {formatCurrency(data.receitaGeral)}
              </td>
            </tr>

            {/* Spacer */}
            <tr><td colSpan={data.imoveis.length + 2} className="h-2" /></tr>

            {/* Gasto rows */}
            {gastoLinhas.map((linha, idx) => (
              <tr key={linha.rubricaId} style={{ backgroundColor: idx % 2 === 0 ? '#ffffff' : '#F9FAFB' }}>
                <td className="px-3 py-2 font-medium sticky left-0" style={{ color: '#0D1B1A', backgroundColor: idx % 2 === 0 ? '#ffffff' : '#F9FAFB' }}>
                  {linha.rubricaNome}
                </td>
                {data.imoveis.map((im) => (
                  <td key={im.id} className="px-3 py-2 text-right" style={{ color: '#A32D2D' }}>
                    {formatCurrency(linha.valores[im.id] || 0)}
                  </td>
                ))}
                <td className="px-3 py-2 text-right font-medium" style={{ color: '#A32D2D' }}>
                  {formatCurrency(linha.total)}
                </td>
              </tr>
            ))}

            {/* Total gastos */}
            <tr style={{ backgroundColor: '#FEF2F2' }}>
              <td className="px-3 py-2 font-semibold sticky left-0" style={{ color: '#A32D2D', backgroundColor: '#FEF2F2' }}>
                Total gastos
              </td>
              {data.imoveis.map((im) => (
                <td key={im.id} className="px-3 py-2 text-right font-semibold" style={{ color: '#A32D2D' }}>
                  {formatCurrency(data.totaisGastos[im.id] || 0)}
                </td>
              ))}
              <td className="px-3 py-2 text-right font-semibold" style={{ color: '#A32D2D' }}>
                {formatCurrency(data.totalGeral)}
              </td>
            </tr>

            {/* Resultado liquido */}
            <tr style={{ borderTop: '2px solid #0D1B1A' }}>
              <td className="px-3 py-2.5 font-bold sticky left-0 bg-white border-t-2 border-[#0D1B1A]" style={{ color: '#0D1B1A' }}>
                Resultado liquido
              </td>
              {data.imoveis.map((im) => {
                const val = data.resultadoLiquido[im.id] || 0
                return (
                  <td key={im.id} className="px-3 py-2.5 text-right font-bold border-t-2 border-[#0D1B1A]" style={{ color: val >= 0 ? '#0F6E56' : '#A32D2D' }}>
                    {formatCurrency(val)}
                  </td>
                )
              })}
              <td className="px-3 py-2.5 text-right font-bold border-t-2 border-[#0D1B1A]" style={{ color: data.resultadoGeral >= 0 ? '#0F6E56' : '#A32D2D' }}>
                {formatCurrency(data.resultadoGeral)}
              </td>
            </tr>

            {/* Margem */}
            <tr>
              <td className="px-3 py-1.5 sticky left-0 bg-white" style={{ color: '#9CA3AF', fontSize: 11 }}>
                Margem
              </td>
              {data.imoveis.map((im) => (
                <td key={im.id} className="px-3 py-1.5 text-right" style={{ color: '#9CA3AF', fontSize: 11 }}>
                  {(data.margens[im.id] || 0).toFixed(1)}%
                </td>
              ))}
              <td className="px-3 py-1.5 text-right" style={{ color: '#9CA3AF', fontSize: 11 }}>
                {data.receitaGeral > 0 ? ((data.resultadoGeral / data.receitaGeral) * 100).toFixed(1) : '0.0'}%
              </td>
            </tr>
          </tbody>
        </table>
      </Card>
    </div>
  )
}
