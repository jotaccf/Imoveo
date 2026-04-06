interface KpiCardProps {
  label: string
  value: string
  sub?: string
  color?: 'green' | 'red' | 'amber' | 'default'
}

const colorMap = {
  green: '#0F6E56',
  red: '#A32D2D',
  amber: '#633806',
  default: '#0D1B1A',
}

export function KpiCard({ label, value, sub, color = 'default' }: KpiCardProps) {
  return (
    <div className="rounded-lg p-3.5" style={{ background: '#F3F4F6' }}>
      <div className="text-[11px] font-medium mb-1" style={{ color: '#6B7280' }}>{label}</div>
      <div className="text-xl font-medium" style={{ color: colorMap[color] }}>{value}</div>
      {sub && <div className="text-[11px] mt-0.5" style={{ color: '#9CA3AF' }}>{sub}</div>}
    </div>
  )
}
