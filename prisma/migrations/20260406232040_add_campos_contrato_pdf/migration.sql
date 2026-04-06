-- AlterTable
ALTER TABLE "contratos" ADD COLUMN     "dataAssinatura" TIMESTAMP(3),
ADD COLUMN     "estadoCivil" TEXT,
ADD COLUMN     "genero" TEXT,
ADD COLUMN     "localAssinatura" TEXT,
ADD COLUMN     "moradaInquilino" TEXT,
ADD COLUMN     "nacionalidade" TEXT,
ADD COLUMN     "naturalidade" TEXT,
ADD COLUMN     "numDocumento" TEXT,
ADD COLUMN     "tipoDocumento" TEXT,
ADD COLUMN     "usarMoradaImovel" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "validadeDocumento" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "fracoes" ADD COLUMN     "casaBanho" TEXT,
ADD COLUMN     "letraQuarto" TEXT,
ADD COLUMN     "mobilia" TEXT,
ADD COLUMN     "numeroAnexo" TEXT,
ADD COLUMN     "tipoQuarto" TEXT;

-- AlterTable
ALTER TABLE "imoveis" ADD COLUMN     "andar" TEXT,
ADD COLUMN     "artigoMatricial" TEXT,
ADD COLUMN     "ccProprietario1" TEXT,
ADD COLUMN     "ccProprietario2" TEXT,
ADD COLUMN     "concelho" TEXT,
ADD COLUMN     "dataContratoArrendamento" TIMESTAMP(3),
ADD COLUMN     "dataLicenca" TEXT,
ADD COLUMN     "descricaoRP" TEXT,
ADD COLUMN     "entidadeLicenca" TEXT,
ADD COLUMN     "equipamentos" TEXT,
ADD COLUMN     "fracaoAutonoma" TEXT,
ADD COLUMN     "freguesia" TEXT,
ADD COLUMN     "incluirProprietarios" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "incluirSubtracaoCaucao" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "licencaUtilizacao" TEXT,
ADD COLUMN     "modeloDespesas" TEXT NOT NULL DEFAULT 'INCLUIDO',
ADD COLUMN     "moradaProprietarios" TEXT,
ADD COLUMN     "nifProprietario2" TEXT,
ADD COLUMN     "nomeProprietario1" TEXT,
ADD COLUMN     "nomeProprietario2" TEXT,
ADD COLUMN     "regimeCasamento" TEXT;
