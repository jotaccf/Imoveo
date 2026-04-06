import { cn } from '@/lib/utils'

const variants = {
  green: 'bg-[#EAF3DE] text-[#27500A]',
  amber: 'bg-[#FAEEDA] text-[#633806]',
  red: 'bg-[#FCEBEB] text-[#791F1F]',
  teal: 'bg-[#E1F5EE] text-[#085041]',
  blue: 'bg-[#E6F1FB] text-[#0C447C]',
  purple: 'bg-[#EEEDFE] text-[#3C3489]',
  gray: 'bg-[#F3F4F6] text-[#6B7280]',
}

interface BadgeProps {
  variant?: keyof typeof variants
  children: React.ReactNode
  className?: string
}

export function Badge({ variant = 'gray', children, className }: BadgeProps) {
  return (
    <span className={cn('inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium', variants[variant], className)}>
      {children}
    </span>
  )
}
