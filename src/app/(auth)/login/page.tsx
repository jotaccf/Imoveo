'use client'

import { useState } from 'react'
import { signIn } from 'next-auth/react'
import { useRouter } from 'next/navigation'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError('')
    setLoading(true)

    const result = await signIn('credentials', {
      email,
      password,
      redirect: false,
    })

    setLoading(false)

    if (result?.error) {
      setError('Email ou password incorrectos')
    } else {
      router.push('/dashboard')
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center" style={{ background: '#F4FAF8' }}>
      <div className="w-full max-w-sm bg-white rounded-xl shadow-sm border border-gray-100 p-8">
        <div className="flex items-center justify-center gap-3 mb-8">
          {/* Imoveo Icon */}
          <svg width="42" height="42" viewBox="0 0 52 52" fill="none">
            <rect width="52" height="52" rx="11.44" fill="#1D9E75" />
            <path d="M14 36V22L26 13L38 22V36" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
            <rect x="21" y="28" width="10" height="8" stroke="white" strokeWidth="2.5" fill="none" />
            <circle cx="38" cy="16" r="5" fill="#0F6E56" stroke="white" strokeWidth="1.5" />
            <line x1="38" y1="13.5" x2="38" y2="18.5" stroke="white" strokeWidth="1.2" />
            <line x1="35.5" y1="16" x2="40.5" y2="16" stroke="white" strokeWidth="1.2" />
          </svg>
          <div>
            <div className="text-lg font-semibold" style={{ color: '#0D1B1A' }}>imoveo</div>
            <div className="text-xs" style={{ color: '#5DCAA5' }}>gestao patrimonial</div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-medium mb-1" style={{ color: '#6B7280' }}>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
              placeholder="email@imoveo.local"
            />
          </div>
          <div>
            <label className="block text-xs font-medium mb-1" style={{ color: '#6B7280' }}>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-brand-primary"
            />
          </div>

          {error && (
            <div className="text-xs text-center py-2 px-3 rounded-lg" style={{ background: '#FCEBEB', color: '#791F1F' }}>
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full py-2.5 rounded-lg text-white text-sm font-medium transition-colors disabled:opacity-50"
            style={{ background: '#1D9E75' }}
            onMouseEnter={(e) => (e.currentTarget.style.background = '#0F6E56')}
            onMouseLeave={(e) => (e.currentTarget.style.background = '#1D9E75')}
          >
            {loading ? 'A entrar...' : 'Entrar'}
          </button>
        </form>
      </div>
    </div>
  )
}
