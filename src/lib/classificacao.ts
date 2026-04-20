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

  if (template && template.linhas.length > 0) {
    const fatura = await prisma.fatura.findUnique({ where: { id: faturaId } })
    if (!fatura) return false
    const total = Number(fatura.totalComIva)

    let rubricaId = template.rubricaId
    if (isReceita) {
      const rubricaRec = await prisma.rubrica.findUnique({ where: { codigo: 'REC' } })
      if (rubricaRec) rubricaId = rubricaRec.id
    }

    const linhas = template.linhas
    for (let i = 0; i < linhas.length; i++) {
      const linha = linhas[i]
      let pct: number
      if (template.tipo === 'IGUAL') {
        pct = 100 / linhas.length
      } else {
        pct = Number(linha.percentagem || 0)
      }

      // Ultima linha absorve arredondamento
      let valor: number
      if (i === linhas.length - 1) {
        const somaAnterior = linhas.slice(0, i).reduce((sum, l, j) => {
          const p = template.tipo === 'IGUAL' ? 100 / linhas.length : Number(l.percentagem || 0)
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
          confirmado: false, // utilizador deve confirmar splits
          valorAtribuido: valor,
          percentagem: pct,
        },
      })
    }
    return 'TEMPLATE'
  }

  // 2. Regra completa (NIF + Imovel especifico)
  const mapping = await prisma.nifImovelMap.findFirst({
    where: { nifEntidade, imovelId: { not: null }, ativo: true },
  })

  if (mapping && mapping.imovelId) {
    let rubricaId = mapping.rubricaId
    if (isReceita) {
      const rubricaRec = await prisma.rubrica.findUnique({ where: { codigo: 'REC' } })
      if (rubricaRec) rubricaId = rubricaRec.id
    }

    await prisma.faturaClassificacao.create({
      data: {
        faturaId,
        imovelId: mapping.imovelId,
        rubricaId,
        fracaoId: mapping.fracaoId,
        origem: 'AUTOMATICA',
        confirmado: true,
      },
    })
    return 'FULL'
  }

  // 3. Regra so rubrica (NIF sem imovel)
  const rubricaOnly = await prisma.nifImovelMap.findFirst({
    where: { nifEntidade, imovelId: null, ativo: true },
  })

  if (rubricaOnly) {
    await prisma.fatura.update({
      where: { id: faturaId },
      data: { rubricaSugeridaId: rubricaOnly.rubricaId },
    })
    return 'PARTIAL'
  }

  return false
}
