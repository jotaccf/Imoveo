-- CreateEnum
CREATE TYPE "TipoDistribuicao" AS ENUM ('IGUAL', 'PERCENTAGEM', 'MANUAL');

-- DropForeignKey
ALTER TABLE "nif_imovel_map" DROP CONSTRAINT "nif_imovel_map_imovelId_fkey";

-- DropIndex
DROP INDEX "fatura_classificacao_faturaId_key";

-- AlterTable
ALTER TABLE "fatura_classificacao" ADD COLUMN     "percentagem" DECIMAL(5,2),
ADD COLUMN     "valorAtribuido" DECIMAL(12,2);

-- AlterTable
ALTER TABLE "faturas" ADD COLUMN     "rubricaSugeridaId" TEXT;

-- AlterTable
ALTER TABLE "nif_imovel_map" ALTER COLUMN "imovelId" DROP NOT NULL;

-- CreateTable
CREATE TABLE "distribuicao_templates" (
    "id" TEXT NOT NULL,
    "nifEntidade" TEXT NOT NULL,
    "rubricaId" TEXT NOT NULL,
    "tipo" "TipoDistribuicao" NOT NULL DEFAULT 'IGUAL',
    "nome" TEXT,
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "distribuicao_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "distribuicao_linhas" (
    "id" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "imovelId" TEXT NOT NULL,
    "fracaoId" TEXT,
    "percentagem" DECIMAL(5,2),
    "ordem" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "distribuicao_linhas_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "distribuicao_templates_nifEntidade_key" ON "distribuicao_templates"("nifEntidade");

-- CreateIndex
CREATE UNIQUE INDEX "distribuicao_linhas_templateId_imovelId_key" ON "distribuicao_linhas"("templateId", "imovelId");

-- CreateIndex
CREATE INDEX "fatura_classificacao_faturaId_idx" ON "fatura_classificacao"("faturaId");

-- AddForeignKey
ALTER TABLE "nif_imovel_map" ADD CONSTRAINT "nif_imovel_map_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES "imoveis"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "faturas" ADD CONSTRAINT "faturas_rubricaSugeridaId_fkey" FOREIGN KEY ("rubricaSugeridaId") REFERENCES "rubricas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "distribuicao_templates" ADD CONSTRAINT "distribuicao_templates_nifEntidade_fkey" FOREIGN KEY ("nifEntidade") REFERENCES "entidades"("nif") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "distribuicao_templates" ADD CONSTRAINT "distribuicao_templates_rubricaId_fkey" FOREIGN KEY ("rubricaId") REFERENCES "rubricas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "distribuicao_linhas" ADD CONSTRAINT "distribuicao_linhas_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "distribuicao_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "distribuicao_linhas" ADD CONSTRAINT "distribuicao_linhas_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES "imoveis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "distribuicao_linhas" ADD CONSTRAINT "distribuicao_linhas_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES "fracoes"("id") ON DELETE SET NULL ON UPDATE CASCADE;
