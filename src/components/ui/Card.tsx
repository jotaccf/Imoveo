import { cn } from '@/lib/utils'

export function Card({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={cn('bg-white rounded-lg border border-gray-100 p-5', className)} {...props}>
      {children}
    </div>
  )
}
