'use client'
import { useCallback, useState } from 'react'
import { Upload, CheckCircle, Loader2 } from 'lucide-react'

interface UploadZoneProps {
  onUpload: (file: File) => Promise<void>
  accept?: string
}

export function UploadZone({ onUpload, accept = '.csv,.xml' }: UploadZoneProps) {
  const [state, setState] = useState<'idle' | 'processing' | 'success'>('idle')
  const [dragOver, setDragOver] = useState(false)

  const handleFile = useCallback(async (file: File) => {
    setState('processing')
    try {
      await onUpload(file)
      setState('success')
      setTimeout(() => setState('idle'), 3000)
    } catch {
      setState('idle')
    }
  }, [onUpload])

  return (
    <div
      className={`border-[1.5px] border-dashed rounded-xl p-8 text-center transition-colors cursor-pointer ${dragOver ? 'border-[#1D9E75] bg-[#E1F5EE]/30' : 'border-gray-300 hover:border-[#1D9E75]'}`}
      onDragOver={(e) => { e.preventDefault(); setDragOver(true) }}
      onDragLeave={() => setDragOver(false)}
      onDrop={(e) => { e.preventDefault(); setDragOver(false); if (e.dataTransfer.files[0]) handleFile(e.dataTransfer.files[0]) }}
      onClick={() => {
        const input = document.createElement('input')
        input.type = 'file'
        input.accept = accept
        input.onchange = (e) => { const f = (e.target as HTMLInputElement).files?.[0]; if (f) handleFile(f) }
        input.click()
      }}
    >
      {state === 'idle' && <>
        <Upload className="mx-auto mb-2 text-gray-400" size={28} />
        <div className="text-sm font-medium text-gray-600">Arrastar ficheiro aqui ou clicar</div>
        <div className="text-[11px] text-gray-400 mt-1">CSV do e-Fatura ou XML SAFT-PT</div>
      </>}
      {state === 'processing' && <>
        <Loader2 className="mx-auto mb-2 text-[#1D9E75] animate-spin" size={28} />
        <div className="text-sm font-medium text-[#1D9E75]">A processar...</div>
      </>}
      {state === 'success' && <>
        <CheckCircle className="mx-auto mb-2 text-[#1D9E75]" size={28} />
        <div className="text-sm font-medium text-[#1D9E75]">Processado com sucesso</div>
      </>}
    </div>
  )
}
