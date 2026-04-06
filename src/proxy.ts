import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { getToken } from 'next-auth/jwt'

const routePermissions: Record<string, string[]> = {
  '/imoveis': ['ADMIN', 'GESTOR'],
  '/importar': ['ADMIN', 'GESTOR', 'OPERADOR'],
  '/lancamentos': ['ADMIN', 'GESTOR', 'OPERADOR'],
  '/pendentes': ['ADMIN', 'GESTOR', 'OPERADOR'],
  '/faturas': ['ADMIN', 'GESTOR'],
  '/resultados': ['ADMIN', 'GESTOR'],
  '/mapeamento': ['ADMIN', 'GESTOR'],
  '/analise': ['ADMIN', 'GESTOR'],
  '/custos': ['ADMIN', 'GESTOR'],
  '/irc': ['ADMIN', 'GESTOR'],
  '/calculadora': ['ADMIN', 'GESTOR'],
  '/configuracoes': ['ADMIN'],
  '/utilizadores': ['ADMIN'],
}

export async function proxy(req: NextRequest) {
  const { pathname } = req.nextUrl

  if (
    pathname.startsWith('/login') ||
    pathname.startsWith('/api/auth') ||
    pathname.startsWith('/_next') ||
    pathname === '/favicon.ico'
  ) {
    return NextResponse.next()
  }

  const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET })

  if (!token) {
    return NextResponse.redirect(new URL('/login', req.url))
  }

  const role = token.role as string
  for (const [route, roles] of Object.entries(routePermissions)) {
    if (pathname.startsWith(route)) {
      if (!roles.includes(role)) {
        return NextResponse.redirect(new URL('/sem-acesso', req.url))
      }
      break
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
