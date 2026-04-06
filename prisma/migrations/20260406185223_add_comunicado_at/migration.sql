-- AlterTable
ALTER TABLE "contratos" ADD COLUMN     "comunicadoAT" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "dataComunicacaoAT" TIMESTAMP(3);
