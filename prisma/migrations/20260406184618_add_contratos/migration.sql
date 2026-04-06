-- CreateEnum
CREATE TYPE "EstadoContrato" AS ENUM ('ATIVO', 'EXPIRADO', 'TERMINADO');

-- CreateTable
CREATE TABLE "contratos" (
    "id" TEXT NOT NULL,
    "fracaoId" TEXT NOT NULL,
    "imovelId" TEXT NOT NULL,
    "nomeInquilino" TEXT NOT NULL,
    "nifInquilino" TEXT,
    "contacto" TEXT,
    "valorRenda" DECIMAL(12,2) NOT NULL,
    "dataInicio" TIMESTAMP(3) NOT NULL,
    "dataFim" TIMESTAMP(3),
    "renovacaoAuto" BOOLEAN NOT NULL DEFAULT true,
    "periodoRenovacao" INTEGER NOT NULL DEFAULT 12,
    "caucao" DECIMAL(12,2),
    "notas" TEXT,
    "estado" "EstadoContrato" NOT NULL DEFAULT 'ATIVO',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "contratos_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "contratos_fracaoId_idx" ON "contratos"("fracaoId");

-- CreateIndex
CREATE INDEX "contratos_imovelId_idx" ON "contratos"("imovelId");

-- CreateIndex
CREATE INDEX "contratos_dataFim_idx" ON "contratos"("dataFim");

-- AddForeignKey
ALTER TABLE "contratos" ADD CONSTRAINT "contratos_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES "fracoes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contratos" ADD CONSTRAINT "contratos_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES "imoveis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
