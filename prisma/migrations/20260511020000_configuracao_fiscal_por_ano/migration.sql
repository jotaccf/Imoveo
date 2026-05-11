-- CreateTable
CREATE TABLE "configuracoes_fiscais" (
    "ano" INTEGER NOT NULL,
    "taxaIrcPme" DECIMAL(5,2) NOT NULL,
    "taxaIrcNormal" DECIMAL(5,2) NOT NULL,
    "limitePme" DECIMAL(12,2) NOT NULL,
    "derramaMunicipal" DECIMAL(5,2) NOT NULL,
    "taxaRetencao" DECIMAL(5,2) NOT NULL,
    "reportePrejuizoPct" DECIMAL(5,2) NOT NULL DEFAULT 65,
    "regimePme" BOOLEAN NOT NULL DEFAULT true,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "configuracoes_fiscais_pkey" PRIMARY KEY ("ano")
);

-- Seed inicial: anos anteriores com taxas antigas
INSERT INTO "configuracoes_fiscais" ("ano", "taxaIrcPme", "taxaIrcNormal", "limitePme", "derramaMunicipal", "taxaRetencao", "reportePrejuizoPct", "regimePme", "atualizadoEm") VALUES
  (2022, 17, 21, 25000, 1.5, 25, 65, true, CURRENT_TIMESTAMP),
  (2023, 17, 21, 50000, 1.5, 25, 65, true, CURRENT_TIMESTAMP),
  (2024, 17, 21, 50000, 1.5, 25, 65, true, CURRENT_TIMESTAMP),
  (2025, 17, 20, 50000, 1.5, 25, 65, true, CURRENT_TIMESTAMP),
  (2026, 15, 19, 50000, 1.5, 25, 65, true, CURRENT_TIMESTAMP),
  (2027, 15, 18, 50000, 1.5, 25, 65, true, CURRENT_TIMESTAMP),
  (2028, 15, 17, 50000, 1.5, 25, 65, true, CURRENT_TIMESTAMP);
