-- CreateEnum
CREATE TYPE "TipoPropriedade" AS ENUM ('ARRENDADO', 'ADQUIRIDO');

-- CreateEnum
CREATE TYPE "TipoActivoFixo" AS ENUM ('VIATURA_LIGEIRA', 'VIATURA_PESADA', 'EQUIPAMENTO', 'OUTRO');

-- CreateEnum
CREATE TYPE "TipoCombustivel" AS ENUM ('COMBUSTAO', 'HIBRIDO_PLUG_IN', 'GPL_GNV', 'ELECTRICO');

-- AlterTable Imovel
ALTER TABLE "imoveis"
  ADD COLUMN "tipoPropriedade" "TipoPropriedade" NOT NULL DEFAULT 'ARRENDADO',
  ADD COLUMN "valorAquisicao" DECIMAL(12,2),
  ADD COLUMN "dataAquisicao" TIMESTAMP(3),
  ADD COLUMN "taxaDepreciacaoAnual" DECIMAL(5,2) DEFAULT 2.00;

-- AlterTable ConfiguracaoFiscal — Tributacao autonoma + limites
ALTER TABLE "configuracoes_fiscais"
  ADD COLUMN "taTaxaComBaixa" DECIMAL(5,2) NOT NULL DEFAULT 10,
  ADD COLUMN "taTaxaComMedia" DECIMAL(5,2) NOT NULL DEFAULT 27.5,
  ADD COLUMN "taTaxaComAlta" DECIMAL(5,2) NOT NULL DEFAULT 35,
  ADD COLUMN "taTaxaHibBaixa" DECIMAL(5,2) NOT NULL DEFAULT 5,
  ADD COLUMN "taTaxaHibMedia" DECIMAL(5,2) NOT NULL DEFAULT 10,
  ADD COLUMN "taTaxaHibAlta" DECIMAL(5,2) NOT NULL DEFAULT 17.5,
  ADD COLUMN "taTaxaGplBaixa" DECIMAL(5,2) NOT NULL DEFAULT 7.5,
  ADD COLUMN "taTaxaGplMedia" DECIMAL(5,2) NOT NULL DEFAULT 15,
  ADD COLUMN "taTaxaGplAlta" DECIMAL(5,2) NOT NULL DEFAULT 27.5,
  ADD COLUMN "taTaxaElectrica" DECIMAL(5,2) NOT NULL DEFAULT 10,
  ADD COLUMN "taLimiteElectricoIsento" DECIMAL(12,2) NOT NULL DEFAULT 62500,
  ADD COLUMN "taLimiteViaturaBaixa" DECIMAL(12,2) NOT NULL DEFAULT 27500,
  ADD COLUMN "taLimiteViaturaAlta" DECIMAL(12,2) NOT NULL DEFAULT 35000,
  ADD COLUMN "limiteDeducaoCombustao" DECIMAL(12,2) NOT NULL DEFAULT 30000,
  ADD COLUMN "limiteDeducaoGpl" DECIMAL(12,2) NOT NULL DEFAULT 37500,
  ADD COLUMN "limiteDeducaoHibrido" DECIMAL(12,2) NOT NULL DEFAULT 50000,
  ADD COLUMN "limiteDeducaoElectrico" DECIMAL(12,2) NOT NULL DEFAULT 62500,
  ADD COLUMN "taTaxaRepresentacao" DECIMAL(5,2) NOT NULL DEFAULT 10,
  ADD COLUMN "taTaxaNaoDocumentadas" DECIMAL(5,2) NOT NULL DEFAULT 50,
  ADD COLUMN "taAgravamentoPrejuizoPp" DECIMAL(5,2) NOT NULL DEFAULT 10;

-- CreateTable ActivoFixo
CREATE TABLE "activos_fixos" (
    "id" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "tipo" "TipoActivoFixo" NOT NULL,
    "combustivel" "TipoCombustivel",
    "matricula" TEXT,
    "valorAquisicao" DECIMAL(12,2) NOT NULL,
    "dataAquisicao" TIMESTAMP(3) NOT NULL,
    "taxaDepreciacaoAnual" DECIMAL(5,2) NOT NULL DEFAULT 25,
    "alienadoEm" TIMESTAMP(3),
    "valorAlienacao" DECIMAL(12,2),
    "notas" TEXT,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "activos_fixos_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "activos_fixos_tipo_idx" ON "activos_fixos"("tipo");

-- CreateTable PagamentoConta
CREATE TABLE "pagamentos_conta" (
    "id" TEXT NOT NULL,
    "ano" INTEGER NOT NULL,
    "prestacao" INTEGER NOT NULL,
    "valor" DECIMAL(12,2) NOT NULL,
    "dataPagamento" TIMESTAMP(3) NOT NULL,
    "notas" TEXT,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pagamentos_conta_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "pagamentos_conta_ano_prestacao_key" ON "pagamentos_conta"("ano", "prestacao");
CREATE INDEX "pagamentos_conta_ano_idx" ON "pagamentos_conta"("ano");
