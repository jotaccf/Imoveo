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
      if (user) {
        token.id = user.id!
        token.nome = (user as { nome: string }).nome
        token.role = (user as { role: Role }).role
      }
      return token
    },
    async session({ session, token }) {
      session.user.id = token.id
      session.user.nome = token.nome
      session.user.role = token.role
      return session
    },
  },
})
