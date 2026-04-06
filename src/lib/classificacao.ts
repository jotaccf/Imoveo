import { prisma } from '@/lib/prisma'

export async function classificarFatura(
  faturaId: string,
  nifEntidade: string,
  isReceita: boolean = false,
): Promise<boolean> {
  const mapping = await prisma.nifImovelMap.findFirst({
    where: { nifEntidade, ativo: true },
  })

  if (!mapping) return false

  let rubricaId = mapping.rubricaId

  // Para receitas (emitidas), forçar rubrica "Receita" (REC)
  if (isReceita) {
    const rubricaRec = await prisma.rubrica.findUnique({ where: { codigo: 'REC' } })
    if (rubricaRec) rubricaId = rubricaRec.id
  }

  await prisma.faturaClassificacao.create({
    data: {
      faturaId,
      imovelId: mapping.imovelId,
      rubricaId,
      fracaoId: mapping.fracaoId || null,
      origem: 'AUTOMATICA',
      confirmado: true,
    },
  })

  return true
}
