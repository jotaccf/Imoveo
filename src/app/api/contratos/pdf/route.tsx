import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { renderToBuffer, Document, Page, Text, View, StyleSheet } from '@react-pdf/renderer'
import { PDFDocument } from 'pdf-lib'
import { writeFileSync, readFileSync, existsSync, mkdirSync } from 'fs'
import { join } from 'path'

// ---------- helpers ----------

const MESES_PT = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
]

function formatDatePT(d: Date | string | null | undefined): string {
  if (!d) return ''
  const date = new Date(d)
  return `${date.getDate()} de ${MESES_PT[date.getMonth()]} de ${date.getFullYear()}`
}

function formatCurrency(v: unknown): string {
  if (v === null || v === undefined) return '0'
  return Number(v).toFixed(2).replace('.', ',')
}

function cfg(configs: Record<string, string>, key: string, fallback = ''): string {
  return configs[key] ?? fallback
}

// ---------- styles ----------

const s = StyleSheet.create({
  page: {
    paddingTop: 50,
    paddingBottom: 50,
    paddingLeft: 45,
    paddingRight: 45,
    fontSize: 10,
    fontFamily: 'Helvetica',
    color: '#0D1B1A',
  },
  title: {
    fontSize: 13,
    fontFamily: 'Helvetica-Bold',
    textAlign: 'center',
    textTransform: 'uppercase',
    marginBottom: 20,
  },
  bold: {
    fontFamily: 'Helvetica-Bold',
  },
  clauseTitle: {
    fontSize: 11,
    fontFamily: 'Helvetica-Bold',
    textAlign: 'center',
    marginTop: 12,
    marginBottom: 2,
  },
  clauseSubtitle: {
    fontSize: 10,
    fontFamily: 'Helvetica-Bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  paragraph: {
    textAlign: 'justify',
    marginBottom: 6,
    lineHeight: 1.5,
    fontSize: 10,
  },
  signatureSection: {
    marginTop: 30,
    break: 'avoid' as unknown as undefined,
    minPresenceAhead: 200,
  },
  signatureBlock: {
    alignItems: 'center',
    marginTop: 20,
    marginBottom: 15,
  },
  signatureLabel: {
    fontSize: 10,
    fontFamily: 'Helvetica-Bold',
    marginBottom: 4,
  },
  signatureDash: {
    width: 200,
    borderBottom: '1px solid #0D1B1A',
    marginTop: 40,
  },
  anexoTitle: {
    fontSize: 14,
    fontFamily: 'Helvetica-Bold',
    textAlign: 'center',
    marginTop: 30,
  },
})

// ---------- data loading ----------

interface ContratoData {
  id: string
  nomeInquilino: string
  nifInquilino: string | null
  contacto: string | null
  genero: string | null
  nacionalidade: string | null
  tipoDocumento: string | null
  numDocumento: string | null
  validadeDocumento: Date | null
  estadoCivil: string | null
  naturalidade: string | null
  moradaInquilino: string | null
  usarMoradaImovel: boolean
  valorRenda: unknown
  dataInicio: Date
  dataFim: Date | null
  renovacaoAuto: boolean
  periodoRenovacao: number
  caucao: unknown
  localAssinatura: string | null
  dataAssinatura: Date | null
  nomeFiador: string | null
  nifFiador: string | null
  contactoFiador: string | null
  parentesco: string | null
  fracao: {
    id: string
    nome: string
    letraQuarto: string | null
    tipoQuarto: string | null
    casaBanho: string | null
    mobilia: string | null
    numeroAnexo: string | null
    imovel: {
      id: string
      morada: string | null
      localizacao: string
      fracaoAutonoma: string | null
      andar: string | null
      freguesia: string | null
      concelho: string | null
      artigoMatricial: string | null
      descricaoRP: string | null
      licencaUtilizacao: string | null
      dataLicenca: string | null
      entidadeLicenca: string | null
      incluirProprietarios: boolean
      nomeProprietario1: string | null
      ccProprietario1: string | null
      nifProprietario: string | null
      nomeProprietario2: string | null
      nifProprietario2: string | null
      ccProprietario2: string | null
      regimeCasamento: string | null
      moradaProprietarios: string | null
      dataContratoArrendamento: Date | null
      equipamentos: string | null
      modeloDespesas: string
      plantaPath: string | null
      incluirSubtracaoCaucao: boolean
      fracoes: { id: string }[]
    }
  }
}

interface Empresa {
  nome: string
  formaJuridica: string
  morada: string
  nipc: string
  conservatoria: string
  foro: string
  limiteElectricidade: string
}

// ---------- gender helpers ----------

function estadoCivilGendered(estadoCivil: string | null, genero: string | null): string {
  if (!estadoCivil) return ''
  const fem = genero === 'Feminino'
  const map: Record<string, [string, string]> = {
    'Solteiro': ['Solteiro', 'Solteira'],
    'Casado': ['Casado', 'Casada'],
    'Divorciado': ['Divorciado', 'Divorciada'],
    'Viuvo': ['Viúvo', 'Viúva'],
    'Uniao de Facto': ['em União de Facto', 'em União de Facto'],
  }
  const pair = map[estadoCivil]
  return pair ? pair[fem ? 1 : 0] : estadoCivil
}

function tipoDocumentoLabel(tipo: string | null): string {
  if (tipo === 'CC') return 'Cartão de Cidadão'
  if (tipo === 'Passaporte') return 'Passaporte'
  if (tipo === 'Titulo de Residencia') return 'Título de Residência'
  return tipo || 'documento de identificação'
}

function portador(genero: string | null): string {
  return genero === 'Feminino' ? 'portadora' : 'portador'
}

function designado(genero: string | null): string {
  return genero === 'Feminino' ? 'designada' : 'designado'
}

function segundoOutorganteLabel(genero: string | null): string {
  return genero === 'Feminino' ? 'A SEGUNDA OUTORGANTE' : 'O SEGUNDO OUTORGANTE'
}

function aSegundaOutorgante(genero: string | null): string {
  return genero === 'Feminino' ? 'A Segunda Outorgante' : 'O Segundo Outorgante'
}

// ---------- month helpers ----------

function mesNome(d: Date): string {
  return MESES_PT[d.getMonth()]
}

function anoNum(d: Date): number {
  return d.getFullYear()
}

function mesSeguinteNome(d: Date): string {
  const nextMonth = (d.getMonth() + 1) % 12
  return MESES_PT[nextMonth]
}

function anoSeguinte(d: Date): number {
  return d.getMonth() === 11 ? d.getFullYear() + 1 : d.getFullYear()
}

// ---------- PDF Component ----------

function ContratoPDF({ contrato: c, empresa: emp }: { contrato: ContratoData; empresa: Empresa }) {
  const im = c.fracao.imovel
  const fr = c.fracao
  const totalQuartos = im.fracoes.length
  const dataInicioDate = new Date(c.dataInicio)

  // ---- Build SEGUNDO OUTORGANTE identification text ----
  let segundoText = `${c.nomeInquilino}, `
  if (c.nifInquilino) {
    segundoText += `NIF ${c.nifInquilino}, `
  }
  segundoText += `${estadoCivilGendered(c.estadoCivil, c.genero)}, Natural de ${c.naturalidade || ''}, ${portador(c.genero)} do ${tipoDocumentoLabel(c.tipoDocumento)} n.º ${c.numDocumento || ''}`
  if (c.validadeDocumento) {
    segundoText += ` e válido até ${formatDatePT(c.validadeDocumento)}`
  }
  segundoText += ', '
  if (c.usarMoradaImovel) {
    if (c.genero === 'Feminino') {
      segundoText += `residente durante ${im.morada || im.localizacao}`
    } else {
      segundoText += `residente na vigência do presente contrato na ${im.morada || im.localizacao}`
    }
  } else {
    segundoText += `residente na ${c.moradaInquilino || ''}`
  }
  segundoText += `, doravante ${designado(c.genero)} por Segundo Outorgante,`

  // ---- Build CONSIDERANDO §1 ----
  let cons1 = `A Primeira Outorgante é arrendatária da fração autónoma designada pela letra "${im.fracaoAutonoma || ''}", correspondente ao ${im.andar || ''}, do prédio sito na ${im.morada || im.localizacao}, freguesia de ${im.freguesia || ''}, concelho de ${im.concelho || ''}, inscrito na respetiva matriz predial urbana sob o artigo ${im.artigoMatricial || ''}`

  if (im.descricaoRP) {
    cons1 += ` e descrito na Conservatória do Registo Predial de ${im.concelho || ''} sob o n.º ${im.descricaoRP}, da mesma freguesia`
  }
  if (im.licencaUtilizacao) {
    cons1 += `, com autorização de utilização n.º ${im.licencaUtilizacao}, emitida pela ${im.entidadeLicenca || ''} a ${im.dataLicenca || ''}`
  }
  cons1 += `, por efeito de contrato de arrendamento outorgado na data de ${formatDatePT(im.dataContratoArrendamento)}`

  if (im.incluirProprietarios && im.nomeProprietario1) {
    cons1 += `, com os donos e legítimos proprietários da referida fração, ${im.nomeProprietario1}, portador do cartão de cidadão n.º ${im.ccProprietario1 || ''}, NIF ${im.nifProprietario || ''}`
    if (im.nomeProprietario2) {
      cons1 += ` e ${im.nomeProprietario2}, portadora do cartão de cidadão n.º ${im.ccProprietario2 || ''}, NIF ${im.nifProprietario2 || ''}, casados entre si no regime de ${im.regimeCasamento || ''}`
    }
    if (im.moradaProprietarios) {
      cons1 += `, ambos residentes na ${im.moradaProprietarios}`
    }
  }

  cons1 += `, doravante designado por o Imóvel;`

  // ---- Build CONSIDERANDO §2 ----
  let cons2 = `A Primeira Outorgante se encontra devidamente autorizada, pelos donos e legítimos proprietários identificados no considerando anterior, a celebrar contratos de subarrendamento`
  if (im.dataContratoArrendamento) {
    cons2 += ` conforme contrato datado de ${formatDatePT(im.dataContratoArrendamento)}`
  }
  cons2 += '.'

  // ---- Cláusula Segunda - Objeto ----
  const casaBanhoPriv = fr.casaBanho === 'Privativa'
  const tipoEspaco = fr.tipoQuarto === 'Suite' ? 'espaço' : 'sala'
  const residenciaPermanente = !c.usarMoradaImovel ? 'permanente ' : ''

  // ---- Cláusula Terceira - Vigência ----
  let renovacaoText = ''
  if (c.renovacaoAuto) {
    renovacaoText = `, renovando-se automaticamente no seu termo por períodos sucessivos de ${c.periodoRenovacao} meses enquanto não nenhumas das partes se opuser à renovação nos termos dos números seguintes.`
  } else {
    renovacaoText = ', não renovável.'
  }

  // ---- Cláusula Quarta - Renda ----
  const valorRenda = formatCurrency(c.valorRenda)
  const mesInicioStr = mesNome(dataInicioDate)
  const anoInicioStr = anoNum(dataInicioDate)
  const mesSeguinteStr = mesSeguinteNome(dataInicioDate)
  const anoSeguinteStr = anoSeguinte(dataInicioDate)

  // ---- Cláusula Quinta - Caução ----
  const valorCaucao = formatCurrency(c.caucao)

  return (
    <Document>
      <Page size="A4" style={s.page} wrap>
        {/* ==================== TITLE ==================== */}
        <Text style={s.title}>
          {'CONTRATO DE SUBARRENDAMENTO\nPARA FINS HABITACIONAIS COM PRAZO CERTO'}
        </Text>

        {/* ==================== PARTIES ==================== */}
        <Text style={s.paragraph}>
          <Text style={s.bold}>Entre:</Text>
        </Text>

        <Text style={s.paragraph}>
          <Text style={s.bold}>PRIMEIRA OUTORGANTE:</Text>
          {'\n'}
          {emp.nome}, {emp.formaJuridica}, com sede na {emp.morada}, matriculada na {emp.conservatoria} sob o número único de matrícula e NIPC {emp.nipc}, doravante designada por Primeira Outorgante, e
        </Text>

        <Text style={s.paragraph}>
          <Text style={s.bold}>SEGUNDO OUTORGANTE:</Text>
          {'\n'}
          {segundoText}
        </Text>

        {/* ==================== CONSIDERANDOS ==================== */}
        <Text style={s.paragraph}>
          <Text style={s.bold}>CONSIDERANDO QUE:</Text>
        </Text>

        <Text style={s.paragraph}>
          §1. {cons1}
        </Text>

        <Text style={s.paragraph}>
          §2. {cons2}
        </Text>

        <Text style={s.paragraph}>
          É, pelo presente, e de boa-fé, celebrado e reduzido a escrito o contrato de subarrendamento para fins habitacionais, com prazo certo, que se rege pelos Considerandos anteriores, pelas cláusulas seguintes e pela legislação aplicável, aceitando as partes os seus exatos termos que se obrigam, reciprocamente, a cumprir:
        </Text>

        {/* ==================== CLÁUSULA PRIMEIRA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA PRIMEIRA</Text>
        <Text style={s.clauseSubtitle}>(Identificação do Imóvel)</Text>

        <Text style={s.paragraph}>
          No imóvel identificado no considerando §1, composto por {totalQuartos} quartos, encontram-se os seguintes eletrodomésticos e equipamentos, que acompanharão o Imóvel durante a vigência do presente contrato:
        </Text>
        <Text style={s.paragraph}>
          {im.equipamentos || ''}
        </Text>

        {/* ==================== CLÁUSULA SEGUNDA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA SEGUNDA</Text>
        <Text style={s.clauseSubtitle}>(Objeto)</Text>

        <Text style={s.paragraph}>
          Pelo presente contrato de subarrendamento, a Primeira Outorgante dá de subarrendamento ao Segundo Outorgante um quarto na habitação descrita no Considerando §1, melhor identificado na Planta que se junta como ANEXO {fr.numeroAnexo || 'I'} e faz parte integrante do presente contrato, identificado pela Letra {fr.letraQuarto || ''}, com serventia de casa de banho {casaBanhoPriv ? 'privativa, ' : ''}cozinha e {tipoEspaco} de refeições. O quarto destina-se exclusivamente à habitação própria {residenciaPermanente}do Segundo Outorgante, não podendo este dar-lhe dado outro fim ou uso, nem fazer dele uma utilização imprudente ou contrária ao fim a que se destina, sob pena de resolução do presente contrato pela Primeira Outorgante.
        </Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante reconhece e aceita o estado de conservação em que tanto o quarto como o imóvel se encontram e que é do conhecimento do mesmo.
        </Text>

        <Text style={s.paragraph}>
          O mencionado quarto é entregue ao Segundo Outorgante mobilado com {fr.mobilia || ''}.
        </Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante não poderá, sem prévio consentimento escrito da Primeira Outorgante, proporcionar a terceiros o gozo, total ou parcial, do quarto ou do imóvel, por qualquer forma de cessão, gratuita ou onerosa, incluindo por subarrendamento ou alojamento.
        </Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante não poderá fazer uso dos restantes quartos existentes no imóvel, sem o prévio consentimento por escrito da Primeira Outorgante.
        </Text>

        <Text style={s.paragraph}>
          Ficam expressamente proibidas a hospedagem e a indústria doméstica, salvo prévia autorização por escrito, dada pelos Senhorios.
        </Text>

        {/* ==================== CLÁUSULA TERCEIRA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA TERCEIRA</Text>
        <Text style={s.clauseSubtitle}>(Vigência e Renovação)</Text>

        <Text style={s.paragraph}>
          O presente contrato de subarrendamento é celebrado pelo prazo de {c.periodoRenovacao} meses, com início em {formatDatePT(c.dataInicio)} e termo em {formatDatePT(c.dataFim)}{renovacaoText}
        </Text>

        <Text style={s.paragraph}>
          A Primeira Outorgante pode opor-se à renovação automática do presente contrato mediante comunicação escrita, registada e com aviso de receção, dirigida ao Segundo Outorgante para a morada do Imóvel, que desde já se convenciona para os referidos efeitos, efetuada com uma antecedência mínima de 60 (sessenta) dias face ao termo do prazo inicial do presente contrato ou da renovação, por meio de carta registada com aviso de receção.
        </Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante pode opor-se à renovação automática do contrato de arrendamento mediante comunicação escrita, registada e com aviso de receção, dirigida à Primeira Outorgante, com a antecedência prevista nos termos legais (60 dias).
        </Text>

        <Text style={s.paragraph}>
          Decorrido um terço do prazo de duração sobre a data de início de vigência do contrato, o Segundo Outorgante poderá denunciá-lo, a todo o tempo, mediante comunicação à Primeira Outorgante, nos termos do número anterior, com antecedência mínima legalmente prevista (60 dias), sobre a data em que pretenda a cessação, a qual produzirá os seus efeitos no final do mês do calendário gregoriano em que se cumpra aquele período de aviso prévio.
        </Text>

        <Text style={s.paragraph}>
          A não observância de um terço de vigência do contracto ou do integral cumprimento do período de pré-aviso previsto no número anterior obriga o Segundo Outorgante ao pagamento das rendas correspondentes ao período em falta.
        </Text>

        <Text style={s.paragraph}>
          Em caso de denúncia do presente contracto de arrendamento pelo Segundo Outorgante, este deverá facultar a vistoria ao quarto e ao Imóvel até 1 (um) mês antes da entrega do locado livre e devoluto de pessoas e bens que não pertençam ao Imóvel, de modo possibilitar à Primeira Outorgante ou alguém que esta indique, a averiguação da existência de danos materiais no mesmo.
        </Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante obriga-se a desocupar o Imóvel e o quarto imediatamente após o termo do presente contracto.
        </Text>

        <Text style={s.paragraph}>
          Em qualquer caso de cessação do presente contracto, especialmente em caso de denúncia pela Primeira outorgante, se o Segundo Outorgante não restituir o quarto e o Imóvel até ao termo do prazo contratual ou até à data em que deveria fazê-lo, constitui-se na obrigação de indemnizar a Primeira Outorgante no valor diário correspondente a um décimo do valor mensal da renda por cada dia de atraso na restituição do Imóvel e do quarto e ainda na obrigação de suportar as despesas judiciais e extrajudiciais que a Primeira Outorgante venha a ter, incluindo custas judiciais e honorários com Advogado ou solicitador de Execução.
        </Text>

        {/* ==================== CLÁUSULA QUARTA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA QUARTA</Text>
        <Text style={s.clauseSubtitle}>(Renda)</Text>

        <Text style={s.paragraph}>
          A renda mensal é de € {valorRenda}, vence-se no 25 do mês anterior àquele a que disser respeito e será paga pelo Segundo Outorgante por referência MB indicado na Factura emitida pela Primeira Outorgante a ser emitida mensalmente a 22 do mês anterior àquela a que disser respeito o pagamento e enviada por correio electrónico para o(s) endereço(s) de e-mail {c.contacto || ''}, ou, sob qualquer outra forma ou local que venha a ser indicado por aquele.
        </Text>

        <Text style={s.paragraph}>
          {aSegundaOutorgante(c.genero)} líquida no ato de assinatura do presente contrato o valor de {valorRenda}€ relativo ao valor de {mesInicioStr} de {anoInicioStr} e retomará o pagamento da renda devida referente ao mês de {mesSeguinteStr} de {anoSeguinteStr}, que deverá ser liquidada até ao dia 25 de {mesInicioStr} de {anoInicioStr}, retomando no mês seguinte os normais pagamentos, sendo que cada renda deverá ser liquidada até ao dia 25 dia do mês anterior a que disser respeito.
        </Text>

        <Text style={s.paragraph}>
          A renda estipulada fica sujeita a atualizações anuais, podendo a primeira atualização ser exigida pela Primeira Outorgante, um ano após a vigência do contracto, tendo como base os coeficientes legalmente fixados, contando que tal atualização seja comunicada ao Segundo Outorgante com uma antecedência mínima de 30 (trinta) dias desde a data em que a nova renda é devida.
        </Text>

        <Text style={s.paragraph}>
          Após o bom recebimento do valor da renda, os respetivos recibos serão emitidos e enviados por e-mail.
        </Text>

        <Text style={s.paragraph}>
          Pelo atraso no pagamento da renda, além das rendas em atraso, a Primeira Outorgante reserva-se o direito de exigir do Segundo Outorgante uma indemnização equivalente a 20% do valor da renda mensal por cada mês ou fração em atraso, sem prejuízo do direito à resolução do contrato{im.incluirSubtracaoCaucao ? ', podendo subtrair o valor da indeminização ao depósito de garantia entregue pela Segunda Outorgante' : ''}.
        </Text>

        {/* ==================== CLÁUSULA QUINTA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA QUINTA</Text>
        <Text style={s.clauseSubtitle}>(Caução)</Text>

        <Text style={s.paragraph}>
          No ato de assinatura do presente contrato, o Segundo Outorgante efetua um depósito de garantia no montante de € {valorCaucao}, destinado a garantir a boa execução das suas obrigações e, bem assim, a conservação e manutenção do Imóvel, quarto, bem como dos eletrodomésticos e equipamentos descritos na Cláusula Primeira, do qual se dá integral quitação.
        </Text>

        <Text style={s.paragraph}>
          Em caso de cessação do presente contrato, por qualquer forma prevista na lei ou no contrato, e verificação do integral cumprimento do mesmo, bem como o bom estado de conservação e manutenção de paredes, chão, teto, janelas e portas e eletrodomésticos e equipamentos, e contando que se encontrem liquidadas todas as despesas decorrentes de consumos de água, eletricidade e, bem assim, quaisquer outros consumos imputáveis ao Segundo Outorgante, o valor caucionado será devolvido a este até 30 (trinta) dias após a efetiva desocupação e entrega do Imóvel.
        </Text>

        <Text style={s.paragraph}>
          Este depósito não poderá ser considerado como pagamento das últimas rendas devidas.
        </Text>

        {/* ==================== CLÁUSULA SEXTA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA SEXTA</Text>
        <Text style={s.clauseSubtitle}>(Despesas)</Text>

        {im.modeloDespesas === 'INDIVIDUAL' ? (
          <>
            <Text style={s.paragraph}>
              Os encargos relativos ao consumo de eletricidade encontram-se incluídos no valor da renda mensal referida no n.º 1 da Cláusula Quarta, até ao limite de {emp.limiteElectricidade}€ por quarto, sendo o remanescente, quando aplicável facturado ao Segundo Outorgante aquando da emissão da factura, sendo o cálculo dos consumos de electricidade realizado da seguinte forma:
            </Text>
            <Text style={s.paragraph}>
              Consumo associado ao quarto ocupado pelo Segundo Outorgante;{'\n'}
              Consumo associado às partes comuns do imóvel será dividida de forma proporcional pelo número de quartos ocupados à data da facturação.
            </Text>
            <Text style={s.paragraph}>
              Os encargos relativos à água, limpeza das zonas comuns, electricidade das zonas comuns, Internet e TV encontram-se incluídos no valor da renda mensal referida no n.º 1 da Cláusula Quarta.
            </Text>
          </>
        ) : (
          <Text style={s.paragraph}>
            Os encargos relativos ao consumo de água, eletricidade, gás e internet encontram-se incluídos no valor da renda mensal referida no n.º 1 da Cláusula Quarta, até ao limite de {emp.limiteElectricidade}€. No caso de os gastos relativos às despesas referidas no número anterior ultrapassarem a quantia mencionado no número anterior, a Primeira Outorgante reserva-se no direito de solicitar ao Segundo Outorgante o pagamento da diferença, que deverá ser liquidada pela mesma no prazo máximo de 10 dias, sendo emitida uma factura correspondente ao valor remanescente no n.º 1 da Cláusula Quarta.
          </Text>
        )}

        {/* ==================== CLÁUSULA SÉTIMA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA SÉTIMA</Text>
        <Text style={s.clauseSubtitle}>(Estado do Imóvel e Obras)</Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante reconhece que o quarto, o Imóvel e suas dependências e demais elementos que o acompanham, nomeadamente os eletrodomésticos e equipamentos descritos na Cláusula Primeira, se encontram em bom estado de conservação e em condições de funcionalidade para o fim a que se destinam, sendo responsável por qualquer dano ou defeito decorrente da utilização do mesmo, pelo que o quarto e o Imóvel devem ser entregues na data da sua cessação limpo e em bom estado de conservação, (nomeadamente com a perfeita manutenção das paredes, tetos, pavimentos, portas, fechaduras, vidros e encanamentos, bem como a manutenção das instalações de água, luz, gás, esgotos e comunicações), obrigando-se o Segundo Outorgante a reparar todas as deteriorações, incluindo obras ou intervenções ilícitas realizadas para melhorar o seu conforto ou comodidade, com exceção das que resultam de um uso normal e prudente, indemnizando a Primeira Outorgante de todos os danos que haja causado, ainda que de forma negligente, e que não tenham sido reparados.
        </Text>

        <Text style={s.paragraph}>
          Em complemento do disposto no número anterior e uma vez verificada a cessação do presente contrato, por qualquer uma das formas possíveis, deverá ser lavrado um Auto, no ato da entrega do quarto e do Imóvel à Primeira Outorgante, onde serão registadas todas as deteriorações encontradas no quarto e no Imóvel, bem como nos eletrodomésticos e equipamentos, responsabilizando-se, desde já o Segundo Outorgante, ilimitadamente, por indemnizar a Primeira Outorgante pelo custo de reparação de deteriorações encontradas, de acordo com as regras de mercado, no prazo máximo de 15 (quinze) dias a contar da interpelação para o efeito.
        </Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante não terá direito a levantar as obras ou benfeitorias realizadas no quarto e no Imóvel, ainda que autorizados pela Primeira Outorgante, renunciando a qualquer indemnização, mesmo que com fundamento nas regras do enriquecimento sem causa, ou a alegar ou exercer o direito de retenção ou de remoção por quaisquer benfeitorias ou obras, incluindo as licitamente edificadas, salvo as que puderem ser levantadas sem dano ou perda do locado.
        </Text>

        <Text style={s.paragraph}>
          A Primeira Outorgante pode, durante a vigência do contracto, realizar quaisquer obras em benefício do quarto e do Imóvel, ainda que de mera conservação ou reparação, sem necessidade de autorização do Segundo Outorgante para quaisquer visitas ou ao acesso ao locado, podendo aqueles indicar, para o efeito, qualquer outra pessoa ou entidade.
        </Text>

        {/* ==================== CLÁUSULA OITAVA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA OITAVA</Text>
        <Text style={s.clauseSubtitle}>(Outras Obrigações do Arrendatário)</Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante obriga-se a:{'\n'}
          Cumprir com as exigências legais, administrativas e fiscais, camarárias ou outras que sejam conexas com a utilização do quarto e do Imóvel ou com o seu arrendamento, bem como pagar as taxas, coimas, multas ou outras cominações legais, relacionados com a utilização do locado bem como eventuais danos ou prejuízos causados a terceiros, ficando, no entanto, ao encargo dos Proprietários os impostos relativos à propriedade do Imóvel, nomeadamente o Imposto Municipal sobre Imóveis;{'\n'}
          Facultar à Primeira Outorgante ou a quem esta indicar, o acesso ao quarto e ao imóvel, mediante marcação prévia com uma antecedência mínima de 24 (vinte e quatro) horas;{'\n'}
          Cumprir e fazer cumprir as obrigações e deveres previstos no Regulamento de Condomínio ou emergentes de qualquer deliberação da assembleia de condóminos.
        </Text>

        {/* ==================== CLÁUSULA NONA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA NONA</Text>
        <Text style={s.clauseSubtitle}>(Resolução e Condição Resolutiva)</Text>

        <Text style={s.paragraph}>
          Qualquer das partes pode resolver o presente contracto, nos termos gerais de direito, com base em incumprimento da outra parte que, pela sua gravidade ou consequências, tornem inexigível a manutenção do arrendamento.
        </Text>

        <Text style={s.paragraph}>
          As partes consideram que o incumprimento do Segundo Outorgante nos termos que ora se discriminam, atenta a gravidade e consequências que implicam, o que, ambas as partes, desde já, reconhecem, tornam inexigível à Primeira Outorgante a manutenção do arrendamento e consubstanciam fundamento direto e imediato para a resolução do contracto, a saber:{'\n'}
          Não pagamento pontual e integral do valor da renda, qualquer que seja o montante e o número de meses de renda, total ou parcial, em dívida;{'\n'}
          Dar hospedagem, arrendar ou subarrendar, no todo ou em parte, qualquer que seja o número de pessoas ou o período em que se mantenham no locado;{'\n'}
          A prática de atos no locado que causem deteriorações ou sejam contrários à lei, à ordem pública ou aos bons costumes;{'\n'}
          A instalação no quarto e no imóvel de equipamentos que não sejam usuais para o fim a que se destina e que possam prejudicar ou pôr em risco a segurança, salubridade e bem-estar do locado, das partes comuns, do prédio ou de qualquer dos seus habitantes ou utilizadores;{'\n'}
          Colocar nas janelas ou varandas objetos que não estejam devidamente resguardados do perigo de queda ou sejam proibidos ou desaconselhados pelo condomínio, seja em regulamento existente para o efeito, seja em qualquer deliberação ad hoc;{'\n'}
          A manutenção de animais no locado, onde se inclui o quarto, bem como nas partes comuns do prédio ou em zonas exteriores;{'\n'}
          A armazenagem ou utilização no quarto ou no imóvel de explosivos ou produtos facilmente inflamáveis;{'\n'}
          A propagação pelo prédio de cheiros desagradáveis ou fumos;{'\n'}
          O atraso na realização de obras de reparação pelas quais seja responsável ou a realização de quaisquer obras de carácter extraordinário, incluindo as que alterem as divisões internas do locado;{'\n'}
          Se autorizada a sublocação, cobrar do sublocatário valor de renda superior à prevista no presente contracto;{'\n'}
          Não facultar à Primeira Outorgante, ou a quem esta tiver indicado, o exame do quarto e do Imóvel, quando tal lhe tenha sido solicitado;{'\n'}
          Impedir a Primeira Outorgante de realizar as reparações urgentes ou, por qualquer forma, atrasar a realização das mesmas;{'\n'}
          O desrespeito pelas normas e regulamentos municipais ou outras regras aplicáveis, nomeadamente, as referentes a ruídos ou barulhos incomodativos;{'\n'}
          A perturbação da tranquilidade do prédio com vozes elevadas, sons, ruídos, vibrações, calor, fumos ou outros fatores que perturbem os demais habitantes ou utilizadores do prédio;{'\n'}
          Despejar, a partir do quarto ou do imóvel, nomeadamente, das portas, janelas ou varandas, qualquer tipo de objetos ou de resíduos para a via pública, para as partes comuns do prédio, para outros prédios confinantes ou para qualquer outra parte privada, bem como manter resíduos ou recipientes fora dos locais destinados para o efeito;{'\n'}
          A colocação de qualquer tipo de antenas exteriores ou de anúncios ou reclamos, luminosos ou não, que sejam visíveis do exterior do quarto ou do imóvel;{'\n'}
          A modificação, por qualquer forma, da estrutura ou aparência do quarto ou do imóvel ou da fachada do prédio, incluindo das janelas e varandas, bem como a colocação ou alteração de caixilharias ou marquises;{'\n'}
          Pintar qualquer zona exterior do prédio, ou, por qualquer forma, a modificar ou alterar o seu aspeto exterior, incluindo na zona das varandas e terraços;{'\n'}
          Obstruir ou dificultar, por qualquer forma, a circulação nas partes comuns do prédio, em especial o acesso e circulação nas escadas, na garagem, ascensores, escadas de emergência e qualquer outra parte comum do prédio ou de qualquer outra zona, apartamento ou fração autónoma, incluindo a colocação de qualquer objeto, nomeadamente, veículos, atrelados, móveis, vasos ou floreiras, que se encontrem fora do Imóvel, se aplicável;{'\n'}
          Praticar qualquer ato que impossibilite, dificulte ou onere a utilização, pelos demais condóminos, de partes privadas do prédio, de outras frações autónomas ou das partes comuns;{'\n'}
          Não cumprir, integral e pontualmente, com as normas constantes do Regulamento de Condomínio ou com qualquer das demais obrigações aplicáveis aos Arrendatários, nomeadamente as previstas neste contracto e na legislação e normas regulamentares e municipais aplicáveis;{'\n'}
          Não respeitar os restantes residentes do Imóvel, nomeadamente, em questões de descanso, segurança e higiene.
        </Text>

        <Text style={s.paragraph}>
          Caso a Primeira Outorgante tenha de recorrer a juízo para o cumprimento de qualquer obrigação emergente do presente contracto, fixa-se, desde já, uma penalização de 500€ para efeito de despesas, que acresce aos valores que sejam imputáveis ao Segundo Outorgante pelos valores em dívida ao abrigo da execução do presente contracto.
        </Text>

        {/* ==================== CLÁUSULA DÉCIMA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA DÉCIMA</Text>
        <Text style={s.clauseSubtitle}>(Comunicações e Foro)</Text>

        <Text style={s.paragraph}>
          As Partes contraentes acordam que as notificações e comunicações entre eles serão consideradas válidas e eficazes, se forem efetuadas para, no caso da Primeira Outorgante, a morada indicada no introito do presente contracto, e no caso do Segundo Outorgante a morada do Imóvel e quarto ora subarrendado, ou para as moradas que posteriormente sejam informadas, através de carta registada e com aviso de receção, à outra Parte.
        </Text>

        <Text style={s.paragraph}>
          Caso algum dos Contraentes não comunique ao outro uma eventual mudança de morada, as notificações e comunicações serão consideradas válidas e eficazes se enviadas para as últimas moradas conhecidas pelas Partes.
        </Text>

        <Text style={s.paragraph}>
          Para qualquer questão emergente do presente contracto, mormente da sua celebração, execução ou cessação, as Partes nomeiam como competente o Foro da Comarca de {emp.foro || im.concelho || ''} da situação do Imóvel, com expressa renúncia a qualquer outro.
        </Text>

        {/* ==================== CLÁUSULA DÉCIMA PRIMEIRA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA DÉCIMA PRIMEIRA</Text>
        <Text style={s.clauseSubtitle}>(Referências)</Text>

        <Text style={s.paragraph}>
          No presente contrato, onde apenas se mencione o &quot;locado&quot; ou o &quot;imóvel&quot;, deverá entender-se que nestes conceitos se inclui o quarto, dado de arrendamento ao Segundo Outorgante.
        </Text>

        {/* ==================== CLÁUSULA DÉCIMA SEGUNDA ==================== */}
        <Text style={s.clauseTitle}>CLÁUSULA DÉCIMA SEGUNDA</Text>
        <Text style={s.clauseSubtitle}>(Direito de Preferência)</Text>

        <Text style={s.paragraph}>
          O Segundo Outorgante declara expressamente que renuncia ao direito de preferência na compra, venda ou dação em pagamento do Imóvel, na sua totalidade, seja qual for o valor ou demais condições da transmissão proposta.
        </Text>

        {/* ==================== SIGNATURE ==================== */}
        <View style={s.signatureSection} wrap={false}>
          <Text style={s.paragraph}>
            Feito em {c.localAssinatura || ''}, aos dias {formatDatePT(c.dataAssinatura)}, em duplicado, ficando um exemplar na posse de cada uma das partes.
          </Text>

          <View style={s.signatureBlock}>
            <Text style={s.signatureLabel}>A PRIMEIRA OUTORGANTE:</Text>
            <View style={s.signatureDash} />
          </View>

          <View style={s.signatureBlock}>
            <Text style={s.signatureLabel}>{segundoOutorganteLabel(c.genero)}:</Text>
            <View style={s.signatureDash} />
          </View>
        </View>
      </Page>

      {/* ==================== ANEXO ==================== */}
      {fr.numeroAnexo && (
        <Page size="A4" style={s.page}>
          <Text style={s.anexoTitle}>Anexo {fr.numeroAnexo}</Text>
        </Page>
      )}
    </Document>
  )
}

// ---------- API Route ----------

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Não autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:ver')

    const id = req.nextUrl.searchParams.get('id')
    if (!id) return Response.json({ error: 'Parâmetro id em falta' }, { status: 400 })

    const contrato = await prisma.contrato.findUnique({
      where: { id },
      include: {
        fracao: {
          include: {
            imovel: {
              include: {
                fracoes: { select: { id: true } },
              },
            },
          },
        },
      },
    })

    if (!contrato) return Response.json({ error: 'Contrato não encontrado' }, { status: 404 })

    // Load empresa configs
    const configRows = await prisma.configuracao.findMany()
    const configs: Record<string, string> = {}
    for (const r of configRows) configs[r.chave] = r.valor

    const empresa: Empresa = {
      nome: cfg(configs, 'empresa_nome', 'Empresa'),
      formaJuridica: cfg(configs, 'empresa_forma_juridica', 'Lda.'),
      morada: cfg(configs, 'empresa_morada', ''),
      nipc: cfg(configs, 'empresa_nipc', ''),
      conservatoria: cfg(configs, 'empresa_conservatoria', ''),
      foro: cfg(configs, 'empresa_foro', ''),
      limiteElectricidade: cfg(configs, 'limite_electricidade', '0'),
    }

    const contractBuffer = await renderToBuffer(
      <ContratoPDF contrato={contrato as unknown as ContratoData} empresa={empresa} />
    )

    // Merge com planta do imóvel (se existir)
    let finalBuffer: Uint8Array
    const plantaPath = contrato.fracao?.imovel?.plantaPath
      ? join(process.cwd(), contrato.fracao.imovel.plantaPath)
      : null

    if (plantaPath && existsSync(plantaPath) && plantaPath.endsWith('.pdf')) {
      // Merge contrato + planta PDF
      const contractPdf = await PDFDocument.load(contractBuffer)
      const plantaPdf = await PDFDocument.load(readFileSync(plantaPath))
      const pages = await contractPdf.copyPages(plantaPdf, plantaPdf.getPageIndices())
      for (const page of pages) contractPdf.addPage(page)
      const merged = await contractPdf.save()
      finalBuffer = new Uint8Array(merged)
    } else {
      finalBuffer = new Uint8Array(contractBuffer)
    }

    // Guardar cópia local
    const contractsDir = join(process.cwd(), 'uploads', 'contratos')
    try { mkdirSync(contractsDir, { recursive: true }) } catch { /* */ }
    const safeName = contrato.nomeInquilino.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_-]/g, '')
    const localFilename = `${contrato.id}_${safeName}.pdf`
    const localPath = join(contractsDir, localFilename)
    writeFileSync(localPath, finalBuffer)

    // Guardar path na DB
    await prisma.contrato.update({
      where: { id: contrato.id },
      data: { contratoPdfPath: `uploads/contratos/${localFilename}` },
    })

    const filename = `Contrato_${contrato.nomeInquilino.replace(/\s+/g, '_')}.pdf`

    return new Response(finalBuffer as unknown as BodyInit, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'Content-Length': String(finalBuffer.length),
      },
    })
  } catch (e) {
    console.error('[contratos/pdf] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) {
      return Response.json({ error: (e as Error).message }, { status: 403 })
    }
    return Response.json({ error: 'Erro ao gerar PDF', details: String(e) }, { status: 500 })
  }
}
