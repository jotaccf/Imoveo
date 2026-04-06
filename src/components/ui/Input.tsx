import { cn } from '@/lib/utils'
import { forwardRef, InputHTMLAttributes } from 'react'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
}

const Input = forwardRef<HTMLInputElement, InputProps>(({ className, label, ...props }, ref) => (
  <div>
    {label && <label className="block text-[11px] font-medium text-[#6B7280] mb-1">{label}</label>}
    <input ref={ref} className={cn('w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-[#1D9E75] transition-colors', className)} {...props} />
  </div>
))
Input.displayName = 'Input'
export { Input }
