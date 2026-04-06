export const prisma = {
  importacao: { findUnique: jest.fn(), create: jest.fn(), update: jest.fn() },
  fatura: { create: jest.fn(), findUnique: jest.fn(), findMany: jest.fn() },
  faturaClassificacao: { create: jest.fn() },
  nifImovelMap: { findFirst: jest.fn() },
  utilizador: { findUnique: jest.fn(), update: jest.fn(), count: jest.fn() },
  imovel: { findMany: jest.fn() },
  rubrica: { findMany: jest.fn() },
  lancamentoManual: { findMany: jest.fn() },
}
