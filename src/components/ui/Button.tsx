'use client'
import { cn } from '@/lib/utils'
import { ButtonHTMLAttributes, forwardRef } from 'react'

const variants = {
  primary: 'bg-[#1D9E75] text-white hover:bg-[#0F6E56]',
  secondary: 'border border-[#1D9E75] text-[#1D9E75] hover:bg-[#E1F5EE]',
  ghost: 'hover:bg-gray-100',
  danger: 'text-[#A32D2D] hover:bg-[#FCEBEB]',
}

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: keyof typeof variants
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', ...props }, ref) => (
    <button ref={ref} className={cn('px-4 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-50', variants[variant], className)} {...props} />
  )
)
Button.displayName = 'Button'
export { Button }
