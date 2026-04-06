-- CreateEnum
CREATE TYPE "EstadoFracao" AS ENUM ('OCUPADO', 'VAGO', 'EM_OBRAS');

-- AlterTable
ALTER TABLE "fatura_classificacao" ADD COLUMN     "fracaoId" TEXT;

-- AlterTable
ALTER TABLE "lancamentos_manuais" ADD COLUMN     "fracaoId" TEXT;

-- AlterTable
ALTER TABLE "nif_imovel_map" ADD COLUMN     "fracaoId" TEXT;

-- CreateTable
CREATE TABLE "fracoes" (
    "id" TEXT NOT NULL,
    "imovelId" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "renda" DECIMAL(12,2) NOT NULL,
    "nifInquilino" TEXT,
    "estado" "EstadoFracao" NOT NULL DEFAULT 'VAGO',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fracoes_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "fracoes" ADD CONSTRAINT "fracoes_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES "imoveis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nif_imovel_map" ADD CONSTRAINT "nif_imovel_map_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES "fracoes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fatura_classificacao" ADD CONSTRAINT "fatura_classificacao_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES "fracoes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lancamentos_manuais" ADD CONSTRAINT "lancamentos_manuais_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES "fracoes"("id") ON DELETE SET NULL ON UPDATE CASCADE;
