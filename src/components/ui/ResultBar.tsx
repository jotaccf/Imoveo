interface ResultBarProps {
  receita: number
  gastos: number
}

export function ResultBar({ receita, gastos }: ResultBarProps) {
  const total = receita + gastos
  if (total === 0) return <div className="h-1.5 rounded-full bg-gray-200 w-full" />
  const receitaPct = (receita / total) * 100

  return (
    <div className="flex h-1.5 rounded-full overflow-hidden w-full min-w-[60px]">
      <div style={{ width: `${receitaPct}%`, background: '#1D9E75' }} />
      <div style={{ width: `${100 - receitaPct}%`, background: '#E24B4A' }} />
    </div>
  )
}
