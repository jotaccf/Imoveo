-- AlterTable
ALTER TABLE "lancamentos_manuais" ADD COLUMN     "retencaoFonte" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "valorRetencao" DECIMAL(12,2);
