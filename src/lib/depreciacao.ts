// Taxas de depreciacao por tipo de activo (DR n.º 25/2009)
// Imoveis: edificios nao industriais 2% (50 anos); industriais 5%; obras 10%
// Viaturas: ligeiras 25% (4 anos); pesadas mercadorias 20%; pesadas passageiros 14%
// Equipamento: equip. basico 12.5-25%

export function depreciacaoImovelDefault(tipo: string): number {
  switch (tipo) {
    case 'INDUSTRIAL':
      return 5 // edificios industriais — 5% (20 anos)
    case 'APARTAMENTO':
    case 'MORADIA':
    case 'ESCRITORIO':
    case 'LOJA':
      return 2 // edificios nao industriais — 2% (50 anos)
    case 'OUTRO':
    case 'GERAL':
    case 'PESSOAL':
      return 2
    default:
      return 2
  }
}

export function depreciacaoActivoDefault(tipo: string): number {
  switch (tipo) {
    case 'VIATURA_LIGEIRA':
      return 25 // 4 anos
    case 'VIATURA_PESADA':
      return 20 // 5 anos (mercadorias); passageiros 14%
    case 'EQUIPAMENTO':
      return 20
    case 'OUTRO':
      return 12.5
    default:
      return 20
  }
}

// Tributacao autonoma — tier por valor de aquisicao da viatura
// (PT IRC art. 88.º)
export type TierViatura = 'BAIXA' | 'MEDIA' | 'ALTA' | 'ELECTRICA_ISENTA' | 'ELECTRICA_TRIBUTADA'

export interface TaConfig {
  taTaxaComBaixa: number; taTaxaComMedia: number; taTaxaComAlta: number
  taTaxaHibBaixa: number; taTaxaHibMedia: number; taTaxaHibAlta: number
  taTaxaGplBaixa: number; taTaxaGplMedia: number; taTaxaGplAlta: number
  taTaxaElectrica: number
  taLimiteElectricoIsento: number
  taLimiteViaturaBaixa: number
  taLimiteViaturaAlta: number
  limiteDeducaoCombustao: number
  limiteDeducaoGpl: number
  limiteDeducaoHibrido: number
  limiteDeducaoElectrico: number
}

export function tierViaturaPorValor(
  valor: number,
  combustivel: string,
  cfg: TaConfig,
): TierViatura {
  if (combustivel === 'ELECTRICO') {
    return valor <= cfg.taLimiteElectricoIsento ? 'ELECTRICA_ISENTA' : 'ELECTRICA_TRIBUTADA'
  }
  if (valor < cfg.taLimiteViaturaBaixa) return 'BAIXA'
  if (valor < cfg.taLimiteViaturaAlta) return 'MEDIA'
  return 'ALTA'
}

export function taxaTaPorViatura(
  valor: number,
  combustivel: string,
  cfg: TaConfig,
): number {
  const tier = tierViaturaPorValor(valor, combustivel, cfg)
  if (combustivel === 'ELECTRICO') {
    return tier === 'ELECTRICA_ISENTA' ? 0 : cfg.taTaxaElectrica
  }
  if (combustivel === 'HIBRIDO_PLUG_IN') {
    if (tier === 'BAIXA') return cfg.taTaxaHibBaixa
    if (tier === 'MEDIA') return cfg.taTaxaHibMedia
    return cfg.taTaxaHibAlta
  }
  if (combustivel === 'GPL_GNV') {
    if (tier === 'BAIXA') return cfg.taTaxaGplBaixa
    if (tier === 'MEDIA') return cfg.taTaxaGplMedia
    return cfg.taTaxaGplAlta
  }
  // COMBUSTAO (default)
  if (tier === 'BAIXA') return cfg.taTaxaComBaixa
  if (tier === 'MEDIA') return cfg.taTaxaComMedia
  return cfg.taTaxaComAlta
}

export function limiteDeducaoPorCombustivel(combustivel: string, cfg: TaConfig): number {
  switch (combustivel) {
    case 'ELECTRICO': return cfg.limiteDeducaoElectrico
    case 'HIBRIDO_PLUG_IN': return cfg.limiteDeducaoHibrido
    case 'GPL_GNV': return cfg.limiteDeducaoGpl
    default: return cfg.limiteDeducaoCombustao
  }
}

// Depreciacao anual fiscalmente aceite para uma viatura
// (limitada pelo custo de aquisicao maximo dedutivel)
export function depreciacaoFiscalViatura(
  valorAquisicao: number,
  taxaAnual: number,
  combustivel: string,
  cfg: TaConfig,
): { depreciacaoContabil: number; depreciacaoAceite: number; acrescimo: number } {
  const limite = limiteDeducaoPorCombustivel(combustivel, cfg)
  const depreciacaoContabil = valorAquisicao * (taxaAnual / 100)
  const valorDedutivel = Math.min(valorAquisicao, limite)
  const depreciacaoAceite = valorDedutivel * (taxaAnual / 100)
  const acrescimo = Math.max(depreciacaoContabil - depreciacaoAceite, 0)
  return { depreciacaoContabil, depreciacaoAceite, acrescimo }
}
