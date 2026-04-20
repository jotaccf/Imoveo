import { prisma } from '@/lib/prisma'

export type ResultadoClassificacao = 'FULL' | 'TEMPLATE' | 'PARTIAL' | false

/**
 * Auto-classifica uma fatura com base em regras existentes.
 * Prioridade: 1) Template distribuicao  2) Regra completa (NIF+Imovel)  3) Regra so rubrica
 */
export async function classificarFatura(
  faturaId: string,
  nifEntidade: string,
  isReceita: boolean = false,
): Promise<ResultadoClassificacao> {

  // 1. Template de distribuicao (split por imoveis)
  const template = await prisma.distribuicaoTemplate.findUnique({
    where: { nifEntidade, ativo: true },
    include: { linhas: true },
  })

  if (template) {
    let rubricaId = template.rubricaId
    if (isReceita) {
      const rubricaRec = await prisma.rubrica.findUnique({ where: { codigo: 'REC' } })
      if (rubricaRec) rubricaId = rubricaRec.id
    }

    // Sem linhas = so sugerir rubrica (imovel escolhido ao classificar)
    if (template.linhas.length === 0) {
      await prisma.fatura.update({
        where: { id: faturaId },
        data: { rubricaSugeridaId: rubricaId },
      })
      return 'PARTIAL'
    }

    // Com linhas = classificar automaticamente
    const fatura = await prisma.fatura.findUnique({ where: { id: faturaId } })
    if (!fatura) return false
    const total = Number(fatura.totalComIva)
    const linhas = template.linhas
    const n = linhas.length

    for (let i = 0; i < n; i++) {
      const linha = linhas[i]
      const pct = template.tipo === 'PERCENTAGEM'
        ? Number(linha.percentagem || 0)
        : 100 / n

      let valor: number
      if (i === n - 1) {
        const somaAnterior = linhas.slice(0, i).reduce((sum, l, j) => {
          const p = template.tipo === 'PERCENTAGEM' ? Number(linhas[j].percentagem || 0) : 100 / n
          return sum + Math.round(total * p) / 100
        }, 0)
        valor = Math.round((total - somaAnterior) * 100) / 100
      } else {
        valor = Math.round(total * pct) / 100
      }

      await prisma.faturaClassificacao.create({
        data: {
          faturaId,
          imovelId: linha.imovelId,
          rubricaId,
          fracaoId: linha.fracaoId,
          origem: 'AUTOMATICA',
          confirmado: true,
          valorAtribuido: valor,
          percentagem: pct,
        },
      })
    }
    return 'TEMPLATE'
  }

  return false
}
