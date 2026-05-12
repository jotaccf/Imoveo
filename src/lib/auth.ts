import NextAuth from 'next-auth'
import Credentials from 'next-auth/providers/credentials'
import { compare } from 'bcryptjs'
import { prisma } from '@/lib/prisma'
import type { Role } from '@/lib/permissions'

declare module 'next-auth' {
  interface Session {
    user: {
      id: string
      nome: string
      email: string
      role: Role
    }
  }
  interface User {
    id: string
    nome: string
    email: string
    role: Role
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    id: string
    nome: string
    role: Role
  }
}

export const { handlers, auth, signIn, signOut } = NextAuth({
  pages: {
    signIn: '/login',
  },
  session: {
    strategy: 'jwt',
    maxAge: 8 * 60 * 60, // 8 horas — forca relogin diario em vez de 30 dias default
  },
  providers: [
    Credentials({
      name: 'credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null

        const user = await prisma.utilizador.findUnique({
          where: { email: credentials.email as string },
        })

        if (!user || !user.ativo) return null

        const isValid = await compare(credentials.password as string, user.passwordHash)
        if (!isValid) return null

        await prisma.utilizador.update({
          where: { id: user.id },
          data: { ultimoLogin: new Date() },
        })

        return {
          id: user.id,
          nome: user.nome,
          email: user.email,
          role: user.role as Role,
        }
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      // Login fresco: popular token a partir do user.
      if (user) {
        token.id = user.id!
        token.nome = (user as { nome: string }).nome
        token.role = (user as { role: Role }).role
        return token
      }
      // Token sem id e' invalido. nome/role podem estar vazios — o
      // self-healing preenche de seguida a partir da BD.
      if (!token.id) {
        return null
      }
      // Self-healing: revalidar contra BD. Permite detectar role alterado,
      // user desactivado ou apagado. Nome vazio em BD e' permitido.
      const db = await prisma.utilizador.findUnique({
        where: { id: token.id as string },
        select: { id: true, nome: true, role: true, ativo: true },
      })
      if (!db || !db.ativo) return null
      token.nome = db.nome ?? ''
      token.role = db.role as Role
      return token
    },
    async session({ session, token }) {
      if (!token?.id) return session
      session.user.id = token.id
      session.user.nome = token.nome
      session.user.role = token.role
      return session
    },
  },
})
