import { cn } from '@/lib/utils'
import { forwardRef, SelectHTMLAttributes } from 'react'

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label?: string
  options: { value: string; label: string }[]
}

const Select = forwardRef<HTMLSelectElement, SelectProps>(({ className, label, options, ...props }, ref) => (
  <div>
    {label && <label className="block text-[11px] font-medium text-[#6B7280] mb-1">{label}</label>}
    <select ref={ref} className={cn('w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-[#1D9E75] bg-white', className)} {...props}>
      <option value="">Seleccionar...</option>
      {options.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
    </select>
  </div>
))
Select.displayName = 'Select'
export { Select }
