-- AlterTable
ALTER TABLE "contratos" ADD COLUMN     "contratoAssinadoPath" TEXT,
ADD COLUMN     "contratoPdfPath" TEXT;

-- AlterTable
ALTER TABLE "imoveis" ADD COLUMN     "plantaPath" TEXT;
