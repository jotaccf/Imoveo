import Link from 'next/link'

export default function SemAcessoPage() {
  return (
    <div className="min-h-screen flex items-center justify-center" style={{ background: '#F4FAF8' }}>
      <div className="text-center">
        <div className="text-5xl font-bold mb-4" style={{ color: '#A32D2D' }}>403</div>
        <h1 className="text-lg font-medium mb-2" style={{ color: '#0D1B1A' }}>Acesso negado</h1>
        <p className="text-sm mb-6" style={{ color: '#6B7280' }}>
          Nao tens permissao para aceder a esta pagina.
        </p>
        <Link
          href="/dashboard"
          className="inline-block px-4 py-2 rounded-lg text-white text-sm font-medium"
          style={{ background: '#1D9E75' }}
        >
          Voltar ao Dashboard
        </Link>
      </div>
    </div>
  )
}
