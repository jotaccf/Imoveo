-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'GESTOR', 'OPERADOR');

-- CreateEnum
CREATE TYPE "TipoImovel" AS ENUM ('APARTAMENTO', 'MORADIA', 'LOJA', 'ESCRITORIO', 'OUTRO');

-- CreateEnum
CREATE TYPE "EstadoImovel" AS ENUM ('ACTIVO', 'VAGO', 'EM_OBRAS', 'INACTIVO');

-- CreateEnum
CREATE TYPE "TipoEntidade" AS ENUM ('FORNECEDOR', 'INQUILINO', 'PROPRIETARIO', 'OUTRO');

-- CreateEnum
CREATE TYPE "TipoRubrica" AS ENUM ('RECEITA', 'GASTO');

-- CreateEnum
CREATE TYPE "TipoFicheiro" AS ENUM ('EMITIDAS', 'RECEBIDAS');

-- CreateEnum
CREATE TYPE "OrigemClassificacao" AS ENUM ('AUTOMATICA', 'MANUAL');

-- CreateEnum
CREATE TYPE "TipoDocManual" AS ENUM ('RECIBO_VERDE', 'CONTRATO_RENDA', 'FATURA_PAPEL', 'OUTRO');

-- CreateEnum
CREATE TYPE "Periodicidade" AS ENUM ('MENSAL', 'TRIMESTRAL', 'ANUAL');

-- CreateTable
CREATE TABLE "utilizadores" (
    "id" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'OPERADOR',
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,
    "ultimoLogin" TIMESTAMP(3),

    CONSTRAINT "utilizadores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "imoveis" (
    "id" TEXT NOT NULL,
    "codigo" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "tipo" "TipoImovel" NOT NULL,
    "morada" TEXT,
    "localizacao" TEXT NOT NULL,
    "nifProprietario" TEXT,
    "estado" "EstadoImovel" NOT NULL DEFAULT 'ACTIVO',
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "imoveis_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "entidades" (
    "id" TEXT NOT NULL,
    "nif" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "tipo" "TipoEntidade" NOT NULL DEFAULT 'FORNECEDOR',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "entidades_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nif_imovel_map" (
    "id" TEXT NOT NULL,
    "nifEntidade" TEXT NOT NULL,
    "imovelId" TEXT NOT NULL,
    "rubricaId" TEXT NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "nif_imovel_map_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rubricas" (
    "id" TEXT NOT NULL,
    "codigo" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "tipo" "TipoRubrica" NOT NULL DEFAULT 'GASTO',
    "ordem" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "rubricas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "importacoes" (
    "id" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "hashFicheiro" TEXT NOT NULL,
    "periodo" TEXT NOT NULL,
    "tipoFicheiro" "TipoFicheiro" NOT NULL,
    "totalFaturas" INTEGER NOT NULL DEFAULT 0,
    "novas" INTEGER NOT NULL DEFAULT 0,
    "duplicadas" INTEGER NOT NULL DEFAULT 0,
    "pendentes" INTEGER NOT NULL DEFAULT 0,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "importacoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "faturas" (
    "id" TEXT NOT NULL,
    "hashFatura" TEXT NOT NULL,
    "nifEmitente" TEXT NOT NULL,
    "serieDoc" TEXT NOT NULL,
    "numeroDoc" TEXT NOT NULL,
    "nifDestinatario" TEXT,
    "nomeEmitente" TEXT,
    "dataFatura" TIMESTAMP(3) NOT NULL,
    "totalSemIva" DECIMAL(12,2) NOT NULL,
    "totalIva" DECIMAL(12,2) NOT NULL,
    "totalComIva" DECIMAL(12,2) NOT NULL,
    "tipoDocumento" TEXT,
    "importacaoId" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "faturas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fatura_classificacao" (
    "id" TEXT NOT NULL,
    "faturaId" TEXT NOT NULL,
    "imovelId" TEXT NOT NULL,
    "rubricaId" TEXT NOT NULL,
    "origem" "OrigemClassificacao" NOT NULL DEFAULT 'AUTOMATICA',
    "confirmado" BOOLEAN NOT NULL DEFAULT false,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fatura_classificacao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lancamentos_manuais" (
    "id" TEXT NOT NULL,
    "tipoDoc" "TipoDocManual" NOT NULL DEFAULT 'RECIBO_VERDE',
    "numeroDoc" TEXT,
    "fornecedor" TEXT NOT NULL,
    "nifFornecedor" TEXT,
    "imovelId" TEXT NOT NULL,
    "rubricaId" TEXT NOT NULL,
    "dataDoc" TIMESTAMP(3) NOT NULL,
    "valorSemIva" DECIMAL(12,2) NOT NULL,
    "taxaIva" INTEGER NOT NULL DEFAULT 0,
    "totalComIva" DECIMAL(12,2) NOT NULL,
    "recorrente" BOOLEAN NOT NULL DEFAULT false,
    "periodicidade" "Periodicidade",
    "dataFim" TIMESTAMP(3),
    "notas" TEXT,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "lancamentos_manuais_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "utilizadores_email_key" ON "utilizadores"("email");

-- CreateIndex
CREATE UNIQUE INDEX "imoveis_codigo_key" ON "imoveis"("codigo");

-- CreateIndex
CREATE UNIQUE INDEX "entidades_nif_key" ON "entidades"("nif");

-- CreateIndex
CREATE INDEX "nif_imovel_map_nifEntidade_idx" ON "nif_imovel_map"("nifEntidade");

-- CreateIndex
CREATE UNIQUE INDEX "nif_imovel_map_nifEntidade_imovelId_key" ON "nif_imovel_map"("nifEntidade", "imovelId");

-- CreateIndex
CREATE UNIQUE INDEX "rubricas_codigo_key" ON "rubricas"("codigo");

-- CreateIndex
CREATE UNIQUE INDEX "importacoes_hashFicheiro_key" ON "importacoes"("hashFicheiro");

-- CreateIndex
CREATE UNIQUE INDEX "faturas_hashFatura_key" ON "faturas"("hashFatura");

-- CreateIndex
CREATE INDEX "faturas_nifEmitente_idx" ON "faturas"("nifEmitente");

-- CreateIndex
CREATE INDEX "faturas_dataFatura_idx" ON "faturas"("dataFatura");

-- CreateIndex
CREATE INDEX "faturas_nifDestinatario_idx" ON "faturas"("nifDestinatario");

-- CreateIndex
CREATE UNIQUE INDEX "faturas_nifEmitente_serieDoc_numeroDoc_key" ON "faturas"("nifEmitente", "serieDoc", "numeroDoc");

-- CreateIndex
CREATE UNIQUE INDEX "fatura_classificacao_faturaId_key" ON "fatura_classificacao"("faturaId");

-- CreateIndex
CREATE INDEX "lancamentos_manuais_imovelId_idx" ON "lancamentos_manuais"("imovelId");

-- CreateIndex
CREATE INDEX "lancamentos_manuais_dataDoc_idx" ON "lancamentos_manuais"("dataDoc");

-- AddForeignKey
ALTER TABLE "nif_imovel_map" ADD CONSTRAINT "nif_imovel_map_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES "imoveis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nif_imovel_map" ADD CONSTRAINT "nif_imovel_map_rubricaId_fkey" FOREIGN KEY ("rubricaId") REFERENCES "rubricas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nif_imovel_map" ADD CONSTRAINT "nif_imovel_map_nifEntidade_fkey" FOREIGN KEY ("nifEntidade") REFERENCES "entidades"("nif") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "faturas" ADD CONSTRAINT "faturas_importacaoId_fkey" FOREIGN KEY ("importacaoId") REFERENCES "importacoes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fatura_classificacao" ADD CONSTRAINT "fatura_classificacao_faturaId_fkey" FOREIGN KEY ("faturaId") REFERENCES "faturas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fatura_classificacao" ADD CONSTRAINT "fatura_classificacao_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES "imoveis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fatura_classificacao" ADD CONSTRAINT "fatura_classificacao_rubricaId_fkey" FOREIGN KEY ("rubricaId") REFERENCES "rubricas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lancamentos_manuais" ADD CONSTRAINT "lancamentos_manuais_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES "imoveis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lancamentos_manuais" ADD CONSTRAINT "lancamentos_manuais_rubricaId_fkey" FOREIGN KEY ("rubricaId") REFERENCES "rubricas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
