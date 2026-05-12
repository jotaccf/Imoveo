-- AlterTable Rubrica — flag de dedutibilidade fiscal
ALTER TABLE "rubricas" ADD COLUMN "dedutivel" BOOLEAN NOT NULL DEFAULT true;

-- Marcar rubricas tipicamente nao dedutiveis (matched by codigo if existe)
UPDATE "rubricas" SET "dedutivel" = false
WHERE "codigo" IN ('MUL', 'MULTAS', 'IRC', 'DON', 'DONATIVOS', 'OFE', 'OFERTAS', 'PEN', 'PENALIZACOES');
