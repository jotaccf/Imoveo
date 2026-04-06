import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import { renderToBuffer, Document, Page, Text, View, StyleSheet } from '@react-pdf/renderer'

// ---------- helpers ----------

const MESES_PT = [
  'Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho',
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
  page: { padding: 40, fontSize: 10, fontFamily: 'Helvetica', color: '#0D1B1A' },
  title: { fontSize: 14, fontFamily: 'Helvetica-Bold', textAlign: 'center', marginBottom: 20 },
  clauseTitle: { fontSize: 11, fontFamily: 'Helvetica-Bold', marginTop: 14, marginBottom: 6 },
  paragraph: { textAlign: 'justify', marginBottom: 6, lineHeight: 1.5 },
  signatureSection: { marginTop: 40 },
  signatureLine: { marginTop: 30, flexDirection: 'row', justifyContent: 'space-between' },
  signatureBlock: { width: '45%', alignItems: 'center' },
  signatureLabel: { fontSize: 10, fontFamily: 'Helvetica-Bold', marginBottom: 4 },
  signatureDash: { width: '100%', borderBottom: '1px solid #0D1B1A', marginTop: 40 },
  anexoTitle: { fontSize: 14, fontFamily: 'Helvetica-Bold', textAlign: 'center', marginTop: 30 },
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
    'Viuvo': ['Viuvo', 'Viuva'],
    'Uniao de Facto': ['em Uniao de Facto', 'em Uniao de Facto'],
  }
  const pair = map[estadoCivil]
  return pair ? pair[fem ? 1 : 0] : estadoCivil
}

function tipoDocumentoLabel(tipo: string | null): string {
  if (tipo === 'CC') return 'Cartao de Cidadao'
  if (tipo === 'Passaporte') return 'Passaporte'
  if (tipo === 'Titulo de Residencia') return 'Titulo de Residencia'
  return tipo || 'documento de identificacao'
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

// ---------- PDF Component ----------

function ContratoPDF({ contrato: c, empresa: emp }: { contrato: ContratoData; empresa: Empresa }) {
  const im = c.fracao.imovel
  const fr = c.fracao
  const totalQuartos = im.fracoes.length

  // Build morada text for segundo outorgante
  const moradaText = c.usarMoradaImovel
    ? `residente durante a vigencia do presente contrato na ${im.morada || im.localizacao}`
    : `residente na ${c.moradaInquilino || ''}`

  // Build considerando 1
  let considerando1 = `A Primeira Outorgante e arrendataria da fracao autonoma designada pela letra "${im.fracaoAutonoma || ''}", correspondente ao ${im.andar || ''}, do predio sito na ${im.morada || im.localizacao}, freguesia de ${im.freguesia || ''}, concelho de ${im.concelho || ''}, inscrito na respetiva matriz predial urbana sob o artigo ${im.artigoMatricial || ''}`

  if (im.descricaoRP) {
    considerando1 += ` e descrito na Conservatoria do Registo Predial de ${im.concelho || ''} sob o n.o ${im.descricaoRP}`
  }
  if (im.licencaUtilizacao) {
    considerando1 += `, com autorizacao de utilizacao n.o ${im.licencaUtilizacao}, emitida pela ${im.entidadeLicenca || ''} a ${im.dataLicenca || ''}`
  }

  // Proprietarios
  if (im.incluirProprietarios && im.nomeProprietario1) {
    considerando1 += `, com os donos e legitimos proprietarios da referida fracao, ${im.nomeProprietario1}, portador do cartao de cidadao n.o ${im.ccProprietario1 || ''}, NIF ${im.nifProprietario || ''}`
    if (im.nomeProprietario2) {
      considerando1 += ` e ${im.nomeProprietario2}, portador(a) do cartao de cidadao n.o ${im.ccProprietario2 || ''}, NIF ${im.nifProprietario2 || ''}, casados entre si no regime de ${im.regimeCasamento || ''}`
    }
    if (im.moradaProprietarios) {
      considerando1 += `, ambos residentes na ${im.moradaProprietarios}`
    }
  }

  if (im.dataContratoArrendamento) {
    considerando1 += `, por efeito de contrato de arrendamento outorgado na data de ${formatDatePT(im.dataContratoArrendamento)}`
  }

  considerando1 += '.'

  // Segundo outorgante text
  let segundoOutorgante = `${c.nomeInquilino}`
  if (c.nifInquilino) segundoOutorgante += `, NIF ${c.nifInquilino}`
  segundoOutorgante += `, ${estadoCivilGendered(c.estadoCivil, c.genero)}`
  if (c.naturalidade) segundoOutorgante += `, Natural de ${c.naturalidade}`
  segundoOutorgante += `, ${portador(c.genero)} do ${tipoDocumentoLabel(c.tipoDocumento)} n.o ${c.numDocumento || ''}`
  if (c.validadeDocumento) segundoOutorgante += ` valido ate ${formatDatePT(c.validadeDocumento)}`
  segundoOutorgante += `, ${moradaText}`

  // Clausula 3 - vigencia
  const vigenciaBase = `Pelo presente contrato, a Primeira Outorgante subarrenda ao Segundo Outorgante e este toma de subarrendamento o quarto identificado na clausula anterior, pelo prazo de ${c.periodoRenovacao} meses, com inicio em ${formatDatePT(c.dataInicio)} e termo em ${formatDatePT(c.dataFim)}`
  let vigenciaRenovacao: string
  if (c.renovacaoAuto) {
    vigenciaRenovacao = `, renovando-se automaticamente no seu termo por periodos sucessivos de ${c.periodoRenovacao} meses, caso nenhuma das partes se oponha a renovacao mediante comunicacao escrita enviada com a antecedencia minima de 120 (cento e vinte) dias em relacao ao termo do contrato ou da sua renovacao.`
  } else {
    vigenciaRenovacao = ', nao renovavel.'
  }

  // Clausula 4 - renda
  const valorRenda = formatCurrency(c.valorRenda)
  let clausula4 = `A renda mensal e de EUR ${valorRenda} (${valorRenda} euros), devida no primeiro dia util de cada mes, e paga por transferencia bancaria para a conta indicada pela Primeira Outorgante.`
  clausula4 += `\n\nO comprovativo de pagamento devera ser enviado para o seguinte endereco de correio eletronico: ${c.contacto || ''}.`
  clausula4 += `\n\nA falta de pagamento da renda, no todo ou em parte, por periodo superior a 8 (oito) dias apos a data do seu vencimento, constitui o Segundo Outorgante em mora, sendo devidos juros legais sobre o montante em divida, acrescidos de uma indemnizacao igual a 50% do valor devido.`
  if (im.incluirSubtracaoCaucao) {
    clausula4 += ` A Primeira Outorgante reserva-se o direito de poder subtrair o valor da indemnizacao ao deposito de garantia.`
  }

  // Clausula 5 - caucao
  const valorCaucao = formatCurrency(c.caucao)

  // Clausula 6 - despesas
  let clausula6: string
  if (im.modeloDespesas === 'INDIVIDUAL') {
    clausula6 = `Os encargos relativos ao consumo de agua, eletricidade, gas e internet serao repartidos entre os subarrendatarios do imovel da seguinte forma:\n\n`
    clausula6 += `a) Os consumos individuais apurados por contador ou medidor proprio serao imputados diretamente ao respetivo subarrendatario;\n\n`
    clausula6 += `b) Os consumos das areas comuns (cozinha, sala, corredores e instalacoes sanitarias comuns) serao divididos em partes iguais por todos os subarrendatarios com contrato em vigor no periodo de faturacao;\n\n`
    clausula6 += `c) A Primeira Outorgante comunicara mensalmente ao Segundo Outorgante o valor dos consumos a pagar, devendo o pagamento ser efetuado conjuntamente com a renda do mes seguinte ao da comunicacao;\n\n`
    clausula6 += `d) O Segundo Outorgante tem o direito de solicitar a consulta das faturas originais dos fornecedores de servicos.`
  } else {
    clausula6 = `Os encargos relativos ao consumo de agua, eletricidade, gas e internet encontram-se incluidos no valor da renda mensal, ate ao limite de ${emp.limiteElectricidade}EUR.`
    clausula6 += `\n\nCaso os consumos excedam o limite referido, o valor excedente sera repartido em partes iguais por todos os subarrendatarios com contrato em vigor no periodo de faturacao, devendo o pagamento ser efetuado conjuntamente com a renda do mes seguinte ao da comunicacao do valor apurado.`
  }

  return (
    <Document>
      <Page size="A4" style={s.page}>
        {/* HEADER */}
        <Text style={s.title}>CONTRATO DE SUBARRENDAMENTO PARA FINS HABITACIONAIS COM PRAZO CERTO</Text>

        {/* PARTIES */}
        <Text style={s.paragraph}>
          PRIMEIRA OUTORGANTE: {emp.nome}, {emp.formaJuridica}, com sede na {emp.morada}, matriculada na {emp.conservatoria} sob o numero unico de matricula e NIPC {emp.nipc}, adiante {designado(null)} por Primeira Outorgante.
        </Text>
        <Text style={s.paragraph}>
          SEGUNDO OUTORGANTE: {segundoOutorgante}, adiante {designado(c.genero)} por Segundo Outorgante.
        </Text>

        {/* CONSIDERANDOS */}
        <Text style={s.clauseTitle}>CONSIDERANDOS</Text>
        <Text style={s.paragraph}>
          Paragrafo 1.o - {considerando1}
        </Text>
        <Text style={s.paragraph}>
          Paragrafo 2.o - A Primeira Outorgante se encontra devidamente autorizada, pelos donos e legitimos proprietarios identificados no considerando anterior, a celebrar contratos de subarrendamento.
        </Text>

        {/* CLAUSULA 1 */}
        <Text style={s.clauseTitle}>CLAUSULA 1.a (Identificacao do Imovel)</Text>
        <Text style={s.paragraph}>
          No imovel identificado no considerando Paragrafo 1.o, composto por {totalQuartos} quartos, encontram-se os seguintes eletrodomesticos e equipamentos: {im.equipamentos || 'N/A'}.
        </Text>

        {/* CLAUSULA 2 */}
        <Text style={s.clauseTitle}>CLAUSULA 2.a (Objeto)</Text>
        <Text style={s.paragraph}>
          A Primeira Outorgante subarrenda ao Segundo Outorgante, que aceita, um quarto no imovel identificado na clausula anterior, identificado pela Letra {fr.letraQuarto || ''}, com serventia de casa de banho {fr.casaBanho === 'Privativa' ? 'privativa, ' : ''}cozinha e sala de refeicoes comuns, conforme descrito no ANEXO {fr.numeroAnexo || 'I'}.
        </Text>
        <Text style={s.paragraph}>
          O mencionado quarto e entregue ao Segundo Outorgante mobilado com {fr.mobilia || 'N/A'}.
        </Text>

        {/* CLAUSULA 3 */}
        <Text style={s.clauseTitle}>CLAUSULA 3.a (Vigencia)</Text>
        <Text style={s.paragraph}>
          {vigenciaBase}{vigenciaRenovacao}
        </Text>
        <Text style={s.paragraph}>
          O Segundo Outorgante podera denunciar o presente contrato mediante comunicacao escrita enviada com a antecedencia minima de 120 (cento e vinte) dias em relacao a data em que pretenda a cessacao, sob pena de ficar obrigado ao pagamento das rendas correspondentes ao periodo de pre-aviso em falta.
        </Text>
        <Text style={s.paragraph}>
          A Primeira Outorgante podera opor-se a renovacao do contrato mediante comunicacao escrita enviada com a antecedencia minima de 240 (duzentos e quarenta) dias, quando o contrato tenha durado ate 3 anos, ou de 120 dias, quando tenha durado mais de 3 anos.
        </Text>

        {/* CLAUSULA 4 */}
        <Text style={s.clauseTitle}>CLAUSULA 4.a (Renda)</Text>
        <Text style={s.paragraph}>
          {clausula4}
        </Text>

        {/* CLAUSULA 5 */}
        <Text style={s.clauseTitle}>CLAUSULA 5.a (Caucao)</Text>
        <Text style={s.paragraph}>
          A titulo de deposito de garantia, o Segundo Outorgante entrega a Primeira Outorgante, na data de assinatura do presente contrato, o montante de EUR {valorCaucao} (caucao), correspondente ao valor de uma renda mensal.
        </Text>
        <Text style={s.paragraph}>
          O referido deposito destina-se a garantir o cumprimento de todas as obrigacoes do Segundo Outorgante emergentes do presente contrato, nomeadamente o pagamento de rendas, encargos, ou a reparacao de quaisquer danos causados no imovel ou no seu recheio.
        </Text>
        <Text style={s.paragraph}>
          O deposito de garantia sera devolvido ao Segundo Outorgante apos a cessacao do contrato e a entrega do imovel nas condicoes em que foi recebido, deduzido de quaisquer valores devidos.
        </Text>
      </Page>

      <Page size="A4" style={s.page}>
        {/* CLAUSULA 6 */}
        <Text style={s.clauseTitle}>CLAUSULA 6.a (Despesas)</Text>
        <Text style={s.paragraph}>
          {clausula6}
        </Text>

        {/* CLAUSULA 7 */}
        <Text style={s.clauseTitle}>CLAUSULA 7.a (Estado do Imovel e Obras)</Text>
        <Text style={s.paragraph}>
          O Segundo Outorgante declara ter visitado o imovel e o quarto que lhe e subarrendado, conhecendo o seu estado de conservacao, que aceita como bom e adequado ao fim a que se destina.
        </Text>
        <Text style={s.paragraph}>
          E vedado ao Segundo Outorgante realizar quaisquer obras ou alteracoes no imovel sem o previo consentimento escrito da Primeira Outorgante, sob pena de resolucao do contrato.
        </Text>

        {/* CLAUSULA 8 */}
        <Text style={s.clauseTitle}>CLAUSULA 8.a (Obrigacoes do Segundo Outorgante)</Text>
        <Text style={s.paragraph}>
          O Segundo Outorgante obriga-se a:{'\n'}
          a) Utilizar o quarto e as areas comuns exclusivamente para fins habitacionais;{'\n'}
          b) Nao ceder, total ou parcialmente, a sua posicao contratual, nem sublocar o quarto, no todo ou em parte;{'\n'}
          c) Manter o quarto e as areas comuns em bom estado de conservacao e limpeza;{'\n'}
          d) Respeitar o regulamento interno do imovel, caso exista, e as regras de convivencia com os demais habitantes;{'\n'}
          e) Nao perturbar o descanso dos vizinhos e demais moradores do imovel;{'\n'}
          f) Comunicar de imediato a Primeira Outorgante quaisquer danos ou avarias no imovel;{'\n'}
          g) Permitir a visita da Primeira Outorgante ao imovel, mediante aviso previo, para vistoria do estado de conservacao;{'\n'}
          h) Entregar o quarto no estado em que o recebeu, salvo o desgaste normal decorrente do uso prudente.
        </Text>

        {/* CLAUSULA 9 */}
        <Text style={s.clauseTitle}>CLAUSULA 9.a (Resolucao)</Text>
        <Text style={s.paragraph}>
          Constituem fundamento de resolucao do contrato pela Primeira Outorgante, para alem dos previstos na lei:{'\n'}
          a) A falta de pagamento da renda por periodo superior a 2 (dois) meses;{'\n'}
          b) A utilizacao do imovel para fim diverso do estipulado;{'\n'}
          c) A realizacao de obras nao autorizadas;{'\n'}
          d) A cedencia ou sublocacao, total ou parcial, nao autorizada;{'\n'}
          e) A pratica de atos que perturbem a normal utilizacao do imovel pelos demais moradores;{'\n'}
          f) O incumprimento reiterado de qualquer obrigacao prevista no presente contrato.
        </Text>

        {/* CLAUSULA 10 */}
        <Text style={s.clauseTitle}>CLAUSULA 10.a (Comunicacoes e Foro)</Text>
        <Text style={s.paragraph}>
          Todas as comunicacoes entre as partes serao efetuadas por escrito, por carta registada com aviso de rececao, ou por correio eletronico com confirmacao de leitura, para os enderecos indicados no presente contrato.
        </Text>
        <Text style={s.paragraph}>
          Para a resolucao de quaisquer litigios emergentes do presente contrato, as partes elegem o foro da comarca de {emp.foro || im.concelho || ''}, com expressa renuncia a qualquer outro.
        </Text>

        {/* CLAUSULA 11 */}
        <Text style={s.clauseTitle}>CLAUSULA 11.a (Referencias Legais)</Text>
        <Text style={s.paragraph}>
          Em tudo o que nao estiver expressamente previsto no presente contrato, aplicam-se as disposicoes do Codigo Civil e do Novo Regime do Arrendamento Urbano (NRAU), aprovado pela Lei n.o 6/2006, de 27 de fevereiro, com as suas sucessivas alteracoes.
        </Text>

        {/* CLAUSULA 12 */}
        <Text style={s.clauseTitle}>CLAUSULA 12.a (Direito de Preferencia)</Text>
        <Text style={s.paragraph}>
          Em caso de venda ou dacao em cumprimento do imovel subarrendado, o Segundo Outorgante goza de direito de preferencia nos termos previstos no artigo 1091.o do Codigo Civil, devendo a Primeira Outorgante comunicar-lhe o projeto de venda e as respetivas condicoes, por carta registada com aviso de rececao, dispondo o Segundo Outorgante do prazo legal para exercer o seu direito.
        </Text>

        {/* ASSINATURA */}
        <View style={s.signatureSection}>
          <Text style={s.paragraph}>
            Feito em {c.localAssinatura || ''}, aos dias {formatDatePT(c.dataAssinatura)}, em duplicado, ficando cada uma das partes com um exemplar.
          </Text>
          <View style={s.signatureLine}>
            <View style={s.signatureBlock}>
              <Text style={s.signatureLabel}>A PRIMEIRA OUTORGANTE</Text>
              <View style={s.signatureDash} />
            </View>
            <View style={s.signatureBlock}>
              <Text style={s.signatureLabel}>{segundoOutorganteLabel(c.genero)}</Text>
              <View style={s.signatureDash} />
            </View>
          </View>
        </View>
      </Page>

      {/* ANEXO */}
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
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'imoveis:ver')

    const id = req.nextUrl.searchParams.get('id')
    if (!id) return Response.json({ error: 'Parametro id em falta' }, { status: 400 })

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

    if (!contrato) return Response.json({ error: 'Contrato nao encontrado' }, { status: 404 })

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

    const buffer = await renderToBuffer(
      <ContratoPDF contrato={contrato as unknown as ContratoData} empresa={empresa} />
    )
    const uint8 = new Uint8Array(buffer)

    const filename = `Contrato_${contrato.nomeInquilino.replace(/\s+/g, '_')}.pdf`

    return new Response(uint8, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'Content-Length': String(buffer.length),
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
