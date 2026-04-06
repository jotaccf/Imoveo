--
-- PostgreSQL database dump
--

\restrict fHwJw9kpTgjEa2vTUA5t2uWzQnppzqxBwI0jMHsI9MzcZNDhmOSoLpS15DUdLAC

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: EstadoFracao; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."EstadoFracao" AS ENUM (
    'OCUPADO',
    'VAGO',
    'EM_OBRAS'
);


ALTER TYPE public."EstadoFracao" OWNER TO imoveo;

--
-- Name: EstadoImovel; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."EstadoImovel" AS ENUM (
    'ACTIVO',
    'VAGO',
    'EM_OBRAS',
    'INACTIVO'
);


ALTER TYPE public."EstadoImovel" OWNER TO imoveo;

--
-- Name: OrigemClassificacao; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."OrigemClassificacao" AS ENUM (
    'AUTOMATICA',
    'MANUAL'
);


ALTER TYPE public."OrigemClassificacao" OWNER TO imoveo;

--
-- Name: Periodicidade; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."Periodicidade" AS ENUM (
    'MENSAL',
    'TRIMESTRAL',
    'ANUAL'
);


ALTER TYPE public."Periodicidade" OWNER TO imoveo;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."Role" AS ENUM (
    'ADMIN',
    'GESTOR',
    'OPERADOR'
);


ALTER TYPE public."Role" OWNER TO imoveo;

--
-- Name: TipoDocManual; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."TipoDocManual" AS ENUM (
    'RECIBO_VERDE',
    'CONTRATO_RENDA',
    'FATURA_PAPEL',
    'OUTRO'
);


ALTER TYPE public."TipoDocManual" OWNER TO imoveo;

--
-- Name: TipoEntidade; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."TipoEntidade" AS ENUM (
    'FORNECEDOR',
    'INQUILINO',
    'PROPRIETARIO',
    'OUTRO'
);


ALTER TYPE public."TipoEntidade" OWNER TO imoveo;

--
-- Name: TipoFicheiro; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."TipoFicheiro" AS ENUM (
    'EMITIDAS',
    'RECEBIDAS'
);


ALTER TYPE public."TipoFicheiro" OWNER TO imoveo;

--
-- Name: TipoImovel; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."TipoImovel" AS ENUM (
    'APARTAMENTO',
    'MORADIA',
    'LOJA',
    'ESCRITORIO',
    'OUTRO',
    'GERAL',
    'PESSOAL'
);


ALTER TYPE public."TipoImovel" OWNER TO imoveo;

--
-- Name: TipoRubrica; Type: TYPE; Schema: public; Owner: imoveo
--

CREATE TYPE public."TipoRubrica" AS ENUM (
    'RECEITA',
    'GASTO'
);


ALTER TYPE public."TipoRubrica" OWNER TO imoveo;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO imoveo;

--
-- Name: configuracoes; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.configuracoes (
    id text NOT NULL,
    chave text NOT NULL,
    valor text NOT NULL
);


ALTER TABLE public.configuracoes OWNER TO imoveo;

--
-- Name: entidades; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.entidades (
    id text NOT NULL,
    nif text NOT NULL,
    nome text NOT NULL,
    tipo public."TipoEntidade" DEFAULT 'FORNECEDOR'::public."TipoEntidade" NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.entidades OWNER TO imoveo;

--
-- Name: fatura_classificacao; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.fatura_classificacao (
    id text NOT NULL,
    "faturaId" text NOT NULL,
    "imovelId" text NOT NULL,
    "rubricaId" text NOT NULL,
    origem public."OrigemClassificacao" DEFAULT 'AUTOMATICA'::public."OrigemClassificacao" NOT NULL,
    confirmado boolean DEFAULT false NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "atualizadoEm" timestamp(3) without time zone NOT NULL,
    "fracaoId" text
);


ALTER TABLE public.fatura_classificacao OWNER TO imoveo;

--
-- Name: faturas; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.faturas (
    id text NOT NULL,
    "hashFatura" text NOT NULL,
    "nifEmitente" text NOT NULL,
    "serieDoc" text NOT NULL,
    "numeroDoc" text NOT NULL,
    "nifDestinatario" text,
    "nomeEmitente" text,
    "dataFatura" timestamp(3) without time zone NOT NULL,
    "totalSemIva" numeric(12,2) NOT NULL,
    "totalIva" numeric(12,2) NOT NULL,
    "totalComIva" numeric(12,2) NOT NULL,
    "tipoDocumento" text,
    "importacaoId" text NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.faturas OWNER TO imoveo;

--
-- Name: fracoes; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.fracoes (
    id text NOT NULL,
    "imovelId" text NOT NULL,
    nome text NOT NULL,
    renda numeric(12,2) NOT NULL,
    "nifInquilino" text,
    estado public."EstadoFracao" DEFAULT 'VAGO'::public."EstadoFracao" NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "atualizadoEm" timestamp(3) without time zone NOT NULL,
    "dataEntradaMercado" timestamp(3) without time zone
);


ALTER TABLE public.fracoes OWNER TO imoveo;

--
-- Name: imoveis; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.imoveis (
    id text NOT NULL,
    codigo text NOT NULL,
    nome text NOT NULL,
    tipo public."TipoImovel" NOT NULL,
    morada text,
    localizacao text NOT NULL,
    "nifProprietario" text,
    estado public."EstadoImovel" DEFAULT 'ACTIVO'::public."EstadoImovel" NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "atualizadoEm" timestamp(3) without time zone NOT NULL,
    "areaMt2" numeric(8,2),
    "valorPatrimonial" numeric(12,2),
    ordem integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.imoveis OWNER TO imoveo;

--
-- Name: importacoes; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.importacoes (
    id text NOT NULL,
    filename text NOT NULL,
    "hashFicheiro" text NOT NULL,
    periodo text NOT NULL,
    "tipoFicheiro" public."TipoFicheiro" NOT NULL,
    "totalFaturas" integer DEFAULT 0 NOT NULL,
    novas integer DEFAULT 0 NOT NULL,
    duplicadas integer DEFAULT 0 NOT NULL,
    pendentes integer DEFAULT 0 NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.importacoes OWNER TO imoveo;

--
-- Name: lancamentos_manuais; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.lancamentos_manuais (
    id text NOT NULL,
    "tipoDoc" public."TipoDocManual" DEFAULT 'RECIBO_VERDE'::public."TipoDocManual" NOT NULL,
    "numeroDoc" text,
    fornecedor text NOT NULL,
    "nifFornecedor" text,
    "imovelId" text NOT NULL,
    "rubricaId" text NOT NULL,
    "dataDoc" timestamp(3) without time zone NOT NULL,
    "valorSemIva" numeric(12,2) NOT NULL,
    "taxaIva" integer DEFAULT 0 NOT NULL,
    "totalComIva" numeric(12,2) NOT NULL,
    recorrente boolean DEFAULT false NOT NULL,
    periodicidade public."Periodicidade",
    "dataFim" timestamp(3) without time zone,
    notas text,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "atualizadoEm" timestamp(3) without time zone NOT NULL,
    "fracaoId" text,
    "retencaoFonte" integer DEFAULT 0 NOT NULL,
    "valorRetencao" numeric(12,2)
);


ALTER TABLE public.lancamentos_manuais OWNER TO imoveo;

--
-- Name: nif_imovel_map; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.nif_imovel_map (
    id text NOT NULL,
    "nifEntidade" text NOT NULL,
    "imovelId" text NOT NULL,
    "rubricaId" text NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "fracaoId" text
);


ALTER TABLE public.nif_imovel_map OWNER TO imoveo;

--
-- Name: rubricas; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.rubricas (
    id text NOT NULL,
    codigo text NOT NULL,
    nome text NOT NULL,
    tipo public."TipoRubrica" DEFAULT 'GASTO'::public."TipoRubrica" NOT NULL,
    ordem integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.rubricas OWNER TO imoveo;

--
-- Name: utilizadores; Type: TABLE; Schema: public; Owner: imoveo
--

CREATE TABLE public.utilizadores (
    id text NOT NULL,
    nome text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    role public."Role" DEFAULT 'OPERADOR'::public."Role" NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    "criadoEm" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "atualizadoEm" timestamp(3) without time zone NOT NULL,
    "ultimoLogin" timestamp(3) without time zone
);


ALTER TABLE public.utilizadores OWNER TO imoveo;

--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
48b7e498-99f5-4ce6-aa31-88d1b6cbaefa	7c42fed20d06e988540acc928794baa0ad5613b9eb7c13c7b10fe3c318fb35cb	2026-04-01 01:23:33.026732+00	20260401012332_init	\N	\N	2026-04-01 01:23:32.831388+00	1
77376d51-a311-426c-806c-130388d59bd3	a138e48ff16ccf6ef986e531111d1d22af548bc1532df46bdf7e23b13936a382	2026-04-01 02:38:52.011388+00	20260401023851_add_centros_custo	\N	\N	2026-04-01 02:38:51.984298+00	1
91de5f30-a2e1-4510-b0f2-ea6aebecb32e	a5101a428cba54b5c5efd9aa8500c8f341d787751e07266b6eb0454eeaca2bec	2026-04-01 03:36:07.637086+00	20260401033607_add_fracoes	\N	\N	2026-04-01 03:36:07.570963+00	1
8ec85dae-e5f4-4237-be08-2845c3fba376	9589db6e3b9746249cb7abfb79ae193138f2992715f516256578f5d030966241	2026-04-01 04:07:51.05041+00	20260401040751_add_config_valor_patrimonial	\N	\N	2026-04-01 04:07:51.010765+00	1
8b7e73c0-b986-4304-827e-6ae967033c6e	9485370daf5ada54b5f713ee194823eaa4985ba075da032a306e3b8b24715c13	2026-04-01 12:10:08.972902+00	20260401121008_add_retencao_fonte	\N	\N	2026-04-01 12:10:08.958855+00	1
ca1e1a11-ef8a-4da2-9051-fa1b62111120	14bf124561d6d370aaffb0aae93408e870444e63a848f182616eb36b466f6808	2026-04-02 17:07:06.056959+00	20260402170706_add_data_entrada_mercado	\N	\N	2026-04-02 17:07:06.039345+00	1
6461e519-0f67-46d9-95dd-325922537733	c77de607031b97eba7163c00be34076a8a28b0de57c3a1af33b086162660f400	2026-04-05 03:05:20.182597+00	20260405030520_add_ordem_imovel	\N	\N	2026-04-05 03:05:20.172502+00	1
\.


--
-- Data for Name: configuracoes; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.configuracoes (id, chave, valor) FROM stdin;
cmng28lbi002drkt46psnq47k	derramaMunicipal	1
cmng28lc4002erkt4qf91bmsg	regimePME	true
cmng28lc8002frkt43io8n8kr	taxaIrcPME	17
cmng28lcc002grkt4af24egy8	taxaIrcNormal	21
cmng28lcg002hrkt4kwqci7b8	limitePME	50000
cmng28lck002irkt4f92lq3fk	taxaRetencaoRendas	25
cmnfizrmq0000y8t43wxrpa2u	derrama_municipal	1.5
cmnfizrn80001y8t4esnfi5lg	regime_pme	true
cmnfizrnk0002y8t4h3j0myac	taxa_irc_pme	17
cmnfizrnt0003y8t4bp9fg3t3	taxa_irc_normal	21
cmnfizro10004y8t42odm0hy7	limite_pme	50000
cmnfizro70005y8t4l75w5dxl	taxa_retencao_rendas	25
cmnfizroe0006y8t49w2c3vf9	exercicio_inicio	01
cmnfizrok0007y8t4vnpg2dtx	exercicio_fim	12
\.


--
-- Data for Name: entidades; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.entidades (id, nif, nome, tipo, "criadoEm") FROM stdin;
cmnflek8201pshgt4wyeacfv0	261849450	261849450	INQUILINO	2026-04-01 05:15:47.81
cmnflezac01q0hgt46vlh4hgn	264947800	264947800	INQUILINO	2026-04-01 05:16:07.332
cmnflfdtb01q8hgt4ryrv7gey	274734338	274734338	INQUILINO	2026-04-01 05:16:26.159
cmnflfs5301qghgt4xbauuzyj	261803310	261803310	INQUILINO	2026-04-01 05:16:44.727
cmnflg4rv01qvhgt4cwnnuqdl	255364962	255364962	INQUILINO	2026-04-01 05:17:01.099
cmnflgi2u01r9hgt4o2k7vtf4	244984883	244984883	INQUILINO	2026-04-01 05:17:18.342
cmnflgtp901rnhgt4yd4ao8jn	259933015	259933015	INQUILINO	2026-04-01 05:17:33.406
cmnflh4of01rvhgt4ob9yciwm	270909028	270909028	INQUILINO	2026-04-01 05:17:47.631
cmnflhdrn01s9hgt4n1vkx22l	262961512	262961512	INQUILINO	2026-04-01 05:17:59.411
cmnflhpcl01snhgt459lszi0q	263053725	263053725	INQUILINO	2026-04-01 05:18:14.421
cmnflhyu401svhgt4rmngzhs8	266827560	266827560	INQUILINO	2026-04-01 05:18:26.716
cmnfli9bc01t3hgt4cznpanlc	266475540	266475540	INQUILINO	2026-04-01 05:18:40.296
cmnflik0o01tbhgt4ysqtgi5d	265435463	265435463	INQUILINO	2026-04-01 05:18:54.168
cmnfliulv01tjhgt4isa7c8gx	258449233	258449233	INQUILINO	2026-04-01 05:19:07.891
cmnflj5ab01tzhgt4gqun1xxs	261598619	261598619	INQUILINO	2026-04-01 05:19:21.731
cmnfljfsm01u7hgt4ez0yc5kv	261748955	261748955	INQUILINO	2026-04-01 05:19:35.35
cmnfljprh01ufhgt47tnt3sdz	260913375	260913375	INQUILINO	2026-04-01 05:19:48.269
cmnflk03g01unhgt4vnxd06g6	262305330	262305330	INQUILINO	2026-04-01 05:20:01.66
cmnflkb3o01uvhgt4djne2c7k	266588255	266588255	INQUILINO	2026-04-01 05:20:15.924
cmnflklvq01v3hgt4ty4osw2z	260754145	260754145	INQUILINO	2026-04-01 05:20:29.894
cmnflkuqk01vdhgt4lh6b8fgo	256125627	256125627	INQUILINO	2026-04-01 05:20:41.372
cmnfll5wt01vrhgt4uo24nn6s	254708528	254708528	INQUILINO	2026-04-01 05:20:55.853
cmnfllfke01vzhgt4cfrjtlf8	223482900	223482900	INQUILINO	2026-04-01 05:21:08.366
cmnfllsqx01wdhgt42659aw1s	248797239	248797239	INQUILINO	2026-04-01 05:21:25.449
cmnflm4t701wohgt4y79hinhb	252916077	252916077	INQUILINO	2026-04-01 05:21:41.083
cmnflmew301wxhgt4r695wm4f	266277055	266277055	INQUILINO	2026-04-01 05:21:54.147
cmnflmlk601x7hgt48d82eg5r	167775014	167775014	INQUILINO	2026-04-01 05:22:02.79
cmnflmvnm01xchgt4ypxauujr	253278716	253278716	INQUILINO	2026-04-01 05:22:15.874
cmnfln7xs01xkhgt4omvsx9e7	257665072	257665072	INQUILINO	2026-04-01 05:22:31.792
cmnflni0u01xuhgt42qfh2jol	259676136	259676136	INQUILINO	2026-04-01 05:22:44.862
cmnflnr6h01y3hgt4q1f5rngy	258836989	258836989	INQUILINO	2026-04-01 05:22:56.729
cmnflo07y01ychgt4pfc9qzp4	262387085	262387085	INQUILINO	2026-04-01 05:23:08.446
cmnfloarz01ykhgt452qp80lr	257675841	257675841	INQUILINO	2026-04-01 05:23:22.127
cmnfloiqg01yuhgt4k3wjdy3l	267439130	267439130	INQUILINO	2026-04-01 05:23:32.44
cmnflount01z2hgt4sfl181pi	330615254	330615254	INQUILINO	2026-04-01 05:23:47.897
cmnflp5go01z5hgt4vyh9yes2	330742213	330742213	INQUILINO	2026-04-01 05:24:01.896
cmnflpndn01z8hgt41yw6p71s	234850876	234850876	INQUILINO	2026-04-01 05:24:25.115
cmnflpx1j01zfhgt41mqg5npp	255497393	255497393	INQUILINO	2026-04-01 05:24:37.639
cmnflrokf023ahgt4sc1thujs	41317182164	41317182164	INQUILINO	2026-04-01 05:25:59.967
cmnflrzk7023fhgt4utqni7xu	323867081	323867081	INQUILINO	2026-04-01 05:26:14.215
cmnfm2htx025rhgt4m9ouekpt	503630330	Worten - Equipamentos Para o Lar S A	FORNECEDOR	2026-04-01 05:34:24.453
cmnfm2vd3025uhgt4uaeqn3m9	510450024	Ifthenpay Lda	FORNECEDOR	2026-04-01 05:34:41.991
cmnfm3615025zhgt477objmv1	502022892	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	FORNECEDOR	2026-04-01 05:34:55.817
cmnfm4cv20263hgt4vmqypotr	516222201	Digi Portugal, Lda	FORNECEDOR	2026-04-01 05:35:51.326
cmnfm4nim0267hgt4je5yhtrn	513325417	Isaura & Lopes - Supermercados Lda	FORNECEDOR	2026-04-01 05:36:05.134
cmnfm6m74026bhgt445hh0fx8	514280956	Empresa Municipal de Ambiente do Porto e M S A	FORNECEDOR	2026-04-01 05:37:36.736
cmnfm7qcn026ghgt45useb95h	516520741	Petroprix Portugal Unipessoal Lda	FORNECEDOR	2026-04-01 05:38:28.775
cmnfm88m3026jhgt4hz52sz7g	514798726	34 Restaurantes, Lda	FORNECEDOR	2026-04-01 05:38:52.443
cmnfm8lwj026mhgt4d0fi9iiz	506848558	Bcm Bricolage S A	FORNECEDOR	2026-04-01 05:39:09.667
cmnfm8v0f026thgt4b9ndqhkd	515373842	Milliwatt Lda	FORNECEDOR	2026-04-01 05:39:21.471
cmnfmav2k026xhgt480prbtfl	500393729	Pastelaria e Confeitaria Moura Herd Viuva Guilherme Ferreira Moura Lda	FORNECEDOR	2026-04-01 05:40:54.86
cmnfmb8b30270hgt4azmds7on	509520561	Alfadvice-Serviços de Engenharia Unipessoal Lda	FORNECEDOR	2026-04-01 05:41:12.015
cmng2zdnn0036rkt4jap3vh6k	518417948	Petronor Combustiveis Lda	FORNECEDOR	2026-04-01 13:27:52.547
cmng346xg003irkt447qlbxc5	502201657	Centrocor Comercio Tintas e Ferramentas Lda	FORNECEDOR	2026-04-01 13:31:37.108
cmng38kw7003qrkt4wyv2zjdi	517514419	Cardoso Carvalho & Silva Lda	FORNECEDOR	2026-04-01 13:35:01.831
cmngeo9lf00x0rkt4xzj7v2uf	516697030	Plenergy Port, Unipessoal Lda	FORNECEDOR	2026-04-01 18:55:09.459
cmngeoxm300x3rkt4hhpxa6td	507718666	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	FORNECEDOR	2026-04-01 18:55:40.587
cmngerpg200xvrkt4wxypv5sw	502075090	Arcol, S.A.	FORNECEDOR	2026-04-01 18:57:49.97
cmnges9r500y9rkt4ao0q5vh8	515337498	Rd48 Reparação e Comercio de Automoveis Unipessoal Lda	FORNECEDOR	2026-04-01 18:58:16.289
cmnho3diq00zhrkt4hb76igpq	516527835	Auchan Energy S A	FORNECEDOR	2026-04-02 16:06:37.106
cmnhq9rhl02jdrkt4mfqdosia	226804747	226804747	INQUILINO	2026-04-02 17:07:34.377
cmnhqa2sc02k8rkt4pkirya3e	516369652	516369652	INQUILINO	2026-04-02 17:07:49.02
cmnhqazt502kyrkt4tln4e4u2	251114996	251114996	INQUILINO	2026-04-02 17:08:31.817
cmnhr9tm002m1rkt4bixve6jw	251701212	251701212	INQUILINO	2026-04-02 17:35:36.744
cmnhra9ju02mfrkt4n5pkmlc5	243483627	243483627	INQUILINO	2026-04-02 17:35:57.403
cmnhrani602mtrkt4irjszr8e	249613018	249613018	INQUILINO	2026-04-02 17:36:15.486
cmnhrd2qq02n6rkt4bb972ezg	248538446	248538446	INQUILINO	2026-04-02 17:38:08.546
cmnhtjh1w00016st4i88mzwvz	264769953	264769953	INQUILINO	2026-04-02 18:39:06.26
cmnhtjtzk000f6st44iptmjde	307451348	307451348	INQUILINO	2026-04-02 18:39:23.024
cmnhtk5n9000m6st4q9gr2jyz	224974963	224974963	INQUILINO	2026-04-02 18:39:38.133
cmnhtkhkt000z6st4ubtcias7	272868906	272868906	INQUILINO	2026-04-02 18:39:53.597
cmnhtkt0h00136st4kl8n3ndv	253023548	253023548	INQUILINO	2026-04-02 18:40:08.417
cmnhtl36z00166st4l2vsf2a2	221761144	221761144	INQUILINO	2026-04-02 18:40:21.611
cmnhtlukt001g6st41mce5dlk	304817341	304817341	INQUILINO	2026-04-02 18:40:57.101
\.


--
-- Data for Name: fatura_classificacao; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.fatura_classificacao (id, "faturaId", "imovelId", "rubricaId", origem, confirmado, "criadoEm", "atualizadoEm", "fracaoId") FROM stdin;
cmnflfdsy01q7hgt4jl69r0hq	cmnfle2gx01i5hgt4t9jq8d0h	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:16:26.146	2026-04-01 05:16:26.146	cmnfkvrla010ehgt4pntoyk13
cmnflfdtr01qahgt4lwf7fz4p	cmnfle2vw01j8hgt4xjwm2sc1	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:26.175	2026-04-01 05:16:26.175	cmnfkvrla010ehgt4pntoyk13
cmnflfdtw01qbhgt4tcv657m4	cmnfle2wr01jdhgt4hdjdy46q	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:26.18	2026-04-01 05:16:26.18	cmnfkvrla010ehgt4pntoyk13
cmnflfdu001qchgt4n1cro5nf	cmnfle34u01kmhgt4wb3venkk	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:26.184	2026-04-01 05:16:26.184	cmnfkvrla010ehgt4pntoyk13
cmnflfdu401qdhgt4yv6gy2jz	cmnfle3bp01lthgt4n9eky924	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:26.188	2026-04-01 05:16:26.188	cmnfkvrla010ehgt4pntoyk13
cmnflfdu801qehgt4uj4sh7oz	cmnfle3cq01m1hgt4xqev24f3	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:26.192	2026-04-01 05:16:26.192	cmnfkvrla010ehgt4pntoyk13
cmnflk03301umhgt4gvh8j3qk	cmnfle2q901ikhgt4qq8gpio3	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:20:01.647	2026-04-01 05:20:01.647	cmnfkr0x200zvhgt4bdrsp2u0
cmnflk04001uphgt42gb14yht	cmnfle2xd01jhhgt4unmjf3cb	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:01.68	2026-04-01 05:20:01.68	cmnfkr0x200zvhgt4bdrsp2u0
cmnflk04601uqhgt4xrtmu8i2	cmnfle2vk01j6hgt4lkfmzx33	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:01.686	2026-04-01 05:20:01.686	cmnfkr0x200zvhgt4bdrsp2u0
cmnflk04b01urhgt4ljq5ctl6	cmnfle32q01k8hgt4wuh1654v	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:01.691	2026-04-01 05:20:01.691	cmnfkr0x200zvhgt4bdrsp2u0
cmnflk04g01ushgt4pcsb7zsk	cmnfle37601kzhgt4sxn3am7n	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:01.696	2026-04-01 05:20:01.696	cmnfkr0x200zvhgt4bdrsp2u0
cmnflk04k01uthgt4fadju1xu	cmnfle37d01l0hgt4jhczbzzm	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:01.7	2026-04-01 05:20:01.7	cmnfkr0x200zvhgt4bdrsp2u0
cmnfloun701z1hgt43lep07b2	cmnfle3h201myhgt444r4yn27	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:23:47.875	2026-04-01 05:23:47.875	cmnfkp2vg00zmhgt4890h7c56
cmnfm78rg026ehgt47n5flxmw	cmnfm206h023phgt4m4p5nyjq	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 05:38:05.98	2026-04-01 05:38:05.98	\N
cmnfzyhi60277hgt4csg6nf0j	cmnfm208t0240hgt4eod3lgnt	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 12:03:12.03	2026-04-01 12:03:12.03	\N
cmng346x5003hrkt4bo1vjuyo	cmnfm20c1024dhgt4homhqv1j	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 13:31:37.097	2026-04-01 13:31:37.097	\N
cmng346xy003krkt4ygyrv8jq	cmnfm206s023qhgt4xunc1euw	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:31:37.126	2026-04-01 13:31:37.126	\N
cmng346y4003lrkt4zuu4zm19	cmnfm20bh024bhgt4kcg87snv	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:31:37.132	2026-04-01 13:31:37.132	\N
cmng3bfcc00n3rkt4vc1k5i6h	cmng3bfbq00n2rkt4xmrdentz	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:37:14.604	2026-04-01 13:37:14.604	\N
cmng3bfco00n5rkt4gwdin6b8	cmng3bfcj00n4rkt4lirzbn86	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:37:14.616	2026-04-01 13:37:14.616	\N
cmng3bfcw00n7rkt4bgy5o2go	cmng3bfcr00n6rkt4zo4s42g9	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:37:14.624	2026-04-01 13:37:14.624	\N
cmng3bg1l00pyrkt4117ksmbh	cmng3bg1f00pxrkt4zpmeb3ry	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:15.513	2026-04-01 13:37:15.513	\N
cmng3bg2500q2rkt4h7949v5k	cmng3bg2100q1rkt4qfxz13yo	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:15.533	2026-04-01 13:37:15.533	\N
cmngd30v900tlrkt48f38llkn	cmng3bgbz00rarkt4ozhoxpok	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.757	2026-04-01 18:10:38.757	\N
cmngd30wm00tmrkt4pk0ik0nd	cmng3bg4m00qdrkt4ms8ne0io	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.806	2026-04-01 18:10:38.806	\N
cmngd30xu00tnrkt4aka2o1vl	cmng3bgar00r5rkt4k3kmad94	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.85	2026-04-01 18:10:38.85	\N
cmngd30zx00torkt4m3keo10r	cmng3bg5o00qhrkt4u3q73zsf	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.925	2026-04-01 18:10:38.925	\N
cmngd312b00tprkt4semmwf1c	cmng3bgd400rfrkt4ozp4ywhz	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.011	2026-04-01 18:10:39.011	\N
cmngd314800tqrkt4y09ji966	cmng3bg5400qgrkt4bcwzk3fh	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.08	2026-04-01 18:10:39.08	\N
cmngd316x00trrkt4j9rtrt1d	cmng38zw200dnrkt44yagxdra	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.177	2026-04-01 18:10:39.177	\N
cmngd318e00tsrkt4erjx1jj8	cmng38z9t00abrkt4ccs5hkp1	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.23	2026-04-01 18:10:39.23	\N
cmngd319y00ttrkt4bd6387cf	cmng38zle00c1rkt4ybucntjw	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.286	2026-04-01 18:10:39.286	\N
cmngd31b600turkt4tdsewl45	cmng38zh900bhrkt47mjgv26e	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.33	2026-04-01 18:10:39.33	\N
cmngd31cw00tvrkt4ntafcyya	cmng38zkr00byrkt4ott2upgq	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.392	2026-04-01 18:10:39.392	\N
cmngd31e900twrkt4nmu12zqs	cmng38zbb00akrkt4adj2b4wd	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.441	2026-04-01 18:10:39.441	\N
cmngd31fx00txrkt4yiqik9jd	cmng38zll00c2rkt4dsn6z9if	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.501	2026-04-01 18:10:39.501	\N
cmngd31gw00tyrkt4se2dxfds	cmng38zfl00b8rkt4nlimjus0	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.536	2026-04-01 18:10:39.536	\N
cmngd31hv00tzrkt4ztgpqkqb	cmng38zze00e7rkt4viofk9g6	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.571	2026-04-01 18:10:39.571	\N
cmngd31j900u0rkt47xju46hj	cmng38zq100crrkt4yllxdyvq	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.621	2026-04-01 18:10:39.621	\N
cmngd31kl00u1rkt4t4ubus6a	cmng38yyy008nrkt4uj6bxnzq	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.669	2026-04-01 18:10:39.669	\N
cmngd31mm00u2rkt4t7gichzc	cmng38zgv00bfrkt4osk9czbq	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.742	2026-04-01 18:10:39.742	\N
cmngd31o700u3rkt4fjt666if	cmng38zmi00c7rkt4bokqm5cx	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.799	2026-04-01 18:10:39.799	\N
cmngd31ps00u4rkt40hm9bs50	cmng38z6p009yrkt4n7pn4qvq	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.856	2026-04-01 18:10:39.856	\N
cmngd31r400u5rkt44mt58v9m	cmng3900o00eerkt4zdn85nz9	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:39.904	2026-04-01 18:10:39.904	\N
cmnge9sqa00vnrkt49jdd2e1h	cmng3bf2100m3rkt4i53uiuid	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.418	2026-04-01 18:43:54.418	\N
cmnge9ssc00vorkt48xemoyip	cmng3bg5x00qjrkt4w38x0ddx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.492	2026-04-01 18:43:54.492	\N
cmnge9su500vprkt4xuci0vrt	cmng3betw00lcrkt49wq4xbib	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.557	2026-04-01 18:43:54.557	\N
cmnflfs4t01qfhgt4eas7ccgy	cmnfle2h801i6hgt40rqll630	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:16:44.717	2026-04-01 05:16:44.717	cmnfkpkhd00zphgt4elqe9l29
cmnflfs5k01qihgt4e9kosqde	cmnfle2tp01ixhgt41e2ah3wy	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.745	2026-04-01 05:16:44.745	cmnfkpkhd00zphgt4elqe9l29
cmnflfs5r01qjhgt49yx8difz	cmnfle30n01jxhgt42f1fdioe	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.751	2026-04-01 05:16:44.751	cmnfkpkhd00zphgt4elqe9l29
cmnflfs5v01qkhgt44a3wd5ii	cmnfle35b01kphgt4kilepjuc	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.755	2026-04-01 05:16:44.755	cmnfkpkhd00zphgt4elqe9l29
cmnflfs5z01qlhgt4qzngzwfx	cmnfle3c001lvhgt4j2imahdi	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.759	2026-04-01 05:16:44.759	cmnfkpkhd00zphgt4elqe9l29
cmnflfs6401qmhgt4qf7tplt6	cmnfle3cm01m0hgt4e4w2b38t	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.764	2026-04-01 05:16:44.764	cmnfkpkhd00zphgt4elqe9l29
cmnflfs6a01qnhgt4siewv2hn	cmnfle3du01mahgt4rh2hy6rl	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.77	2026-04-01 05:16:44.77	cmnfkpkhd00zphgt4elqe9l29
cmnflfs6f01qohgt4t4fzcf5r	cmnfle3fb01mlhgt42iz60erq	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.775	2026-04-01 05:16:44.775	cmnfkpkhd00zphgt4elqe9l29
cmnflfs6k01qphgt4sg400dbe	cmnfle3hp01n3hgt4pq2j710s	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.78	2026-04-01 05:16:44.78	cmnfkpkhd00zphgt4elqe9l29
cmnflfs6p01qqhgt4herk614f	cmnfle3mc01nthgt43e6ywnai	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.785	2026-04-01 05:16:44.785	cmnfkpkhd00zphgt4elqe9l29
cmnflfs6t01qrhgt4d9do6upc	cmnfle3p801o6hgt4r6g3mnjq	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.789	2026-04-01 05:16:44.789	cmnfkpkhd00zphgt4elqe9l29
cmnflfs6y01qshgt4vovgnk7e	cmnfle3uw01oyhgt42acbpu7o	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.794	2026-04-01 05:16:44.794	cmnfkpkhd00zphgt4elqe9l29
cmnflfs7201qthgt4db2qle5f	cmnfle3yq01pmhgt4eprx4eu4	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:44.798	2026-04-01 05:16:44.798	cmnfkpkhd00zphgt4elqe9l29
cmnflkb3d01uuhgt4pinmsxl6	cmnfle2qp01ilhgt42q4aw5n9	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:20:15.913	2026-04-01 05:20:15.913	cmnfks14q00zzhgt47kj8x90e
cmnflkb4301uxhgt4wc6dst3g	cmnfle2wf01jbhgt427v9m2mw	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:15.939	2026-04-01 05:20:15.939	cmnfks14q00zzhgt47kj8x90e
cmnflkb4901uyhgt4flti8f4x	cmnfle32d01k6hgt4pfs3bafs	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:15.945	2026-04-01 05:20:15.945	cmnfks14q00zzhgt47kj8x90e
cmnflkb4d01uzhgt4vvjzx52v	cmnfle3a801ljhgt4h7malnjb	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:15.949	2026-04-01 05:20:15.949	cmnfks14q00zzhgt47kj8x90e
cmnflkb4h01v0hgt41njhn5f6	cmnfle3aj01llhgt4mmvp0lbv	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:15.953	2026-04-01 05:20:15.953	cmnfks14q00zzhgt47kj8x90e
cmnflkb4l01v1hgt4xzoi9vwe	cmnfle2zz01juhgt4r3p2jr3a	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:15.957	2026-04-01 05:20:15.957	cmnfks14q00zzhgt47kj8x90e
cmnflp5gc01z4hgt4mprjdpj8	cmnfle3jn01nghgt4ckf25fxl	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:24:01.884	2026-04-01 05:24:01.884	cmnfkpq1m00zqhgt4hjec3t2c
cmnfm7qcc026fhgt4gnpx3kjy	cmnfm20az0249hgt4xoygz9bk	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 05:38:28.764	2026-04-01 05:38:28.764	\N
cmnfzz35v0278hgt4sm1zj5ss	cmnfm20a40245hgt4r6fefmbk	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 12:03:40.099	2026-04-01 12:03:40.099	\N
cmnfzz4ys0279hgt408lqbf05	cmnfm20jn0259hgt4j9d8r28k	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 12:03:42.436	2026-04-01 12:03:42.436	\N
cmng34p8a003mrkt41hbfikdq	cmnfm205k023mhgt47cpohteu	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 13:32:00.826	2026-04-01 13:32:00.826	\N
cmng3bfg000nirkt43ju6hw7h	cmng3bffe00nhrkt48v8qvoo5	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:37:14.736	2026-04-01 13:37:14.736	\N
cmng3bg3j00q6rkt4sn8mdfle	cmng3bg2z00q5rkt4hlxv1gdl	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:15.583	2026-04-01 13:37:15.583	\N
cmng3bg3u00q8rkt4dxwby9q1	cmng3bg3o00q7rkt4f4g14hbq	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:15.594	2026-04-01 13:37:15.594	\N
cmng3bg4300qarkt41k2ktt7r	cmng3bg3y00q9rkt4y3usm6oo	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:15.603	2026-04-01 13:37:15.603	\N
cmnge54do00u6rkt4j5x1tssd	cmng3bf4j00merkt42zy9byo7	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:16.236	2026-04-01 18:40:16.236	\N
cmnge54ol00u7rkt4a14u4qxs	cmng3bfil00nprkt4mae7ic6w	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:16.629	2026-04-01 18:40:16.629	\N
cmnge54sv00u8rkt41fraldd0	cmng3bf4e00mdrkt4l0tjgx9k	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:16.783	2026-04-01 18:40:16.783	\N
cmnge54uh00u9rkt4g28lk1jm	cmng3bg6r00qmrkt4qacfztoz	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:16.841	2026-04-01 18:40:16.841	\N
cmnge54wc00uarkt4gx96qyym	cmng3bf6600mmrkt4arw8waqy	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:16.908	2026-04-01 18:40:16.908	\N
cmnge54xp00ubrkt4ej0i9sn5	cmng3bfpa00obrkt4bzijd4zu	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:16.957	2026-04-01 18:40:16.957	\N
cmnge54zk00ucrkt4ucfmzbfq	cmng3bfs500oqrkt4ogtjxz4k	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.024	2026-04-01 18:40:17.024	\N
cmnge550z00udrkt4ztqberu9	cmng3bfv000p1rkt479ffakaz	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.075	2026-04-01 18:40:17.075	\N
cmnge552900uerkt46bxna5v4	cmng3bfdj00narkt4lxv1yor8	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.121	2026-04-01 18:40:17.121	\N
cmnge553h00ufrkt4mpzi6u9x	cmng3bft100osrkt4qhjuau22	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.165	2026-04-01 18:40:17.165	\N
cmnge555800ugrkt4espa5m4q	cmng3bg0q00ptrkt4al24h362	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.228	2026-04-01 18:40:17.228	\N
cmnge556p00uhrkt4mku7sv77	cmng3bg8j00qwrkt4rf5huw28	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.281	2026-04-01 18:40:17.281	\N
cmnge558000uirkt45q59kts8	cmng3bfou00o8rkt40ol8tjvt	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.328	2026-04-01 18:40:17.328	\N
cmnge559600ujrkt4wi86d1xj	cmng3bg8b00qvrkt4tbrir32w	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.371	2026-04-01 18:40:17.371	\N
cmnge55ax00ukrkt4k55ac9wd	cmng3bfxt00pfrkt47dofyi0a	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.433	2026-04-01 18:40:17.433	\N
cmnge55c900ulrkt4nhxpntsa	cmng3bg8000qtrkt4jykfkr0s	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.481	2026-04-01 18:40:17.481	\N
cmnge55dm00umrkt40p94zane	cmng3bfzn00porkt4tpjcvk14	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.53	2026-04-01 18:40:17.53	\N
cmnge55f500unrkt44pgmwtcl	cmng3bg1100pvrkt4g7fj8m55	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.585	2026-04-01 18:40:17.585	\N
cmnflg4rj01quhgt45gpd3tvv	cmnfle2hw01i7hgt4e5mp88j4	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:17:01.088	2026-04-01 05:17:01.088	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4sc01qxhgt4mx7xmwov	cmnfle2vf01j5hgt4n9he4uag	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.116	2026-04-01 05:17:01.116	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4sh01qyhgt4z5isvj6h	cmnfle2wv01jehgt4bpuuyqdx	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.121	2026-04-01 05:17:01.121	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4sl01qzhgt4ijuoce4f	cmnfle32801k5hgt4e9p2o4z8	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.126	2026-04-01 05:17:01.126	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4sr01r0hgt43lds8la0	cmnfle3bv01luhgt4qxbpyzoj	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.131	2026-04-01 05:17:01.131	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4sw01r1hgt4wk0em5s3	cmnfle3eb01mdhgt4obnnj6p5	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.136	2026-04-01 05:17:01.136	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4t101r2hgt4l989nv7m	cmnfle3fs01mphgt4fkhf0gh3	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.141	2026-04-01 05:17:01.141	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4t701r3hgt42thaxis2	cmnfle3hh01n1hgt4mox1sz16	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.147	2026-04-01 05:17:01.147	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4tc01r4hgt4u3nxymrp	cmnfle3n401nwhgt47skts24p	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.152	2026-04-01 05:17:01.152	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4th01r5hgt47us82hp5	cmnfle3pw01o9hgt45q5fmrlb	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.157	2026-04-01 05:17:01.157	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4tm01r6hgt4xyt7lif8	cmnfle3uh01owhgt46e4f6wdo	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.162	2026-04-01 05:17:01.162	cmnfkqexq00zthgt4g4n1fbfy
cmnflg4tr01r7hgt4bmmzw6uq	cmnfle3ww01pahgt4k4npze0c	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:01.167	2026-04-01 05:17:01.167	cmnfkqexq00zthgt4g4n1fbfy
cmnflklve01v2hgt4dqabv801	cmnfle2qz01imhgt47ssn5lpq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:20:29.882	2026-04-01 05:20:29.882	cmnfkt8q40104hgt41ma5h63p
cmnflklw801v5hgt4k6jkxijg	cmnfle2xw01jkhgt4z9v4yp0l	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:29.912	2026-04-01 05:20:29.912	cmnfkt8q40104hgt41ma5h63p
cmnflklwe01v6hgt4zbhnnah9	cmnfle34101khhgt4vo7vvfn4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:29.918	2026-04-01 05:20:29.918	cmnfkt8q40104hgt41ma5h63p
cmnflklwj01v7hgt4ibi6q1re	cmnfle2wa01jahgt4tjmgbo0z	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:29.923	2026-04-01 05:20:29.923	cmnfkt8q40104hgt41ma5h63p
cmnflklwn01v8hgt4vmxqdoen	cmnfle38f01l7hgt4ep3zober	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:29.927	2026-04-01 05:20:29.927	cmnfkt8q40104hgt41ma5h63p
cmnflklws01v9hgt4jtz9hhw6	cmnfle37m01l2hgt49njywe7j	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:29.932	2026-04-01 05:20:29.932	cmnfkt8q40104hgt41ma5h63p
cmnflklwx01vahgt44wxfskxu	cmnfle38101l5hgt4qqo3dx32	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:29.937	2026-04-01 05:20:29.937	cmnfkt8q40104hgt41ma5h63p
cmnflklx301vbhgt4g7oemul0	cmnfle37s01l3hgt49evli4vq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:29.943	2026-04-01 05:20:29.943	cmnfkt8q40104hgt41ma5h63p
cmnflpndb01z7hgt4tk3r60an	cmnfle3oo01o3hgt4iawrch0f	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:24:25.103	2026-04-01 05:24:25.103	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflpne601zahgt4s5hi5w3m	cmnfle3tq01othgt443yaztpl	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:24:25.134	2026-04-01 05:24:25.134	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflpnec01zbhgt4b0d082xk	cmnfle3xu01pghgt4gfj7qjis	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:24:25.14	2026-04-01 05:24:25.14	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflpneh01zchgt4lrqgpyno	cmnfle3w201p5hgt4uztnj9o9	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:24:25.145	2026-04-01 05:24:25.145	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflpnen01zdhgt4dsz50ede	cmnfle3w801p6hgt4x3l9b1m7	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:24:25.151	2026-04-01 05:24:25.151	cmnfkrcpl00zxhgt4sxtmnh6n
cmnfm88lt026ihgt4wy8g5b7k	cmnfm2086023whgt4dcxq4hzf	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-01 05:38:52.433	2026-04-01 05:38:52.433	\N
cmng2f176002rrkt48x9kwen7	cmnfm20iu0256hgt4x7zfidh9	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:12:03.282	2026-04-01 13:12:03.282	\N
cmng2f302002srkt4thh7f2zi	cmnfm20il0255hgt4n10mlpxn	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:12:05.618	2026-04-01 13:12:05.618	\N
cmng36op1003nrkt448m7kq83	cmnfm20ac0246hgt4dfnxaddv	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-01 13:33:33.445	2026-04-01 13:33:33.445	\N
cmng3bfhe00nmrkt4chhfv9ic	cmng3bfh600nlrkt4krdc1bxe	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:37:14.786	2026-04-01 13:37:14.786	\N
cmng3bgbg00r7rkt4h2lqegtn	cmng3bgbb00r6rkt45ubz6azh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:15.868	2026-04-01 13:37:15.868	\N
cmng3bgbu00r9rkt4qqazd1x3	cmng3bgbo00r8rkt42wuhrpka	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	AUTOMATICA	t	2026-04-01 13:37:15.882	2026-04-01 13:37:15.882	\N
cmnge55ga00uorkt4hdsqwdd8	cmng3bga000r2rkt44evpdzgi	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.626	2026-04-01 18:40:17.626	\N
cmnge55hk00uprkt47b8g3px1	cmng3bg8600qurkt4g2x4lger	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.672	2026-04-01 18:40:17.672	\N
cmnge55iu00uqrkt41gdhi9fs	cmng38yz5008orkt4fhdbkdzk	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.718	2026-04-01 18:40:17.718	\N
cmnge55ka00urrkt4vhqf02w7	cmng38za100acrkt4w1zifqv7	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.77	2026-04-01 18:40:17.77	\N
cmnge55lu00usrkt4nathorig	cmng38zos00ckrkt4mw6rmert	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.826	2026-04-01 18:40:17.826	\N
cmnge55n500utrkt4tfcmsspr	cmng38zkk00bxrkt4utfxqcfp	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.873	2026-04-01 18:40:17.873	\N
cmnge55oh00uurkt4zhf59m3j	cmng38ysi007rrkt44ewcredn	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.921	2026-04-01 18:40:17.921	\N
cmnge55pr00uvrkt4ahintcdo	cmng38ywq008brkt409flg322	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:17.967	2026-04-01 18:40:17.967	\N
cmnge55r100uwrkt40e6j7e0a	cmng38zfe00b7rkt48q6q38yt	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.014	2026-04-01 18:40:18.014	\N
cmnge55sh00uxrkt4zigewsl4	cmng38ym00071rkt42z81dc6g	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.065	2026-04-01 18:40:18.065	\N
cmnge55u400uyrkt48um4s32v	cmng38zl500c0rkt4omnpalt7	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.124	2026-04-01 18:40:18.124	\N
cmnge55v900uzrkt4hb9r66or	cmng38z4o009mrkt4kevnjfqe	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.165	2026-04-01 18:40:18.165	\N
cmnge55wp00v0rkt46x4z8xs9	cmng38zp400cmrkt4xiegn05b	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.217	2026-04-01 18:40:18.217	\N
cmnge55y000v1rkt4a6ji22ed	cmng38zgm00berkt424v0bbg9	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.264	2026-04-01 18:40:18.264	\N
cmnflgi2j01r8hgt4t57a7sya	cmnfle2ic01i8hgt4fxxj0lm8	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:17:18.331	2026-04-01 05:17:18.331	cmnfkvenc010chgt44uzjdcc6
cmnflgi3901rbhgt42eww8c8z	cmnfle2sg01ishgt4kvy38lgr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.357	2026-04-01 05:17:18.357	cmnfkvenc010chgt44uzjdcc6
cmnflgi3e01rchgt4kscud6k6	cmnfle2zq01jthgt4arlacnz6	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.362	2026-04-01 05:17:18.362	cmnfkvenc010chgt44uzjdcc6
cmnflgi3i01rdhgt4s10z27ip	cmnfle33l01kehgt4uxblbcwl	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.366	2026-04-01 05:17:18.366	cmnfkvenc010chgt44uzjdcc6
cmnflgi3l01rehgt43bsnx2z3	cmnfle3bl01lshgt4frj4w659	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.369	2026-04-01 05:17:18.369	cmnfkvenc010chgt44uzjdcc6
cmnflgi3p01rfhgt4coil9itc	cmnfle3do01m9hgt4dkkbqox8	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.373	2026-04-01 05:17:18.373	cmnfkvenc010chgt44uzjdcc6
cmnflgi3t01rghgt4lw3rclcm	cmnfle3fo01mohgt4g8lb2zr4	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.377	2026-04-01 05:17:18.377	cmnfkvenc010chgt44uzjdcc6
cmnflgi3x01rhhgt4xp1d8weo	cmnfle3il01nahgt4rva29i0h	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.381	2026-04-01 05:17:18.381	cmnfkvenc010chgt44uzjdcc6
cmnflgi4101rihgt460k1rgwp	cmnfle3k001nihgt470peisp0	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.385	2026-04-01 05:17:18.385	cmnfkvenc010chgt44uzjdcc6
cmnflgi4501rjhgt4qq8hn7ch	cmnfle3rg01ohhgt4x7g0x7dc	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.389	2026-04-01 05:17:18.389	cmnfkvenc010chgt44uzjdcc6
cmnflgi4901rkhgt497p46j95	cmnfle3uo01oxhgt47yco5ddu	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.393	2026-04-01 05:17:18.393	cmnfkvenc010chgt44uzjdcc6
cmnflgi4e01rlhgt4du8hi43n	cmnfle3ya01pjhgt438bfbi69	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:18.398	2026-04-01 05:17:18.398	cmnfkvenc010chgt44uzjdcc6
cmnflkuqa01vchgt4qopdl7x6	cmnfle2ra01inhgt4ee2nqmdg	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:20:41.362	2026-04-01 05:20:41.362	cmnfkq1wt00zshgt4nv418741
cmnflkur001vfhgt41n6uzwov	cmnfle30g01jwhgt4ep9va1wn	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.388	2026-04-01 05:20:41.388	cmnfkq1wt00zshgt4nv418741
cmnflkur601vghgt4eqst544x	cmnfle3yv01pnhgt48ecqd8gh	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.394	2026-04-01 05:20:41.394	cmnfkq1wt00zshgt4nv418741
cmnflkur901vhhgt4non0nryj	cmnfle3ef01mehgt4eby4gzl1	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.397	2026-04-01 05:20:41.397	cmnfkq1wt00zshgt4nv418741
cmnflkurd01vihgt4boks18cv	cmnfle3kt01nmhgt4vflrhv3l	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.401	2026-04-01 05:20:41.401	cmnfkq1wt00zshgt4nv418741
cmnflkurh01vjhgt4mxco7f3e	cmnfle3b501lphgt4q2t6tq6h	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.405	2026-04-01 05:20:41.405	cmnfkq1wt00zshgt4nv418741
cmnflkurl01vkhgt4hmx29gca	cmnfle2w201j9hgt4rq591t5k	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.409	2026-04-01 05:20:41.409	cmnfkq1wt00zshgt4nv418741
cmnflkuro01vlhgt4cktfdoxc	cmnfle3ff01mmhgt42saxwx3z	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.412	2026-04-01 05:20:41.412	cmnfkq1wt00zshgt4nv418741
cmnflkurs01vmhgt4m75kve6s	cmnfle3vg01p1hgt4dkiywdjq	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.416	2026-04-01 05:20:41.416	cmnfkq1wt00zshgt4nv418741
cmnflkurw01vnhgt47r7vauaq	cmnfle3qi01ochgt4wsy8m3xi	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.42	2026-04-01 05:20:41.42	cmnfkq1wt00zshgt4nv418741
cmnflkus101vohgt48yy621xw	cmnfle3i101n6hgt4h0nkp7gi	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.425	2026-04-01 05:20:41.425	cmnfkq1wt00zshgt4nv418741
cmnflkus601vphgt463cs76vm	cmnfle34o01klhgt40t8sezmt	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:41.43	2026-04-01 05:20:41.43	cmnfkq1wt00zshgt4nv418741
cmnflpx1601zehgt4n5y73id5	cmnfle3ro01oihgt4flg9udcu	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:24:37.626	2026-04-01 05:24:37.626	cmnfkp2vg00zmhgt4890h7c56
cmnflpx2601zhhgt404r2uvdp	cmnfle3yl01plhgt4f5yizik4	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:24:37.662	2026-04-01 05:24:37.662	cmnfkp2vg00zmhgt4890h7c56
cmnflpx2c01zihgt43ri6e8ys	cmnfle3rw01ojhgt4m1f90793	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:24:37.668	2026-04-01 05:24:37.668	cmnfkp2vg00zmhgt4890h7c56
cmnfm8lw6026lhgt4ymygx0fj	cmnfm205w023nhgt4xrjhh1bv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 05:39:09.654	2026-04-01 05:39:09.654	\N
cmnfm8lx2026ohgt42f6zoh48	cmnfm20l2025fhgt45e0y63qh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 05:39:09.686	2026-04-01 05:39:09.686	\N
cmnfm8lx8026phgt4ct0bzh2e	cmnfm20dh024ihgt4ruv8ly1i	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 05:39:09.692	2026-04-01 05:39:09.692	\N
cmnfm8lxe026qhgt43nmua79k	cmnfm20gd024vhgt4y5okq6pq	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 05:39:09.698	2026-04-01 05:39:09.698	\N
cmnfm8lxj026rhgt4v4uo0l8h	cmnfm20mp025nhgt4cccuq3pk	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 05:39:09.703	2026-04-01 05:39:09.703	\N
cmng2g3et002trkt4gxpbk75d	cmnfm20ld025hhgt49ey4nh42	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:12:52.805	2026-04-01 13:12:52.805	\N
cmng2g4u0002urkt4391rjry6	cmnfm20hj0251hgt464yvhu3x	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:12:54.648	2026-04-01 13:12:54.648	\N
cmng2g6lf002vrkt4sgw0o1qz	cmnfm20gx024yhgt4hkdekxla	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:12:56.931	2026-04-01 13:12:56.931	\N
cmng379p4003orkt44xl39rxp	cmnfm20cd024ehgt40hy9wcmz	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-01 13:34:00.664	2026-04-01 13:34:00.664	\N
cmng3bfll00nvrkt4b889uj0f	cmng3bflb00nurkt4fvfxslvj	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-01 13:37:14.937	2026-04-01 13:37:14.937	\N
cmng3bgek00rkrkt4kk9l3ymh	cmng3bgdw00rjrkt4s7wmmiuq	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:15.98	2026-04-01 13:37:15.98	\N
cmng3bgf000rmrkt4ektj42ll	cmng3bgeu00rlrkt4skvamkuv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:15.996	2026-04-01 13:37:15.996	\N
cmng3bggc00rsrkt44qmgvc6q	cmng3bgg300rrrkt4m6ort5x5	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:16.044	2026-04-01 13:37:16.044	\N
cmng3bggv00rvrkt4km78uqe9	cmng3bggo00rurkt4s1qhc0d2	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:16.063	2026-04-01 13:37:16.063	\N
cmnge55zc00v2rkt4063rg2iz	cmng38ywy008crkt42wu9rbb4	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.312	2026-04-01 18:40:18.312	\N
cmnge560o00v3rkt45dtnlqh5	cmng38z04008urkt4xsxpim8c	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.36	2026-04-01 18:40:18.36	\N
cmnge562d00v4rkt4wofumj2a	cmng38zge00bdrkt4f60yuo0d	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.421	2026-04-01 18:40:18.421	\N
cmnge563p00v5rkt4kvsdbvgi	cmng38ytu007xrkt4pnx4knz5	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.47	2026-04-01 18:40:18.47	\N
cmnflgtoz01rmhgt4jb2w4g2z	cmnfle2il01i9hgt4yligve4a	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:17:33.395	2026-04-01 05:17:33.395	cmnfksd8d0101hgt4l62jg4a7
cmnflgtpu01rphgt447ofnpk1	cmnfle2uw01j2hgt45yvzw957	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:33.426	2026-04-01 05:17:33.426	cmnfksd8d0101hgt4l62jg4a7
cmnflgtq001rqhgt4n3um0oqf	cmnfle2yy01jqhgt4ic97palt	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:33.432	2026-04-01 05:17:33.432	cmnfksd8d0101hgt4l62jg4a7
cmnflgtq501rrhgt4ipz8h97r	cmnfle32101k4hgt4d3c313yc	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:33.437	2026-04-01 05:17:33.437	cmnfksd8d0101hgt4l62jg4a7
cmnflgtqb01rshgt4cr2m8ecp	cmnfle38z01lbhgt4lamytklo	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:33.443	2026-04-01 05:17:33.443	cmnfksd8d0101hgt4l62jg4a7
cmnflgtqg01rthgt4k4q15hb7	cmnfle39901lchgt4v2b0b368	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:33.448	2026-04-01 05:17:33.448	cmnfksd8d0101hgt4l62jg4a7
cmnfll5vm01vqhgt4z9n5q9ft	cmnfle2rk01iohgt4frjaqozg	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:20:55.81	2026-04-01 05:20:55.81	cmnfkp8nw00znhgt4wtrtzofm
cmnfll5x901vthgt4furhqcf9	cmnfle3ap01lmhgt4e5fs2i6j	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:55.869	2026-04-01 05:20:55.869	cmnfkp8nw00znhgt4wtrtzofm
cmnfll5xe01vuhgt4cp3lkyor	cmnfle3ac01lkhgt4kbav4z0l	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:55.874	2026-04-01 05:20:55.874	cmnfkp8nw00znhgt4wtrtzofm
cmnfll5xi01vvhgt40zc3a72r	cmnfle30w01jyhgt4zeufg5n9	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:55.878	2026-04-01 05:20:55.878	cmnfkp8nw00znhgt4wtrtzofm
cmnfll5xo01vwhgt48aex23k7	cmnfle32v01k9hgt4pt41ev3q	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:55.884	2026-04-01 05:20:55.884	cmnfkp8nw00znhgt4wtrtzofm
cmnfll5xt01vxhgt4p7w0wz2g	cmnfle2ti01iwhgt48ljuiopy	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:20:55.889	2026-04-01 05:20:55.889	cmnfkp8nw00znhgt4wtrtzofm
cmnflr31w01zmhgt4dsjfnp7f	cmnflr31i01zlhgt46983xrhr	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.084	2026-04-01 05:25:32.084	cmnfkskbx0102hgt4wp2stj9s
cmnflr32e01zohgt4ofz4rrlm	cmnflr32401znhgt4ip535es6	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.102	2026-04-01 05:25:32.102	cmnfkv17r010ahgt4x5dtkz2a
cmnflr32q01zqhgt4ri8w55sh	cmnflr32j01zphgt42nqdc4p3	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.115	2026-04-01 05:25:32.115	cmnfkp8nw00znhgt4wtrtzofm
cmnflr33901zthgt4tzjy18kx	cmnflr33201zshgt4p0u0sag8	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.133	2026-04-01 05:25:32.133	cmnfkt2br0103hgt4yaylhkk7
cmnflr33m01zvhgt4ailqx70w	cmnflr33f01zuhgt44z2d4ait	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.146	2026-04-01 05:25:32.146	cmnfkvrla010ehgt4pntoyk13
cmnflr33u01zxhgt48yl9ub4t	cmnflr33p01zwhgt4j2wmor8z	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.154	2026-04-01 05:25:32.154	cmnfks7y90100hgt4htds26dj
cmnflr34601zzhgt4sbnmtm27	cmnflr33y01zyhgt47e8ry9ey	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.166	2026-04-01 05:25:32.166	cmnfkpkhd00zphgt4elqe9l29
cmnflr34h0201hgt442yff2nr	cmnflr3480200hgt49otg88rx	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.177	2026-04-01 05:25:32.177	cmnfkr0x200zvhgt4bdrsp2u0
cmnflr34t0203hgt4x3ofwn78	cmnflr34k0202hgt4gqgq099d	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.189	2026-04-01 05:25:32.189	cmnfkvrla010ehgt4pntoyk13
cmnflr3550205hgt4xqug8q6u	cmnflr34y0204hgt4vuzmzdet	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.201	2026-04-01 05:25:32.201	cmnfkt8q40104hgt41ma5h63p
cmnflr35j0207hgt4dw8tld69	cmnflr35a0206hgt44bho6433	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.215	2026-04-01 05:25:32.215	cmnfkp2vg00zmhgt4890h7c56
cmnflr35w0209hgt4ccp2t3lp	cmnflr35m0208hgt4tl92dirf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.228	2026-04-01 05:25:32.228	cmnfkqexq00zthgt4g4n1fbfy
cmnflr366020bhgt470fnxlrt	cmnflr35z020ahgt4jsyg9zl3	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.238	2026-04-01 05:25:32.238	cmnfksd8d0101hgt4l62jg4a7
cmnflr36i020dhgt4anhv2ird	cmnflr36a020chgt4eyd630if	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.25	2026-04-01 05:25:32.25	cmnfks14q00zzhgt47kj8x90e
cmnflr36t020fhgt4h6ihr66h	cmnflr36m020ehgt4iz5pm5kq	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.261	2026-04-01 05:25:32.261	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflr374020hhgt4rn6awdkn	cmnflr36w020ghgt4f990j9i7	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.272	2026-04-01 05:25:32.272	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflr37f020jhgt4an9phzdr	cmnflr378020ihgt42fpejzo4	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.283	2026-04-01 05:25:32.283	cmnfkq1wt00zshgt4nv418741
cmnflr37p020lhgt42yr9hmtw	cmnflr37i020khgt46t3cqksv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.293	2026-04-01 05:25:32.293	cmnfkvenc010chgt44uzjdcc6
cmnflr37z020nhgt4jo0ljnyv	cmnflr37t020mhgt4q9b6yikf	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.303	2026-04-01 05:25:32.303	cmnfkrvw300zyhgt403qbk0s6
cmnflr38a020phgt49tqv2icx	cmnflr384020ohgt4fl7a7niw	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.314	2026-04-01 05:25:32.314	cmnfkpf0u00zohgt40qewt2f3
cmnflr38l020rhgt4nfe4weib	cmnflr38d020qhgt4hgvr8r1r	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.325	2026-04-01 05:25:32.325	cmnfkpwhq00zrhgt4kwye95fl
cmnflr38y020uhgt4p0pyek52	cmnflr38s020thgt4yksdti1s	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.338	2026-04-01 05:25:32.338	cmnfkt2br0103hgt4yaylhkk7
cmnflr397020whgt4oyvm3evd	cmnflr392020vhgt40kp97gct	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.347	2026-04-01 05:25:32.347	cmnfkvrla010ehgt4pntoyk13
cmnflr39h020yhgt4xe1qwra4	cmnflr39a020xhgt4b4dixvm2	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.357	2026-04-01 05:25:32.357	cmnfks7y90100hgt4htds26dj
cmnflr39t0211hgt4u8mund5v	cmnflr39p0210hgt4ozmm888d	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.369	2026-04-01 05:25:32.369	cmnfkvenc010chgt44uzjdcc6
cmnflr3a50213hgt4exgqxhzp	cmnflr39y0212hgt4281edkfb	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.381	2026-04-01 05:25:32.381	cmnfkq1wt00zshgt4nv418741
cmnflr3af0215hgt4lp07uiuk	cmnflr3a80214hgt4nkd6d2cg	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.391	2026-04-01 05:25:32.391	cmnfkr0x200zvhgt4bdrsp2u0
cmnflr3an0217hgt4aabkp3de	cmnflr3ai0216hgt4tdatgiyn	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.399	2026-04-01 05:25:32.399	cmnfksd8d0101hgt4l62jg4a7
cmnflr3az0219hgt4p63act42	cmnflr3aq0218hgt46mglt3jc	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.411	2026-04-01 05:25:32.411	cmnfkpf0u00zohgt40qewt2f3
cmnflr3bb021bhgt40l39r1oq	cmnflr3b2021ahgt4uwbtgg8t	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.423	2026-04-01 05:25:32.423	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflr3bv021dhgt480sp1u58	cmnflr3bj021chgt4n74m3ruc	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.443	2026-04-01 05:25:32.443	cmnfkt8q40104hgt41ma5h63p
cmnflh4o001ruhgt46zhjzf5f	cmnfle2iz01iahgt4k2q2p03c	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:17:47.616	2026-04-01 05:17:47.616	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4p001rxhgt421k498gb	cmnfle2s801irhgt4g3ebyqow	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.652	2026-04-01 05:17:47.652	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4p601ryhgt4k5lhbi0s	cmnfle2yl01johgt40o8a1ap0	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.658	2026-04-01 05:17:47.658	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4p901rzhgt4vp9gr645	cmnfle35601kohgt4gytz96av	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.661	2026-04-01 05:17:47.661	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4pe01s0hgt4kdtxsvpe	cmnfle3c401lwhgt4v03j6e1a	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.666	2026-04-01 05:17:47.666	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4pi01s1hgt4wbzmpw24	cmnfle3dh01m7hgt45nr2ihjv	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.67	2026-04-01 05:17:47.67	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4pn01s2hgt43xlgg51b	cmnfle3f701mkhgt4rs35pmgj	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.675	2026-04-01 05:17:47.675	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4pr01s3hgt445kuiia7	cmnfle3hb01n0hgt4fm1adoy1	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.679	2026-04-01 05:17:47.679	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4pv01s4hgt4rfsu8unp	cmnfle3m501nshgt4vegw5urd	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.683	2026-04-01 05:17:47.683	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4pz01s5hgt4sg4kg6le	cmnfle3qc01obhgt4wkn74mrk	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.687	2026-04-01 05:17:47.687	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4q301s6hgt4v3xa6i75	cmnfle3td01orhgt49sfmaf1e	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.691	2026-04-01 05:17:47.691	cmnfkqspm00zuhgt4hu2eqk4l
cmnflh4q701s7hgt43aj62pgs	cmnfle3xe01pdhgt4yyrvi71q	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:47.695	2026-04-01 05:17:47.695	cmnfkqspm00zuhgt4hu2eqk4l
cmnfllfk201vyhgt4n0in4zob	cmnfle2rs01iphgt4nfqyw5rp	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:21:08.354	2026-04-01 05:21:08.354	cmnfl616e01cdhgt468d1xir6
cmnfllfkw01w1hgt4tenp1yfr	cmnfle2un01j1hgt4ihpml9wl	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.384	2026-04-01 05:21:08.384	cmnfl616e01cdhgt468d1xir6
cmnfllfl201w2hgt4xfi4n2y8	cmnfle2yd01jnhgt4ltb43578	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.39	2026-04-01 05:21:08.39	cmnfl616e01cdhgt468d1xir6
cmnfllfl801w3hgt4404u5i76	cmnfle31q01k2hgt4curjf1af	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.396	2026-04-01 05:21:08.396	cmnfl616e01cdhgt468d1xir6
cmnfllfle01w4hgt40xl19e2j	cmnfle3ba01lqhgt4ilj75rq0	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.402	2026-04-01 05:21:08.402	cmnfl616e01cdhgt468d1xir6
cmnfllflj01w5hgt4e5ixqgos	cmnfle3d301m4hgt4dvblrfaz	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.407	2026-04-01 05:21:08.407	cmnfl616e01cdhgt468d1xir6
cmnfllflo01w6hgt4xm3cq67f	cmnfle3g901mthgt4fsmq5vcz	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.412	2026-04-01 05:21:08.412	cmnfl616e01cdhgt468d1xir6
cmnfllflv01w7hgt4cvdk4k8c	cmnfle3jb01nehgt4ni9vo2v8	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.419	2026-04-01 05:21:08.419	cmnfl616e01cdhgt468d1xir6
cmnfllflz01w8hgt4ovlcy2pr	cmnfle3ml01nuhgt4s2h0de5u	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.423	2026-04-01 05:21:08.423	cmnfl616e01cdhgt468d1xir6
cmnfllfm401w9hgt4ggo6fbi4	cmnfle3ph01o7hgt4dc5jlwvj	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.428	2026-04-01 05:21:08.428	cmnfl616e01cdhgt468d1xir6
cmnfllfma01wahgt4e7dz2bqk	cmnfle3u801ovhgt4umuuv4ir	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.434	2026-04-01 05:21:08.434	cmnfl616e01cdhgt468d1xir6
cmnfllfme01wbhgt450z44t61	cmnfle3xp01pfhgt4n1jiz4kr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:08.438	2026-04-01 05:21:08.438	cmnfl616e01cdhgt468d1xir6
cmnflr3ca021fhgt4dlpil6up	cmnflr3bz021ehgt4jiqj3ccs	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.458	2026-04-01 05:25:32.458	cmnfkvrla010ehgt4pntoyk13
cmnflr3cp021hhgt47kd4aufg	cmnflr3ce021ghgt4mvzpgqnj	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.473	2026-04-01 05:25:32.473	cmnfkp8nw00znhgt4wtrtzofm
cmnflr3d1021jhgt41brtaz02	cmnflr3ct021ihgt4he4boc6l	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.485	2026-04-01 05:25:32.485	cmnfkqexq00zthgt4g4n1fbfy
cmnflr3de021lhgt4gvaqawg6	cmnflr3d7021khgt4pfohsxdx	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.498	2026-04-01 05:25:32.498	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflr3dr021nhgt46ikurtgp	cmnflr3dh021mhgt40i789hvm	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.511	2026-04-01 05:25:32.511	cmnfkpwhq00zrhgt4kwye95fl
cmnflr3e0021phgt4nl4lcfl2	cmnflr3du021ohgt4s51zu8ng	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.52	2026-04-01 05:25:32.52	cmnfkp2vg00zmhgt4890h7c56
cmnflr3ea021rhgt40tbou2cx	cmnflr3e4021qhgt4hzb4spox	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.53	2026-04-01 05:25:32.53	cmnfkrvw300zyhgt403qbk0s6
cmnflr3em021thgt4ea0ymb10	cmnflr3ee021shgt4esp7u1re	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.542	2026-04-01 05:25:32.542	cmnfks14q00zzhgt47kj8x90e
cmnflr3ey021vhgt47211wvc1	cmnflr3ep021uhgt4x1id084d	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.555	2026-04-01 05:25:32.555	cmnfkskbx0102hgt4wp2stj9s
cmnflr3fd021xhgt4gh5re9rk	cmnflr3f4021whgt4fnu6hes9	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.569	2026-04-01 05:25:32.569	cmnfkv17r010ahgt4x5dtkz2a
cmnflr3fs021zhgt4d0d0p8rg	cmnflr3fi021yhgt4wd0rkhb1	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.584	2026-04-01 05:25:32.584	cmnfkpkhd00zphgt4elqe9l29
cmnflr3h10224hgt4f0a8b29m	cmnflr3go0223hgt40cvwlzrd	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.629	2026-04-01 05:25:32.629	cmnfksd8d0101hgt4l62jg4a7
cmnflr3hc0226hgt4kpvqvpw6	cmnflr3h40225hgt4yugkml85	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.64	2026-04-01 05:25:32.64	cmnfkt8q40104hgt41ma5h63p
cmnflr3hm0228hgt4gw0z7pni	cmnflr3hf0227hgt49eipjgpc	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.65	2026-04-01 05:25:32.65	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflr3hw022ahgt43y1d33u2	cmnflr3ho0229hgt4ghfh5q9i	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.66	2026-04-01 05:25:32.66	cmnfkvrla010ehgt4pntoyk13
cmnflr3i8022chgt4lph33dgz	cmnflr3hz022bhgt4v4yb7zv4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.672	2026-04-01 05:25:32.672	cmnfks14q00zzhgt47kj8x90e
cmnflr3ih022ehgt4m2fp954k	cmnflr3ic022dhgt4k4s8s2ik	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.682	2026-04-01 05:25:32.682	cmnfkpf0u00zohgt40qewt2f3
cmnflr3is022ghgt4jw8iui8n	cmnflr3ik022fhgt4vaoki6qv	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.692	2026-04-01 05:25:32.692	cmnfkrvw300zyhgt403qbk0s6
cmnflr3j1022ihgt47j3e89v9	cmnflr3iv022hhgt4bqzfgdui	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.701	2026-04-01 05:25:32.701	cmnfkskbx0102hgt4wp2stj9s
cmnflhdra01s8hgt4sjx75a6n	cmnfle2ja01ibhgt4rek6g2sy	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:17:59.398	2026-04-01 05:17:59.398	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdsa01sbhgt4413pxj8i	cmnfle2wm01jchgt4c52oatyt	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.434	2026-04-01 05:17:59.434	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdsi01schgt4p3gc1m3q	cmnfle2zg01jshgt42ku2f558	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.442	2026-04-01 05:17:59.442	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdsn01sdhgt448l17avq	cmnfle31w01k3hgt4qwi9k50k	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.447	2026-04-01 05:17:59.447	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdsr01sehgt4dgl32gk3	cmnfle3ce01lyhgt4x1ms21ou	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.451	2026-04-01 05:17:59.451	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdsx01sfhgt4gowy3m2k	cmnfle3eo01mghgt4dzz0z2nl	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.457	2026-04-01 05:17:59.457	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdt201sghgt4ssdftfds	cmnfle3gk01mvhgt4e198sao3	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.462	2026-04-01 05:17:59.462	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdt601shhgt4y8k9k6nr	cmnfle3h701mzhgt432rcd7k9	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.466	2026-04-01 05:17:59.466	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdtc01sihgt4bvwys4f6	cmnfle3mt01nvhgt47j17joov	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.472	2026-04-01 05:17:59.472	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdtg01sjhgt4mu9iwlon	cmnfle3p301o5hgt4u268uoy5	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.476	2026-04-01 05:17:59.476	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdtl01skhgt4b8yh8n3z	cmnfle3tl01oshgt4erdcq4dl	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.481	2026-04-01 05:17:59.481	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhdtq01slhgt4hx66927u	cmnfle3z301pohgt40nlkb0dy	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:17:59.486	2026-04-01 05:17:59.486	cmnfkr6pe00zwhgt4j7vbb5vx
cmnfllsql01wchgt41dxwkcvf	cmnfle31e01k0hgt4jouy8qqr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:21:25.437	2026-04-01 05:21:25.437	cmnfkvkyn010dhgt4qymxazu8
cmnfllsrb01wfhgt4tfic7hzt	cmnfle3c801lxhgt4iz4ffvct	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.463	2026-04-01 05:21:25.463	cmnfkvkyn010dhgt4qymxazu8
cmnfllsrg01wghgt44xytd03w	cmnfle3d701m5hgt4ysbfdnlp	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.468	2026-04-01 05:21:25.468	cmnfkvkyn010dhgt4qymxazu8
cmnfllsrk01whhgt45zfn0ux1	cmnfle3fv01mqhgt4fhqhyqwq	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.472	2026-04-01 05:21:25.472	cmnfkvkyn010dhgt4qymxazu8
cmnfllsro01wihgt4un9p8eww	cmnfle3hm01n2hgt4yqws425z	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.476	2026-04-01 05:21:25.476	cmnfkvkyn010dhgt4qymxazu8
cmnfllsrr01wjhgt4vlq4keip	cmnfle3jv01nhhgt4osju75up	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.479	2026-04-01 05:21:25.479	cmnfkvkyn010dhgt4qymxazu8
cmnfllsrw01wkhgt4lip1yt8o	cmnfle3o101o0hgt4oqbg4yp5	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.484	2026-04-01 05:21:25.484	cmnfkvkyn010dhgt4qymxazu8
cmnfllss001wlhgt4o77wjmow	cmnfle3tz01ouhgt4d1yqofko	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.488	2026-04-01 05:21:25.488	cmnfkvkyn010dhgt4qymxazu8
cmnfllss501wmhgt412twon1n	cmnfle3wj01p8hgt4cjejbt39	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:25.493	2026-04-01 05:21:25.493	cmnfkvkyn010dhgt4qymxazu8
cmnflr3jc022khgt46l9dzr97	cmnflr3j5022jhgt4xoixar6w	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.712	2026-04-01 05:25:32.712	cmnfkvenc010chgt44uzjdcc6
cmnflr3jp022mhgt4aaole8hu	cmnflr3jg022lhgt45t9am92c	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.725	2026-04-01 05:25:32.725	cmnfkt2br0103hgt4yaylhkk7
cmnflr3jx022ohgt4zdj7pa0e	cmnflr3js022nhgt47crpuopb	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.733	2026-04-01 05:25:32.733	cmnfkqexq00zthgt4g4n1fbfy
cmnflr3k7022qhgt4nt5trdhh	cmnflr3k0022phgt4y3svfi67	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.743	2026-04-01 05:25:32.743	cmnfkp2vg00zmhgt4890h7c56
cmnflr3kh022shgt443pasw6z	cmnflr3kb022rhgt4018jgxcc	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.753	2026-04-01 05:25:32.753	cmnfkvrla010ehgt4pntoyk13
cmnflr3kr022uhgt4rzy080w6	cmnflr3kl022thgt4cs06amvh	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.763	2026-04-01 05:25:32.763	cmnfkr0x200zvhgt4bdrsp2u0
cmnflr3l4022whgt46rkd1wqn	cmnflr3ku022vhgt4g8d91n0r	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.776	2026-04-01 05:25:32.776	cmnfks7y90100hgt4htds26dj
cmnflr3ld022yhgt4ig9fjzf7	cmnflr3l8022xhgt4qz2ywk9u	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.785	2026-04-01 05:25:32.785	cmnfkpkhd00zphgt4elqe9l29
cmnflr3lo0230hgt44x298n1y	cmnflr3lh022zhgt4uqexgrn3	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.796	2026-04-01 05:25:32.796	cmnfkq1wt00zshgt4nv418741
cmnflr3lz0232hgt4a5qp86dj	cmnflr3lr0231hgt4rfdfetv8	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.808	2026-04-01 05:25:32.808	cmnfkpwhq00zrhgt4kwye95fl
cmnflr3m70234hgt4i6fgyfdy	cmnflr3m20233hgt4jt09tm1x	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.815	2026-04-01 05:25:32.815	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflr3mh0236hgt425to68jm	cmnflr3ma0235hgt4g8kxleqn	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.825	2026-04-01 05:25:32.825	cmnfkv17r010ahgt4x5dtkz2a
cmnflr3mp0238hgt4m3c5hjy5	cmnflr3mk0237hgt4pvu5ackw	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:32.833	2026-04-01 05:25:32.833	cmnfkp8nw00znhgt4wtrtzofm
cmnfm8v03026shgt4i3cuc50t	cmnfm2067023ohgt40t5ydknl	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 05:39:21.459	2026-04-01 05:39:21.459	\N
cmng2gwtp002wrkt4kg1qm7ta	cmnfm20jv025ahgt4p0hxtmvr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:13:30.925	2026-04-01 13:13:30.925	\N
cmng2gyni002xrkt4nwtxip44	cmnfm20kn025dhgt4i6jnmjdy	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:13:33.294	2026-04-01 13:13:33.294	\N
cmng38kvv003prkt4zwq4pgnv	cmnfm209b0242hgt4781gkwwj	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	MANUAL	t	2026-04-01 13:35:01.819	2026-04-01 13:35:01.819	\N
cmng38kwn003srkt405gahh2x	cmnfm207z023vhgt4go9jbwgw	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:35:01.847	2026-04-01 13:35:01.847	\N
cmng3bfmt00nyrkt4tagsta9i	cmng3bfm300nxrkt4hswl63gi	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:37:14.981	2026-04-01 13:37:14.981	\N
cmng3bfn700o0rkt40u8mxpw7	cmng3bfn000nzrkt45eg57lnz	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:37:14.995	2026-04-01 13:37:14.995	\N
cmng3bgjj00s2rkt4fnqnhuz9	cmng3bgjb00s1rkt4g59p6znj	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:37:16.159	2026-04-01 13:37:16.159	\N
cmng3bgki00s7rkt4nihhupns	cmng3bgkb00s6rkt49euk7l0h	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:37:16.194	2026-04-01 13:37:16.194	\N
cmng3bgl800sbrkt412krfqus	cmng3bgl100sarkt4ft88h48x	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:37:16.22	2026-04-01 13:37:16.22	\N
cmnflhpcb01smhgt4gr33gpzu	cmnfle2js01ichgt4u8m3z1yv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:18:14.411	2026-04-01 05:18:14.411	cmnfkvrla010ehgt4pntoyk13
cmnflhpd101sphgt413p8i8mc	cmnfle39u01lghgt491le2d6v	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:14.437	2026-04-01 05:18:14.437	cmnfkvrla010ehgt4pntoyk13
cmnflhpd701sqhgt4ya8zdan0	cmnfle39x01lhhgt4n637ccua	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:14.443	2026-04-01 05:18:14.443	cmnfkvrla010ehgt4pntoyk13
cmnflhpdd01srhgt4mwg6tuqx	cmnfle32z01kahgt4ub3zng63	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:14.449	2026-04-01 05:18:14.449	cmnfkvrla010ehgt4pntoyk13
cmnflhpdj01sshgt4cxty6yz1	cmnfle2va01j4hgt4fjfm0on6	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:14.455	2026-04-01 05:18:14.455	cmnfkvrla010ehgt4pntoyk13
cmnflhpdo01sthgt4ppkop36a	cmnfle2y301jlhgt48el2saom	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:14.46	2026-04-01 05:18:14.46	cmnfkvrla010ehgt4pntoyk13
cmnflm4sx01wnhgt4dd8ancy1	cmnfle35i01kqhgt4xrj7wxa1	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:21:41.073	2026-04-01 05:21:41.073	cmnfkr0x200zvhgt4bdrsp2u0
cmnflm4tk01wqhgt42ug470ms	cmnfle3ie01n9hgt4a9gozsw0	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:41.096	2026-04-01 05:21:41.096	cmnfkr0x200zvhgt4bdrsp2u0
cmnflm4tn01wrhgt4cgtkhg2a	cmnfle3wp01p9hgt4ln0pzphx	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:41.1	2026-04-01 05:21:41.1	cmnfkr0x200zvhgt4bdrsp2u0
cmnflm4tr01wshgt43joo9put	cmnfle3g001mrhgt463ypk763	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:41.103	2026-04-01 05:21:41.103	cmnfkr0x200zvhgt4bdrsp2u0
cmnflm4tv01wthgt40d7fi4k7	cmnfle3lo01nqhgt4vxm3i8z6	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:41.107	2026-04-01 05:21:41.107	cmnfkr0x200zvhgt4bdrsp2u0
cmnflm4tz01wuhgt4pbm8khou	cmnfle3o801o1hgt4f9wgq6x8	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:41.111	2026-04-01 05:21:41.111	cmnfkr0x200zvhgt4bdrsp2u0
cmnflm4u301wvhgt4htctabyn	cmnfle3v801p0hgt455jbtr7d	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:41.115	2026-04-01 05:21:41.115	cmnfkr0x200zvhgt4bdrsp2u0
cmnflrok30239hgt48ei4w681	cmnflr31801zkhgt420bhkkur	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:25:59.955	2026-04-01 05:25:59.955	cmnfkqspm00zuhgt4hu2eqk4l
cmnflrokx023chgt4mryv0i2g	cmnflr38o020shgt41j926u73	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:59.985	2026-04-01 05:25:59.985	cmnfkqspm00zuhgt4hu2eqk4l
cmnflrol2023dhgt4lj3tc08d	cmnflr3g10220hgt4ez1dw23q	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:25:59.99	2026-04-01 05:25:59.99	cmnfkqspm00zuhgt4hu2eqk4l
cmnfm98sc026vhgt414blp9y0	cmnfm20ei024mhgt4qa2x5b81	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 05:39:39.324	2026-04-01 05:39:39.324	\N
cmng2iip4002zrkt4d6otu2g6	cmnfm20k6025bhgt491oqpfjk	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:14:45.929	2026-04-01 13:14:45.929	\N
cmng2ijy90030rkt4w7hokb1i	cmnfm20ke025chgt4ji3yv4vd	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 13:14:47.553	2026-04-01 13:14:47.553	\N
cmng38y390043rkt4gko2zgqg	cmng38y320042rkt4i2ohily2	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:18.933	2026-04-01 13:35:18.933	\N
cmng38y450047rkt4prjoxz8f	cmng38y3y0046rkt4e8lqikc1	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:18.965	2026-04-01 13:35:18.965	\N
cmng38y4e0049rkt4ybu3a5lj	cmng38y490048rkt4jv1l0f84	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:18.974	2026-04-01 13:35:18.974	\N
cmng38y4p004brkt4ihrugtoz	cmng38y4k004arkt4f29hy6c8	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:18.985	2026-04-01 13:35:18.985	\N
cmng38y51004drkt4z2gufofo	cmng38y4u004crkt4w8a5p6n3	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:18.997	2026-04-01 13:35:18.997	\N
cmng38y5a004frkt4b6s6c2dp	cmng38y55004erkt4c4xafmgh	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.006	2026-04-01 13:35:19.006	\N
cmng38y68004krkt4qjd495ck	cmng38y62004jrkt4wf2w0vrz	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.04	2026-04-01 13:35:19.04	\N
cmng38y6r004nrkt4bqznw1kw	cmng38y6k004mrkt46r6aglmw	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:35:19.059	2026-04-01 13:35:19.059	\N
cmng38y75004prkt4mgp32z6u	cmng38y6y004orkt4lbb7j4ic	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:35:19.073	2026-04-01 13:35:19.073	\N
cmng38y8c004vrkt4tiqiltsh	cmng38y86004urkt4a7f6wszo	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.117	2026-04-01 13:35:19.117	\N
cmng38y8t004yrkt4y0x4gy34	cmng38y8n004xrkt4j5xq7mlw	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:19.133	2026-04-01 13:35:19.133	\N
cmng38y920050rkt411jiqb79	cmng38y8w004zrkt4466mxsla	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:19.142	2026-04-01 13:35:19.142	\N
cmng38y9b0052rkt4lc17box0	cmng38y960051rkt44oboboq5	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:19.151	2026-04-01 13:35:19.151	\N
cmng38y9k0054rkt44xjirqq2	cmng38y9e0053rkt42a6kstfw	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:19.16	2026-04-01 13:35:19.16	\N
cmng38y9t0056rkt4ouhloizh	cmng38y9o0055rkt4f2r7rd7b	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:19.169	2026-04-01 13:35:19.169	\N
cmng38ya30058rkt4ylvherid	cmng38y9w0057rkt47fmfowc5	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:19.179	2026-04-01 13:35:19.179	\N
cmng38yab005arkt426wfudtz	cmng38ya60059rkt45c0x7f2n	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:19.187	2026-04-01 13:35:19.187	\N
cmng38yal005crkt4eykswcyg	cmng38yae005brkt4iouzzgzu	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-01 13:35:19.197	2026-04-01 13:35:19.197	\N
cmng38yat005erkt407ay8pwz	cmng38yap005drkt40s6a0lus	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.205	2026-04-01 13:35:19.205	\N
cmng38yb3005grkt4s1cetac6	cmng38yay005frkt476z2kzt9	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:35:19.215	2026-04-01 13:35:19.215	\N
cmng38ybu005krkt4an3ga7zn	cmng38ybm005jrkt4hc0bsif4	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.242	2026-04-01 13:35:19.242	\N
cmng38yc9005mrkt4er2674s4	cmng38yc1005lrkt4h3q6lh19	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:35:19.257	2026-04-01 13:35:19.257	\N
cmng38ycm005orkt4wuv5815y	cmng38ycf005nrkt486wmtdh6	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:35:19.27	2026-04-01 13:35:19.27	\N
cmng38yd1005qrkt4eidpl19g	cmng38ycs005prkt45wx2teqq	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:35:19.285	2026-04-01 13:35:19.285	\N
cmng38ydp005trkt4u3yf800l	cmng38ydg005srkt47k1zgj5k	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.309	2026-04-01 13:35:19.309	\N
cmng38yee005wrkt4ii753x2o	cmng38ye5005vrkt4gnal9rbr	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.334	2026-04-01 13:35:19.334	\N
cmng38yet005yrkt4q7tlxu8i	cmng38yek005xrkt4o9bwq4k5	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.349	2026-04-01 13:35:19.349	\N
cmng38yf70060rkt44pwe89nd	cmng38yey005zrkt4d2xpij0n	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.363	2026-04-01 13:35:19.363	\N
cmnflhysu01suhgt482ifuvbj	cmnfle2ka01idhgt400c54s5x	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:18:26.67	2026-04-01 05:18:26.67	cmnfkskbx0102hgt4wp2stj9s
cmnflhyuk01sxhgt488pq8p8m	cmnfle39q01lfhgt4jbojv0kn	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:26.732	2026-04-01 05:18:26.732	cmnfkskbx0102hgt4wp2stj9s
cmnflhyup01syhgt4ov95i2iz	cmnfle33501kbhgt4lb5t0jj4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:26.737	2026-04-01 05:18:26.737	cmnfkskbx0102hgt4wp2stj9s
cmnflhyuu01szhgt4j6w5t414	cmnfle2y801jmhgt4j5l6waiu	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:26.742	2026-04-01 05:18:26.742	cmnfkskbx0102hgt4wp2stj9s
cmnflhyuz01t0hgt4ac5d4t9f	cmnfle2t801ivhgt430671vj1	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:26.747	2026-04-01 05:18:26.747	cmnfkskbx0102hgt4wp2stj9s
cmnflhyv301t1hgt4l20sp7gc	cmnfle3a401lihgt4ihkonk9e	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:26.751	2026-04-01 05:18:26.751	cmnfkskbx0102hgt4wp2stj9s
cmnflmevs01wwhgt4ixi0epws	cmnfle35o01krhgt4jakw5ac1	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:21:54.136	2026-04-01 05:21:54.136	cmnfkpwhq00zrhgt4kwye95fl
cmnflmewh01wzhgt4k08i9i0q	cmnfle3z801pphgt4ewnpwocs	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:54.161	2026-04-01 05:21:54.161	cmnfkpwhq00zrhgt4kwye95fl
cmnflmewl01x0hgt4hn0n4cho	cmnfle3pn01o8hgt4gpfy0lvy	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:54.165	2026-04-01 05:21:54.165	cmnfkpwhq00zrhgt4kwye95fl
cmnflmewp01x1hgt4tctfhqmx	cmnfle3le01nphgt4wel7vs62	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:54.169	2026-04-01 05:21:54.169	cmnfkpwhq00zrhgt4kwye95fl
cmnflmews01x2hgt497yxco5d	cmnfle3ir01nbhgt4jy6i83qe	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:54.172	2026-04-01 05:21:54.172	cmnfkpwhq00zrhgt4kwye95fl
cmnflmeww01x3hgt4vmk909zi	cmnfle3v101ozhgt49we50qqi	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:54.176	2026-04-01 05:21:54.176	cmnfkpwhq00zrhgt4kwye95fl
cmnflmex001x4hgt4z3or9ede	cmnfle3ge01muhgt4ny4sp0t5	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:54.181	2026-04-01 05:21:54.181	cmnfkpwhq00zrhgt4kwye95fl
cmnflmex501x5hgt4wi8y9l18	cmnfle3e501mchgt4rr9080so	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:21:54.185	2026-04-01 05:21:54.185	cmnfkpwhq00zrhgt4kwye95fl
cmnflmljx01x6hgt4wsd6ntmv	cmnfle36m01kwhgt43nive3ld	cmnffta06000068t4x50l5rq5	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:22:02.781	2026-04-01 05:22:02.781	\N
cmnflmlkj01x9hgt425xqvs0k	cmnfle36u01kxhgt4mmiv0gc4	cmnffta06000068t4x50l5rq5	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:02.803	2026-04-01 05:22:02.803	\N
cmnflmlko01xahgt4i34w1clc	cmnfle36z01kyhgt4qgsm8mbz	cmnffta06000068t4x50l5rq5	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:02.808	2026-04-01 05:22:02.808	\N
cmnflrzju023ehgt4r44g68fd	cmnflr32v01zrhgt49ju2o1tz	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:26:14.202	2026-04-01 05:26:14.202	cmnfkv8t7010bhgt4yrqs8e67
cmnflrzkp023hhgt40akvkfbu	cmnflr39k020zhgt4ltg4vlby	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:26:14.233	2026-04-01 05:26:14.233	cmnfkv8t7010bhgt4yrqs8e67
cmnflrzku023ihgt4goh25uu7	cmnflr3g80221hgt4gj8k6dzt	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:26:14.238	2026-04-01 05:26:14.238	cmnfkv8t7010bhgt4yrqs8e67
cmnflrzky023jhgt406t0ipzs	cmnflr3gh0222hgt4bobiwywf	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:26:14.242	2026-04-01 05:26:14.242	cmnfkv8t7010bhgt4yrqs8e67
cmnfmav28026whgt46k8ezvpu	cmnfm20gq024xhgt4pxld0ev1	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-01 05:40:54.848	2026-04-01 05:40:54.848	\N
cmng2x2a00031rkt4ucz7xtfx	cmnfm20ft024shgt4mn8vs293	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 13:26:04.488	2026-04-01 13:26:04.488	\N
cmng2x3od0032rkt4v7xkz54h	cmnfm20g0024thgt4eksxyb8r	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 13:26:06.301	2026-04-01 13:26:06.301	\N
cmng2x4z50033rkt4sdyjz4zl	cmnfm20fk024rhgt4jpg7vywn	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 13:26:07.985	2026-04-01 13:26:07.985	\N
cmng38yha006brkt4tm31piwu	cmng38yh6006arkt4fj4529dx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.438	2026-04-01 13:35:19.438	\N
cmng38yht006erkt4i87h361h	cmng38yhn006drkt4hfxze3h3	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.457	2026-04-01 13:35:19.457	\N
cmng38yi5006grkt468rqse52	cmng38yi0006frkt4n5ix23b5	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.47	2026-04-01 13:35:19.47	\N
cmng38yij006irkt4qntrdiu9	cmng38yia006hrkt40dui77y7	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.483	2026-04-01 13:35:19.483	\N
cmng38yix006krkt437ozq0to	cmng38yio006jrkt4fzr8dnuv	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.497	2026-04-01 13:35:19.497	\N
cmng38yj7006mrkt4c8wwpwl0	cmng38yj2006lrkt4hnmow2ft	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.507	2026-04-01 13:35:19.507	\N
cmng38yji006orkt42fjhmegx	cmng38yjc006nrkt43goiahih	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.518	2026-04-01 13:35:19.518	\N
cmng38yk3006rrkt4qloz83xw	cmng38yjw006qrkt4saxiy9qw	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.539	2026-04-01 13:35:19.539	\N
cmng38ylo006zrkt41boxe3w3	cmng38ylh006yrkt4jz2c16vh	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.596	2026-04-01 13:35:19.596	\N
cmng38ymf0073rkt40djfulem	cmng38ym80072rkt48bxqjnaq	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.623	2026-04-01 13:35:19.623	\N
cmng38ymt0075rkt4gbx2ju95	cmng38ymm0074rkt49qumjrdn	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.637	2026-04-01 13:35:19.637	\N
cmng38yn50077rkt4hae841pf	cmng38ymx0076rkt4o8xrjd2b	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.649	2026-04-01 13:35:19.649	\N
cmng38ynj0079rkt42gn9tg6y	cmng38ynb0078rkt4z6dg1j5i	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.663	2026-04-01 13:35:19.663	\N
cmng38ypg007hrkt4qeqgvzfl	cmng38yp1007grkt4wvx4h8bp	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:19.732	2026-04-01 13:35:19.732	\N
cmng38yqg007krkt4vywfowyh	cmng38yq4007jrkt4m2wvbgv5	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.768	2026-04-01 13:35:19.768	\N
cmng38yrf007mrkt4jix7mzyr	cmng38yqn007lrkt4d38gj3l4	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.803	2026-04-01 13:35:19.803	\N
cmng38ysc007qrkt4owts4khk	cmng38ys6007prkt4ggp6fxch	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.836	2026-04-01 13:35:19.836	\N
cmng38yt4007urkt4vjqpvugx	cmng38ysv007trkt4donh30l9	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.864	2026-04-01 13:35:19.864	\N
cmng38yud007zrkt4qzhrf1gy	cmng38yu5007yrkt48j5tr54k	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.909	2026-04-01 13:35:19.909	\N
cmng38yur0081rkt42e9heo4m	cmng38yuj0080rkt4wwctw700	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.923	2026-04-01 13:35:19.923	\N
cmng38yvg0085rkt4zf3qcqqg	cmng38yv90084rkt4xclfuw61	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:35:19.948	2026-04-01 13:35:19.948	\N
cmng38yw40088rkt4acovesea	cmng38yvx0087rkt4ggdnlk76	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:19.972	2026-04-01 13:35:19.972	\N
cmnfli9b201t2hgt4ith7yt7r	cmnfle2kr01iehgt4saqqa99b	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:18:40.286	2026-04-01 05:18:40.286	cmnfks7y90100hgt4htds26dj
cmnfli9bv01t5hgt4lawehw6m	cmnfle2x701jghgt4vg2aligz	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:40.315	2026-04-01 05:18:40.315	cmnfks7y90100hgt4htds26dj
cmnfli9c001t6hgt4v6d4wmnq	cmnfle38v01lahgt4sgxdp05c	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:40.32	2026-04-01 05:18:40.32	cmnfks7y90100hgt4htds26dj
cmnfli9c401t7hgt4pjqbt751	cmnfle38q01l9hgt4l7ow11lc	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:40.325	2026-04-01 05:18:40.325	cmnfks7y90100hgt4htds26dj
cmnfli9c801t8hgt49jj81wf3	cmnfle34701kihgt4ll9b8s1z	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:40.328	2026-04-01 05:18:40.328	cmnfks7y90100hgt4htds26dj
cmnfli9cc01t9hgt43dpxev83	cmnfle2vr01j7hgt4xpdya45r	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:40.332	2026-04-01 05:18:40.332	cmnfks7y90100hgt4htds26dj
cmnflmvnb01xbhgt4pppf1qs4	cmnfle3ci01lzhgt4cprfebph	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:22:15.863	2026-04-01 05:22:15.863	cmnfkrvw300zyhgt403qbk0s6
cmnflmvo301xehgt470b4kxch	cmnfle3y501pihgt4a41aras5	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:15.891	2026-04-01 05:22:15.891	cmnfkrvw300zyhgt403qbk0s6
cmnflmvo901xfhgt4c52ndvub	cmnfle3ji01nfhgt4t0mgxqyp	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:15.897	2026-04-01 05:22:15.897	cmnfkrvw300zyhgt403qbk0s6
cmnflmvoe01xghgt4psrs922h	cmnfle3vl01p2hgt41g6axixq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:15.902	2026-04-01 05:22:15.902	cmnfkrvw300zyhgt403qbk0s6
cmnflmvoj01xhhgt4ew7245av	cmnfle3lx01nrhgt4nbckyhq9	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:15.907	2026-04-01 05:22:15.907	cmnfkrvw300zyhgt403qbk0s6
cmnflmvon01xihgt4e193s4vs	cmnfle3nt01nzhgt41izmpfnh	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:15.911	2026-04-01 05:22:15.911	cmnfkrvw300zyhgt403qbk0s6
cmnfm2htk025qhgt4yfd8b6dr	cmnfm20b8024ahgt4fyc7if4c	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	MANUAL	t	2026-04-01 05:34:24.44	2026-04-01 05:34:24.44	\N
cmnfmb8au026zhgt4rbcz71tb	cmnfm2072023rhgt4eefo9onk	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-01 05:41:12.006	2026-04-01 05:41:12.006	\N
cmng2xrrf0034rkt4xun0b515	cmnfm20fb024qhgt4nxqy10wm	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 13:26:37.515	2026-04-01 13:26:37.515	\N
cmng38z0c008wrkt4op5jk6d3	cmng38z08008vrkt438l1nvm7	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.124	2026-04-01 13:35:20.124	\N
cmng38z0p008zrkt432zeo4l5	cmng38z0l008yrkt4ewh0rztq	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.138	2026-04-01 13:35:20.138	\N
cmng38z100091rkt4pylg19lq	cmng38z0u0090rkt40qwos3n1	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.148	2026-04-01 13:35:20.148	\N
cmng38z34009crkt4vu2lhp8s	cmng38z2w009brkt4xjnnv9tf	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.224	2026-04-01 13:35:20.224	\N
cmng38z4b009jrkt4kysbee17	cmng38z45009irkt4qieq5re4	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.267	2026-04-01 13:35:20.267	\N
cmng38z4k009lrkt42t4p7xai	cmng38z4f009krkt4cyl4o77d	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.276	2026-04-01 13:35:20.276	\N
cmng38z6c009wrkt4y8pxcmhp	cmng38z66009vrkt4n45wth5s	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.34	2026-04-01 13:35:20.34	\N
cmng38z8g00a5rkt4b09emhgn	cmng38z8800a4rkt4vbgt5ata	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.416	2026-04-01 13:35:20.416	\N
cmng38z9p00aarkt4w160htnl	cmng38z9h00a9rkt493fw5grx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.461	2026-04-01 13:35:20.461	\N
cmng38zai00afrkt4jipjtto2	cmng38zae00aerkt4dwtxobnu	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.49	2026-04-01 13:35:20.49	\N
cmng38zat00ahrkt4u3f1dfko	cmng38zan00agrkt43gvkzxms	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:35:20.501	2026-04-01 13:35:20.501	\N
cmng38zdl00avrkt42i6fegeb	cmng38zdh00aurkt4t9l30epi	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:20.601	2026-04-01 13:35:20.601	\N
cmng38zdr00axrkt4cxjvdg4g	cmng38zdn00awrkt4sakrlz56	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:20.607	2026-04-01 13:35:20.607	\N
cmng38ze100azrkt4xq73b8tc	cmng38zdv00ayrkt4hdb6f08t	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.617	2026-04-01 13:35:20.617	\N
cmng38zee00b1rkt4r980izg7	cmng38ze600b0rkt412b7sx9o	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.63	2026-04-01 13:35:20.63	\N
cmng38zex00b4rkt4ojsabpo2	cmng38zeq00b3rkt4hwpdq0n2	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.649	2026-04-01 13:35:20.649	\N
cmng38zfa00b6rkt4aiyipn6o	cmng38zf300b5rkt4r5mo6joz	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.662	2026-04-01 13:35:20.662	\N
cmng38zfz00barkt4o75pchgl	cmng38zfs00b9rkt47cjirova	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:20.687	2026-04-01 13:35:20.687	\N
cmng38zg900bcrkt4fde84u0f	cmng38zg300bbrkt4cir5co7d	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:20.697	2026-04-01 13:35:20.697	\N
cmng38zi400blrkt481i1809b	cmng38zhw00bkrkt4taxn62ub	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:35:20.764	2026-04-01 13:35:20.764	\N
cmng38ziq00borkt47xf1rrxo	cmng38zij00bnrkt4hifsypc4	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:20.786	2026-04-01 13:35:20.786	\N
cmng38zm200c4rkt42pxtllrg	cmng38zlw00c3rkt4600aaobc	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:20.906	2026-04-01 13:35:20.906	\N
cmng38zme00c6rkt4ag5a76it	cmng38zm800c5rkt4p84t6zee	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:20.918	2026-04-01 13:35:20.918	\N
cmng38zod00chrkt4tgkpxedh	cmng38zo900cgrkt4l2ikxv8c	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:35:20.989	2026-04-01 13:35:20.989	\N
cmng38zpj00corkt4l86pjsbx	cmng38zpc00cnrkt4bct5pk6q	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:21.031	2026-04-01 13:35:21.031	\N
cmng38zrj00cxrkt42iauhudf	cmng38zre00cwrkt4dy4d6tzb	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:35:21.103	2026-04-01 13:35:21.103	\N
cmng38zrv00czrkt432pwbqz8	cmng38zrn00cyrkt43fq6jqfe	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:21.115	2026-04-01 13:35:21.115	\N
cmng38zsf00d2rkt4426vnrgj	cmng38zs900d1rkt4xwieh95p	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:35:21.135	2026-04-01 13:35:21.135	\N
cmng38zso00d4rkt4ddhs4o2s	cmng38zsi00d3rkt4gf1431qm	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:35:21.144	2026-04-01 13:35:21.144	\N
cmng38zt000d6rkt4i3dgg0bg	cmng38zst00d5rkt48lnavqbf	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:35:21.156	2026-04-01 13:35:21.156	\N
cmng38ztm00d9rkt4hmz3dvs3	cmng38zte00d8rkt4ub3sercv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:21.178	2026-04-01 13:35:21.178	\N
cmng38ztx00dbrkt4u39l72da	cmng38ztr00darkt4s4jn8og0	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:21.189	2026-04-01 13:35:21.189	\N
cmng38zub00ddrkt4etoocw9u	cmng38zu400dcrkt4mlm2hdma	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:21.203	2026-04-01 13:35:21.203	\N
cmnflik0d01tahgt42f6zooni	cmnfle2mk01ifhgt41ivl241m	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:18:54.157	2026-04-01 05:18:54.157	cmnfkpwhq00zrhgt4kwye95fl
cmnflik1401tdhgt4trt7gfjb	cmnfle33u01kghgt4ax1knpdr	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:54.184	2026-04-01 05:18:54.184	cmnfkpwhq00zrhgt4kwye95fl
cmnflik1801tehgt45xd1wcet	cmnfle2sy01iuhgt4hr14x6iz	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:54.188	2026-04-01 05:18:54.188	cmnfkpwhq00zrhgt4kwye95fl
cmnflik1c01tfhgt4o7f17vej	cmnfle38k01l8hgt4znwuznnx	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:54.192	2026-04-01 05:18:54.192	cmnfkpwhq00zrhgt4kwye95fl
cmnflik1f01tghgt4dx8k2bc6	cmnfle2yr01jphgt4uxv9fbn5	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:54.195	2026-04-01 05:18:54.195	cmnfkpwhq00zrhgt4kwye95fl
cmnflik1j01thhgt4voum09lf	cmnfle37i01l1hgt43pkcczbs	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:18:54.199	2026-04-01 05:18:54.199	cmnfkpwhq00zrhgt4kwye95fl
cmnfln7xh01xjhgt4zk61rkcx	cmnfle3cv01m2hgt49549xayg	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:22:31.781	2026-04-01 05:22:31.781	cmnfkvkyn010dhgt4qymxazu8
cmnfln7y801xmhgt4d1hnjlsk	cmnfle3x801pchgt4msgglhpf	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:31.808	2026-04-01 05:22:31.808	cmnfkvkyn010dhgt4qymxazu8
cmnfln7ye01xnhgt4f7ub4w5o	cmnfle3t801oqhgt43q7xl61n	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:31.814	2026-04-01 05:22:31.814	cmnfkvkyn010dhgt4qymxazu8
cmnfln7yj01xohgt4xr8p7w7f	cmnfle3kd01nkhgt40lx4m2f9	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:31.819	2026-04-01 05:22:31.819	cmnfkvkyn010dhgt4qymxazu8
cmnfln7yo01xphgt4g3cdjpp8	cmnfle3hx01n5hgt460x6pg8q	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:31.824	2026-04-01 05:22:31.824	cmnfkvkyn010dhgt4qymxazu8
cmnfln7yu01xqhgt48s33gi9l	cmnfle3es01mhhgt4wi58vmfv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:31.83	2026-04-01 05:22:31.83	cmnfkvkyn010dhgt4qymxazu8
cmnfln7yy01xrhgt4ewjhn0f9	cmnfle3dk01m8hgt4ebxw85x4	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:31.835	2026-04-01 05:22:31.835	cmnfkvkyn010dhgt4qymxazu8
cmnfln7z301xshgt4ykvo358q	cmnfle3rb01oghgt4b58mj8cc	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:31.839	2026-04-01 05:22:31.839	cmnfkvkyn010dhgt4qymxazu8
cmnfm2vcr025thgt43kc3i7pg	cmnfm20lk025ihgt4j7pkjx9i	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-01 05:34:41.979	2026-04-01 05:34:41.979	\N
cmnfm2vdj025whgt4ct43xs3f	cmnfm20gj024whgt4swzii6om	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 05:34:42.007	2026-04-01 05:34:42.007	\N
cmnfm2vdo025xhgt4jy4g9d5d	cmnfm20g5024uhgt43iks57d0	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 05:34:42.012	2026-04-01 05:34:42.012	\N
cmnfmeai50272hgt4ko2k5vlj	cmnfm208n023zhgt4u1hodgbf	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 05:43:34.829	2026-04-01 05:43:34.829	\N
cmng2zdn00035rkt4uedba72g	cmnfm20cy024ghgt4q41nkdrw	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 13:27:52.524	2026-04-01 13:27:52.524	\N
cmng38zuu00dgrkt42m07npuq	cmng38zup00dfrkt4dwakyms4	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:35:21.222	2026-04-01 13:35:21.222	\N
cmng38zvr00dlrkt4hqtd2gdd	cmng38zvm00dkrkt4zgser4he	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:35:21.255	2026-04-01 13:35:21.255	\N
cmng38zwm00dqrkt4snpu2iha	cmng38zwi00dprkt4ltqw4r1f	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:35:21.286	2026-04-01 13:35:21.286	\N
cmng38zx900durkt4ixvtwml1	cmng38zx300dtrkt4806nuc02	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:35:21.309	2026-04-01 13:35:21.309	\N
cmng38zxz00dyrkt4vcaz90nb	cmng38zxu00dxrkt43pnqczvy	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:35:21.335	2026-04-01 13:35:21.335	\N
cmng38zyj00e2rkt4r15lixjc	cmng38zyf00e1rkt4emxzs6yy	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:35:21.355	2026-04-01 13:35:21.355	\N
cmng38zza00e6rkt4uimvpo9v	cmng38zz100e5rkt4afvrrfx9	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:35:21.382	2026-04-01 13:35:21.382	\N
cmng3900000earkt4oh04ylei	cmng38zzu00e9rkt4pitj99qw	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:35:21.409	2026-04-01 13:35:21.409	\N
cmng3900b00ecrkt4wbedmw7u	cmng3900600ebrkt4rj1y45se	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:35:21.419	2026-04-01 13:35:21.419	\N
cmng3bfo900o5rkt4av5b675v	cmng3bfnr00o4rkt413no2jv3	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:37:15.033	2026-04-01 13:37:15.033	\N
cmng3bfop00o7rkt4hz75i80b	cmng3bfoj00o6rkt4hx9ncan1	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:15.049	2026-04-01 13:37:15.049	\N
cmng3bfp700oarkt4lebbfhur	cmng3bfp100o9rkt4vcbqfw67	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-01 13:37:15.067	2026-04-01 13:37:15.067	\N
cmng3bfpm00odrkt49fvzdgr6	cmng3bfph00ocrkt4zoz11hi2	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:37:15.082	2026-04-01 13:37:15.082	\N
cmng3bglx00sdrkt4d62qkw7n	cmng3bglk00scrkt4lgp7txo1	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:37:16.245	2026-04-01 13:37:16.245	\N
cmng3bgmi00sgrkt4rymc54l6	cmng3bgmc00sfrkt4axnmxvqx	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:37:16.266	2026-04-01 13:37:16.266	\N
cmng3bgn100sjrkt4t3v2covq	cmng3bgmw00sirkt4lkwf2q8k	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:37:16.285	2026-04-01 13:37:16.285	\N
cmng3bgnd00slrkt4kng7cco0	cmng3bgn500skrkt4zzahbem1	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 13:37:16.297	2026-04-01 13:37:16.297	\N
cmnge565g00v6rkt4y44l9e9v	cmng38ywa0089rkt42u2woq9k	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.532	2026-04-01 18:40:18.532	\N
cmnge566m00v7rkt4sq6eg7fe	cmng38z7p00a2rkt43uwf3obz	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.574	2026-04-01 18:40:18.574	\N
cmnge567x00v8rkt4iphciequ	cmng38ydw005urkt4lsu2lvk1	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.621	2026-04-01 18:40:18.621	\N
cmnge569d00v9rkt4w9dlh8pg	cmng38yoa007drkt49a6jljrw	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.673	2026-04-01 18:40:18.673	\N
cmnge56ao00varkt4oont51wy	cmng38yrj007nrkt4ffg3d50q	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.72	2026-04-01 18:40:18.72	\N
cmnge56ce00vbrkt4fm39yu85	cmng38yjn006prkt4ddr2gias	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.782	2026-04-01 18:40:18.782	\N
cmnge56e400vcrkt4xu73xb1d	cmng38z1d0094rkt4n9oqqq6e	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.844	2026-04-01 18:40:18.844	\N
cmnge56fe00vdrkt45fy7np97	cmng38z130092rkt4c0x2b9mq	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.891	2026-04-01 18:40:18.891	\N
cmnge56gq00verkt4rsyskqj3	cmng38z3m009frkt4arrwlngw	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.938	2026-04-01 18:40:18.938	\N
cmnge56hs00vfrkt4kzkixezr	cmng38z170093rkt4lh3sx5jw	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:18.976	2026-04-01 18:40:18.976	\N
cmnge56jd00vgrkt45xb4vn8o	cmng38za800adrkt4x0by748c	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:19.033	2026-04-01 18:40:19.033	\N
cmnfliulh01tihgt4yq8bz4fi	cmnfle2o001ighgt47s5hlmfb	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:19:07.877	2026-04-01 05:19:07.877	cmnfkpf0u00zohgt40qewt2f3
cmnfliumi01tlhgt489n4xch7	cmnfle3fj01mnhgt49zguzyvq	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.914	2026-04-01 05:19:07.914	cmnfkpf0u00zohgt40qewt2f3
cmnfliumo01tmhgt4j9ra9cso	cmnfle3so01onhgt40m5u20yj	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.92	2026-04-01 05:19:07.92	cmnfkpf0u00zohgt40qewt2f3
cmnfliums01tnhgt4619odj76	cmnfle34c01kjhgt4gg3ig6nb	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.924	2026-04-01 05:19:07.924	cmnfkpf0u00zohgt40qewt2f3
cmnfliumx01tohgt470bgserx	cmnfle3oh01o2hgt48ye5a16p	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.929	2026-04-01 05:19:07.929	cmnfkpf0u00zohgt40qewt2f3
cmnfliun201tphgt4hxwmwite	cmnfle3hs01n4hgt4bkwb3sdm	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.934	2026-04-01 05:19:07.934	cmnfkpf0u00zohgt40qewt2f3
cmnfliun701tqhgt4i3l653f6	cmnfle2u501izhgt428pus36j	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.939	2026-04-01 05:19:07.939	cmnfkpf0u00zohgt40qewt2f3
cmnfliunc01trhgt4vhnzbuz8	cmnfle32j01k7hgt4nrzx7gm7	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.944	2026-04-01 05:19:07.944	cmnfkpf0u00zohgt40qewt2f3
cmnfliunh01tshgt4606hxidg	cmnfle3xj01pehgt4oh8hyfhu	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.949	2026-04-01 05:19:07.949	cmnfkpf0u00zohgt40qewt2f3
cmnfliunm01tthgt4afp5yten	cmnfle3bg01lrhgt4x57g7ai9	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.954	2026-04-01 05:19:07.954	cmnfkpf0u00zohgt40qewt2f3
cmnfliunq01tuhgt4axezfr4k	cmnfle3cz01m3hgt41vvsr6c6	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.958	2026-04-01 05:19:07.958	cmnfkpf0u00zohgt40qewt2f3
cmnfliunu01tvhgt4ejsux360	cmnfle34j01kkhgt4fhvi2b9i	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.962	2026-04-01 05:19:07.962	cmnfkpf0u00zohgt40qewt2f3
cmnfliunz01twhgt4xg6u57fd	cmnfle3nb01nxhgt4wmw9puri	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.967	2026-04-01 05:19:07.967	cmnfkpf0u00zohgt40qewt2f3
cmnfliuo401txhgt4psgdk31m	cmnfle2x101jfhgt441c931mx	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:07.972	2026-04-01 05:19:07.972	cmnfkpf0u00zohgt40qewt2f3
cmnflni0j01xthgt44t0ww9g4	cmnfle3dd01m6hgt4ecn0raj7	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:22:44.851	2026-04-01 05:22:44.851	cmnfkvrla010ehgt4pntoyk13
cmnflni1a01xwhgt4g0lqv7fm	cmnfle3iy01nchgt4xnakai5w	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:44.878	2026-04-01 05:22:44.878	cmnfkvrla010ehgt4pntoyk13
cmnflni1f01xxhgt4c9mczpxu	cmnfle3zc01pqhgt4idfzebdt	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:44.883	2026-04-01 05:22:44.883	cmnfkvrla010ehgt4pntoyk13
cmnflni1j01xyhgt4224kww0j	cmnfle3s401okhgt4fjpbcze0	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:44.887	2026-04-01 05:22:44.887	cmnfkvrla010ehgt4pntoyk13
cmnflni1n01xzhgt4rz8d8gut	cmnfle3g501mshgt4sgxeax7w	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:44.892	2026-04-01 05:22:44.892	cmnfkvrla010ehgt4pntoyk13
cmnflni1s01y0hgt4mgpbsaqv	cmnfle3k601njhgt4hiyj6e6u	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:44.896	2026-04-01 05:22:44.896	cmnfkvrla010ehgt4pntoyk13
cmnflni1v01y1hgt44i7fk1hz	cmnfle3r501ofhgt4rn0n1dx8	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:44.9	2026-04-01 05:22:44.9	cmnfkvrla010ehgt4pntoyk13
cmnfm360k025yhgt4yfnd74yl	cmnfm208i023yhgt46rdmhm3c	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-01 05:34:55.796	2026-04-01 05:34:55.796	\N
cmnfm361w0261hgt4394pw6nv	cmnfm208b023xhgt4jypczed2	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 05:34:55.844	2026-04-01 05:34:55.844	\N
cmnfmg67u0273hgt40418ezf9	cmnfm209m0243hgt4hrgoyg6m	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 05:45:02.586	2026-04-01 05:45:02.586	\N
cmng30nrl0038rkt4atwccz91	cmnfm20kt025ehgt4pxw0f6g9	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 13:28:52.305	2026-04-01 13:28:52.305	\N
cmng30p8s0039rkt4h5p92fvr	cmnfm207r023uhgt40mpmg8rv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 13:28:54.221	2026-04-01 13:28:54.221	\N
cmng30qgn003arkt4cukzr30y	cmnfm20900241hgt42wmbjy7b	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 13:28:55.8	2026-04-01 13:28:55.8	\N
cmng30rri003brkt4nwtt3hww	cmnfm20f5024phgt47eicbfuh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 13:28:57.486	2026-04-01 13:28:57.486	\N
cmng3bf1r00m2rkt47a268r8g	cmng3bf1k00m1rkt43y0gq6dv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:14.223	2026-04-01 13:37:14.223	\N
cmng3bfqn00oirkt4gv0ykl64	cmng3bfqi00ohrkt47jt1s267	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 13:37:15.119	2026-04-01 13:37:15.119	\N
cmngcex8d00sprkt4xtcdo63y	cmng3bgfu00rqrkt4ew2c5vxr	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:51:54.301	2026-04-01 17:51:54.301	\N
cmngcezof00sqrkt4fcx2dq4d	cmng3bgf400rnrkt4kwuz8ywy	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:51:57.471	2026-04-01 17:51:57.471	\N
cmngcf1nd00srrkt482xzcib9	cmng3bgfc00rorkt4s7kczafw	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:00.025	2026-04-01 17:52:00.025	\N
cmngcf42h00ssrkt47pqdfmf0	cmng3bgfk00rprkt4mnrgebtn	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:03.161	2026-04-01 17:52:03.161	\N
cmngcf6ek00strkt403d1f9ws	cmng3bggh00rtrkt4mob3fj4o	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:06.188	2026-04-01 17:52:06.188	\N
cmngcf8g600surkt43iccdor4	cmng38zvf00djrkt43nodtrxw	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:08.838	2026-04-01 17:52:08.838	\N
cmngcfapb00svrkt41l87rflt	cmng38zqu00curkt4rb4f8h2c	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:11.759	2026-04-01 17:52:11.759	\N
cmngcfcgz00swrkt4qgdpobcv	cmng38ykh006trkt4i4rae45t	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:14.051	2026-04-01 17:52:14.051	\N
cmngcfe0700sxrkt4r22myiab	cmng38ykb006srkt4f611r6nt	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:16.039	2026-04-01 17:52:16.039	\N
cmngcfh2u00syrkt4x18jlskp	cmng38zug00derkt4lum2d48t	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:20.022	2026-04-01 17:52:20.022	\N
cmngcfj0500szrkt4lphqq7pf	cmng38zvu00dmrkt45b7zjusd	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:22.517	2026-04-01 17:52:22.517	\N
cmngcfkfy00t0rkt4pt9pmd3s	cmng38yxv008grkt4jnwojoek	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:24.382	2026-04-01 17:52:24.382	\N
cmngcfm5q00t1rkt4cu6crfru	cmng38yy4008hrkt4rjdf6qf4	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:26.606	2026-04-01 17:52:26.606	\N
cmngcfopq00t2rkt4b1sp1yzt	cmng38ykw006vrkt46nxtdetj	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:29.918	2026-04-01 17:52:29.918	\N
cmngcfqgd00t3rkt4jgq0uclx	cmng38zt600d7rkt4m3xrp4tq	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:32.173	2026-04-01 17:52:32.173	\N
cmngcfs6000t4rkt42s294298	cmng38yl4006wrkt4gzmnfc8g	cmng2hy95002yrkt4805y33j9	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:52:34.392	2026-04-01 17:52:34.392	\N
cmnflj59z01tyhgt4ydh0976z	cmnfle2ou01ihhgt4rc5o8x3l	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:19:21.719	2026-04-01 05:19:21.719	cmnfkrvw300zyhgt403qbk0s6
cmnflj5as01u1hgt4lx7t1rue	cmnfle33f01kdhgt4pk7q96vx	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:21.748	2026-04-01 05:19:21.748	cmnfkrvw300zyhgt403qbk0s6
cmnflj5ax01u2hgt4we6y4ptb	cmnfle2xq01jjhgt43aldbtmy	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:21.753	2026-04-01 05:19:21.753	cmnfkrvw300zyhgt403qbk0s6
cmnflj5b101u3hgt4khcr7qc2	cmnfle3at01lnhgt48nbo9rfy	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:21.757	2026-04-01 05:19:21.757	cmnfkrvw300zyhgt403qbk0s6
cmnflj5b601u4hgt4yxlx076y	cmnfle3b101lohgt4g8yrr1ts	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:21.762	2026-04-01 05:19:21.762	cmnfkrvw300zyhgt403qbk0s6
cmnflj5ba01u5hgt46dknitg8	cmnfle2v201j3hgt48he6hvz6	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:21.766	2026-04-01 05:19:21.766	cmnfkrvw300zyhgt403qbk0s6
cmnflnr6501y2hgt4i315805a	cmnfle3dy01mbhgt420c4a6tu	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:22:56.717	2026-04-01 05:22:56.717	cmnfks7y90100hgt4htds26dj
cmnflnr6x01y5hgt4wjahs0hz	cmnfle3t201ophgt47gdr9ga6	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:56.745	2026-04-01 05:22:56.745	cmnfks7y90100hgt4htds26dj
cmnflnr7301y6hgt4axnkyecr	cmnfle3qx01oehgt416x343yv	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:56.751	2026-04-01 05:22:56.751	cmnfks7y90100hgt4htds26dj
cmnflnr7801y7hgt4q52rz7d9	cmnfle3ei01mfhgt40n2ezje9	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:56.756	2026-04-01 05:22:56.756	cmnfks7y90100hgt4htds26dj
cmnflnr7d01y8hgt4gyxb3tyy	cmnfle3yf01pkhgt4yotq1rff	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:56.761	2026-04-01 05:22:56.761	cmnfks7y90100hgt4htds26dj
cmnflnr7h01y9hgt441o0vi2a	cmnfle3nl01nyhgt448c50s0w	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:56.765	2026-04-01 05:22:56.765	cmnfks7y90100hgt4htds26dj
cmnflnr7n01yahgt4sw0ihzpx	cmnfle3i501n7hgt4d4c6xob8	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:22:56.771	2026-04-01 05:22:56.771	cmnfks7y90100hgt4htds26dj
cmnfm4cus0262hgt47bzzkird	cmnfm20aj0247hgt4yfc7g0jo	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 05:35:51.316	2026-04-01 05:35:51.316	\N
cmnfm4cvh0265hgt48g52hklc	cmnfm20br024chgt4zv44m096	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 05:35:51.341	2026-04-01 05:35:51.341	\N
cmnfmgnl00274hgt4hr18noli	cmnfm20ez024ohgt4si9u9xk4	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 05:45:25.092	2026-04-01 05:45:25.092	\N
cmng31j94003crkt40jf19m7i	cmnfm207i023thgt4il89yqkh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsa00054wt4rildbdz8	MANUAL	t	2026-04-01 13:29:33.112	2026-04-01 13:29:33.112	\N
cmng31kj8003drkt4gbdev8x7	cmnfm209v0244hgt4u7gwvrzy	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsa00054wt4rildbdz8	MANUAL	t	2026-04-01 13:29:34.772	2026-04-01 13:29:34.772	\N
cmng31ltm003erkt4tare9cms	cmnfm2055023lhgt4cfsoaqqp	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsa00054wt4rildbdz8	MANUAL	t	2026-04-01 13:29:36.442	2026-04-01 13:29:36.442	\N
cmng3bf4x00mgrkt4103fqtsx	cmng3bf4s00mfrkt497avncki	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:37:14.337	2026-04-01 13:37:14.337	\N
cmng3bf5d00mirkt46jtralc6	cmng3bf5500mhrkt47k3uufxu	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 13:37:14.353	2026-04-01 13:37:14.353	\N
cmng3bfrl00omrkt4p1idb04y	cmng3bfr300olrkt4wuoltte5	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:37:15.153	2026-04-01 13:37:15.153	\N
cmng3bfry00oorkt4ph0edl0f	cmng3bfrt00onrkt49nwemfwz	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	AUTOMATICA	t	2026-04-01 13:37:15.166	2026-04-01 13:37:15.166	\N
cmngcn7yf00t5rkt4k2d4g5cl	cmng3bg7h00qqrkt4cnqlpkei	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:58:21.447	2026-04-01 17:58:21.447	\N
cmngcne3a00t6rkt4qygz8zeo	cmng3bg4700qbrkt403pyu1xu	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:58:29.398	2026-04-01 17:58:29.398	\N
cmngcnj1x00t7rkt42nmibfb9	cmng3bgcf00rcrkt4m1l6nx4w	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 17:58:35.829	2026-04-01 17:58:35.829	\N
cmnge56kn00vhrkt4ff0s8ivi	cmng38znt00cdrkt4pi109r79	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:19.079	2026-04-01 18:40:19.079	\N
cmnge56m000virkt41gw7ui1p	cmng38zcq00aqrkt4o905zhf1	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:19.128	2026-04-01 18:40:19.128	\N
cmnge56na00vjrkt4vg2g64g3	cmng38zmz00c9rkt40aeh1yzf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:19.174	2026-04-01 18:40:19.174	\N
cmnge56oz00vkrkt4cj74lg88	cmng38y7y004trkt4g9q23y5k	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:19.235	2026-04-01 18:40:19.235	\N
cmnge56qh00vlrkt4zqlzmbid	cmng38z250098rkt4jqc5lwkz	cmnfig5t40005rgt4visli2qu	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:40:19.289	2026-04-01 18:40:19.289	\N
cmnge9svq00vqrkt41zr9id3r	cmng3bfwm00p8rkt4rgdntgqy	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.614	2026-04-01 18:43:54.614	\N
cmnge9sx600vrrkt4cl1os91s	cmng3bfsr00orrkt4qmhoaa11	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.666	2026-04-01 18:43:54.666	\N
cmnge9syx00vsrkt45m2ve40k	cmng3bg1q00pzrkt4v0nf9812	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.729	2026-04-01 18:43:54.729	\N
cmnge9t0l00vtrkt4zzxue1c2	cmng3bf2s00m7rkt4y9t0llui	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.789	2026-04-01 18:43:54.789	\N
cmnge9t2b00vurkt4pwvg93sy	cmng3bg4f00qcrkt4cwt0sp44	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.851	2026-04-01 18:43:54.851	\N
cmnge9t3l00vvrkt4fsio8bjl	cmng3bfxy00pgrkt4avdvphf7	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.897	2026-04-01 18:43:54.897	\N
cmnge9t4t00vwrkt455dkzghc	cmng3bf3s00mcrkt4u8hclywo	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.941	2026-04-01 18:43:54.941	\N
cmnge9t6400vxrkt4ag7b0pia	cmng3bf1100lyrkt4c6yyc2u9	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:54.989	2026-04-01 18:43:54.989	\N
cmnge9t7k00vyrkt4q8jvhykh	cmng3bf2k00m6rkt49grtu895	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:55.041	2026-04-01 18:43:55.041	\N
cmnge9t9300vzrkt43zxr946i	cmng38y7p004srkt460ynh0kv	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:55.095	2026-04-01 18:43:55.095	\N
cmnge9tan00w0rkt418hqel0r	cmng38ynw007brkt4liaudwf8	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:55.151	2026-04-01 18:43:55.151	\N
cmnge9tc200w1rkt4biva7skr	cmng38ybf005irkt4w8ebha5u	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:55.202	2026-04-01 18:43:55.202	\N
cmnge9tdf00w2rkt4eme2j3j7	cmng38y1v003xrkt4pvdoce1w	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:55.251	2026-04-01 18:43:55.251	\N
cmnge9teo00w3rkt4fuu6xtk1	cmng38y2e003zrkt4svzn3ahs	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:55.296	2026-04-01 18:43:55.296	\N
cmnge9tgq00w4rkt40p5lbc6o	cmng38zn600carkt4638diuah	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:43:55.37	2026-04-01 18:43:55.37	\N
cmngej8jp00workt43hgty7gm	cmng38z5z009urkt4vghv238p	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.821	2026-04-01 18:51:14.821	\N
cmnfljfs901u6hgt41p2ugncf	cmnfle2pf01iihgt49wx4c2bi	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:19:35.337	2026-04-01 05:19:35.337	cmnfkrcpl00zxhgt4sxtmnh6n
cmnfljft201u9hgt49b9bfybx	cmnfle31j01k1hgt4mroedhid	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:35.366	2026-04-01 05:19:35.366	cmnfkrcpl00zxhgt4sxtmnh6n
cmnfljft701uahgt4s5to9ocq	cmnfle2xk01jihgt44gt3yfdw	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:35.371	2026-04-01 05:19:35.371	cmnfkrcpl00zxhgt4sxtmnh6n
cmnfljftc01ubhgt4x03tciro	cmnfle38801l6hgt4to66plnr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:35.376	2026-04-01 05:19:35.376	cmnfkrcpl00zxhgt4sxtmnh6n
cmnfljfti01uchgt4e2zk0nhx	cmnfle37x01l4hgt4l4kn6adp	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:35.382	2026-04-01 05:19:35.382	cmnfkrcpl00zxhgt4sxtmnh6n
cmnfljfto01udhgt44j383igo	cmnfle2so01ithgt4m3oa03mw	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:35.388	2026-04-01 05:19:35.388	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflo07m01ybhgt46ir1a0o2	cmnfle3ew01mihgt42nd0bdh5	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:23:08.435	2026-04-01 05:23:08.435	cmnfks14q00zzhgt47kj8x90e
cmnflo08f01yehgt4vijmrk0x	cmnfle3kz01nnhgt4tgxdy037	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:08.463	2026-04-01 05:23:08.463	cmnfks14q00zzhgt47kj8x90e
cmnflo08k01yfhgt4agmnlx7y	cmnfle3i801n8hgt4k8l2y55g	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:08.468	2026-04-01 05:23:08.468	cmnfks14q00zzhgt47kj8x90e
cmnflo08p01yghgt4pe49kaja	cmnfle3s901olhgt4ljrojw80	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:08.473	2026-04-01 05:23:08.473	cmnfks14q00zzhgt47kj8x90e
cmnflo08t01yhhgt4i7b7ylth	cmnfle3we01p7hgt4tj95rwe3	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:08.477	2026-04-01 05:23:08.477	cmnfks14q00zzhgt47kj8x90e
cmnflo08y01yihgt47vxxkkyr	cmnfle3qq01odhgt4vvu0weid	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:08.482	2026-04-01 05:23:08.482	cmnfks14q00zzhgt47kj8x90e
cmnfm4nib0266hgt4zzvazh05	cmnfm20jc0258hgt4qzp6mea8	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 05:36:05.123	2026-04-01 05:36:05.123	\N
cmnfm4nj20269hgt4h7gv32pc	cmnfm20ar0248hgt4v7u5mb02	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-01 05:36:05.15	2026-04-01 05:36:05.15	\N
cmnfmhwen0275hgt42xnok8ju	cmnfm20hs0252hgt4lxar923w	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 05:46:23.183	2026-04-01 05:46:23.183	\N
cmng32278003frkt46zikci4s	cmnfm20ea024lhgt4s4dr6k7k	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 13:29:57.668	2026-04-01 13:29:57.668	\N
cmng3bf7400morkt4epl820hw	cmng3bf6w00mnrkt4f1lxzcae	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:14.416	2026-04-01 13:37:14.416	\N
cmng3bfu200owrkt4zfvr3qlr	cmng3bfti00ovrkt4hv6r0s0s	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:15.242	2026-04-01 13:37:15.242	\N
cmng3bfvm00p4rkt4gzggupqj	cmng3bfvf00p3rkt45dpdqypj	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:15.298	2026-04-01 13:37:15.298	\N
cmngcsqwu00t8rkt472lz4435	cmng3bgd900rgrkt4phil637p	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.295	2026-04-01 18:02:39.295	\N
cmngcsqzb00t9rkt4bmlzz5aw	cmng3bgcv00rerkt4yhbmtfbh	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.383	2026-04-01 18:02:39.383	\N
cmngcsr0f00tarkt4klkkbo6r	cmng38zv800dirkt45kg6k5wy	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.423	2026-04-01 18:02:39.423	\N
cmngcsr1o00tbrkt4mm8lq4h8	cmng38znm00ccrkt4jwyctqqn	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.468	2026-04-01 18:02:39.468	\N
cmngcsr3000tcrkt45ymrjzq5	cmng38zjp00btrkt40nqplwwl	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.516	2026-04-01 18:02:39.516	\N
cmngcsr4g00tdrkt4nxw1spua	cmng38zoi00cirkt4ssmgb9v6	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.568	2026-04-01 18:02:39.568	\N
cmngcsr6600terkt4phe97zwm	cmng38zkc00bwrkt49pdmqq6i	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.63	2026-04-01 18:02:39.63	\N
cmngcsr7p00tfrkt4tt724udh	cmng38zq900csrkt4n84qrh4i	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.685	2026-04-01 18:02:39.685	\N
cmngcsr8w00tgrkt4ekt0sqt8	cmng38zoo00cjrkt4hxulei8e	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:02:39.728	2026-04-01 18:02:39.728	\N
cmnge7azn00vmrkt45zaxv6d8	cmng38yxm008frkt4g09fo93r	cmnfh60wc001ejot4uioz8q1l	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:41:58.115	2026-04-01 18:41:58.115	\N
cmngej7ob00w5rkt4u85117t9	cmng3bfyb00pirkt4q1bvbgi4	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:13.691	2026-04-01 18:51:13.691	\N
cmngej7t000w6rkt4as98itl7	cmng3bfy400phrkt4lqx8v91c	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:13.86	2026-04-01 18:51:13.86	\N
cmngej7u600w7rkt4nfhib4ja	cmng3bfzw00pqrkt4s6u8klw7	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:13.902	2026-04-01 18:51:13.902	\N
cmngej7vl00w8rkt4qno8v529	cmng3bg0v00purkt4g64maxwg	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:13.953	2026-04-01 18:51:13.953	\N
cmngej7x800w9rkt4ebf7fx29	cmng3bg0l00psrkt43kxujuhn	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.012	2026-04-01 18:51:14.012	\N
cmngej7z400warkt4lebp3vqe	cmng3bg0e00prrkt4gezo7puo	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.08	2026-04-01 18:51:14.08	\N
cmngej81i00wbrkt4eu08cfmi	cmng3bfxn00perkt4t0uuro8i	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.166	2026-04-01 18:51:14.166	\N
cmngej83j00wcrkt43sp1balc	cmng3bfyx00pmrkt4gh7v3gn9	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.239	2026-04-01 18:51:14.239	\N
cmngej85000wdrkt40p69xxqh	cmng38z6j009xrkt43ni1hfnj	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.292	2026-04-01 18:51:14.292	\N
cmngej86h00werkt4hy73e2pg	cmng38z7600a0rkt4chyey4yy	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.345	2026-04-01 18:51:14.345	\N
cmngej87t00wfrkt4okccp0wn	cmng38z5n009srkt4r87t6nrj	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.393	2026-04-01 18:51:14.393	\N
cmngej89700wgrkt4x0t483a5	cmng38z5a009qrkt4w38uvm48	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.443	2026-04-01 18:51:14.443	\N
cmngej8ah00whrkt4z5bfxo0n	cmng38z5f009rrkt4b681ezth	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.49	2026-04-01 18:51:14.49	\N
cmngej8bt00wirkt4eefd8ji7	cmng38z5s009trkt4mv7eryra	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.537	2026-04-01 18:51:14.537	\N
cmngej8da00wjrkt4w80xy8ee	cmng38z4t009nrkt40ykhh7ln	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.59	2026-04-01 18:51:14.59	\N
cmngej8ej00wkrkt4znrscnmg	cmng38z3x009hrkt40l36mrl2	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.635	2026-04-01 18:51:14.635	\N
cmngej8fu00wlrkt4hup8tksr	cmng38z8l00a6rkt4ft1r3ozj	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.682	2026-04-01 18:51:14.682	\N
cmngej8h300wmrkt4i2ai0r83	cmng38z8w00a7rkt4hfj28jid	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.727	2026-04-01 18:51:14.727	\N
cmngej8ih00wnrkt41cch553e	cmng38z4y009orkt4kuv0c8rr	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.777	2026-04-01 18:51:14.777	\N
cmnfljpr601uehgt4gvg9vmt8	cmnfle2px01ijhgt4sod4omb0	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:19:48.258	2026-04-01 05:19:48.258	cmnfkv17r010ahgt4x5dtkz2a
cmnfljprz01uhhgt4mabmkqqu	cmnfle2ug01j0hgt43m99yn2j	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:48.287	2026-04-01 05:19:48.287	cmnfkv17r010ahgt4x5dtkz2a
cmnfljps501uihgt4ddtrpe5w	cmnfle33a01kchgt411hntm31	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:48.293	2026-04-01 05:19:48.293	cmnfkv17r010ahgt4x5dtkz2a
cmnfljps901ujhgt4vmnxlw11	cmnfle31301jzhgt44zvgrl6i	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:48.297	2026-04-01 05:19:48.297	cmnfkv17r010ahgt4x5dtkz2a
cmnfljpsg01ukhgt4ff5oynmu	cmnfle36101kthgt4imet3u1x	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:48.304	2026-04-01 05:19:48.304	cmnfkv17r010ahgt4x5dtkz2a
cmnfljpsl01ulhgt4s35d43wk	cmnfle35v01kshgt4cg2r8660	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:19:48.309	2026-04-01 05:19:48.309	cmnfkv17r010ahgt4x5dtkz2a
cmnfloarn01yjhgt49jgj9k0b	cmnfle3f101mjhgt4acmrdevr	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:23:22.116	2026-04-01 05:23:22.116	cmnfksd8d0101hgt4l62jg4a7
cmnfloasi01ymhgt4v74ns987	cmnfle3gv01mxhgt4pdq5paki	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:22.146	2026-04-01 05:23:22.146	cmnfksd8d0101hgt4l62jg4a7
cmnfloasn01ynhgt4p5lf9zlk	cmnfle3l601nohgt4ku2xe423	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:22.152	2026-04-01 05:23:22.152	cmnfksd8d0101hgt4l62jg4a7
cmnflek7q01prhgt4feadjuog	cmnfle2g901i3hgt4iy48t3z9	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:15:47.798	2026-04-01 05:15:47.798	cmnfkp2vg00zmhgt4890h7c56
cmnflek8m01puhgt4vv6n6sns	cmnfle2z501jrhgt4wjhqr7yc	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:15:47.83	2026-04-01 05:15:47.83	cmnfkp2vg00zmhgt4890h7c56
cmnflek8q01pvhgt47l56r6tx	cmnfle35101knhgt4n6yh33q5	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:15:47.834	2026-04-01 05:15:47.834	cmnfkp2vg00zmhgt4890h7c56
cmnflek8u01pwhgt4p3nhpw8l	cmnfle39l01lehgt444eu0qup	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:15:47.838	2026-04-01 05:15:47.838	cmnfkp2vg00zmhgt4890h7c56
cmnflek8x01pxhgt44tdnihs6	cmnfle39e01ldhgt4n93ge469	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:15:47.841	2026-04-01 05:15:47.841	cmnfkp2vg00zmhgt4890h7c56
cmnflek9101pyhgt42wo3vba2	cmnfle2s101iqhgt4yal4qtp7	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:15:47.845	2026-04-01 05:15:47.845	cmnfkp2vg00zmhgt4890h7c56
cmnfleza001pzhgt4s8ye7sh3	cmnfle2go01i4hgt4pko8nw89	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:16:07.32	2026-04-01 05:16:07.32	cmnfkt2br0103hgt4yaylhkk7
cmnflezaw01q2hgt4es3vij4m	cmnfle36d01kvhgt43q7pos33	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:07.352	2026-04-01 05:16:07.352	cmnfkt2br0103hgt4yaylhkk7
cmnflezb101q3hgt4qmzoi7sa	cmnfle33p01kfhgt4bvkaarxn	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:07.357	2026-04-01 05:16:07.357	cmnfkt2br0103hgt4yaylhkk7
cmnflezb501q4hgt4w9we1von	cmnfle36601kuhgt4u7ssg3m0	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:07.361	2026-04-01 05:16:07.361	cmnfkt2br0103hgt4yaylhkk7
cmnflezba01q5hgt41sasomiy	cmnfle2ty01iyhgt4ahzp3tlz	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:07.366	2026-04-01 05:16:07.366	cmnfkt2br0103hgt4yaylhkk7
cmnflezbf01q6hgt4s5xjutx9	cmnfle30601jvhgt4nfet1ht4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:16:07.371	2026-04-01 05:16:07.371	cmnfkt2br0103hgt4yaylhkk7
cmnfloast01yohgt42sqtbgfg	cmnfle3vr01p3hgt4sh5p0hyr	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:22.157	2026-04-01 05:23:22.157	cmnfksd8d0101hgt4l62jg4a7
cmnfloasy01yphgt4ca514fg6	cmnfle3x201pbhgt433b7tued	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:22.162	2026-04-01 05:23:22.162	cmnfksd8d0101hgt4l62jg4a7
cmnfloat301yqhgt4kr3mf7z0	cmnfle3ow01o4hgt4wq636pop	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:22.167	2026-04-01 05:23:22.167	cmnfksd8d0101hgt4l62jg4a7
cmnfloat701yrhgt4zr0ih6rx	cmnfle3su01oohgt4n2oq5hiy	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:22.171	2026-04-01 05:23:22.171	cmnfksd8d0101hgt4l62jg4a7
cmnfloatc01yshgt4fuk07x2t	cmnfle3vx01p4hgt4pwjcu1hg	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:22.176	2026-04-01 05:23:22.176	cmnfksd8d0101hgt4l62jg4a7
cmnfloiq801ythgt4znq1uoqu	cmnfle3gr01mwhgt4vxiwxtgh	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-01 05:23:32.432	2026-04-01 05:23:32.432	cmnfkskbx0102hgt4wp2stj9s
cmnfloiqu01ywhgt4d2kmysym	cmnfle3q401oahgt4bne1o7dz	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:32.454	2026-04-01 05:23:32.454	cmnfkskbx0102hgt4wp2stj9s
cmnfloiqz01yxhgt4wwdhzu1o	cmnfle3xz01phhgt4d8h7ecfv	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:32.459	2026-04-01 05:23:32.459	cmnfkskbx0102hgt4wp2stj9s
cmnfloir401yyhgt4njihmnsq	cmnfle3sf01omhgt4a42qi7ts	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:32.464	2026-04-01 05:23:32.464	cmnfkskbx0102hgt4wp2stj9s
cmnfloir801yzhgt497tfyey3	cmnfle3kk01nlhgt4n61miyen	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:32.468	2026-04-01 05:23:32.468	cmnfkskbx0102hgt4wp2stj9s
cmnfloirc01z0hgt4h4cey96f	cmnfle3j401ndhgt4i1zt5fti	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-01 05:23:32.472	2026-04-01 05:23:32.472	cmnfkskbx0102hgt4wp2stj9s
cmnfm6m6r026ahgt4ckyzv3s6	cmnfm20m0025khgt41vxhk6w1	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 05:37:36.723	2026-04-01 05:37:36.723	\N
cmnfm6m7p026dhgt4of8cjt9l	cmnfm20mj025mhgt4fdv7vb0h	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 05:37:36.757	2026-04-01 05:37:36.757	\N
cmnfmibnu0276hgt4aw7qic84	cmnfm20hb0250hgt4n5v1kcc6	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 05:46:42.954	2026-04-01 05:46:42.954	\N
cmng33iwf003grkt4crhds272	cmnfm20l7025ghgt4gcg2lazn	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 13:31:05.967	2026-04-01 13:31:05.967	\N
cmng3bf8400mrrkt4u4h8ewqb	cmng3bf7g00mqrkt4jjf1pxvw	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:14.452	2026-04-01 13:37:14.452	\N
cmng3bf9100mtrkt4b4wx18oi	cmng3bf8k00msrkt4zn7wz8v6	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:14.485	2026-04-01 13:37:14.485	\N
cmng3bf9h00mvrkt4015gl1et	cmng3bf9a00murkt4aexx7noi	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:14.501	2026-04-01 13:37:14.501	\N
cmng3bfai00mxrkt4231o398i	cmng3bf9n00mwrkt4e4z5p697	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-01 13:37:14.538	2026-04-01 13:37:14.538	\N
cmng3bfym00pkrkt4741rx75g	cmng3bfyh00pjrkt4vqfq9g76	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 13:37:15.406	2026-04-01 13:37:15.406	\N
cmngd30p100thrkt49kq7f1db	cmng3bg6x00qnrkt47og4ktzx	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.533	2026-04-01 18:10:38.533	\N
cmngd30qv00tirkt48jod6pij	cmng3bg7400qorkt48924j22u	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.599	2026-04-01 18:10:38.599	\N
cmngd30sk00tjrkt4twm8s53b	cmng3bg1800pwrkt4tdh27xq2	cmnfig5t40005rgt4visli2qu	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.661	2026-04-01 18:10:38.661	\N
cmngd30u300tkrkt4p5rs2vmb	cmng3bgc800rbrkt48q660lzy	cmnfjiu0f002trgt4r83oahan	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:10:38.715	2026-04-01 18:10:38.715	\N
cmngej8le00wprkt4dvcdapgn	cmng38z6x009zrkt4a8eteaj7	cmng2hy95002yrkt4805y33j9	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.882	2026-04-01 18:51:14.882	\N
cmngej8n300wqrkt44bm7e71b	cmng38z7g00a1rkt479sol4ma	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:51:14.943	2026-04-01 18:51:14.943	\N
cmngenrul00wrrkt4yes8fzs5	cmng3bfxi00pdrkt4623bz585	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.461	2026-04-01 18:54:46.461	\N
cmngenrw600wsrkt47zv9yjca	cmng3bfzg00pnrkt4igea3zty	cmnfjeb71002lrgt453z02rn6	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.518	2026-04-01 18:54:46.518	\N
cmngenrxj00wtrkt4nqo9s2x1	cmng38zoz00clrkt4isrwq4j9	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.567	2026-04-01 18:54:46.567	\N
cmngenrz000wurkt4j3hz793e	cmng38ygy0069rkt4cgsl53rg	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.62	2026-04-01 18:54:46.62	\N
cmngens0b00wvrkt4q5611c8m	cmng38yb7005hrkt4rr96zhfi	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.667	2026-04-01 18:54:46.667	\N
cmngens1k00wwrkt4a1skmllg	cmng38yo4007crkt413t8p9dj	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.712	2026-04-01 18:54:46.712	\N
cmngens2t00wxrkt4kaww6lti	cmng38yd7005rrkt4gpo2ka7y	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.757	2026-04-01 18:54:46.757	\N
cmngens3z00wyrkt490m1bkcv	cmng38y7i004rrkt49vf5dvew	cmnfjiu0f002trgt4r83oahan	cmnfdbzt4000a4wt4u1f07hjs	MANUAL	t	2026-04-01 18:54:46.799	2026-04-01 18:54:46.799	\N
cmngeo9kv00wzrkt4dl4tlct9	cmnfm20co024fhgt4e56sz9yy	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 18:55:09.439	2026-04-01 18:55:09.439	\N
cmngeoxlp00x2rkt4k2pu9h9c	cmnfm20j10257hgt4bfdv23aa	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	MANUAL	t	2026-04-01 18:55:40.573	2026-04-01 18:55:40.573	\N
cmngeoxms00x5rkt44crn90ec	cmng3bgco00rdrkt4hpuxlbjz	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.612	2026-04-01 18:55:40.612	\N
cmngeoxmz00x6rkt4l8wr31yz	cmng38zj300bqrkt4olq9qdsp	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.619	2026-04-01 18:55:40.619	\N
cmngeoxn300x7rkt46weij46v	cmng38zdb00atrkt434grlomn	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.623	2026-04-01 18:55:40.623	\N
cmngeoxn800x8rkt44lz3bbe0	cmng38zcy00arrkt4t8qwb8o6	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.628	2026-04-01 18:55:40.628	\N
cmngeoxne00x9rkt4wnvy9u0o	cmng38zbr00amrkt4i5j14jad	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.634	2026-04-01 18:55:40.634	\N
cmngeoxnk00xarkt4okyygt4n	cmng38zbk00alrkt4ts20rcs4	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.64	2026-04-01 18:55:40.64	\N
cmngeoxnq00xbrkt4h32kfahk	cmng3bg4t00qerkt4uvvn8uwf	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.646	2026-04-01 18:55:40.646	\N
cmngeoxo000xcrkt4w0yauk5w	cmng3bg7o00qrrkt40cce1gmg	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.656	2026-04-01 18:55:40.656	\N
cmngeoxo600xdrkt4swjmvl61	cmng3bg8r00qyrkt4t1fq1ty1	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.662	2026-04-01 18:55:40.662	\N
cmngeoxob00xerkt4aco7kvi2	cmng38zd500asrkt4zz0g08qt	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.667	2026-04-01 18:55:40.667	\N
cmngeoxoe00xfrkt4rdjap24x	cmng3bg9900qzrkt4w884tjj3	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.67	2026-04-01 18:55:40.67	\N
cmngeoxoi00xgrkt4spifqzrx	cmng3bg9i00r1rkt4b0mnzrpy	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.674	2026-04-01 18:55:40.674	\N
cmngeoxol00xhrkt4ojskp80h	cmnfm20ia0254hgt4o3p9nnxc	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.677	2026-04-01 18:55:40.677	\N
cmngeoxop00xirkt4cshjvrty	cmng3bf5s00mkrkt4df8mq3ue	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.681	2026-04-01 18:55:40.681	\N
cmngeoxot00xjrkt49veb6w94	cmng38zc000anrkt4wmxurrsp	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-01 18:55:40.685	2026-04-01 18:55:40.685	\N
cmngepjuy00xkrkt45i325lot	cmng3bgjq00s3rkt4z8f987hq	cmnfjeb71002lrgt453z02rn6	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:56:09.418	2026-04-01 18:56:09.418	\N
cmngepjwr00xlrkt4xo0j2l68	cmng3bgjy00s4rkt45ao9r7gf	cmnfjeb71002lrgt453z02rn6	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:56:09.483	2026-04-01 18:56:09.483	\N
cmngepjya00xmrkt4hzigpnq2	cmng3bfqd00ogrkt48m0azc5q	cmnfjeb71002lrgt453z02rn6	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:56:09.538	2026-04-01 18:56:09.538	\N
cmngeqbet00xnrkt4j60lzbs3	cmnfm207a023shgt46x8ecftc	cmnfjeb71002lrgt453z02rn6	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:56:45.125	2026-04-01 18:56:45.125	\N
cmngeqbgf00xorkt4kypfxwl3	cmng3bf2y00m8rkt4mw0ht1do	cmnfjiu0f002trgt4r83oahan	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:56:45.183	2026-04-01 18:56:45.183	\N
cmngeqbht00xprkt42isg53de	cmng3bf1600lzrkt43ms6hkxb	cmnfjeb71002lrgt453z02rn6	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:56:45.233	2026-04-01 18:56:45.233	\N
cmngeqbj200xqrkt4qbctnohh	cmng38y6d004lrkt4bqg8bvdy	cmnfjeb71002lrgt453z02rn6	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:56:45.278	2026-04-01 18:56:45.278	\N
cmnger3ji00xrrkt4bbg1y8rd	cmng3bfe200nbrkt499suek4c	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:57:21.582	2026-04-01 18:57:21.582	\N
cmnger3ld00xsrkt4o8njnl1i	cmng3beuz00lgrkt4rbfmu2qw	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:57:21.649	2026-04-01 18:57:21.649	\N
cmnger3mr00xtrkt4lq5vz66k	cmng38y2t0041rkt449nxqvrx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:57:21.699	2026-04-01 18:57:21.699	\N
cmngerpfp00xurkt4x2pm5r83	cmnfm20lr025jhgt4s7kierip	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	MANUAL	t	2026-04-01 18:57:49.957	2026-04-01 18:57:49.957	\N
cmngerpgm00xxrkt4wb43tzm0	cmnfm20n2025phgt4hw5iz09v	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:49.99	2026-04-01 18:57:49.99	\N
cmngerpgs00xyrkt46yjelzub	cmng3bgm200serkt49wmiz1s8	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:49.996	2026-04-01 18:57:49.996	\N
cmngerpgz00xzrkt4thx4rtj1	cmng38yrt007orkt4y2jvodxe	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.003	2026-04-01 18:57:50.003	\N
cmngerph500y0rkt4ityq3qa4	cmng3bgkl00s8rkt45jjotxf6	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.009	2026-04-01 18:57:50.009	\N
cmngerpha00y1rkt4bs2sad1l	cmng3bgin00s0rkt4dyl71v7j	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.014	2026-04-01 18:57:50.014	\N
cmngerphe00y2rkt4dit6hn32	cmnfm20m9025lhgt4zvmwapca	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.018	2026-04-01 18:57:50.018	\N
cmngerphi00y3rkt499x7y92l	cmng38y8h004wrkt4dbo8pmux	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.023	2026-04-01 18:57:50.023	\N
cmngerphn00y4rkt4x5rezwty	cmnfm20mx025ohgt4k14c4lhu	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.027	2026-04-01 18:57:50.027	\N
cmngerphr00y5rkt4epibr6lp	cmng3bfk200ntrkt4f6zwxt31	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.031	2026-04-01 18:57:50.031	\N
cmngerphw00y6rkt4sfwb2mb9	cmng3bfwx00parkt4syreabmt	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.036	2026-04-01 18:57:50.036	\N
cmngerpi200y7rkt49p0ehhl2	cmng3bgmm00shrkt4dkgylg7p	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-01 18:57:50.042	2026-04-01 18:57:50.042	\N
cmnges9qs00y8rkt4cbx337z9	cmng3bf2800m4rkt44m6m8xnz	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 18:58:16.276	2026-04-01 18:58:16.276	\N
cmnges9ro00ybrkt4k2o6vur7	cmng38y1c003vrkt4ua18n90m	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-01 18:58:16.308	2026-04-01 18:58:16.308	\N
cmngeumk000ycrkt4gtxiajs4	cmng3bf0c00lxrkt4zkobhsk9	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.192	2026-04-01 19:00:06.192	\N
cmngeumlc00ydrkt4ngdxnmh0	cmng3bft900otrkt44kb7qe3k	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.24	2026-04-01 19:00:06.24	\N
cmngeummv00yerkt43ssb6a2o	cmng3bf0100lvrkt4fxk9hjcr	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.295	2026-04-01 19:00:06.295	\N
cmngeumob00yfrkt4rdg8rr7m	cmng3bfnf00o2rkt4loyvvdnw	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.347	2026-04-01 19:00:06.347	\N
cmngeumq200ygrkt4vq45yrqy	cmng3bfe700ncrkt49q2zxmie	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.41	2026-04-01 19:00:06.41	\N
cmngeumre00yhrkt4zqr40du9	cmng3bfej00nerkt4dw5wyf2z	cmnfjiu0f002trgt4r83oahan	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.458	2026-04-01 19:00:06.458	\N
cmngeumsx00yirkt43fldvuiu	cmng38yfj0062rkt4o0o4aj2v	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.513	2026-04-01 19:00:06.513	\N
cmngeumu700yjrkt4o4u6w7p9	cmng38yfr0063rkt4ebda85ms	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.559	2026-04-01 19:00:06.559	\N
cmngeumvv00ykrkt44ev2dh4x	cmng38yfy0064rkt45mjj8c0w	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.619	2026-04-01 19:00:06.619	\N
cmngeumxd00ylrkt4k4q6d68g	cmng38yg90065rkt4e0zj4i7p	cmnfjiu0f002trgt4r83oahan	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.673	2026-04-01 19:00:06.673	\N
cmngeumyo00ymrkt4sa3963iu	cmng38ygf0066rkt4sc701osk	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.72	2026-04-01 19:00:06.72	\N
cmngeun0p00ynrkt4fe6p6t79	cmng38ygm0067rkt4sc480h6e	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.793	2026-04-01 19:00:06.793	\N
cmngeun2j00yorkt4qp8csqsl	cmng38ygr0068rkt4epmq050t	cmnfjeb71002lrgt453z02rn6	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:00:06.86	2026-04-01 19:00:06.86	\N
cmngevd6x00yprkt48h0nc2u4	cmng3bey900lorkt41pn6se8f	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:00:40.713	2026-04-01 19:00:40.713	\N
cmngevnds00yqrkt49x74ikai	cmnfm20i00253hgt4kvq91zbz	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:00:53.92	2026-04-01 19:00:53.92	\N
cmngewehb00yrrkt428t8nql8	cmng3bewa00ljrkt40b4v0kmt	cmnfjiu0f002trgt4r83oahan	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:01:29.039	2026-04-01 19:01:29.039	\N
cmngeweit00ysrkt49e5rvxwi	cmng3bf5k00mjrkt4oun7n4nl	cmnfjiu0f002trgt4r83oahan	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:01:29.093	2026-04-01 19:01:29.093	\N
cmngewek600ytrkt4u8hc0wwx	cmng3bew000lirkt4p3ie7kj4	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:01:29.142	2026-04-01 19:01:29.142	\N
cmngex9rz00yurkt4pgz4q9pd	cmng3bf1d00m0rkt4697vo0t1	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:02:09.599	2026-04-01 19:02:09.599	\N
cmngex9u800yvrkt4yuz6ucm4	cmng3bezt00lurkt4h6f46dhj	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:02:09.68	2026-04-01 19:02:09.68	\N
cmngex9vp00ywrkt4wndgzntt	cmng38y23003yrkt41ft695pl	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:02:09.733	2026-04-01 19:02:09.733	\N
cmngf2w2k00yxrkt4ig3cnoug	cmng3beuk00lerkt4il2wciw1	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-01 19:06:31.772	2026-04-01 19:06:31.772	\N
cmngf2w9u00yyrkt4dsmi7ewv	cmng3beyl00lqrkt4xmqqnv2g	cmnfjiu0f002trgt4r83oahan	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.034	2026-04-01 19:06:32.034	\N
cmngf2wb900yzrkt4s9gtgi5a	cmng3bewj00lkrkt4u61bhtih	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-01 19:06:32.085	2026-04-01 19:06:32.085	\N
cmngf2wcz00z0rkt4qcm1v7bt	cmng3beu900ldrkt4d5g575u2	cmnfig5t40005rgt4visli2qu	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-01 19:06:32.147	2026-04-01 19:06:32.147	\N
cmngf2wfp00z1rkt4reme4pds	cmng3bexg00lnrkt4f8091ll6	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.245	2026-04-01 19:06:32.245	\N
cmngf2wha00z2rkt49qnmx4mz	cmng3bfna00o1rkt4g6atizbu	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 19:06:32.302	2026-04-01 19:06:32.302	\N
cmngf2wiv00z3rkt4741s6cdy	cmng3bfee00ndrkt44m3p3020	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 19:06:32.359	2026-04-01 19:06:32.359	\N
cmngf2wkp00z4rkt40moksdgm	cmng38yux0082rkt4dhu8wptp	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 19:06:32.425	2026-04-01 19:06:32.425	\N
cmngf2wlw00z5rkt4943vpp27	cmng38y1m003wrkt4aijcncv4	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.468	2026-04-01 19:06:32.468	\N
cmngf2wnm00z6rkt427085zff	cmng38y5n004hrkt4imabxq7t	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.53	2026-04-01 19:06:32.53	\N
cmngf2wpb00z7rkt4f68p5u0j	cmng38z0g008xrkt4enjg6y8z	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.591	2026-04-01 19:06:32.591	\N
cmngf2wqz00z8rkt4lmxjk8wn	cmng38ypq007irkt4vunu612u	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.651	2026-04-01 19:06:32.651	\N
cmngf2ws800z9rkt45ityhhf0	cmng38y7b004qrkt4rkfizpf0	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.696	2026-04-01 19:06:32.696	\N
cmngf2wt700zarkt444l73qxg	cmng38ynn007arkt4ngiiswoe	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.731	2026-04-01 19:06:32.731	\N
cmngf2wuf00zbrkt45ryuxa0m	cmng38z1l0095rkt4twtc2027	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-01 19:06:32.775	2026-04-01 19:06:32.775	\N
cmngf2wwb00zcrkt4kzxahvek	cmng38yor007frkt40i57kkmx	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-01 19:06:32.843	2026-04-01 19:06:32.843	\N
cmngf2wxh00zdrkt4ad5af1ji	cmng38yyp008lrkt49wryu9kh	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-01 19:06:32.885	2026-04-01 19:06:32.885	\N
cmngf2wyo00zerkt48vhirgmq	cmng38y10003urkt46c6w8xwb	cmnfig5t40005rgt4visli2qu	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-01 19:06:32.928	2026-04-01 19:06:32.928	\N
cmngf2x0j00zfrkt471ghoya1	cmng38ysp007srkt4l4k4u1cd	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-01 19:06:32.995	2026-04-01 19:06:32.995	\N
cmnho3dhx00zgrkt46vtia018	cmng3bfgg00nkrkt4uvntz92u	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-02 16:06:37.077	2026-04-02 16:06:37.077	\N
cmnho3dk700zjrkt4xw0f3rdw	cmng38yv30083rkt4bior6dei	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-02 16:06:37.159	2026-04-02 16:06:37.159	\N
cmnho3dkf00zkrkt4uy1ocxbh	cmng38yfc0061rkt4rqr0ui8l	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-02 16:06:37.167	2026-04-02 16:06:37.167	\N
cmnho7cq200zlrkt4frnwhwiq	cmng3bfat00mzrkt4e9rkenvk	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:42.698	2026-04-02 16:09:42.698	\N
cmnho7ct100zmrkt4o93nfwz7	cmng3bfht00nnrkt4zrojh76s	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:42.805	2026-04-02 16:09:42.805	\N
cmnho7cve00znrkt4f9sb76x3	cmng3bfi900norkt4n2u7ndpr	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:42.89	2026-04-02 16:09:42.89	\N
cmnho7cxd00zorkt4hqceiy3f	cmng3bfbf00n0rkt4zimf4qf4	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:42.961	2026-04-02 16:09:42.961	\N
cmnho7cz600zprkt4uh3a0339	cmng38zwa00dorkt47wz5119m	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.026	2026-04-02 16:09:43.026	\N
cmnho7d0v00zqrkt4axe06iz6	cmng38zxg00dvrkt4kq9jtx5q	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.087	2026-04-02 16:09:43.087	\N
cmnho7d3m00zrrkt4glynse7h	cmng38yy9008irkt4ox1wvzit	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.186	2026-04-02 16:09:43.186	\N
cmnho7d5900zsrkt4di3xs628	cmng38yzc008prkt4lsa3tk9o	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.245	2026-04-02 16:09:43.245	\N
cmnho7d8b00ztrkt4bnulcfe1	cmng38yyd008jrkt4fa94rewg	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.355	2026-04-02 16:09:43.355	\N
cmnho7dbs00zurkt4lqbc1gtu	cmng38yzk008qrkt4obcw49y6	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.48	2026-04-02 16:09:43.48	\N
cmnho7ddx00zvrkt4cs0suz80	cmng38yyk008krkt4ver6ewsf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.557	2026-04-02 16:09:43.557	\N
cmnho7dff00zwrkt43hgewjbg	cmng38yzp008rrkt4q9gjzz0z	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.611	2026-04-02 16:09:43.611	\N
cmnho7dgm00zxrkt412k2h4l5	cmng38yzu008srkt4ixra15lt	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.654	2026-04-02 16:09:43.654	\N
cmnho7di800zyrkt46wb4elc6	cmng38yyt008mrkt4smwaz7wp	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.712	2026-04-02 16:09:43.712	\N
cmnho7dk300zzrkt4fi6ukiaq	cmng38yzz008trkt4xkfpr1wc	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsf00064wt4plz0ps6i	MANUAL	t	2026-04-02 16:09:43.779	2026-04-02 16:09:43.779	\N
cmnhobe7a0100rkt4jo4y4ltk	cmng3bfu800oxrkt452x2wl02	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	MANUAL	t	2026-04-02 16:12:51.238	2026-04-02 16:12:51.238	\N
cmnhobecu0101rkt4viz20ssf	cmng3bgkr00s9rkt4d6w221hk	cmnffta06000068t4x50l5rq5	cmnfdbztr000e4wt4u3dc57us	MANUAL	t	2026-04-02 16:12:51.438	2026-04-02 16:12:51.438	\N
cmnhobegr0102rkt4cl74ilsi	cmng3beza00lrrkt4a0bimevi	cmnffta06000068t4x50l5rq5	cmnfdbzub000h4wt4ywojkc87	MANUAL	t	2026-04-02 16:12:51.579	2026-04-02 16:12:51.579	\N
cmnhobejv0103rkt49tjzife3	cmng3bghs00ryrkt4nnho0o62	cmnffta06000068t4x50l5rq5	cmnfdbzub000h4wt4ywojkc87	MANUAL	t	2026-04-02 16:12:51.691	2026-04-02 16:12:51.691	\N
cmnhobemm0104rkt4tc3a2397	cmng3bfx400pbrkt4ow9o3f1r	cmnffta06000068t4x50l5rq5	cmnfdbzub000h4wt4ywojkc87	MANUAL	t	2026-04-02 16:12:51.79	2026-04-02 16:12:51.79	\N
cmnhobeor0105rkt4d4gs5dqt	cmng3bfug00oyrkt4w7c74r3q	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:12:51.867	2026-04-02 16:12:51.867	\N
cmnhober80106rkt46xhhd95a	cmng3bfqu00ojrkt4acl62fk0	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:12:51.956	2026-04-02 16:12:51.956	\N
cmnhobesd0107rkt41xzfeu2t	cmng3bgdf00rhrkt4pfv49l99	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:12:51.997	2026-04-02 16:12:51.997	\N
cmnhobeu20108rkt4pzokefw6	cmng3bg7t00qsrkt4vrk4ni6v	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:12:52.058	2026-04-02 16:12:52.058	\N
cmnhobevm0109rkt48bdhzvh9	cmng3bevr00lhrkt4u26dtzkr	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-02 16:12:52.114	2026-04-02 16:12:52.114	\N
cmnhobex0010arkt4va1wtlv2	cmng38zwx00dsrkt4lk1d2wgg	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-02 16:12:52.164	2026-04-02 16:12:52.164	\N
cmnhobeyc010brkt49f1lljx6	cmng38zv100dhrkt43xjypcg6	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:12:52.212	2026-04-02 16:12:52.212	\N
cmnhobf05010crkt4ihnx4zpx	cmng38zyw00e4rkt4m3426ga7	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-02 16:12:52.277	2026-04-02 16:12:52.277	\N
cmnhobf18010drkt4h856jrnu	cmng38z1s0096rkt4t5x9td98	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:12:52.316	2026-04-02 16:12:52.316	\N
cmnhobf2n010erkt4ynw6n485	cmng38zzl00e8rkt40fhv7f8y	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	MANUAL	t	2026-04-02 16:12:52.367	2026-04-02 16:12:52.367	\N
cmnhobf3x010frkt4mnekx7u9	cmng38zb600ajrkt4saccf8aq	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:12:52.413	2026-04-02 16:12:52.413	\N
cmnhoc2er010grkt4lv98kqtn	cmng38ziv00bprkt4jqsmkld8	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:13:22.611	2026-04-02 16:13:22.611	\N
cmnhoc2h5010hrkt48cm6lc1u	cmng38zrz00d0rkt4kfuu2acr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:13:22.697	2026-04-02 16:13:22.697	\N
cmnhoc2jc010irkt4irleuhj6	cmng38zia00bmrkt4c5hunhgm	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:13:22.776	2026-04-02 16:13:22.776	\N
cmnhoc2l4010jrkt41ielq4l7	cmng38zc800aorkt44li6a3it	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:13:22.84	2026-04-02 16:13:22.84	\N
cmnhoc2nr010krkt4xciee26z	cmng38zja00brrkt4fash8lkm	cmnfjiu0f002trgt4r83oahan	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:13:22.935	2026-04-02 16:13:22.935	\N
cmnhocukg010lrkt4ureq1aei	cmng3bfvv00p6rkt4hji9u1z8	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsa00054wt4rildbdz8	MANUAL	t	2026-04-02 16:13:59.104	2026-04-02 16:13:59.104	\N
cmnhoei7i010mrkt4qp91yrrr	cmnfm20h3024zhgt4i7cdmgew	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	MANUAL	t	2026-04-02 16:15:16.398	2026-04-02 16:15:16.398	\N
cmnhoeii0010nrkt4tii5na5r	cmnfm20e1024khgt40neb8n8h	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	MANUAL	t	2026-04-02 16:15:16.776	2026-04-02 16:15:16.776	\N
cmnhoeikk010orkt4z050fkhk	cmng3bfwr00p9rkt4c48bax6d	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:15:16.868	2026-04-02 16:15:16.868	\N
cmnhoeyt2010prkt4p3j11m97	cmng3bezn00ltrkt4wmhoufyy	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:15:37.91	2026-04-02 16:15:37.91	\N
cmnhoeyvp010qrkt4xpg48hyn	cmng38yvn0086rkt4x00g5h18	cmnfig5t40005rgt4visli2qu	cmnfdbzsl00074wt4lub1r7uv	MANUAL	t	2026-04-02 16:15:38.005	2026-04-02 16:15:38.005	\N
cmnhoycbp0112rkt44j2fpzpp	cmnhoycbb0111rkt4h68exsaa	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:41.893	2026-04-02 16:30:41.893	\N
cmnhoycdf0118rkt4spy7pprq	cmnhoycda0117rkt499ax48eu	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:41.956	2026-04-02 16:30:41.956	\N
cmnhoycdx011brkt4555pl8d7	cmnhoycdr011arkt4d10oqjsw	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:41.973	2026-04-02 16:30:41.973	\N
cmnhoyce8011drkt4iwepnt1t	cmnhoyce1011crkt4xsz1sncz	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:41.984	2026-04-02 16:30:41.984	\N
cmnhoycei011frkt46plczbw2	cmnhoyced011erkt4nbgaax5i	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:41.994	2026-04-02 16:30:41.994	\N
cmnhoyces011hrkt4nv1fxglo	cmnhoycel011grkt49yzxdxdh	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:42.004	2026-04-02 16:30:42.004	\N
cmnhoycg0011jrkt4lyzw29pm	cmnhoycez011irkt4ftiusl2s	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:42.048	2026-04-02 16:30:42.048	\N
cmnhoych4011lrkt42q7jct8h	cmnhoycgt011krkt47g7cio2q	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:42.088	2026-04-02 16:30:42.088	\N
cmnhoychn011nrkt4ls7n3j24	cmnhoycha011mrkt4712xfbtq	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:42.107	2026-04-02 16:30:42.107	\N
cmnhoychw011prkt4hg7h7toh	cmnhoychq011orkt4hr9gat8n	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:42.117	2026-04-02 16:30:42.117	\N
cmnhoyci8011rrkt4sc13d1q1	cmnhoyci0011qrkt4wz34bsct	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:42.128	2026-04-02 16:30:42.128	\N
cmnhoycii011trkt4kntrigb8	cmnhoycic011srkt4waiher0e	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:42.138	2026-04-02 16:30:42.138	\N
cmnhoyhe70133rkt4jm8bsopp	cmnhoyhdu0132rkt40qrgaxh5	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.463	2026-04-02 16:30:48.463	\N
cmnhoyhen0135rkt4c1tbutmo	cmnhoyheg0134rkt43f3bwggl	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.479	2026-04-02 16:30:48.479	\N
cmnhoyhf10137rkt4q311kunh	cmnhoyhes0136rkt466ooe3np	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.493	2026-04-02 16:30:48.493	\N
cmnhoyhfg0139rkt4axhiuofc	cmnhoyhf60138rkt4uh0ifmmg	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.508	2026-04-02 16:30:48.508	\N
cmnhoyhhf013grkt4kk4s3jyr	cmnhoyhgr013frkt42kfee5rv	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:48.579	2026-04-02 16:30:48.579	\N
cmnhoyhju013mrkt492hgr06z	cmnhoyhjl013lrkt4gzec54f4	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.666	2026-04-02 16:30:48.666	\N
cmnhoyhkj013orkt4525g5tur	cmnhoyhk4013nrkt4lfnq3jns	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.691	2026-04-02 16:30:48.691	\N
cmnhoyhmy013qrkt4etm14qxe	cmnhoyhl6013prkt431q4ygrq	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.778	2026-04-02 16:30:48.778	\N
cmnhoyhnp013srkt4jdslzo12	cmnhoyhne013rrkt44gcx6ycz	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.805	2026-04-02 16:30:48.805	\N
cmnhoyho6013urkt4cl94rkd7	cmnhoyhnx013trkt4vgj2e6v5	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.822	2026-04-02 16:30:48.822	\N
cmnhoyhop013wrkt45s6msu7p	cmnhoyhod013vrkt4b45x06dm	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.841	2026-04-02 16:30:48.841	\N
cmnhoyhp3013yrkt4rke15p0t	cmnhoyhou013xrkt4awsmb47k	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.855	2026-04-02 16:30:48.855	\N
cmnhoyhpj0140rkt456cc9bjq	cmnhoyhpa013zrkt4ohc56v7e	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.871	2026-04-02 16:30:48.871	\N
cmnhoyhpw0142rkt4p0rl1l3u	cmnhoyhpq0141rkt4mgf7z96q	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.884	2026-04-02 16:30:48.884	\N
cmnhoyhq70144rkt4gamv92xl	cmnhoyhq00143rkt461gdk7o0	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.895	2026-04-02 16:30:48.895	\N
cmnhoyhqj0146rkt40pl9td1m	cmnhoyhqa0145rkt4egbw1qe7	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.907	2026-04-02 16:30:48.907	\N
cmnhoyhqs0148rkt4pka8ix27	cmnhoyhqm0147rkt4m8kwhonf	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.916	2026-04-02 16:30:48.916	\N
cmnhoyhr1014arkt4q8m72soe	cmnhoyhqv0149rkt4f1s27wjn	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.925	2026-04-02 16:30:48.925	\N
cmnhoyhr8014crkt4fiopqin4	cmnhoyhr3014brkt40z57io2v	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:48.932	2026-04-02 16:30:48.932	\N
cmnhoyhrn014frkt41yx0ce57	cmnhoyhri014erkt4m6pt4l3j	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.947	2026-04-02 16:30:48.947	\N
cmnhoyhsv014jrkt4fhcusthm	cmnhoyhsh014irkt4qt9500lx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:48.991	2026-04-02 16:30:48.991	\N
cmnhoyhuw014orkt4b529fwak	cmnhoyhuk014nrkt4v9uuw5t9	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.064	2026-04-02 16:30:49.064	\N
cmnhoyhzg014urkt4w124eh7n	cmnhoyhz3014trkt4v15q6nmp	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.228	2026-04-02 16:30:49.228	\N
cmnhoyi06014wrkt4r1m1sc8o	cmnhoyhzv014vrkt49x4j7j5p	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.254	2026-04-02 16:30:49.254	\N
cmnhoyi15014yrkt49dkxtuqw	cmnhoyi0n014xrkt4cor9spcj	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.289	2026-04-02 16:30:49.289	\N
cmnhoyi350153rkt48flddpxp	cmnhoyi2w0152rkt4ujv5fetj	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.361	2026-04-02 16:30:49.361	\N
cmnhoyi3m0155rkt4b2sb8mkr	cmnhoyi3a0154rkt413ngnsot	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.378	2026-04-02 16:30:49.378	\N
cmnhoyi480158rkt4oat7ywos	cmnhoyi410157rkt4lzivohre	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.4	2026-04-02 16:30:49.4	\N
cmnhoyi4s015brkt4gexkctbj	cmnhoyi4m015arkt46dhqdzfz	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.42	2026-04-02 16:30:49.42	\N
cmnhoyi52015drkt4r33udh31	cmnhoyi4x015crkt4f193xk3t	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.43	2026-04-02 16:30:49.43	\N
cmnhoyi7z015vrkt43g7j0bsg	cmnhoyi7t015urkt4ylhpf1s4	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.535	2026-04-02 16:30:49.535	\N
cmnhoyi8m015yrkt4xuxacrd8	cmnhoyi8e015xrkt4yc06sim1	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.558	2026-04-02 16:30:49.558	\N
cmnhoyi940161rkt4qsidzmzn	cmnhoyi8w0160rkt44ixogk73	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.576	2026-04-02 16:30:49.576	\N
cmnhoyibs016frkt4peqwul5o	cmnhoyibm016erkt4r6s3iqym	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.672	2026-04-02 16:30:49.672	\N
cmnhoyicb016hrkt41kjiff40	cmnhoyic2016grkt4lvye7p6i	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.691	2026-04-02 16:30:49.691	\N
cmnhoyidc016lrkt434c12ygy	cmnhoyid2016krkt4utwihfpc	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.728	2026-04-02 16:30:49.728	\N
cmnhoyie2016orkt4p1zhqadv	cmnhoyidu016nrkt440t029bq	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-02 16:30:49.754	2026-04-02 16:30:49.754	\N
cmnhoyifd016rrkt44w2cm2um	cmnhoyif8016qrkt4gut4lbjw	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.801	2026-04-02 16:30:49.801	\N
cmnhoyifm016trkt4wibu4c0n	cmnhoyifh016srkt4szflmoi6	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.81	2026-04-02 16:30:49.81	\N
cmnhoyig0016wrkt47wd7uxas	cmnhoyifu016vrkt4tf77kt5a	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.824	2026-04-02 16:30:49.824	\N
cmnhoyig9016yrkt47k5yizct	cmnhoyig4016xrkt43yp0ncnl	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.833	2026-04-02 16:30:49.833	\N
cmnhoyigj0170rkt4lngup7up	cmnhoyigd016zrkt44tu36zd6	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.843	2026-04-02 16:30:49.843	\N
cmnhoyih00173rkt47vzzlnqi	cmnhoyigu0172rkt4x144d8h4	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.86	2026-04-02 16:30:49.86	\N
cmnhoyih90175rkt4d5no5785	cmnhoyih40174rkt4898fes80	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.869	2026-04-02 16:30:49.869	\N
cmnhoyii2017arkt4nwnacmdh	cmnhoyihw0179rkt4il3j5mw7	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.898	2026-04-02 16:30:49.898	\N
cmnhoyiib017crkt4ito2nbmt	cmnhoyii6017brkt445u1z9g7	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.907	2026-04-02 16:30:49.907	\N
cmnhoyik7017orkt4ud8wlm0i	cmnhoyik1017nrkt4coe4oviv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:49.975	2026-04-02 16:30:49.975	\N
cmnhoyprp0185rkt4jydktjr6	cmnhoyprj0184rkt46blakctx	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:59.317	2026-04-02 16:30:59.317	\N
cmnhoyps60188rkt4jxw473jx	cmnhoyps10187rkt4az1bxww8	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:30:59.334	2026-04-02 16:30:59.334	\N
cmnhoypsi018arkt4tgp8i4be	cmnhoypsd0189rkt43uz7zt4u	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:30:59.346	2026-04-02 16:30:59.346	\N
cmnhoyptc018frkt4w7pz28x2	cmnhoypt5018erkt43ont5v5n	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.376	2026-04-02 16:30:59.376	\N
cmnhoypu9018lrkt45i6b1yob	cmnhoypu3018krkt4c7c2c61r	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:30:59.409	2026-04-02 16:30:59.409	\N
cmnhoypuq018orkt4wpl5tbpj	cmnhoypuh018nrkt43hl6p64n	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.426	2026-04-02 16:30:59.426	\N
cmnhoypv1018qrkt4d3ex7yzl	cmnhoypuv018prkt4u08zgwnh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.437	2026-04-02 16:30:59.437	\N
cmnhoypvl018trkt4xf0hvfiv	cmnhoypva018srkt4dr3ixjhn	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.457	2026-04-02 16:30:59.457	\N
cmnhoypvu018vrkt4kutucxre	cmnhoypvp018urkt4ft7qw49y	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.466	2026-04-02 16:30:59.466	\N
cmnhoypw4018xrkt4kjh1anat	cmnhoypvw018wrkt4ckf603h6	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.476	2026-04-02 16:30:59.476	\N
cmnhoypwe018zrkt4s4ebvvwt	cmnhoypw8018yrkt4x1ibjoes	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.486	2026-04-02 16:30:59.486	\N
cmnhoypwo0191rkt4axvcq04g	cmnhoypwi0190rkt4hsff1vp9	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.496	2026-04-02 16:30:59.496	\N
cmnhoypwx0193rkt41747dq80	cmnhoypwr0192rkt4veixk4r3	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.505	2026-04-02 16:30:59.505	\N
cmnhoypxf0195rkt4dljnt29d	cmnhoypx30194rkt46g8deztb	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.523	2026-04-02 16:30:59.523	\N
cmnhoypxw0197rkt4eozrjucc	cmnhoypxj0196rkt4usfbgvj1	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.541	2026-04-02 16:30:59.541	\N
cmnhoypy70199rkt44v3bd6lr	cmnhoypy10198rkt4ceyxa4p4	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.551	2026-04-02 16:30:59.551	\N
cmnhoypyf019brkt48q7d7f5d	cmnhoypyb019arkt4mslmzpyc	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.559	2026-04-02 16:30:59.559	\N
cmnhoypyu019drkt4lheq0tbi	cmnhoypyj019crkt4seoz7p9p	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.574	2026-04-02 16:30:59.574	\N
cmnhoypz1019frkt4hlicttiu	cmnhoypyx019erkt4ibn5kvi4	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:30:59.581	2026-04-02 16:30:59.581	\N
cmnhoypzb019hrkt4no49dgty	cmnhoypz4019grkt4tfhq65aa	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.591	2026-04-02 16:30:59.591	\N
cmnhoyq0b019nrkt4cy6jmwyg	cmnhoyq05019mrkt4z5v9xmde	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.627	2026-04-02 16:30:59.627	\N
cmnhoyq2m019rrkt49x0bsysj	cmnhoyq2b019qrkt4vosn1cpv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.71	2026-04-02 16:30:59.71	\N
cmnhoyq38019trkt4t8t6b0vb	cmnhoyq2r019srkt49hu8ufgo	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.732	2026-04-02 16:30:59.732	\N
cmnhoyq5o01a3rkt48hyc95oe	cmnhoyq5i01a2rkt40l95h5fm	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.82	2026-04-02 16:30:59.82	\N
cmnhoyq6601a5rkt4svlfie3l	cmnhoyq5x01a4rkt4hb5mjn8o	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.838	2026-04-02 16:30:59.838	\N
cmnhoyq7201a9rkt411jhfzwr	cmnhoyq6y01a8rkt4vrp6cd8d	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.87	2026-04-02 16:30:59.87	\N
cmnhoyq7d01abrkt4jyrto3g5	cmnhoyq7801aarkt4fd6h1vgv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.881	2026-04-02 16:30:59.881	\N
cmnhoyq7o01adrkt4moau95w6	cmnhoyq7i01acrkt4c9qmrd2t	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.892	2026-04-02 16:30:59.892	\N
cmnhoyq8501agrkt4gu0j0esc	cmnhoyq7z01afrkt49fx68jkc	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:30:59.909	2026-04-02 16:30:59.909	\N
cmnhoyqec01berkt4jgdhjkim	cmnhoyqe801bdrkt4ih205f9s	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.132	2026-04-02 16:31:00.132	\N
cmnhoyqem01bgrkt4kezt5egn	cmnhoyqef01bfrkt44viglsc1	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.142	2026-04-02 16:31:00.142	\N
cmnhoyqf101birkt426zf5erg	cmnhoyqes01bhrkt44pepr371	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.157	2026-04-02 16:31:00.157	\N
cmnhoyqfp01bmrkt4852n8zsh	cmnhoyqfk01blrkt44312bxe6	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.181	2026-04-02 16:31:00.181	\N
cmnhoyqga01borkt46d5tp6xa	cmnhoyqft01bnrkt4z8ceheyn	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.202	2026-04-02 16:31:00.202	\N
cmnhoyqgn01bqrkt4dccqcotv	cmnhoyqgg01bprkt4rkiib2lm	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.215	2026-04-02 16:31:00.215	\N
cmnhoyqh101btrkt4p2jwu832	cmnhoyqgv01bsrkt4px20l1zv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.229	2026-04-02 16:31:00.229	\N
cmnhoyqkk01c7rkt4a3g6x9gw	cmnhoyqkc01c6rkt4i0glz363	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:00.356	2026-04-02 16:31:00.356	\N
cmnhoyqle01ccrkt4xjkmoqa4	cmnhoyql801cbrkt4jmpoo8vq	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.386	2026-04-02 16:31:00.386	\N
cmnhoyqlw01cfrkt4cbs0b59s	cmnhoyqlq01cerkt4uppyga8l	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.404	2026-04-02 16:31:00.404	\N
cmnhoyqmq01cjrkt4kk3omdhv	cmnhoyqmi01cirkt4lmimdwlq	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:00.434	2026-04-02 16:31:00.434	\N
cmnhoyqo101corkt4mychdny3	cmnhoyqnq01cnrkt4g0px8fy3	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.481	2026-04-02 16:31:00.481	\N
cmnhoyqot01csrkt49704ee0p	cmnhoyqop01crrkt4ze08na7d	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.509	2026-04-02 16:31:00.509	\N
cmnhoyqqa01d1rkt4qlg36l7e	cmnhoyqq601d0rkt4w7kgib5j	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.562	2026-04-02 16:31:00.562	\N
cmnhoyqrf01d8rkt4pb4vkpc6	cmnhoyqr801d7rkt4i7mx0f8i	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.603	2026-04-02 16:31:00.603	\N
cmnhoyqro01darkt49n51i9v1	cmnhoyqrk01d9rkt4hurqypxl	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.612	2026-04-02 16:31:00.612	\N
cmnhoyqs701derkt4gai5xpi3	cmnhoyqs201ddrkt476jbjl7y	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.631	2026-04-02 16:31:00.631	\N
cmnhoyqt501djrkt4p0o3r1m0	cmnhoyqsz01dirkt4b1d251ci	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.665	2026-04-02 16:31:00.665	\N
cmnhoyqtp01dmrkt4xhv0vw84	cmnhoyqtj01dlrkt4o5njvlcy	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.685	2026-04-02 16:31:00.685	\N
cmnhoyqud01dqrkt4wfalmamf	cmnhoyqu601dprkt47cs1exfd	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.709	2026-04-02 16:31:00.709	\N
cmnhoyqwe01dyrkt40f0hv9bi	cmnhoyqvw01dxrkt40w8oo20l	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.782	2026-04-02 16:31:00.782	\N
cmnhoyqwt01e0rkt4zgar5dwy	cmnhoyqwm01dzrkt46a0cwvoh	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:00.797	2026-04-02 16:31:00.797	\N
cmnhoyqxg01e4rkt4vzu53csj	cmnhoyqxb01e3rkt409r9g5sx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.82	2026-04-02 16:31:00.82	\N
cmnhoyqxr01e6rkt4ose0im56	cmnhoyqxl01e5rkt4e4wism9h	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.831	2026-04-02 16:31:00.831	\N
cmnhoyqyz01ebrkt4y877xgek	cmnhoyqyn01earkt4wbwbxsub	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.875	2026-04-02 16:31:00.875	\N
cmnhoyqzm01eerkt4lm3vpxj7	cmnhoyqzf01edrkt49b7wduwc	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.898	2026-04-02 16:31:00.898	\N
cmnhoyr0301ehrkt4klw7wi0a	cmnhoyqzw01egrkt48gryfeor	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.915	2026-04-02 16:31:00.915	\N
cmnhoyr0k01ekrkt4kim405pw	cmnhoyr0g01ejrkt44341val8	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.932	2026-04-02 16:31:00.932	\N
cmnhoyr0v01emrkt4xr0kldx2	cmnhoyr0o01elrkt4d0wid57i	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.943	2026-04-02 16:31:00.943	\N
cmnhoyr1501eorkt491sodjha	cmnhoyr0z01enrkt4epg9vmdb	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.953	2026-04-02 16:31:00.953	\N
cmnhoyr1f01eqrkt4iikr5e87	cmnhoyr1801eprkt41n6xczao	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:00.963	2026-04-02 16:31:00.963	\N
cmnhoyr5u01fbrkt43aszrl9g	cmnhoyr5o01farkt4bb7jpgzi	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:01.122	2026-04-02 16:31:01.122	\N
cmnhoyr6601fdrkt4fn7fqv0b	cmnhoyr6001fcrkt49uvbvst2	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:01.134	2026-04-02 16:31:01.134	\N
cmnhoyr6p01fgrkt4362lxcg5	cmnhoyr6g01ffrkt42bjrh9zr	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:01.153	2026-04-02 16:31:01.153	\N
cmnhoyr7201firkt4akvs9k93	cmnhoyr6u01fhrkt4qwz8cf08	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:01.166	2026-04-02 16:31:01.166	\N
cmnhoyr7s01flrkt4w4b8m5eh	cmnhoyr7h01fkrkt458psyllx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:01.192	2026-04-02 16:31:01.192	\N
cmnhoywtm01g3rkt44pseuvb6	cmnhoywtd01g2rkt4utk3n3ok	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:08.458	2026-04-02 16:31:08.458	\N
cmnhoywua01g6rkt4vlyvk5rq	cmnhoywu201g5rkt4kqcnty3q	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:08.482	2026-04-02 16:31:08.482	\N
cmnhoywv501gbrkt4ndnxhml1	cmnhoywuy01garkt4gn8bn21t	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.513	2026-04-02 16:31:08.513	\N
cmnhoywve01gdrkt4htqyz0x3	cmnhoywv801gcrkt4i14c6qm5	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.522	2026-04-02 16:31:08.522	\N
cmnhoywvl01gfrkt46ikpq4dc	cmnhoywvh01gerkt4hzrx6d2a	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.529	2026-04-02 16:31:08.529	\N
cmnhoywvy01ghrkt4k1u0a0gl	cmnhoywvo01ggrkt4oqch4fzy	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.542	2026-04-02 16:31:08.542	\N
cmnhoywwf01gjrkt4gufxtk45	cmnhoyww201girkt4tzs2m670	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.559	2026-04-02 16:31:08.559	\N
cmnhoywwu01glrkt4uhivccwy	cmnhoywwj01gkrkt4lwxvyrhp	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.574	2026-04-02 16:31:08.574	\N
cmnhoywxa01gnrkt40g11rfvz	cmnhoywx201gmrkt4dosahl7c	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.59	2026-04-02 16:31:08.59	\N
cmnhoywxm01gprkt4i0qrgxru	cmnhoywxe01gorkt4or9uo7pu	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.602	2026-04-02 16:31:08.602	\N
cmnhoywxx01grrkt4mpu1qdk4	cmnhoywxr01gqrkt4eg1f3pbj	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.613	2026-04-02 16:31:08.613	\N
cmnhoywy901gtrkt4gti5fdfp	cmnhoywy101gsrkt42uuj747b	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.625	2026-04-02 16:31:08.625	\N
cmnhoywzw01gvrkt4wvc5n1lq	cmnhoywyu01gurkt44e7706e5	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.684	2026-04-02 16:31:08.684	\N
cmnhoyx2501gxrkt4en090iqe	cmnhoyx0b01gwrkt4qwupj3zj	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:08.765	2026-04-02 16:31:08.765	\N
cmnhoyxcf01h8rkt4pdc8p9d9	cmnhoyxbv01h7rkt42vut2fcx	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:09.135	2026-04-02 16:31:09.135	\N
cmnhoyxdy01hdrkt4lqldxz5z	cmnhoyxdp01hcrkt4c3uddkqx	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:09.19	2026-04-02 16:31:09.19	\N
cmnhoyxe701hfrkt482ulkfyq	cmnhoyxe201herkt4gaqbslyx	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:09.199	2026-04-02 16:31:09.199	\N
cmnhoyxif01hzrkt4ghkpwnoo	cmnhoyxia01hyrkt4lxwyc3e2	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:09.351	2026-04-02 16:31:09.351	\N
cmnhoyxjd01i5rkt4o09c6mya	cmnhoyxj701i4rkt4822bc290	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:09.385	2026-04-02 16:31:09.385	\N
cmnhoyxny01ixrkt427l39son	cmnhoyxnr01iwrkt4ygfklhpc	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:09.55	2026-04-02 16:31:09.55	\N
cmnhoyxs601jjrkt4bu97ot60	cmnhoyxrz01jirkt48tvmk54o	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:09.702	2026-04-02 16:31:09.702	\N
cmnhoyxv901k1rkt4zai4tdqh	cmnhoyxv601k0rkt464wyxfm8	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:09.813	2026-04-02 16:31:09.813	\N
cmnhoyxyc01kirkt4x89ds67k	cmnhoyxy501khrkt4hor53g1k	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:09.924	2026-04-02 16:31:09.924	\N
cmnhoyxz501knrkt4zwoe0arj	cmnhoyxyz01kmrkt4n2hjyyj0	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:09.953	2026-04-02 16:31:09.953	\N
cmnhoyy0901kvrkt4o56u1vog	cmnhoyy0301kurkt4jr90iwqz	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:09.993	2026-04-02 16:31:09.993	\N
cmnhoyy3k01l9rkt4grla24wy	cmnhoyy3e01l8rkt4cc979qn3	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:10.112	2026-04-02 16:31:10.112	\N
cmnhoyy4i01lfrkt4nh0tspea	cmnhoyy4e01lerkt4inwj9oey	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:10.146	2026-04-02 16:31:10.146	\N
cmnhoyy6y01ltrkt4624r4u9r	cmnhoyy6t01lsrkt4e6ms4jbk	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:10.234	2026-04-02 16:31:10.234	\N
cmnhoyy7o01lyrkt4ukd7nmwo	cmnhoyy7j01lxrkt4ckm5zylv	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:10.26	2026-04-02 16:31:10.26	\N
cmnhoyy7u01m0rkt4283kzb02	cmnhoyy7q01lzrkt4s3vnet05	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:10.266	2026-04-02 16:31:10.266	\N
cmnhoyy8301m2rkt44dv9v9v1	cmnhoyy7x01m1rkt4e50kwi09	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:10.275	2026-04-02 16:31:10.275	\N
cmnhoyyae01mdrkt4qlzxr1f3	cmnhoyya601mcrkt4jn4lk93q	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:10.358	2026-04-02 16:31:10.358	\N
cmnhoyyb401mhrkt4y84psyrn	cmnhoyyay01mgrkt4l4uz1732	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:10.384	2026-04-02 16:31:10.384	\N
cmnhoyybg01mjrkt48wsb2700	cmnhoyyba01mirkt4z9yv7on3	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:10.396	2026-04-02 16:31:10.396	\N
cmnhoyybw01mmrkt4edf0s6zh	cmnhoyybp01mlrkt4f0y3mgnc	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:10.412	2026-04-02 16:31:10.412	\N
cmnhoz2cn01mvrkt42zya0bh0	cmnhoz2cg01murkt4q7al13uh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:15.623	2026-04-02 16:31:15.623	\N
cmnhoz2dj01n0rkt4dvf1emc1	cmnhoz2dc01mzrkt4v3v7rkpj	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:15.655	2026-04-02 16:31:15.655	\N
cmnhoz2fw01narkt4tfup1s8e	cmnhoz2fp01n9rkt489ph5cyu	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:15.74	2026-04-02 16:31:15.74	\N
cmnhoz2id01norkt4hebljkdq	cmnhoz2i801nnrkt4lp0ubo6o	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:15.829	2026-04-02 16:31:15.829	\N
cmnhoz2io01nqrkt466yb1oxj	cmnhoz2ih01nprkt47mo93ei1	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:15.84	2026-04-02 16:31:15.84	\N
cmnhoz2ja01ntrkt4cddw7hix	cmnhoz2j201nsrkt4iizh4isk	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:15.862	2026-04-02 16:31:15.862	\N
cmnhoz2k301nyrkt415ledx0i	cmnhoz2ju01nxrkt4adzzb47q	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:15.891	2026-04-02 16:31:15.891	\N
cmnhoz2kc01o0rkt4kj3g8wk3	cmnhoz2k701nzrkt4f6hv75a0	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:15.9	2026-04-02 16:31:15.9	\N
cmnhoz2ki01o2rkt49u6xquzt	cmnhoz2kf01o1rkt4xqhw3f2k	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:15.906	2026-04-02 16:31:15.906	\N
cmnhoz2kq01o4rkt4pyco6wn4	cmnhoz2kl01o3rkt4ydkqcaqb	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:15.914	2026-04-02 16:31:15.914	\N
cmnhoz2ky01o6rkt45s5c7y2n	cmnhoz2kt01o5rkt4iyjigyd0	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:15.922	2026-04-02 16:31:15.922	\N
cmnhoz2l601o8rkt4uohr9hp5	cmnhoz2l201o7rkt4l6d2jhar	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:15.93	2026-04-02 16:31:15.93	\N
cmnhoz2lf01oarkt4mi9c6pql	cmnhoz2la01o9rkt4gq71a083	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:15.939	2026-04-02 16:31:15.939	\N
cmnhoz2ll01ocrkt4gm6iwi41	cmnhoz2lh01obrkt4upci17xa	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:15.945	2026-04-02 16:31:15.945	\N
cmnhoz2lt01oerkt4mhowzhqs	cmnhoz2lo01odrkt42b5kllh2	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:15.953	2026-04-02 16:31:15.953	\N
cmnhoz2m301ogrkt43wiu6eop	cmnhoz2ly01ofrkt48x9efv7j	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:15.963	2026-04-02 16:31:15.963	\N
cmnhoz2n801omrkt43b1e9oaj	cmnhoz2n101olrkt4uqpaothc	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-02 16:31:16.004	2026-04-02 16:31:16.004	\N
cmnhoz2nl01oorkt40elwwi8n	cmnhoz2ne01onrkt4ish4m9c5	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:16.017	2026-04-02 16:31:16.017	\N
cmnhoz2p501ovrkt47oawmus1	cmnhoz2oy01ourkt43txh1hd4	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:16.073	2026-04-02 16:31:16.073	\N
cmnhoz2pd01oxrkt4r549olpe	cmnhoz2p901owrkt4llsiytax	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	AUTOMATICA	t	2026-04-02 16:31:16.081	2026-04-02 16:31:16.081	\N
cmnhoz2q401p2rkt4br53jgqq	cmnhoz2pz01p1rkt46t9osogb	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:16.108	2026-04-02 16:31:16.108	\N
cmnhoz2r001p5rkt4x30jxd6q	cmnhoz2qu01p4rkt4yyjzovn1	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:16.14	2026-04-02 16:31:16.14	\N
cmnhoz2s601pbrkt47q0fsth9	cmnhoz2s001parkt4lcd6lj1e	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	AUTOMATICA	t	2026-04-02 16:31:16.182	2026-04-02 16:31:16.182	\N
cmnhoz2sf01pdrkt466oqm80e	cmnhoz2s901pcrkt4vw7h0oez	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:16.191	2026-04-02 16:31:16.191	\N
cmnhoz2sx01pgrkt43lqa2kqp	cmnhoz2sm01pfrkt4omh9mi2r	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:16.209	2026-04-02 16:31:16.209	\N
cmnhoz2uk01pkrkt4znbw1nxy	cmnhoz2uc01pjrkt40i6esjkz	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:16.268	2026-04-02 16:31:16.268	\N
cmnhoz2uw01pmrkt4525d9yvk	cmnhoz2uq01plrkt4q65mbwrh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:16.28	2026-04-02 16:31:16.28	\N
cmnhoz33o01qsrkt4xmxws3gs	cmnhoz33i01qrrkt4zyuv7mlw	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:16.596	2026-04-02 16:31:16.596	\N
cmnhoz35n01r2rkt4egh1f492	cmnhoz35j01r1rkt49dqfmfid	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:16.667	2026-04-02 16:31:16.667	\N
cmnhoz36o01r7rkt44o6fj87w	cmnhoz36f01r6rkt48c7a37yb	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:16.704	2026-04-02 16:31:16.704	\N
cmnhoz37u01rdrkt4ui6thefs	cmnhoz37n01rcrkt4avox2bia	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:16.747	2026-04-02 16:31:16.747	\N
cmnhoz39001rjrkt4uudv03q9	cmnhoz38u01rirkt44zjw129h	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:16.788	2026-04-02 16:31:16.788	\N
cmnhoz39d01rlrkt4csjhp6nt	cmnhoz39601rkrkt4rji8lmw1	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:16.801	2026-04-02 16:31:16.801	\N
cmnhoz3a301rprkt4agp68b0l	cmnhoz39y01rorkt4qqhalqzo	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:16.827	2026-04-02 16:31:16.827	\N
cmnhoz3ak01rsrkt4qsv9hgar	cmnhoz3af01rrrkt43rvyt44r	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:16.844	2026-04-02 16:31:16.844	\N
cmnhoz3ar01rurkt48hrjuqb9	cmnhoz3an01rtrkt4zaboteda	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:16.851	2026-04-02 16:31:16.851	\N
cmnhoz3b001rwrkt4vmpb9hmz	cmnhoz3aw01rvrkt4lqmngoe5	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:16.86	2026-04-02 16:31:16.86	\N
cmnhoz3bc01ryrkt4pqv9k7i7	cmnhoz3b401rxrkt4k62ynxp6	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:16.872	2026-04-02 16:31:16.872	\N
cmnhoz3br01s1rkt46wksvqxt	cmnhoz3bk01s0rkt49tficl1b	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:16.887	2026-04-02 16:31:16.887	\N
cmnhoz3cg01s6rkt4xvtb8w3u	cmnhoz3cd01s5rkt4s58384rl	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:16.912	2026-04-02 16:31:16.912	\N
cmnhoz3cz01sarkt4r99abfzt	cmnhoz3cv01s9rkt4nb6gjjjl	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:16.931	2026-04-02 16:31:16.931	\N
cmnhoz3d401scrkt4whvl6xfy	cmnhoz3d101sbrkt4u7db3qvz	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:16.936	2026-04-02 16:31:16.936	\N
cmnhoz3dm01sgrkt4mvzfu3qt	cmnhoz3di01sfrkt4e65xzh0a	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:16.954	2026-04-02 16:31:16.954	\N
cmnhoz3fo01srrkt4zdelrbip	cmnhoz3fg01sqrkt4t0sxufxf	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:17.028	2026-04-02 16:31:17.028	\N
cmnhoz3fw01strkt4d2bo7q9g	cmnhoz3fr01ssrkt4qo2y7z57	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:17.036	2026-04-02 16:31:17.036	\N
cmnhoz3hl01t5rkt4i4nnqepg	cmnhoz3hf01t4rkt4ucfyx0nh	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:17.097	2026-04-02 16:31:17.097	\N
cmnhoz3hw01t7rkt4gghd4gee	cmnhoz3hp01t6rkt45tagp8td	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:17.108	2026-04-02 16:31:17.108	\N
cmnhoz3ie01tbrkt4iaz40xzo	cmnhoz3ia01tarkt439nr15vh	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:17.126	2026-04-02 16:31:17.126	\N
cmnhoz3ja01tfrkt4dc4y98jx	cmnhoz3j101terkt42rdasy1v	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:17.158	2026-04-02 16:31:17.158	\N
cmnhoz3k801tirkt4dk499uhz	cmnhoz3jz01thrkt4nm55pulh	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:17.192	2026-04-02 16:31:17.192	\N
cmnhoz3kr01tmrkt4ionavj6q	cmnhoz3kk01tlrkt41id0gutl	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:17.211	2026-04-02 16:31:17.211	\N
cmnhoz3l801tprkt4ea75o338	cmnhoz3l101torkt4ibns8lnu	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:17.228	2026-04-02 16:31:17.228	\N
cmnhoz3lk01trrkt402qzfy61	cmnhoz3lf01tqrkt41pcyen46	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:17.24	2026-04-02 16:31:17.24	\N
cmnhozan101u9rkt4iep2cs5g	cmnhozamw01u8rkt4jrfh4jz8	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.365	2026-04-02 16:31:26.365	\N
cmnhozand01ubrkt4ar9w6run	cmnhozan601uarkt4kqy1301h	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:26.378	2026-04-02 16:31:26.378	\N
cmnhozanq01udrkt4sbq70sf4	cmnhozanj01ucrkt47dr75qvs	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:26.39	2026-04-02 16:31:26.39	\N
cmnhozanx01ufrkt4jxfph3f9	cmnhozans01uerkt447zdix7j	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:26.397	2026-04-02 16:31:26.397	\N
cmnhozapg01ukrkt4ttn6ngl2	cmnhozap901ujrkt4ura8fbez	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:26.452	2026-04-02 16:31:26.452	\N
cmnhozaqc01uprkt4w0ay9yfp	cmnhozaq401uorkt48z63bhn8	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.484	2026-04-02 16:31:26.484	\N
cmnhozaqu01urrkt4rz1n1omo	cmnhozaqm01uqrkt4wk2i6tdw	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.502	2026-04-02 16:31:26.502	\N
cmnhozar401utrkt45ymz2nik	cmnhozaqy01usrkt4cub92waz	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.512	2026-04-02 16:31:26.512	\N
cmnhozarg01uvrkt4jf7sxxle	cmnhozar801uurkt4u1zba4os	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.524	2026-04-02 16:31:26.524	\N
cmnhozaro01uxrkt4ji5etuxg	cmnhozark01uwrkt4mp2yksh0	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.533	2026-04-02 16:31:26.533	\N
cmnhozary01uzrkt4uumvc1be	cmnhozart01uyrkt4g02j0m7m	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.542	2026-04-02 16:31:26.542	\N
cmnhozasf01v1rkt42p9v3yvx	cmnhozas201v0rkt46wzdts5w	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.559	2026-04-02 16:31:26.559	\N
cmnhozatq01v5rkt4yvfge7oa	cmnhozath01v4rkt4ybtuo5wu	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	AUTOMATICA	t	2026-04-02 16:31:26.606	2026-04-02 16:31:26.606	\N
cmnhozau401v8rkt4ougo1ypy	cmnhozatz01v7rkt4lgvgrf73	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	AUTOMATICA	t	2026-04-02 16:31:26.62	2026-04-02 16:31:26.62	\N
cmnhozbb201x5rkt47zc3qsfl	cmnhozbay01x4rkt405izpl6c	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.23	2026-04-02 16:31:27.23	\N
cmnhozbbb01x7rkt4r8luxeup	cmnhozbb501x6rkt47zgsmjo0	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	AUTOMATICA	t	2026-04-02 16:31:27.239	2026-04-02 16:31:27.239	\N
cmnhozbbi01x9rkt4hoqf503k	cmnhozbbf01x8rkt4szgeu739	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.246	2026-04-02 16:31:27.246	\N
cmnhozbcf01xerkt4z83z1ztg	cmnhozbca01xdrkt49xay25ye	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.279	2026-04-02 16:31:27.279	\N
cmnhozbct01xgrkt4w6jimnl5	cmnhozbci01xfrkt4yugrjni5	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.293	2026-04-02 16:31:27.293	\N
cmnhozbdi01xirkt4xtlopl96	cmnhozbdc01xhrkt4cogh0557	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.318	2026-04-02 16:31:27.318	\N
cmnhozbf401xnrkt4bx6e1fvs	cmnhozbex01xmrkt4k1spe2hf	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.376	2026-04-02 16:31:27.376	\N
cmnhozbgn01xvrkt43eu3wo12	cmnhozbgh01xurkt4044qs7k0	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:27.431	2026-04-02 16:31:27.431	\N
cmnhozbip01y4rkt4rfefjf32	cmnhozbii01y3rkt4h7fghbiu	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:27.505	2026-04-02 16:31:27.505	\N
cmnhozbj801y7rkt42ms9iuzk	cmnhozbj001y6rkt4c3ytrjil	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	AUTOMATICA	t	2026-04-02 16:31:27.524	2026-04-02 16:31:27.524	\N
cmnhozbjo01y9rkt4h474kklk	cmnhozbjb01y8rkt4rzuyk3zn	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.54	2026-04-02 16:31:27.54	\N
cmnhozbk001ybrkt499lfrl5w	cmnhozbjt01yarkt4nwbeozl1	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.552	2026-04-02 16:31:27.552	\N
cmnhozbkw01yfrkt4lse0y8jv	cmnhozbkn01yerkt4shc4veor	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.584	2026-04-02 16:31:27.584	\N
cmnhozblc01yhrkt4wvbofwd2	cmnhozbl301ygrkt4f9i4imf5	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.6	2026-04-02 16:31:27.6	\N
cmnhozblp01yjrkt4jbvau1bp	cmnhozbli01yirkt4vp4fwrzb	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.613	2026-04-02 16:31:27.613	\N
cmnhozbm301ylrkt4x0jqbw7i	cmnhozblu01ykrkt49ps5nukv	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	AUTOMATICA	t	2026-04-02 16:31:27.627	2026-04-02 16:31:27.627	\N
cmnhp03u401ysrkt40fx1oocp	cmnhp03tj01yrrkt4wnyp4nrd	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:04.204	2026-04-02 16:32:04.204	cmnfkvenc010chgt44uzjdcc6
cmnhp03vk01z0rkt4db5i9xh9	cmnhp03vb01yzrkt4bi9hqder	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:04.256	2026-04-02 16:32:04.256	cmnfkvenc010chgt44uzjdcc6
cmnhp03wp01z6rkt4yka1lqji	cmnhp03wh01z5rkt47dlm6hvv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:04.297	2026-04-02 16:32:04.297	cmnfkvenc010chgt44uzjdcc6
cmnhp08ks0202rkt422982dhh	cmnhp08kl0201rkt4vonk5jtk	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.348	2026-04-02 16:32:10.348	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp08l40204rkt4cn9dc5un	cmnhp08kv0203rkt4u82wmnyq	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.36	2026-04-02 16:32:10.36	cmnfkvenc010chgt44uzjdcc6
cmnhp08ll0207rkt438uf8i3m	cmnhp08ld0206rkt4xhogv82j	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.377	2026-04-02 16:32:10.377	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp08lz0209rkt4of3hr9gv	cmnhp08lo0208rkt4idtgpm0r	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.391	2026-04-02 16:32:10.391	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp08n5020erkt4vf9qlrap	cmnhp08mu020drkt4qo2jtsgd	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.433	2026-04-02 16:32:10.433	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp08nk020grkt4os0clxs0	cmnhp08na020frkt4ajnp2vxr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.448	2026-04-02 16:32:10.448	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp08o4020jrkt4z1x8hm0e	cmnhp08nx020irkt4loii5nks	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.468	2026-04-02 16:32:10.468	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp08ov020mrkt4jjt8py4h	cmnhp08ok020lrkt4acp5fyqk	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.495	2026-04-02 16:32:10.495	cmnfkvkyn010dhgt4qymxazu8
cmnhp08p7020orkt4nztzfax0	cmnhp08ox020nrkt4n8itlmun	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.507	2026-04-02 16:32:10.507	cmnfkvenc010chgt44uzjdcc6
cmnhr8s2q02lzrkt472irmh9a	cmnhp0dff023orkt4pejmcoff	cmnffta06000068t4x50l5rq5	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:34:48.098	2026-04-02 17:34:48.098	\N
cmnhp08qk020trkt4ssnwuk65	cmnhp08qc020srkt4fm2l6imm	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.556	2026-04-02 16:32:10.556	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp08r7020vrkt4tady551n	cmnhp08qt020urkt4qbvt00ue	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.579	2026-04-02 16:32:10.579	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp08rv020xrkt4o6zy2saj	cmnhp08rc020wrkt4we18s9da	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.603	2026-04-02 16:32:10.603	cmnfkvenc010chgt44uzjdcc6
cmnhp08so0210rkt4v7c0yaib	cmnhp08sb020zrkt46tv7sh7t	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.632	2026-04-02 16:32:10.632	cmnfkvkyn010dhgt4qymxazu8
cmnhp08ti0214rkt4o500wt4i	cmnhp08tb0213rkt433bq5yig	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.662	2026-04-02 16:32:10.662	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp08un0217rkt4rybjx5r2	cmnhp08uc0216rkt4uo52pekf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.703	2026-04-02 16:32:10.703	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp08w2021erkt4cec7x5pf	cmnhp08vu021drkt4siua4rpu	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.754	2026-04-02 16:32:10.754	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp08wl021grkt4g3urwbfu	cmnhp08w6021frkt4xeghrjbo	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.773	2026-04-02 16:32:10.773	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp08x5021irkt436vq4ok3	cmnhp08wq021hrkt4ybk7ftig	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.793	2026-04-02 16:32:10.793	cmnfkvenc010chgt44uzjdcc6
cmnhp08xw021lrkt4q3zbgqi3	cmnhp08xj021krkt4mp5yssx2	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.82	2026-04-02 16:32:10.82	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp08z4021nrkt4wvdbhr1z	cmnhp08y4021mrkt4kr5cthot	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.864	2026-04-02 16:32:10.864	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp08zv021qrkt4fktxdcrb	cmnhp08zl021prkt411keoafd	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.891	2026-04-02 16:32:10.891	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp090l021srkt418wq8910	cmnhp0905021rrkt4qo1r8dwb	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.917	2026-04-02 16:32:10.917	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0919021urkt4p5d5yi27	cmnhp090u021trkt4o40gs4h4	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:10.942	2026-04-02 16:32:10.942	cmnfkvkyn010dhgt4qymxazu8
cmnhp094f021yrkt4n4ujplow	cmnhp0925021xrkt4cj1pztpj	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.055	2026-04-02 16:32:11.055	cmnfkvkyn010dhgt4qymxazu8
cmnhp095i0220rkt4qitvk093	cmnhp094p021zrkt4zjdi2vsr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.094	2026-04-02 16:32:11.094	cmnfkvkyn010dhgt4qymxazu8
cmnhp096h0222rkt4abew2x2w	cmnhp095y0221rkt4h7ddrv8i	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.129	2026-04-02 16:32:11.129	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp097e0224rkt4an9kd7z0	cmnhp096q0223rkt4iwnej23i	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.162	2026-04-02 16:32:11.162	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp09830226rkt4qpxymspu	cmnhp097r0225rkt4ph6tew5m	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.187	2026-04-02 16:32:11.187	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp099t022brkt4ly537oiu	cmnhp099d022arkt4nh4aeeil	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.249	2026-04-02 16:32:11.249	cmnfkvenc010chgt44uzjdcc6
cmnhp09bl022irkt4mx41j2lo	cmnhp09ba022hrkt42t23tehi	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.313	2026-04-02 16:32:11.313	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp09co022mrkt4v8yojs7d	cmnhp09cd022lrkt4x2p04030	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.352	2026-04-02 16:32:11.352	cmnfkvenc010chgt44uzjdcc6
cmnhp09eh022trkt4awuwb4b4	cmnhp09e6022srkt4dn5hjbfx	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.417	2026-04-02 16:32:11.417	cmnfkvenc010chgt44uzjdcc6
cmnhp09fd022xrkt4y1pxvpva	cmnhp09f4022wrkt419o8hhs0	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.449	2026-04-02 16:32:11.449	cmnfkvenc010chgt44uzjdcc6
cmnhp09fq022zrkt4axxwsgx8	cmnhp09fh022yrkt4qvrtq8hv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.462	2026-04-02 16:32:11.462	cmnfkvenc010chgt44uzjdcc6
cmnhp09gt0234rkt4c48zmyrt	cmnhp09gi0233rkt4ucfe8t32	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.501	2026-04-02 16:32:11.501	cmnfkvenc010chgt44uzjdcc6
cmnhp09ia023arkt4g0xhgk40	cmnhp09hx0239rkt4bl4pxghh	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.554	2026-04-02 16:32:11.554	cmnfkvenc010chgt44uzjdcc6
cmnhp09k6023erkt41nju3h6t	cmnhp09jm023drkt4d3ubfq6p	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.622	2026-04-02 16:32:11.622	cmnfkvenc010chgt44uzjdcc6
cmnhp09ls023mrkt4p2ljpim7	cmnhp09lj023lrkt44mtch0x1	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:11.68	2026-04-02 16:32:11.68	cmnfkvenc010chgt44uzjdcc6
cmnhp0dg2023qrkt48eosa3sz	cmnhp0dfp023prkt4o81j7ich	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.658	2026-04-02 16:32:16.658	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0dgi023srkt4ojpq3yne	cmnhp0dg5023rrkt4ozr3xwf6	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.674	2026-04-02 16:32:16.674	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0dgw023urkt4lnxsu49r	cmnhp0dgo023trkt4gcwqx60e	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.688	2026-04-02 16:32:16.688	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0dhi023xrkt4sqdrkqsi	cmnhp0dha023wrkt4ij7ukvne	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.711	2026-04-02 16:32:16.711	cmnfkvkyn010dhgt4qymxazu8
cmnhp0dhx023zrkt4rukiq0dj	cmnhp0dhl023yrkt40is5k8gj	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.725	2026-04-02 16:32:16.725	cmnfkvenc010chgt44uzjdcc6
cmnhp0dil0242rkt4yumo8btu	cmnhp0dia0241rkt4j3e3zdbo	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.749	2026-04-02 16:32:16.749	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0djk0247rkt46k5lawqz	cmnhp0djc0246rkt42bing7tr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.784	2026-04-02 16:32:16.784	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0djw0249rkt498d2cu6l	cmnhp0djo0248rkt4qw6m36t3	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.796	2026-04-02 16:32:16.796	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0dkf024brkt4fyi2rct6	cmnhp0dk1024arkt44i2pym32	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.815	2026-04-02 16:32:16.815	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0dl5024erkt40waoka2p	cmnhp0dku024drkt4bm7ekvne	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.841	2026-04-02 16:32:16.841	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0dlo024grkt4nihpl90a	cmnhp0dlb024frkt4xipawdx5	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.86	2026-04-02 16:32:16.86	cmnfkvkyn010dhgt4qymxazu8
cmnhp0dm8024irkt4zya4rlg7	cmnhp0dls024hrkt4a092vd9v	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.88	2026-04-02 16:32:16.88	cmnfkvenc010chgt44uzjdcc6
cmnhp0dny024orkt4e7cha74z	cmnhp0dnk024nrkt43me63ili	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.942	2026-04-02 16:32:16.942	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0doi024qrkt460eqewar	cmnhp0do5024prkt4mvbd3qff	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:16.962	2026-04-02 16:32:16.962	cmnfkvkyn010dhgt4qymxazu8
cmnhp0dpo024trkt4ellyb62n	cmnhp0dp0024srkt482kgk0r4	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.004	2026-04-02 16:32:17.004	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0drm024vrkt43yxn4a21	cmnhp0dq3024urkt46yyq7sdp	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.074	2026-04-02 16:32:17.074	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0dwm024xrkt4l1pr530d	cmnhp0ds9024wrkt4jbabtktm	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.255	2026-04-02 16:32:17.255	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0e29024zrkt4hgojd6nn	cmnhp0e1w024yrkt4ymjbj6sw	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.457	2026-04-02 16:32:17.457	cmnfkvenc010chgt44uzjdcc6
cmnhp0e3q0256rkt4xrl7x6n7	cmnhp0e3f0255rkt4m0olw9n2	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.51	2026-04-02 16:32:17.51	cmnfkvkyn010dhgt4qymxazu8
cmnhp0e470258rkt4hez38dt3	cmnhp0e3w0257rkt4s3lewquv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.527	2026-04-02 16:32:17.527	cmnfkvenc010chgt44uzjdcc6
cmnhp0e4m025arkt4kib5p1c7	cmnhp0e4c0259rkt4j2k3wq7e	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.543	2026-04-02 16:32:17.543	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0e57025drkt4sae679be	cmnhp0e4z025crkt4ilfwtvvo	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.563	2026-04-02 16:32:17.563	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0e5m025frkt4f0ux5u4b	cmnhp0e5c025erkt4dqeo5g0x	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.578	2026-04-02 16:32:17.578	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0e60025hrkt4ep7y2o7k	cmnhp0e5q025grkt4t4hzcjhz	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.592	2026-04-02 16:32:17.592	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0e6u025lrkt4vm1dqg4v	cmnhp0e6l025krkt4g9vg16oc	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.622	2026-04-02 16:32:17.622	cmnfkvkyn010dhgt4qymxazu8
cmnhp0e7b025nrkt4tma7s16b	cmnhp0e6y025mrkt4fed6eirw	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.639	2026-04-02 16:32:17.639	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0e7z025prkt4qz0jrsy6	cmnhp0e7o025orkt4mmqd6nl5	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.663	2026-04-02 16:32:17.663	cmnfkvenc010chgt44uzjdcc6
cmnhp0e8u025trkt4mq8uc4s0	cmnhp0e8k025srkt403ob305l	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.694	2026-04-02 16:32:17.694	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0e99025vrkt40x8yvw60	cmnhp0e8y025urkt4je9cja5g	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.709	2026-04-02 16:32:17.709	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0e9p025xrkt4g6hb1bk5	cmnhp0e9d025wrkt447yfca4y	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.725	2026-04-02 16:32:17.725	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0ea2025zrkt434kmt767	cmnhp0e9t025yrkt424hazt0k	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.738	2026-04-02 16:32:17.738	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0ead0261rkt4jgc7k3aa	cmnhp0ea60260rkt4vlxmvqhr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.749	2026-04-02 16:32:17.749	cmnfkvkyn010dhgt4qymxazu8
cmnhp0eaq0263rkt4ktkbbkt3	cmnhp0eai0262rkt4q6uwz3ji	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.762	2026-04-02 16:32:17.762	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0eba0266rkt4fitjyufe	cmnhp0eb20265rkt4s7i3zi4n	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.782	2026-04-02 16:32:17.782	cmnfkvenc010chgt44uzjdcc6
cmnhp0ebp0268rkt4g3cctxcd	cmnhp0ebe0267rkt42jms5zau	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.797	2026-04-02 16:32:17.797	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0ecg026crkt4iprusc28	cmnhp0ec7026brkt488l1p0c8	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.825	2026-04-02 16:32:17.825	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0ed9026grkt4glpxvqdw	cmnhp0ed1026frkt4oijbdc10	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.854	2026-04-02 16:32:17.854	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0ee3026lrkt47ljvo6h8	cmnhp0edw026krkt4nnea0v9d	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.883	2026-04-02 16:32:17.883	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0eef026nrkt4fcrd4fe1	cmnhp0ee8026mrkt42jlgngq4	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.895	2026-04-02 16:32:17.895	cmnfkvkyn010dhgt4qymxazu8
cmnhp0eev026prkt4n1mqvtyt	cmnhp0eem026orkt4mz8jg8ty	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.911	2026-04-02 16:32:17.911	cmnfkvenc010chgt44uzjdcc6
cmnhp0egb026trkt4v1i6q0dk	cmnhp0efz026srkt4hmcyw986	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.964	2026-04-02 16:32:17.964	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0eh2026wrkt4puc6apd2	cmnhp0egs026vrkt42gklrrp9	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:17.99	2026-04-02 16:32:17.99	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0ehh026yrkt4hpcexxx8	cmnhp0eh5026xrkt4qdoytfsr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.005	2026-04-02 16:32:18.005	cmnfkvenc010chgt44uzjdcc6
cmnhp0eht0270rkt4sw98z0s2	cmnhp0ehk026zrkt45cxrm1lr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.017	2026-04-02 16:32:18.017	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0ei80272rkt40b0fepi6	cmnhp0ehy0271rkt4pn5job34	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.032	2026-04-02 16:32:18.032	cmnfkvkyn010dhgt4qymxazu8
cmnhp0ej70277rkt4g6xoiq4u	cmnhp0ej10276rkt4rb69qnxk	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.067	2026-04-02 16:32:18.067	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0ek4027drkt4s1nesqdh	cmnhp0ejx027crkt4vf6h89qy	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.1	2026-04-02 16:32:18.1	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0el0027irkt4elai6qwr	cmnhp0ekr027hrkt4xgimz8vp	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.132	2026-04-02 16:32:18.132	cmnfkvkyn010dhgt4qymxazu8
cmnhp0elb027krkt4ayj78j59	cmnhp0el5027jrkt4rbqap7jq	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.143	2026-04-02 16:32:18.143	cmnfkvenc010chgt44uzjdcc6
cmnhp0eln027mrkt4u2km9bd0	cmnhp0ele027lrkt4xya0wle7	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.155	2026-04-02 16:32:18.155	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0em1027orkt4qfue2c1c	cmnhp0els027nrkt48wrz5gxn	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.169	2026-04-02 16:32:18.169	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0emh027rrkt4kbid09ep	cmnhp0ema027qrkt4ckci45jq	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.185	2026-04-02 16:32:18.185	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0emr027trkt4v33cq3nu	cmnhp0eml027srkt4hueo9atu	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.195	2026-04-02 16:32:18.195	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0enb027wrkt4j2x9gp6l	cmnhp0en4027vrkt4f322sgmn	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.215	2026-04-02 16:32:18.215	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0enp027yrkt49ldl71y1	cmnhp0eng027xrkt4p8no8b1b	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.229	2026-04-02 16:32:18.229	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0eo20280rkt4cc5649mb	cmnhp0ent027zrkt4jvz19a10	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.242	2026-04-02 16:32:18.242	cmnfkvkyn010dhgt4qymxazu8
cmnhp0eof0282rkt4yxperwyl	cmnhp0eo60281rkt4wxd1n4p2	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.255	2026-04-02 16:32:18.255	cmnfkvenc010chgt44uzjdcc6
cmnhp0epy0288rkt4r035i5ya	cmnhp0epp0287rkt4d559tdsv	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.31	2026-04-02 16:32:18.31	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0er6028drkt4ag8tzsrn	cmnhp0equ028crkt4w10cigvd	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.354	2026-04-02 16:32:18.354	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0erk028frkt4gvt3kqlw	cmnhp0erb028erkt4sp44sk83	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.368	2026-04-02 16:32:18.368	cmnfkvenc010chgt44uzjdcc6
cmnhp0esb028jrkt4xfh76eun	cmnhp0es3028irkt4n132c9nr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.395	2026-04-02 16:32:18.395	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0esp028lrkt4utkcaytm	cmnhp0esg028krkt48db36bwr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.409	2026-04-02 16:32:18.409	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0et4028nrkt49ynpbgkf	cmnhp0est028mrkt4gxvimxci	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.424	2026-04-02 16:32:18.424	cmnfkvkyn010dhgt4qymxazu8
cmnhp0eto028qrkt4x52bc6b7	cmnhp0etf028prkt4lb0s431v	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:18.444	2026-04-02 16:32:18.444	cmnfkvkyn010dhgt4qymxazu8
cmnhp0i06028trkt4ermyhxs5	cmnhp0hzy028srkt4ro8gq11w	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.566	2026-04-02 16:32:22.566	cmnfkp2vg00zmhgt4890h7c56
cmnhp0i0n028vrkt443wyc1e4	cmnhp0i0c028urkt440qr0f8x	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.583	2026-04-02 16:32:22.583	cmnfks14q00zzhgt47kj8x90e
cmnhp0i11028xrkt43btphlvj	cmnhp0i0s028wrkt4wtq67izl	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.597	2026-04-02 16:32:22.597	cmnfkpf0u00zohgt40qewt2f3
cmnhp0i1e028zrkt4nb777w1i	cmnhp0i16028yrkt4dujlij4x	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.61	2026-04-02 16:32:22.61	cmnfkq1wt00zshgt4nv418741
cmnhp0i1n0291rkt49xxtmdca	cmnhp0i1g0290rkt4aexrxzu0	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.619	2026-04-02 16:32:22.619	cmnfkskbx0102hgt4wp2stj9s
cmnhp0i1z0293rkt486xd8rrb	cmnhp0i1r0292rkt4q5b3hcpo	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.631	2026-04-02 16:32:22.631	cmnfks7y90100hgt4htds26dj
cmnhp0i280295rkt40l1vfpcx	cmnhp0i220294rkt4wkcgwc52	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.64	2026-04-02 16:32:22.64	cmnfkpwhq00zrhgt4kwye95fl
cmnhp0i2k0297rkt483fcoqi2	cmnhp0i2b0296rkt41e9p16a0	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.652	2026-04-02 16:32:22.652	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0i3b0299rkt4826fhctz	cmnhp0i2r0298rkt4356neww2	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.679	2026-04-02 16:32:22.679	cmnfkvrla010ehgt4pntoyk13
cmnhp0i3p029brkt4vw729lzk	cmnhp0i3f029arkt4dwl0wbxo	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.693	2026-04-02 16:32:22.693	cmnfkvkyn010dhgt4qymxazu8
cmnhp0i45029drkt4dwdkex4s	cmnhp0i3t029crkt45kgpogs9	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.709	2026-04-02 16:32:22.709	cmnfkrvw300zyhgt403qbk0s6
cmnhp0i4i029frkt41zmyp2z9	cmnhp0i49029erkt40oktys89	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.722	2026-04-02 16:32:22.722	cmnfksd8d0101hgt4l62jg4a7
cmnhp0i4s029hrkt4dp3es2d7	cmnhp0i4m029grkt4xjj0ngs9	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.732	2026-04-02 16:32:22.732	cmnfkqexq00zthgt4g4n1fbfy
cmnhp0i53029jrkt4urj0tcn2	cmnhp0i4w029irkt4x06t4to2	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.743	2026-04-02 16:32:22.743	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0i5e029lrkt4dajipixp	cmnhp0i56029krkt4wddjew7g	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.754	2026-04-02 16:32:22.754	cmnfl616e01cdhgt468d1xir6
cmnhp0i5p029nrkt4y3mnndbe	cmnhp0i5i029mrkt4hdrgu2v0	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.765	2026-04-02 16:32:22.765	cmnfkpkhd00zphgt4elqe9l29
cmnhp0i5z029prkt4wlz2zk0w	cmnhp0i5r029orkt4gzf2vf4l	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.775	2026-04-02 16:32:22.775	cmnfkvkyn010dhgt4qymxazu8
cmnhp0i6c029rrkt4ge7gk2xk	cmnhp0i62029qrkt4wa5691qf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.788	2026-04-02 16:32:22.788	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0i6p029trkt4kodp422d	cmnhp0i6g029srkt4jz48ipnf	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.801	2026-04-02 16:32:22.801	cmnfkvenc010chgt44uzjdcc6
cmnhp0i73029vrkt4iv5euo0a	cmnhp0i6u029urkt4z2e8s4re	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.815	2026-04-02 16:32:22.815	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0i7g029xrkt4y1rqbrtm	cmnhp0i77029wrkt4wtzd893f	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.828	2026-04-02 16:32:22.828	cmnfkvkyn010dhgt4qymxazu8
cmnhp0i7u029zrkt48a6pe07g	cmnhp0i7k029yrkt4wfqc3pz1	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.842	2026-04-02 16:32:22.842	cmnfkrvw300zyhgt403qbk0s6
cmnhp0i8902a1rkt4um1o2bcw	cmnhp0i7y02a0rkt4rva4af58	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.857	2026-04-02 16:32:22.857	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0i8m02a3rkt4c7m3mdj3	cmnhp0i8d02a2rkt4tgop7yqj	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.87	2026-04-02 16:32:22.87	cmnfkq1wt00zshgt4nv418741
cmnhp0i8x02a5rkt4uj72jn1y	cmnhp0i8q02a4rkt4aimfbcwr	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.881	2026-04-02 16:32:22.881	cmnfkskbx0102hgt4wp2stj9s
cmnhp0i9b02a7rkt4skj2zor6	cmnhp0i9202a6rkt4214gfeb5	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.895	2026-04-02 16:32:22.895	cmnfksd8d0101hgt4l62jg4a7
cmnhp0i9q02a9rkt4qv6kc7sk	cmnhp0i9f02a8rkt4y17fzcgw	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.911	2026-04-02 16:32:22.911	cmnfkp2vg00zmhgt4890h7c56
cmnhp0ia202abrkt4vrpz5r72	cmnhp0i9t02aarkt48ewi773s	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.922	2026-04-02 16:32:22.922	cmnfkqexq00zthgt4g4n1fbfy
cmnhp0iad02adrkt4k24shjnt	cmnhp0ia502acrkt442z4spgx	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.933	2026-04-02 16:32:22.933	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0iar02afrkt4s27qddc7	cmnhp0iah02aerkt4j9qo29j6	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.947	2026-04-02 16:32:22.947	cmnfkvkyn010dhgt4qymxazu8
cmnhp0ibq02ahrkt4vump8bs6	cmnhp0ib302agrkt40dyj8uhh	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:22.982	2026-04-02 16:32:22.982	cmnfks14q00zzhgt47kj8x90e
cmnhp0ic902ajrkt43wzibwgd	cmnhp0ibx02airkt4vefq37rw	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.001	2026-04-02 16:32:23.001	cmnfks7y90100hgt4htds26dj
cmnhp0icw02alrkt4cm42mzj7	cmnhp0ich02akrkt4s92j148f	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.025	2026-04-02 16:32:23.025	cmnfkpkhd00zphgt4elqe9l29
cmnhp0idi02anrkt4p3puaj44	cmnhp0id102amrkt4iqu0focr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.046	2026-04-02 16:32:23.046	cmnfl616e01cdhgt468d1xir6
cmnhp0iea02aprkt44lh11vp7	cmnhp0idv02aorkt41ugnspgv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.074	2026-04-02 16:32:23.074	cmnfkvrla010ehgt4pntoyk13
cmnhp0ieo02arrkt4tzsk3kqq	cmnhp0ied02aqrkt4vef0d927	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.088	2026-04-02 16:32:23.088	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0if102atrkt4x6e6vvs3	cmnhp0ies02asrkt45xo70nwf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.101	2026-04-02 16:32:23.101	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0ifg02avrkt43po698o3	cmnhp0if702aurkt40fmrsjrb	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.116	2026-04-02 16:32:23.116	cmnfkvenc010chgt44uzjdcc6
cmnhp0ifs02axrkt42k902rqx	cmnhp0ifk02awrkt4tnus6oxs	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.128	2026-04-02 16:32:23.128	cmnfkpf0u00zohgt40qewt2f3
cmnhp0ig302azrkt4ccoumzkk	cmnhp0ifw02ayrkt4pejau9am	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.139	2026-04-02 16:32:23.139	cmnfkpwhq00zrhgt4kwye95fl
cmnhp0igg02b1rkt436jppxbw	cmnhp0ig702b0rkt4kh8hrh0q	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.152	2026-04-02 16:32:23.152	cmnfkpwhq00zrhgt4kwye95fl
cmnhp0igs02b3rkt4z32wyote	cmnhp0igl02b2rkt4ecnihlyu	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.164	2026-04-02 16:32:23.164	cmnfkqexq00zthgt4g4n1fbfy
cmnhp0ihy02b5rkt493kkewv9	cmnhp0ih102b4rkt4eawynmjf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.206	2026-04-02 16:32:23.206	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0iib02b7rkt414og9v9g	cmnhp0ii202b6rkt4xzi3t9si	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.219	2026-04-02 16:32:23.219	cmnfkvkyn010dhgt4qymxazu8
cmnhp0iio02b9rkt4erg5zq9w	cmnhp0iig02b8rkt4xtxjt7m5	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.232	2026-04-02 16:32:23.232	cmnfkpkhd00zphgt4elqe9l29
cmnhp0ij602bbrkt4iqohg6fs	cmnhp0iiv02barkt4o4hwnwe3	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.25	2026-04-02 16:32:23.25	cmnfks7y90100hgt4htds26dj
cmnhp0ijn02bdrkt4m2fijqxt	cmnhp0ijc02bcrkt45ymoc4ob	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.267	2026-04-02 16:32:23.267	cmnfkvenc010chgt44uzjdcc6
cmnhp0ik102bfrkt4ys5ijqgk	cmnhp0ijt02berkt4xmn34v5c	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.281	2026-04-02 16:32:23.281	cmnfkpf0u00zohgt40qewt2f3
cmnhp0ikc02bhrkt40bw03yaw	cmnhp0ik602bgrkt47f64s00r	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.292	2026-04-02 16:32:23.292	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0ikl02bjrkt43eauoq1t	cmnhp0ikf02birkt4f9jvu1xl	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.301	2026-04-02 16:32:23.301	cmnfkp2vg00zmhgt4890h7c56
cmnhp0ikw02blrkt49hl9y19m	cmnhp0ikq02bkrkt4l9i7a2c2	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.312	2026-04-02 16:32:23.312	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0il502bnrkt4gid9gii6	cmnhp0iky02bmrkt4m4u8gbxt	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.321	2026-04-02 16:32:23.321	cmnfkrvw300zyhgt403qbk0s6
cmnhp0ilg02bprkt4migqbuo3	cmnhp0il902borkt4nx4fiq4m	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.332	2026-04-02 16:32:23.332	cmnfks7y90100hgt4htds26dj
cmnhp0ilr02brrkt4nykec0tb	cmnhp0ilk02bqrkt4yejswyk4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.343	2026-04-02 16:32:23.343	cmnfkskbx0102hgt4wp2stj9s
cmnhp0im102btrkt4m8ek7ry8	cmnhp0ilv02bsrkt41pkfpz8y	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.354	2026-04-02 16:32:23.354	cmnfkvrla010ehgt4pntoyk13
cmnhp0imd02bvrkt4bsd195o6	cmnhp0im402burkt462o35laq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.365	2026-04-02 16:32:23.365	cmnfksd8d0101hgt4l62jg4a7
cmnhp0imp02bxrkt4u02r94pv	cmnhp0imh02bwrkt48c21p99t	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.377	2026-04-02 16:32:23.377	cmnfkvkyn010dhgt4qymxazu8
cmnhp0in102bzrkt49yukdrcf	cmnhp0ims02byrkt4qd4ffu6l	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.389	2026-04-02 16:32:23.389	cmnfkq1wt00zshgt4nv418741
cmnhp0inh02c1rkt4qoc4para	cmnhp0in602c0rkt4dpudpb8l	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.405	2026-04-02 16:32:23.405	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0inw02c3rkt4nqewofef	cmnhp0inl02c2rkt4wrvyf4vx	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.42	2026-04-02 16:32:23.42	cmnfl616e01cdhgt468d1xir6
cmnhp0ior02c5rkt4il0sbktm	cmnhp0iod02c4rkt4x8vev39d	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.451	2026-04-02 16:32:23.451	cmnfks14q00zzhgt47kj8x90e
cmnhp0ipd02c7rkt47imt5nfk	cmnhp0ioz02c6rkt4to8nhnsf	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.474	2026-04-02 16:32:23.474	cmnfks7y90100hgt4htds26dj
cmnhp0iq102c9rkt4wv1ejxej	cmnhp0ipj02c8rkt45cgwd078	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.497	2026-04-02 16:32:23.497	cmnfkvrla010ehgt4pntoyk13
cmnhp0iqf02cbrkt4qzql5xll	cmnhp0iq602carkt4iwzfy1mm	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.511	2026-04-02 16:32:23.511	cmnfkp2vg00zmhgt4890h7c56
cmnhp0is602cdrkt43a6mpnil	cmnhp0irw02ccrkt46wf00wr2	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.574	2026-04-02 16:32:23.574	cmnfksd8d0101hgt4l62jg4a7
cmnhp0isk02cfrkt4d3bpmxlx	cmnhp0is902cerkt4729sxnz0	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.588	2026-04-02 16:32:23.588	cmnfkpf0u00zohgt40qewt2f3
cmnhp0it102chrkt4l6n8yl1c	cmnhp0iso02cgrkt484pzqbne	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.605	2026-04-02 16:32:23.605	cmnfkpkhd00zphgt4elqe9l29
cmnhp0itg02cjrkt4r2elvx2x	cmnhp0it502cirkt4e4cchh1h	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.62	2026-04-02 16:32:23.62	cmnfkrvw300zyhgt403qbk0s6
cmnhp0itx02clrkt4ssgwgkkr	cmnhp0itl02ckrkt48bgv9fhj	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.637	2026-04-02 16:32:23.637	cmnfkskbx0102hgt4wp2stj9s
cmnhp0iub02cnrkt43iy4u2jp	cmnhp0iu202cmrkt4e4nc741k	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.651	2026-04-02 16:32:23.651	cmnfkpwhq00zrhgt4kwye95fl
cmnhp0ium02cprkt45bgskg82	cmnhp0iuf02corkt4505aa95b	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.662	2026-04-02 16:32:23.662	cmnfl616e01cdhgt468d1xir6
cmnhp0iuz02crrkt4t3i2v8rl	cmnhp0iup02cqrkt4szs9h92b	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.675	2026-04-02 16:32:23.675	cmnfks14q00zzhgt47kj8x90e
cmnhp0iva02ctrkt4n0xizfe6	cmnhp0iv202csrkt428q2u4dh	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.686	2026-04-02 16:32:23.686	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0ivn02cvrkt4ungqfjma	cmnhp0ive02curkt4u21ongez	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.699	2026-04-02 16:32:23.699	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0iwi02cxrkt4ma5jy5b3	cmnhp0iw702cwrkt47976knua	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.73	2026-04-02 16:32:23.73	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0iwv02czrkt4dupntj6l	cmnhp0iwm02cyrkt4k135qb7u	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.743	2026-04-02 16:32:23.743	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0ixc02d1rkt4jy2926er	cmnhp0ix202d0rkt4p4q2jipi	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.76	2026-04-02 16:32:23.76	cmnfkvkyn010dhgt4qymxazu8
cmnhp0ixr02d3rkt4btlosnzu	cmnhp0ixg02d2rkt4l1np2me3	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.775	2026-04-02 16:32:23.775	cmnfkvenc010chgt44uzjdcc6
cmnhp0iy202d5rkt4vgiu4rnf	cmnhp0ixu02d4rkt4dn03huvu	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.786	2026-04-02 16:32:23.786	cmnfkvkyn010dhgt4qymxazu8
cmnhp0iyf02d7rkt44vnifzxg	cmnhp0iy602d6rkt4473o5qet	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.799	2026-04-02 16:32:23.799	cmnfkvkyn010dhgt4qymxazu8
cmnhp0iys02d9rkt4xhyxts76	cmnhp0iyl02d8rkt4l39n2lqk	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.812	2026-04-02 16:32:23.812	cmnfkq1wt00zshgt4nv418741
cmnhp0iz602dbrkt4yrj8oq99	cmnhp0iyw02darkt4l48llw4l	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.826	2026-04-02 16:32:23.826	cmnfkqexq00zthgt4g4n1fbfy
cmnhp0izg02ddrkt4nqqao9ee	cmnhp0iz902dcrkt49lubd5ub	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.836	2026-04-02 16:32:23.836	cmnfks7y90100hgt4htds26dj
cmnhp0izq02dfrkt4chikzide	cmnhp0izk02derkt4tqpm2ma0	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.846	2026-04-02 16:32:23.846	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0izz02dhrkt4z2owbvdd	cmnhp0izs02dgrkt4gajhi0du	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.855	2026-04-02 16:32:23.855	cmnfkvkyn010dhgt4qymxazu8
cmnhp0j0802djrkt48i3yz5s2	cmnhp0j0302dirkt4nes2fgj9	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.864	2026-04-02 16:32:23.864	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0j0h02dlrkt47972w31n	cmnhp0j0b02dkrkt40rmitx1g	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.873	2026-04-02 16:32:23.873	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0j0u02dnrkt4ocpob7sn	cmnhp0j0m02dmrkt4uaxdlvca	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.886	2026-04-02 16:32:23.886	cmnfkvenc010chgt44uzjdcc6
cmnhp0j1702dprkt4sgxvxidk	cmnhp0j0y02dorkt472spikue	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.9	2026-04-02 16:32:23.9	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0j1o02drrkt40dh8hfmu	cmnhp0j1d02dqrkt4c0321737	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.916	2026-04-02 16:32:23.916	cmnfkq1wt00zshgt4nv418741
cmnhp0j2502dtrkt4ar4ikokj	cmnhp0j1v02dsrkt46rg8w6vp	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.933	2026-04-02 16:32:23.933	cmnfkq1wt00zshgt4nv418741
cmnhp0j2j02dvrkt4tjuo55iv	cmnhp0j2a02durkt4io6cldwi	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.947	2026-04-02 16:32:23.947	cmnfkpwhq00zrhgt4kwye95fl
cmnhp0j2y02dxrkt45xna6k01	cmnhp0j2n02dwrkt47dbboc1c	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.962	2026-04-02 16:32:23.962	cmnfkpwhq00zrhgt4kwye95fl
cmnhp0j3t02e2rkt4fussy2d8	cmnhp0j3i02e1rkt44vkqorb6	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:23.993	2026-04-02 16:32:23.993	cmnfl616e01cdhgt468d1xir6
cmnhp0j4302e4rkt4y3x8fx0f	cmnhp0j3x02e3rkt436wmknmk	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.003	2026-04-02 16:32:24.003	cmnfl616e01cdhgt468d1xir6
cmnhp0j4d02e6rkt43r6j7yq3	cmnhp0j4602e5rkt42wom4be6	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.013	2026-04-02 16:32:24.013	cmnfkpkhd00zphgt4elqe9l29
cmnhp0j4m02e8rkt4vn18gwqq	cmnhp0j4h02e7rkt46d76j65m	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.022	2026-04-02 16:32:24.022	cmnfkpkhd00zphgt4elqe9l29
cmnhp0j4w02earkt4npzkm9nu	cmnhp0j4p02e9rkt4krrtipeo	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.032	2026-04-02 16:32:24.032	cmnfks14q00zzhgt47kj8x90e
cmnhp0j5502ecrkt40yx9x81t	cmnhp0j4z02ebrkt4y6tdxwe4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.041	2026-04-02 16:32:24.041	cmnfks14q00zzhgt47kj8x90e
cmnhp0j5i02eerkt4wela2y35	cmnhp0j5902edrkt4rhedsghh	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.054	2026-04-02 16:32:24.054	cmnfkpf0u00zohgt40qewt2f3
cmnhp0j5v02egrkt4g40fag8g	cmnhp0j5m02efrkt4wzczv2fq	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.067	2026-04-02 16:32:24.067	cmnfkpf0u00zohgt40qewt2f3
cmnhp0j6602eirkt4rsrtvap7	cmnhp0j5z02ehrkt4qranaq5f	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.078	2026-04-02 16:32:24.078	cmnfkp2vg00zmhgt4890h7c56
cmnhp0j6k02ekrkt4rqm2rmmt	cmnhp0j6a02ejrkt4qkedc10c	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.092	2026-04-02 16:32:24.092	cmnfkp2vg00zmhgt4890h7c56
cmnhp0j7502emrkt46r8hp1mc	cmnhp0j6q02elrkt48imvk6rs	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.113	2026-04-02 16:32:24.113	cmnfkskbx0102hgt4wp2stj9s
cmnhp0j7m02eorkt4dmskcj94	cmnhp0j7902enrkt4eeoj97e9	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.13	2026-04-02 16:32:24.13	cmnfks7y90100hgt4htds26dj
cmnhp0j8202errkt4l55zvhgz	cmnhp0j7w02eqrkt4dsgp9htn	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.146	2026-04-02 16:32:24.146	cmnfks7y90100hgt4htds26dj
cmnhp0j8e02etrkt4fs1l59fm	cmnhp0j8702esrkt429p0g1oc	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.158	2026-04-02 16:32:24.158	cmnfkvrla010ehgt4pntoyk13
cmnhp0j8o02evrkt4ug1qii9p	cmnhp0j8h02eurkt424bkslnw	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.168	2026-04-02 16:32:24.168	cmnfkrvw300zyhgt403qbk0s6
cmnhp0j9002exrkt44m8llquh	cmnhp0j8r02ewrkt4tql6p8vg	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.18	2026-04-02 16:32:24.18	cmnfkvrla010ehgt4pntoyk13
cmnhp0j9a02ezrkt4tdyoqsj5	cmnhp0j9302eyrkt41blcko3y	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.19	2026-04-02 16:32:24.19	cmnfkqexq00zthgt4g4n1fbfy
cmnhp0j9o02f1rkt49vu9eb76	cmnhp0j9h02f0rkt42y48y3xm	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.204	2026-04-02 16:32:24.204	cmnfkvkyn010dhgt4qymxazu8
cmnhp0j9y02f3rkt42ix9rdcb	cmnhp0j9s02f2rkt4m101zj1t	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.214	2026-04-02 16:32:24.214	cmnfkpf0u00zohgt40qewt2f3
cmnhp0jaa02f5rkt40ysxrrfj	cmnhp0ja202f4rkt4gx7y69il	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.226	2026-04-02 16:32:24.226	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jam02f7rkt4s9mvg7bo	cmnhp0jae02f6rkt489f5yvor	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.238	2026-04-02 16:32:24.238	cmnfkrvw300zyhgt403qbk0s6
cmnhp0jaw02f9rkt4taw0q7dv	cmnhp0jaq02f8rkt4pvjey0t0	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.248	2026-04-02 16:32:24.248	cmnfkqexq00zthgt4g4n1fbfy
cmnhp0jba02fbrkt47fa5p22o	cmnhp0jaz02farkt4fblr75f5	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.262	2026-04-02 16:32:24.262	cmnfksd8d0101hgt4l62jg4a7
cmnhp0jbp02fdrkt4d8p436yp	cmnhp0jbe02fcrkt4i6okgsnr	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.277	2026-04-02 16:32:24.277	cmnfkpf0u00zohgt40qewt2f3
cmnhp0jc202ffrkt4eng0f45a	cmnhp0jbt02ferkt4hslzgn7e	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.29	2026-04-02 16:32:24.29	cmnfkskbx0102hgt4wp2stj9s
cmnhp0jcj02firkt4yfl6401n	cmnhp0jca02fhrkt49z2z3b94	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.307	2026-04-02 16:32:24.307	cmnfkvenc010chgt44uzjdcc6
cmnhp0jcs02fkrkt4jdp3pt5v	cmnhp0jcm02fjrkt4kumu82n6	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.316	2026-04-02 16:32:24.316	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jd302fmrkt4wff263oy	cmnhp0jcw02flrkt4yulwlkwf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.327	2026-04-02 16:32:24.327	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0jdb02forkt4a8qjmbdl	cmnhp0jd602fnrkt4q59khw86	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.335	2026-04-02 16:32:24.335	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0jdk02fqrkt4mx9d6t20	cmnhp0jdd02fprkt4nrrviies	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.344	2026-04-02 16:32:24.344	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jdv02fsrkt4jbabhyxz	cmnhp0jdo02frrkt4rwf1f7eg	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.355	2026-04-02 16:32:24.355	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0jeb02fvrkt44idydiiz	cmnhp0je202furkt4i3ou6qqa	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.371	2026-04-02 16:32:24.371	cmnfksd8d0101hgt4l62jg4a7
cmnhp0jep02fxrkt40unhmfdh	cmnhp0jeg02fwrkt4p3b1eiyw	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.385	2026-04-02 16:32:24.385	cmnfksd8d0101hgt4l62jg4a7
cmnhp0jf202fzrkt4a7pezr51	cmnhp0jeu02fyrkt4pexao02e	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.398	2026-04-02 16:32:24.398	cmnfksd8d0101hgt4l62jg4a7
cmnhp0jfy02g3rkt48ouayagp	cmnhp0jfl02g2rkt4f66xqqo4	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.43	2026-04-02 16:32:24.43	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0jgc02g5rkt443heobii	cmnhp0jg302g4rkt4xydwb7tz	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.444	2026-04-02 16:32:24.444	cmnfkvenc010chgt44uzjdcc6
cmnhp0jgn02g7rkt4wa98sss9	cmnhp0jgg02g6rkt4cbpvnwyg	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.455	2026-04-02 16:32:24.455	cmnfkvenc010chgt44uzjdcc6
cmnhp0jh202garkt4j1xavra5	cmnhp0jgv02g9rkt4pd0anh8w	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.47	2026-04-02 16:32:24.47	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0jhf02gcrkt40h4q3ev3	cmnhp0jh602gbrkt4sdrf2hzr	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.483	2026-04-02 16:32:24.483	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jhp02gerkt4a29izs4k	cmnhp0jhj02gdrkt4egfjiu4n	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.493	2026-04-02 16:32:24.493	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0ji302ggrkt4bchtoslm	cmnhp0jhu02gfrkt4a3xywkgl	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.507	2026-04-02 16:32:24.507	cmnfkvenc010chgt44uzjdcc6
cmnhp0jid02girkt45d0loxqa	cmnhp0ji602ghrkt427kok8d3	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.517	2026-04-02 16:32:24.517	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0jiz02glrkt4nhkr95bp	cmnhp0jio02gkrkt4yrspacbr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.539	2026-04-02 16:32:24.539	cmnfkvenc010chgt44uzjdcc6
cmnhp0jjm02gorkt4oyk5t5fc	cmnhp0jjb02gnrkt4tal84o8g	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.562	2026-04-02 16:32:24.562	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jk102gqrkt4s7mce90b	cmnhp0jjq02gprkt4d4cmov6p	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.577	2026-04-02 16:32:24.577	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jke02gsrkt45542lwzs	cmnhp0jk502grrkt4e61o9l4o	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.59	2026-04-02 16:32:24.59	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0jko02gurkt4fjxl03tx	cmnhp0jki02gtrkt4ln1x4auq	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.6	2026-04-02 16:32:24.6	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0jll02h0rkt4kjcz96y3	cmnhp0jlc02gzrkt466lrpie1	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.633	2026-04-02 16:32:24.633	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0jmc02h2rkt4cj7n4h5w	cmnhp0jlp02h1rkt46kmgrxdf	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.66	2026-04-02 16:32:24.66	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0jmw02h5rkt4peigor1p	cmnhp0jmn02h4rkt46f92cs9u	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.68	2026-04-02 16:32:24.68	cmnfkvenc010chgt44uzjdcc6
cmnhp0jna02h7rkt4v2qzuip7	cmnhp0jn002h6rkt4cqj5ktk4	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.694	2026-04-02 16:32:24.694	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jnm02h9rkt48o66x47k	cmnhp0jne02h8rkt40jpfw5to	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.706	2026-04-02 16:32:24.706	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jo502hcrkt480lotfw1	cmnhp0jnv02hbrkt4q8qazilp	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.725	2026-04-02 16:32:24.725	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0jom02hfrkt46a36d4y0	cmnhp0joe02herkt4y3mae9md	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.742	2026-04-02 16:32:24.742	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0joz02hhrkt4zwbom5lj	cmnhp0joq02hgrkt4bvt5imy0	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.755	2026-04-02 16:32:24.755	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0jpm02hlrkt4sl7175uf	cmnhp0jpd02hkrkt4l0orgkpt	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.778	2026-04-02 16:32:24.778	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jpw02hnrkt4zikahqi3	cmnhp0jpq02hmrkt4kc88ku51	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.788	2026-04-02 16:32:24.788	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0jqf02hqrkt47o2xhill	cmnhp0jq702hprkt45yhj5j7i	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.807	2026-04-02 16:32:24.807	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jqq02hsrkt45m67yx34	cmnhp0jqi02hrrkt443vu88fb	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.818	2026-04-02 16:32:24.818	cmnfkvenc010chgt44uzjdcc6
cmnhp0jra02hvrkt4inqz4ypd	cmnhp0jr102hurkt413ajndqc	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.838	2026-04-02 16:32:24.838	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jrs02hyrkt479goml5w	cmnhp0jrj02hxrkt44tniqa1r	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.856	2026-04-02 16:32:24.856	cmnfkvkyn010dhgt4qymxazu8
cmnhp0js702i0rkt4p5cq7lu4	cmnhp0jrx02hzrkt48q9dvh8q	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.871	2026-04-02 16:32:24.871	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jss02i3rkt46xxj7vjj	cmnhp0jsi02i2rkt4gbj1y5lt	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.892	2026-04-02 16:32:24.892	cmnfkvenc010chgt44uzjdcc6
cmnhp0jt002i5rkt4ys5xljng	cmnhp0jsv02i4rkt43q1u7ys3	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.9	2026-04-02 16:32:24.9	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jtc02i7rkt4whc1lpk3	cmnhp0jt402i6rkt40w5k2tgk	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.912	2026-04-02 16:32:24.912	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0jtk02i9rkt4fkjo3829	cmnhp0jtf02i8rkt4i2ivlzgb	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.92	2026-04-02 16:32:24.92	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0jtz02icrkt4svc0apoc	cmnhp0jtt02ibrkt419o2la49	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.935	2026-04-02 16:32:24.935	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0jum02ihrkt4bdxgm75d	cmnhp0jud02igrkt4zzhd0rwp	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.958	2026-04-02 16:32:24.958	cmnfkvenc010chgt44uzjdcc6
cmnhp0jv802ilrkt43lu6611k	cmnhp0juy02ikrkt4b8r2ay5m	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.98	2026-04-02 16:32:24.98	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jvn02inrkt4gnynvwkp	cmnhp0jvb02imrkt4mkpl0bwb	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:24.996	2026-04-02 16:32:24.996	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0jwe02iqrkt4eb8assjo	cmnhp0jw002iprkt4a7kv7lsg	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.022	2026-04-02 16:32:25.022	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0jwv02isrkt4cse3p5kb	cmnhp0jwj02irrkt459f8nq1b	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.039	2026-04-02 16:32:25.039	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jxa02iurkt4z62ehvw4	cmnhp0jwz02itrkt40q5te9u4	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.054	2026-04-02 16:32:25.054	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhp0jxr02iyrkt4hfo7xlw0	cmnhp0jxl02ixrkt40c9b5m33	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.071	2026-04-02 16:32:25.071	cmnfkvkyn010dhgt4qymxazu8
cmnhp0jy202j0rkt4z8urenq5	cmnhp0jxw02izrkt45h1m9jtv	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.082	2026-04-02 16:32:25.082	cmnfkr6pe00zwhgt4j7vbb5vx
cmnhp0jyc02j2rkt4kehn5ymm	cmnhp0jy502j1rkt4fnfnv076	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.092	2026-04-02 16:32:25.092	cmnfkr0x200zvhgt4bdrsp2u0
cmnhp0jyo02j4rkt4g6hart3t	cmnhp0jyg02j3rkt4v0jgspoq	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.104	2026-04-02 16:32:25.104	cmnfkqspm00zuhgt4hu2eqk4l
cmnhp0jzc02j9rkt49bspihdc	cmnhp0jz702j8rkt4y7goq8bu	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.128	2026-04-02 16:32:25.128	cmnfkvenc010chgt44uzjdcc6
cmnhp0jzr02jbrkt4e3bkpcw1	cmnhp0jzh02jarkt43puqk4fu	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 16:32:25.144	2026-04-02 16:32:25.144	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhq9rfw02jcrkt4003752ck	cmnhp0j3902dzrkt426gglck8	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:07:34.316	2026-04-02 17:07:34.316	cmnfkrvw300zyhgt403qbk0s6
cmnhq9ri702jfrkt4zmjmmya0	cmnhp0eqd028arkt4idu33kmx	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.399	2026-04-02 17:07:34.399	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rib02jgrkt4u4cyp615	cmnhp0jup02iirkt4leb2lzlq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.403	2026-04-02 17:07:34.403	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rie02jhrkt4ehz8xml4	cmnhp0ec1026arkt4j2q6e8kx	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.406	2026-04-02 17:07:34.406	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rik02jirkt49q5lm2o7	cmnhp0j7q02eprkt43v733d0n	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.412	2026-04-02 17:07:34.412	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rio02jjrkt42m94mcuw	cmnhp0dme024jrkt4otpxjj01	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.417	2026-04-02 17:07:34.417	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rit02jkrkt4w5nx20dm	cmnhp098i0228rkt4nbbg9gii	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.421	2026-04-02 17:07:34.421	cmnfkrvw300zyhgt403qbk0s6
cmnhq9riw02jlrkt43aknwcye	cmnhp09a7022drkt4w9gp6uc6	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.424	2026-04-02 17:07:34.424	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rj002jmrkt4wgc7fon4	cmnhp0jsc02i1rkt40zb0d18w	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.428	2026-04-02 17:07:34.428	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rj402jnrkt46uxjf22k	cmnhp0jkq02gvrkt4yk3rydz8	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.432	2026-04-02 17:07:34.432	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rj802jorkt4c2igz7wp	cmnhp0jz402j7rkt4xpeh8rlu	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.436	2026-04-02 17:07:34.436	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rjc02jprkt48v4bop6e	cmnhp0efi026rrkt4vhnun3iw	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.44	2026-04-02 17:07:34.44	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rjf02jqrkt4cmpehcu6	cmnhp0dn0024lrkt4xux5yn9e	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.443	2026-04-02 17:07:34.443	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rji02jrrkt488lurtxd	cmnhp0dix0244rkt4p9l3hpmz	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.446	2026-04-02 17:07:34.446	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rjm02jsrkt4snmytoda	cmnhp08k101zyrkt4hhb2f37j	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.45	2026-04-02 17:07:34.45	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rjp02jtrkt43tdzrmr4	cmnhp0j3d02e0rkt4b2amvjf7	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.453	2026-04-02 17:07:34.453	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rjs02jurkt42dq59dnp	cmnhp0eim0274rkt4x5xw4wgl	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.456	2026-04-02 17:07:34.456	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rjv02jvrkt4fgcvjvsk	cmnhp0ejt027brkt4hi5s94sq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.459	2026-04-02 17:07:34.459	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rjz02jwrkt4duq2qihb	cmnhp0e320253rkt4e1o3gkq9	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.463	2026-04-02 17:07:34.463	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rk302jxrkt4gsoom18y	cmnhp0jp802hjrkt4swu99kqz	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.467	2026-04-02 17:07:34.467	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rk602jyrkt4l5byzi16	cmnhp08v3021arkt40wf6q6dv	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.47	2026-04-02 17:07:34.47	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rka02jzrkt49wvd3jfg	cmnhp08md020brkt4gn95oj07	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.474	2026-04-02 17:07:34.474	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rkf02k0rkt43u3psdug	cmnhp0ep30285rkt4imruh9zu	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.479	2026-04-02 17:07:34.479	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rki02k1rkt4dtwvcu1h	cmnhp0jnq02harkt4bryw07ro	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.482	2026-04-02 17:07:34.482	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rkl02k2rkt4puh8aozv	cmnhp099y022crkt41vdkjx2a	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.485	2026-04-02 17:07:34.485	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rkp02k3rkt4i4rkey84	cmnhp08s1020yrkt49p6frpz1	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.489	2026-04-02 17:07:34.489	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rks02k4rkt4c1xroq0m	cmnhp0jgr02g8rkt4ztedubkr	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.493	2026-04-02 17:07:34.493	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rkw02k5rkt4ubr2x9gx	cmnhp0e8d025rrkt4dmaz4ekc	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.496	2026-04-02 17:07:34.496	cmnfkrvw300zyhgt403qbk0s6
cmnhq9rkz02k6rkt41sjqd7ge	cmnhp0j3102dyrkt4cs40q0f5	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:34.499	2026-04-02 17:07:34.499	cmnfkrvw300zyhgt403qbk0s6
cmnhqa2s002k7rkt4jkayqqrh	cmnhp0jc602fgrkt4ytqsug7c	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:07:49.008	2026-04-02 17:07:49.008	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2sx02karkt4zm2q43eb	cmnhp0ju902ifrkt4zbff73dj	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.041	2026-04-02 17:07:49.041	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2t302kbrkt4waou99mk	cmnhp0egk026urkt4c71cgzui	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.047	2026-04-02 17:07:49.047	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2t802kcrkt4l0dzl10u	cmnhp0dmn024krkt46ftj2o9a	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.053	2026-04-02 17:07:49.053	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2te02kdrkt4rz34jo59	cmnhp0jxd02ivrkt4p465adw1	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.058	2026-04-02 17:07:49.058	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2tk02kerkt4gctrk63m	cmnhp0jqw02htrkt4h4b9oni1	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.064	2026-04-02 17:07:49.064	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2tq02kfrkt47gjs33om	cmnhp0jo802hdrkt4yeljdmdh	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.07	2026-04-02 17:07:49.07	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2tv02kgrkt44lt98a6m	cmnhp0eau0264rkt4puni1zor	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.075	2026-04-02 17:07:49.075	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2u202khrkt40rgtkmp7	cmnhp0jf602g0rkt4nhtxqzms	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.082	2026-04-02 17:07:49.082	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2u702kirkt43jzi5ofd	cmnhp0jkx02gwrkt4jlew0ge3	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.087	2026-04-02 17:07:49.087	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2uc02kjrkt4gikpsj0f	cmnhp0jxh02iwrkt4blkcgrvw	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.092	2026-04-02 17:07:49.092	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2ui02kkrkt4zhj1iiq6	cmnhp0e2u0252rkt4pexbbal7	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.098	2026-04-02 17:07:49.098	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2um02klrkt4wskzf6ns	cmnhp08us0218rkt455uf7dcd	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.103	2026-04-02 17:07:49.103	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2us02kmrkt49cu9wzv9	cmnhp0eq30289rkt48tixc1pj	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.108	2026-04-02 17:07:49.108	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2ux02knrkt4w418x86e	cmnhp0e2n0251rkt45e2u10ti	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.113	2026-04-02 17:07:49.113	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2v302korkt4dgwsy7vq	cmnhp0ejm027arkt4xupn0bml	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.119	2026-04-02 17:07:49.119	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2vb02kprkt4j601jm1i	cmnhp0ju502ierkt45sysf8ql	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.127	2026-04-02 17:07:49.127	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2vg02kqrkt49toubs51	cmnhp0ect026erkt4fhpi5clb	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.132	2026-04-02 17:07:49.132	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2vp02krrkt4vvtm4qlx	cmnhp0e2f0250rkt4418lykgq	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.141	2026-04-02 17:07:49.141	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2vu02ksrkt4qypfppyj	cmnhp0dj50245rkt45s8howpa	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.146	2026-04-02 17:07:49.146	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2vy02ktrkt4rbrs2v4r	cmnhp0ju102idrkt46p4j2gw9	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.15	2026-04-02 17:07:49.15	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2w402kurkt40ch17kli	cmnhp0jl202gxrkt4hsizyyam	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.156	2026-04-02 17:07:49.156	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2wa02kvrkt45i1if4qr	cmnhp08zd021orkt410dp6unx	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.162	2026-04-02 17:07:49.162	cmnfkqexq00zthgt4g4n1fbfy
cmnhqa2wf02kwrkt4ca8u4zmo	cmnhp08tn0215rkt46p761o3v	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:07:49.167	2026-04-02 17:07:49.167	cmnfkqexq00zthgt4g4n1fbfy
cmnhqazsr02kxrkt4wtebgbsz	cmnhp0jff02g1rkt4nmy2y6cm	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:08:31.803	2026-04-02 17:08:31.803	cmnfkv17r010ahgt4x5dtkz2a
cmnhqaztn02l0rkt4sakqidtn	cmnhp08uw0219rkt4ga8tgnpv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.835	2026-04-02 17:08:31.835	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazts02l1rkt4bo8efo11	cmnhp0jvt02iorkt48oxmve99	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.84	2026-04-02 17:08:31.84	cmnfkv17r010ahgt4x5dtkz2a
cmnhqaztw02l2rkt4mm6bi0kv	cmnhp0eid0273rkt4e8l6yjqa	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.844	2026-04-02 17:08:31.844	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazu102l3rkt49c9llcgh	cmnhp0di20240rkt43e0rs0iu	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.849	2026-04-02 17:08:31.849	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazu602l4rkt4rebr1c96	cmnhp0doq024rrkt48rh2hcjy	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.854	2026-04-02 17:08:31.854	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazuc02l5rkt42e75l5yq	cmnhp0jl702gyrkt4xgyb331s	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.86	2026-04-02 17:08:31.86	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazuh02l6rkt43hw8gkil	cmnhp09et022vrkt4b0mbhqyk	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.865	2026-04-02 17:08:31.865	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazun02l7rkt4j5w4dx0l	cmnhp0ero028grkt4oqcd298d	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.871	2026-04-02 17:08:31.871	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazut02l8rkt4y9w3o9li	cmnhp03vo01z1rkt4ujrgpt5d	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.877	2026-04-02 17:08:31.877	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazuy02l9rkt4fri11vu5	cmnhp09c3022krkt4cdxcf9b8	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.882	2026-04-02 17:08:31.882	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazv302larkt4fskvs6wa	cmnhp098x0229rkt4xufag9vv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.887	2026-04-02 17:08:31.887	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazv902lbrkt4xxbdbqfy	cmnhp08ml020crkt4szq8v8b8	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.893	2026-04-02 17:08:31.893	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazvd02lcrkt4jpj9hnho	cmnhp09dp022qrkt42ngvjd5g	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.897	2026-04-02 17:08:31.897	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazvj02ldrkt4belmsc5q	cmnhp08m3020arkt4v3r3y1ie	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.903	2026-04-02 17:08:31.903	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazvr02lerkt4ui8t8bbp	cmnhp0e84025qrkt4ob72rhty	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.911	2026-04-02 17:08:31.911	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazvv02lfrkt4vqhx0wsd	cmnhp0e4r025brkt41hq9txq2	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.915	2026-04-02 17:08:31.915	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazvz02lgrkt4o00q2egx	cmnhp0ede026hrkt4jatn4oy6	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.919	2026-04-02 17:08:31.919	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazw602lhrkt4f2nqlohz	cmnhp0jys02j5rkt4o2wo2js2	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.926	2026-04-02 17:08:31.926	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazwd02lirkt4o3iegrsv	cmnhp09if023brkt40mx4acab	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.933	2026-04-02 17:08:31.933	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazwj02ljrkt4h1z4xmgz	cmnhp0ek9027erkt4tt9t40tc	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.939	2026-04-02 17:08:31.939	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazwq02lkrkt4sz7abzc8	cmnhp0ecl026drkt4azizow59	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.946	2026-04-02 17:08:31.946	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazww02llrkt4t219vrub	cmnhp0dkm024crkt4c5xx1uzu	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.952	2026-04-02 17:08:31.952	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazx202lmrkt4pp92ptjt	cmnhp0jre02hwrkt45o321qxd	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.958	2026-04-02 17:08:31.958	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazx802lnrkt45ecep76r	cmnhp09lb023krkt401yuzw34	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.964	2026-04-02 17:08:31.964	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazxd02lorkt4rz3s3k3j	cmnhp0eok0283rkt4afrthzox	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.969	2026-04-02 17:08:31.969	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazxi02lprkt4xicgk9rb	cmnhp03uo01yvrkt4vlcakiea	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.975	2026-04-02 17:08:31.975	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazxq02lqrkt4qm01wy7p	cmnhp09hh0237rkt4xh5q77cj	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.982	2026-04-02 17:08:31.982	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazxw02lrrkt4tgomh8c4	cmnhp09g90232rkt4rqjgr01c	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.988	2026-04-02 17:08:31.988	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazy102lsrkt4n67ewxnu	cmnhp03w901z4rkt4mqt262ig	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.993	2026-04-02 17:08:31.993	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazy702ltrkt4tocmc4xd	cmnhp09fu0230rkt43uf0r1u2	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:31.999	2026-04-02 17:08:31.999	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazyc02lurkt44up04pev	cmnhp08sv0211rkt4xugvgavd	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:32.004	2026-04-02 17:08:32.004	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazyh02lvrkt49d0tnmqi	cmnhp09ho0238rkt45t7ppxyu	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:32.009	2026-04-02 17:08:32.009	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazym02lwrkt4qksd4b2j	cmnhp09kj023grkt4sffig18n	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:32.014	2026-04-02 17:08:32.014	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazyt02lxrkt42ddamhgl	cmnhp0jj302gmrkt4ovnynyw0	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:32.021	2026-04-02 17:08:32.021	cmnfkv17r010ahgt4x5dtkz2a
cmnhqazyz02lyrkt4tuziwm5n	cmnhp0jp202hirkt465ilkedv	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:08:32.027	2026-04-02 17:08:32.027	cmnfkv17r010ahgt4x5dtkz2a
cmnhr9tln02m0rkt40advloko	cmnhp0ebt0269rkt4gm1atrf2	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:35:36.732	2026-04-02 17:35:36.732	cmnfks14q00zzhgt47kj8x90e
cmnhr9tmi02m3rkt4b4jp9r36	cmnhp08kd0200rkt4mbbo89fp	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.762	2026-04-02 17:35:36.762	cmnfks14q00zzhgt47kj8x90e
cmnhr9tmm02m4rkt43t77t28r	cmnhp08pa020prkt4szsmoicy	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.766	2026-04-02 17:35:36.766	cmnfks14q00zzhgt47kj8x90e
cmnhr9tmr02m5rkt4u19jsp8o	cmnhp08pf020qrkt4pm73kn3a	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.771	2026-04-02 17:35:36.771	cmnfks14q00zzhgt47kj8x90e
cmnhr9tmw02m6rkt46zc2w8ao	cmnhp08vb021brkt4yo968kt9	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.776	2026-04-02 17:35:36.776	cmnfks14q00zzhgt47kj8x90e
cmnhr9tn002m7rkt439diwtd7	cmnhp09ae022erkt4u35zcnk0	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.78	2026-04-02 17:35:36.78	cmnfks14q00zzhgt47kj8x90e
cmnhr9tn502m8rkt4zo6h1xxa	cmnhp09ap022frkt4g5gq5pu1	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.785	2026-04-02 17:35:36.785	cmnfks14q00zzhgt47kj8x90e
cmnhr9tn902m9rkt4w1nigu18	cmnhp0eez026qrkt4nze6xzvn	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.789	2026-04-02 17:35:36.789	cmnfks14q00zzhgt47kj8x90e
cmnhr9tnc02markt4hrt1qtlc	cmnhp0ejh0279rkt49swu611p	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.792	2026-04-02 17:35:36.792	cmnfks14q00zzhgt47kj8x90e
cmnhr9tng02mbrkt4ftg1zv34	cmnhp0em5027prkt47j4zk2zq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.796	2026-04-02 17:35:36.796	cmnfks14q00zzhgt47kj8x90e
cmnhr9tnj02mcrkt464f8pire	cmnhp0epg0286rkt4oc0kmjnl	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.799	2026-04-02 17:35:36.799	cmnfks14q00zzhgt47kj8x90e
cmnhr9tnn02mdrkt446mpvfn8	cmnhp0et8028orkt4argta3j7	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:36.803	2026-04-02 17:35:36.803	cmnfks14q00zzhgt47kj8x90e
cmnhra9jk02merkt44imo45a7	cmnhp0edj026irkt4kyqy6itj	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:35:57.392	2026-04-02 17:35:57.392	cmnfkskbx0102hgt4wp2stj9s
cmnhra9kb02mhrkt4sf59ktxh	cmnhp08k701zzrkt4d0dnkl9n	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.419	2026-04-02 17:35:57.419	cmnfkskbx0102hgt4wp2stj9s
cmnhra9kh02mirkt4mfzjmwsy	cmnhp08np020hrkt4nxu14cco	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.425	2026-04-02 17:35:57.425	cmnfkskbx0102hgt4wp2stj9s
cmnhra9kl02mjrkt4y85568w4	cmnhp08t40212rkt4p4erdchw	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.429	2026-04-02 17:35:57.429	cmnfkskbx0102hgt4wp2stj9s
cmnhra9kp02mkrkt4d6wscmpz	cmnhp08x9021jrkt4i6okazzj	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.433	2026-04-02 17:35:57.433	cmnfkskbx0102hgt4wp2stj9s
cmnhra9kt02mlrkt438pre7go	cmnhp09890227rkt4wfpvnyb2	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.437	2026-04-02 17:35:57.437	cmnfkskbx0102hgt4wp2stj9s
cmnhra9kx02mmrkt4kcs9lx50	cmnhp09bu022jrkt4mve5iy1p	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.441	2026-04-02 17:35:57.441	cmnfkskbx0102hgt4wp2stj9s
cmnhra9l102mnrkt4duk7f0sr	cmnhp09ct022nrkt47wy3hzpp	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.445	2026-04-02 17:35:57.445	cmnfkskbx0102hgt4wp2stj9s
cmnhra9l502morkt43cqol5at	cmnhp0ejc0278rkt44dsns9hu	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.449	2026-04-02 17:35:57.449	cmnfkskbx0102hgt4wp2stj9s
cmnhra9l902mprkt4fncnoy9c	cmnhp0eke027frkt4gl6je1sn	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.453	2026-04-02 17:35:57.453	cmnfkskbx0102hgt4wp2stj9s
cmnhra9ld02mqrkt4x5iwkveo	cmnhp0eos0284rkt4b4e3g7tb	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.457	2026-04-02 17:35:57.457	cmnfkskbx0102hgt4wp2stj9s
cmnhra9li02mrrkt47gwamx2k	cmnhp0erv028hrkt4be4au4sa	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:35:57.462	2026-04-02 17:35:57.462	cmnfkskbx0102hgt4wp2stj9s
cmnhranhq02msrkt4dxd9mq2j	cmnhp0eiu0275rkt45r8l0m09	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:36:15.47	2026-04-02 17:36:15.47	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranir02mvrkt4tza8cwfn	cmnhp08l70205rkt4cpu2hi4g	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.507	2026-04-02 17:36:15.507	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranix02mwrkt4m2v5snbj	cmnhp08o8020krkt4aa6tolci	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.513	2026-04-02 17:36:15.513	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranj102mxrkt42hnakvb3	cmnhp08pw020rrkt48nxftdaq	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.517	2026-04-02 17:36:15.517	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranj702myrkt4ioyyzu8l	cmnhp08vn021crkt47psomgzy	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.523	2026-04-02 17:36:15.523	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranjc02mzrkt4a6hg4f7p	cmnhp091e021vrkt4ae7rksje	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.528	2026-04-02 17:36:15.528	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranjh02n0rkt4wzd784mb	cmnhp091n021wrkt40vpolk0j	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.533	2026-04-02 17:36:15.533	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranjm02n1rkt41ss18skq	cmnhp0edq026jrkt4s9vfwh0c	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.538	2026-04-02 17:36:15.538	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranjr02n2rkt43atdz54v	cmnhp0ekj027grkt4yy37wzay	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.544	2026-04-02 17:36:15.544	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhranjw02n3rkt46anzz9aq	cmnhp0emv027urkt4f9jsmb6v	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.548	2026-04-02 17:36:15.548	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhrank202n4rkt4z0pklh29	cmnhp0eqk028brkt4po0lswpn	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:36:15.554	2026-04-02 17:36:15.554	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhrd2qb02n5rkt4zzhve7zd	cmnhp0jdy02ftrkt4513zt6h7	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 17:38:08.531	2026-04-02 17:38:08.531	cmnfkvrla010ehgt4pntoyk13
cmnhrd2r902n8rkt4ntzrpvi8	cmnhp0dh3023vrkt4bxp2m5he	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.565	2026-04-02 17:38:08.565	cmnfkvrla010ehgt4pntoyk13
cmnhrd2rh02n9rkt47gict1pd	cmnhp0diq0243rkt4lxijx7nk	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.573	2026-04-02 17:38:08.573	cmnfkvrla010ehgt4pntoyk13
cmnhrd2rm02narkt47zxppnxp	cmnhp0dn8024mrkt4floy7k3m	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.578	2026-04-02 17:38:08.578	cmnfkvrla010ehgt4pntoyk13
cmnhrd2rr02nbrkt49kern4pp	cmnhp0e390254rkt4l0gju368	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.583	2026-04-02 17:38:08.583	cmnfkvrla010ehgt4pntoyk13
cmnhrd2rw02ncrkt4v266vmmt	cmnhp0e64025irkt41t25yc2x	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.588	2026-04-02 17:38:08.588	cmnfkvrla010ehgt4pntoyk13
cmnhrd2s202ndrkt44l2ti8p1	cmnhp0e6d025jrkt4q4tyyo10	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.594	2026-04-02 17:38:08.594	cmnfkvrla010ehgt4pntoyk13
cmnhrd2s702nerkt44jdfy4pu	cmnhp0jii02gjrkt479rw92pu	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.599	2026-04-02 17:38:08.599	cmnfkvrla010ehgt4pntoyk13
cmnhrd2sb02nfrkt4xyvf57b6	cmnhp0jmg02h3rkt4solwtkhy	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.603	2026-04-02 17:38:08.603	cmnfkvrla010ehgt4pntoyk13
cmnhrd2sg02ngrkt4wzbk7ajs	cmnhp0jq002horkt4ve112r8v	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.608	2026-04-02 17:38:08.608	cmnfkvrla010ehgt4pntoyk13
cmnhrd2sn02nhrkt46yk4hq1u	cmnhp0jto02iarkt4wre5up31	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.615	2026-04-02 17:38:08.615	cmnfkvrla010ehgt4pntoyk13
cmnhrd2sr02nirkt4dmi3srfw	cmnhp0jut02ijrkt4xqsh7acf	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.619	2026-04-02 17:38:08.619	cmnfkvrla010ehgt4pntoyk13
cmnhrd2sv02njrkt42htzbr51	cmnhp0jyz02j6rkt43jcqafe5	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 17:38:08.623	2026-04-02 17:38:08.623	cmnfkvrla010ehgt4pntoyk13
cmnhtjh0n00006st43y2mdaf4	cmnhp09dc022prkt4vfahbyyb	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:39:06.216	2026-04-02 18:39:06.216	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh3600036st4z7qya1eo	cmnhp03ui01yurkt4nnzk4pup	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.306	2026-04-02 18:39:06.306	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh3d00046st4feaa9j9q	cmnhp03vu01z2rkt4qjokz37r	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.313	2026-04-02 18:39:06.313	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh3h00056st4dqt4ss5y	cmnhp03x001z8rkt4rx3c23wb	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.317	2026-04-02 18:39:06.317	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh3l00066st4t0vzi7uk	cmnhp03xb01z9rkt4qtzwrf57	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.321	2026-04-02 18:39:06.321	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh4000076st48yo1srps	cmnhp03xm01zarkt4ufq65bzo	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.336	2026-04-02 18:39:06.336	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh4f00086st41jodg0px	cmnhp09dx022rrkt4tdtavw5s	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.351	2026-04-02 18:39:06.351	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh4k00096st4xxsi56en	cmnhp09g20231rkt4fscm791r	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.356	2026-04-02 18:39:06.356	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh4q000a6st4blzw4x64	cmnhp09gx0235rkt4rp3tuol6	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.362	2026-04-02 18:39:06.362	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh4t000b6st4f3elhrs1	cmnhp09ir023crkt4dnvrurzr	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.365	2026-04-02 18:39:06.365	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh4x000c6st4ka3h3djl	cmnhp09kq023hrkt4dxin1aol	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.369	2026-04-02 18:39:06.369	cmnfkvkyn010dhgt4qymxazu8
cmnhtjh50000d6st45ez0qh02	cmnhp09l4023jrkt4d7l9x2qt	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:06.372	2026-04-02 18:39:06.372	cmnfkvkyn010dhgt4qymxazu8
cmnhtjtz8000e6st47l2cwi01	cmnhp09h60236rkt4ks6hpp63	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:39:23.012	2026-04-02 18:39:23.012	cmnfksd8d0101hgt4l62jg4a7
cmnhtju05000h6st4196y394l	cmnhp03uv01ywrkt4ancsv4h4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:23.045	2026-04-02 18:39:23.045	cmnfksd8d0101hgt4l62jg4a7
cmnhtju0b000i6st4c32hhwua	cmnhp03w301z3rkt4u8hfo189	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:23.051	2026-04-02 18:39:23.051	cmnfksd8d0101hgt4l62jg4a7
cmnhtju0h000j6st47utgaimi	cmnhp09kb023frkt4l73k5gze	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:23.057	2026-04-02 18:39:23.057	cmnfksd8d0101hgt4l62jg4a7
cmnhtju0l000k6st4rhg025at	cmnhp09kw023irkt4vk2u2pa2	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:23.062	2026-04-02 18:39:23.062	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5mx000l6st4hrwnvrf9	cmnhp03ud01ytrkt4amoqvl6t	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:39:38.121	2026-04-02 18:39:38.121	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5nq000o6st4919tmk0j	cmnhp03v701yyrkt4afkiacqk	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.15	2026-04-02 18:39:38.15	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5nv000p6st454a292te	cmnhp03wt01z7rkt4803l0a33	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.155	2026-04-02 18:39:38.155	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5o0000q6st4v75zimz6	cmnhp03ye01zfrkt4ctk74zum	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.16	2026-04-02 18:39:38.16	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5o6000r6st4ztkb9zcm	cmnhp03ym01zhrkt48g4tir48	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.166	2026-04-02 18:39:38.166	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5ob000s6st4529wnsg4	cmnhp03yv01zjrkt4jq3v6hgh	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.171	2026-04-02 18:39:38.171	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5og000t6st4e0qzj4t9	cmnhp03z201zkrkt4dbfj1ru3	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.176	2026-04-02 18:39:38.176	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5ok000u6st4i2r1x2am	cmnhp03zi01znrkt4yi0uh4f4	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.18	2026-04-02 18:39:38.18	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5oo000v6st4jsqxagzy	cmnhp03zq01zorkt4ssnhq8tq	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.184	2026-04-02 18:39:38.184	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5ot000w6st4nsyx104b	cmnhp040j01zsrkt49d67pf2j	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.189	2026-04-02 18:39:38.189	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5oy000x6st40tf97ns0	cmnhp041201zurkt4v3y6z5qk	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:38.194	2026-04-02 18:39:38.194	cmnfksd8d0101hgt4l62jg4a7
cmnhtkhkk000y6st4zg3gh9s0	cmnhp03v101yxrkt4m4vo7pp5	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:39:53.588	2026-04-02 18:39:53.588	cmnfks14q00zzhgt47kj8x90e
cmnhtkhl900116st4jln77y64	cmnhp03y001zcrkt43drrdtca	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:39:53.613	2026-04-02 18:39:53.613	cmnfks14q00zzhgt47kj8x90e
cmnhtkt0600126st4ibvu9fbg	cmnhp03xu01zbrkt4deihuxtz	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:40:08.406	2026-04-02 18:40:08.406	cmnfkv8t7010bhgt4yrqs8e67
cmnhtl36o00156st4g93q6wt5	cmnhp03y801zerkt4975r5xil	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:40:21.6	2026-04-02 18:40:21.6	cmnfksd8d0101hgt4l62jg4a7
cmnhtl37g00186st46gma3g0n	cmnhp03yj01zgrkt49tzm7tlg	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:40:21.628	2026-04-02 18:40:21.628	cmnfksd8d0101hgt4l62jg4a7
cmnhtl37m00196st4otiz6jyr	cmnhp03yq01zirkt4s1ppvrxn	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:40:21.634	2026-04-02 18:40:21.634	cmnfksd8d0101hgt4l62jg4a7
cmnhtl37r001a6st4q59v8ylf	cmnhp03z901zlrkt48wi556yd	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:40:21.639	2026-04-02 18:40:21.639	cmnfksd8d0101hgt4l62jg4a7
cmnhtl37v001b6st435u0qzal	cmnhp03ze01zmrkt404vl8orf	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:40:21.643	2026-04-02 18:40:21.643	cmnfksd8d0101hgt4l62jg4a7
cmnhtl380001c6st456132nmm	cmnhp03zw01zprkt49hahw08k	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:40:21.648	2026-04-02 18:40:21.648	cmnfksd8d0101hgt4l62jg4a7
cmnhtl386001d6st4pef30uxy	cmnhp040b01zrrkt4p08itfsp	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:40:21.654	2026-04-02 18:40:21.654	cmnfksd8d0101hgt4l62jg4a7
cmnhtl38b001e6st4wl6ef5dy	cmnhp041901zvrkt421ikm8xw	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	AUTOMATICA	t	2026-04-02 18:40:21.659	2026-04-02 18:40:21.659	cmnfksd8d0101hgt4l62jg4a7
cmnhtluki001f6st4vohjhz1f	cmnhp040301zqrkt4xic3fr96	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:40:57.09	2026-04-02 18:40:57.09	cmnfks14q00zzhgt47kj8x90e
cmnhtn41g001i6st46ookfa8c	cmnhp041f01zwrkt406ynv766	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:41:56.021	2026-04-02 18:41:56.021	cmnfks7y90100hgt4htds26dj
cmnhtn432001j6st4i2mg4919	cmnhozzsb01yorkt4kiw5vbsd	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:41:56.078	2026-04-02 18:41:56.078	cmnfksd8d0101hgt4l62jg4a7
cmnhtn44g001k6st4kpeo3w8n	cmnhozzrv01ynrkt41owlg2od	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:41:56.128	2026-04-02 18:41:56.128	cmnfksd8d0101hgt4l62jg4a7
cmnhtn45r001l6st4qqom96ht	cmnhozzsl01yprkt4nmr4y4oi	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:41:56.175	2026-04-02 18:41:56.175	cmnfksd8d0101hgt4l62jg4a7
cmnhtopdg001m6st44rd1231c	cmnhp040t01ztrkt419yyde0j	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:43:10.324	2026-04-02 18:43:10.324	cmnfksd8d0101hgt4l62jg4a7
cmnhtzon7001n6st4r0vnii1u	cmnhp09d2022orkt4kt2oqfmy	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:51:42.595	2026-04-02 18:51:42.595	cmnfks14q00zzhgt47kj8x90e
cmnhtzopc001o6st4a1hpwork	cmnhp09el022urkt4a83q5ooy	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:51:42.672	2026-04-02 18:51:42.672	cmnfks14q00zzhgt47kj8x90e
cmnhtztqr001p6st42yr7zga0	cmnhp09b1022grkt4v88epgvj	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:51:49.203	2026-04-02 18:51:49.203	cmnfks14q00zzhgt47kj8x90e
cmnhtzts2001q6st4v4q30wk2	cmnhp03y401zdrkt4g59m19o2	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	MANUAL	t	2026-04-02 18:51:49.25	2026-04-02 18:51:49.25	cmnfksd8d0101hgt4l62jg4a7
cmnl5rjva001r6st4r8gmoo01	cmnfm20dq024jhgt44r4qfrtu	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	MANUAL	t	2026-04-05 02:44:37.078	2026-04-05 02:44:37.078	\N
cmnl5s42t001s6st4g4mn5cr9	cmnfm20er024nhgt42gakf4m0	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-05 02:45:03.269	2026-04-05 02:45:03.269	\N
cmnl5shog001t6st40xqg2nxs	cmnfm20da024hhgt4hiopbwrp	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	MANUAL	t	2026-04-05 02:45:20.896	2026-04-05 02:45:20.896	\N
\.


--
-- Data for Name: faturas; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.faturas (id, "hashFatura", "nifEmitente", "serieDoc", "numeroDoc", "nifDestinatario", "nomeEmitente", "dataFatura", "totalSemIva", "totalIva", "totalComIva", "tipoDocumento", "importacaoId", "criadoEm") FROM stdin;
cmnfm2055023lhgt4cfsoaqqp	0a403fdb457a56dec758f618680c4cad776344c3697c5223c7194a0939a2de8a	501293710	FT FA.2026	462	\N	Jocel Lda	2026-01-22 00:00:00	950.96	218.72	1169.68	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.529
cmnfm205k023mhgt47cpohteu	7f31f51793cb4cb2ba80926a4695ecae0a7480330098c2d873c82c1848ba7bd1	503000000	FACTC 155126	27	\N	A M Industria de Colchões Lda	2026-01-21 00:00:00	772.00	177.56	949.56	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.544
cmnfm205w023nhgt4xrjhh1bv	4b6ffde8ef7fe162adf21862dec78d8094ecb9a9e0efa51377babe54d2e22cf3	506848558	FT 20260085701	000508	\N	Bcm Bricolage S A	2026-01-19 00:00:00	559.24	128.63	687.87	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.556
cmnfm2067023ohgt40t5ydknl	4867cc3f38e91d3d1447f33711e7b8c373f6215ef5e1c500a6427ab7a36f712c	515373842	FT 11.1	307	\N	Milliwatt Lda	2026-01-14 00:00:00	510.00	117.30	627.30	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.567
cmnfm206h023phgt4m4p5nyjq	1ce84c9f3b2005d8def753d59b37223fcd9e3b17bdd74b86444c1f54959d6043	505993058	FT V201.04	26015892	\N	Robert Mauser, Lda	2026-02-03 00:00:00	242.27	55.72	297.99	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.577
cmnfm206s023qhgt4xunc1euw	03f0e1fa8f0536655d99e19e8d41dce3301340993f497b563decf40a4f8ca570	502201657	FR FRG.2026	32	\N	Centrocor Comercio Tintas e Ferramentas Lda	2026-01-08 00:00:00	233.11	53.62	286.73	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.588
cmnfm2072023rhgt4eefo9onk	6c4329ede4526f410cf041e0dd44445c49b765344823c4dedfcb00430e8613e6	509520561	FT M	3767	\N	Alfadvice-Serviços de Engenharia Unipessoal Lda	2026-02-25 00:00:00	200.00	46.00	246.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.598
cmnfm207a023shgt46x8ecftc	4cc5f921695ba395ab5da29689342624c6d403dcecf2eb9ac81eed3fd78704e5	508546702	FT 2026A1	46	\N	Norcana - Canalizações do Norte Lda	2026-02-20 00:00:00	200.00	46.00	246.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.606
cmnfm207i023thgt4il89yqkh	35ce9ecf41c06d0c054620c606843565d0da9c2a5d7505ad3e3182df21e759a1	501293710	FT FA.2026	1098	\N	Jocel Lda	2026-02-13 00:00:00	149.90	34.48	184.38	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.614
cmnfm207r023uhgt40mpmg8rv	a0db57f5a0b16f98ea7d4d98e301889179a43ee614670faf2df2babfc1236c0e	505416654	FAC 4990882026	0002213	\N	Ikea Portugal Moveis e Decoração Lda	2026-02-07 00:00:00	120.98	27.82	148.80	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.623
cmnfm207z023vhgt4go9jbwgw	6ac24b71064871f21a243fdad53aedf21e321f94828863b98871750b6e968d8b	517514419	1 2026	28	\N	Cardoso Carvalho & Silva Lda	2026-02-02 00:00:00	120.00	27.60	147.60	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.631
cmnfm2086023whgt4dcxq4hzf	6afa4b6bf8ecf4b9109b355b728f9b8d0d522c355486fd40419769eda5cc6afd	514798726	FT 2A2602	60	\N	34 Restaurantes, Lda	2026-01-24 00:00:00	164.44	24.96	189.40	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.638
cmnfm208b023xhgt4jypczed2	ef697e8d762e0756487a81684109d87e2042eab2474df2d8eda4e4278a624d24	502022892	FT 0	051052	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2026-01-29 00:00:00	107.50	24.73	132.23	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.643
cmnfm208i023yhgt46rdmhm3c	a3952e506c233ab1492c3e3cb5c24f8b3b2f96ecd20aec5df7eac0ef85d49701	502022892	FT 0	051386	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2026-02-26 00:00:00	105.00	24.15	129.15	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.65
cmnfm208n023zhgt4u1hodgbf	5a8c5cc130e32ee317123089e1ff745c3e2c647b1c0f9dae9f6aeef65dcf9156	516676180	FT FT26	013760	\N	Ibelectra Mercados Lda	2026-01-28 00:00:00	126.68	23.37	150.05	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.655
cmnfm208t0240hgt4eod3lgnt	3ff0c7d068c86df900224cb5220255144681af6b98af824857d302f71d068ed8	516676180	FT FT26	011430	\N	Ibelectra Mercados Lda	2026-01-23 00:00:00	132.47	23.06	155.53	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.661
cmnfm20900241hgt42wmbjy7b	5d9d71afa8ccd9b8f6c3e29284311cedb42e9e34891bc9e26d2992a026830179	505416654	FAC 4990022026	0000316	\N	Ikea Portugal Moveis e Decoração Lda	2026-02-07 00:00:00	97.57	22.43	120.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.668
cmnfm209b0242hgt4781gkwwj	02e3ea54212f2e1dbcc61c5a8d404708bf736f6d30b2af685d5c3c222202cba0	517514419	1 2026	4	\N	Cardoso Carvalho & Silva Lda	2026-01-03 00:00:00	96.00	22.08	118.08	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.679
cmnfm209m0243hgt4hrgoyg6m	10074b76f2a35085734c6ca3d9f89e531851d40c87bcb54ec4b772d8b8214a09	516676180	FT FT262	003606	\N	Ibelectra Mercados Lda	2026-02-24 00:00:00	117.95	21.39	139.34	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.69
cmnfm209v0244hgt4u7gwvrzy	123324e3fc82740e3d2d586a45f8f81df2f139d5655a8d68621df03f3232e465	501293710	FT FA.2026	739	\N	Jocel Lda	2026-02-04 00:00:00	74.90	17.23	92.13	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.699
cmnfm20a40245hgt4r6fefmbk	067614b47c162d376ad20c144c39c5ed562caffdfc6b696e54285882c3520915	516676180	FT FT262	000712	\N	Ibelectra Mercados Lda	2026-02-19 00:00:00	82.44	15.15	97.59	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.708
cmnfm20ac0246hgt4dfnxaddv	3e0f8153ae889eca14bb0beb2d32da43a7f8ead2a77f292baa586b6ee2b36872	513590722	FT 1A2601	215	\N	Hermano Sampaio & Flávia Sampaio, Lda	2026-01-24 00:00:00	99.76	14.49	114.25	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.716
cmnfm20aj0247hgt4yfc7g0jo	b040f8dec48b6af1c8fc898234371f1875fa93348d5b1c1682b107e0fa6e30d5	516222201	FT FT.FC26	379215	\N	Digi Portugal, Lda	2026-02-12 00:00:00	58.13	13.36	71.49	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.723
cmnfm20ar0248hgt4v7u5mb02	2c2b5175c0102870947f0e8100c4de5437852f45bca5ad61f638dd07322a8aa8	513325417	G 1123-23P	204582	\N	Isaura & Lopes - Supermercados Lda	2026-01-07 00:00:00	57.15	13.14	70.29	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.731
cmnfm20az0249hgt4xoygz9bk	ef2d2810cee2e0ee22d590fc5d17d5c3bb88b1386dd32a49cc8ef1226abcf31c	516520741	FR 2026A33	16253	\N	Petroprix Portugal Unipessoal Lda	2026-02-15 00:00:00	57.11	13.13	70.24	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.739
cmnfm20b8024ahgt4fyc7if4c	61d6f4ddd46c8785bb0456377945ed5854db65ad4eb7b24883f05f5d8290e85d	503630330	FS AUM004	189285	\N	Worten - Equipamentos Para o Lar S A	2026-03-04 00:00:00	56.90	13.09	69.99	Fatura simplificada	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.748
cmnfm20bh024bhgt4kcg87snv	1a09be058254d8a46678ba9601f4e3620c97fc2b47965395067472d0340de4b4	502201657	FR FRG.2026	55	\N	Centrocor Comercio Tintas e Ferramentas Lda	2026-01-17 00:00:00	53.98	12.42	66.40	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.758
cmnfm20br024chgt4zv44m096	b3f5ee8cab7f2f277906cac5ab97ad30a25cc92cb52e36aaccfb25f0f523f3aa	516222201	FT FT.FC26	36465	\N	Digi Portugal, Lda	2026-01-14 00:00:00	53.66	12.34	66.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.767
cmnfm20c1024dhgt4homhqv1j	edfdd19f085ea94fffd49d34f1e2c1170c3e18072b6ebacda81163158ffc9712	502201657	FR FRG.2026	37	\N	Centrocor Comercio Tintas e Ferramentas Lda	2026-01-09 00:00:00	51.38	11.82	63.20	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.777
cmnfm20cd024ehgt40hy9wcmz	9e84abbbe9f8e494e47d8d5c34c3fe970975fe7f56b68c9e2be34c8284f7d2e8	513595503	FRH 1	17850	\N	Geopor, S.A.	2026-01-17 00:00:00	193.40	11.60	205.00	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.789
cmnfm20co024fhgt4e56sz9yy	19b7edcf6ea66d04e50bcedcb7b95bdd713ddce13c1048b69755c508efcd1969	516697030	FT 336D26	0014522	\N	Plenergy Port, Unipessoal Lda	2026-02-28 00:00:00	50.00	11.50	61.50	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.8
cmnfm20cy024ghgt4q41nkdrw	9d427415b1ec9459f123f0ebdf44f17c877de2a3804825c29027f2e744d2c489	518417948	G 1243-25P	7068	\N	Petronor Combustiveis Lda	2026-01-26 00:00:00	48.78	11.22	60.00	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.81
cmnfm20da024hhgt4hiopbwrp	8c4c770ff5fd72b21bbd97414fd3511b35ef3a4f780f5974224a3e28e7f96fd7	514606525	FTS 2	14179	\N	Magalhães & Antunes Lda	2026-01-28 00:00:00	74.50	9.90	84.40	Fatura simplificada	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.822
cmnfm20dh024ihgt4ruv8ly1i	aa750388a0b4033a15dd1fbfa0726bb2bfe6e38006e5ec10e5c83806fe13c8da	506848558	FT 20260335301	000385	\N	Bcm Bricolage S A	2026-02-05 00:00:00	37.37	8.59	45.96	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.829
cmnfm20dq024jhgt44r4qfrtu	38cfd3326a28022edf885f567d235b116691038bb41aa3e3cea16f01379ecf71	509887945	FATC R26	26	\N	O Jardim de Pevidem Lda	2026-02-11 00:00:00	36.59	8.41	45.00	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.838
cmnfm20e1024khgt40neb8n8h	8422a831f98aa51504c96e6966ab7c51e9633834718756d5c1d981ad76352bcb	503340855	VD 042800525	001553	\N	Lidl & Companhia	2026-01-16 00:00:00	36.57	8.41	44.98	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.849
cmnfm20ea024lhgt4s4dr6k7k	e419572741af6dbcc11ca77092ac1d90672597adc27a52a20ba73e3e22547597	502544180	FT 101	108096152	\N	Vodafone Portugal - Comunicações Pessoais S A	2026-02-03 00:00:00	35.31	8.12	43.43	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.858
cmnfm20ei024mhgt4qa2x5b81	850f7cc5eb0fe7019ecd33037001ecb9a8126718157778acd8ea2a6c7e7afa98	502544180	FT 101	106397095	\N	Vodafone Portugal - Comunicações Pessoais S A	2026-01-03 00:00:00	34.68	7.98	42.66	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.866
cmnfm20er024nhgt42gakf4m0	3b91cbed054a0b87f732a9b275f52618ebb3e6371240bb720afe44a5086f8dfa	513429913	FS A26DOM	2586	\N	Maisqmenos Lda	2026-02-09 00:00:00	49.63	7.12	56.75	Fatura simplificada	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.875
cmnfm20ez024ohgt4si9u9xk4	63cdd302f75168105c72e7bf229c512980d312feb1494f894109dbae397949ac	516676180	FT FT26	012381	\N	Ibelectra Mercados Lda	2026-01-26 00:00:00	53.00	6.43	59.43	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.883
cmnfm20f5024phgt47eicbfuh	1e8cbfbfa9aa3c208dcc7350db93210d160da59a5c7e8dae34dee07deff312dc	505416654	FAC 0091112026	0000730	\N	Ikea Portugal Moveis e Decoração Lda	2026-01-25 00:00:00	27.64	6.36	34.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.889
cmnfm20fb024qhgt4nxqy10wm	16807ee58a6f286a56fc844671efedc74d8e5b772e3d06b242a9cb374ef7a94e	980245974	FAC 0250312026	0065070412	\N	Endesa Energia S a Sucursal Portugal	2026-02-08 00:00:00	40.47	5.59	46.06	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.895
cmnfm20fk024rhgt4jpg7vywn	fdfa8c7609192bbb543e508202b420f1b2bf5722877ba78fcbdb0233c4c0bf02	980245974	FAC 0240312026	0061012588	\N	Endesa Energia S a Sucursal Portugal	2026-01-08 00:00:00	35.71	5.12	40.83	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.904
cmnfm20ft024shgt4mn8vs293	e8a6d74edb1e41b8b35a4ba44645ace18ea3242a2fb46c29273bf02b06aab76f	980245974	FAC 0230312026	0057092588	\N	Endesa Energia S a Sucursal Portugal	2026-02-19 00:00:00	23.35	4.87	28.22	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.913
cmnfm20g0024thgt4eksxyb8r	5b6508079b5c5b7bbe884790f37b5de42856c391f4d79e17a38c1ae6910aad3b	980245974	FAC 0240312026	0061032177	\N	Endesa Energia S a Sucursal Portugal	2026-01-18 00:00:00	21.31	4.63	25.94	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.92
cmnfm20g5024uhgt43iks57d0	9badcf969a38b87d3c1478ff502dd07b8f6f385cbcb9fe518d28ad4a0d4cd363	510450024	FR 003	2545744	\N	Ifthenpay Lda	2026-01-31 00:00:00	16.78	3.86	20.64	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.925
cmnfm20gd024vhgt4y5okq6pq	20ce60d9133a043cf48f91d8c74a9a9405b65f08be0622a242b9a440cf7492ae	506848558	FT 20260335701	000142	\N	Bcm Bricolage S A	2026-01-08 00:00:00	17.40	3.58	20.98	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.933
cmnfm20gj024whgt4swzii6om	2fec071bf2f3da379e9165c305a4ac394ecef4f94f25126b9e0d4598ebcc51d8	510450024	FR 003	2562194	\N	Ifthenpay Lda	2026-02-28 00:00:00	14.68	3.38	18.06	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.939
cmnfm20gq024xhgt4pxld0ev1	83706b73404d24e67e92f32b2b13220b2ab1255fb63c7a7142869c8ac5f3ec73	500393729	FS 1A2601	16224	\N	Pastelaria e Confeitaria Moura Herd Viuva Guilherme Ferreira Moura Lda	2026-02-27 00:00:00	14.63	3.37	18.00	Fatura simplificada	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.946
cmnfm20gx024yhgt4hkdekxla	e1cdb9b4ca8704ae7ca75d5738c1a64865bb7add101ef1a953a185636a10489f	505993082	FAC 0210322026	0049000118	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-01-06 00:00:00	72.56	3.13	75.69	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.953
cmnfm20h3024zhgt4i7cdmgew	b109635501c1708952e9cc9fdab9c00aa5779d56d3502eac5103d022457f40d2	500829993	FS 08740392502242331	031641	\N	Pingo Doce Distribuicao Alimentar Sa	2026-02-28 00:00:00	21.67	3.05	24.72	Fatura simplificada	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.959
cmnfm20hb0250hgt4n5v1kcc6	b96b42912661c20e5ae3982cfe24a316209a46dde5b2c94306b7340bf3df5407	516676180	FT FT262	000930	\N	Ibelectra Mercados Lda	2026-02-19 00:00:00	23.11	2.92	26.03	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.967
cmnfm20hj0251hgt464yvhu3x	b93f4078637c8c4626ef0c66011e45a7e0f2e9f6a47d3370b1390e6dd145c69f	505993082	FAC 0210322026	0049022403	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-02-02 00:00:00	67.20	2.92	70.12	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.975
cmnfm20hs0252hgt4lxar923w	dba7607c2a6331c9c5d97cc119ba604529667363b38cf20aa9dea5331e298a45	516676180	FT FT26	008324	\N	Ibelectra Mercados Lda	2026-01-19 00:00:00	16.45	2.47	18.92	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.984
cmnfm20i00253hgt4kvq91zbz	c199b1abfe12438930d5a6140cb979950e410463ce8431a9f1d1f96a013065a4	502365846	FR 4	10190	\N	Madeitrofa Comercio Derivados de Madeiras Lda	2026-02-09 00:00:00	10.56	2.43	12.99	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:01.992
cmnfm20ia0254hgt4o3p9nnxc	53e7e1c4b76658c1f61c6ccd4bbf6298b1179210421e920d740b6596b2b4d3f1	507718666	FAC 009	95815964	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2026-01-26 00:00:00	36.32	2.19	38.51	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.002
cmnfm20il0255hgt4n10mlpxn	b82842981ed1009a1ff954bfd0a9441a7f792478dcb47e55138b2045cdc4da83	505993082	FAC 0210322026	0049017465	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-01-26 00:00:00	51.49	2.16	53.65	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.013
cmnfm20iu0256hgt4x7zfidh9	48d4c30af908c68af1c79d568570a089e46f628cf99f684877dec17986731f99	505993082	FAC 0210322026	0049039085	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-02-23 00:00:00	44.37	1.98	46.35	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.022
cmnfm20j10257hgt4bfdv23aa	a29c3802e45d49b49f4536f3e951babbc83752df96ed14a771c473b2c7a571b9	507718666	FAC 009	95881000	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2026-02-17 00:00:00	32.30	1.95	34.25	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.029
cmnfm20jc0258hgt4qzp6mea8	4289d165550354c2f6b26ee85cbb1e28888b727647f2d1a26c16fa59e88b78c6	513325417	G 1123-23P	210088	\N	Isaura & Lopes - Supermercados Lda	2026-02-08 00:00:00	8.13	1.87	10.00	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.04
cmnfm20jn0259hgt4j9d8r28k	6578021513b9b3538a262959be11ba9438bcd916ede73619ebdf8a450b38a494	516676180	FT FT262	003450	\N	Ibelectra Mercados Lda	2026-02-23 00:00:00	8.88	1.61	10.49	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.051
cmnfm20jv025ahgt4p0hxtmvr	b232d2d310f51ddcfdc982ad3a890831f7cf90c9a6314b96c10ddcde8aef4c40	505993082	FAC 0210322026	0049039083	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-02-23 00:00:00	30.42	1.14	31.56	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.059
cmnfm20k6025bhgt491oqpfjk	97cfa1de247303b13a5b4a8bc1189681b56eacba46b42b1bd33cf46562669d0f	505993082	FAC 0210322026	0049000248	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-01-06 00:00:00	21.85	0.66	22.51	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.07
cmnfm20ke025chgt4ji3yv4vd	40b00bf2d9cfbb02dff6daeac4fb28a4a5e6a6d0fa11ebded8b0cf064fd83962	505993082	FAC 0210322026	0049024489	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-02-03 00:00:00	23.95	0.62	24.57	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.078
cmnfm20kn025dhgt4i6jnmjdy	7d79cf383ca20c69538f2d608ed5c94b62ac99be7f5db5d7a7fc2d656c9130b4	505993082	FAC 0210322026	0049017464	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-01-26 00:00:00	23.98	0.51	24.49	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.087
cmnfm20kt025ehgt4pxw0f6g9	3c3624ff4e8e1cdebb3fe058e5aa9a3628a5064b834217942dab2e3f97f0164f	505416654	FAC 0090692026	0003772	\N	Ikea Portugal Moveis e Decoração Lda	2026-02-15 00:00:00	1.62	0.37	1.99	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.093
cmnfm20l2025fhgt45e0y63qh	9a1ca6a057fb8927339898b76c27d54fff655c423faf700241bf1324fbece80e	506848558	FT 20260015801	000817	\N	Bcm Bricolage S A	2026-01-31 00:00:00	1.37	0.31	1.68	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.102
cmnfm20l7025ghgt4gcg2lazn	01ca6fc8118e58a1dfe02debe620e2c81b85439ebabd95ce53b5cd07ff734fc3	501965319	FR 1	104249	\N	Luis Peixoto Lda	2026-01-24 00:00:00	1.22	0.28	1.50	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.107
cmnfm20ld025hhgt49ey4nh42	b0138b1a6e66e2270b196b2ca0655688edbc12a964c1f58fa97fbcadd5a34e79	505993082	FAC 0210322026	0049042601	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2026-02-27 00:00:00	10.50	0.18	10.68	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.113
cmnfm20lk025ihgt4j7pkjx9i	373694b6a667630b7c1d7638c77cfa4b067ab126e92fba8a3f0452244ba20fc2	510450024	FR 003	2564767	\N	Ifthenpay Lda	2026-02-28 00:00:00	0.70	0.16	0.86	Fatura-recibo	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.12
cmnfm20lr025jhgt4s7kierip	6f6ff6bda368abda7857ce88c77aa431ef9fbc136e0a371f2c2a3ed02839a08d	502075090	FT 5412026	480	\N	Arcol, S.A.	2026-02-18 00:00:00	0.00	0.00	0.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.127
cmnfm20m0025khgt41vxhk6w1	1258a2cfea4520012af3fca713901ef781a26e034737d1e871d8ae27c775bada	514280956	FAC 109	1184965919	\N	Empresa Municipal de Ambiente do Porto e M S A	2026-02-17 00:00:00	21.18	0.00	21.18	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.137
cmnfm20m9025lhgt4zvmwapca	7054d5055adf9ee9e259243b968d3becc3ed40ddc004df817ae5af335dff6792	502075090	FT 5212026	282	\N	Arcol, S.A.	2026-02-05 00:00:00	0.00	0.00	0.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.145
cmnfm20mj025mhgt4fdv7vb0h	3d55f3f7d90ba23264efd7e2b42e223cbd95ee1ce38908adcd771c2e55d98da2	514280956	FAC 109	1184902044	\N	Empresa Municipal de Ambiente do Porto e M S A	2026-01-26 00:00:00	23.32	0.00	23.32	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.155
cmnfm20mp025nhgt4cccuq3pk	b0d099d1fa2ef29773ec4ad80288a5e2d0771b36d5e0ecb01f696802c37a03cd	506848558	FT 20260015401	000348	\N	Bcm Bricolage S A	2026-01-25 00:00:00	0.00	0.00	0.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.161
cmnfm20mx025ohgt4k14c4lhu	a78e07632da19b81f7fa4b06214f39731a0af2957da21ebfdb90062bf92971d5	502075090	FT 5412026	62	\N	Arcol, S.A.	2026-01-10 00:00:00	0.00	0.00	0.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.169
cmnfm20n2025phgt4hw5iz09v	ab42033b5c442ee8b71fd92ef8ed1f9f152ddd7ffd21f571e08bbcac70fdfe69	502075090	FT 5212026	90	\N	Arcol, S.A.	2026-01-10 00:00:00	0.00	0.00	0.00	Fatura	cmnfm204v023khgt4ictgupot	2026-04-01 05:34:02.174
cmnhoyc7p010srkt4igyvtap3	8ae066368ff8c5fd2655069613dad4709e4eaf0d998655756c54b3769f86bbec	505416654	FAC 00903020200014	247	\N	Ikea Portugal Moveis e Decoração Lda	2020-07-21 00:00:00	1928.04	443.39	2371.43	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.749
cmnhoyc8m010trkt4j5aumx76	5c4e1c3eac83336b0b0c101e20b5b94a74419a60e7a9fa75aeae01cc1ceb69b7	200235125	FA 2020	10	\N	Jose Antonio Pereira Salgado	2020-09-25 00:00:00	1398.74	321.71	1720.45	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.782
cmnhoyc8v010urkt4hvo9nkq8	4dbb6b1c926c1134d70a627d0803c5c0be65ee51e26d88d24d35ca8c21aa15b0	509836593	FACT SEC120	326	\N	Maria Manuela Barros Unipessoal Lda	2020-09-12 00:00:00	1264.03	290.73	1554.76	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.791
cmnhoyc90010vrkt4z1vi33y9	05f8d56c35ed02ac186906da46081981bbea0ab33638797cce084d40a1110155	503000000	FACTC 120	529	\N	A M Industria de Colchões Lda	2020-10-06 00:00:00	717.80	165.09	882.89	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.796
cmnhoyc9f010wrkt4cmojelsp	c855965890908d200bffd278c1ef09698ec9d97c1a671a435cbf0a958689f76c	505416654	FAC 00900820200073	529	\N	Ikea Portugal Moveis e Decoração Lda	2020-09-12 00:00:00	682.93	157.07	840.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.811
cmnhoyc9o010xrkt42tc6xr2f	752f14f102a1ad3afd3ecc7894917cf16e9bee14dc21bc5dbf1c8e9dc581276e	505416654	DEV 49903420200018	796	\N	Ikea Portugal Moveis e Decoração Lda	2020-10-23 00:00:00	-347.16	-79.83	-426.99	Nota de crédito	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.82
cmnhoycak010yrkt423nawij0	52c6431b63e19672dccedd23579f01e03797330ba5ab65cc8f365d55157065ec	509836593	FACT SEC120	299	\N	Maria Manuela Barros Unipessoal Lda	2020-08-13 00:00:00	336.96	77.50	414.46	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.852
cmnhoycat010zrkt4tgwoofvn	b2750eb212884d09a888e3db35ff9031b902f9724da7041a1480df7f164324a2	505416654	FAC 49900220200157	273	\N	Ikea Portugal Moveis e Decoração Lda	2020-10-23 00:00:00	290.08	66.68	356.76	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.861
cmnhoycb20110rkt4niayc6b4	b644fcdfb07032b9ee48b5b1af4aa1d813a4bd06b4e78d1f0c777a7532d19403	503133221	FT M2020	4495	\N	Macominho Materiais Construcao do Minho Lda	2020-10-06 00:00:00	283.20	65.14	348.34	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.87
cmnhoycbb0111rkt4h68exsaa	5b42448b428c5c266bed1796e8e09abff2f4f65a3dcfcbdfd6939a1c4cf22c30	503630330	FT AUM009	004423	\N	Worten - Equipamentos Para o Lar S A	2020-08-05 00:00:00	268.28	61.71	329.99	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.879
cmnhoycc50113rkt4yih8cmvc	359cfa24fe80be68ae8aa38cb1ef7640a5253708df4a8987dc67fcf28cec8b70	513277668	FT 2020	340	\N	Ana Pereira Fernandes Unipessoal Lda	2020-09-21 00:00:00	216.75	49.85	266.60	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.909
cmnhoyccd0114rkt4ebtgfhzp	5e619e5612d1aa2c9c79856e020ee6d0a8eec5a3805bf38837e7526e44ffcb6e	503000000	NCRED 120	39	\N	A M Industria de Colchões Lda	2020-10-06 00:00:00	-215.34	-49.53	-264.87	Nota de crédito	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.917
cmnhoyccu0115rkt4rn3fpd25	e495e1206f9bb9976d348b0252fc2ee98f4b521f0fd1708a2b01be0130ad7a11	503000000	FACTC 120	353	\N	A M Industria de Colchões Lda	2020-07-16 00:00:00	215.34	49.53	264.87	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.934
cmng38y10003urkt46c6w8xwb	209af8b45f8ce511f0322ee56b7ba9af3ce50cde5428939ca6fea0ec0540e061	205510833	FR ATSIRE01FR	3	\N	Raul Fernando da Costa Oliveira	2025-02-13 00:00:00	1100.00	253.00	1353.00	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.852
cmng38y1c003vrkt4ua18n90m	a2cbcf243ab7a2a96acafa64f6f9656623b57169c435e0bc40a669f52e9819fd	515337498	FAC 1	605	\N	Rd48 Reparação e Comercio de Automoveis Unipessoal Lda	2025-01-29 00:00:00	943.24	216.95	1160.19	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.864
cmng38y1m003wrkt4aijcncv4	f05e8d4fda9e75b8c68195878f5067582e208d053565db522f608d59b1de1157	500387281	FR 25	1838	\N	Corticas N S Lda	2025-05-30 00:00:00	913.62	210.13	1123.75	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.874
cmng38y1v003xrkt4pvdoce1w	efc0509fa6588303bfb0248e02b3715d571f899fb4c8ff144749c7cd36ad375c	505416654	FAC 0090412025	0001986	\N	Ikea Portugal Moveis e Decoração Lda	2025-07-21 00:00:00	907.38	208.62	1116.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.883
cmng38y23003yrkt41ft695pl	3f72e4c3b74522780e1e259b02a43ecf47abf542b915691d454792ac3204d8ea	501293710	FT FA.2025	5962	\N	Jocel Lda	2025-07-21 00:00:00	559.60	128.71	688.31	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.892
cmng38y2e003zrkt4svzn3ahs	7d414cc6ddd0c8f2dbc389bdbb2ec3f0b897bb33def556fe848a63ee402a1c5a	505416654	FAC 0090412025	0001985	\N	Ikea Portugal Moveis e Decoração Lda	2025-07-21 00:00:00	547.99	125.99	673.98	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.902
cmng38y2k0040rkt4h5cnla2l	370deaae5f5fb14d705fdf8ef099da0ca6847b2900f969020b1a577b5fdcef35	241303940	FAC 1	200	\N	Tania Marlene Magalhães Ribeiro	2025-04-09 00:00:00	500.00	115.00	615.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.908
cmng38y2t0041rkt449nxqvrx	16f6c2409f18edc29a450fe7f526882d13d082415cdaa846d6c1feff005ff18e	504984810	FR 2025A3	19	\N	Saniestilo - Materiais de Construção Lda	2025-01-10 00:00:00	424.44	97.62	522.06	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.917
cmng38y320042rkt4i2ohily2	693db700b157f70ad95767453ad32ca338894dd4f89d65cec8d41fff939a40d5	506848558	FT 20250115601	005297	\N	Bcm Bricolage S A	2025-07-16 00:00:00	388.33	89.31	477.64	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.926
cmng38y3i0044rkt4o0halrqt	e69f1a851e362a86677c868a419b4b9a884a18b5c46dd4afe91b86b2ca74348f	502021420	1 2500	000124	\N	Manuel J S Peixoto e Cia Lda	2025-06-26 00:00:00	1318.87	79.13	1398.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.942
cmng38y3r0045rkt4n2fdbxm6	5aae7e6b7ce6afcf4845af517aa6e6089573fa651c2fda0d6457d98f1bea335f	505241285	FT D2-A	14455	\N	João Pinheiro de Abreu & Filhos Lda	2025-02-06 00:00:00	276.42	63.58	340.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.951
cmng38y3y0046rkt4e8lqikc1	32fb5a6fcb6d82bb8e8390c3d16186a076bcbcba9cce050cca1ff8e525ee60ef	506848558	FT 20250335601	002681	\N	Bcm Bricolage S A	2025-07-18 00:00:00	250.71	57.66	308.37	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.958
cmng38y490048rkt4jv1l0f84	7afeab86eb29a4735610da2cda693014769430ecdcad79cd83d82924bce02145	506848558	FT 20250335201	001318	\N	Bcm Bricolage S A	2025-04-24 00:00:00	244.99	56.35	301.34	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.969
cmng38y4k004arkt4f29hy6c8	b0a5e558e1d6e4979962923b04cd8e3633dbb497329d031ba9c19811181ad518	502201657	FR FRG.2025	393	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-04-15 00:00:00	226.60	52.12	278.72	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.98
cmng38y4u004crkt4w8a5p6n3	1750ff344fff5fe59f14b4edd2176b6a1782b47b3207f90a08ba6a6154463eaa	502201657	FR FRG.2025	37	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-01-11 00:00:00	206.07	47.40	253.47	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:18.99
cmng38y55004erkt4c4xafmgh	41ba5e20c022490836f1d47d765d7a0a15085cf2aad0a3bbe9b7ee62bffe65a5	502201657	FR FRG.2025	556	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-30 00:00:00	205.82	47.34	253.16	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.001
cmng38y5f004grkt4a0gyyu2w	d532f63548765046c9b50f3fad3673d9cc0536cdbf21a7f32e36931e766fb23a	513469559	FAC 25	770	\N	Trilhos Simétricos, Unipessoal Lda	2025-04-10 00:00:00	200.00	46.00	246.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.011
cmng38y5n004hrkt4imabxq7t	a586f8d2bfe7250cc36fbc5d07a884a3a1cb7b713d8e9190e99b2f5936ba9bd0	503738301	FR1 SIT2	57323	\N	Airoferragens Ferragens e Ferramentas Lda	2025-05-06 00:00:00	154.39	35.51	189.90	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.019
cmng38y5u004irkt4c6ofegzs	99d06cae11121b938e308582084f94ed6b72d8c98d14a0701119c05758f0d406	231578504	FACC-N 1	10007	\N	Monica Linda Ribeiro	2025-07-11 00:00:00	146.34	33.66	180.00	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.026
cmng38y62004jrkt4wf2w0vrz	43452c16012a49c73fa1962af158de5820e132478dfe4a9f4ef9284632c939ca	502201657	FR FRG.2025	229	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-03-05 00:00:00	131.71	30.29	162.00	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.034
cmng38y6d004lrkt4bqg8bvdy	1396ef26547fcc2be8dd9ddf665d6ccab998b3bd26c478294cdd5470653fb7f4	508546702	FT 2025A1	137	\N	Norcana - Canalizações do Norte Lda	2025-05-07 00:00:00	125.00	28.75	153.75	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.045
cmng38y6k004mrkt46r6aglmw	6096cfd887109e1dcd98e375a38299711ae38120f989bcf41be878b4937ac675	517514419	1 2025	127	\N	Cardoso Carvalho & Silva Lda	2025-06-02 00:00:00	120.00	27.60	147.60	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.052
cmng38y6y004orkt4lbb7j4ic	90426576eaa3aa6c8e2513b3ceffe20f27578bd15c4612fe86629e086b7f0cea	517514419	1 2025	77	\N	Cardoso Carvalho & Silva Lda	2025-03-29 00:00:00	115.00	26.45	141.45	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.066
cmng38y7b004qrkt4rkfizpf0	969ce2a6d2826c2be32e7093b6309a61a3486c33f6d207e01b7505363a44bd67	507206797	FR FTS25	491	\N	Carstuff Artigos Para Carroçarias e Estofos Sociedade Unipessoal Lda	2025-04-15 00:00:00	114.58	26.35	140.93	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.079
cmng38y7i004rrkt49vf5dvew	40a4ec2bda304d18af4a7a387c3fcd16398001d38163250dbd6560e80afa4bbc	980245974	FAC 0230312025	0057010846	\N	Endesa Energia S a Sucursal Portugal	2025-01-07 00:00:00	113.64	25.94	139.58	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.086
cmng38y7p004srkt460ynh0kv	14eeffaec593bc7bce0e984a583cec36507f88ebf92b242491fa4dc1c2a4e605	505416654	FAC 4990022025	0001232	\N	Ikea Portugal Moveis e Decoração Lda	2025-07-23 00:00:00	106.52	24.48	131.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.093
cmng38y7y004trkt4g9q23y5k	cddcef8a76155eeca5b34bbad6d3f857958a9be0bcb463249667cff224f41d57	516676180	FT FT25	009380	\N	Ibelectra Mercados Lda	2025-01-31 00:00:00	136.29	24.41	160.70	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.102
cmng38y86004urkt4a7f6wszo	e838801302a5519d57c97372492767d9e5bebab820f05f18d3af5a9df40439df	506848558	FT 20250016101	013921	\N	Bcm Bricolage S A	2025-07-20 00:00:00	100.81	23.19	124.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.11
cmng38y8h004wrkt4dbo8pmux	f51794322e37ff191756bb4aa4a57ad2eddac7bd8ffe20c28d32cbbcd01be4c0	502075090	FT 5012025	17704	\N	Arcol, S.A.	2025-03-14 00:00:00	100.56	23.13	123.69	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.121
cmng38y8n004xrkt4j5xq7mlw	87a3cebd2515e5f0888de931924da7f1f5c04b0d96c98f44ab993425cba13bbc	502022892	FT 0	049083	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-07-30 00:00:00	100.00	23.00	123.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.128
cmng38y8w004zrkt4466mxsla	d299bd0b53116cc4b1b10b38cd6344c93418ddde9cc7675bbc75ff940b48b179	502022892	FT 0	048737	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-06-30 00:00:00	100.00	23.00	123.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.136
cmng38y960051rkt44oboboq5	6c23d743ad381f77cfce53a3c8f850553b026f90255cd5e748627e0a49e9234c	502022892	FT 0	048599	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-06-05 00:00:00	100.00	23.00	123.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.146
cmng38y9e0053rkt42a6kstfw	96b3d49a03aff91a81ae3cba14faa7f0d6c7dd9047e20f762782b51a75bcfddd	502022892	FT 0	048070	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-04-30 00:00:00	100.00	23.00	123.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.154
cmng38y9o0055rkt4f2r7rd7b	513ee86ab2a77b5db64b6cbe8125f8f7945204afea54393ea1b058d8826a7c7b	502022892	FT 0	047738	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-03-28 00:00:00	100.00	23.00	123.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.164
cmng38y9w0057rkt47fmfowc5	fb022a4ae132a3876da9f7578077d5cd1032ab51c08928746ccbe47696beda8a	502022892	FT 0	047624	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-03-10 00:00:00	100.00	23.00	123.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.172
cmng38ya60059rkt45c0x7f2n	69fd4a2941f8980d844f48b53ebe826cfd4da63353093ec9731cdd3b39e647e2	502022892	FT 0	047088	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-01-30 00:00:00	100.00	23.00	123.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.182
cmng38yae005brkt4iouzzgzu	21fc80f9d388f25257e7766e00048e2b5464827b371bff470c0da1a688504043	503630330	FT AUM004	031877	\N	Worten - Equipamentos Para o Lar S A	2025-03-19 00:00:00	97.55	22.44	119.99	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.19
cmng38yap005drkt40s6a0lus	4cbc4832e46c80b1c47e87632aaa6e1cff1b171a3265bd52564d2ac75e6265e5	506848558	FT 20250105201	002711	\N	Bcm Bricolage S A	2025-07-20 00:00:00	96.75	22.25	119.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.201
cmng38yay005frkt476z2kzt9	4e96fc3f2b2d0e1e8ebff0d181a7e07e12c6e13917cfca5598208ce56e3855e3	517514419	1 2025	140	\N	Cardoso Carvalho & Silva Lda	2025-07-04 00:00:00	96.00	22.08	118.08	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.21
cmng38yb7005hrkt4rr96zhfi	d49f7f96e9cbe980700631ca0fa0005cd73ebb3692cc55b83e80c69ae4b73c84	980245974	FAC 0230312025	0057191588	\N	Endesa Energia S a Sucursal Portugal	2025-04-08 00:00:00	96.73	22.06	118.79	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.219
cmng38ybf005irkt4w8ebha5u	f33438b403147189bc6377eaa6877c0fba9a6f83e2b86102cd4b7b9b2bb91776	505416654	FAC 0091102025	0005457	\N	Ikea Portugal Moveis e Decoração Lda	2025-07-21 00:00:00	95.13	21.87	117.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.227
cmng38ybm005jrkt4hc0bsif4	7f48fc5e4356077a95c8a1d269580e2e70c00692b040ff5db7a9f5220ad4c90a	502201657	FR FRG.2025	449	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-06 00:00:00	94.71	21.78	116.49	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.234
cmng38yc1005lrkt4h3q6lh19	3e686aaaa5eae9b9f87d605fbb41370cb44f82d2970627a951184e7b81fe2a10	517514419	1 2025	100	\N	Cardoso Carvalho & Silva Lda	2025-05-01 00:00:00	92.00	21.16	113.16	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.249
cmng38ycf005nrkt486wmtdh6	3ca43fe5f998404fd38d69c213e2614cfcd08c0ebd13076cee83a52b63aec604	517514419	1 2025	48	\N	Cardoso Carvalho & Silva Lda	2025-03-04 00:00:00	92.00	21.16	113.16	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.263
cmng38ycs005prkt45wx2teqq	96f9f510396f35207e083c011a00f42163bb1ccd6c529e0bdac2c162ddb110af	517514419	1 2025	16	\N	Cardoso Carvalho & Silva Lda	2025-02-01 00:00:00	92.00	21.16	113.16	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.276
cmng38yd7005rrkt4gpo2ka7y	81c8ff7e810a6c2e54a34e44895e1a19157a8867088cc3db40e2712c58a545ef	980245974	FAC 0220312025	0053074935	\N	Endesa Energia S a Sucursal Portugal	2025-02-06 00:00:00	89.96	20.49	110.45	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.291
cmng38ydg005srkt47k1zgj5k	23a8cf203ed305c439e56c100cce2789f37ea0c50e435c445bd5c4473f070b47	502201657	FR FRG.2025	530	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-23 00:00:00	88.01	20.24	108.25	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.3
cmng38ydw005urkt4lsu2lvk1	ac9e97869c8d631c877d2bb953188c24727d543446e1a4fd1911a49c51eea2b8	516676180	FT FT25	028607	\N	Ibelectra Mercados Lda	2025-03-28 00:00:00	104.92	19.01	123.93	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.316
cmng38ye5005vrkt4gnal9rbr	734b41b961d50689bc60be9422d174cd193bef7ef2e653790e407164e1c41294	502201657	FR FRG.2025	421	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-04-24 00:00:00	81.03	18.64	99.67	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.325
cmng38yek005xrkt4o9bwq4k5	2fb550ad2406555dcfb0a832e64392e2aec24a4cdf67062b3d5ffc2592432d76	506848558	FT 20250335101	000719	\N	Bcm Bricolage S A	2025-03-22 00:00:00	74.78	17.20	91.98	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.34
cmng38yey005zrkt4d2xpij0n	995f311e47924e95e8c106c96da77fc10df2a1967a3fe6f5b6c5f0b5d1c2e608	513325417	G 1123-23P	148937	\N	Isaura & Lopes - Supermercados Lda	2025-03-04 00:00:00	73.20	16.84	90.04	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.354
cmng38yfc0061rkt4rqr0ui8l	35a48647372743baa7d6390eb02ff36e435eea65cf00bd1b3b8e81d08d97f6b4	516527835	FS 009312001	287488	\N	Auchan Energy S A	2025-04-01 00:00:00	72.72	16.72	89.44	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.368
cmng38yfj0062rkt4o0o4aj2v	7df1f23366d3d515bde682cd152089344af68f2950d73e82b4422f831d280b2a	502544180	FT 101	096096238	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-07-04 00:00:00	69.39	15.96	85.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.375
cmng38yfr0063rkt4ebda85ms	2c45195b8e378e438981575e8098e60d888271c0ca31172c9fbc3dc4d2255c7d	502544180	FT 101	094402153	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-06-04 00:00:00	69.39	15.96	85.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.383
cmng38yfy0064rkt45mjj8c0w	3fab2843b833e081f011174ed9843d842c61d895b8f2e697c9429598ac96c4c7	502544180	FT 101	092672804	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-05-04 00:00:00	69.39	15.96	85.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.39
cmng38yg90065rkt4e0zj4i7p	e61c95c52114b561827f5e8cc75bfbab1f0f0fd377f58b7bd1f1bf3ee530d17c	502544180	FT 101	090980051	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-04-04 00:00:00	69.39	15.96	85.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.401
cmng38ygf0066rkt4sc701osk	198ba4ef88abdb0d2308615f41ac21adf56a79a7bf37f18e1dc8c6e20ed01c8a	502544180	FT 101	089294874	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-03-04 00:00:00	69.39	15.96	85.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.407
cmng38ygm0067rkt4sc480h6e	841fc33002684f30c4d1935a704e8cba0c01db556bd44b913566bad16a7fc13d	502544180	FT 101	087602324	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-02-05 00:00:00	69.39	15.96	85.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.414
cmng38ygr0068rkt4epmq050t	f5b2f5b413cabb3e98c87788ec932e3154c084d8eb5c1ff5a55b6094557bec4a	502544180	FT 101	085932479	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-01-05 00:00:00	69.39	15.96	85.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.419
cmng38ygy0069rkt4cgsl53rg	52d1d4e059b520674ba89f1cc8760a9c7466b0d5f6f1f047b997c31fbb97039e	980245974	FAC 0220312025	0053250051	\N	Endesa Energia S a Sucursal Portugal	2025-05-07 00:00:00	70.19	15.94	86.13	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.426
cmng38yh6006arkt4fj4529dx	f6d953308133a05a35390d260875902e390ad8293f238ecc07ab95601237fd4f	506848558	FT 20250335501	000395	\N	Bcm Bricolage S A	2025-01-25 00:00:00	68.28	15.70	83.98	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.434
cmng38yhf006crkt4qc7h4jz4	efb93d2ceff179c3fe428a498c187632be610c2221cbf90245ce028ddb3b8236	500766452	FR 025	926	\N	Congregação das Beneditinas Missionarias	2025-05-26 00:00:00	67.89	15.61	83.50	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.443
cmng38yhn006drkt4hfxze3h3	c39e4c1c69a53f2bb3780d4299921763f2abeab464129e7a631300f7d3ba9649	506848558	FT 20250335601	002644	\N	Bcm Bricolage S A	2025-07-15 00:00:00	67.77	15.59	83.36	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.451
cmng38yi0006frkt4n5ix23b5	1fe5160eafabf2e28342d268d125f17c68cdc0106fc9d5b527443f00f5ae3be6	502201657	FR FRG.2025	647	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-06-23 00:00:00	67.32	15.48	82.80	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.464
cmng38yia006hrkt40dui77y7	6523c08becdbd32ec298f6da96b210bd3eae8264a9b65c394f18ab47214d547e	513325417	G 1123-23P	175286	\N	Isaura & Lopes - Supermercados Lda	2025-07-21 00:00:00	66.80	15.37	82.17	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.474
cmng38yio006jrkt4fzr8dnuv	4d85ad35baae53641f8e2588e611bd4d7f5b35a8453f6a85c9ed9969d9368389	513325417	G 1123-23P	161879	\N	Isaura & Lopes - Supermercados Lda	2025-05-09 00:00:00	65.70	15.11	80.81	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.489
cmng38yj2006lrkt4hnmow2ft	7277fbbbe3f7e05ad96420d00409e2706b94fc4f04a49102e5a60c9eb54e5cbc	513325417	G 1123-23P	144230	\N	Isaura & Lopes - Supermercados Lda	2025-02-08 00:00:00	65.25	15.01	80.26	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.502
cmng38yjc006nrkt43goiahih	a4378ed6385d759b8d3dd0a4b400f2663140eed65701e320f21a53542be0a247	513325417	G 1123-23P	171357	\N	Isaura & Lopes - Supermercados Lda	2025-06-28 00:00:00	65.18	14.99	80.17	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.512
cmng38yjn006prkt4ddr2gias	16690870556e6108a392ad132f748814689eb3bff9fbe03668562d6f7f62b5c6	516676180	FT FT25	019598	\N	Ibelectra Mercados Lda	2025-03-03 00:00:00	78.22	14.35	92.57	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.523
cmng38yjw006qrkt4saxiy9qw	bb2aa8348d0f3ad5333a2785b75dc8c5479dfd1c20dfd2d650961d062616c84a	513325417	G 1123-23P	158889	\N	Isaura & Lopes - Supermercados Lda	2025-04-22 00:00:00	62.36	14.34	76.70	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.532
cmng38ykb006srkt4f611r6nt	973c1b344f1313906cc709ddb28e21ff866c76d49d4ef95e2d894f230257f119	505993082	NCR 0000322025	0001000601	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-07-08 00:00:00	-299.83	-14.13	-313.96	Nota de crédito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.547
cmng38ykh006trkt4i4rae45t	a7bf41836a65fd29d684a817395bb652561ac35f2984cd3421807fd5275520ab	505993082	FAC 0210322025	0049020601	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-07-03 00:00:00	299.83	14.13	313.96	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.553
cmng38yko006urkt4iye8uqji	620f9906216fcc81964469f1cd702033867934f546fe2a5773a2eb3b4445b26f	509514502	FT 2025A9	55	\N	Chave Vertical - Unipessoal Lda	2025-01-20 00:00:00	60.00	13.80	73.80	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.56
cmng38ykw006vrkt46nxtdetj	1b2e468fdbc43da6561630392f26abab17f5340fe6468a6f704867041bf8181b	505993082	NCR 000	1828784	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-02 00:00:00	-245.39	-13.73	-259.12	Nota de crédito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.568
cmng38yl4006wrkt4gzmnfc8g	c10935987403603fd5042d81b89fd78f1ea5beb7673f0618cfd2a9024b84b891	505993082	FAC 006	61101786	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-04-30 00:00:00	245.39	13.73	259.12	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.576
cmng38yla006xrkt4me59f4zn	58dee2a4fd20a1671f6ca197685d1284b8671053af24b94e3e0faa39e4e86377	516107127	FS 1	8694	\N	Memorias Atributos Lda	2025-05-21 00:00:00	77.85	13.65	91.50	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.582
cmng38ylh006yrkt4jz2c16vh	cdf29bb2702d26efff6a018293e0edb5102055ee0c2d3123b03d40aa27aeb28f	502201657	FR FRG.2025	588	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-06-05 00:00:00	59.11	13.60	72.71	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.589
cmng38ylt0070rkt4bkqnrzjl	6257557517315f79b2b6c29285facaac33caf140df1b2bb87811f03a7884599b	516114182	FT 3A2501	1465	\N	Dute Unipessoal Lda	2025-04-18 00:00:00	85.01	13.57	98.58	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.601
cmng38ym00071rkt42z81dc6g	5b6a57e4b2cc6b9abcc9f427b2b0a79f962785947ac53690cb139f1d1d2ce543	516676180	FT FT25	076814	\N	Ibelectra Mercados Lda	2025-07-08 00:00:00	82.12	13.28	95.40	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.608
cmng38ym80072rkt48bxqjnaq	3be1157852d47129061dba2387f5e75b867917cf1f98079f72508be9723ebe80	506848558	FT 20250335201	002345	\N	Bcm Bricolage S A	2025-07-24 00:00:00	55.18	12.69	67.87	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.616
cmng38ymm0074rkt49qumjrdn	a55bbc2961ae0d02a43654dbb5de9b7fa6114ba7e1904ccd21e41288ab19093e	513325417	G 1123-23P	136697	\N	Isaura & Lopes - Supermercados Lda	2025-01-02 00:00:00	55.13	12.68	67.81	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.63
cmng38ymx0076rkt4o8xrjd2b	522f37fc0ffbcf8ecd52031984e1286852f503dab413bb537edab333747ebba1	502201657	FR FRG.2025	373	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-04-08 00:00:00	54.87	12.62	67.49	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.641
cmng38ynb0078rkt4z6dg1j5i	cea4f47d9ec295b0304f6b03f696ccc2556f982e8545514b60c9b040269fb002	502201657	FR FRG.2025	461	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-08 00:00:00	54.69	12.58	67.27	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.655
cmng38ynn007arkt4ngiiswoe	a4467eb186f1b93bfa116646ed7277563d5b2dfdb12defa4ee4eff6717990328	502590629	FR 130012025	1351	\N	Casa Napas Lda	2025-04-04 00:00:00	54.45	12.52	66.97	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.667
cmng38ynw007brkt4liaudwf8	272f7fded75a5006173a0e83cd7329c464c6c563796232972e8ded00850d40dd	505416654	FAC 0090412025	0002019	\N	Ikea Portugal Moveis e Decoração Lda	2025-07-23 00:00:00	52.85	12.15	65.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.676
cmng38yo4007crkt413t8p9dj	75d7500f9ab6d4db6e3826a19beb6e1eda45b0b4f7cbe813ae68d27930324df0	980245974	FAC 0240312025	0061128379	\N	Endesa Energia S a Sucursal Portugal	2025-03-08 00:00:00	53.70	12.15	65.85	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.684
cmng38yoa007drkt49a6jljrw	49164fbecf7c115659ad8d4ebd455e1569f8f6a797b75d4de18ef993392683c9	516676180	FT FT25	027638	\N	Ibelectra Mercados Lda	2025-03-25 00:00:00	74.86	12.10	86.96	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.69
cmng38yoj007erkt45h3lwsww	d5cd5a2842697f548b6123afa79464358646518f4da2cdee17b5939f2f9615b3	518794890	FATREC SERIE1	40	\N	Rui Pedro Lemos Unipessoal Lda	2025-06-12 00:00:00	84.26	11.64	95.90	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.699
cmng38yor007frkt40i57kkmx	7a7a3084200212cca459e7bd03ef28b8c955241e8415c0cc47a6f2e91ad88f31	231578504	FACC-N 1	9745	\N	Monica Linda Ribeiro	2025-02-28 00:00:00	88.94	11.56	100.50	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.707
cmnhoyqes01bhrkt44pepr371	f58d5f609d9b66d30d3ae48d98e4d5d7d991e65054af291c5c83a3c335fb5b00	506848558	FT 202200851	000925	\N	Bcm Bricolage S A	2022-09-08 00:00:00	27.04	6.22	33.26	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.148
cmng38yp1007grkt4wvx4h8bp	834ed8e4006d532142f7a18f076f78bc8056e11fc39d9c5a28e8e60d27d00a3c	513325417	G 1123-23P	166057	\N	Isaura & Lopes - Supermercados Lda	2025-05-31 00:00:00	48.78	11.22	60.00	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.717
cmng38ypq007irkt4vunu612u	d3dc8e255fedb99ec303d4dd7eda42a85e59d678a90cd18a3195bf825a83ca3f	501241191	FS FS.2025	5446	\N	Drogaria da Ponte Lda	2025-04-26 00:00:00	48.59	11.18	59.77	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.742
cmng38yq4007jrkt4m2wvbgv5	3fc3c53fc0bb4d4d08de03f42ea34a0dad569e6f1d0477c2e833638e5337bd7e	502201657	FR FRG.2025	473	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-09 00:00:00	48.18	11.08	59.26	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.756
cmng38yqn007lrkt4d38gj3l4	c7a2e2deecbcd55a2f9b7ca8dd2c1d810e48e6fbfe77e27f0b0a98d74c7fb535	502201657	FR FRG.2025	104	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-01-29 00:00:00	47.78	10.99	58.77	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.775
cmng38yrj007nrkt4ffg3d50q	8d2a890277a2d85912dedc4c02b12ebc77cf4d8498718f0e274af8598cec81f2	516676180	FT FT25	027381	\N	Ibelectra Mercados Lda	2025-03-24 00:00:00	73.52	10.86	84.38	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.807
cmng38yrt007orkt4y2jvodxe	489767a37aeaa78846d37c46ddaa0f952ce4c39a4804a45c9caf02c79ca74d0f	502075090	FT 5012025	41194	\N	Arcol, S.A.	2025-06-16 00:00:00	47.82	10.70	58.52	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.817
cmng38ys6007prkt4ggp6fxch	5760779bc2e1b979b211b00f510e1f3efcab26a72716007c146020777ebdd1e7	502201657	FR FRG.2025	231	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-03-06 00:00:00	46.48	10.69	57.17	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.83
cmng38ysi007rrkt44ewcredn	b8608e28f808209103b90fb12994246d5de46966924528daeff493ca76c865fb	516676180	FT FT25	076813	\N	Ibelectra Mercados Lda	2025-07-08 00:00:00	62.07	10.32	72.39	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.842
cmng38ysp007srkt4l4k4u1cd	c99dbf541c1ce3c7a21a51573f2f1c65196e16cad2b5c113902eea3b7591141f	501241191	FS FS.2025	532	\N	Drogaria da Ponte Lda	2025-01-13 00:00:00	44.81	10.31	55.12	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.849
cmng38ysv007trkt4donh30l9	bdd82fbe6e8123507e46db461060bfe3d9265e4ebde3eae867647a719ac6b852	502201657	FR FRG.2025	483	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-12 00:00:00	44.23	10.17	54.40	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.855
cmng38yta007vrkt4t49yumcv	3e309a760c2e11c005e4047d511282e022af0c96efe105145256a057d50adac0	515370193	G 23	3287	\N	Restaurante Ferro & Fogo Lda	2025-01-24 00:00:00	76.77	9.98	86.75	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.87
cmng38ytl007wrkt4t09rki8v	9e8aeb254d23c2eca8631bee6a1904d1de29a79aca391434679548142bb21618	505694751	FS 00002	36266	\N	Gestnegocios Investimentos Hoteleiros Lda	2025-01-11 00:00:00	68.15	9.92	78.07	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.881
cmng38ytu007xrkt4pnx4knz5	2de1142b0a791d74214b3c82750f95b65d386ea6cdee8bc566854a56467cde69	516676180	FT FT25	039477	\N	Ibelectra Mercados Lda	2025-04-29 00:00:00	67.03	9.81	76.84	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.89
cmng38yu5007yrkt48j5tr54k	689f520cdf3a3ab4a18a267b97b73ef00d0e38cb358e39e089b5ab57f0955aac	506848558	FT 20250335401	002370	\N	Bcm Bricolage S A	2025-05-30 00:00:00	41.46	9.53	50.99	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.901
cmng38yuj0080rkt4wwctw700	117fdc89df93ecf34bd8a86da73c70c52e8f027284ff20b48c3314dd60572f1e	502201657	FR FRG.2025	559	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-30 00:00:00	40.94	9.42	50.36	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.915
cmng38yux0082rkt4dhu8wptp	471f8182a12ba98820c43284c1f0632927b98a8563c9730523a2096ec6d765ae	516527835	FS 009312001	310253	\N	Auchan Energy S A	2025-06-14 00:00:00	40.65	9.35	50.00	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.929
cmng38yv30083rkt4bior6dei	8f84b62664665bafd91dbfed0ba0973a8e65e937ba07b2ba45c0f1ab259b46c8	516527835	FS 009311001	302784	\N	Auchan Energy S A	2025-05-22 00:00:00	40.65	9.35	50.00	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.935
cmng38yv90084rkt4xclfuw61	5294537f9b64110f99d6ee350d0561403f6e1a967c7ff82717452b671ae3607a	516222201	FT FT.FC25	919426	\N	Digi Portugal, Lda	2025-07-13 00:00:00	39.53	9.09	48.62	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.941
cmng38yvn0086rkt4x00g5h18	b248e49463bdcd14be87a0622a5f92c92cdf418cfa24006be8fce3600e128f72	501689010	FR 13	49445	\N	J Correia e Filhos Lda	2025-03-15 00:00:00	39.45	9.07	48.52	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.955
cmng38yvx0087rkt4ggdnlk76	a9c8b9c97cba1c8ab98348f1573b287b2223f4264d4ebd6844963aa3405b60c8	506848558	FT 20250335601	001056	\N	Bcm Bricolage S A	2025-03-22 00:00:00	38.75	8.91	47.66	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.965
cmng38ywa0089rkt42u2woq9k	b518a9636c17faeea5789fc6d8239615872b0a86a5207fd58100967df7349ba4	516676180	FT FT25	040926	\N	Ibelectra Mercados Lda	2025-04-29 00:00:00	62.77	8.83	71.60	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.978
cmng38ywi008arkt4zfrswdup	002a0f7ee825339e52cd31982cbe9f8e001d31be9336d6ea57a622a476ea7b85	514606525	FTS 2	10158	\N	Magalhães & Antunes Lda	2025-03-19 00:00:00	64.17	8.73	72.90	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.986
cmng38ywq008brkt409flg322	43db9a4378601e434c02a390f590b869ab56da29a3e8a658f7179bbb2ff15139	516676180	NC NC25	001365	\N	Ibelectra Mercados Lda	2025-07-08 00:00:00	-60.89	-8.57	-69.46	Nota de crédito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:19.994
cmng38ywy008crkt42wu9rbb4	1182b7ae7e1c62ec2b65bbaea386e99c6a585c00c9fafe67c60188e2bf716627	516676180	FT FT25	054319	\N	Ibelectra Mercados Lda	2025-05-28 00:00:00	60.89	8.57	69.46	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.002
cmng38yx6008drkt4co62kxgm	31c8deaf156aa1153b73e5393ef17c33922dd6fd5e9f2d5fbf339c12c94afc8e	506394107	FS 25005	254	\N	A Floresta de Moscavide II Actividades Hoteleiras Lda	2025-01-16 00:00:00	59.81	8.49	68.30	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.01
cmng38yxd008erkt4zpfllhip	6dd52336f156610b6a58c1043373d43e6cd34dc3ce30398c2ca805a4cf580747	501840877	FR FR.2025	5757	\N	Atila - a Trigueira & Irmao Lda	2025-05-09 00:00:00	36.59	8.42	45.01	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.017
cmng38yxm008frkt4g09fo93r	5293f1a843bfc67474bdc84bd447f29c921d4dbf18d1f2fd84b9a002d6003d50	516676180	FT FT25	008412	\N	Ibelectra Mercados Lda	2025-01-28 00:00:00	65.84	8.27	74.11	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.026
cmng38yxv008grkt4jnwojoek	2fffb0a3426805aa2e6189e5ba86e723d0430a16e185c93806948e5163171925	505993082	NCR 000	1832542	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-27 00:00:00	-175.14	-8.24	-183.38	Nota de crédito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.035
cmng38yy4008hrkt4rjdf6qf4	e40178f5ba2911bdf64b5c2dcb0ed7f7bed428ca7091178b758b1155d2804c01	505993082	FAC 006	61120503	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-23 00:00:00	175.14	8.24	183.38	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.044
cmng38yy9008irkt4ox1wvzit	8f5bfe317a40de5cccd28c8cb935b5d40ee2dcbe39555dc9f5cd1fb483895349	502604751	FT 202593	1134751	\N	Nos Comunicações S A	2025-05-26 00:00:00	34.73	7.99	42.72	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.05
cmng38yyd008jrkt4fa94rewg	20431d52fb91b7c896a1c02d3f457a6960f0b83615e9300dc034c80b72be4dc3	502604751	FT 202593	874598	\N	Nos Comunicações S A	2025-04-24 00:00:00	34.73	7.99	42.72	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.053
cmng38yyk008krkt4ver6ewsf	c5372df8c63f443a2e1be193e2594b1f71cea3e31b464a70484f780cf4039c55	502604751	FT 202593	612277	\N	Nos Comunicações S A	2025-03-25 00:00:00	34.73	7.99	42.72	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.06
cmng38yyp008lrkt49wryu9kh	7876e60eab446aa9c08ab25fc10532bf92cead33609febfa2324f1fb0183712a	502604751	FT 202593	348402	\N	Nos Comunicações S A	2025-02-25 00:00:00	34.73	7.99	42.72	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.065
cmng38yyt008mrkt4smwaz7wp	b6208657baf40555a400f43a2a5a0ad07e2652077aef303cb4104a1af29eeea0	502604751	FT 202593	87013	\N	Nos Comunicações S A	2025-01-24 00:00:00	34.73	7.99	42.72	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.069
cmng38yyy008nrkt4uj6bxnzq	c5c917dac7bcb4dcbca0b80093cac7a3c6be7f27ef7ad11c046320190fad73bb	505993082	FAC 006	61061881	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-02-28 00:00:00	170.06	7.92	177.98	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.074
cmng38yz5008orkt4fhdbkdzk	8ae685b409a5f5538776c578889264b3ba4675c7c628acda4fc156d1a9aa313d	516676180	FT FT25	086996	\N	Ibelectra Mercados Lda	2025-07-29 00:00:00	56.92	7.66	64.58	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.081
cmng38yzc008prkt4lsa3tk9o	040ef3d6d63f5f9885c21a76dfb1bd29c305feacb7a4b62685c184cd652c0977	502604751	FT 202592	1469802	\N	Nos Comunicações S A	2025-05-19 00:00:00	32.91	7.56	40.47	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.088
cmng38yzk008qrkt4obcw49y6	f32af8c9d84fc70903e7f5f2517afc7ab77fa014b2d4cd10d568ef6f1ba8a950	502604751	FT 202592	1169547	\N	Nos Comunicações S A	2025-04-17 00:00:00	32.91	7.56	40.47	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.096
cmng38yzp008rrkt4q9gjzz0z	0789f75d1bfba167bf68f7bd85fe6849c5e9ef5c698d7efce3e4b7ce6a2115ac	502604751	FT 202592	866009	\N	Nos Comunicações S A	2025-03-18 00:00:00	32.91	7.56	40.47	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.101
cmng38yzu008srkt4ixra15lt	7095c0ae22c6833d710b3e111bb186069de1e87706dd4e6a5e720cb5b8206d40	502604751	FT 202592	564850	\N	Nos Comunicações S A	2025-02-18 00:00:00	32.91	7.56	40.47	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.106
cmng38yzz008trkt4xkfpr1wc	017b5a14c4c30b10a7c2e667126529ee2fadff2031a7559320b0c69fff77a746	502604751	FT 202592	262600	\N	Nos Comunicações S A	2025-01-17 00:00:00	32.91	7.56	40.47	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.111
cmng38z04008urkt4xsxpim8c	27cd241108e5f0de3c51c287238db444d26ad51e0074fe12384c44dd5b2a2c9c	516676180	FT FT25	052619	\N	Ibelectra Mercados Lda	2025-05-26 00:00:00	55.91	7.43	63.34	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.116
cmng38z08008vrkt438l1nvm7	98affd6cf513fae534ad328f84780cc3a76e13ac7c063ffbfdf4085cdb7cb121	502201657	FR FRG.2025	594	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-06-06 00:00:00	32.20	7.41	39.61	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.12
cmng38z0g008xrkt4enjg6y8z	ee665520bc40acf31afa14e36caf582e4c7976f8e1d5ec2497e8a79f82f84be0	507206797	FS TVD25	450	\N	Carstuff Artigos Para Carroçarias e Estofos Sociedade Unipessoal Lda	2025-04-29 00:00:00	31.87	7.33	39.20	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.128
cmng38z0l008yrkt4ewh0rztq	77008dfad3f1f1c8d5111fc254bf39ec13ac6ce0c5bdf0b9f4ca998b99107027	506848558	FT 20250335601	001212	\N	Bcm Bricolage S A	2025-04-05 00:00:00	31.67	7.28	38.95	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.133
cmng38z0u0090rkt40qwos3n1	925fd64f66dfc4ff1686d719e66ea4e3acc4751803bd905d49b7ca08b20a7ea4	502201657	FR FRG.2025	482	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-12 00:00:00	31.59	7.27	38.86	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.142
cmng38z130092rkt4c0x2b9mq	d4327ee0b7ed19619db9130bc53edd815e4bdc71452208db1abd41fa93965184	516676180	NC NC25	000419	\N	Ibelectra Mercados Lda	2025-02-28 00:00:00	-43.53	-7.20	-50.73	Nota de crédito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.151
cmng38z170093rkt4lh3sx5jw	2e1a52016fee525b7e65e1176604f3d70f4e7a7ceacbbaf13b813f7e9be41306	516676180	FT FT25	018268	\N	Ibelectra Mercados Lda	2025-02-24 00:00:00	43.53	7.20	50.73	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.155
cmng38z1d0094rkt4n9oqqq6e	bd5b628ea7ceb1fc849fe7a962a55f6f26b89aebca124265ea95d861f64e0cd5	516676180	FT FT25	019204	\N	Ibelectra Mercados Lda	2025-02-28 00:00:00	43.31	7.17	50.48	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.162
cmng38z1l0095rkt4twtc2027	da2f1526ab094ea3e24d32017589abd42a2c12720ecfe5fa0d1afc0f88dbc32e	502828625	FT 012010015594FAAA00000118672025	000003792	\N	Santos da Cunha Logística e Combustíveis, Lda	2025-03-24 00:00:00	30.84	7.09	37.93	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.169
cmng38z1s0096rkt4t5x9td98	72fadaf8fdca61e4a0c823af991b5c3b609e1592360c18b49e77ded9c37182ab	509937772	FR FR2025355	006256	\N	Nasa - Inspecões a Veiculos, S.A.	2025-04-02 00:00:00	29.79	6.85	36.64	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.176
cmng38z1y0097rkt4fvcqdkdr	8f39096723307fac5e076da7d5b5d344f46d3b030c02b6eff9ac67da8eb90e5d	509899382	FS FS25A	2941	\N	Adega Gavina, Lda	2025-06-29 00:00:00	47.09	6.61	53.70	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.182
cmng38z250098rkt4jqc5lwkz	3c9c3df38dc550d77d9300784b765efe84ab287a9f2d23b688855879f6a12123	516676180	FT FT25	006772	\N	Ibelectra Mercados Lda	2025-01-24 00:00:00	59.76	6.30	66.06	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.189
cmng38z2e0099rkt4kevgf209	967185cbf0b2b58f711e638656cc4a628b504623567be6d8ab40f30283fbf77e	513712755	FS 21	90072	\N	Enigma Necessario - Lda	2025-06-21 00:00:00	42.76	6.09	48.85	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.198
cmng38z2n009arkt469ypqluq	d0ef4d14d161bc093e5f55f6eb55b2f28f35ba646cff0314a246282d047c8bb2	514606525	FTN 2	342	\N	Magalhães & Antunes Lda	2025-01-28 00:00:00	46.64	6.06	52.70	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.207
cmng38z2w009brkt4xjnnv9tf	561cf5f9610bd9d3844ca01f8f32a2da31e298c820b9f8ca00d7022e1f783e3d	506848558	FT 20250335201	002334	\N	Bcm Bricolage S A	2025-07-23 00:00:00	26.23	6.03	32.26	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.216
cmng38z39009drkt48v3whz4x	2777539a9c9255ff2f39470f4af1cde30ed7f46fdb01fda23197df5d862b7623	508080436	FS F01	75058	\N	Jormardoce Lda	2025-04-18 00:00:00	25.37	5.83	31.20	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.229
cmng38z3g009erkt40enkko86	1cd0c2cbf955154ebf5b4444d344c9ef0bad609a5e343a67fc0a6158ca7b3ea7	513605533	FR 2025A3	103	\N	Abr Equipamentos Industriais Lda	2025-01-24 00:00:00	24.60	5.66	30.26	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.236
cmng38z3m009frkt4arrwlngw	3fe23d8a7c414755acdda0ae18033aa911e375c736b9e582ceab70395590dd58	516676180	FT FT25	018011	\N	Ibelectra Mercados Lda	2025-02-24 00:00:00	58.61	5.64	64.25	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.242
cmng38z3s009grkt409iffm6a	cc2b814ecc7cdb64adf9cc1c99294a236088fcf7b0373743fa006644f40ee41b	503340855	VD 042800525	000021	\N	Lidl & Companhia	2025-03-06 00:00:00	24.38	5.61	29.99	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.248
cmng38z3x009hrkt40l36mrl2	3c024ef5daf9541febfbf0f77b23008409e6be8b4f431866a08420e479b2dc1b	980245974	FAC 0270312025	0073181720	\N	Endesa Energia S a Sucursal Portugal	2025-04-09 00:00:00	37.41	5.22	42.63	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.253
cmng38z45009irkt4qieq5re4	a5a684fc4f3cb6bb5fed46b1bcb680f99fe861d400ebb0699f5ac0af6178356d	506848558	FT 20250335201	000278	\N	Bcm Bricolage S A	2025-01-25 00:00:00	21.93	5.04	26.97	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.261
cmng38z4f009krkt4cyl4o77d	af0ecd665e82529534a7b02e5a8845c81e9d1be395e4217cdd97274c1e35ce4c	506848558	FT 20250335101	001463	\N	Bcm Bricolage S A	2025-05-30 00:00:00	21.35	4.91	26.26	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.271
cmng38z4o009mrkt4kevnjfqe	f13836fbdbc3ce184b71edde0d941950e7c4d8bffb53f8edc285f45ac3a8c289	516676180	FT FT25	069355	\N	Ibelectra Mercados Lda	2025-06-24 00:00:00	43.86	4.88	48.74	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.28
cmng38z4t009nrkt40ykhh7ln	f59e8cb720b3488b4a0a2ae3a8bf5b5dc7f478df7dccdb58629041c2304187d5	980245974	FAC 0240312025	0061212024	\N	Endesa Energia S a Sucursal Portugal	2025-04-21 00:00:00	26.35	4.87	31.22	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.285
cmng38z4y009orkt4kuv0c8rr	94849c374bd5df5d100d880dd9f20e18423b358adcdbbb6ca2a58bbae00afe2c	980245974	FAC 0240312025	0061091369	\N	Endesa Energia S a Sucursal Portugal	2025-02-18 00:00:00	26.35	4.87	31.22	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.29
cmng38z54009prkt4g5tt1sz4	ff12c654246c6ada7d279b16af7453bc431c925dd2f400b771a9d23d2d249478	510798276	FT 2A2501	372	\N	Momento Salutar - Lda	2025-01-18 00:00:00	35.34	4.86	40.20	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.296
cmng38z5a009qrkt4w38uvm48	f71d0b08e9a8dae9c9f5c2288d07ed958758bf690f44fb68d764e12b19c72adc	980245974	FAC 0250312025	0065295057	\N	Endesa Energia S a Sucursal Portugal	2025-06-08 00:00:00	30.36	4.79	35.15	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.302
cmng38z5f009rrkt4b681ezth	068fa3349820c6e53b1ebdbd84876801bec3281b87b9dc767a79da20194a7bd0	980245974	FAC 0240312025	0061265051	\N	Endesa Energia S a Sucursal Portugal	2025-05-19 00:00:00	26.45	4.76	31.21	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.307
cmng38z5n009srkt4r87t6nrj	61c853362519f87a4ed341cdf8aa2e20c23c0c63abeba52ec8ed9f85257beb64	980245974	FAC 0240312025	0061321617	\N	Endesa Energia S a Sucursal Portugal	2025-06-18 00:00:00	23.86	4.71	28.57	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.315
cmng38z5s009trkt4mv7eryra	ff4db140003158571612a9edc8eff93c44d36209b831a7bd8886f1d46913fceb	980245974	FAC 0260312025	0069240898	\N	Endesa Energia S a Sucursal Portugal	2025-05-08 00:00:00	30.51	4.70	35.21	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.32
cmng38z5z009urkt4vghv238p	954649ef01b740757a5a40ec0a91e6975de44c085ca20fd61473cc197b4c4151	980245974	FAC 0260312025	0069072941	\N	Endesa Energia S a Sucursal Portugal	2025-02-08 00:00:00	28.45	4.67	33.12	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.327
cmng38z66009vrkt4n45wth5s	1994b6dcc03728248d4b4d0873c71386feb7c87557ff2d292abe52d7f76b6806	506848558	FT 20250335101	000114	\N	Bcm Bricolage S A	2025-01-13 00:00:00	20.19	4.64	24.83	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.334
cmng38z6j009xrkt43ni1hfnj	91cde74ad4553861899ac8071a8d2f3b853c13c24f2aee717820047388d7bb38	980245974	FAC 0240312025	0061372790	\N	Endesa Energia S a Sucursal Portugal	2025-07-18 00:00:00	23.63	4.60	28.23	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.347
cmng38z6p009yrkt4n7pn4qvq	80c938cc420cf7b3e8f2e663ad44ea2fe55da4c4b3e82a1ed54d592e140c793c	505993082	FAC 006	61039421	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-01-24 00:00:00	92.86	4.59	97.45	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.353
cmng38z6x009zrkt4a8eteaj7	5eb465590655f435529d13c56689d34b97794524c5e88a2380bcb322de389b73	980245974	FAC 0250312025	0065032056	\N	Endesa Energia S a Sucursal Portugal	2025-01-18 00:00:00	22.09	4.56	26.65	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.361
cmng38z7600a0rkt4chyey4yy	668b5a5170f301f619f352f2eb5c232446779c93562f140161a240320c5fab22	980245974	FAC 0250312025	0065348099	\N	Endesa Energia S a Sucursal Portugal	2025-07-08 00:00:00	26.97	4.49	31.46	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.37
cmng38z7g00a1rkt479sol4ma	358c696332540c16a3d0c31ef2c306f38141456359a11520d7da6cfa621b2193	980245974	FAC 0260312025	0069014076	\N	Endesa Energia S a Sucursal Portugal	2025-01-08 00:00:00	26.31	4.48	30.79	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.38
cmng38z7p00a2rkt43uwf3obz	8bcd048d5e2753c064adc1a878ea88d339864c966932abdf6dc77efca2b46362	516676180	FT FT25	039111	\N	Ibelectra Mercados Lda	2025-04-23 00:00:00	41.57	4.45	46.02	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.389
cmng38z8000a3rkt4piiljgnq	a730a586677f2e6d5cc3f6f308bc2dbe16e6435679d1fc5f2510b6a43aa6c0d8	515079677	FS 1	28731	\N	Plim Lda	2025-04-16 00:00:00	33.66	4.39	38.05	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.4
cmng38z8800a4rkt4vbgt5ata	9547488f0f5d38ed4b69bb0d01bdce2552520578994f1f0adfb5d2aba1e2eca9	502201657	FR FRG.2025	457	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-05-07 00:00:00	18.98	4.37	23.35	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.408
cmng38z8l00a6rkt4ft1r3ozj	e041686599234411d60ade89c7ba6a11fd572fde324dcd4105f3618e1adff544	980245974	FAC 0240312025	0061150096	\N	Endesa Energia S a Sucursal Portugal	2025-03-18 00:00:00	22.05	4.30	26.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.421
cmng38z8w00a7rkt4hfj28jid	de7d017c7e2cbce79d85139231a16d9baff2d906d48500f082209964125c1edd	980245974	FAC 0260312025	0069127719	\N	Endesa Energia S a Sucursal Portugal	2025-03-08 00:00:00	25.05	4.18	29.23	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.432
cmng38z9800a8rkt4vf7dvee5	4251b5c7ed99a520ec05fa71bdb7deae3546073d6fc9659e3e7e5dab4cac8d61	514508884	FR FARLJ.2025	54	\N	Not Guilty - The Right Way, Lda	2025-04-15 00:00:00	18.08	4.16	22.24	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.444
cmng38z9h00a9rkt493fw5grx	3817d93c9c41425f95c69a1f6a79107c168c0affcd0012a6cf368d5af2d8fcec	506848558	FT 20250335701	001547	\N	Bcm Bricolage S A	2025-05-03 00:00:00	17.80	4.09	21.89	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.453
cmng38z9t00abrkt4ccs5hkp1	e249dc551eb6352e9fa8d5bd7a5fc05815a26b172ba9de9c5475c519f8a424a7	505993082	FAC 0210322025	0049019585	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-07-01 00:00:00	92.78	4.05	96.83	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.466
cmng38za100acrkt4w1zifqv7	bf89c1a62d7901b0ed1f7975ff26dcf388fd4b7a8ce228a8d7160b2182bf82ad	516676180	FT FT25	085317	\N	Ibelectra Mercados Lda	2025-07-24 00:00:00	31.42	4.04	35.46	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.473
cmng38za800adrkt4x0by748c	2490551fc2cb74b1083268696790303849e3e34e4246ba9760c41840f7a44f6c	516676180	FT FT25	012678	\N	Ibelectra Mercados Lda	2025-02-10 00:00:00	23.21	4.00	27.21	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.48
cmng38zae00aerkt4dwtxobnu	de3a710f2d23856da421255f2ba1fc9c042c9683597bae4098b6d3eb83b425b3	502201657	FR FRG.2025	97	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-01-25 00:00:00	16.55	3.81	20.36	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.486
cmng38zan00agrkt43gvkzxms	b68be8e5772cccecc33da075370d21a22280891ea97005f79d2e14c9af3ccbaf	513325417	G 1123-23P	143042	\N	Isaura & Lopes - Supermercados Lda	2025-02-03 00:00:00	16.46	3.78	20.24	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.496
cmng38zax00airkt4p01bpzqe	b505011546b68085ab84c7227de1cc2db362e24183610836e12988545b290e44	515674346	FT 6132110001	00065482	\N	Petalshadow Lda	2025-04-19 00:00:00	16.26	3.74	20.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.506
cmng38zb600ajrkt4saccf8aq	d5811258c584da8a672688c083697f9633d65f78b6bad291a670b510616ceb9d	503629995	FS 25NORPT0616P54IS	0002008	\N	Norauto Portugal - Peças e Acessorios Para Automovel Sa	2025-01-24 00:00:00	16.25	3.74	19.99	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.514
cmng38zbb00akrkt4adj2b4wd	92336cd796f15e8b838e3fe68664cfa068830aed02b9c84132f9c79bd8ade307	505993082	FAC 006	61100496	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-04-29 00:00:00	84.58	3.73	88.31	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.519
cmng38zbk00alrkt4ts20rcs4	b43e6b60032eac48b473b1f12b92e0417f51fd09883aab84d754e605180aebe9	507718666	FAC 009	94994430	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-03-27 00:00:00	62.12	3.73	65.85	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.528
cmng38zbr00amrkt4i5j14jad	df1474ca34e1bdff8d2d3d12667b414373097ae397035b3f5abec9bffb5940ac	507718666	FAC 009	95152991	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-05-27 00:00:00	61.53	3.69	65.22	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.535
cmng38zc000anrkt4wmxurrsp	2df9ef96f4484923a3c5a06c747b9ab9dca7d9c6ddeea239e222f7f28c6b0c6f	507718666	FAC 009	94888813	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-02-18 00:00:00	61.33	3.68	65.01	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.544
cmng38zc800aorkt44li6a3it	aa204d76796c36200f77fa4411ab9ec6a6252a5433e783f5eef3003aaa265a8c	501241191	FS FS.2025	2596	\N	Drogaria da Ponte Lda	2025-02-28 00:00:00	15.83	3.64	19.47	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.552
cmng38zcf00aprkt4w0pzbgas	79cc78af64b93496d872958669b6c8361f44541aff824e71a43282963dacc000	514709006	FS 11A2501	1774	\N	Stm - Sabores Tradicionais da Madeira, Lda	2025-04-04 00:00:00	26.22	3.58	29.80	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.559
cmng38zcq00aqrkt4o905zhf1	71b9219a9c99e713442d3df14f52783a8a11e585e55ad1d7c919b2f23264ba54	516676180	FT FT25	010917	\N	Ibelectra Mercados Lda	2025-02-05 00:00:00	17.77	3.54	21.31	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.57
cmng38zcy00arrkt4t8qwb8o6	03be5d81eb37706cdfb123b0ff37ff2ccf1f671ddd382196fa5ba5287eccda71	507718666	FAC 009	95206609	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-06-18 00:00:00	57.27	3.44	60.71	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.578
cmng38zd500asrkt4zz0g08qt	6463464e62886ddd369cf1a15cc47ca8bf599be2dc4f050f117fdd4df7221736	507718666	FAC 009	94834505	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-01-28 00:00:00	56.71	3.42	60.13	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.585
cmng38zdb00atrkt434grlomn	78d2b9c2d2c0b270735d786c3d549e2f589616f780230b2713a82b9202cdb844	507718666	FAC 009	95312069	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-07-24 00:00:00	56.87	3.41	60.28	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.591
cmng38zdh00aurkt4t9l30epi	42e9ed5944c62e17bf2979309921e38f3041a7b8cd9070bfacd7707e4c7e1a06	510450024	FR 003	2415708	\N	Ifthenpay Lda	2025-05-31 00:00:00	14.68	3.38	18.06	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.597
cmng38zdn00awrkt4sakrlz56	736ba407cf94b3972ff9fcc32089c6739721dcfce9aedc905551c323a1b8bcc2	510450024	FR 003	2384075	\N	Ifthenpay Lda	2025-03-31 00:00:00	14.68	3.38	18.06	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.603
cmng38zdv00ayrkt4hdb6f08t	80d0122611df0b023953a6c06a0ebb1865ecccd5790012f6fdfbf3698bd17efe	506848558	FT 20250335701	001198	\N	Bcm Bricolage S A	2025-04-05 00:00:00	14.63	3.36	17.99	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.611
cmng38ze600b0rkt412b7sx9o	19c5f105088323147cd33a6a85ec70fc4f4ecbb39987471f3b99726bbd1fb513	506848558	FT 20250335601	000367	\N	Bcm Bricolage S A	2025-02-01 00:00:00	14.63	3.36	17.99	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.622
cmng38zej00b2rkt4m1omppiu	56fbb290ec560e923907741f67aa21d385678c6c0af12d0a733aefdc96499f76	500109966	FT 2025A1	100	\N	Fatal Fabrica Artigos Cave e Componentes Plasticas Lda	2025-01-23 00:00:00	13.64	3.14	16.78	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.635
cmng38zeq00b3rkt4hwpdq0n2	b22f74553dd2d684e51cd3f200f90f775ee0881c8ec37a17d0dcaa886eac947b	506848558	FT 20250335601	001216	\N	Bcm Bricolage S A	2025-04-05 00:00:00	13.46	3.10	16.56	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.642
cmng38zf300b5rkt4r5mo6joz	5221a12e019237ed73581622cc5dfb25b05ab5555f053065e316d6a3d05a9236	506848558	FS 20250330202	000110	\N	Bcm Bricolage S A	2025-04-03 00:00:00	13.41	3.09	16.50	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.655
cmng38zfe00b7rkt48q6q38yt	b7fc6b53dde3b294ad88d0d830cf86833229f04d99984038e0f77365c72835c9	516676180	FT FT25	076812	\N	Ibelectra Mercados Lda	2025-07-08 00:00:00	19.78	3.08	22.86	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.666
cmng38zfl00b8rkt4nlimjus0	a8dd0e100b0bff1873dbc180afacb8e732d5a6bb98b723261bf4e5323eee9acc	505993082	FAC 006	61081167	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-03-28 00:00:00	69.92	3.06	72.98	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.673
cmng38zfs00b9rkt47cjirova	0c0c95a8fe523e4a94ac2d6e90880a66e423a177f2d6c1399942f3f5105c8f2f	510450024	FR 003	2368679	\N	Ifthenpay Lda	2025-02-28 00:00:00	13.28	3.06	16.34	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.68
cmng38zg300bbrkt4cir5co7d	370c77e7375d1d8f075c0e66e4f6360423b755e39a751f6836e3497786db2bcb	510450024	FR 003	2353388	\N	Ifthenpay Lda	2025-01-31 00:00:00	13.28	3.06	16.34	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.691
cmng38zge00bdrkt4f60yuo0d	bf3c06106c220d3c7e4735055e8cee5037050d565cfd3f3bf435b28ea23b79f9	516676180	FT FT25	052209	\N	Ibelectra Mercados Lda	2025-05-23 00:00:00	33.55	2.91	36.46	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.702
cmng38zgm00berkt424v0bbg9	db7dbff64520db2b15c5d7e34cb84fe92aa1e779b1af32b9bbb01a8b34a79db4	516676180	FT FT25	055782	\N	Ibelectra Mercados Lda	2025-05-30 00:00:00	17.55	2.84	20.39	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.71
cmng38zgv00bfrkt4osk9czbq	080a816957d91a533bb46b5f8380986b22eee6466a3a8b90803ee86a3e30d763	505993082	FAC 006	61057562	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-02-20 00:00:00	58.66	2.79	61.45	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.719
cmng38zh300bgrkt4kkut4rp5	df0896be5ffaa94f6a372abd3e072f7c1cac44290924010b2009103375dcdfdd	513043110	FS 1	48859	\N	Carlos Miguel Carvalho Unipessoal Lda	2025-05-09 00:00:00	20.84	2.76	23.60	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.727
cmng38zh900bhrkt47mjgv26e	1572a95b95eaefc02d0f0f662c2f8b77cb2d99a8e785e2fdd484de154bd9023e	505993082	FAC 006	61120453	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-23 00:00:00	62.37	2.74	65.11	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.733
cmng38zhh00birkt4r92g9067	9fb952aeea51e8e2f0c3e802db1036d6de93981064490d8f6685b5cfebd4e8a2	157242102	FS 2025	522	\N	Joaquim Jorge Pereira da Costa	2025-03-05 00:00:00	11.71	2.69	14.40	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.741
cmng38zhp00bjrkt4eu2c7lk7	3748bca11daffd3a4e8e1bd09fce8c29a5ec56e2494f4b9e94576c8c64061307	507027566	FS0 9	57051	\N	Com Requinte Marisqueira Lda	2025-02-11 00:00:00	19.32	2.63	21.95	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.749
cmng38zhw00bkrkt4taxn62ub	7ad33df014ad2bc2b98fc25c4806eff8e1df500ba17f1070860b9522eb3feb3f	516222201	FT FT.FC25	852799	\N	Digi Portugal, Lda	2025-06-13 00:00:00	11.33	2.61	13.94	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.756
cmng38zia00bmrkt4c5hunhgm	2f79090c35d75fa5543e98c034ef97da9453d2d990121e44fd8f4c00bca71a47	501241191	FS FS.2025	2703	\N	Drogaria da Ponte Lda	2025-03-03 00:00:00	11.23	2.58	13.81	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.77
cmng38zij00bnrkt4hifsypc4	8173a3ee4bfeb5b07af61b9c4dc56b7c8fa78d77e96703b360576a22a81062c5	510450024	FR 003	2399877	\N	Ifthenpay Lda	2025-04-30 00:00:00	11.19	2.57	13.76	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.78
cmng38ziv00bprkt4jqsmkld8	967b2937ae2801a27aaed7bf489b6f3a60c8f683068854c4f42ea5a1666f1650	501241191	FS FS.2025	3547	\N	Drogaria da Ponte Lda	2025-03-20 00:00:00	10.77	2.48	13.25	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.791
cmng38zj300bqrkt4olq9qdsp	8f0d9f6513e39a90ff3715bf830239160197fb2c4f06a3ccad97d3af7b15e649	507718666	FAC 009	95058787	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-04-17 00:00:00	40.82	2.45	43.27	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.799
cmng38zja00brrkt4fash8lkm	3ed35a9a006360ffdae935f987ae198912d949e760250c89a06f839d5249d1ff	501241191	FS FS.2025	2441	\N	Drogaria da Ponte Lda	2025-02-25 00:00:00	10.67	2.45	13.12	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.806
cmng38zjj00bsrkt4ti1fd8gh	fd8834c46053f57e172f46489f6462fbc73ef4b9e1bf8d9fc5cc6661ff04cba4	518657817	FS 25A	00425	\N	Tasc Restauração Unipessoal Lda	2025-04-30 00:00:00	17.70	2.30	20.00	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.815
cmng38zjp00btrkt40nqplwwl	8d5262a64a1275edbf966bcfa096fe19a5328dbae08b48d86877bbee6cc045d0	505993082	FAC 006	61119063	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-22 00:00:00	51.66	2.26	53.92	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.821
cmng38zjy00burkt4p9ku63ar	c19ae365adaa08b0e94f377f71b2b80d7d3724322de934978e21cfd5a9415d0b	221679642	FS SM	0008932	\N	Sandra Margarida de Faria Rodrigues	2025-04-16 00:00:00	14.81	2.14	16.95	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.83
cmng38zk500bvrkt4vnymep61	f58a47099df8d48879d5ab4d45cf1acf8fd4f2f2b74c98c5387776a6c8d2bbd7	511137109	FS 439	4025810	\N	Ibersol Madeira e Açores Restauração Sa	2025-02-15 00:00:00	20.90	2.10	23.00	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.837
cmng38zkc00bwrkt49pdmqq6i	7287341ef9528c8e3d8185359a440eb1249b1a65d03b63cbcfca4ec2acd4000e	505993082	FAC 006	61077807	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-03-24 00:00:00	49.05	2.07	51.12	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.845
cmng38zkk00bxrkt4utfxqcfp	b758127c278f35ce7b3fef821551c2a512fa4d059c385a76b5bb1a5183880c74	516676180	FT FT25	081894	\N	Ibelectra Mercados Lda	2025-07-21 00:00:00	11.01	2.05	13.06	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.852
cmng38zkr00byrkt4ott2upgq	8151a40fdf0f1306d4c9ab0c051e759aae7beac197641fabe3bbbee727558ef7	505993082	FAC 006	61118777	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-22 00:00:00	48.26	2.04	50.30	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.859
cmng38zky00bzrkt40nx6805d	9240ff733a4db8e22b49072913703bbb5694ad3b5fbfdd6a0415d43aef909fe1	514038942	FS 70100142025001	022599	\N	Irmãdona Supermercados, Unipessoal, Lda.	2025-06-06 00:00:00	8.82	2.03	10.85	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.866
cmng38zl500c0rkt4omnpalt7	5bf11f3552310fac77596f4fcf8b0947a4d0f96af82565db2c2b47b51a868eaf	516676180	FT FT25	068901	\N	Ibelectra Mercados Lda	2025-06-24 00:00:00	27.76	2.01	29.77	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.873
cmng38zle00c1rkt4ybucntjw	28dfde0223e9dc9f4627c50a9d825c565639f03a86b67c169cfb04e6ac144e64	505993082	FAC 0210322025	0049013530	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-06-24 00:00:00	46.69	2.01	48.70	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.882
cmng38zll00c2rkt4dsn6z9if	eed43b86bf252707d3c0ba60fdba4c45da04b15d8554089c09571a568e9f3328	505993082	FAC 006	61096659	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-04-21 00:00:00	45.90	1.99	47.89	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.889
cmng38zlw00c3rkt4600aaobc	ec7b75d01d5be2a21f72c935d33d5ed3fe7f43ecadcfd439cb6bab4f15f2462f	502201657	FR FRG.2025	148	\N	Centrocor Comercio Tintas e Ferramentas Lda	2025-02-12 00:00:00	8.51	1.96	10.47	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.9
cmng38zm800c5rkt4p84t6zee	187c6c468cede412b32cbd4f72feac9f032c430e5f45414c8a157a42a7f21106	510450024	FR 003	2431749	\N	Ifthenpay Lda	2025-06-30 00:00:00	8.39	1.93	10.32	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.913
cmng38zmi00c7rkt4bokqm5cx	5b8baf988e22725df3aadd93c86f589bd0ad6e53c3beab1f86d134384e1c8b3e	505993082	FAC 006	61042500	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-01-30 00:00:00	47.82	1.92	49.74	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.922
cmng38zmq00c8rkt4t96n9gqx	bef7e32df5962f8997251acd17939c2adec2053eb6dcfd644cd0c58dd1fc9955	180110047	FR 2025A201	31427	\N	Maria de Lurdes Magalhães da Silva Azevedo Oliveira	2025-05-05 00:00:00	31.87	1.91	33.78	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.93
cmng38zmz00c9rkt40aeh1yzf	72cc3bf57356c3672a13103b298671307c9b85b47dda77da414341666e68bbb2	516676180	FT FT25	010918	\N	Ibelectra Mercados Lda	2025-02-05 00:00:00	13.17	1.91	15.08	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.939
cmng38zn600carkt4638diuah	55fe7417ed7729b4f68ab9e8e947814f325ea0b0bdba65f6ad3f5c56acf59054	505416654	FAC 4990712025	0023440	\N	Ikea Portugal Moveis e Decoração Lda	2025-07-16 00:00:00	13.31	1.89	15.20	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.946
cmng38zne00cbrkt468fq1agd	d6cad6f9a51d48d2f7f3fed38cc45e4298fcb53ca507e85eb33755b1d7a635ff	504661264	FS B17	108581	\N	Bk Portugal, S.A.	2025-03-28 00:00:00	13.52	1.88	15.40	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.954
cmng38znm00ccrkt4jwyctqqn	1dfbeadee21dbf28078f8ba9392713a40ddd94229ce122aca8c67730eb0b2008	505993082	FAC 0210322025	0049013528	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-06-24 00:00:00	43.30	1.80	45.10	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.962
cmng38znt00cdrkt4pi109r79	f3b5c72611e886f40153a8d140112991b00325c055e63588184a1786f59f085a	516676180	FT FT25	012683	\N	Ibelectra Mercados Lda	2025-02-10 00:00:00	14.12	1.73	15.85	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.969
cmng38znx00cerkt4wxtmzurm	2c0c19c0d513654c5e9b1bf515432ffa13089c29429bee3a78d0344175a64378	501139184	N/FTR IND2025	2330	\N	J M M Goncalves Lda	2025-03-13 00:00:00	7.48	1.72	9.20	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.973
cmng38zo400cfrkt4xf0ppxu1	a4b115a07c63fa4793438d191f1903b6b37fb529bbb1755c0066eeb65f37494e	145222136	FT 01P2025	149	\N	Maria da Graça Almeida Vaz	2025-04-23 00:00:00	7.24	1.66	8.90	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.98
cmng38zo900cgrkt4l2ikxv8c	35efc8c0cbe70ae6e683036482d25a52603cd1936af36086cd5a78ba7fdf1445	510450024	FR 003	2447563	\N	Ifthenpay Lda	2025-07-31 00:00:00	6.99	1.61	8.60	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.985
cmng38zoi00cirkt4ssmgb9v6	b73ee15d0152428088b0df2231c75950bbb462f6d02bb8f54de9bb94fd769a7b	505993082	FAC 006	61096806	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-04-21 00:00:00	39.12	1.58	40.70	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:20.994
cmng38zoo00cjrkt4hxulei8e	d8fdba0902571247f86f8253ecd87e2230ae5fea7e40dbac567632338ff9cb68	505993082	FAC 006	61040566	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-01-27 00:00:00	42.03	1.54	43.57	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21
cmng38zos00ckrkt4mw6rmert	aca5fe10d9af200c1a8f71e66a10bf89201ee5cd08f566219f5f4303340d4011	516676180	FT FT25	084717	\N	Ibelectra Mercados Lda	2025-07-23 00:00:00	18.27	1.42	19.69	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.004
cmng38zoz00clrkt4isrwq4j9	19c881b586378bb51c0c1377d1b6a1df26fea5f16f795f63775fac0a3506012a	980245974	NCR 0220312025	0055002513	\N	Endesa Energia S a Sucursal Portugal	2025-05-14 00:00:00	-5.62	-1.39	-7.01	Nota de crédito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.011
cmng38zp400cmrkt4xiegn05b	651359e2f6885d0fe3578d67e1e077842786d9bda013d832ba0c206b030474a1	516676180	FT FT25	065822	\N	Ibelectra Mercados Lda	2025-06-20 00:00:00	7.28	1.34	8.62	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.016
cmng38zpc00cnrkt4bct5pk6q	03bb8f53a91ea3c4db66671809a1f19cf228e0570c75a41a1bb44ad98b022c63	506848558	FT 20250335201	001420	\N	Bcm Bricolage S A	2025-05-03 00:00:00	5.76	1.33	7.09	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.024
cmng38zpm00cprkt4txbow3ib	903d5cd7e5ea66dd8ff5a34ea7b3464d5f0f8b4a19f85ff276c5041f1280450d	503340855	VD 042800225	000016	\N	Lidl & Companhia	2025-04-12 00:00:00	5.71	1.31	7.02	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.034
cmng38zpr00cqrkt438xbk7k7	776b4ab288b3e4afdd772fcbc014329688ca98d7804cab7e57136594457f77a6	516323938	FS SDFS	223463	\N	D Alma - Pastelaria Catering e Restauração Lda	2025-05-09 00:00:00	9.68	1.27	10.95	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.039
cmng38zq100crrkt4yllxdyvq	42ef4ccdbbad54340bf4c5edf38834357868d9b536e0572575707be7b0dc877a	505993082	FAC 006	61077462	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-03-24 00:00:00	35.50	1.24	36.74	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.049
cmng38zq900csrkt4n84qrh4i	7edd3df9f0bfe1fdec6c18f1f09acb05e3467ea56c5013af980eb94e86f84574	505993082	FAC 006	61057826	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-02-20 00:00:00	31.56	1.16	32.72	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.057
cmng38zqk00ctrkt4l4e5k3c5	355a35c57b281a481a1d793e4c78649cca58177f9f81ffcad1160b3063bf1161	515439240	FS DBF1	17787	\N	Requinte Prodigioso Lda	2025-04-19 00:00:00	7.96	1.04	9.00	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.068
cmng38zqu00curkt4rb4f8h2c	f6fcdc65c0c345ebe0d18310b2da083565b4135049df669c6848b8b96a27687d	505993082	FAC 0210322025	0049024738	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-07-08 00:00:00	29.38	0.97	30.35	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.078
cmng38zr500cvrkt4xxds4oj8	3b4dbe6b7fdd9e27978dccd0b6b9453c64d8b1ac47ce14e927d77e1ead23c114	503952230	FT 0180052025060001/001473	JJDWGDNR	\N	Fnac Portugal - Actividades Culturais e Distribuição de Livros, Discos Multimédia e Produtos Técnicos, Sociedade Unipessoal Lda	2025-06-21 00:00:00	15.94	0.96	16.90	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.089
cmng38zre00cwrkt4dy4d6tzb	29024534171f8b5c6d142625ba24e2888fc0980db2212458ee79dd66a58409c5	516222201	FT FT.FC25	128804	\N	Digi Portugal, Lda	2025-02-14 00:00:00	3.88	0.90	4.78	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.098
cmng38zrn00cyrkt43fq6jqfe	fbc982247f02a9b441d80f969e639d0ae32973099f4b1a0dea4b403d5a0c8ea4	506848558	FT 20250105401	002441	\N	Bcm Bricolage S A	2025-06-21 00:00:00	3.80	0.87	4.67	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.107
cmng38zrz00d0rkt4kfuu2acr	2c6f6875b79a488bcc439466211b649371ae6420ee9cba04759ee743fefb8862	501241191	FS FS.2025	2953	\N	Drogaria da Ponte Lda	2025-03-10 00:00:00	3.62	0.83	4.45	Fatura simplificada	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.119
cmng38zs900d1rkt4xwieh95p	9b33478b59a15cb40a449ec0c2eb806617bbef8126dce35554082f1b3aa8240a	516222201	FT FT.FC25	342218	\N	Digi Portugal, Lda	2025-04-11 00:00:00	3.25	0.75	4.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.129
cmng38zsi00d3rkt4gf1431qm	1224ba8fec3df3371a30129c77a5685bd7385ddcc21aa68aaff326758fc9083e	516222201	FT FT.FC25	298982	\N	Digi Portugal, Lda	2025-03-14 00:00:00	3.25	0.75	4.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.138
cmng38zst00d5rkt48lnavqbf	d433b81dcde58d88c0cd088eee61cb2569216fd4cf1bff89ec722b179a537677	516222201	FT FT.FC25	596893	\N	Digi Portugal, Lda	2025-05-14 00:00:00	3.11	0.72	3.83	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.149
cmng38zt600d7rkt4m3xrp4tq	4628377ebce2439d40a885d93bbc25d06b749ef97b8acb598650d056a22a205c	505993082	FAC 006	61102592	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-02 00:00:00	28.52	0.72	29.24	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.162
cmng38zte00d8rkt4ub3sercv	5a1d3f6a824d1a630dbb30ddf081e641460ecbcb65e7ab09a6d67c80ae6ad27a	506848558	FT 20250335701	000288	\N	Bcm Bricolage S A	2025-01-25 00:00:00	3.08	0.71	3.79	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.17
cmng38ztr00darkt4s4jn8og0	c81f0260f0ccb9288a5d75fc065c3250b4e652b766d5537631b1c2af60a4cfe5	506848558	FT 20250335601	001653	\N	Bcm Bricolage S A	2025-05-08 00:00:00	3.00	0.69	3.69	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.183
cmng38zu400dcrkt4mlm2hdma	4ce01ad831685aca3aacf90a112a0025ad748df35e8734479d4933679ac44b1a	506848558	FT 20250335401	000571	\N	Bcm Bricolage S A	2025-02-08 00:00:00	2.67	0.62	3.29	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.196
cmng38zug00derkt4lum2d48t	463a80d519053e0275602dd21e2847e5e57abce7021cf7f1a253dcee0d089258	505993082	FAC 006	61123021	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-27 00:00:00	14.56	0.44	15.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.208
cmng38zup00dfrkt4dwakyms4	16f4e49ab19815eb9d4fbbc4e10ec4473d8f7e434bf7589bc3829539b38445de	506848558	FT 20250335201	000762	\N	Bcm Bricolage S A	2025-03-08 00:00:00	1.26	0.29	1.55	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.217
cmng38zv100dhrkt43xjypcg6	feee01cfadb43dea997d1df4bbdd9a125a3098199226c287414ccdd978770f26	501139184	N/FTR IND2025	4540	\N	J M M Goncalves Lda	2025-05-22 00:00:00	1.22	0.28	1.50	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.229
cmng38zv800dirkt45kg6k5wy	6f37965d776427e9ebd281b8b7ae5de3274f8913a7c816b9e4e07e3413caaf9e	505993082	FAC 0210322025	0049034460	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-07-22 00:00:00	17.77	0.22	17.99	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.236
cmng38zvf00djrkt43nodtrxw	c9880bc3061021fdfafb34bd6b95cf976df930efd8ee98528218019d23dd59e2	505993082	FAC 0210322025	0049034731	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-07-23 00:00:00	5.96	0.18	6.14	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.243
cmng38zvm00dkrkt4zgser4he	e4f6b4c35b3432409071b00a2ccfb44c7a6219f04021bd30f5b3f158a362c035	516222201	FT FT.FC25	84225	\N	Digi Portugal, Lda	2025-01-14 00:00:00	0.37	0.08	0.45	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.251
cmng38zvu00dmrkt45b7zjusd	e69a6c92947dfa91f8bd376dd0e1dffd21cdcf2ac82406fbdccbb4ad516a90af	505993082	FAC 006	61120502	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-05-23 00:00:00	0.79	0.02	0.81	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.259
cmng38zw200dnrkt44yagxdra	ade87a17bd523946367b29463811025861f9a3e45063d9a9207e2fb48ea99be7	505993082	FAC 0210322025	0049034461	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-07-22 00:00:00	14.38	0.01	14.39	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.266
cmng38zwa00dorkt47wz5119m	f8f8a96b565572c93e7fb8401466e777a2f98162a4d8e01bd02627e54b390ddb	502604751	FT 202593	1397558	\N	Nos Comunicações S A	2025-06-24 00:00:00	0.00	0.01	0.01	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.274
cmng38zwi00dprkt4ltqw4r1f	3dd14c974a9011418a36f950bb29987389242678798079a7614733270660e8c4	514280956	FAC 109	1184405817	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-07-24 00:00:00	25.07	0.00	25.07	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.282
cmng38zwq00drrkt4xg9xdhkv	ecd06d0a55b809d12b0f9f05636e417da7a25228679703f60fcfca95d2d4cc5e	518233693	1 2025	21	\N	Tacofrei - Unipessoal Lda	2025-07-17 00:00:00	335.50	0.00	335.50	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.29
cmng38zwx00dsrkt4lk1d2wgg	0adc63ee9fd9dbd2e5aff017e77e7bbde493f87ad5435e357f2368315ef1bd64	513204016	F1 F42C	4203394622	\N	Novo Banco S A	2025-07-05 00:00:00	20.00	0.00	20.80	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.298
cmng38zx300dtrkt4806nuc02	2e5baf732cd11685eaf41707342317ff990b364aa0120dbb77c2bfc415c2d772	514280956	FAC 109	1184301557	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-06-18 00:00:00	26.14	0.00	26.14	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.303
cmng38zxg00dvrkt4kq9jtx5q	944ace97d9f157d682d29fd51feeb9238b8dc4c9bccc3e9acc64fb09c4ef86b5	502604751	FT 202592	1773117	\N	Nos Comunicações S A	2025-06-17 00:00:00	0.00	0.00	0.00	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.316
cmng38zxl00dwrkt44u57s9dg	89472697c578eeb9dd632d14afaed873672a224f598440e9aa8273ece872acda	500077568	EN FEN5	5190081781	\N	Ctt - Correios de Portugal S A	2025-05-30 00:00:00	14.00	0.00	14.00	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.321
cmng38zxu00dxrkt43pnqczvy	2ba0e5f33e1116fa2b40459f5d6f21fdbe40c461731394b5f4e4061e7a3d4911	514280956	FAC 109	1184248945	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-05-27 00:00:00	28.47	0.00	28.47	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.33
cmng38zy200dzrkt43gh7kaog	3b2c852a012a4483bfa335ce8d033fbe48e3652161b9c774cea63fe547e86af2	500077568	EN FEN5	5190077929	\N	Ctt - Correios de Portugal S A	2025-05-22 00:00:00	14.00	0.00	14.00	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.338
cmng38zy800e0rkt4u9t4aza5	0559fb9a797e99c9ff079dd1ce54ae567349cccfb5fcb6b0143d535893b58541	500077568	EN FEN5	5190078401	\N	Ctt - Correios de Portugal S A	2025-05-22 00:00:00	14.00	0.00	14.00	Fatura-recibo	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.344
cmng38zyf00e1rkt4emxzs6yy	00940f088169f9296f4b6f4e09ad4c7a11b0c33d82af08f19913b92193654307	514280956	FAC 109	1184156315	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-04-17 00:00:00	18.44	0.00	18.44	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.351
cmng38zyn00e3rkt4gyz13gfb	e7845eced564de390c76e9043137fa51f1e5321c658379790f7e47ca752da3bd	239413105	FT ATSIRE01FT	48	\N	Pedro Luis Maia Barros	2025-04-14 00:00:00	934.80	0.00	934.80	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.359
cmng38zyw00e4rkt4m3426ga7	4ca729441fd668b3913e8f256bc5349d4e8fa314401faa1ef56e49c16a518d52	513204016	F1 F42C	4201794808	\N	Novo Banco S A	2025-04-11 00:00:00	12.20	0.00	12.69	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.368
cmng38zz100e5rkt4afvrrfx9	08999cc3531be13487e4063b2c1156a71f3d6ce2a598b3134352d8fa0d9aa7c9	514280956	FAC 109	1184092735	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-03-27 00:00:00	30.08	0.00	30.08	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.373
cmng38zze00e7rkt4viofk9g6	382426b6a407ec21866330eed2b8eb9b784efc60dfccb39a83ab0ce853537e43	505993082	NDB 000	1823647	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-03-25 00:00:00	91.93	0.00	91.93	Nota de débito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.386
cmng38zzl00e8rkt40fhv7f8y	a4fdcd3bce021eeeef5f5faa99b06d0bce3851408c6f4cbb73f5d5846c07bdb6	513204016	F1 F42C	4200954053	\N	Novo Banco S A	2025-02-19 00:00:00	0.54	0.00	0.56	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.393
cmng38zzu00e9rkt4pitj99qw	c6884fb667ee40bd6c84cf5e30056cba09a1484b9e617d5892b226b370c296ee	514280956	FAC 109	1183988659	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-02-18 00:00:00	27.93	0.00	27.93	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.402
cmng3900600ebrkt4rj1y45se	97229a9bc8ad2eeb59b04dd46c1d69f71a5471e5fcd84211b0bf288c1b0f8857	514280956	FAC 109	1183935283	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-01-28 00:00:00	25.88	0.00	25.88	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.414
cmng3900f00edrkt47ltkkweo	3b007b602d97255e22e5670fb6ddc59b7318ecc9571a4ccc2cb62fdba455cf1e	239413105	FT ATSIRE01FT	26	\N	Pedro Luis Maia Barros	2025-01-22 00:00:00	393.60	0.00	393.60	Fatura	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.423
cmng3900o00eerkt4zdn85nz9	45be8dc2c44fbdc6660382e0951417bd6f5c5971b2b8b80cdaac46c14ab8b2f6	505993082	NDB 000	1813949	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-01-20 00:00:00	0.63	0.00	0.63	Nota de débito	cmng38y0r003trkt4np4hq3pa	2026-04-01 13:35:21.432
cmnhoycd40116rkt4tiel0rcj	b93fb10ec0a2b63f521895beddcc105d8865d3f481bbef5e7edcb5b8f8f9e61b	509836593	FACT SEC120	435	\N	Maria Manuela Barros Unipessoal Lda	2020-12-14 00:00:00	208.96	48.06	257.02	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.944
cmnhoycda0117rkt499ax48eu	005e95730338ceb425e1f8de9a42ab309a16cf041d71fef9b24afc9b25ee6740	503630330	FT BPS007	005056	\N	Worten - Equipamentos Para o Lar S A	2020-08-07 00:00:00	162.59	37.40	199.99	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.95
cmnhoycdl0119rkt4iwjvq4zu	057d915332db61238289f058a27158f696fbb65c9763ee042507a098941e2ca4	505416654	DEV 00903220200089	186	\N	Ikea Portugal Moveis e Decoração Lda	2020-07-21 00:00:00	-162.71	-37.29	-200.00	Nota de crédito	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.961
cmnhoycdr011arkt4d10oqjsw	0fda2f6341c3e9f9d057e32fe1610739290b437ff7ba5c2c94ccefbeb3474471	506848558	FT 202003304	006358	\N	Bcm Bricolage S A	2020-10-27 00:00:00	140.10	32.22	172.32	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.967
cmnhoyce1011crkt4xsz1sncz	176524297df502af773db36d588553eab76b300b6b354c51ab9fdc3600497a0e	503630330	FT AUM009	004424	\N	Worten - Equipamentos Para o Lar S A	2020-08-05 00:00:00	130.07	29.92	159.99	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.977
cmnhoyced011erkt4nbgaax5i	1728ad663aa4e3c3acee754699f46cce2bd80728da04f75be3b30538bb697c4a	502022892	FT 0	031808	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2020-12-28 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.989
cmnhoycel011grkt49yzxdxdh	b10e64b9125c93661fc1f85a9d12add96cc32aa2da56f01768ab1cb448ccf938	502022892	FT 0	031502	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2020-11-24 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:41.997
cmnhoycez011irkt4ftiusl2s	9610792197dad57da4fa672b150dba2d715f11d842357a015c4f0b7b2645cb63	502022892	FT 0	031248	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2020-10-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.012
cmnhoycgt011krkt47g7cio2q	31d2002353d8aa720fcc70d5e815c68ca211314ff0d670542f5632a8c54b3894	502022892	FT 0	030942	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2020-09-30 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.077
cmnhoycha011mrkt4712xfbtq	fd13242076105960818b1805eb10d1f4ab3334ad9d34af59a9836f7a5753da9c	502022892	FT 0	030667	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2020-08-31 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.094
cmnhoychq011orkt4hr9gat8n	80b37f595009a8a9ede1e08d53c1ef9c737d48af10eae1546c7a421de51a27ad	502022892	FT 0	030569	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2020-08-13 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.11
cmnhoyci0011qrkt4wz34bsct	5e9689a6a2d75c81f4c6e244f82e1e5a5919326f95cf9ede5506ce4ef6ce1765	503630330	FS AUM003	062886	\N	Worten - Equipamentos Para o Lar S A	2020-10-29 00:00:00	62.59	14.39	76.98	Fatura simplificada	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.12
cmnhoycic011srkt4waiher0e	abf51310eb7a97b77636ca194f515ae307a7ca30a0ee2c82f104daeaaf514838	503630330	FS AUM003	062619	\N	Worten - Equipamentos Para o Lar S A	2020-10-27 00:00:00	56.89	13.09	69.98	Fatura simplificada	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.132
cmnhoycin011urkt47huga2tu	44e0b222f426f1873dc5b6d80a2dc00a1e99bc7a82048d7f2f1c984f6385a0af	505993082	NCR 000	1618741	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-09-01 00:00:00	-208.59	-10.28	-218.87	Nota de crédito	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.143
cmnhoycix011vrkt4ufp67fi3	6cacb0df4eb9fa910f7d48f45a1dad0011847032a1b1071a12bfbd611466b835	505993082	FAC 003	31854789	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-08-24 00:00:00	208.59	10.28	218.87	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.153
cmnhoycj1011wrkt4mitqejsd	a266e980866a2748da3a06a0a67a3a8736d37902114ab505da4430b3cb48c55b	500268886	FT FT20001	204	\N	Coelima - Industrias Texteis S A	2020-10-27 00:00:00	37.48	8.61	46.09	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.157
cmnhoycj7011xrkt41vtjxp2o	85720b4c5648a37f8b1a63035eba19be480db199668b44c6589aea17aaf41a76	503340855	VD 042801320	000754	\N	Lidl & Companhia	2020-12-09 00:00:00	36.08	8.30	44.38	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.163
cmnhoycjo011yrkt4jtwncj5y	7a85b646203b0aa139979216f83ab88fd061f91ee13f3e4c6eb46d1363bcb6ed	502604751	FT 202093	1943042	\N	Nos Comunicações S A	2020-12-23 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.18
cmnhoycju011zrkt4yg9o1f83	86cea8d35c4e0bd030eeceb10b3501b70cfc9a3fbc5676d391e3bc885c95ea7f	505416654	DEV 49903320200033	959	\N	Ikea Portugal Moveis e Decoração Lda	2020-11-07 00:00:00	-28.45	-6.55	-35.00	Nota de crédito	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.186
cmnhoyck40120rkt4qvagaqht	b0e0aa58cb5303b66cb31f27b90a83efc91b2046510ecf3d71ed91865992c066	505416654	FAC 49905420200015	542	\N	Ikea Portugal Moveis e Decoração Lda	2020-11-07 00:00:00	26.42	6.07	32.49	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.196
cmnhoycke0121rkt4wwapiruj	642299b2b6c211b7431b925d92ad1e11c2ff73a245b51bcb858ed992406ee7c8	502604751	FT 202093	1764070	\N	Nos Comunicações S A	2020-11-26 00:00:00	23.28	5.36	28.64	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.206
cmnhoyckl0122rkt4f9muazsh	61d4257269fdb8de779a926f34c34748d40177c0d16bef79a00a959d75445925	507082907	13 815	2005026056	\N	Pc Diga Lda	2020-10-09 00:00:00	21.06	4.84	25.90	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.213
cmnhoyckx0123rkt476j2b99w	7a8c1699199dce2d00b88e23c875f55ff873022923d36d7eabf095d3ee82b9d6	513204016	F9 1	5800137965	\N	Novo Banco S A	2020-11-05 00:00:00	18.00	4.14	22.14	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.225
cmnhoycl30124rkt4zbobcz5n	cb3731468cf2e04180f1a3ba98e9c27fbdece5ad47e35740df3d915fdbd23bf0	515023264	FATS D20	5301	\N	Drogarias Pevidem Lda	2020-10-09 00:00:00	15.04	3.46	18.50	Fatura simplificada	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.231
cmnhoycll0125rkt4inq9x964	4da30da63c09f942c62d36ee1a1cbb85db48f4d6137639144664b283e90c02f7	505416654	FAC 49903420200005	477	\N	Ikea Portugal Moveis e Decoração Lda	2020-10-23 00:00:00	13.81	3.18	16.99	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.249
cmnhoyclu0126rkt4o09qbexh	1ce5458e9beab2ab7f2742a0386054f2d95d0d5a3118cd7728f70e3f1528e774	503789372	FAC 1303202	0003557	\N	Staples Portugal - Equipamento de Escritorio S A	2020-06-18 00:00:00	10.49	2.41	12.90	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.258
cmnhoycm00127rkt4at7mvahy	39c8f8281eb10a612f5c169a1a52c8e5a561da0b420b9d15347d4a8b57233600	513204016	F9 1	5800159190	\N	Novo Banco S A	2020-12-07 00:00:00	9.00	2.07	11.07	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.264
cmnhoycm40128rkt4egkdsh3x	9c62bf2808c07727b1eefff9970800608d317e477bac40da9b66a01d41b27d9f	513204016	F9 1	5800130024	\N	Novo Banco S A	2020-10-06 00:00:00	9.00	2.07	11.07	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.268
cmnhoycmb0129rkt4mbruzady	d608ce6913499a47e11bbc4f3f88f60f66d59e37c497a52fbfa340316f67c838	505993082	FAC 003	31894755	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-11-20 00:00:00	30.17	1.11	31.28	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.275
cmnhoycmj012arkt4etujktdn	ff04e038f184990118c15de573c0d13e96cce9ed438547b17afc0943fc4e07c0	505993082	FAC 005	51908367	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-12-24 00:00:00	26.58	0.92	27.50	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.283
cmnhoycmq012brkt4yg7w2gny	db249f6abb88a393c825e201ce1ee429b685252a6464e7c865c9fef79fc3fe63	505993082	FAC 003	31859341	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-09-01 00:00:00	28.78	0.91	29.69	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.29
cmnhoycmv012crkt4w3baxe7r	73c98c9106fca17091bf5241a4b7f685c1af544380f0e2757d3aa2cd4cead8e7	505993082	FAC 004	41882292	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-10-26 00:00:00	22.97	0.74	23.71	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.295
cmng3betw00lcrkt49wq4xbib	7e7e37de773fd979ad1287e32f228032517ab4cc2bd0818f77dfe3f21738f9b9	505416654	FAE 58.2025.FAE.ED2	582519	\N	Ikea Portugal Moveis e Decoração Lda	2025-12-21 00:00:00	1978.49	455.05	2433.54	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:13.94
cmng3beu900ldrkt4d5g575u2	f9abf57e8a091c932f3d132a25cea960ab08d4c629a8bd972d049db6013c4713	205510833	FR ATSIRE01FR	14	\N	Raul Fernando da Costa Oliveira	2025-09-10 00:00:00	1100.00	253.00	1353.00	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:13.953
cmng3beuk00lerkt4il2wciw1	0bb3e73224cf61a000e1ffab3a1422497ede8d2ad3c0eaa2b67a1b2695b2764b	503137413	F FCT	67	\N	Clube Paraiso Hotelaria e Turismo Lda	2025-10-28 00:00:00	1593.75	239.06	1832.81	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:13.964
cmnhoycn1012drkt409h6y124	0ad76409fde26b420731ca7da33e60ca45775e9ec15836646b3faf3b989c883f	509836593	VDIN SEC120	356	\N	Maria Manuela Barros Unipessoal Lda	2020-09-22 00:00:00	3.21	0.74	3.95	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.301
cmng3bf3e00markt4uhov5o28	0a1e6b8b021933afe823476c393dde3f658371939e27fbbce5e12c2eb1463090	502021420	1 2500	000200	\N	Manuel J S Peixoto e Cia Lda	2025-09-18 00:00:00	150.00	34.50	184.50	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.282
cmnhoycn7012erkt4eml1vfn5	7f4e6bc7f28948e002c5da193f7b57fb49ab3b5c36483ce50b1db9f569099e42	505993082	FAC 003	31869219	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-09-22 00:00:00	22.97	0.74	23.71	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.307
cmnhoycnc012frkt4r4b2g1yc	4c1d03646cba52e02de99efcee3d0ce4232aa3d60fedd5d93958c3f961f62271	513204016	F0 1	4100996612	\N	Novo Banco S A	2020-12-04 00:00:00	14.91	0.00	15.51	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.312
cmnhoycnj012grkt45zgapbf0	7ddf5ad8524e8eb9bb6725edfd894eefe4dd3e632032b8a78d722e11d40bec1c	507432444	FT20 20	93	\N	Sampulau Lda	2020-11-26 00:00:00	847.50	0.00	847.50	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.319
cmnhoycnq012hrkt4m6pt3ccc	073f7722d67867ba665b7471d1d392094c6d628941b31499393754c58c25812c	502604751	FT 202033	42742	\N	Nos Comunicações S A	2020-11-02 00:00:00	0.00	0.00	0.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.326
cmnhoycnu012irkt4ip4z5w26	44310be1aa7ca09ce36381ca61ab84b5183ce561048923b8214328357a4e4f1d	507432444	FT20 20	86	\N	Sampulau Lda	2020-10-30 00:00:00	60.75	0.00	60.75	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.33
cmnhoycnz012jrkt46hu7sam8	35eedc38010d581f309d71160e09f5c231e0bb4a5a268ba77bc9fb7efe42dc12	507432444	FT20 20	82	\N	Sampulau Lda	2020-10-30 00:00:00	3479.00	0.00	3479.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.335
cmnhoyco6012krkt4v7loz2yc	8f4f5c5849fd4fb2717d42dc0c3a0d49dcaf39afe95294f73d6ebbffdc7976b8	505816105	FACT SEC120	113	\N	Manuel F Campos Unipessoal Lda	2020-10-26 00:00:00	30.00	0.00	30.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.342
cmnhoycoc012lrkt4ze0417tz	478aa26b35fcb693aae15881ea47d222114daac06f85cd7677a33433e822365a	514230509	FAC 117	128	\N	Queiros Azevedo Unipessoal Lda	2020-10-20 00:00:00	7310.00	0.00	7310.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.348
cmnhoycok012mrkt45k89oiuo	7a60b8c9d3bf0dc79e8394ea41611459a30558c5f0f342e4a07f79358db3a290	510170617	FT M	36	\N	Climafama Unipessoal Lda	2020-10-17 00:00:00	3179.43	0.00	3179.43	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.356
cmnhoycop012nrkt4ll93azwc	59dab15c9cac08ae998c0a10039d8834bd34f19be50b78caa3e63466aa7e061c	507432444	FT20 20	73	\N	Sampulau Lda	2020-09-15 00:00:00	375.00	0.00	375.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.362
cmnhoycov012orkt4lgvcc6ig	729fa201e35a0ec4f2df429f683307fc5193521567c80e0cf8e099629bcf9246	507432444	FT20 20	71	\N	Sampulau Lda	2020-09-15 00:00:00	4000.00	0.00	4000.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.367
cmnhoycp2012prkt4xiwehdm2	f68f1c7b5640b9bba6dd1c7116a25d8cebd802c8d23b2827a91612451b8e42ae	510170617	FT M	26	\N	Climafama Unipessoal Lda	2020-09-08 00:00:00	3730.00	0.00	3730.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.374
cmnhoycpb012qrkt4hc5bqd3y	1ac78b4e1f209a6b5471453df57ebf4288520bd9057c1cddf422dfae7b7285ff	505816105	FACT SEC120	81	\N	Manuel F Campos Unipessoal Lda	2020-08-04 00:00:00	590.00	0.00	590.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.383
cmnhoycpj012rrkt41c2tos9b	153fddf5aba89029390c037a7d8badcaec783e4c4e289ba1eda8cd1a44262967	507432444	FT20 20	60	\N	Sampulau Lda	2020-07-29 00:00:00	4986.00	0.00	4986.00	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.391
cmnhoycpp012srkt4kqbmrs0m	397b5a5b68fe8fcdf7317bdfa9dd9f6f3a1f00adc317e901298c4d06f8f3d43d	513204016	F1 1	4202532903	\N	Novo Banco S A	2020-07-25 00:00:00	15.00	0.00	15.60	Fatura	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.397
cmnhoycpv012trkt415vov636	ce6d0cd01746bc4233117ef81b66317ab19a82cc4415b2af11920cf3618fb7b0	505993082	NDB 000	1616811	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2020-07-22 00:00:00	86.65	0.00	86.65	Nota de débito	cmnhoyc72010rrkt4ib8yu53b	2026-04-02 16:30:42.403
cmnhoyhc8012vrkt4ujp9bc63	5299b9b16fafafbd969076737bd2d8387914dd6d63ef7ecfe799d92a21b97087	503000000	FACTC 121	376	\N	A M Industria de Colchões Lda	2021-07-12 00:00:00	768.73	176.81	945.54	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.392
cmnhoyhck012wrkt4lvwoi713	387bf650b8499e6575ece074ea5eb01f0d54bbb5c1e42a24a19632760df4acb1	500239169	FR BLA	16955	\N	Salvor Soc Investimento Hoteleiro S A	2021-08-30 00:00:00	1576.31	125.60	1701.91	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.404
cmnhoyhcr012xrkt4mohfssl2	d3328fad8a489b583476472c35c1904340be6ff1de4fb554df560e84ec934694	505416654	FAC 49900220210181	057	\N	Ikea Portugal Moveis e Decoração Lda	2021-09-17 00:00:00	391.72	90.08	481.80	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.412
cmnhoyhd0012yrkt4vj6wpmfc	d4f1cd114509fc2e53777238d35db3a75f96244b5eddca9a8fa8ad914af705b0	212394894	FT 2021	88	\N	Carlos Manuel de Sousa Abreu	2021-11-15 00:00:00	340.00	78.20	418.20	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.42
cmnhoyhd8012zrkt44vetia7v	700a6c026fb0959f88219d92b8d6f5c86f5b386814e96b20aca0231ed07e1cf2	503000000	FACTC 121	377	\N	A M Industria de Colchões Lda	2021-07-12 00:00:00	332.00	76.36	408.36	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.428
cmnhoyhdg0130rkt49jwr2th7	8aa5b38f2d6b4bcc25a092333c8d5710d1e3ccbfbb7f94d8ffcdff9271f4f889	503000000	NCRA 121	18	\N	A M Industria de Colchões Lda	2021-07-12 00:00:00	-330.22	-75.95	-406.17	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.436
cmnhoyhdn0131rkt4gmtsdesr	ac65fca7c56294172030f03330c623cb2464b8a57bf21396ac6b03218bdd93db	503000000	FTAD 121	11	\N	A M Industria de Colchões Lda	2021-06-15 00:00:00	330.22	75.95	406.17	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.443
cmnhoyhdu0132rkt40qrgaxh5	576bb0e316da40853fc6d0861d4e44b52fbce90da72d8b819a4677d3af294f8e	506848558	FT 202100214	000751	\N	Bcm Bricolage S A	2021-10-17 00:00:00	245.41	56.45	301.86	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.451
cmng3beuz00lgrkt4rbfmu2qw	d8f41dd688edb2d8688af645b1bac0021666812cdbaf2e96fc6c4152cf676d76	504984810	FR 2025A3	1064	\N	Saniestilo - Materiais de Construção Lda	2025-12-05 00:00:00	883.71	203.25	1086.96	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:13.979
cmng3bevr00lhrkt4u26dtzkr	ed064a445c68f77f27ff8fb11da16212ac4d5dc0e7a47d1edda4756a05a09424	503137413	F FCTR	376	\N	Clube Paraiso Hotelaria e Turismo Lda	2025-08-06 00:00:00	1088.76	161.87	1250.63	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.007
cmng3bew000lirkt4p3ie7kj4	c0f71e612e60b38f30498635f2a8dafed70f4f926a67dd720b1722638f4549df	505993058	FR V502.03	25027354	\N	Robert Mauser, Lda	2025-09-03 00:00:00	604.35	139.00	743.35	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.016
cmng3bewa00ljrkt40b4v0kmt	1692fb0a86234f07822ac169f63a720909857f301a6e1a850a7d5c66aae1591d	505993058	FT V201.03	25126619	\N	Robert Mauser, Lda	2025-11-28 00:00:00	588.37	135.33	723.70	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.026
cmng3bewj00lkrkt4u61bhtih	6cd4e8f10bc2b10f1f99505c975902f570f104f126de1c6b6bf671b41757c73e	503137413	F FCT	57	\N	Clube Paraiso Hotelaria e Turismo Lda	2025-10-03 00:00:00	862.50	129.38	991.88	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.035
cmnhoyheg0134rkt43f3bwggl	23fbc2a1d36a0c709954d992232015dfb19471997874bb85218a14bbe62e180b	506848558	NC 202100214	000312	\N	Bcm Bricolage S A	2021-10-17 00:00:00	-245.41	-56.45	-301.86	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.472
cmnhoyhes0136rkt466ooe3np	d8567b652b5d53ecd8d6f25e0802559339014c496993df71e4ad08ccc6c32d7a	506848558	FT 202100219	001646	\N	Bcm Bricolage S A	2021-10-16 00:00:00	245.41	56.45	301.86	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.484
cmnhoyhf60138rkt4uh0ifmmg	0b19729de9b6650f4e564a4ba53b2101041c826b73fd03eedb41924c602f5ce5	506848558	FT 202101106	004181	\N	Bcm Bricolage S A	2021-05-28 00:00:00	208.14	47.87	256.01	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.498
cmnhoyhfl013arkt4wjky7fao	816c2bbb6b227b9c33e53e141fb7bd166d490f1cfe6455f7773e8dc1c6006ac3	509887945	FR 2021A11	169	\N	O Jardim de Pevidem Lda	2021-07-07 00:00:00	178.86	41.14	220.00	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.513
cmnhoyhfu013brkt4ptjy3qux	a43f870c9a3b39136fcc9621647166798c6407a48ac764ea93d5e2b0a793eb03	503044083	FT 2021A1	585	\N	Pondus Investimentos, Unipessoal Lda	2021-05-21 00:00:00	158.00	36.34	194.34	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.522
cmnhoyhg1013crkt45qyve0cx	f37111b726ab58600b7110e5e653ddde03ed836737931e431c2142aacbda7bbc	507857542	FT VNFACR	210202446470	\N	Gold Energy - Comercializadora de Energia, S.A.	2021-12-15 00:00:00	157.89	34.28	192.17	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.529
cmnhoyhgc013drkt4o86gmprb	b905c2cda4780536de96ed90d15c867297efc891eab206476275870cfd7dac43	510888682	FR M	9213	\N	Telesgotos - Desentupimentos Unipessoal Lda	2021-01-29 00:00:00	140.00	32.20	172.20	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.54
cmnhoyhgj013erkt44sxjr1ac	678982dfc677cc90797ee4c0e6c02378c4c7f9454c27b533a82280810d2537f7	504055330	FT 1	17083	\N	Royal Obidos - Promoção e Gestão Imobiliaria e Turistica S A	2021-12-12 00:00:00	483.08	28.92	512.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.547
cmnhoyhgr013frkt42kfee5rv	9d0efa9adc7822592c35b4edfea773055faa61b417ea5daf490cdba5328303c1	503630330	FT AUM003	017018	\N	Worten - Equipamentos Para o Lar S A	2021-09-24 00:00:00	125.37	28.83	154.20	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.555
cmnhoyhhw013hrkt4xtkbwl67	9ac129287b5581f976efa1b905176d5e2716a5b6a1c7b799468aaa4988516a70	505416654	FAC 49908320210009	425	\N	Ikea Portugal Moveis e Decoração Lda	2021-09-21 00:00:00	113.01	25.99	139.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.597
cmnhoyhic013irkt4iamksotr	3e444e522c42f441ef6b826753f818a2887270c76638541992c922552f506ada	507356519	FR 2021	95	\N	Manuel Ribeiro Limpeza de Saneamento Lda	2021-12-17 00:00:00	95.00	21.85	116.85	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.612
cmnhoyhiv013jrkt4ezziftpx	b0fe6d9f1f21cfddd14413adde548899459555b7cc7a3a65dc3e58e641d17178	505416654	FAC 49908120210011	411	\N	Ikea Portugal Moveis e Decoração Lda	2021-09-15 00:00:00	92.69	21.31	114.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.631
cmnhoyhj9013krkt41cjb7n2z	d4141484005697d7170865b1fdec87f699b834bfd6da835e8bac55cae5f6dcce	507857542	FT VNFACR	210202182843	\N	Gold Energy - Comercializadora de Energia, S.A.	2021-11-15 00:00:00	96.45	20.10	116.55	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.645
cmnhoyhjl013lrkt4gzec54f4	d63de2db384f433f4c3dc0207357b0df64ee5cb110c0fc0d9579efc2adae4c29	506848558	FT 202103353	000233	\N	Bcm Bricolage S A	2021-08-19 00:00:00	83.69	19.25	102.94	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.657
cmnhoyhk4013nrkt4lfnq3jns	796f8e0e7b8c4528f79f516e1a196d0527da4a4c4aec347cb26a96dbd70d7ae6	506848558	FT 202103304	007842	\N	Bcm Bricolage S A	2021-09-18 00:00:00	80.24	18.46	98.70	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.676
cmnhoyhl6013prkt431q4ygrq	57b7dcda10ccefbbf685097736f92b2de7694475063d761797677cf1bb5a871f	502022892	FT 0	035478	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-12-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.714
cmnhoyhne013rrkt44gcx6ycz	8c6b360e159d2f8b32a6f7f774745a9bb0f3ba23ac89ff7f3471fbc81fb2a5c3	502022892	FT 0	035175	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-11-26 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.794
cmnhoyhnx013trkt4vgj2e6v5	671a349a4aa08cd627e1d73b895890cba0b864a403013eb78da18dc7b167bcc5	502022892	FT 0	034870	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-10-28 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.813
cmnhoyhod013vrkt4b45x06dm	585bf71882b97c003abf4ee67b8f3150262f69970ee88a0b6510d68ead633b07	502022892	FT 0	034574	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-09-29 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.829
cmnhoyhou013xrkt4awsmb47k	05aa222a54ce6da7554863ac64caa573d7d9f98c8d4db135dd21b9b37adb330c	502022892	FT 0	034280	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-08-30 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.846
cmnhoyhpa013zrkt4ohc56v7e	99c5e9535d1ec72a76c3e85217656b5b96158c6dd6edcc08d35e7d27e75a361a	502022892	FT 0	033990	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-07-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.862
cmnhoyhpq0141rkt4mgf7z96q	bae7d0f4e66c234a7f95358c1baf887927f6ce8ff8c1bdbac43d92b30bfa6767	502022892	FT 0	033685	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-06-28 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.878
cmnhoyhq00143rkt461gdk7o0	bc02291dc0288e6d83f5db9e18e3ffdefa88526b3c7bfd533504d952596eaa62	502022892	FT 0	033383	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-05-25 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.888
cmnhoyhqa0145rkt4egbw1qe7	e2eca5ba027b2ae87633ebc92726d0c7cf48f2183a1596329d1fbbe06b87e0e9	502022892	FT 0	033058	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-04-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.898
cmnhoyhqm0147rkt4m8kwhonf	90412e9bce5a4d0e6769eea3b7f87c04e3dfde58bf1b14524a5fcb47234698f0	502022892	FT 0	032751	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-03-29 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.91
cmnhoyhqv0149rkt4f1s27wjn	729cb5b2d0877484e77a4ad7d12875c0314a74c01c100fdf7ccbc5cea2fb86a9	502022892	FT 0	032410	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-02-24 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.919
cmnhoyhr3014brkt40z57io2v	b7365e2a83b6e0cce1a53abac71bd88b364cf424d0e400c19a5c3d54b76bbb6b	502022892	FT 0	032114	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2021-01-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.927
cmnhoyhrb014drkt4t1nhr4se	7997ec6b4a65b54f23fa4096ae7268cd1e0ac37c92d39bea1a44ecf0a0385f65	503340855	VD 042801221	000002	\N	Lidl & Companhia	2021-03-05 00:00:00	73.16	16.83	89.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.935
cmnhoyhri014erkt4m6pt4l3j	6cf6fd8967ef741a537e420c7e7dc7a8fdba98f975639a1257203535bb208f62	506848558	FT 202103304	007958	\N	Bcm Bricolage S A	2021-09-21 00:00:00	71.24	16.39	87.63	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.942
cmng3bf6600mmrkt4arw8waqy	534fc56238239dd36344e78fa2cfc7ec2e955422842d6128ba5a16296a4a0c90	516676180	FT FT25	160740	\N	Ibelectra Mercados Lda	2025-11-28 00:00:00	129.80	23.96	153.76	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.382
cmng3bf6w00mnrkt4f1lxzcae	ea126c832cf10844d902d732b4512c0acc8125283d1b4cec766d1cc18b9fdf2e	502022892	FT 0	050089	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-10-30 00:00:00	102.50	23.58	126.08	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.408
cmng3bf7g00mqrkt4jjf1pxvw	9aa1991931a63d77aa1eae6a251b2507f85999a971a8c6dfde03a9108102315a	502022892	FT 0	050732	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-12-29 00:00:00	100.00	23.00	123.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.428
cmnhoyhrq014grkt4v7yp7xko	5c51271227a3705353791b9ae65b1149f5fdf131d0d8480fdaf464ee04c0d870	980245974	FAC 0280312021	0077353520	\N	Endesa Energia S a Sucursal Portugal	2021-12-08 00:00:00	73.42	14.98	88.40	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.95
cmnhoyhs0014hrkt4qvjyszpc	a1fe944a1f276eb8674b5222c050b56f76f50a05fc4e41cddafac6cfc2b5d070	503301043	FS 2021	10174	\N	Ferragens e Ferramentas S Gonçalo Lda	2021-09-17 00:00:00	61.57	14.16	75.73	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.96
cmnhoyhsh014irkt4qt9500lx	0ec16e402b834a320732bd685e42a192640c76a114e34b9841c9c6e9ad9aeddf	506848558	FT 202103353	000261	\N	Bcm Bricolage S A	2021-09-18 00:00:00	57.87	13.31	71.18	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.977
cmnhoyhsz014krkt4dmtye1ep	7f27206fb9a28ad3b7c2b621ef484dce0d605a7d099753dc9ef737d83257519d	505416654	FAC 00913420210005	419	\N	Ikea Portugal Moveis e Decoração Lda	2021-12-17 00:00:00	56.90	13.09	69.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:48.995
cmnhoyht8014lrkt48oj4o4dz	28629b1f0f50aaee553ed4353abe2e687d0e5cc28b99e5414e177849c797a2b7	505993082	NCR 000	1657156	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-12-09 00:00:00	-224.36	-11.22	-235.58	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.004
cmnhoyhtw014mrkt4heacgyin	be685b3b22c562cdd8893ff8506945fe2119858667a4820f1dad52d1275c6da3	505993082	FAC 006	60472177	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-12-03 00:00:00	224.36	11.22	235.58	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.028
cmnhoyhuk014nrkt4v9uuw5t9	8aa3b3362f5dbd5d3ab315e64fcb2f6423e581b58824d7bc7551eec012d2c6f6	506848558	FT 202103301	007117	\N	Bcm Bricolage S A	2021-07-02 00:00:00	44.71	10.28	54.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.052
cmnhoyhv2014prkt4x3v6w8g1	ebc83dc15bfe879caa426dd2bb54600c30ab520c46d580d0899892abfc898ae0	513213619	FR Z	29680	\N	Martroia Setubal Sociedade Unipessoal Lda	2021-08-20 00:00:00	70.68	10.02	80.70	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.07
cmnhoyhvj014qrkt46y7y3ooz	e418280df287fb2421f4b227af49e46981941565a69effe3eb6b020c5350c8da	505416654	FAC 49905520210020	918	\N	Ikea Portugal Moveis e Decoração Lda	2021-09-18 00:00:00	40.64	9.35	49.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.087
cmnhoyhwb014rrkt4e0mejpwt	d31acd062da72655883b4a20ff66034c3bfa3e5296c16f48e41cfc5aeae14c38	502161221	FRGRO 2021	21	\N	Maria Fernanda Nogueira e Filhos Lda	2021-03-09 00:00:00	39.43	9.07	48.50	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.115
cmnhoyhyh014srkt4j4zw4pfy	987a61f4b1195f891d639127315220988f8c6edfdc900d09e1a973508c8c7452	502264730	FS 2021	1363	\N	Sanitintas Lda	2021-08-14 00:00:00	39.37	9.06	48.43	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.193
cmnhoyhz3014trkt4v15q6nmp	85a1118e53d890e421f63605e8ebe88653352a6f12832420a8c437b6ea08c313	506848558	FT 202103303	009335	\N	Bcm Bricolage S A	2021-12-13 00:00:00	36.58	8.41	44.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.215
cmnhoyhzv014vrkt49x4j7j5p	a002b066ffa8f0f4dbfb5e1fc933d39f2935a3332885f77f2604273acf42947b	506848558	NC 202103307	000493	\N	Bcm Bricolage S A	2021-01-20 00:00:00	-36.58	-8.41	-44.99	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.243
cmnhoyi0n014xrkt4cor9spcj	a2b6205a878df73a68dabc2862671f1eae369ae21e1502b38ca49a4e706901b2	506848558	FT 202103399	000298	\N	Bcm Bricolage S A	2021-01-19 00:00:00	36.58	8.41	44.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.274
cmnhoyi1g014zrkt4dlzjkrpw	c8f44ce8ff586525c0c4aa1061ebf01de16625d2684f2d4892318d24ba017e24	508148006	FS CITYTEC	110	\N	Jose Antonio Martins Ferreira - Sociedade de Reparações Unipessoal Lda	2021-05-21 00:00:00	36.21	8.33	44.54	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.3
cmnhoyi260150rkt4gx863p9s	0b6622efe7dacfe47dd20dbc50728027369d1006d3963b52542d7e61e8df0a17	505416654	FAC 00913320210001	259	\N	Ikea Portugal Moveis e Decoração Lda	2021-10-04 00:00:00	34.56	7.94	42.50	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.326
cmnhoyi2g0151rkt4w3zekw32	353e9ad748cfec2531e5c743d277fc603a3bbc0ff98b3995e17d1c108340d85b	501241191	FS 2021	9946	\N	Drogaria da Ponte Lda	2021-08-10 00:00:00	34.05	7.83	41.88	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.336
cmnhoyi2w0152rkt4ujv5fetj	8cf8b3a5e6611c6b62856838a985ecce8608f49a3fbad9b8e395b152b4fddd6b	506848558	NC 202103301	027195	\N	Bcm Bricolage S A	2021-11-23 00:00:00	-33.15	-7.63	-40.78	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.352
cmnhoyi3a0154rkt413ngnsot	a46c256f03587cae326c7172413e0108ce8e73d92b60987391a18789aeccbede	506848558	FT 202103305	009661	\N	Bcm Bricolage S A	2021-11-19 00:00:00	33.15	7.63	40.78	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.366
cmnhoyi3r0156rkt4j82cgqlk	79a350d1ff42c37f361392ae95b370116cb8c606005d0ba34eb8f92d93972d3b	505993082	FAC 006	60461754	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-11-03 00:00:00	152.16	7.58	159.74	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.383
cmnhoyi410157rkt4lzivohre	89df65a0a4680150056960d436668458ee90bbd5b0158e7ba40256ea5317145b	506848558	FT 202103303	009068	\N	Bcm Bricolage S A	2021-12-04 00:00:00	32.51	7.48	39.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.393
cmnhoyi4f0159rkt4zmzryeh5	cef646b32407e170f0c33b4bacf12fe290d11b3a558ab615365e4ab8af758cf4	502604751	FT 202193	1995180	\N	Nos Comunicações S A	2021-11-24 00:00:00	32.31	7.44	39.75	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.407
cmnhoyi4m015arkt46dhqdzfz	86e198635e367031830db9127efefb44bb47b3598dba8d5da5d5f9a52297eb32	506848558	NC 202103301	028941	\N	Bcm Bricolage S A	2021-12-13 00:00:00	-31.69	-7.29	-38.98	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.414
cmnhoyi4x015crkt4f193xk3t	b006eabd5974ed4b68c4775cf66ac422684e60810a0eaff8d4edff3b0d849208	506848558	NC 202103301	026371	\N	Bcm Bricolage S A	2021-11-13 00:00:00	-31.69	-7.29	-38.98	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.425
cmng3bexg00lnrkt4f8091ll6	105e1ef5cac31ac1c32c19b5ec51fbc507870b5258e5682b2b7036673194980a	503000000	FACTC 155125	463	\N	A M Industria de Colchões Lda	2025-08-11 00:00:00	447.00	102.81	549.81	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.068
cmng3bey900lorkt41pn6se8f	40ad62aa56f1b8cf94df8b59e88bba165e72d4b01e01eb82ee03763fa3097e01	505816105	FACT 79SEC125	65	\N	Manuel F Campos Unipessoal Lda	2025-09-11 00:00:00	390.00	89.70	479.70	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.097
cmnhoyi56015erkt4jx6zzh0r	87b02c539247d9da16e9b5107877aa5cb5d4789a3bb91541d1c789065ac3d74c	500389217	FT FT21002	19	\N	Mabera - Acabamentos Têxteis S.A.	2021-09-28 00:00:00	31.68	7.29	38.97	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.434
cmng3bf3s00mcrkt4u8hclywo	79e8fdc0467dbfcb20b4154d6460ccbb4bcde9b2b0b7df810d0caf9148aed14a	505416654	DEV 4990372025	0003623	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-18 00:00:00	-141.48	-32.52	-174.00	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.296
cmng3bf4e00mdrkt4l0tjgx9k	eaf4ab95c8db048322c7bbd97921d707f394e2f4173bad81a27f5e07d67ebda4	516676180	FT FT25	174905	\N	Ibelectra Mercados Lda	2025-12-23 00:00:00	156.95	29.50	186.45	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.318
cmng3bf4j00merkt42zy9byo7	4516d3ec92dc7c95e0db876745490406fd555cdb3ef3fb49a761cb19683aa7f0	516676180	FT FT25	177413	\N	Ibelectra Mercados Lda	2025-12-29 00:00:00	147.02	28.10	175.12	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.324
cmnhoyi5d015frkt4tmufr4lz	707ffc2525820995ec04d9d1c95c85368df77cb73bc99ea756a243e8039b8938	502544180	FT 101	029073515	\N	Vodafone Portugal - Comunicações Pessoais S A	2021-12-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.441
cmnhoyi5i015grkt4gs5hoz6x	5e71c2c61f76d7d7780e8971c4ae64ea20eb9d5916dc9a37d1eb23e09b59e3f2	502544180	FT 101	027676965	\N	Vodafone Portugal - Comunicações Pessoais S A	2021-11-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.446
cmnhoyi5o015hrkt49s4oydn2	1d8e19a67bed6d157a734e0647a07f633179d2e27f1e112c37b95b17e05faf84	500389217	FT FT21001	209	\N	Mabera - Acabamentos Têxteis S.A.	2021-09-18 00:00:00	30.85	7.09	37.94	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.452
cmnhoyi5x015irkt4ug061p3s	4abef322ddfd9758020ea85ff9f005999630b718b96ba897f390e20085f3b3e6	502604751	FT 202193	476401	\N	Nos Comunicações S A	2021-03-24 00:00:00	30.21	6.95	37.16	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.462
cmnhoyi63015jrkt46ey7z5fw	2c04e6c83d178c652e3d6c56bceb332235e96d50c7ae42544efcc7f379d72445	503301043	FS 2021	10187	\N	Ferragens e Ferramentas S Gonçalo Lda	2021-09-17 00:00:00	30.15	6.93	37.08	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.467
cmnhoyi68015krkt4ob2gni67	01ad954ee4395b22fa3c9edf18a290d4656d1b8eee5d294b809bca553da501d8	502604751	FT 202193	2202560	\N	Nos Comunicações S A	2021-12-23 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.472
cmnhoyi6e015lrkt452qkkzgn	75ab777d67b466c4f6206e5af9b583465098a796c40d625d5e46165af3e13627	502604751	FT 202193	1813322	\N	Nos Comunicações S A	2021-10-26 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.478
cmnhoyi6i015mrkt4mtba92ao	5045130834a78bf4cd84bd25603c76a3dbdcd214c7d63af3fb45815782736ee6	502604751	FT 202193	1618275	\N	Nos Comunicações S A	2021-09-24 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.482
cmnhoyi6n015nrkt4h4r5af63	b1220c195cbbefa175bc65a75914edda0a121d344243cc4150fdffee80a9f9d9	502604751	FT 202193	1424424	\N	Nos Comunicações S A	2021-08-24 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.487
cmnhoyi6v015orkt4awrf0rn1	60134afefc5204fadd84988adcbbaee1069026bcd53f033276d4a47b5b2dc754	502604751	FT 202193	1230207	\N	Nos Comunicações S A	2021-07-26 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.495
cmnhoyi70015prkt4jva9x652	c60e17a79a1c7aa8af5b912abb67f0d85b81f07ded88572324dfb505f1627b60	502604751	FT 202193	1007730	\N	Nos Comunicações S A	2021-06-24 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.5
cmnhoyi77015qrkt432nndh0p	38e70445d35f837104ea152b8b438df9dcc41bd6e8e07de619395abbcb653cc1	502604751	FT 202193	851503	\N	Nos Comunicações S A	2021-05-25 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.507
cmnhoyi7c015rrkt4d41twm5e	9140190dc1126a3b0069961528d2088e1ed32e84e34dcd962fa05f746613a31f	502604751	FT 202193	662413	\N	Nos Comunicações S A	2021-04-26 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.512
cmnhoyi7f015srkt4aaxouaip	35cf30892843084394d4d62a8935ae5e23936c979c01a95fdd0e6dd11832e044	502604751	FT 202193	271961	\N	Nos Comunicações S A	2021-02-24 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.515
cmnhoyi7m015trkt4ek4s0net	b0200e1d89a26c796f6d24a3c198afc6a746dda0b0122ea84ea7679d68e71426	502604751	FT 202193	100920	\N	Nos Comunicações S A	2021-01-26 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.522
cmnhoyi7t015urkt4ylhpf1s4	66fa719ad42a95bab762e91d41653114b11fcee27fddd69f9af4913d46ca681f	506848558	FT 202100652	003476	\N	Bcm Bricolage S A	2021-10-04 00:00:00	26.82	6.17	32.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.529
cmnhoyi86015wrkt4o1yplyq5	a094e127d8977c0b98514fd3e3ba42ed2efcf453a9c09f57401dcbcf5d9064d4	980245974	FAC 0280312021	0077320539	\N	Endesa Energia S a Sucursal Portugal	2021-11-08 00:00:00	33.79	5.87	39.66	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.542
cmnhoyi8e015xrkt4yc06sim1	55230b1cff70c3a1fdac96b9dee47c59baa9ab3bf9eb37fd832a4af1fffa5af5	506848558	FT 202100804	013263	\N	Bcm Bricolage S A	2021-09-22 00:00:00	25.38	5.84	31.22	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.55
cmnhoyi8q015zrkt4yvsod8qw	a78c7ba5fb8d1018746fbf441a825c00de4b73dee0cbdcec65ce5e49f489d699	505416654	DEV 00903320210098	914	\N	Ikea Portugal Moveis e Decoração Lda	2021-10-04 00:00:00	-24.40	-5.60	-30.00	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.562
cmnhoyi8w0160rkt44ixogk73	dc3a709152916189fdd4ebff596cb397beac7aa3953c199396d3177e0d282b49	506848558	FT 202103304	007403	\N	Bcm Bricolage S A	2021-09-03 00:00:00	23.47	5.40	28.87	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.568
cmnhoyi980162rkt46z1k2lem	254ab421c87e86e0e67acfd5d4eebc67474a19aca5ef41306807a7f3c2e95f32	503274496	ZV 0206	20985	\N	Bolama Supermercados Lda	2021-12-23 00:00:00	20.62	4.74	25.36	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.58
cmnhoyi9e0163rkt4pmolat2c	f5e18a9e00688919c844a21a46d7bd5afe998d2f69375fe8db87c766e4cd40be	500149640	FT 2021A25	1509	\N	Joao Garcia e Cia Lda	2021-06-11 00:00:00	18.35	4.22	22.57	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.586
cmnhoyi9l0164rkt4zpoxvtar	c0829e3678e7d71107dc5a799134dd646c7be12b6817739768a57caab491219f	503340855	VD 042801321	001015	\N	Lidl & Companhia	2021-12-06 00:00:00	16.25	3.74	19.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.593
cmnhoyi9p0165rkt4na1zxbjh	e5af0e87282902842886a2626ad43d1b21669ab4dc73153c24075f62c0d7f3b5	505416654	FAC 00904120210028	678	\N	Ikea Portugal Moveis e Decoração Lda	2021-10-04 00:00:00	16.26	3.74	20.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.597
cmng3beyl00lqrkt4xmqqnv2g	054d7d262a9ffe815ac33d0d2eb8be17bb0e6d50283b327a1f9349a18f8e2b7f	503638471	FR 2025A19	21303	\N	Castro Electronica Lda	2025-10-28 00:00:00	373.97	86.01	459.98	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.109
cmng3beza00lrrkt4a0bimevi	89f884f5f9c290e10cbce629ea9e09faece920f73b89697c24e2a0adf3d65d86	517377870	FR M	981	\N	Legal Factor Lda	2025-09-24 00:00:00	348.44	80.14	428.58	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.134
cmng3bezg00lsrkt43tg2oqch	fa65bd14cd6bea0b99ae58e3391f0ad17bf37bb97e01bba4bdb9257a33f9c9fd	515370193	G 23	4558	\N	Restaurante Ferro & Fogo Lda	2025-12-20 00:00:00	541.96	77.74	619.70	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.14
cmng3bezn00ltrkt4wmhoufyy	b6132bba1954598ec82dabc515f4e855feaa654f9f23515fb4834376024938a8	501689010	FR 13	51435	\N	J Correia e Filhos Lda	2025-09-02 00:00:00	312.47	71.87	384.34	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.147
cmng3bezt00lurkt4h6f46dhj	0a184028b3d9b2fa235ed04f5f023d5c4e59b80776faf4e83c6d89b73657bde2	501293710	FT FA.2025	6822	\N	Jocel Lda	2025-08-11 00:00:00	279.20	64.22	343.42	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.153
cmng3bf0100lvrkt4fxk9hjcr	45e81993d78ff9aeddf151d1fee25d16d6703f9260678a949076d61cb40a851d	502544180	FT 101	102944907	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-11-04 00:00:00	278.58	64.07	342.65	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.161
cmnhoyi9w0166rkt4dcb1hn5p	eccbfa143b2fd72f2c8e43be126b80014c2c3150dd37fde31cc78b59f2a849a0	507667344	FR 2021R	1305	\N	Daportas Automaticas Lda	2021-09-29 00:00:00	15.44	3.55	18.99	Fatura-recibo	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.604
cmnhoyia10167rkt4xbsxnka5	2327722db89833a32f866562f0abf4d36034a96ff535f264fc68f628f7b7d925	500268886	FT FT21001	121	\N	Coelima - Industrias Texteis S A	2021-06-22 00:00:00	15.45	3.55	19.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.609
cmnhoyia60168rkt4wo35opm5	27ce3c08a4b8fcfd09223d9cfb8e40c8ba9a1a413897c6ffa7dae2f7c5e773d2	503301043	FS 2021	10478	\N	Ferragens e Ferramentas S Gonçalo Lda	2021-09-25 00:00:00	15.12	3.48	18.60	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.614
cmnhoyiai0169rkt4ootwkf8w	0ca890388a4a3a2ba8ed5c63d8110b49ae1bf5ec9c7a133d42dca28954197caf	501241191	FS 2021	9947	\N	Drogaria da Ponte Lda	2021-08-10 00:00:00	14.62	3.36	17.98	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.626
cmnhoyiav016arkt45ht0azff	57207fd593b571cdaae0f086c2c2cd46833b7c278ec7f32728179cf4aba73835	501689010	FT 13	33409	\N	J Correia e Filhos Lda	2021-07-02 00:00:00	14.45	3.32	17.77	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.64
cmnhoyib2016brkt406rifiqt	c187e59c2da5a3583c5c4df45eaa77dfbb010de6980257ae6d322efe3fe54b91	505416654	FAC 00904520210013	605	\N	Ikea Portugal Moveis e Decoração Lda	2021-09-25 00:00:00	13.82	3.18	17.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.646
cmnhoyib8016crkt45iqzrpe1	a11f208a43c77d0fe62822a0c4518c191660ee69e30b8a9130034039c529a52a	505993082	FAC 005	51946417	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-03-22 00:00:00	66.12	2.99	69.11	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.652
cmnhoyibg016drkt4l6eq4k8y	503d00a51d7df526655133329648660d6cafbc5e6a231aae79d07cb64b5c2467	502011475	FS AAH029	545393	\N	Modelo Continente Hipermercados S A	2021-09-24 00:00:00	12.25	2.82	15.07	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.66
cmnhoyibm016erkt4r6s3iqym	6ecc0160599512bbc8edc5a80bbc1f82c23d4f88a89adc438d02cb1de56ac9ec	506848558	FT 202103305	006699	\N	Bcm Bricolage S A	2021-08-18 00:00:00	11.83	2.72	14.55	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.666
cmnhoyic2016grkt4lvye7p6i	48b1065a142bb9574a6d11cfd0761603ac51798521d4a210599e2b7d4137fb59	506848558	FT 202103352	000381	\N	Bcm Bricolage S A	2021-08-14 00:00:00	11.18	2.57	13.75	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.682
cmnhoyicf016irkt4wcgo2hug	405d9d4371b9caa035cf58ce5f1895c28b332b5eaad443f57881f347c1706ef5	980245974	FAC 0280312021	0077353521	\N	Endesa Energia S a Sucursal Portugal	2021-12-08 00:00:00	10.18	2.27	12.45	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.695
cmnhoyics016jrkt4je41sy24	ec5995077d88b83d77031b7d0f76e7526068d74d15ba16b44ba9a79cce822446	513204016	F9 1	5800005019	\N	Novo Banco S A	2021-01-05 00:00:00	9.00	2.07	11.07	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.708
cmnhoyid2016krkt4utwihfpc	9fa4e9ffd88e3b069e038965fa8146bc01c8f16eb677403322a3e75b0ec3ab3f	506848558	FT 202103305	007696	\N	Bcm Bricolage S A	2021-09-22 00:00:00	8.43	1.94	10.37	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.718
cmnhoyidi016mrkt41hw11zmw	a3bae4ceedf53a3134a896dc9c4fad469c86aea657cc4baf9c8e66ac8ea11c42	502264730	FS 2021	1343	\N	Sanitintas Lda	2021-08-11 00:00:00	7.92	1.82	9.74	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.735
cmnhoyidu016nrkt440t029bq	517570b95a9786ef1bc225b0a7bd53b1272137f9fb637758344c5b7f7a9dbb2f	513325417	FS SP21	221059	\N	Isaura & Lopes - Supermercados Lda	2021-09-18 00:00:00	6.48	1.49	7.97	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.746
cmnhoyie7016prkt4exq0xhsd	0cc65b6dd5949332064b5868337deb80ac2b19821202af3cf0ff9002b4a97d99	505993082	FAC 005	51960359	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-04-26 00:00:00	37.36	1.49	38.85	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.759
cmnhoyif8016qrkt4gut4lbjw	eef4f93c0f2f432e0f636ef3faf2bf49854d51ba97305a86051b6ffe477ede58	506848558	FT 202103305	009660	\N	Bcm Bricolage S A	2021-11-19 00:00:00	6.08	1.40	7.48	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.796
cmnhoyifh016srkt4szflmoi6	8f31f042951ab583bc17d923a83f8e6e6174ccaa24192e3c460242afd0ab9ef6	506848558	FT 202103306	006048	\N	Bcm Bricolage S A	2021-08-14 00:00:00	6.00	1.38	7.38	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.805
cmnhoyifq016urkt4h5ahqd49	1d00d1f3badca9897a548e35a807d23ce21e8f225611f54560f6c3db3b772691	505993082	NCR 006	60473943	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-12-09 00:00:00	-16.60	-1.33	-17.93	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.814
cmnhoyifu016vrkt4tf77kt5a	5a64d259c8817723ff52f5dde0aaf702764bcbe1db76ce45747ffa8cb3b425a7	506848558	FT 202103353	000224	\N	Bcm Bricolage S A	2021-08-16 00:00:00	5.59	1.28	6.87	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.818
cmnhoyig4016xrkt43yp0ncnl	7662942530f4a275242abd1c3047da5f21ed3781d8eb2f75b443494471c3859d	506848558	FT 202103304	007311	\N	Bcm Bricolage S A	2021-08-31 00:00:00	5.17	1.19	6.36	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.828
cmnhoyigd016zrkt44tu36zd6	345e52db01485d84e3e7934c2fff7077d1b2a9811527f2e46ae405348ef16c61	506848558	FT 202103303	005973	\N	Bcm Bricolage S A	2021-08-11 00:00:00	5.08	1.17	6.25	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.837
cmnhoyign0171rkt41e7ljq2q	f43bada2b43eefbeaf21b8f505098dd075b79dbfd9e9a6a3117398e28ffeb7aa	980245974	FAC 0200312021	0045082730	\N	Endesa Energia S a Sucursal Portugal	2021-11-09 00:00:00	5.27	1.14	6.41	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.847
cmnhoyigu0172rkt4x144d8h4	8bd56ba96c53b0825f9811170f2e10ae24a97e8a3850c4741a49fc33a022b426	506848558	FT 202100653	003212	\N	Bcm Bricolage S A	2021-09-25 00:00:00	4.70	1.08	5.78	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.854
cmnhoyih40174rkt4898fes80	b6d6058f3cce2344e39cd7f8563c99097dba5978cb5f68a1efdd3d8b3f44ec64	506848558	FT 202103304	007881	\N	Bcm Bricolage S A	2021-09-18 00:00:00	4.14	0.95	5.09	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.864
cmnhoyihd0176rkt426ekqqvw	55eb247c0d1858c562bc8c038c5b31a218ec082da4c35c181c546ee4c9338eb0	505993082	FAC 005	51934669	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-02-22 00:00:00	26.58	0.92	27.50	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.873
cmng3bf4s00mfrkt497avncki	625f9fe7334dc788828bbe5f168377db50c107cacff13414f3527efbb80f7ad7	517514419	1 2025	306	\N	Cardoso Carvalho & Silva Lda	2025-12-02 00:00:00	120.00	27.60	147.60	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.332
cmng3bf5500mhrkt47k3uufxu	d4f8e1655c6ecbf4af7d3d173dbdf7e6951f80c0359db2a6bd507a698d750d12	517514419	1 2025	200	\N	Cardoso Carvalho & Silva Lda	2025-09-02 00:00:00	120.00	27.60	147.60	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.345
cmng3bf5k00mjrkt4oun7n4nl	369a24c03868fcc9a1d69f58c0bcbdb977afbc2961d21d78752cef4d0fc819d3	505993058	FT V201.03	25119796	\N	Robert Mauser, Lda	2025-11-17 00:00:00	114.84	26.41	141.25	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.36
cmng3bf5s00mkrkt4df8mq3ue	5680d629a33a7c975067f0661852f4a9d9b807e6a5b48265ee03d59a69804769	507718666	NCR 009	95327818	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-08-04 00:00:00	-434.23	-26.05	-460.28	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.368
cmnhoyihj0177rkt4vxwgp6hj	6dc81cdb3237d6987657208bd31ad3b081d6b03dfa88b960ea6ee07f1878a4c6	505993082	FAC 002	21921590	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-01-25 00:00:00	26.58	0.92	27.50	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.879
cmnhoyihn0178rkt4hspcnha4	f56e854d49a8cb6c4c946d4a592622c81fcc80b6cde2b730cd4558ec9139f4cb	503301043	FS 2021	12897	\N	Ferragens e Ferramentas S Gonçalo Lda	2021-11-29 00:00:00	3.42	0.79	4.21	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.883
cmnhoyihw0179rkt4il3j5mw7	8965e061d4510d90707bf77834a6b8c12f9d295ac327993a197aafdea667cde2	506848558	FT 202103303	006157	\N	Bcm Bricolage S A	2021-08-17 00:00:00	3.24	0.75	3.99	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.892
cmnhoyii6017brkt445u1z9g7	d74ce9be110f9b8c6663ef9ba72ed38978a9be594b638f0cb7845b4cc27a58e5	506848558	FT 202103306	006628	\N	Bcm Bricolage S A	2021-09-07 00:00:00	3.17	0.73	3.90	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.902
cmnhoyiif017drkt4fqd2dvaa	7522ebc362dc756754bcb58ad17da20185a29255dd1f66d586699a4038b259a9	505993082	FAC 006	60480346	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-12-27 00:00:00	19.38	0.55	19.93	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.911
cmnhoyiii017erkt4l2imgx4n	d108e0af3b8a581371c6b7359d5aad5d1ffcad1a61d58780cedcd4f9ba5e7d59	505993082	FAC 006	60469018	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-11-23 00:00:00	19.38	0.55	19.93	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.914
cmnhoyiin017frkt4kd0adviq	8cba0854424e9335e0e81a164a4d6d780cbd4b443ac5c44d77e50371fea8a660	505993082	FAC 006	60458743	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-10-25 00:00:00	19.38	0.55	19.93	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.919
cmnhoyiiv017grkt4bw7zsdso	994541c5119aa6948f321ebb8d2e6bd2a01aeb2e8e17bce869352458ca17b46a	505993082	FAC 001	12024647	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-09-24 00:00:00	19.38	0.55	19.93	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.927
cmnhoyij1017hrkt4wvvnmgf6	5b940a2bcd8c22d3db3a4e5b2e868b072d85c8ae5b73ca4aac489cc173840dde	505993082	FAC 002	22011070	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-08-23 00:00:00	19.38	0.55	19.93	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.933
cmnhoyij6017irkt48ixhsvgw	d8ad355302f1132a178fa9f5332e5775a0f24deabd794cf6c41b1d7b90919e45	505993082	FAC 002	21998178	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-07-23 00:00:00	19.38	0.55	19.93	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.938
cmnhoyijc017jrkt4755k4ei4	0aa5cdf31a10d53769c68418e6785d2bb94564c1bf5cceccb28ae30b418635ed	505993082	FAC 001	11985846	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-06-25 00:00:00	19.38	0.55	19.93	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.944
cmnhoyijj017krkt4xz9nljz4	2cd80bf06bbc59a42d9eec508717d9ee93361033050866b203eba5cee1a414c9	502544180	FT 101	026291506	\N	Vodafone Portugal - Comunicações Pessoais S A	2021-10-05 00:00:00	2.06	0.47	2.53	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.951
cmnhoyijq017lrkt4nozfet5x	9aa612e8e2e26ea123c84d60ed2e0734fcd842bfa3262325ac719892373469a1	505993082	FAC 002	21972863	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-05-25 00:00:00	1.40	0.39	1.01	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.958
cmnhoyijv017mrkt4hb6prvwr	c5f926d7a0499f58faf8f6116a9ee265bb25071602b25225c962fd100cfb5a14	503301043	FS 2021	10480	\N	Ferragens e Ferramentas S Gonçalo Lda	2021-09-25 00:00:00	1.22	0.28	1.50	Fatura simplificada	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.963
cmnhoyik1017nrkt4coe4oviv	a81a3f5300c5e5738be9cde9a4929fc258ddeb3c3fcf0710e7a58c440a3232a8	506848558	FT 202103306	006936	\N	Bcm Bricolage S A	2021-09-20 00:00:00	1.04	0.24	1.28	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.969
cmnhoyika017prkt48136xe6r	604a6fe7c0ee15e8230a8c5e592d80f24461d6417943f19eb9f86fa81d47b94a	505993082	NDB 000	1652857	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2021-10-07 00:00:00	86.65	0.00	86.65	Nota de débito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.978
cmnhoyikf017qrkt4gvlqbzcu	787c310a34bc28c4c55ef423b878dd4ab726cf7a4fa53353982a381659bd426b	513204016	F1 2	4202283842	\N	Novo Banco S A	2021-07-05 00:00:00	17.50	0.00	18.20	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.983
cmnhoyikn017rrkt4dokhv7fb	97a2a0a9b0235c316b4e5939ab2be34bbfa6b1c8a1814153dfb25d6e73d7249b	510257585	ZFTP 1	3100307254	\N	Travelfactory Portugal Unipessoal Lda	2021-06-17 00:00:00	10.00	0.00	10.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.991
cmnhoyikt017srkt4vmr4dyys	2d4ff5d0da89e3245c0b3c89c94a98d2aa2b38c943a09dcb39997bd3c29836ed	507432444	NC21 21	1	\N	Sampulau Lda	2021-01-29 00:00:00	-110.00	0.00	-110.00	Nota de crédito	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:49.997
cmnhoyil0017trkt4ccwz9qs8	2b42c1671f94e614cbb65aaf25e1eb2ca94762fd6b807f66e9cce960ce07a540	507432444	FT21 21	1	\N	Sampulau Lda	2021-01-19 00:00:00	110.00	0.00	110.00	Fatura	cmnhoyhc2012urkt4fajo4txy	2026-04-02 16:30:50.004
cmnhoyppi017vrkt43kus91vg	2006a6dda06403beddb4a54bf377a152677dff45481f9181bfa80ce2cc29d4da	505416654	FAC 00903320220008	108	\N	Ikea Portugal Moveis e Decoração Lda	2022-06-02 00:00:00	3571.19	821.31	4392.50	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.238
cmnhoyppo017wrkt4vrfwhhq5	8d0b7962b7359fdafa73a2a5542e46cd72e9612dd8ac05c93f368986f4a7dfc1	503000000	FACTC 122	501	\N	A M Industria de Colchões Lda	2022-08-08 00:00:00	967.50	222.53	1190.03	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.244
cmnhoyppu017xrkt44ywjbitb	352dc29cd429d46d8f176aebde0e51063f7216c8107cdab2bd3513fea7f2b38f	505816105	FACT 79SEC122	15	\N	Manuel F Campos Unipessoal Lda	2022-03-11 00:00:00	690.00	158.70	848.70	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.25
cmnhoypq3017yrkt4kedxv80e	78a3ac3e9e217968deb5989bd71e81c90e23140dc200a06521770ea47fa651d2	506553914	FACC-S 1	85714	\N	Papaboa Restauração Lda	2022-11-29 00:00:00	995.58	129.42	1125.00	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.259
cmng3bf0c00lxrkt4zkobhsk9	5219a3c0643e87ce28f5096c909cd8fe042f5dd3db80a81e754a0c6f398068d9	502544180	NC 201	003773698	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-12-04 00:00:00	-243.90	-56.10	-300.00	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.172
cmng3bf1100lyrkt4c6yyc2u9	c326015be1c51a802d1b3f36dfc9c648e10b171a556dda3fb7d65c9abd0943dc	505416654	FAC 0090412025	0002297	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-17 00:00:00	213.83	49.17	263.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.197
cmng3bf1600lzrkt43ms6hkxb	b2d4e1ddbe5e1e3780f6d74b890ce0b164aad35e2be207d401a277e170794f76	508546702	FT 2025A1	246	\N	Norcana - Canalizações do Norte Lda	2025-09-29 00:00:00	200.00	46.00	246.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.202
cmng3bf1d00m0rkt4697vo0t1	b1c9f1fbc5198b11d661f549cec8ffee5c26ee09a9ac271007d9265f5298b993	501293710	FT FA.2025	11232	\N	Jocel Lda	2025-12-05 00:00:00	199.90	45.98	245.88	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.209
cmng3bf1k00m1rkt43y0gq6dv	d547ac5b7f7f6c57b3a6e9950f000b276cb1e625b15058b52c3765f1f8e4f42d	506848558	FT 20250015801	006949	\N	Bcm Bricolage S A	2025-10-28 00:00:00	193.50	44.50	238.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.216
cmng3bf2100m3rkt4i53uiuid	afc07475fccbd1dafe5dbaf91e848b28c30b949cbb0ad3f4b212bcb2b62be1de	505416654	FAC 0091152025	0011738	\N	Ikea Portugal Moveis e Decoração Lda	2025-12-28 00:00:00	187.50	43.12	230.62	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.233
cmnhoypq8017zrkt4s4vfrrws	c22a04801b4f2c67d0a9ce92c2fc9fc85883c9540a2c50e9cfd3fb70f98a6b6b	502006234	FT 2022	21	\N	Riba de Ave Hoquei Clube	2022-10-05 00:00:00	450.00	103.50	553.50	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.264
cmnhoypqg0180rkt4daz1zaer	5c950a7c20f1a3e807753f3730bf107d3f36e260d640a8e7074eda4ede574081	516917927	F FCTREST22	1465	\N	Vi-Fe Resort Lda	2022-12-09 00:00:00	544.79	72.21	617.00	Fatura-recibo	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.272
cmnhoypqr0181rkt438xxs4al	ef059d01993ea6d263269a39a7dcc754004dc95d313fdfb28791b48c8efa2a0e	503000000	NCRA 122	18	\N	A M Industria de Colchões Lda	2022-08-08 00:00:00	-290.24	-66.76	-357.00	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.283
cmnhoypr20182rkt4eq2bln8g	238835c2ca63301baaa39638b1a2dcc791dfeaf7cd94577f8ffa2541036f315a	503000000	FTAD 122	15	\N	A M Industria de Colchões Lda	2022-06-21 00:00:00	290.24	66.76	357.00	Fatura-recibo	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.294
cmnhoypra0183rkt42jh8z10h	e848f846d82f07c0019757d9c68130c5b7d44911bed0800f3bb7559d76ba30e5	500239169	FR BLA	32854	\N	Salvor Soc Investimento Hoteleiro S A	2022-10-09 00:00:00	625.03	55.97	681.00	Fatura-recibo	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.302
cmnhoyprj0184rkt46blakctx	28d752619fb9a5f8c5274c092396fd9041f4082048097ad6215eac5b3d149f82	503630330	FT AUM004	010268	\N	Worten - Equipamentos Para o Lar S A	2022-09-12 00:00:00	227.63	52.36	279.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.311
cmnhoyprv0186rkt41hgc6aje	decb5c95b50d03b2abc5dbccb5e9cfaf05e929599a17651051516af126bc7dc6	505416654	FAC 00906920220030	284	\N	Ikea Portugal Moveis e Decoração Lda	2022-09-08 00:00:00	214.88	49.38	264.26	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.323
cmnhoyps10187rkt4az1bxww8	4e5202eccba83435e700cb1a1f7e819beb15a12d57aa260b7136cfd1aa6788e2	502075090	FT 501	2022066207	\N	Arcol, S.A.	2022-09-20 00:00:00	167.13	38.44	205.57	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.329
cmnhoypsd0189rkt43uz7zt4u	c32ad3a3f2d0269ec9c55b62f61df9c22ae032d15932d2311a1571e79f1aaa95	503630330	FT AUM003	022135	\N	Worten - Equipamentos Para o Lar S A	2022-09-18 00:00:00	148.75	34.21	182.96	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.341
cmnhoypsm018brkt4gsiwazef	4eebcb15fff96d1f73ac827dc9c982e87a26fe7ab375d3a92e08a622420fe3d5	509068839	FR 2022	1255	\N	Prinfor - Informática e Electrodomésticos, Lda.	2022-03-05 00:00:00	123.05	28.30	151.35	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.35
cmnhoypst018crkt45x7c8j1i	882c50a8d053fdd078f123cb976b74bc6b3c6bf9a26b936d829675caa1cb2f87	507857542	FT FTRPORTAL	22040010681	\N	Gold Energy - Comercializadora de Energia, S.A.	2022-02-09 00:00:00	130.03	28.07	158.10	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.357
cmnhoypsz018drkt4u1rioc5e	b3b3e4a5be18875db01b42d12e5e27a48cad69a12ef7a5f41c6851cd42dd900a	505416654	DEV 49903520220020	322	\N	Ikea Portugal Moveis e Decoração Lda	2022-09-30 00:00:00	-119.51	-27.49	-147.00	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.363
cmnhoypt5018erkt43ont5v5n	fff16cd635544b5f481ac8fdc5764b02606d1b42255a3a41584bd256aaf1f87b	506848558	FT 202203304	005605	\N	Bcm Bricolage S A	2022-07-18 00:00:00	117.07	26.93	144.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.369
cmnhoyptf018grkt42bok99vy	91ce7ac0138e75115e74119a6bd17be7a33b0da8c568ee3711f32909607a8ee2	516917927	F FCTREST22	1787	\N	Vi-Fe Resort Lda	2022-12-30 00:00:00	182.38	24.97	207.35	Fatura-recibo	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.379
cmnhoyptj018hrkt41ib3mv9o	143c9b237e4c00741a40a92a7a1a5c9d9e00e019f8f729a5017adaee2d2cf1ef	507857542	FT VNFACR	220200167870	\N	Gold Energy - Comercializadora de Energia, S.A.	2022-01-15 00:00:00	117.03	24.83	141.86	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.383
cmnhoyptq018irkt47e5hrcxv	9aaf1d566b802cd0299603b6723dd47a6996da99f677e841d1ca91531d0845c0	980245974	FAC 0240312022	0061504124	\N	Endesa Energia S a Sucursal Portugal	2022-12-19 00:00:00	115.01	23.88	138.89	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.39
cmnhoyptw018jrkt4epr3l7yj	456f8a655b8e554d55d4606f6b58929637ebe3b86958b478b10161d73a452b52	505416654	FAC 49905220220021	005	\N	Ikea Portugal Moveis e Decoração Lda	2022-08-02 00:00:00	100.82	23.18	124.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.396
cmnhoypu3018krkt4c7c2c61r	a3cd5474b9a7767c44840e345caae09d00bf6307438ca69deb512e1b293e4c5e	502075090	FT 501	2022068621	\N	Arcol, S.A.	2022-09-29 00:00:00	112.62	22.08	134.70	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.403
cmnhoypuc018mrkt4h3uxh1yn	075badacef786101b8273006579340b78ca3783c4401cf985cd7d46719f9df7e	980245974	FAC 0260312022	0069092169	\N	Endesa Energia S a Sucursal Portugal	2022-03-16 00:00:00	99.97	21.04	121.01	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.412
cmnhoypuh018nrkt43hl6p64n	93a95ab216c75db63c325d2419351d8dbea65d7e97db37767fa36b5205bf23c0	506848558	NC 202203303	000353	\N	Bcm Bricolage S A	2022-09-06 00:00:00	-91.42	-21.03	-112.45	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.418
cmnhoypuv018prkt4u08zgwnh	63b2015c69467fc2e372902cef8412c2fe539bdc6901562afbe123056ca1d4d4	506848558	FS 202203303	041866	\N	Bcm Bricolage S A	2022-09-06 00:00:00	91.42	21.03	112.45	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.431
cmnhoypv6018rrkt4zyqyp2gt	651131628d7fcd3f90b9481bc06dd090cd60736f405c4876f0ed7b5f4f424b6c	980245974	FAC 0250312022	0065135254	\N	Endesa Energia S a Sucursal Portugal	2022-04-16 00:00:00	93.80	19.50	113.30	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.442
cmnhoypva018srkt4dr3ixjhn	b726e47824cfc2a793e22c5efd696e2e71aa8e000109a5678b22edca9a13f200	502022892	FT 0	039109	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-12-26 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.446
cmnhoypvp018urkt4ft7qw49y	82d9c1a0979fc3d1c8c0007231a53fd62e094ded136b4b09879e862b2467136a	502022892	FT 0	038999	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-12-09 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.461
cmng3bf2800m4rkt44m6m8xnz	688b3495e4894c5ab47bf808570fb05279f8de956b8f628d1e7f6d2b7ade0aa3	515337498	FAC 1	750	\N	Rd48 Reparação e Comercio de Automoveis Unipessoal Lda	2025-12-12 00:00:00	183.40	42.18	225.58	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.24
cmng3bf2f00m5rkt41z2l4k2b	72d1094aad1b49539331e6268326a92013eb1139044cb4da247541036a5b7537	500766452	FR 025	2294	\N	Congregação das Beneditinas Missionarias	2025-12-17 00:00:00	172.36	39.64	212.00	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.247
cmng3bf2k00m6rkt49grtu895	4014f6dba979c7861a716833353448c8a9c5c39ccdea082e095dbaabacb9db4f	505416654	FAC 0091232025	0020343	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-17 00:00:00	169.00	38.89	207.89	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.252
cmng3bf2s00m7rkt4y9t0llui	6636fa082d7146bfc41cabb721a5a7366fcafda485135e4ef07c28164ea277ad	505416654	DEV 4990372025	0003622	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-18 00:00:00	-168.30	-38.70	-207.00	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.26
cmng3bf2y00m8rkt4mw0ht1do	123b7caf92a345d9d29346e85469ced1d1ef221ce1eb3080f1b90f2cbdec056a	508546702	FT 2025A1	268	\N	Norcana - Canalizações do Norte Lda	2025-10-29 00:00:00	160.00	36.80	196.80	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.267
cmng3bf3400m9rkt4khdsoft2	fdf6a802e841e2122ea3f1af1ef00cba913c2d84c7d9ffcd5b73388118f2698a	500506272	FR FR25	87	\N	Irmaos Almeida Lda	2025-12-10 00:00:00	232.66	36.69	269.35	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.273
cmnhoypvw018wrkt4ckf603h6	ea80a7a4cbf35fdcf4be04a09f402ef2ed677bb7a33fad5b4db6fef394b635d9	502022892	FT 0	038506	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-10-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.468
cmnhoypw8018yrkt4x1ibjoes	bbbc54c4d6eeb35902c31d1d7ace7f32d8a7f7f10a97dd4c1d1b5bdd73a20f84	502022892	FT 0	038205	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-09-28 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.48
cmnhoypwi0190rkt4hsff1vp9	f3afd1d16dcc803e9e7a1a5344daff4ce757e1e9045e163a1e6971468e454190	502022892	FT 0	037897	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-08-30 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.49
cmnhoypwr0192rkt4veixk4r3	af729fd1f75e6d136b2aa37e1c1183ed596b3f4e8b1f45a0d58f7d6972895588	502022892	FT 0	037597	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-07-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.499
cmnhoypx30194rkt46g8deztb	e44b6d8a5d2ce6bfaf5e841ffbb35d2d05c7d762ca05fdfa387bea7e1ce9989d	502022892	FT 0	037291	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-06-29 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.511
cmnhoypxj0196rkt4usfbgvj1	c7a74f2954c6c9a121b658e0d9924449fa2104e146f0e7962754989ae276cb5d	502022892	FT 0	036974	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-05-30 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.528
cmnhoypy10198rkt4ceyxa4p4	f321d3f12c584298c4d5b97140226a16717e0dce94fa262d2d2c87dfdc698313	502022892	FT 0	036853	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-05-12 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.545
cmnhoypyb019arkt4mslmzpyc	146bbf01ed624e69cb7e8c09f10e62e5d77497987610542c6ddd97ed8cf08ae7	502022892	FT 0	036384	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-03-28 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.555
cmnhoypyj019crkt4seoz7p9p	68ea7fe4229a0c2adf59d122114bf132738a852061aacd702c6744096911b81a	502022892	FT 0	036083	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-02-25 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.563
cmnhoypyx019erkt4ibn5kvi4	feb316db46fb1334caaca1eb42e2243025a046a9d3d3abead899f3e8262b8961	502022892	FT 0	035783	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2022-01-27 00:00:00	80.00	18.40	98.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.577
cmnhoypz4019grkt4tfhq65aa	b7d72cad4dd21e3c24f857990dee1e2ae52b6767a68c26be77183e3c005c6f50	506848558	FT 202203303	001308	\N	Bcm Bricolage S A	2022-02-28 00:00:00	68.01	15.64	83.65	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.584
cmnhoypzf019irkt4okek7kti	20289ecc1d8b10dbdee126bd4a47762152dc8cfc28d696649ea23b1fc2a3c5ec	500389217	FT FT22001	342	\N	Mabera - Acabamentos Têxteis S.A.	2022-11-22 00:00:00	65.85	15.15	81.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.596
cmnhoypzl019jrkt4hdoe9rd2	badac9b846806a8de2e881371066c801a8ec0f7c68333e065b95e8308375bab0	500389217	FT FT22001	255	\N	Mabera - Acabamentos Têxteis S.A.	2022-09-07 00:00:00	60.09	13.82	73.91	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.601
cmnhoypzs019krkt4w7bwl8lt	1b8776c95977f5060d4dead925bb558ad31046e375f78fcbe07e03286455ac51	980245974	FAC 0270312022	0073041825	\N	Endesa Energia S a Sucursal Portugal	2022-02-07 00:00:00	66.26	13.66	79.92	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.608
cmnhoypzy019lrkt47bs9mttb	54a3bf9d243ce7041440657984f8aa49738afb7aa22b768f3a8399ff9bba8f55	980245974	FAC 0280312022	0077005209	\N	Endesa Energia S a Sucursal Portugal	2022-01-08 00:00:00	65.72	13.27	78.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.614
cmnhoyq05019mrkt4z5v9xmde	837368867d0c46c2d779bb292a9604168fbef5d5327c3158bf95845050c16164	506848558	FT 202203352	000458	\N	Bcm Bricolage S A	2022-07-20 00:00:00	56.90	13.09	69.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.621
cmnhoyq0f019orkt4pa7zx81z	4815e19e89bd7bf7e2b1538b6260e6e0cc1820268b32954618c25f303d4592c5	980245974	FAC 0240312022	0061482808	\N	Endesa Energia S a Sucursal Portugal	2022-12-07 00:00:00	66.58	12.81	79.39	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.631
cmnhoyq1d019prkt4zbwn7xnr	ebefb6d1554f77f179f83a59a20cb4b003604802766795d8fdf1ee60c025a7d2	980245974	FAC 0270312022	0073117668	\N	Endesa Energia S a Sucursal Portugal	2022-04-11 00:00:00	60.79	12.51	73.30	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.665
cmnhoyq2b019qrkt4vosn1cpv	7eafc79ef3adf5cae81557f96b354bbc21a5f41b6ca42e29cb8e74a718041466	506848558	FT 202203305	006262	\N	Bcm Bricolage S A	2022-08-16 00:00:00	52.00	11.96	63.96	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.699
cmnhoyq2r019srkt49hu8ufgo	0e53d415f25901e03c75c900f6777f1d8ecf9b0aa9d924374c1d813b5e2dbd09	506848558	FT 202203353	000287	\N	Bcm Bricolage S A	2022-09-06 00:00:00	50.30	11.57	61.87	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.715
cmnhoyq3k019urkt40dbwzerd	d053ee8ac6a0ebbb51972cdf691361b3806c4a125d9ffbf9b9bb316b883a5dd3	980245974	FAC 0280312022	0077076777	\N	Endesa Energia S a Sucursal Portugal	2022-03-09 00:00:00	56.42	11.47	67.89	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.744
cmnhoyq3s019vrkt4abtva2z2	960ee575605cd7609b3390b1d1c9bcd89ac1b20ef936d9a8659a123f3106b4c9	503502820	FT 2022A11	3669	\N	A P Freitas Lda	2022-09-08 00:00:00	46.95	10.80	57.75	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.752
cmnhoyq42019wrkt4elcb5ide	2290e91ad491147e4a3823d6cd281e548ab6df9534772f13a774500bfdc5179f	980245974	FAC 0250312022	0065178421	\N	Endesa Energia S a Sucursal Portugal	2022-05-16 00:00:00	54.63	10.55	65.18	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.762
cmnhoyq4f019xrkt4992625qk	7912a1bb7dc1775bbc82a75f1c91d84487e97ceb9f86b6591530941b24474d67	980245974	FAC 0250312022	0065431839	\N	Endesa Energia S a Sucursal Portugal	2022-11-07 00:00:00	53.41	9.91	63.32	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.775
cmnhoyq4l019yrkt4o7xu8d55	49315ee564e4349111308e9b24750d38f68eaed6306c88f55626f28a028eca6a	505416654	FAC 00906420210081	935	\N	Ikea Portugal Moveis e Decoração Lda	2022-09-08 00:00:00	42.28	9.72	52.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.782
cmnhoyq4v019zrkt466cc1i0n	e55b301c2bb1719a3624466a3e5815ad74e4cf40c5bb1dd02483d7504f19152e	508793556	FACB-S 1	75142	\N	Vida de Marinheiro Unipessoal Lda	2022-12-31 00:00:00	69.37	9.68	79.05	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.791
cmnhoyq5101a0rkt4im5y4gkw	2fd2ace97103ad6f7e16295d21f44b02017d693e2fa923fe5583436e6e4b0559	980245974	FAC 0260312022	0069163612	\N	Endesa Energia S a Sucursal Portugal	2022-05-09 00:00:00	41.23	9.41	50.64	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.797
cmnhoyq5b01a1rkt4gi2mutoy	0fd08d38481b6d8e3cbe2137e7902d117197873de001b4580165350411763546	980245974	FAC 0250312022	0065485984	\N	Endesa Energia S a Sucursal Portugal	2022-12-08 00:00:00	47.32	9.13	56.45	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.807
cmnhoyq5i01a2rkt40l95h5fm	978779c4867f051c2d24a6bed5acdb09c218942952b9bc3745f29917c0f54427	506848558	FT 202203306	002684	\N	Bcm Bricolage S A	2022-06-16 00:00:00	56.53	9.03	65.56	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.814
cmnhoyq5x01a4rkt4hb5mjn8o	203caaf73e9dcc70bf9f536f569ac51ad68706e9a1df674c447842513caff07f	506848558	FT 202201102	010892	\N	Bcm Bricolage S A	2022-08-31 00:00:00	37.75	8.68	46.43	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.829
cmnhoyq6c01a6rkt4jvt4bf0c	1b98473514b891c829465c65a07fe12a00e49fe1cfbd6ce4c3fbfe615d44a1da	980245974	NCR 0200312022	0047014167	\N	Endesa Energia S a Sucursal Portugal	2022-07-12 00:00:00	-45.82	-8.61	-54.43	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.844
cmnhoyq6s01a7rkt4m72k7lzc	f8efa52e670825e3f6cdb4dbf014082c3634673b5072242d074c8da8bcc90531	980245974	FAC 0280312022	0077190627	\N	Endesa Energia S a Sucursal Portugal	2022-06-07 00:00:00	45.82	8.61	54.43	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.86
cmnhoyq6y01a8rkt4vrp6cd8d	773098977f93c3cd6f26f732b58e23024a14193546a3eb7a8639b05c7127c63b	506848558	FT 202203351	000380	\N	Bcm Bricolage S A	2022-07-17 00:00:00	34.94	8.04	42.98	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.866
cmng3bf8k00msrkt4zn7wz8v6	af76db63a784eb03bc4dc5d3707964e61e759b20a4817437b5498b19bd51760d	502022892	FT 0	050411	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-11-27 00:00:00	100.00	23.00	123.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.468
cmng3bf9a00murkt4aexx7noi	577c10d3b20d456c2c01fa96231b36d3ebe8cfad672cb9b310d0c86469251c01	502022892	FT 0	049754	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-09-29 00:00:00	100.00	23.00	123.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.494
cmng3bf9n00mwrkt4e4z5p697	76993c94596e6d6e446371391c95f277ab9f87b038b1a7c9ca6dd6bb5fda7f7a	502022892	FT 0	049427	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2025-08-26 00:00:00	100.00	23.00	123.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.507
cmnhoyq7801aarkt4fd6h1vgv	b9c792eb71c850cc5ced785bd23f0cb9d9d4409fe21d78a361e187570c67fcd8	506848558	FT 202203352	000490	\N	Bcm Bricolage S A	2022-07-30 00:00:00	33.79	7.77	41.56	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.876
cmng3bfat00mzrkt4e9rkenvk	67696f975366e25d1bdffda0b4a3d4be63126499609dfc7ac18abc93f87fd3d9	502604751	NC e25	172129	\N	Nos Comunicações S A	2025-09-01 00:00:00	-97.56	-22.44	-120.00	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.549
cmng3bfbf00n0rkt4zimf4qf4	72165c88783b0b2de06a9ae8114ebcb6f2876ff271ab4c949b98e7fad58c045a	502604751	FT 202592	2377441	\N	Nos Comunicações S A	2025-08-19 00:00:00	97.56	22.44	120.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.571
cmnhoyq7i01acrkt4c9qmrd2t	f0be1de96213c5b3a20c714844e2d9e6732078b23f6c15245a9ae6710f354107	506848558	FS 202203303	000635	\N	Bcm Bricolage S A	2022-01-05 00:00:00	33.22	7.64	40.86	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.886
cmng3bfbq00n2rkt4xmrdentz	90dd8ad4ea0724091ab0caa63ef036b5b77028f5a325a7edc9a89af0ae86b1fa	517514419	1 2025	273	\N	Cardoso Carvalho & Silva Lda	2025-11-07 00:00:00	96.00	22.08	118.08	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.582
cmng3bfcj00n4rkt4lirzbn86	0af56bfa0a219f91c2207275161f32f86483f2cbba623d07567ee7d24e3c3077	517514419	1 2025	236	\N	Cardoso Carvalho & Silva Lda	2025-10-02 00:00:00	96.00	22.08	118.08	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.611
cmng3bfcr00n6rkt4zo4s42g9	ef44114e23b89145e5347459ff865d6099bb6403c6d929f99fa63cfbec204e05	517514419	1 2025	178	\N	Cardoso Carvalho & Silva Lda	2025-08-04 00:00:00	96.00	22.08	118.08	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.619
cmnhoyq7s01aerkt45rql2rs6	5b3e62471699d817c3747585991c75804dc7292d9d1495ef5bdd3bbbc936bc2e	980245974	FAC 0270312022	0073154865	\N	Endesa Energia S a Sucursal Portugal	2022-05-08 00:00:00	39.04	7.42	46.46	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.896
cmnhoyq7z01afrkt49fx68jkc	a1b6cedd5fd2dc356d69763410502f73f1074b541d321467e5bc06d246d88d43	506848558	FS 202203303	031417	\N	Bcm Bricolage S A	2022-07-16 00:00:00	31.97	7.35	39.32	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.903
cmng3bfdj00narkt4lxv1yor8	6ecaddd69652e4a18fc41c2625faa582c618e9008aebd4b4d31d041f1d5d1e89	516676180	FT FT25	143122	\N	Ibelectra Mercados Lda	2025-10-28 00:00:00	103.82	18.20	122.02	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.647
cmng3bfe200nbrkt499suek4c	ecf16f15db588f4dacd407062dc07232f08b82d7f4c62ce5dccdcee95f58958a	504984810	FR 2025A3	1092	\N	Saniestilo - Materiais de Construção Lda	2025-12-17 00:00:00	79.06	18.18	97.24	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.666
cmng3bfe700ncrkt49q2zxmie	0ab75f732d611dc82e3b5602134049f9faae35bfb3c8989daf391f10aecb57e4	502544180	FT 101	099486274	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-09-04 00:00:00	72.41	16.65	89.06	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.671
cmng3bfee00ndrkt44m3p3020	d956626e0ccd258224019abef164181eb898702a8e419b4c0b117e899de205d8	516527835	FS 009172001	293863	\N	Auchan Energy S A	2025-08-07 00:00:00	69.48	15.98	85.46	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.678
cmng3bfej00nerkt4dw5wyf2z	bf54ade7437eb7cc906fc37d4f431b8b4ff58bc8727c76159788bf2e970db518	502544180	FT 101	097952611	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-08-04 00:00:00	69.39	15.96	85.35	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.683
cmnhoyq8801ahrkt4dtgz1bjd	94e47f6f4b0e0e18462d7940781ee2bfb97740ed41498122b6a3cdfdfa2e1b8c	502604751	FT 202293	2382940	\N	Nos Comunicações S A	2022-12-26 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.912
cmnhoyq8d01airkt4rfd9ue5i	c090169a755ebaff51b6ea5e22ce0b642d1b17b114b947d68d38f05d0ab75f0d	502604751	FT 202293	2164462	\N	Nos Comunicações S A	2022-11-25 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.917
cmng3bffe00nhrkt48v8qvoo5	3004b6afac185936c66c042c8c064deccd96e8e6a03b75f5a8631a205d958a1a	513325417	G 1123-23P	196884	\N	Isaura & Lopes - Supermercados Lda	2025-11-21 00:00:00	66.98	15.40	82.38	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.714
cmnhoyq8m01ajrkt4nhzo6sz6	c84ad310d450c73a010cbe2cf8160a874c85145f117419dd738434b45e273039	502604751	FT 202293	1949207	\N	Nos Comunicações S A	2022-10-25 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.926
cmng3bfgg00nkrkt4uvntz92u	1d188896c5b24fc0d438b855051116205f88f38d9af3f27cf641567f834a8ffb	516527835	FS 009311001	330551	\N	Auchan Energy S A	2025-09-02 00:00:00	66.13	15.21	81.34	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.752
cmng3bfh600nlrkt4krdc1bxe	de560c78e19a1a25dd4327252d7be71b2bf1699031d6372829c5d693e0d0f7b3	513325417	G 1123-23P	190017	\N	Isaura & Lopes - Supermercados Lda	2025-10-13 00:00:00	66.06	15.19	81.25	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.779
cmng3bfht00nnrkt4zrojh76s	d35061aa229ab1b3c47e68d1ec24591bf9797461f6d69ba899baf364a7e8dced	502604751	NC e25	172127	\N	Nos Comunicações S A	2025-09-01 00:00:00	-65.04	-14.96	-80.00	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.801
cmng3bfi900norkt4n2u7ndpr	61b6900d539ad614ab60b7da34876297e81a52e59f83eab5843f181ca09a174d	502604751	FT 202593	1917883	\N	Nos Comunicações S A	2025-08-26 00:00:00	65.04	14.96	80.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.817
cmng3bfil00nprkt4mae7ic6w	58413f211da239a3e68a15fc780e0df0f4afc06b6d8f3e518adfc5ca7b098d77	516676180	FT FT25	175456	\N	Ibelectra Mercados Lda	2025-12-24 00:00:00	88.66	14.68	103.34	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.829
cmnhoyq8r01akrkt4e51dr43q	f190a3281de8780d09ffdcaeea051cff22b6be5eb3c1c84d1231a81ad5276646	502604751	FT 202293	1735211	\N	Nos Comunicações S A	2022-09-26 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.931
cmnhoyq8x01alrkt4r3tfu0x3	3882e78214a11425bb88d7bff6154bcc1c3a828ea0fe354b717e734706623d75	502604751	FT 202293	1482890	\N	Nos Comunicações S A	2022-08-24 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.937
cmnhoyq9201amrkt44ywqwe1r	59bd84b49bc96db045fbfe1b43687fe5d15dd16a00a49e759584154855644ecb	502604751	FT 202293	1313884	\N	Nos Comunicações S A	2022-07-26 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.942
cmng3bfk200ntrkt4f6zwxt31	0b3ab532e2f88b8a3ef0b00aa9c0239fc321c02bee6a63ae15973cf213949219	502075090	FT 5012025	69033	\N	Arcol, S.A.	2025-10-02 00:00:00	57.48	13.22	70.70	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.882
cmnhoyq9801anrkt43g6eiogu	711bf7754fab313ff75d4e17c40fe8724468336cb59fd15c6b9fab60b3387ca3	502604751	FT 202293	1108944	\N	Nos Comunicações S A	2022-06-27 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.948
cmng3bflb00nurkt4fvfxslvj	2cec05e454432ab709462417f702a87cc55abc34ba936a06a24566f3721f49fb	503630330	FS AUM003	198348	\N	Worten - Equipamentos Para o Lar S A	2025-08-26 00:00:00	56.90	13.09	69.99	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.927
cmnhoyq9g01aorkt4pqq5qnuj	e58bc9daa6acdd1536ccae1c4eded3905ff34bd230163f76c143e12363ca3561	502604751	FT 202293	903714	\N	Nos Comunicações S A	2022-05-25 00:00:00	30.89	7.10	37.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.956
cmng3bfm300nxrkt4hswl63gi	be2630091c5e6bf10094233c272b2898dde7f7cc7a7a1b2ec9e020be5564947b	516222201	FT FT.FC25	2232962	\N	Digi Portugal, Lda	2025-12-12 00:00:00	53.66	12.34	66.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.955
cmng3bfn000nzrkt45eg57lnz	d6a6175ba5fe7cd2f1ee655e1b7a45cfc21a382eb497c96e4a852e294cac3505	516222201	FT FT.FC25	1992333	\N	Digi Portugal, Lda	2025-11-13 00:00:00	53.66	12.34	66.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.988
cmng3bfna00o1rkt4g6atizbu	c48b826037c217715dc56085cddbaf39f23667d2e44e50e3e4795a8da03ae9b9	516527835	FS 009179001	140764	\N	Auchan Energy S A	2025-08-08 00:00:00	53.59	12.33	65.92	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:14.998
cmng3bfnf00o2rkt4loyvvdnw	81c96319b64192ee6e229e02d65053e109ff57dab943ba1c09befc80a686abf9	502544180	FT 101	101246400	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-10-04 00:00:00	53.54	12.31	65.85	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.003
cmnhoyq9o01aprkt406cey2ac	3ddd723fcd16919069b4276002b9d2107fbf1535edbaf8f326b529eba1f6af32	502544180	FT 101	046454908	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-12-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.964
cmng3bfnr00o4rkt413no2jv3	28a905c8605d5377999df54a4ea6b944caf1c7cea5bd866b6cb0b719aebfbec7	513325417	G 1123-23P	185053	\N	Isaura & Lopes - Supermercados Lda	2025-09-16 00:00:00	51.57	11.86	63.43	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.015
cmng3bfoj00o6rkt4hx9ncan1	f3764a7c05853d35aa6a9aedb911f4df14d3bf6b220f5440804c6152012b49a9	506848558	FT 20250335601	003059	\N	Bcm Bricolage S A	2025-08-13 00:00:00	51.44	11.83	63.27	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.043
cmng3bfou00o8rkt40ol8tjvt	ca85bdb13017746722538f64cb7f8950351269a0106ac336307f624266a543a9	516676180	FT FT25	123613	\N	Ibelectra Mercados Lda	2025-09-29 00:00:00	75.61	11.57	87.18	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.054
cmng3bfp100o9rkt4vcbqfw67	52d0768c6764dd29e70484feb2d6e84072e90fc1693e8e496a8ff56b3bb4cae8	503630330	FS AUM002	033477	\N	Worten - Equipamentos Para o Lar S A	2025-08-03 00:00:00	48.77	11.22	59.99	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.061
cmng3bfpa00obrkt4bzijd4zu	1cb215287ec6fe2784ec4e429cc527fd060c20a01d59adac552ccb68367ffcd4	516676180	FT FT25	158673	\N	Ibelectra Mercados Lda	2025-11-24 00:00:00	73.60	11.03	84.63	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.07
cmng3bfph00ocrkt4zoz11hi2	ddb739cf533266c8c46f62e69c78c38d4cae903a1dba9f32919de82d34951bea	516222201	FT FT.FC25	1764168	\N	Digi Portugal, Lda	2025-10-15 00:00:00	47.80	11.01	58.81	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.077
cmnhoyq9w01aqrkt49l2v4qbv	67cccf006e93a76bd14b5206d749ff841fbaa92fa90ae5a45932da3f0b64db92	502544180	FT 101	044965060	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-11-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.972
cmng3bfpt00ofrkt4rxv6z3la	e63eaa1969f0698efebea3da16f2a5d015a582bf7a861693d9ce742d51de16be	518754618	FS TAN1	2655	\N	Bateira e Fonseca Lda	2025-10-24 00:00:00	75.30	9.80	85.10	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.089
cmng3bfqd00ogrkt48m0azc5q	fcbeb4448a6e3d869087ec955523caf909e064b9f753c4696696585b5cc65bc3	507432444	FT FT25_25	156	\N	Sampulau Lda	2025-12-12 00:00:00	42.50	9.78	52.28	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.109
cmng3bfqi00ohrkt47jt1s267	72d1da5374c2aed5a05bd8bb6ae205f4946f9a3ec3eb6e05b3127d6d75b441e8	518417948	G 1243-25P	1276	\N	Petronor Combustiveis Lda	2025-12-16 00:00:00	40.65	9.35	50.00	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.114
cmng3bfqu00ojrkt4acl62fk0	dd4c46c9171c72fb369e30c2e928c80d8afa441922a37ea09d2b294d5d4e7097	503301043	FS FS.2025	7127	\N	Ferragens e Ferramentas S Gonçalo Lda	2025-08-14 00:00:00	39.60	9.11	48.71	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.126
cmnhoyqa101arrkt4cssmczyw	61ff126c1b39ef9e3560c10f6c6a9ee428f3e497aa992cb7ad65ca36aae9cd08	502544180	FT 101	043482947	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-10-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.977
cmng3bfr300olrkt4wuoltte5	74d6c25c8fcdcfd81725e22348dd39f6a4ee9a1bd518d5211350a265351a5354	516222201	FT FT.FC25	1380036	\N	Digi Portugal, Lda	2025-09-12 00:00:00	39.03	8.97	48.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.135
cmng3bfrt00onrkt49nwemfwz	20cd1a53deaab4ca8a5575befa94825bd13ec4f8a2f6b1e46830c09c1064a57e	516222201	FT FT.FC25	1110410	\N	Digi Portugal, Lda	2025-08-14 00:00:00	39.03	8.97	48.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.161
cmnhoyqa501asrkt48qwm5lu4	a1d3f5534c30ae46ebff442b0eede9ed1e567d30c92dd51628d11f0917263ddf	502544180	FT 101	042006982	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-09-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.981
cmng3bfs500oqrkt4ogtjxz4k	b36f3c36c3d207e3fecc50f1d5e002b6cc8bff6d48ade1f6dfc7d09cd59ee993	516676180	FT FT25	158193	\N	Ibelectra Mercados Lda	2025-11-24 00:00:00	63.99	8.36	72.35	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.173
cmng3bfsr00orrkt4qmhoaa11	ad08dd96f61815a7ffa1795b95911d1320a7c9e6b1832064fca448780c72f027	505416654	FAC 4990822025	0013568	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-18 00:00:00	36.18	8.31	44.49	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.195
cmng3bft100osrkt4qhjuau22	835f9926d773db44c506cbe2b8ab7103d5d0aab94a559181ee45b6b6eb578122	516676180	FT FT25	140772	\N	Ibelectra Mercados Lda	2025-10-24 00:00:00	60.49	8.20	68.69	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.205
cmng3bft900otrkt44kb7qe3k	7132d0aada5d9a2a8c010123603af9ee2ccd2145b0aea721cbd3ec4d975b6dec	502544180	FT 101	105146867	\N	Vodafone Portugal - Comunicações Pessoais S A	2025-12-04 00:00:00	34.68	7.98	42.66	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.213
cmng3bfti00ovrkt4hv6r0s0s	3402bc9743f856afdcd3cce69e9de51c4cff4ef414f93723f2b8f487b4ee3a88	506848558	FT 20250335701	003471	\N	Bcm Bricolage S A	2025-09-10 00:00:00	33.07	7.61	40.68	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.222
cmng3bfu800oxrkt452x2wl02	18c1c3cd723c3dafcc24c0374e51af8dc637fe5814167cfb93509e8a458505ef	503126730	G 1238-25P	5947	\N	Petrofregim Posto de Abastecimento de Combustiveis Lda	2025-11-14 00:00:00	32.52	7.48	40.00	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.248
cmng3bfug00oyrkt4w7c74r3q	aa4a3b183de3a9e8608e10670a5c6044a388ffe6b96b2bf9a161d2f72353e5ec	500387281	FR 25	3048	\N	Corticas N S Lda	2025-09-10 00:00:00	31.50	7.25	38.75	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.256
cmng3bfuo00ozrkt47vwhrhiv	8720738200254e3115e5af4d94fb1836d8f90ebc0e14d22c8d2e6e6f3aed3844	503789372	FS 10130032404091116	012672	\N	Staples Portugal - Equipamento de Escritorio S A	2025-08-27 00:00:00	30.64	7.05	37.69	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.264
cmng3bfut00p0rkt4za04w1qf	dc8792ea10924ca2cea3af616918cff1cc73ceecb097883993ac306305b61edf	500506272	FS FS25	36815	\N	Irmaos Almeida Lda	2025-12-24 00:00:00	53.24	6.96	60.20	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.269
cmng3bfv000p1rkt479ffakaz	078a447ba4afa4d547b0ca91713861aee4955a58e950fd97261654a56c55a1d8	516676180	FT FT25	154864	\N	Ibelectra Mercados Lda	2025-11-20 00:00:00	34.99	6.93	41.92	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.276
cmng3bfv800p2rkt40pvvh1n2	c6a5e07a2e9c8a83c756814eaae2d1d5b11d3f96a365dadf77aa951101ec83e6	507027566	FS0 60	30288	\N	Com Requinte Marisqueira Lda	2025-08-17 00:00:00	47.79	6.61	54.40	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.284
cmng3bfvf00p3rkt45dpdqypj	fc4791df6a4f6e3a4008df4e7b645d9e10d5b49f629516fd399fb2355a134e58	510450024	FR 003	2463501	\N	Ifthenpay Lda	2025-08-31 00:00:00	26.57	6.11	32.68	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.291
cmnhoyqa801atrkt45c3txmsu	3afcf9969927f2dd5cc44f6b9362ef6002dd96b3f2a91f476e8352b0ae04fa51	502544180	FT 101	040544226	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-08-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.984
cmng3bfvv00p6rkt4hji9u1z8	8889a070d8f5c0dfb4f7d53aee5c9a1196bcb041d1a4ba3eed1b81179d8d49d7	500389217	FT FT25002	76	\N	Mabera - Acabamentos Têxteis S.A.	2025-11-21 00:00:00	25.85	5.95	31.80	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.307
cmng3bfwf00p7rkt4xxmmqf8r	0d195e6891fc5649c54a0d9b175386714a5eee4c4686275e01020129c788f484	502888512	FS 00002	126101	\N	Brandão & Martins Lda	2025-10-12 00:00:00	39.98	5.72	45.70	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.327
cmng3bfwm00p8rkt4rgdntgqy	742c38f949d4183e8eda5a0c57312d1c2f130671ae808b57ff6744ff512ad10d	505416654	FAC 0090442025	0021301	\N	Ikea Portugal Moveis e Decoração Lda	2025-09-05 00:00:00	24.38	5.61	29.99	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.334
cmng3bfwr00p9rkt4c48bax6d	280ed40f9695a62a63f3d767453f31d61e93503c2a4287ea5ff1cae6a964202f	510049001	FR 1025	30811	\N	Gfeira, Lda	2025-09-07 00:00:00	24.15	5.55	29.70	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.339
cmng3bfwx00parkt4syreabmt	6311b2e629ae04d6bc9d5eb4e6a6d9b31b93b0807350f97727fad4e8e104a53c	502075090	FT 5012025	62263	\N	Arcol, S.A.	2025-09-05 00:00:00	23.87	5.49	29.36	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.346
cmng3bfx400pbrkt4ow9o3f1r	ae39b18c02679da76e2c6ea53d471472b686cec603f12eab07234f02a3e43020	517377870	FR M	460	\N	Legal Factor Lda	2025-09-17 00:00:00	21.95	5.05	27.00	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.352
cmng3bfxc00pcrkt4xqp9xcbl	04160273be89e07be9e240505d6533dedf15b9c62df490893f6ffe412e010baf	514508884	FR FARLJ.2025	126	\N	Not Guilty - The Right Way, Lda	2025-10-29 00:00:00	20.86	4.80	25.66	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.36
cmng3bfxi00pdrkt4623bz585	9aedb36abc2ae5b4689005bf3b8bf835df4b6c103f059f3a0bac791102212029	980245974	FAC 0240312025	0061644398	\N	Endesa Energia S a Sucursal Portugal	2025-12-08 00:00:00	31.94	4.78	36.72	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.366
cmng3bfxn00perkt4t0uuro8i	c07580a1ba918c6d58db079a99275e7c3d5ef6aa0af2b6b8b5087020b8ccec4a	980245974	FAC 0240312025	0061429527	\N	Endesa Energia S a Sucursal Portugal	2025-08-18 00:00:00	24.69	4.77	29.46	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.371
cmng3bfxt00pfrkt47dofyi0a	a53342ecd1072e50c31fce94fdfaec0e7e545b5a5e39683d7ae2a4effab09e0a	516676180	FT FT25	121281	\N	Ibelectra Mercados Lda	2025-09-24 00:00:00	40.53	4.67	45.20	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.377
cmng3bfxy00pgrkt4avdvphf7	10b7b3d221ffa070d7777825930d82a0d320558329a66b38da9bebdf882b3d2e	505416654	FAC 4990822025	0013569	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-18 00:00:00	20.32	4.67	24.99	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.382
cmng3bfy400phrkt4lqx8v91c	ec366e3b34bb2d0bb6986e752e26a47039b154635dde1f54cdc8d086e9670e6b	980245974	FAC 0240312025	0061607991	\N	Endesa Energia S a Sucursal Portugal	2025-11-18 00:00:00	23.02	4.66	27.68	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.388
cmng3bfyb00pirkt4q1bvbgi4	3c3e598ee487efdd89f978dc4b4d7dc3fd1b32d94267c84cd48a1f3be9be9490	980245974	FAC 0240312025	0061664634	\N	Endesa Energia S a Sucursal Portugal	2025-12-18 00:00:00	23.80	4.61	28.41	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.395
cmng3bfyh00pjrkt4vqfq9g76	f50f6e8eb6d4a45837b817003979a9cc3ff7c39749419a55390412491388e453	506848558	FT 20250335501	004205	\N	Bcm Bricolage S A	2025-08-19 00:00:00	19.98	4.60	24.58	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.401
cmnhoyqaf01aurkt46ggn1ev0	6ae8f18efca7a4fc6437d4f0e7f53cf0c765993d9dcf1f99ae88960b777032be	502544180	FT 101	039087066	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-07-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.991
cmng3bfyx00pmrkt4gh7v3gn9	68b2e0195093f19f0ff336b2525e0e7995df023f07b7773cf189a1ca48604ed6	980245974	FAC 0240312025	0061407864	\N	Endesa Energia S a Sucursal Portugal	2025-08-08 00:00:00	26.85	4.58	31.43	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.417
cmng3bfzg00pnrkt4igea3zty	486afd1d48a6d7c0a455c77694ca279d22235bcb3e4e222db1638dab53ef3e05	980245974	FAC 0250312025	0065572625	\N	Endesa Energia S a Sucursal Portugal	2025-11-08 00:00:00	26.68	4.57	31.25	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.436
cmng3bfzn00porkt4tpjcvk14	8f9bddfc47506f7f94926b6596c71e7da9ac80f323a419d14e57a9f41514d9a4	516676180	FT FT25	103981	\N	Ibelectra Mercados Lda	2025-08-28 00:00:00	38.59	4.56	43.15	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.443
cmnhoyqak01avrkt4vmnujpwy	dde3e73db1b2c0d798bb82dd45cadc536284f0eb6480e234446bb44eaaab3823	502544180	FT 101	037637519	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-06-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:30:59.996
cmng3bfzw00pqrkt4s6u8klw7	cb6d51b0741e5a70737686aaaa98f33c143a0f89bcd9bbf322d9c3b101487c39	980245974	FAC 0240312025	0061550621	\N	Endesa Energia S a Sucursal Portugal	2025-10-18 00:00:00	21.49	4.47	25.96	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.452
cmng3bg0e00prrkt4gezo7puo	0ae6f1a94c265da091a51d0ec01d845ebaa1a86dcb546a3c5f52d1391df0732a	980245974	FAC 0220312025	0053496847	\N	Endesa Energia S a Sucursal Portugal	2025-09-09 00:00:00	24.30	4.41	28.71	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.47
cmng3bg0l00psrkt43kxujuhn	d869d781457dfe313aa4e182748d13cf1c5fbffadfabc5d8bfafc0a3fdebe18f	980245974	FAC 0240312025	0061494147	\N	Endesa Energia S a Sucursal Portugal	2025-09-18 00:00:00	18.08	4.36	22.44	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.477
cmng3bg0q00ptrkt4al24h362	cdf80977ab0d02503170a212777c4789163272ba5ca33b51908df77bd13e0dcd	516676180	FT FT25	140208	\N	Ibelectra Mercados Lda	2025-10-23 00:00:00	48.12	4.31	52.43	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.482
cmng3bg0v00purkt4g64maxwg	15af2edd108a8ba46f6ccfd7cc0b30f6d69059471ff543cf94a658976c33c826	980245974	FAC 0240312025	0061531513	\N	Endesa Energia S a Sucursal Portugal	2025-10-08 00:00:00	24.10	4.31	28.41	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.487
cmng3bg1100pvrkt4g7fj8m55	c8502e2b4bb2093b90e33b2e964c1e1a46beb1d5b92634b689fd54a79484adc9	516676180	FT FT25	101599	\N	Ibelectra Mercados Lda	2025-08-25 00:00:00	33.89	4.27	38.16	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.493
cmng3bg1800pwrkt4tdh27xq2	ce0c80435cb3aebe5b2b1bd9862fc3bc1c30e20866145df003a7b04de0d5f429	505993082	FAC 0210322025	0049115844	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-11-21 00:00:00	84.76	4.26	89.02	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.501
cmng3bg1f00pxrkt4zpmeb3ry	52540a8580e11ad8203e698dbcb0f6be6b7a25f68ba6ca03daf43b7e7b3ab14c	510450024	FR 003	2511941	\N	Ifthenpay Lda	2025-11-30 00:00:00	18.18	4.18	22.36	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.507
cmng3bg1q00pzrkt4v0nf9812	163e6d0c4367555ddb98cc26075c327228a01ea76ac9eaef897d671843599557	505416654	DEV 4990372025	0003624	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-18 00:00:00	-17.89	-4.11	-22.00	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.518
cmng3bg1v00q0rkt4zb461avw	8001bc18b060cbcaeeda015063bcddfc3d34784476a76eb96282c33d074192cb	517857472	FS 1A2501	1794	\N	Cascading Dreams - Lda	2025-10-24 00:00:00	27.90	4.10	32.00	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.523
cmng3bg2100q1rkt4qfxz13yo	a8d96b2d78a95297f77ea69dd339df9b9e61c18d78b7966d55965f23796a3d16	506848558	FT 20250335701	003120	\N	Bcm Bricolage S A	2025-08-16 00:00:00	17.61	4.05	21.66	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.529
cmnhoyqao01awrkt4v28j8awz	c6405a5a3d3741f5aa660a411ad5e74522820aa1c4c0fa98b29b66a5f0ec1325	502544180	FT 101	036192595	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-05-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00
cmnhoyqav01axrkt4udx8wf9f	7b31ed09a968137905cff9ffa5948560f3311efc5f8cb910e5e1da147b647eb1	502544180	FT 101	034755120	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-04-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.008
cmng3bg2z00q5rkt4hlxv1gdl	ea761a3f0c68ab28a3c64891e74456c8de417addc068b822bc1f0d3f608c0f9c	510450024	FR 003	2528854	\N	Ifthenpay Lda	2025-12-31 00:00:00	16.08	3.70	19.78	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.563
cmng3bg3o00q7rkt4f4g14hbq	70599d61415f2928a1532e3382a86c1a8b28407f17305c828953a89d66e41adb	510450024	FR 003	2495450	\N	Ifthenpay Lda	2025-10-31 00:00:00	16.08	3.70	19.78	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.588
cmng3bg3y00q9rkt4y3usm6oo	a6d7ab65bb7a800945199199bbce4dbeae222ea1df18a5da2d8ca24a58481cf9	510450024	FR 003	2479141	\N	Ifthenpay Lda	2025-09-30 00:00:00	16.08	3.70	19.78	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.598
cmng3bg4700qbrkt403pyu1xu	00ee30147f98ab95f56783c5a5cf8b989cf814b94f4ffca0ddc9d33afc769c7b	505993082	FAC 0210322025	0049115843	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-11-21 00:00:00	74.60	3.65	78.25	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.607
cmng3bg4f00qcrkt4cwt0sp44	3c6ef32d0c161f5ddb19260937b9a19839fa27f083b7128808e87750fcfabf6a	505416654	FAC 4990022025	0001419	\N	Ikea Portugal Moveis e Decoração Lda	2025-08-18 00:00:00	15.45	3.55	19.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.615
cmng3bg4m00qdrkt4ms8ne0io	52122d03eb97470a7401350ba412e15bb02a7a6fe6e8d9bd5521786d2245594c	505993082	FAC 0210322025	0049081542	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-10-02 00:00:00	80.35	3.52	83.87	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.622
cmng3bg4t00qerkt4uvvn8uwf	e7b8b295ebd3c9e3921c81a42a476c3fe2af8a37f3068c426ccb634231debd3a	507718666	NCR 000	2524991	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-08-04 00:00:00	-56.87	-3.41	-60.28	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.629
cmnhoyqb201ayrkt41y03awcp	a8fc822361786a6d3d3618714eaaa0c06b44a8162636461d0d2392b805b7542a	502544180	FT 101	033318833	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-03-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.014
cmng3bg5400qgrkt4bcwzk3fh	49ee877076de257412df5f43c4f097c07fe891a0c4e1d58ba7cb2b658743a784	505993082	FAC 0210322025	0049041014	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-08-04 00:00:00	74.80	3.28	78.08	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.64
cmng3bg5o00qhrkt4u3q73zsf	08fe7c372810c6f9133729f3c7054278ec1681de2c84de2b2644d6fa008820bd	505993082	FAC 0210322025	0049059588	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-09-01 00:00:00	74.13	3.26	77.39	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.66
cmnhoyqbb01azrkt4lx5u6pln	e0db41f2fe3fe4aeb25d2e44e02ec13e7f58337786f12b793be9860d9df3c601	502544180	FT 101	031899460	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-02-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.023
cmng3bg5x00qjrkt4w38x0ddx	a32cae3a0857894e989a038db811caaf14b33fba553802f74bd893da95d67ce7	505416654	FAC 0090712025	0041726	\N	Ikea Portugal Moveis e Decoração Lda	2025-12-28 00:00:00	22.38	3.07	25.45	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.669
cmng3bg6e00qkrkt4tyr3ysdz	3dc56091e5a411072969ebd7ccf82466c72340d6bf81de220b8c2b0104e87d5c	502855363	FR SE2522	4739	\N	Narciso Gomes Componentes Electronicos Lda	2025-08-22 00:00:00	13.30	3.06	16.36	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.686
cmng3bg6m00qlrkt4ul9pwgzm	3980773fabfb1eca95855b1e9cb6f4eed93b75714f86fcaf70374f133e3d40f6	157242102	FS 2025	2116	\N	Joaquim Jorge Pereira da Costa	2025-08-29 00:00:00	11.71	2.69	14.40	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.694
cmng3bg6r00qmrkt4qacfztoz	bfdb12f80a0a5cc7c9636ebe6161df5be1100dba64b11184a65acf06ef7d6f7c	516676180	FT FT25	171816	\N	Ibelectra Mercados Lda	2025-12-19 00:00:00	21.23	2.67	23.90	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.699
cmng3bg6x00qnrkt47og4ktzx	90e213cf8f2e4297e26f80a3cb05775865adbf6e2511f98151b35a91b18d0f7d	505993082	FAC 0210322025	0049139130	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-12-26 00:00:00	58.44	2.66	61.10	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.705
cmng3bg7400qorkt48924j22u	cca1a3141db21e7a241f910e4337f7a6a299ecbe6e2e7345acdd8475b7d7acac	505993082	FAC 0210322025	0049122179	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-12-02 00:00:00	61.46	2.64	64.10	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.712
cmng3bg7900qprkt4oej6p32m	d9c8f743c913f3956ae71a65e66c046c5dcd208efd0eff53ce0a70624c155671	509559980	11 I25	1659	\N	Rainha da Chuva - Unipessoal Lda	2025-09-05 00:00:00	11.38	2.62	14.00	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.717
cmng3bg7h00qqrkt4cnqlpkei	48d01ec744d64dcc3168638e722bdc8b76f116beaa164cb8fb486b4d335d9546	505993082	FAC 0210322025	0049139128	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-12-26 00:00:00	51.66	2.25	53.91	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.725
cmng3bg7o00qrrkt40cce1gmg	e975bcad7105c1e9e49a1a6024dacb681db6a67603bd59046dcd887e8af773c5	507718666	FAC 009	95661753	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-11-27 00:00:00	35.87	2.15	38.02	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.732
cmng3bg7t00qsrkt4vrk4ni6v	c1628b176b4541ef6aaf000cf869ae17f7c777a9297fe7d40a8861ddcfc26c6e	503301043	FS FS.2025	6937	\N	Ferragens e Ferramentas S Gonçalo Lda	2025-08-08 00:00:00	9.31	2.14	11.45	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.737
cmng3bg8000qtrkt4jykfkr0s	7596b924d2d73ff83dda1ed029e9a72fb2b76210b67914adc88ab1de261602d2	516676180	FT FT25	116899	\N	Ibelectra Mercados Lda	2025-09-19 00:00:00	11.28	2.11	13.39	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.744
cmng3bg8600qurkt4g2x4lger	f28561d39af44f6447ee52fa60d9a3f00917e20903a7de7fd5e68e3aec1d2f67	516676180	FT FT25	097536	\N	Ibelectra Mercados Lda	2025-08-19 00:00:00	11.28	2.11	13.39	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.75
cmng3bg8b00qvrkt4tbrir32w	cbfb7c0f3df5f2e33d1ddfc4486d032f358b3f5a699846d2f095541908f77658	516676180	FT FT25	120742	\N	Ibelectra Mercados Lda	2025-09-24 00:00:00	29.27	2.10	31.37	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.755
cmng3bg8j00qwrkt4rf5huw28	e0a2c1fafab43f8b01e978c3959f4b9a70290da78521fa6b43548794d35ee0e4	516676180	FT FT25	136430	\N	Ibelectra Mercados Lda	2025-10-20 00:00:00	11.32	2.07	13.39	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.763
cmnhoyqbg01b0rkt42xtg0ukf	10879c533166ef1a185f3786ae9d672a0571cd17e2a471e4f05223436902c0cb	502544180	FT 101	030473363	\N	Vodafone Portugal - Comunicações Pessoais S A	2022-01-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.028
cmng3bg8r00qyrkt4t1fq1ty1	932962836e9f124e7ff9545176bc96bb4d2ad6789640474e1c2b9cc4a7e8cff3	507718666	FAC 009	95717499	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-12-18 00:00:00	31.59	1.91	33.50	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.771
cmng3bg9900qzrkt4w884tjj3	97905c40f3440f9b679be1569b557ef7cc739a4ec4ad7939f57107978e64aedd	507718666	FAC 009	95536578	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-10-16 00:00:00	31.59	1.91	33.50	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.789
cmnhoyqbl01b1rkt42mgdgx1t	05eb3e651698ab9aa370aa211a2b5a2e528c5d9c50d54c4e8e142dfdc9983bd0	507603990	FSPOS 2022	194	\N	Domingos Alves de Sousa Unipessoal Lda	2022-06-10 00:00:00	38.03	6.98	45.01	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.034
cmng3bg9i00r1rkt4b0mnzrpy	578e92df041b8a0df287f8eebe1e565786ed5fcd039ef6ad9ae79bf41a900bc8	507718666	FAC 009	95478463	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-09-26 00:00:00	31.19	1.88	33.07	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.798
cmng3bga000r2rkt44evpdzgi	6ace80be1a055e587afff50813c6f32aa454feaaebd42e6f91d5d453398ae236	516676180	FT FT25	101140	\N	Ibelectra Mercados Lda	2025-08-25 00:00:00	23.38	1.74	25.12	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.816
cmnhoyqbt01b2rkt4snd5n1d7	864fe45dd1f36779b1170cb94c4c387ae7e450a3f6d8a12331d74076fa63b154	502604751	FT 202293	489777	\N	Nos Comunicações S A	2022-03-24 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.041
cmnhoyqbz01b3rkt4qq9j4dlq	80dc52da4719e8b1486409e9a5e89598756300071d40a1c2b049e14c8ff9a4ef	502604751	FT 202293	295107	\N	Nos Comunicações S A	2022-02-24 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.047
cmng3bgar00r5rkt4k3kmad94	17cef61024502080a31a89bee835f393d59335a38d9d1db30ebfd2d7bfd43200	505993082	FAC 0210322025	0049072952	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-09-18 00:00:00	35.73	1.38	37.11	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.843
cmng3bgbb00r6rkt45ubz6azh	25bcc365fce5431b1be0a0424cfbf5fd83fe35c0c748d589306b9d8c04bc2e6c	506848558	FT 20250335201	002730	\N	Bcm Bricolage S A	2025-08-20 00:00:00	6.00	1.38	7.38	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.863
cmng3bgbo00r8rkt42wuhrpka	da26a0f056acb5ac1e206ee3b4d9836cea6f1c64d4dfff88300d19b51be286ae	500393729	FS 1A2505	18495	\N	Pastelaria e Confeitaria Moura Herd Viuva Guilherme Ferreira Moura Lda	2025-10-30 00:00:00	10.49	1.36	11.85	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.876
cmng3bgbz00rarkt4ozhoxpok	116450b9916486f988fb3a1c5cbb808cd62e0d4658862be80973e1de78b2dc00	505993082	FAC 0210322025	0049097279	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-10-27 00:00:00	37.09	1.29	38.38	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.887
cmng3bgc800rbrkt48q660lzy	8ed8db42d98e6f93085e6e3ad0b475b77dbc5d822e6115a3904ef269f3d13dbe	505993082	FAC 0210322025	0049099193	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-10-29 00:00:00	32.54	1.22	33.76	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.896
cmng3bgcf00rcrkt4m1l6nx4w	bafac75c85abb024a1da10b0f3456050e829fe26550930963b3012659b72a1cc	505993082	FAC 0210322025	0049097277	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-10-27 00:00:00	33.70	1.09	34.79	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.903
cmng3bgco00rdrkt4hpuxlbjz	a3739189659376433b88ec8dabb752f61af34912991355c87b5e5fc90ba907bb	507718666	FAC 009	95381586	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2025-08-20 00:00:00	18.21	1.09	19.30	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.912
cmng3bgcv00rerkt4yhbmtfbh	841adf37292e6bae32a078b09e4ec78fa62e17abb0e6a06b83768f7a663371a3	505993082	FAC 0210322025	0049054165	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-08-25 00:00:00	31.33	1.03	32.36	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.919
cmng3bgd400rfrkt4ozp4ywhz	3d4c43116f03044e755431c203126aba28ab66bbeae2bd098614ea5819d06931	505993082	FAC 0210322025	0049054163	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-08-25 00:00:00	31.33	1.03	32.36	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.928
cmng3bgd900rgrkt4phil637p	b498d8afdc415962b08358db451d07d06e9cd11948df7a631c96a358064d7f45	505993082	FAC 0210322025	0049072951	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-09-18 00:00:00	28.95	0.97	29.92	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.933
cmng3bgdf00rhrkt4pfv49l99	4354aa394ff014feb984af30eb9137d59ecb2546867bb9600f40751a5166e01d	503301043	FS FS.2025	6981	\N	Ferragens e Ferramentas S Gonçalo Lda	2025-08-11 00:00:00	4.23	0.97	5.20	Fatura simplificada	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.939
cmnhoyqc501b4rkt460e1ffzi	fa2adc1b687576b942226abdc62567f64275429664d2b9ec739dd3b93b440bb8	502604751	FT 202293	91386	\N	Nos Comunicações S A	2022-01-27 00:00:00	30.07	6.92	36.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.053
cmng3bgdw00rjrkt4s7wmmiuq	d950c4c218c5f158159c56efd0bc65414a165da66cf6f00319c70e63857da750	506848558	FT 20250335701	003472	\N	Bcm Bricolage S A	2025-09-10 00:00:00	3.49	0.80	4.29	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.957
cmng3bgeu00rlrkt4skvamkuv	cf2a52bd3d4b80f965a4afa1bbede72a809ad1278fa6d98ffad6d3a82cc2f4dd	506848558	FT 20250335201	003620	\N	Bcm Bricolage S A	2025-10-20 00:00:00	5.30	0.69	5.99	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:15.99
cmng3bgf400rnrkt4kwuz8ywy	3fb3e5e124d0a19cb202e244fcf7e57226d453d8be412f5dd006f1cd2eb38019	505993082	FAC 0210322025	0049101803	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-11-03 00:00:00	21.19	0.64	21.83	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16
cmng3bgfc00rorkt4s7kczafw	2dd0e20e9c179e77e180a3b0c95e35b56d0e50cf0a20ef0c58bfebecef040763	505993082	FAC 0210322025	0049082810	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-10-03 00:00:00	20.52	0.62	21.14	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.008
cmng3bgfk00rprkt4mnrgebtn	bf3a121935acc2e504787f3ece984efeca297ff9f759252eb408ade496d7a048	505993082	FAC 0210322025	0049059717	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-09-01 00:00:00	19.87	0.60	20.47	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.016
cmng3bgfu00rqrkt4ew2c5vxr	94a885a202f7ccb94912941d868e2358db32a6b5647caf6cf87e9e79b685b05d	505993082	FAC 0210322025	0049122266	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-12-02 00:00:00	18.53	0.56	19.09	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.027
cmng3bgg300rrrkt4m6ort5x5	5103fddee6bfbba0502201db01b7172de80f6fb64cff80ab19752493b6fa25a6	506848558	FT 20250335201	003496	\N	Bcm Bricolage S A	2025-10-13 00:00:00	2.43	0.56	2.99	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.035
cmng3bggh00rtrkt4mob3fj4o	7f7f4e526fd5f39ee83eb506da31481fd78f4bf34a3dd69d975c9377b3b2c456	505993082	FAC 0210322025	0049048316	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2025-08-12 00:00:00	13.91	0.42	14.33	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.049
cmng3bggo00rurkt4s1qhc0d2	dc252ce289ed9ece811b32d1a863c0a112f8a641aa36fbd0dc9a81567c65f032	506848558	FT 20250335601	003183	\N	Bcm Bricolage S A	2025-08-21 00:00:00	1.46	0.33	1.79	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.056
cmnhoyqcd01b5rkt4vuttm9ur	2b62225480f43a174ba168a49db50d96d11e613519cac1b8c112ea00eeaa63fd	502604751	FT 202292	3024804	\N	Nos Comunicações S A	2022-12-19 00:00:00	29.26	6.73	35.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.061
cmnhoyqcn01b6rkt41dvd64w3	db7fb106b53f82040d659b3708285608ee3e896a18057a9693f83a13837afcdd	502604751	FT 202292	2761117	\N	Nos Comunicações S A	2022-11-18 00:00:00	29.26	6.73	35.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.071
cmng3bghs00ryrkt4nnho0o62	85f2ba413b113a8292d7b08799afcb2ad830676bea51388f9549f8e909314e12	510914713	FR premium	323025	\N	Observador On Time S A	2025-09-18 00:00:00	2.82	0.17	2.99	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.096
cmnhoyqcy01b7rkt4kaoimpd1	5255332e3d83d03d084be4e31126b4e7e430f1a8872217a18750e698bb3e2b28	502604751	FT 202292	2506163	\N	Nos Comunicações S A	2022-10-18 00:00:00	29.26	6.73	35.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.082
cmng3bgin00s0rkt4dyl71v7j	ad970decbe22144deb2f770ea7709f53f264a72d9ef86007debca784d488134d	502075090	FT 5212025	2943	\N	Arcol, S.A.	2025-12-30 00:00:00	0.00	0.00	0.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.127
cmng3bgjb00s1rkt4g59p6znj	121db7afb93b792fa971a791d94ecd441f597d4c31146ea3426b012f08206248	514280956	FAC 109	1184804960	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-12-18 00:00:00	21.12	0.00	21.12	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.151
cmng3bgjq00s3rkt4z8f987hq	691a1a03e2c356f98f5ee8f4df0bef6cbdcc2b123bdee4f072b605741bdc1af0	507432444	NC NC25_25	10	\N	Sampulau Lda	2025-12-12 00:00:00	-42.50	0.00	-42.50	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.166
cmng3bgjy00s4rkt45ao9r7gf	62ff350fed00254855b644cd24087c733578176c5a01a22633c5b81c60285937	507432444	FT FT25_25	155	\N	Sampulau Lda	2025-12-12 00:00:00	42.50	0.00	42.50	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.174
cmng3bgk500s5rkt4pscuk753	fd0adc69766b58a65915e782b87b07802408a4b8e2af4e2f6053d4bbbb24875d	213912210	FR ATSIRE01FR	58	\N	Miguel Angelo da Silva Vaz	2025-12-09 00:00:00	120.00	0.00	120.00	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.181
cmng3bgkb00s6rkt49euk7l0h	39b6524af77e98dd0fd84050a711dcea87c7aa2152a615950f6a31f91e3bddd4	514280956	FAC 109	1184750168	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-11-27 00:00:00	23.44	0.00	23.44	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.187
cmng3bgkl00s8rkt45jjotxf6	027685b2dad1ce1845bdd7e7b359eb56959f3c77178fd624c78016efaacc1cad	502075090	FT 5212025	2567	\N	Arcol, S.A.	2025-11-17 00:00:00	0.00	0.00	0.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.198
cmng3bgkr00s9rkt4d6w221hk	d26df015dac40cdf91b4a2388a4c76b83f0f9c831a3b5df59423c175da36d34a	980420636	FR 009	008866211	\N	Zurich Insurance Europe Ag - Sucursal Em Portugal	2025-11-06 00:00:00	250.06	0.00	271.62	Fatura-recibo	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.203
cmng3bgl100sarkt4ft88h48x	955187f8948e6e76e1faafe37ee12c7e12ef2e217ee52a212a552734eb58d0a7	514280956	FAC 109	1184626749	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-10-16 00:00:00	21.12	0.00	21.12	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.213
cmng3bglk00scrkt4lgp7txo1	d7fb196f404f9c23127b7d4d79ab5edac17c5b1715596d3799845b19dea6f074	514280956	FAC 109	1184569653	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-09-26 00:00:00	20.05	0.00	20.05	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.232
cmng3bgm200serkt49wmiz1s8	d6d5a65942ab7cce65d61cac79aec6a614cfa95a751814dded468abba14ba3a5	502075090	FT 5212025	2148	\N	Arcol, S.A.	2025-09-24 00:00:00	0.00	0.00	0.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.25
cmng3bgmc00sfrkt4axnmxvqx	8f2c66e1a6c7442fd05ab7834f17b220c26c6294a731181c1690e35ba33b73dd	514280956	FAC 109	1184474655	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-08-20 00:00:00	12.52	0.00	12.52	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.26
cmng3bgmm00shrkt4dkgylg7p	5f52f7c77187a83b13994da4cb420e6ab162a48fd6b4791f74f7d574ba5192a1	502075090	FT 5212025	1894	\N	Arcol, S.A.	2025-08-19 00:00:00	0.00	0.00	0.00	Fatura	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.27
cmng3bgmw00sirkt4lkwf2q8k	8ce726fc86a7414fceafb30b3e12e61da468f581ad0505c34af670e605cee849	514280956	NCR 091	920039540	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-08-04 00:00:00	-25.07	0.00	-25.07	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.28
cmng3bgn500skrkt4zzahbem1	80073e9de6f3e93a498144658e758707e3b7ddb8d0efbb70c43734875fc5fbee	514280956	NCR 109	1184421318	\N	Empresa Municipal de Ambiente do Porto e M S A	2025-08-04 00:00:00	-59.26	0.00	-59.26	Nota de crédito	cmng3betp00lbrkt4ugvuvo54	2026-04-01 13:37:16.289
cmnhoyqd801b8rkt4eqapsh9c	111f1bd6d614f8e12a8838e699d6a75bc6e36957dd45aadd6a5d322ed4efcd58	502604751	FT 202232	28166	\N	Nos Comunicações S A	2022-09-23 00:00:00	29.26	6.73	35.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.092
cmnhoyqdg01b9rkt450lg2ayc	cc8d54c346e0e4bf793f640553dcd052bfba437d6ef241b841338a2156760956	157242102	FS 2022	2188	\N	Joaquim Jorge Pereira da Costa	2022-09-15 00:00:00	29.27	6.73	36.00	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.1
cmnhoyqdn01barkt4b2yegf6n	847f3b3cf668eb76e1c3b773733567a65aea9ce0a949105ceba6d74fd70105e0	503301043	FS 2022	8626	\N	Ferragens e Ferramentas S Gonçalo Lda	2022-09-15 00:00:00	28.79	6.62	35.41	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.107
cmnhoyqdu01bbrkt40yxhzydq	91a5e9aaeea184427cf2689ffccff889edd9fd4c6a688c2652ba3c55bd9da6b2	980245974	FAC 0240312022	0061447596	\N	Endesa Energia S a Sucursal Portugal	2022-11-16 00:00:00	39.87	6.53	46.40	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.114
cmnhoyqe201bcrkt49u7po2yy	b827d456ef2cd53d0dbd863903b63eb2e09b030e89a05640d209539d2f60c18b	980245974	FAC 0260312022	0069253618	\N	Endesa Energia S a Sucursal Portugal	2022-07-11 00:00:00	28.53	6.49	35.02	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.122
cmnhoyqe801bdrkt4ih205f9s	75d641935203195e0a11ac632c14029b7b7b1cab00af330dd05c14f46d251c1e	506848558	NC 202203308	000139	\N	Bcm Bricolage S A	2022-01-06 00:00:00	-28.11	-6.47	-34.58	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.128
cmnhoyqef01bfrkt44viglsc1	e9c66c742a3ec86d7bfca1fc5c4934dae12df2ea09345c25bd3c21dc7fdfdd95	506848558	FT 202203351	000376	\N	Bcm Bricolage S A	2022-07-16 00:00:00	28.10	6.46	34.56	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.135
cmnhoyqf501bjrkt4s62zfl7v	3ecef7bacffda064d6afc4690379b2791c97afe13d63e9c69ecb2acf715b506e	503502820	FT 2022A11	3695	\N	A P Freitas Lda	2022-09-09 00:00:00	25.29	5.82	31.11	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.161
cmnhoyqfb01bkrkt493vn7x7a	f389c3edd31a55ab07517c3c1d4456788a3df6f0a8ad10ada8b18e430fefb20f	980245974	FAC 0260312022	0069250471	\N	Endesa Energia S a Sucursal Portugal	2022-07-08 00:00:00	31.53	5.69	37.22	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.167
cmnhoyqfk01blrkt44312bxe6	41c23d9387cf87fdfd75b51d0639265192dab275d407dbebae735bfd1db707b2	506848558	NC 202203307	002938	\N	Bcm Bricolage S A	2022-11-17 00:00:00	-24.38	-5.61	-29.99	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.176
cmnhoyqft01bnrkt4z8ceheyn	ecb35d1e8608645997399e5ca2909a07c7a97d9d91f5d7f0e912b3e9ce5d63fa	506848558	FT 202203307	003580	\N	Bcm Bricolage S A	2022-11-17 00:00:00	24.38	5.61	29.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.185
cmnhoyqgg01bprkt4rkiib2lm	726d3ada62153dbdd7ba8898d29676c18461d312f0364d5f6ad9eca69e063f59	506848558	FT 202203303	007842	\N	Bcm Bricolage S A	2022-10-17 00:00:00	24.38	5.61	29.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.208
cmnhoyqgr01brrkt4g3dx9923	24f2d95b6dbbb2d93ec600640f682e510c2997171680881ef237f27cb2893f8c	502011475	FS AAH029	621264	\N	Modelo Continente Hipermercados S A	2022-09-18 00:00:00	24.39	5.61	30.00	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.219
cmnhoyqgv01bsrkt4px20l1zv	16a17569b2a32b686e9d4ff8b072bc74d2657c57c7b9bae4e03f77be053fe70f	506848558	FT 202203304	001829	\N	Bcm Bricolage S A	2022-03-05 00:00:00	24.38	5.61	29.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.223
cmnhoyqh601burkt4n77cvih6	300e091f9af57aec3a5d00834d0b722d9b474f2c3d7362af6c6664f34efb9ca0	980245974	FAC 0250312022	0065220134	\N	Endesa Energia S a Sucursal Portugal	2022-06-16 00:00:00	32.10	5.31	37.41	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.235
cmnhoyqhd01bvrkt478twp3jy	1aefb851ab4584db085b0374fd6e7f22f42099baf7c2fba15682d1d275fad9b5	980245974	FAC 0230312022	0057270994	\N	Endesa Energia S a Sucursal Portugal	2022-07-20 00:00:00	31.31	5.28	36.59	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.241
cmnhoyqhi01bwrkt433nbbpzj	93b5cf5c2942f0091c21590cd56c6ad20f0921add81da7629009d41600407136	980245974	FAC 0260312022	0069206530	\N	Endesa Energia S a Sucursal Portugal	2022-06-08 00:00:00	29.34	5.24	34.58	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.246
cmnhoyqhp01bxrkt4g09gof9i	226aa4157afdc0f1db6831fc6faefdea87520c93e8fcedf95fc7aa801f43d8ad	980245974	FAC 0250312022	0065485985	\N	Endesa Energia S a Sucursal Portugal	2022-12-08 00:00:00	23.10	5.13	28.23	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.253
cmnhoyqi001byrkt4h6mz9hxy	aa9740b4b1d8942a08b33c28e898b8b713f44755e77150e83a4c00f75c405f0b	500389217	FT FT22002	14	\N	Mabera - Acabamentos Têxteis S.A.	2022-03-16 00:00:00	22.18	5.10	27.28	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.264
cmnhoyqir01bzrkt4xuvjv8fl	e09eedd842f27cd620d5dc83e2808c913d60fb74e02a5fc633f5b548658a62c5	980245974	FAC 0280312022	0077005210	\N	Endesa Energia S a Sucursal Portugal	2022-01-08 00:00:00	21.92	4.97	26.89	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.291
cmnhoyqj401c0rkt4bocx99rx	e4b0e8f55cccdec5a40114ce582c2a65f114eb73bb1e84d0702e8b0bd15ab920	980245974	FAC 0260312022	0069434422	\N	Endesa Energia S a Sucursal Portugal	2022-11-08 00:00:00	22.07	4.93	27.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.304
cmnhoyqjb01c1rkt49yp748l0	4684762400a2249dec849395da2b0b30a764303444297a316bf427abaf6dbb4b	980245974	FAC 0260312022	0069434421	\N	Endesa Energia S a Sucursal Portugal	2022-11-08 00:00:00	28.72	4.90	33.62	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.311
cmnhoyqjg01c2rkt4pep7ea4r	04ffabbde91b09791353868401007338869ae3f3fef3fa95400fd8187f9a69a9	980245974	FAC 0220312022	0053427941	\N	Endesa Energia S a Sucursal Portugal	2022-10-31 00:00:00	29.61	4.87	34.48	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.316
cmnhoyqju01c3rkt46f6351xy	1c1a71f5ad21eeef92be864839a4a57453abceef80ac5aa5c2edd179618033e7	980245974	FAC 0200312022	0045118270	\N	Endesa Energia S a Sucursal Portugal	2022-10-15 00:00:00	27.95	4.77	32.72	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.33
cmnhoyqk001c4rkt4d2x08o4w	c639d2b5b80e1505b00389f86e49fe3260f5d426aba96c52b6479c59ad45eac7	505993082	FAC 006	60550982	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-07-01 00:00:00	93.19	4.40	97.59	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.336
cmnhoyqk401c5rkt4d5hy1kdb	71e24548bccb9ce3b528810a6e83d170f63aa7c156f4b52fa0b9f4970b821efc	980245974	FAC 0260312022	0069294912	\N	Endesa Energia S a Sucursal Portugal	2022-08-08 00:00:00	23.74	4.26	28.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.34
cmnhoyqkc01c6rkt4i0glz363	add95e64f5b6f0df1a28a4e8f977eedc9bd8c9de40cd8357ed1fdce9cbfbc3e1	503630330	FS AUM003	122904	\N	Worten - Equipamentos Para o Lar S A	2022-09-18 00:00:00	17.88	4.11	21.99	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.348
cmnhoyqko01c8rkt47sdjm877	9379aa6de748e268bd756100e5404cafec7006adaedac71c9cc64872a04c0bf1	980245974	NCR 0000312022	0001059909	\N	Endesa Energia S a Sucursal Portugal	2022-10-15 00:00:00	-27.98	-4.04	-32.02	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.36
cmnhoyqkw01c9rkt47wynt82s	d8d749a20ba67d5634a046709f752b9a98d3b0997aea53604a60b0de44c0fa88	980245974	FAC 0260312022	0069383678	\N	Endesa Energia S a Sucursal Portugal	2022-10-07 00:00:00	27.98	4.04	32.02	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.368
cmnhoyql301carkt4nsnbheer	a38c9feb8889b92b7010ae6878666d5f0a84ad9dda3cf897ddebdb338471f2a3	980245974	FAC 0250312022	0065342500	\N	Endesa Energia S a Sucursal Portugal	2022-09-07 00:00:00	22.86	4.02	26.88	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.375
cmnhoyql801cbrkt4jmpoo8vq	4ae09a4117d4edc284b846dbace229322a06976a3afbd9f719e6d4a55d1763dd	506848558	FT 202203304	006552	\N	Bcm Bricolage S A	2022-08-14 00:00:00	17.22	3.96	21.18	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.38
cmnhoyqlk01cdrkt42gnok7u7	f127d60def91bcb5bf4020cda6632eeff94db2fffe752286e604089d627abaed	980245974	FAC 0200312022	0045129995	\N	Endesa Energia S a Sucursal Portugal	2022-10-17 00:00:00	22.56	3.95	26.51	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.392
cmnhoyqlq01cerkt4uppyga8l	ed8c59b688cbcda42465f4436d8b72d9c1ba6844b7e1e7777788fe5a7711d230	506848558	FT 202203352	000546	\N	Bcm Bricolage S A	2022-08-11 00:00:00	17.06	3.92	20.98	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.398
cmnhoyqm101cgrkt4r5t7nlqi	2fdf37205dc723b9ad961a2aedf659f66ebff36f63fcdb3220b9f6bbb5c21290	515096180	FT FOLS3230	26724	\N	Portas de Guimarães Lda	2022-05-01 00:00:00	65.00	3.90	68.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.409
cmnhoyqm901chrkt4ye6b4al8	d73c0edf6be14fd5904d2cf21a3f1151d704801cb222292644b24fcaee8e14ee	505993082	FAC 006	60612349	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-11-21 00:00:00	74.90	3.86	78.76	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.417
cmnhoyqmi01cirkt4lmimdwlq	178791c657d5eeab4371b8da039d91ba75385d4d24df951372e9f12a3d351031	502075090	FT 501	2022069004	\N	Arcol, S.A.	2022-09-30 00:00:00	18.34	3.83	22.17	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.426
cmnhoyqmv01ckrkt4hmc121w0	8ce403ec6d2c4c53d55e4652e6faba3170170323b5a49f92de4f7168ab1f94a0	980245974	FAC 0270312022	0073293789	\N	Endesa Energia S a Sucursal Portugal	2022-08-16 00:00:00	23.29	3.73	27.02	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.439
cmnhoyqn301clrkt4yf31r3is	248f68293b3e54101f39bbe25c79b52e39f1b2c506a7e76a87352ba05c5d4d5f	980245974	FAC 0270312022	0073245620	\N	Endesa Energia S a Sucursal Portugal	2022-07-12 00:00:00	19.78	3.71	23.49	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.447
cmnhoyqng01cmrkt4lhf6239b	acad6d046c902ec31d593d966fface5b86c0b9fe5d61124f3f22275cc17bcd89	505993082	FAC 006	60628652	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-12-29 00:00:00	77.59	3.64	81.23	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.46
cmnhoyqnq01cnrkt4g0px8fy3	dab1ceec5dfe10a22e7e1de6962d552b210a1faf48469d53f7e944b59f7fec97	506848558	FT 202203352	000532	\N	Bcm Bricolage S A	2022-08-08 00:00:00	15.76	3.62	19.38	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.473
cmnhoyqo701cprkt45cow4xgu	2c5f8f54030b725402bc1159b7922d25dcb5275dec995cd1f14f5ce62df112c5	980245974	FAC 0230312022	0057361457	\N	Endesa Energia S a Sucursal Portugal	2022-09-16 00:00:00	22.04	3.57	25.61	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.487
cmnhoyqoh01cqrkt4byhtl7pd	59e9844d050358ac01eca4382fe11e0f570ff3ed1e214bf9aa7c558dea77c24d	503789372	FAC 1303222	0005134	\N	Staples Portugal - Equipamento de Escritorio S A	2022-05-15 00:00:00	15.48	3.56	19.04	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.497
cmnhoyqop01crrkt4ze08na7d	5e67d2590f636e9e770ae2b8d97df99ddaea71e30e5c5828af5b73e94fd65c67	506848558	FS 202203353	005283	\N	Bcm Bricolage S A	2022-09-10 00:00:00	15.42	3.55	18.97	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.505
cmnhoyqox01ctrkt4rjpr5pvl	d79508a54ce2025821dde3e00114803fe8d667a88c39dc71605b0c10df4fb922	980245974	FAC 0270312022	0073278966	\N	Endesa Energia S a Sucursal Portugal	2022-08-06 00:00:00	18.32	3.48	21.80	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.513
cmnhoyqp501curkt42i6y8api	9a904d2b5c0246daf23883ca356819c7b5cbcb2fed4eba8818dba51fe94ab03d	980245974	NCR 0000312022	0001077739	\N	Endesa Energia S a Sucursal Portugal	2022-10-17 00:00:00	-22.54	-3.45	-25.99	Nota de crédito	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.521
cmnhoyqpb01cvrkt4km92e2ch	a6986e145fa707649c23c19e4fc5a9e97cd57d398276ae127901eda6a2601163	980245974	FAC 0250312022	0065390112	\N	Endesa Energia S a Sucursal Portugal	2022-10-08 00:00:00	22.54	3.45	25.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.527
cmnhoyqpg01cwrkt44gxe3t4k	2e41651139047bff679cb2f03b35eceb5af5e9a85d96ec6e137a94c6b790ead3	980245974	FAC 0280312022	0077150119	\N	Endesa Energia S a Sucursal Portugal	2022-05-06 00:00:00	17.57	3.41	20.98	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.532
cmnhoyqpo01cxrkt473rvawyo	cc06c76303da192550d817dddb3a62d41989275003f13955669185b5d782420d	980245974	FAC 0270312022	0073321154	\N	Endesa Energia S a Sucursal Portugal	2022-09-05 00:00:00	16.94	3.33	20.27	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.54
cmnhoyqpu01cyrkt4wc5z0p8l	5a4dfd4b2dcc9d3bc42debab7ba4e1b62564c749e76a250694ca281876391c31	505993082	FAC 006	60576608	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-09-02 00:00:00	71.82	3.30	75.12	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.546
cmnhoyqq001czrkt4zs0i02bn	0b2d85e1a3b18336c47ee0292e58183c76cd89e256f73033267d4bf1cdde77b3	980245974	FAC 0280312022	0077112511	\N	Endesa Energia S a Sucursal Portugal	2022-04-08 00:00:00	17.12	3.29	20.41	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.552
cmnhoyqq601d0rkt4w7kgib5j	a7dc8166342d8ccba84a54e0887879b9c5ef8386ed2d96ae76c29ad058551340	506848558	FS 202203306	028333	\N	Bcm Bricolage S A	2022-09-13 00:00:00	14.20	3.27	17.47	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.558
cmnhoyqqd01d2rkt491tdig74	40ed74eaf305cac9373e6e78e2ae0bd15f7265656f4db259d449696942cd34b2	980245974	FAC 0200312022	0045065695	\N	Endesa Energia S a Sucursal Portugal	2022-07-12 00:00:00	16.76	3.27	20.03	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.565
cmnhoyqql01d3rkt44okme83n	36b2aabe801f04417a31a1ae67608d3834a0db719f6481977d84ea7fdc7bf878	505993082	FAC 006	60589763	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-10-03 00:00:00	66.31	3.05	69.36	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.573
cmnhoyqqq01d4rkt4w8kqa125	b10bf692ae5f91fb74d76ad24d594674c67a2becc3e80fb615deb7682b30f205	980245974	FAC 0270312022	0073041826	\N	Endesa Energia S a Sucursal Portugal	2022-02-07 00:00:00	13.59	3.05	16.64	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.578
cmnhoyqqu01d5rkt4i1f1lg44	73c19d3ea4f6373df5ac1c122c0d8eeb42bf5e300d7eec61d0dedd8f4d548fed	980245974	FAC 0280312022	0077076778	\N	Endesa Energia S a Sucursal Portugal	2022-03-09 00:00:00	13.36	3.01	16.37	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.582
cmnhoyqr201d6rkt45huc6y4q	8807a59079dc8bb5803390d1d4a92afbb14f43ba2ed6ff279b7a1014879105ed	502027614	FR 2022A15	16660	\N	Esperança, Lda	2022-12-09 00:00:00	13.05	3.00	16.05	Fatura-recibo	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.59
cmnhoyqr801d7rkt4i7mx0f8i	ac20502d2925b9920153d6f57cdc57ec2e9a78b15b82515a7c1518106b78bccd	506848558	FT 202203353	000210	\N	Bcm Bricolage S A	2022-08-02 00:00:00	13.00	2.99	15.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.596
cmnhoyqrk01d9rkt4hurqypxl	62de53bed8d68fd1e4c0c8287c717729cb56fb11d3f72c7d315b7f6d91cab05b	506848558	FS 202203305	043880	\N	Bcm Bricolage S A	2022-09-17 00:00:00	12.74	2.93	15.67	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.608
cmnhoyqrr01dbrkt4ub9zy3e1	6940deb0486974d0e7434111047400841cb49a0661b6bbaa74ba1bc2c08bc778	505993082	FAC 006	60516503	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-04-04 00:00:00	64.30	2.92	67.22	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.615
cmnhoyqrw01dcrkt47xaui0rt	8db61730bf7c8a8396f3771e114a761050696d8927036be69cb4cacdde8ebf28	505993082	FAC 006	60564127	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-08-02 00:00:00	61.38	2.83	64.21	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.62
cmnhoyqs201ddrkt476jbjl7y	cbb4cb49ec88196aac1a8d567c1653124cd38892777b310080846d372ccb0f6d	506848558	FS 202203304	048400	\N	Bcm Bricolage S A	2022-09-19 00:00:00	11.85	2.72	14.57	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.626
cmnhoyqsb01dfrkt40pm7cg2c	6368c3fb741decc3eb1cc6af354b7eb12800f7681a08b7f06c629a7fcc528607	503301043	FS 2022	6996	\N	Ferragens e Ferramentas S Gonçalo Lda	2022-08-01 00:00:00	11.80	2.71	14.51	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.635
cmnhoyqsi01dgrkt40nkd4f9f	98694d1683d40f95498266f892eeb1b02c721c9488abeba463c80a74b2e47a82	505993082	FAC 006	60539941	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-06-02 00:00:00	59.98	2.71	62.69	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.642
cmnhoyqso01dhrkt4dsxcb3p1	40f577e397233b6e5f4be18d62abf80edd63e0085818cec0f5c443e3aed06dda	505993082	FAC 006	60492833	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-02-01 00:00:00	57.64	2.64	60.28	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.648
cmnhoyqsz01dirkt4b1d251ci	a9c9f697a5ed73ecf07a96cfa3d482485ff449f8afa8e4fcdc54b57db5d85ea1	506848558	FT 202201153	002199	\N	Bcm Bricolage S A	2022-08-31 00:00:00	11.37	2.62	13.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.659
cmnhoyqtb01dkrkt4u6lb24g5	37f4fae766558b82583c691056329e5d2d8bf2461abca883896d64ef831b2150	980245974	FAC 0250312022	0065342501	\N	Endesa Energia S a Sucursal Portugal	2022-09-07 00:00:00	11.61	2.60	14.21	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.671
cmnhoyqtj01dlrkt4o5njvlcy	20d5b26feb4fb71a919bbbcc392b238b7921ee8f3e2424b10d31246fc7d44ef4	506848558	FT 202203352	001048	\N	Bcm Bricolage S A	2022-11-17 00:00:00	10.80	2.48	13.28	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.679
cmnhoyqtv01dnrkt4iv8h2rpp	874fdc43f1bc6ef4caea015ede14864ccf49d66559104c8a85bcae23bb9741ff	505993082	FAC 006	60616025	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-12-02 00:00:00	54.45	2.45	56.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.691
cmnhoyqu001dorkt48q6fys4i	6baf6632df0aeba2268363cc17817ea346ee009f339af8787fb3dc866847f861	505993082	FAC 006	60527219	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-05-02 00:00:00	54.45	2.45	56.90	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.696
cmnhoyqu601dprkt47cs1exfd	1574140b06cce76d69302937211e7a6603d08a26e22d25f6f583a8852bd21f91	506848558	FS 202203304	056936	\N	Bcm Bricolage S A	2022-11-17 00:00:00	10.22	2.35	12.57	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.702
cmnhoyqug01drrkt4uy7f9q7h	aa6175928e86817d8be7fb14bd2a28a06099a5ff7f9fcf3528d6ecf1ee4f5bb4	980245974	FAC 0270312022	0073115046	\N	Endesa Energia S a Sucursal Portugal	2022-04-10 00:00:00	10.39	2.32	12.71	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.712
cmnhoyqum01dsrkt4od8dz086	838ee2f8a3cee820bfbee5782d252a7b982f3eca040d50d9257bbe49f4fe5536	505993082	FAC 006	60627570	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-12-26 00:00:00	48.11	2.28	50.39	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.718
cmnhoyquw01dtrkt4aotjxijf	c99268a2a417cccf1e2b2aad706f2960703d2378cb660e4e84a55a20623f0265	516877364	FS0 22	12646	\N	Elegancia Erudita Lda	2022-12-02 00:00:00	17.52	2.28	19.80	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.728
cmnhoyqv201durkt4dt0jdpuh	8f87507b9b91997570bd477a8baa59af7acd7cc6a1582d3713ad5beade0be1c0	505993082	FAC 006	60503411	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-02-25 00:00:00	50.12	2.23	52.35	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.734
cmnhoyqvb01dvrkt4ezglp4vj	8f1a51166beeec46360d1fe90be51e1228ae76b3e04d5de535d0186e2bb9ca11	503789372	FAC 1303222	0003897	\N	Staples Portugal - Equipamento de Escritorio S A	2022-04-12 00:00:00	9.08	2.09	11.17	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.743
cmnhoyqvp01dwrkt46kv7hw91	f0f0523a81c3c98838d775b2dfa08510cc4664f5530484db93698b30c5a96a1e	505416654	FAC 49905720220052	463	\N	Ikea Portugal Moveis e Decoração Lda	2022-08-31 00:00:00	8.94	2.06	11.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.757
cmnhoyqvw01dxrkt40w8oo20l	aa2d8f09f91a200593aac6f3985dc52822e4242bfdbe3a0ffc6f830cdea1827d	506848558	FT 202203351	000552	\N	Bcm Bricolage S A	2022-09-06 00:00:00	8.60	1.98	10.58	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.764
cmnhoyqwm01dzrkt46a0cwvoh	0ef555e701e5a9482608e72394e94a56ba6633886789e26c1475a3567330bfdf	502075090	FT 501	2022068999	\N	Arcol, S.A.	2022-09-30 00:00:00	32.32	1.94	34.26	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.79
cmnhoyqwz01e1rkt4w81i2tnv	99c424774399dd4251d4c96e5b0b49b8978290479fa1c65bc91bba26acfb74da	515023264	FATS D22	2324	\N	Drogarias Pevidem Lda	2022-11-17 00:00:00	8.29	1.91	10.20	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.803
cmnhoyqx501e2rkt4fswlo3s2	1a8ff0694140b3dd962dfe26a9e9361d03d79fb3d5dd0fe7d1793821fd8bd4e9	980245974	FAC 0260312022	0069206531	\N	Endesa Energia S a Sucursal Portugal	2022-06-08 00:00:00	8.52	1.89	10.41	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.809
cmnhoyqxb01e3rkt409r9g5sx	66734dad55bd2edb3d0c24165f2e18b9af8bc4fdc6b7ada04325de290d76bce3	506848558	FT 202203352	001115	\N	Bcm Bricolage S A	2022-11-22 00:00:00	7.86	1.81	9.67	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.815
cmnhoyqxl01e5rkt4e4wism9h	0532d1a0674c8a6bd2cc2433800c250b53426ba1946fb5b5d3cfbca015608b0f	506848558	FT 202203351	000574	\N	Bcm Bricolage S A	2022-09-16 00:00:00	7.71	1.77	9.48	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.826
cmnhoyqxv01e7rkt4dl7703qh	fde7f0aa93a8fc16ca04c92aca39c6f298e373ad0aec7a6f880b087d840901cc	505993082	FAC 006	60602315	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-10-31 00:00:00	37.45	1.55	39.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.835
cmnhoyqy301e8rkt4qqekkmkh	8f0f1b9c1b07cf9e4f506e2dd05971408f700b77c97b59c05eb1cf4f310ce6a4	980245974	FAC 0250312022	0065390113	\N	Endesa Energia S a Sucursal Portugal	2022-10-08 00:00:00	7.05	1.55	8.60	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.843
cmnhoyqyc01e9rkt48kax9bpg	95d1da76befcab11a0d8f8d3624b5357431b386d677578e884e359bcdaed4ff9	980245974	FAC 0260312022	0069294913	\N	Endesa Energia S a Sucursal Portugal	2022-08-08 00:00:00	6.97	1.54	8.51	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.852
cmnhoyqyn01earkt4wbwbxsub	b00b10b4aae2d7af1fbf5ca842fe4753cc0fc8dbe9c29f887924b2052c44ac91	506848558	FT 202203351	000551	\N	Bcm Bricolage S A	2022-09-06 00:00:00	6.50	1.49	7.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.863
cmnhoyqz801ecrkt4p96siwgd	c06bba77ab99a457cbed77f5050485d7f28918e80ebb39c13e4cfaa34393494d	515023264	FATS D22	2178	\N	Drogarias Pevidem Lda	2022-10-17 00:00:00	5.81	1.34	7.15	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.885
cmnhoyqzf01edrkt49b7wduwc	8c6dd6cdf704248d46520d6bdfde7060f8347f06860de2fce8a9ab01162a3e06	506848558	FT 202203304	006090	\N	Bcm Bricolage S A	2022-08-01 00:00:00	5.85	1.34	7.19	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.891
cmnhoyqzr01efrkt47dkt7zkq	619d4edb27e9da74c79fa8bb494f251e702159b027aaf4c086b49340b4c1a55a	505993082	FAC 006	60482333	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-01-03 00:00:00	33.76	1.30	35.06	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.903
cmnhoyqzw01egrkt48gryfeor	2390344957292992560f81b07885af303994d9c80704e4f70e07f574c417da88	506848558	FT 202200806	009472	\N	Bcm Bricolage S A	2022-08-05 00:00:00	5.33	1.22	6.55	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.908
cmnhoyr0901eirkt4b974fhkn	051996e2bf2697001ece80dba0bc7ad98e82439bbd99f979f12369507fd883b4	505993082	FAC 006	60561242	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-07-22 00:00:00	29.01	1.14	30.15	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.921
cmnhoyr0g01ejrkt44341val8	41bc363d1bb9d92152847a3c62c90e0bb742b40dc6f6c962e38a2d30b152e219	506848558	FT 202203304	001671	\N	Bcm Bricolage S A	2022-02-28 00:00:00	4.87	1.12	5.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.928
cmnhoyr0o01elrkt4d0wid57i	ed1b1257dd0811b3b7b036986408a5685938ed1c5c5f2306be01fede3a9b35c0	506848558	FT 202203352	000953	\N	Bcm Bricolage S A	2022-11-04 00:00:00	6.95	1.03	7.98	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.936
cmnhoyr0z01enrkt4epg9vmdb	5c16cb1e1682e989087ee7a947917ba4e63402779958d6e0027997478833d262	506848558	FT 202203352	000671	\N	Bcm Bricolage S A	2022-09-07 00:00:00	4.06	0.93	4.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.947
cmnhoyr1801eprkt41n6xczao	d6cfcf6914b53074dc9d7edac9c9d40382d120c3969eab08ee5a7df8f48163ff	506848558	FT 202203305	006005	\N	Bcm Bricolage S A	2022-08-06 00:00:00	4.06	0.93	4.99	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.956
cmnhoyr1n01errkt4944ekc1d	8be76bebc144ac61ec95c6e9591085dc3bd25b47e7f1873afcb9024fde6ce13f	515023264	FATS D22	2179	\N	Drogarias Pevidem Lda	2022-10-17 00:00:00	3.66	0.84	4.50	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.971
cmnhoyr1x01esrkt43zypbk8e	a5ea6d66a4e8ac7b11507789a0a901c4460ef3d501f718603e5b70014050dc2d	505993082	FAC 006	60574055	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-08-25 00:00:00	23.93	0.79	24.72	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.981
cmnhoyr2b01etrkt46ims915o	cafddccc385e5127d7bff485847713dd5f086ac138245a5404f7b2a8849e312c	505993082	FAC 006	60586358	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-09-22 00:00:00	23.29	0.78	24.07	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:00.995
cmnhoyr2g01eurkt478xmjuff	6190d88bd18794db64fcd1a18a8ad010e68a278119c4259e349cf72b86e835e4	509980171	FR01 2022	881	\N	Aderito Electronica Lda	2022-09-16 00:00:00	3.25	0.75	4.00	Fatura-recibo	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01
cmnhoyr2p01evrkt4kz306i5w	dc43cac07f253a7a628002d60d5e3ca11c4cd1989311f87de796bb4e66407f6d	505993082	FAC 006	60599959	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-10-24 00:00:00	21.33	0.72	22.05	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.009
cmnhoyr2w01ewrkt4rvj6o7mj	b77d47dd12a9f6442cce4e876d4582da67f8bfd57c1ced467b998cc2a1a9b6ba	505993082	FAC 006	60513320	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-03-24 00:00:00	19.26	0.63	19.89	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.016
cmnhoyr3401exrkt4kq50z5k1	64b53037b39e5bfb3b35c47424ed66c0d0dd204e04558edff41f0a91ebb2be10	505993082	FAC 006	60612819	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-11-22 00:00:00	20.76	0.60	21.36	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.024
cmnhoyr3a01eyrkt44ix8hwyu	9dd7f1c816c9b3b09d6fddfdc6db21018ce699426660465a9247bf93b50c1add	505993082	FAC 006	60573939	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-08-25 00:00:00	20.75	0.60	21.35	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.03
cmnhoyr3g01ezrkt47g2zrdu8	2c881093773d16804b7cef067fad563028335ca4eadc4fbaf84114d958f8f8b8	505993082	FAC 006	60549762	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-06-27 00:00:00	20.75	0.60	21.35	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.036
cmnhoyr3n01f0rkt4qty9h2rr	6b16e7228517786a14799cd18335f1157de305fb599efae113d8e7f1ab866d45	505993082	FAC 006	60549412	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-06-27 00:00:00	20.75	0.60	21.35	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.043
cmnhoyr3x01f1rkt42b53z8ff	e49f9251c24291b330fb22a3c93b487bea9c54a6cbd451362cdd5b8d70bb6e77	505993082	FAC 006	60586694	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-09-23 00:00:00	20.10	0.59	20.69	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.053
cmnhoyr4601f2rkt4m7xagjcb	28a7d76c1c7ecd9f906a3f97f275e7a2dca3397dddf3a3c7422af5d26e00b6ae	505993082	FAC 006	60561747	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-07-25 00:00:00	19.46	0.57	20.03	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.062
cmnhoyr4c01f3rkt4ueg7h23y	4f65fd8fd9b2ebf3079518ab5a052307aae6f5087ffac4d6e96b504cc6247839	505993082	FAC 006	60627191	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-12-26 00:00:00	19.45	0.56	20.01	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.068
cmnhoyr4j01f4rkt4sq562xoj	873961d983341c5e00d55ca2a924ceedf3db7d3150f280941ae75a84dab0ca99	505993082	FAC 006	60536359	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-05-23 00:00:00	19.45	0.56	20.01	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.075
cmnhoyr4o01f5rkt4vr8a9grm	10d8e746747c98b247b0c30d85c2ae79e91f071ce2c12c63c612b1d8e84d81df	505993082	FAC 006	60536694	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-05-23 00:00:00	19.45	0.56	20.01	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.08
cmnhoyr4w01f6rkt4hgcu443d	d94add6de7a48fe08e2a0cc3ae3cd6bf1baf124f728759267697549ccd4b2cfd	505993082	FAC 006	60525596	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-04-26 00:00:00	18.80	0.54	19.34	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.088
cmnhoyr5101f7rkt4ws069qnf	1d9c471401acf82dcab8ef2d07c63ba8679c1999f59d788b811444ed8f6274e5	505993082	FAC 006	60525209	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-04-26 00:00:00	18.80	0.54	19.34	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.093
cmnhoyr5601f8rkt45t6yskl8	c0f3c62d74fc86fce3bf5e61c75652d7e9e49a0476c42934d97164ec99c1086d	505993082	FAC 006	60600536	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-10-25 00:00:00	18.15	0.53	18.68	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.098
cmnhoyr5h01f9rkt4f76ebwuh	1a5752f122fcb01d3bea3ddd099d5ba4b1984eaa070c35a2bdc87f711b58aa7c	505993082	FAC 006	60501717	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-02-21 00:00:00	16.33	0.53	16.86	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.109
cmnhoyr5o01farkt4bb7jpgzi	f386f39b3a4be499eef853d248a7f8dd163bd3a9ceb7eca7d838791eedf4fee7	506848558	FT 202203352	000512	\N	Bcm Bricolage S A	2022-08-04 00:00:00	2.27	0.52	2.79	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.116
cmnhoyr6001fcrkt49uvbvst2	32ed7545c3da3688006b00ae2cbc19ea505452e083db79b464bff3deab7781e7	502075090	FT 501	2022068622	\N	Arcol, S.A.	2022-09-29 00:00:00	9.93	0.48	10.41	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.128
cmnhoyr6a01ferkt4sk99segu	5b9efbb1d3ea7e807a09ab63dd4b054f0f41cc1d4a03a5300186e7d8a373306d	505993082	FAC 006	60490692	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-01-24 00:00:00	11.67	0.37	12.04	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.138
cmnhoyr6g01ffrkt42bjrh9zr	8bc3c8ab31e5ab997e6454babf0588483177c7858b77c3985afd1a04082be2a4	506848558	FS 202203305	035008	\N	Bcm Bricolage S A	2022-08-02 00:00:00	1.44	0.33	1.77	Fatura simplificada	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.144
cmnhoyr6u01fhrkt4qwz8cf08	387b9b534529ed35abd9195e39477846d66f2ce15db8a9d1cf013e5a74818ea4	506848558	FT 202203352	000690	\N	Bcm Bricolage S A	2022-09-15 00:00:00	1.29	0.30	1.59	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.158
cmnhoyr7901fjrkt4du323ivx	a7e85920d0e4ad2327e11b2f717a604aa87ac74c893c344684ceb339346804eb	505993082	FAC 006	60513132	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2022-03-22 00:00:00	96.38	0.29	96.67	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.173
cmnhoyr7h01fkrkt458psyllx	110d5381cc2b992ccf0103a1b91135699925d4ad1445b1a48d6f47e69a306b52	506848558	FT 202203306	001207	\N	Bcm Bricolage S A	2022-03-22 00:00:00	0.48	0.11	0.59	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.181
cmnhoyr7w01fmrkt4yg651ijc	4fb0d09e2f221a5c8df25c252551ef9a2efe99e6719361641ead779c38ee9a8f	513204016	FQ 2	9610024859	\N	Novo Banco S A	2022-07-06 00:00:00	7.50	0.00	7.80	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.196
cmnhoyr8401fnrkt4nab1r6aa	a04a3ac092f005311da9e9e75686c4c24484d7e0df48964cb271a3c805aaef83	513204016	F1 2	4202425124	\N	Novo Banco S A	2022-07-05 00:00:00	20.00	0.00	20.80	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.204
cmnhoyr8a01forkt42am3g0up	e640ebcfacc882abd16c46df4578bb4e4408b2c9c279f2421f1a76ed9ddbe357	502604751	FT 202293	706035	\N	Nos Comunicações S A	2022-04-27 00:00:00	0.00	0.00	0.00	Fatura	cmnhoyppc017urkt4owu6dinb	2026-04-02 16:31:01.21
cmnhoywpb01fqrkt4aygb760i	6992684f94ec3fb5a3bf591d25f88c1740ea592d458e8668eee35beb09f3d68c	505416654	FAC 0091232023	0012313	\N	Ikea Portugal Moveis e Decoração Lda	2023-12-12 00:00:00	1355.28	311.72	1667.00	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.303
cmnhoywpn01frrkt4p5f62x6i	51cdcb55846b5941603ee71e50480b97f176ce46eb0259f7633c5096d637a1a8	503137413	FTPBO 5	26	\N	Clube Paraiso Hotelaria e Turismo Lda	2023-11-11 00:00:00	687.43	104.91	792.34	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.315
cmnhoywq901fsrkt4a60zklwk	af46069cab196f16de3a4477d7c2883bff05b1d229c573c1bd4fbb9d9e493764	501578455	FR140 140/81	JFMJDBR6	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-05 00:00:00	403.28	92.75	496.03	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.337
cmnhoywrj01ftrkt4kbdxyxat	8124cb2927a9ce0458f2ee8a31b10de2660383f34aab948d20f72cf5a8393c4b	517377870	FT 2023	387	\N	Legal Factor Lda	2023-12-22 00:00:00	402.44	92.56	495.00	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.383
cmnhoywrq01furkt4poqaa10g	f998bc3f6129af82f6aae5969d1b7783bdbedc47c3c4ae4e270d68a30297efa9	501578455	FR114 114/9232	JFM8DXDZ	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-01 00:00:00	373.44	85.89	459.33	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.39
cmnhoywry01fvrkt4chzhzgf7	7158335548e82b6c1aa7f625d3a9e8212daf4578a6370c670304edd586f45542	504984810	FR 2023A3	776	\N	Saniestilo - Materiais de Construção Lda	2023-09-01 00:00:00	266.24	61.24	327.48	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.398
cmnhoyws701fwrkt4h6do8dvz	aa0ff1af5a0ae35dadc3e02b47e93c0b33b3f711729c6e748bc6556330186339	516917927	F FCTREST23	4910	\N	Vi-Fe Resort Lda	2023-10-01 00:00:00	330.22	48.48	378.70	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.407
cmnhoywse01fxrkt4l1iw97a3	fddbc6e117e5f01c300da64706c27aec431feb57a4c8de0976563bcf96cbdd82	514598670	FT 1A2301	362	\N	Jumpers Spot, Unipessoal Lda	2023-01-28 00:00:00	208.94	48.06	257.00	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.414
cmnhoywsm01fyrkt4u47ll3jo	9eccf6cb1e64700792b1b3acf2185b40c2ef5d2862de97d9db1571f92146a48a	513845550	FR 004	5097	\N	Baladas e Pitadas - Lda	2023-03-31 00:00:00	279.71	40.39	320.10	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.422
cmnhoywss01fzrkt4sflom4ba	b30d5de376079d635b3701e640d11281361e1411dc5c06d070a9b74a8953725a	514598670	FT JS	7	\N	Jumpers Spot, Unipessoal Lda	2023-02-03 00:00:00	165.85	38.15	204.00	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.428
cmnhoywsy01g0rkt44dc49gpr	3190991262ae0269423af36250e23b818cc324c28cd7b4d282b57bd8c3b7602c	514598670	NC JS	4	\N	Jumpers Spot, Unipessoal Lda	2023-02-03 00:00:00	-165.85	-38.15	-204.00	Nota de crédito	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.434
cmnhoywt501g1rkt4kf5qhqq4	6a41fa801e6f89ec4ef34aa9d8f6e23c0740bb2849884c549a70dd9f2f758b29	514598670	FR JS	127	\N	Jumpers Spot, Unipessoal Lda	2023-01-13 00:00:00	165.85	38.15	204.00	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.441
cmnhoywtd01g2rkt4utk3n3ok	c093ea8d44b1e4c52ed6e9c6fecf6ced88e923e6f0223e2eb1e7a6660803271e	502075090	FT 5012023	23909	\N	Arcol, S.A.	2023-04-05 00:00:00	149.94	34.49	184.43	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.449
cmnhoywtq01g4rkt4v0shsevu	72f678ef69b60796a8e6e9a144a3c34cad2e47e6103b7d45c71f37c924aa6391	743060288	FR 002	82	\N	Jose Manuel Dias dos Reis - Cabeça de Casal da Herança De	2023-01-13 00:00:00	243.36	31.64	275.00	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.462
cmnhoywu201g5rkt4kqcnty3q	fd52d0e2731e952089c8ea7df3b9cbdd94d30bb478c4691813ee735a2b47745c	506848558	FT 20230330301	009286	\N	Bcm Bricolage S A	2023-10-03 00:00:00	129.25	29.73	158.98	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.474
cmnhoywui01g7rkt4bwkxdwdj	51135750be30563b5884b03236e6180342173f7181240c65aa22ba87d288b6f7	505215144	FT 1A2303	5917	\N	Grupo Capricciosa, S.A.	2023-02-19 00:00:00	187.37	28.48	215.85	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.49
cmnhoywuo01g8rkt42yysi7k1	c570e6c3761451041fd979d5c3d63904811aa3782d6dc7f91b2ba3631ada33a6	513909826	FR 5	2034	\N	Sorriso Macio, Lda	2023-04-01 00:00:00	178.80	26.90	205.70	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.496
cmnhoywut01g9rkt4tspif47s	942630d1fc3244809e705a798dd4dcd511838fc47d64e25b1db1aa61597192ce	513306498	FT 2023B135	2872	\N	Blindstore - Unipessoal Lda	2023-08-18 00:00:00	91.48	21.04	112.52	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.501
cmnhoywuy01garkt4gn8bn21t	3c994560f9842c9d37135beaa2b1c25fa2ea924a411615d0d13c4b65b997ff09	502022892	FT 0	042886	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-12-27 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.506
cmnhoywv801gcrkt4i14c6qm5	7a2ffad803e4ca73e20e1d0391e43c528d68322f3da6f35141e1f3f153a2fcaf	502022892	FT 0	042584	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-11-28 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.516
cmnhoywvh01gerkt4hzrx6d2a	f51ba731ae396d468b1ea84274ab07531d90b0071b78fb446a5c1fc823a1e969	502022892	FT 0	042264	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-10-30 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.525
cmnhoywvo01ggrkt4oqch4fzy	aaacf3d600b2a36fc40719c881496c7ffb0d0ecc4190e253a0cdd0e1654c2779	502022892	FT 0	041936	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-09-25 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.532
cmnhoyww201girkt4tzs2m670	586879f7437d1c06c1779f85fb3292168d6ecbbb8f18f2487f52f74315ef3946	502022892	FT 0	041642	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-08-29 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.546
cmnhoywwj01gkrkt4lwxvyrhp	e6a872ac18dfa15d5b7ddfa88c27e5e67c002220f280993b5c40efd4a12704d2	502022892	FT 0	041332	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-07-28 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.563
cmnhoywx201gmrkt4dosahl7c	fa840a3ebaeb5b1340c6e3bafdb5578fb38fb22f220e0ae0085dc0bed5ad84ab	502022892	FT 0	041027	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-06-29 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.582
cmnhoywxe01gorkt4or9uo7pu	b2ec42b6073ff65fdcdfd9aab436645c9d416b13d93448bf38c7215add6b7305	502022892	FT 0	040707	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-05-29 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.594
cmnhoywxr01gqrkt4eg1f3pbj	9266c5d0cf13ee898c1807cedaa7c57c8ebbc8cb63fa503e312d1274db341d21	502022892	FT 0	040385	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-04-27 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.608
cmnhoywy101gsrkt42uuj747b	62ce628c49a170eceb2c09880575e1778380759d70910f9bc1473e41fe6a7b06	502022892	FT 0	040065	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-03-28 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.617
cmnhoywyu01gurkt44e7706e5	c3bf59abd8da9b789c7f5542059ebc69b5313b79a3d81946c9dd397d59ce8487	502022892	FT 0	039958	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-03-15 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.647
cmnhoyx0b01gwrkt4qwupj3zj	b6a01af687df576f592da00df4f33063db41f5089e856475bc8138d57681b0a4	502022892	FT 0	039418	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2023-01-31 00:00:00	90.00	20.70	110.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.699
cmnhoyx4901gyrkt4qt7yhiun	513bca6b661980a565031c4fa4d5dd7fa51dea49352d46375ac7bc52009bd4e2	510535518	002 1	90685	\N	Amazingwaves Cafe Bar e Restaurante Lda	2023-06-10 00:00:00	141.78	20.22	162.00	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.841
cmnhoyx5e01gzrkt4z8w15d58	30d9c660a0a7fb87c1f25c2e1355ab79276dc46e51777c6be4954f6623c70354	980245974	FAC 0240312023	0061092231	\N	Endesa Energia S a Sucursal Portugal	2023-02-20 00:00:00	90.48	19.35	109.83	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.89
cmnhoyx6f01h0rkt4cfmjwmby	44ce15b71df015c7c4eb69f7053e9ff6bea7e6177c4836d1ba4671335e09240d	516255975	FR ROOFFR	44	\N	Anvileo Rooftop Lda	2023-01-28 00:00:00	128.85	18.75	147.60	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.919
cmnhoyx8n01h1rkt4plrohket	6302cf82e26a4afd23b844a82c7baff98307c1a89b4789a5c789874bd9cfc91a	980245974	FAC 0230312023	0057627125	\N	Endesa Energia S a Sucursal Portugal	2023-12-08 00:00:00	89.41	17.76	107.17	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:08.999
cmnhoyx9a01h2rkt4n1t5p3et	e024596aa3cad5e7f0c3968fce3e5c515f344b937c441ec5a8fe54e8f1d67322	980245974	FAC 0240312023	0061635508	\N	Endesa Energia S a Sucursal Portugal	2023-12-06 00:00:00	86.54	17.51	104.05	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.022
cmnhoyx9t01h3rkt49k1f0ui5	ff70b9acac1c8d9a0abd2730c720d1d14f64200d266bc5106abb4248001b079a	980245974	FAC 0240312023	0061236722	\N	Endesa Energia S a Sucursal Portugal	2023-05-08 00:00:00	75.22	17.12	92.34	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.041
cmnhoyxad01h4rkt42ewj0mwg	b9925a3872366d75d4ca5a77e37e928b8e6d9bff2368d9c2e2cd3478e41b8f34	185613314	158	JFK4GT98	\N	Rui Manuel Alves Madeira	2023-01-21 00:00:00	120.42	17.08	137.50	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.061
cmnhoyxb501h5rkt4va173eot	fbf59ebd0f93d7de0c346960d9f0f6ce56b8266090c94bb95ebec81795d8d85a	980245974	FAC 0240312023	0061070354	\N	Endesa Energia S a Sucursal Portugal	2023-02-07 00:00:00	72.81	16.56	89.37	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.089
cmnhoyxbf01h6rkt4k3dkjq6u	d3c63335e33f949074f2342e83e921556bb6bb28a7f9fd660022c116c7fe5541	980245974	FAC 0240312023	0061028765	\N	Endesa Energia S a Sucursal Portugal	2023-01-16 00:00:00	77.26	15.42	92.68	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.099
cmnhoyxbv01h7rkt42vut2fcx	72999bcde0b34ef060b026842776561370c5157d15108b768d6ae83cfccf9a17	503630330	FS AUM012	020176	\N	Worten - Equipamentos Para o Lar S A	2023-10-26 00:00:00	66.09	15.20	81.29	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.116
cmnhoyxcq01h9rkt41glvcnls	4ff85f20c817248516103c619499b8ba1e40629ee6ecd3fc6e9363badd3e9bf0	980245974	FAC 0240312023	0061143427	\N	Endesa Energia S a Sucursal Portugal	2023-03-17 00:00:00	69.26	14.62	83.88	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.146
cmnhoyxd501harkt4ethu8vhc	94c9f94332a86d3c6c047c92b6a42b3a4c59978a2303580820d223b1bac06df1	980245974	FAC 0240312023	0061347833	\N	Endesa Energia S a Sucursal Portugal	2023-07-08 00:00:00	64.16	14.57	78.73	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.161
cmnhoyxdg01hbrkt4qxrq8gvl	99600c6fcae11c1867499eaf5933862421d442ee9379c4d748dcf2d3cdd4ec5e	980245974	FAC 0250312023	0065011445	\N	Endesa Energia S a Sucursal Portugal	2023-01-10 00:00:00	73.59	14.50	88.09	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.173
cmnhoyxdp01hcrkt4c3uddkqx	eab81cc51d08f1e9e450cb397953a2226a02902374afcc5f58c38e06550aa3c4	506848558	FT 20230335201	002785	\N	Bcm Bricolage S A	2023-10-03 00:00:00	56.90	13.09	69.99	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.181
cmnhoyxe201herkt4gaqbslyx	c02fb8b81a3a291a8206ad580a3fabea692c8516107d035090bf894fafa003dc	502075090	FT 5012023	90920	\N	Arcol, S.A.	2023-12-14 00:00:00	100.13	13.02	113.15	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.194
cmnhoyxed01hgrkt4nfamdkvn	87cb741533a633f079794918bc16b917df9f558c52012e5314c4051d126ac9dc	501578455	NC105 105/5057	JFM2R3JR	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-06 00:00:00	-56.27	-12.94	-69.21	Nota de crédito	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.205
cmnhoyxek01hhrkt4s93x2roc	913f06c15110183d291b81cb39a78d1c29f535736ed9978fe0465a699b67469a	980245974	FAC 0250312023	0065131431	\N	Endesa Energia S a Sucursal Portugal	2023-03-12 00:00:00	65.62	12.86	78.48	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.212
cmnhoyxet01hirkt4j7m644sj	3d3cc909f8bf21322c3b9e78dbeb659d6e6130b5483900e16ea22b81e56f8aa5	501578455	FR150 150/7459	JFMXY9B6	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-06 00:00:00	55.86	12.85	68.71	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.221
cmnhoyxf201hjrkt47vjiz3ne	c1b92f27009823402a2bac6620d7cbf9424e238df5a0866e811251fbf2a0b78d	514163925	FR NPVP	5160	\N	Nogueiras e Santana - Restauração e Refeições Lda	2023-10-31 00:00:00	85.26	12.75	98.01	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.23
cmnhoyxfa01hkrkt42yt3ezx6	61c6817dbed4c9a270cc628b8b264a40af18369f1d7b8361b2655609375cbb77	511071230	FR 23	2535	\N	Ilmare Exploração de Bares, Restaurantes e Similares de Hotelaria Lda	2023-08-05 00:00:00	90.91	12.39	103.30	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.238
cmnhoyxfn01hlrkt4jexeg7g8	da3f9905a41fa540f3cd01d3450ed3221f27488ee86283c360080e29a35df0c1	980245974	FAC 0230312023	0057644445	\N	Endesa Energia S a Sucursal Portugal	2023-12-16 00:00:00	64.02	12.35	76.37	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.252
cmnhoyxfy01hmrkt41vsc4lan	bb0de5a3effd182cdd2ebb0393404a7afaac46bca0b6788be20ca56cf2751524	980245974	FAC 0270312023	0073436351	\N	Endesa Energia S a Sucursal Portugal	2023-09-19 00:00:00	62.30	11.93	74.23	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.263
cmnhoyxg701hnrkt44hn3pzsd	59c1f30c0db8e311075a9c3347d8a45ae616aefad7f02feb95e7094be5a66ac7	980245974	FAC 0240312023	0061595219	\N	Endesa Energia S a Sucursal Portugal	2023-11-16 00:00:00	61.84	11.77	73.61	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.271
cmnhoyxgf01horkt4ki78ee19	50d63c9267e5d5939189e85c2fd89f1a5b8a3d6259015ece44a139c2231abe38	980245974	FAC 0280312023	0077079177	\N	Endesa Energia S a Sucursal Portugal	2023-02-19 00:00:00	63.61	11.48	75.09	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.279
cmnhoyxgl01hprkt4xgttsxx9	6c69b3dddb4b89bb676769caa27ea9b7696bafadc3c80dfe21bc2db11063da3c	513998128	FS 4B2301	2398	\N	Pitada do Costume, Lda	2023-07-22 00:00:00	77.58	11.32	88.90	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.285
cmnhoyxgs01hqrkt4s18skkuk	02c3990e6918aca169429a12c2c082b801c1664c5138945df15a2f5b48c3aea8	510261264	FR 1Y2023	6160	\N	Indice da Alegria - Unipessoal Lda	2023-05-27 00:00:00	76.98	11.27	88.25	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.292
cmnhoyxgy01hrrkt48vt748zo	dbc65227437e4f82d22d4a236af0f133cac33cf9702784134a6893fe898f563e	510261264	FR 1Y2023	6161	\N	Indice da Alegria - Unipessoal Lda	2023-05-27 00:00:00	76.98	11.27	88.25	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.298
cmnhoyxh701hsrkt4z20l8wm5	2acda8a65fffde97bc83b790e50414a6e9d03ddaf172a22d5abd65b61d06e53f	980245974	FAC 0250312023	0065178264	\N	Endesa Energia S a Sucursal Portugal	2023-04-09 00:00:00	58.13	11.20	69.33	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.307
cmnhoyxhd01htrkt4hpjcs0lw	ce142539d73870d7d935e789894aae28623db31f0b201d17044e434370ec3ccf	980245974	FAC 0250312023	0065179498	\N	Endesa Energia S a Sucursal Portugal	2023-04-09 00:00:00	48.54	10.98	59.52	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.313
cmnhoyxhk01hurkt4pzfqn7d6	75cb1797539e0f40bc57f73a9909ce8ee77ff1b3a31da532323cf0e73dcd1796	980245974	FAC 0230312023	0057627789	\N	Endesa Energia S a Sucursal Portugal	2023-12-08 00:00:00	48.55	10.97	59.52	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.32
cmnhoyxhr01hvrkt4l3harjpm	d711566a8771559a1ea35d89fad34831e4a6d426df036b529e0cac58e1cdc4d0	506619508	FS 2312025	00000060	\N	Grupo Pestana Pousadas Investimentos Turisticos S A	2023-01-21 00:00:00	73.58	10.42	84.00	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.327
cmnhoyxhx01hwrkt4pz7yh2se	38c63b12c5008e0770b3a48237c6ce8689bc7ef49f57032d9fa89cd6dded7cab	980245974	FAC 0250312023	0065066722	\N	Endesa Energia S a Sucursal Portugal	2023-02-06 00:00:00	51.19	10.36	61.55	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.333
cmnhoyxi501hxrkt4r9h9hpjh	9a183d292182158da2f5d52ae86a42af3daf16c8b4a500232d6600a829758ef9	980245974	FAC 0260312023	0069174484	\N	Endesa Energia S a Sucursal Portugal	2023-04-10 00:00:00	49.97	10.33	60.30	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.341
cmnhoyxia01hyrkt4lxwyc3e2	44a778bd7983a3a19d04e2d5c36518080ad210bab00deca18b5709a01130d285	507718666	FAC 009	93709559	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2023-10-18 00:00:00	84.07	10.30	94.37	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.346
cmnhoyxik01i0rkt45bs60wnq	00f288e000cf8e587ddc36d70556a6d1c8173b8b11865e65ea0bec388becaef2	980245974	FAC 0250312023	0065011132	\N	Endesa Energia S a Sucursal Portugal	2023-01-08 00:00:00	44.62	10.08	54.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.356
cmnhoyxiq01i1rkt46qkj1nw8	b2b1895010664eeb0d2c40699aede1e74fdee592ca8673abf65f01fa196f1202	980245974	FAC 0240312023	0061575063	\N	Endesa Energia S a Sucursal Portugal	2023-11-06 00:00:00	53.07	9.88	62.95	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.362
cmnhoyxiw01i2rkt4njg7ango	1870e212a6bd4a7110be9950ff3a2a6862938ab2b59984537a290e4ce5439dfc	980245974	FAC 0240312023	0061070353	\N	Endesa Energia S a Sucursal Portugal	2023-02-07 00:00:00	48.62	9.78	58.40	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.368
cmnhoyxj201i3rkt4f5dd79xy	498a3b598adbddb3e76ba008fb831d3bafaa9e3e42482c261634f47324a06014	506693872	FT 1D2302	723	\N	O Velho e o Mar Actividades Hoteleiras Lda	2023-02-19 00:00:00	59.29	9.21	68.50	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.375
cmnhoyxj701i4rkt4822bc290	cb4243a84e09acd6df0eab576f017dff4fd0a9364cb671ba9972616c38b06a58	506848558	FT 20230066201	003982	\N	Bcm Bricolage S A	2023-09-19 00:00:00	39.96	9.19	49.15	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.379
cmnhoyxjj01i6rkt436dm195n	48839e65bad11790fd650bf14403b20db5cc216cd2f75694601a5ae6efa94cd0	980245974	FAC 0250312023	0065011131	\N	Endesa Energia S a Sucursal Portugal	2023-01-08 00:00:00	46.83	9.06	55.89	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.391
cmnhoyxjo01i7rkt40rfg9503	6b09cab96faf62503cac6be198103e12cce7964298ce2a828758e45d074bcb9d	980245974	FAC 0250312023	0065635994	\N	Endesa Energia S a Sucursal Portugal	2023-12-19 00:00:00	50.70	8.96	59.66	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.396
cmnhoyxjt01i8rkt4gqz5saov	1eda0575066bcf5fb0e1bc1828f5b5e354a9081c4b729b4d7c56cd53d4611e8f	980245974	FAC 0280312023	0077129328	\N	Endesa Energia S a Sucursal Portugal	2023-03-19 00:00:00	50.69	8.93	59.62	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.401
cmnhoyxk301i9rkt4vckvhkli	716508088599e1dbe0bb31271d74eddfbd29cb71db326f64a5b66604183232cd	980245974	FAC 0270312023	0073179346	\N	Endesa Energia S a Sucursal Portugal	2023-04-19 00:00:00	51.66	8.85	60.51	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.411
cmnhoyxk901iarkt4vc4eunwk	8ccbbfa3da7efaf489e25ff313e7ba753730e5f690c166c05c0e9b8ad72249c6	980245974	FAC 0230312023	0057566304	\N	Endesa Energia S a Sucursal Portugal	2023-11-08 00:00:00	50.03	8.78	58.81	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.417
cmnhoyxkf01ibrkt45gg4igt8	09891931d1ba0b321bc0ceab6a66829bf001627a5c5c9a268965280556d06eb3	980245974	FAC 0270312023	0073383183	\N	Endesa Energia S a Sucursal Portugal	2023-08-19 00:00:00	49.65	8.39	58.04	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.423
cmnhoyxkm01icrkt4h52lpqgn	9f2b1bb41fcbd83b5a79be4c3d8aa2c11698c5e27c3dcb939a4e6d54a97705fb	980245974	FAC 0260312023	0069566056	\N	Endesa Energia S a Sucursal Portugal	2023-11-19 00:00:00	48.64	8.16	56.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.43
cmnhoyxkt01idrkt4lpfemxrh	55b3e043bf92648fad199dddf15cef48c0643a2518f6f44e7d9c76c45d7f1df8	980245974	FAC 0260312023	0069118209	\N	Endesa Energia S a Sucursal Portugal	2023-03-09 00:00:00	40.50	8.02	48.52	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.437
cmnhoyxl001ierkt4fbth1wlr	31292f57bfd6e3419965c5596e740375e8023eef75eaa58f7a9f8d5f6f4058bb	980245974	FAC 0270312023	0073279855	\N	Endesa Energia S a Sucursal Portugal	2023-06-19 00:00:00	46.99	7.78	54.77	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.444
cmnhoyxl501ifrkt4ivgaaaka	559fa9150ae555a1ef80704e94ab3eeaeb4018044f89cc92d4b07cfb732c65c4	980245974	FAC 0270312023	0073228915	\N	Endesa Energia S a Sucursal Portugal	2023-05-19 00:00:00	46.62	7.78	54.40	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.449
cmnhoyxlc01igrkt4fr65ljbu	895408edff6416e47098ac1afe87c8478eb6ccd785c90904d4a42443ee9033a2	980245974	FAC 0280312023	0077326759	\N	Endesa Energia S a Sucursal Portugal	2023-07-24 00:00:00	46.36	7.72	54.08	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.456
cmnhoyxlk01ihrkt4hxywmncu	ff4aef3f2bd366526da3a4d4bcb87874e976dc4b66363d5548b515938d17ae4b	502604751	FT 202393	2666039	\N	Nos Comunicações S A	2023-12-27 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.464
cmnhoyxlr01iirkt4re6fbciu	de6fc152b0cda83215c3ba2d3e345dc806118a98ed3282ab956762f17a6051d9	502604751	FT 202393	2424176	\N	Nos Comunicações S A	2023-11-24 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.471
cmnhoyxlw01ijrkt4gibyq61k	820a03a6c170e6a691df34236cf4c177f190129f6050f94902092da77d1894fe	502604751	FT 202393	2182304	\N	Nos Comunicações S A	2023-10-24 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.476
cmnhoyxm201ikrkt42k719h23	b8cbf528bb8f32eb3a9f54d4aa6d36aa7cdd59beed5807d4a693b96dc39ab68a	502604751	FT 202393	1941601	\N	Nos Comunicações S A	2023-09-26 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.482
cmnhoyxm701ilrkt4cstqfga1	a0fe29b9e0a17b0cb3551d21900cfc86abe768862c990e57ea814be49cafcd02	502604751	FT 202393	1701339	\N	Nos Comunicações S A	2023-08-24 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.487
cmnhoyxmc01imrkt4dvvexhr0	0c9c1c704a420fa70d9f7deefdb2e257c65a6bd2c2c174414e9a6a8374a138f1	502604751	FT 202393	1439137	\N	Nos Comunicações S A	2023-07-25 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.493
cmnhoyxmi01inrkt4pbeahtks	c9276a830242dfda868c6025b5279b8b6df8d93d31ff4fbf443cfe1a6d95cbce	502604751	FT 202393	1221349	\N	Nos Comunicações S A	2023-06-26 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.498
cmnhoyxmo01iorkt46vk7pr8i	aee6d6d13f46c9c08bfa91a024ed20ff6f43b5c67387828f45404f3ffdbbd476	502604751	FT 202393	986020	\N	Nos Comunicações S A	2023-05-24 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.504
cmnhoyxmt01iprkt4gdeqt1mv	552c8e3d459c03a024917cc667f12b644cf3665776fcc79e16bdf03b6594b2c0	502604751	FT 202393	754940	\N	Nos Comunicações S A	2023-04-26 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.509
cmnhoyxmz01iqrkt4wrk8p22c	6cd4319d80384b5019c9a3bbebc698d821371b5d9c29383d442eaa3dec99e264	502604751	FT 202393	531537	\N	Nos Comunicações S A	2023-03-24 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.515
cmnhoyxn301irrkt4oo6hbeu8	b5a0d4d0c771fdfe3207ffac939a01c1797c8181195e40c7093e2cd0dc3fc047	502604751	FT 202393	310376	\N	Nos Comunicações S A	2023-02-24 00:00:00	33.30	7.66	40.96	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.519
cmnhoyxn801isrkt4yc7577ia	8c4f7377f40f5429831a77443b090793b7ff56e15d769a206488eb8c76fe52a4	502544180	FT 101	064785944	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-12-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.524
cmnhoyxne01itrkt4yspwz2xa	7f6563a00228f708223e59a5fe74ed012e3387cd4b5fe043134c13f5364eef13	502544180	FT 101	063259736	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-11-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.53
cmnhoyxnj01iurkt48s0cg05e	f3824a04cd32bd9da309a787f0373acc75663c54b111736519f8bcc8e24bc0a1	980245974	FAC 0260312023	0069510142	\N	Endesa Energia S a Sucursal Portugal	2023-10-19 00:00:00	45.95	7.63	53.58	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.535
cmnhoyxnn01ivrkt4glghl1tk	89548a460085a3ffa5f47078880379a09f6abaf4df13afeede1f45ef4b4c8274	502544180	FT 101	061683608	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-10-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.539
cmnhoyxnr01iwrkt4ygfklhpc	a9a85c746a432910d745faa2dbdf8a5044b856b03147ad7fc87d85d79a130f6e	506848558	FT 20230335101	002486	\N	Bcm Bricolage S A	2023-09-08 00:00:00	33.15	7.63	40.78	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.543
cmnhoyxo201iyrkt4oxoaihz3	61a73971ea2f8456c22f94fee928f76f99e9ba7d1e97fedf34bfa43c8cf2b5b0	502544180	FT 101	058591498	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-08-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.554
cmnhoyxo701izrkt405du91z4	d9411b821a205a2b845fde5defbbff30889b557d812ca2da7ef9eb803db90a37	502544180	FT 101	057059297	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-07-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.559
cmnhoyxoc01j0rkt4y1qaw9e0	a0cc42d2c280e2e66b12c6945437906df77b3621af097d318849ff8013c99ead	502544180	FT 101	055525185	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-06-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.564
cmnhoyxoi01j1rkt4rscrl27p	5cf96463be879c8540cbf77c9b444a35b14665d0218afe297aa6b4a1f46e2da7	502544180	FT 101	053992998	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-05-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.57
cmnhoyxoo01j2rkt4kwt26729	e537ce45d3e11e514a48901b72d1ec1e6b5550fe87dabed0b9c5331b2ce14d74	502544180	FT 101	052483830	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-04-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.576
cmnhoyxou01j3rkt4eonbaelm	4261a8268b24bbae82684c4cfdab9c36212f22ab401d60244bc17891d38dd455	980245974	FAC 0240312023	0061292397	\N	Endesa Energia S a Sucursal Portugal	2023-06-08 00:00:00	33.85	7.60	41.45	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.582
cmnhoyxp101j4rkt4hslmkpoi	7f5382cafbd1a84ce571eb2e23f02151dcb925edefa780b6c8b8504feb7fdc06	502544180	FT 101	060170597	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-09-05 00:00:00	32.87	7.56	40.43	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.589
cmnhoyxpb01j5rkt4q7fupu72	e6e5a23a46bf6a6014ab503d46c833a8ce7caed760609ac2036b8b22599a9962	507903480	FT 2023A0430	64734	\N	Everything Is New Lda	2023-09-04 00:00:00	124.53	7.47	132.00	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.599
cmnhoyxpn01j6rkt4n8mje7jt	9f8430475bb854bdfb8217d911fca16b90ebfa84adf6b2fd440a328100f88783	502604751	FT 202392	3321280	\N	Nos Comunicações S A	2023-12-19 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.611
cmnhoyxpu01j7rkt4c8r901fo	63d31081700ff55177362ae5987fb3d200288b63e00e8db8b72f8dc8d169bc64	502604751	FT 202392	2876869	\N	Nos Comunicações S A	2023-11-17 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.618
cmnhoyxq401j8rkt44xukt43q	82ba45f38cddb3bbe59b58e613ffdcab03ba41bf2b64088da937ec97a49744bb	502604751	FT 202392	2761480	\N	Nos Comunicações S A	2023-10-17 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.628
cmnhoyxqb01j9rkt4nr8f14jh	d2780b3e70c22ae1cf3122656b2cb71f12f833736fd7c917ba5589a6228a12b4	502604751	FT 202392	2477391	\N	Nos Comunicações S A	2023-09-19 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.635
cmnhoyxqi01jarkt4c2cgfk9j	fcb061a745d23d176fbed59df0b8d2d785c01fbdd21a63c97429d3402de1a5a4	502604751	FT 202392	2164496	\N	Nos Comunicações S A	2023-08-17 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.642
cmnhoyxqm01jbrkt4xsz8kr2b	3c3b59ba4afb9fe8141bd6ecddf8743a3cb75073ae912e81626b9bf793ff3b5a	502604751	FT 202392	1905764	\N	Nos Comunicações S A	2023-07-18 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.647
cmnhoyxqr01jcrkt4bwudyowg	97b6204ea32ae1b097fd70dc0996e807c9dcff9fc5665eacc9a475dcc4972b76	502604751	FT 202392	1618243	\N	Nos Comunicações S A	2023-06-19 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.651
cmnhoyxqx01jdrkt42clvlu0q	6e72915e58ea7c48ec94bcbc73e894e89448e6221eec29b3ec95c8b4dbea1a10	502604751	FT 202392	1317687	\N	Nos Comunicações S A	2023-05-17 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.657
cmnhoyxr201jerkt401gwifsv	88261bab4c2aeec236afc3fffda54fd8d4cfdfbcacd6c5bb313e61111b4a1279	502604751	FT 202392	1053003	\N	Nos Comunicações S A	2023-04-18 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.662
cmnhoyxr601jfrkt4gb4h5dmm	373eb6b78cf1ea819af053613a9e1cd3444be3508ccfd4cd3e6158601150ed8d	502604751	FT 202392	796029	\N	Nos Comunicações S A	2023-03-17 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.666
cmnhoyxrb01jgrkt4kk2af909	1494a1a4eedab604b1d47536a8c5ffe613263334de22d6942078d0f1b1ba32cd	502604751	FT 202392	398182	\N	Nos Comunicações S A	2023-02-17 00:00:00	31.55	7.25	38.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.671
cmnhoyxrh01jhrkt4chf7zadt	35a23d21f7261976489bf680c37e505503a9566ef3b044f8ec41410b456101e1	980245974	FAC 0250312023	0065501832	\N	Endesa Energia S a Sucursal Portugal	2023-10-12 00:00:00	41.88	7.24	49.12	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.677
cmnhoyxrz01jirkt48tvmk54o	36024725e1a3a720eba6fc2a0a64ceea7e76aec08799eab69da3f723bfecf194	506848558	NC 20230330103	021759	\N	Bcm Bricolage S A	2023-10-03 00:00:00	-30.89	-7.10	-37.99	Nota de crédito	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.695
cmnhoyxsa01jkrkt4jyde9jdm	3be69b449c5f02fb3239e3e78573980c841f38031111cf95ce726714f5fe3a5c	502604751	FT 202393	87277	\N	Nos Comunicações S A	2023-01-24 00:00:00	30.89	7.10	37.99	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.706
cmnhoyxsh01jlrkt41pxw5avt	14a3083a845b4bc9f9821950cec1c14c435ffbee1dd7c2276037866d5ff6af5d	502544180	FT 101	050970334	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-03-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.713
cmnhoyxsn01jmrkt4w6ohv7lw	c48348e20346de8eb1f4e7f9b0c5f45ef3d0c0fd1c4ef0b5e218a1ca468aac8e	502544180	FT 101	049460026	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-02-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.719
cmnhoyxst01jnrkt4fv5518em	571079998f3ecfa3792afa8c63f5236e6769234678522b1f7d98b1f9acd285d9	502544180	FT 101	047930511	\N	Vodafone Portugal - Comunicações Pessoais S A	2023-01-05 00:00:00	30.81	7.09	37.90	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.725
cmnhoyxt001jorkt4ljv0ipw9	4bf388c2b147512ba8656a6e051248683f608beb551c0c85384b93339f2375ac	980245974	FAC 0230312023	0057566856	\N	Endesa Energia S a Sucursal Portugal	2023-11-08 00:00:00	31.11	6.97	38.08	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.732
cmnhoyxt901jprkt4dhwmmce5	d1ddba479f1f2f581bd7afbc1d2d78fec22c4c76a86be8aff255f9f9ab4ef8ba	980245974	FAC 0260312023	0069219556	\N	Endesa Energia S a Sucursal Portugal	2023-05-06 00:00:00	35.52	6.88	42.40	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.741
cmnhoyxtg01jqrkt409f3a3rw	5c8a41022e1e3e60519c1a8fc98e24fd4148f90729009bd59f6d29aa7e03a06b	980245974	FAC 0240312023	0061236721	\N	Endesa Energia S a Sucursal Portugal	2023-05-08 00:00:00	39.77	6.84	46.61	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.748
cmnhoyxtn01jrrkt45s9iq76a	d3048f0013efe8bde2c2f13733f381ebb48b5e1d9e0ee99029b549424f79f0fc	502604751	FT 202392	250334	\N	Nos Comunicações S A	2023-01-17 00:00:00	29.26	6.73	35.99	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.755
cmnhoyxtv01jsrkt4udl1aro7	fec38df0c3648d87d55c93c4d1a2d5963f0840efbbdaec7c991e2a8e07dc8d0b	980245974	FAC 0250312023	0065283459	\N	Endesa Energia S a Sucursal Portugal	2023-06-06 00:00:00	34.04	6.57	40.61	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.763
cmnhoyxu101jtrkt45nr27jj1	0fe8a84179a5dee95279fdb61bf157a4657aa74c5bd9d9a69cdb9a3f9c89139f	513956174	FT 17A2301	418	\N	Alcance D Excelencia - Pizzaria Lda	2023-06-14 00:00:00	42.99	6.36	49.35	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.769
cmnhoyxu801jurkt47wo51gxr	0dcb2bf4945bfa6b78c413bcb35d3c1834c836ecc93e92c0c8bd2c927593407b	980245974	FAC 0240312023	0061198347	\N	Endesa Energia S a Sucursal Portugal	2023-04-16 00:00:00	32.86	6.09	38.95	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.776
cmnhoyxue01jvrkt49pr8hcwa	a32ea9f3963bcf81a474091021d6a19615b5bc11510e78289daa2bd03e91ed09	980245974	FAC 0240312023	0061519737	\N	Endesa Energia S a Sucursal Portugal	2023-10-08 00:00:00	26.74	5.96	32.70	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.782
cmnhoyxul01jwrkt4o16xj4gv	69db874936813d174e765ed8a41c9412eb8d99d2b9dc1fd0c1d52e5c3077ca09	980245974	FAC 0240312023	0061404819	\N	Endesa Energia S a Sucursal Portugal	2023-08-08 00:00:00	26.31	5.87	32.18	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.789
cmnhoyxur01jxrkt4z2ze7fs7	c8abe13c16ba91463cdf6b6fbe2d7dfc76dcf7d37305b9abf84711892181d4d4	980245974	FAC 0250312023	0065131428	\N	Endesa Energia S a Sucursal Portugal	2023-03-12 00:00:00	26.16	5.83	31.99	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.795
cmnhoyxuv01jyrkt4ztbx46ut	8ffc4d3b3f2ca590eaff0911bf4885a3b6cde56de4638e77d6408e653cfc44ff	980245974	FAC 0240312023	0061536569	\N	Endesa Energia S a Sucursal Portugal	2023-10-16 00:00:00	35.38	5.76	41.14	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.799
cmnhoyxv001jzrkt4ix3eettp	4a308da0a48a33e3e68ce79651a917216c8a05309e0a16cce6186e21f40d66e2	980245974	FAC 0250312023	0065336816	\N	Endesa Energia S a Sucursal Portugal	2023-07-07 00:00:00	30.25	5.67	35.92	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.804
cmnhoyxv601k0rkt464wyxfm8	ea0b727d2ac0222306cc1eeb0270da1c4394ec22b4f8d3612b2db89f27a27b01	503630330	FS AUM004	088289	\N	Worten - Equipamentos Para o Lar S A	2023-09-20 00:00:00	24.38	5.61	29.99	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.81
cmnhoyxvc01k2rkt4j76228oy	faf9ac1c99d4554df1853ca59be1cd322ee1a3ba72e68a6d7f1f7f12e35e884c	505993082	FAC 006	60792592	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-11-23 00:00:00	100.33	5.35	105.68	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.816
cmnhoyxvh01k3rkt40l5b9n5x	9d6c44791bcdba7e2aa798fb7fecc267801019e0762f48849ed60353979b7512	980245974	FAC 0240312023	0061292788	\N	Endesa Energia S a Sucursal Portugal	2023-06-08 00:00:00	30.98	4.89	35.87	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.821
cmnhoyxvo01k4rkt4j49lib29	e033daab5a20e82e0c6385e0c1482011ef6e56bd4fa6fdfc51d6c80ed1f83296	513529381	FTN2 12	4260	\N	Mauricio & Jordão Lda	2023-08-06 00:00:00	32.64	4.66	37.30	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.828
cmnhoyxvu01k5rkt4q6e06vx0	40591814ddba58b831b850354a32b6c997b08a4ee1460b5371bd0228e5f7d3f1	507688694	FS 2023A540	63100	\N	Branco e Negro Gifts e Decoração Lda	2023-08-05 00:00:00	20.66	4.54	25.20	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.834
cmnhoyxvz01k6rkt4tb3q9ra6	1f9a7f0a1f69802b912d8260eaa9d618c972a5fa812673d7e77d4e896c220933	980245974	FAC 0240312023	0061518833	\N	Endesa Energia S a Sucursal Portugal	2023-10-08 00:00:00	31.43	4.43	35.86	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.84
cmnhoyxw801k7rkt4zgjw01fn	023b9c90e72c7e010345a56c5305d18c223cb2ecd669e8797cb2d7238288de46	980245974	FAC 0250312023	0065391565	\N	Endesa Energia S a Sucursal Portugal	2023-08-06 00:00:00	28.85	4.38	33.23	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.848
cmnhoyxwf01k8rkt4f5bi3vce	3bd7b6363486491f45ae81af1ee34c7438c8cd74c845dfe30a9b15d511f09225	980245974	FAC 0250312023	0065445754	\N	Endesa Energia S a Sucursal Portugal	2023-09-05 00:00:00	29.15	4.31	33.46	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.855
cmnhoyxwl01k9rkt4xh0g07m8	a1d6af068e3722d672b7d0d4abaf5399e7661a4fc343c76fd6c21b6d02c7d89d	513747087	FS 1	116022	\N	Tl Paçô Vieira, Unipessoal Lda	2023-09-04 00:00:00	32.04	4.16	36.20	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.862
cmnhoyxwq01karkt4kfdgaxwk	7582ceccd752a191e270b5067f424c851d0fc4f6f08c782d0440d01c3bb9d8d1	980245974	FAC 0240312023	0061347832	\N	Endesa Energia S a Sucursal Portugal	2023-07-08 00:00:00	27.58	4.04	31.62	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.866
cmnhoyxwy01kbrkt4qvmsz1ws	fdc3dd77b29f351ef7acc5b2158d8c9327dad9907dfe03623b4783238207816d	980245974	FAC 0240312023	0061252984	\N	Endesa Energia S a Sucursal Portugal	2023-05-16 00:00:00	23.41	3.97	27.38	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.874
cmnhoyxx401kcrkt4rgbujqdp	ea27b48f449c7167595884448ba7f65b6de4625ee41a34de27948912b56c2a9a	980245974	FAC 0240312023	0061308848	\N	Endesa Energia S a Sucursal Portugal	2023-06-16 00:00:00	23.59	3.96	27.55	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.88
cmnhoyxxd01kdrkt47jh2gcad	8160909549f2edd7865ee9893b1b10e0671ec38874e6b7693433279b6fecb7a4	501966013	F F2023	36	\N	Forte S Francisco Hoteis Lda	2023-01-14 00:00:00	63.68	3.82	67.50	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.889
cmnhoyxxl01kerkt4o5bjarh1	29585be252a8481bb0f27890e6e38a22dbc4d0476c55063f0e60307e4cb7001b	980245974	FAC 0240312023	0061420853	\N	Endesa Energia S a Sucursal Portugal	2023-08-16 00:00:00	25.76	3.80	29.56	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.897
cmnhoyxxq01kfrkt4geqim6wr	0d20cb1e5539b29cd39b444424f548e6f9fd21f034a6ef6488ec33e281723423	505993082	FAC 006	60792214	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-11-22 00:00:00	74.10	3.77	77.87	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.902
cmnhoyxxy01kgrkt4jyzxit62	fe1f9b78d03b5852eb160e2c3d0e51ae3910509e7e167b58ddd545eeb355b56c	980245974	FAC 0240312023	0061478578	\N	Endesa Energia S a Sucursal Portugal	2023-09-16 00:00:00	24.63	3.73	28.36	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.91
cmnhoyxy501khrkt4hor53g1k	9582b38eebdd88791c2997f99736b20578642b682fbba63c493ae5f259c120bc	506848558	FT 20230335101/000064	JFF4VSDJ -000064	\N	Bcm Bricolage S A	2023-01-07 00:00:00	16.15	3.72	19.87	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.917
cmnhoyxyg01kjrkt47io1ybol	16a07c1c0573013ce9ac0900fc4756e437e20b9ad461b38c6e5a7ed1f46f24f7	505993082	FAC 006	60748070	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-08-31 00:00:00	81.35	3.59	84.94	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.928
cmnhoyxyk01kkrkt4oun2ae26	931a44e7d8970914595a7901b516c13b80cca2673eece6ddb34204a3d8d8f42f	505993082	FAC 006	60703874	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-06-02 00:00:00	81.35	3.59	84.94	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.932
cmnhoyxyq01klrkt4s44aaivx	d1409ece4dd86fd23dee14f2874dbe60d4128f420f7a1e4240fff01b17b810a6	505993082	FAC 006	60673836	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-04-03 00:00:00	81.35	3.59	84.94	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.938
cmnhoyxyz01kmrkt4n2hjyyj0	ed464e3083cc9822922ebf481319bded1860d7595c444c293314b8a3ba70ec25	507718666	FAC 009	93858391	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2023-12-20 00:00:00	57.21	3.44	60.65	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.947
cmnhoyxz901korkt47y2gc9w7	469524a862026baa9ca2d5f59db371d353c01efe337585525d091802a5719bd7	980245974	FAC 0240312023	0061363867	\N	Endesa Energia S a Sucursal Portugal	2023-07-16 00:00:00	20.72	3.42	24.14	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.957
cmnhoyxze01kprkt4yu1geoj1	fb0e80df4adbfd0f456f9c5d3157ebcebca0ee6c6e697019b80c91c05503c61d	505993082	FAC 006	60700228	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-05-24 00:00:00	68.89	3.39	72.28	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.962
cmnhoyxzi01kqrkt46kvqyu5d	2b00005005a468394b49bce94db2811befddde4801b628a092aeaf61c795d616	980245974	FAC 0280312023	0077453796	\N	Endesa Energia S a Sucursal Portugal	2023-10-09 00:00:00	16.79	3.35	20.14	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.966
cmnhoyxzq01krrkt4h3n1487b	894316ddb6ca9d78da611f39e45279852bd8a98d730b92a8a5ccea4b89b96f42	505993082	FAC 006	60717054	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-06-29 00:00:00	75.41	3.33	78.74	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.974
cmnhoyxzu01ksrkt4u3kcfo2v	523b4735d51a09f98d68de6e896b6a576adeb56e5ed45f87a273a4d6448cd512	505993082	FAC 006	60645974	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-02-02 00:00:00	74.78	3.28	78.06	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.978
cmnhoyxzy01ktrkt4jexyr5o9	25689517f73e44309410bd0033076b051d6bd47cb334b1d68fa241f2014d2e0e	980245974	FAC 0280312023	0077502168	\N	Endesa Energia S a Sucursal Portugal	2023-11-09 00:00:00	16.64	3.27	19.91	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.982
cmnhoyy0301kurkt4jr90iwqz	88e54ae315b78ce3db9126fc0d515c9f0e1f09d9e6d3066eb102fa27f009399b	507718666	FAC 009	93800248	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2023-11-27 00:00:00	53.26	3.21	56.47	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.987
cmnhoyy0f01kwrkt4lth8whb3	0da1b184acda39558bd24b7cf92f6557b8c148b60ec5b2c2cd03dc8a4677a0ae	980245974	FAC 0280312023	0077548826	\N	Endesa Energia S a Sucursal Portugal	2023-12-09 00:00:00	15.72	3.14	18.86	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:09.999
cmnhoyy0m01kxrkt4ds5ws9bu	a551954d127f3fdc1b3299f26a4a5537bbad6ccd06750cd783c17b68141ff3ed	505993082	FAC 006	60809584	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-12-26 00:00:00	62.24	3.12	65.36	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.006
cmnhoyy0s01kyrkt4l62gyjon	192690900ae622f5b70f7bfda85322c2c6bc23b15506b12b979f6e2072879ea6	505993082	FAC 006	60764705	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-10-02 00:00:00	70.75	3.12	73.87	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.012
cmnhoyy0x01kzrkt49o1gw78p	c07f3059ec963e0c6283d978a4b92f1b0f370cd28e7d8517cd67bd439f7e7f54	505993082	FAC 006	60732861	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-07-31 00:00:00	70.75	3.12	73.87	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.017
cmnhoyy1501l0rkt40qhmga1s	f4339eb40222379738a03d81fcb21f624d3d7a0a90e2d60ce3de225533e8249c	505993082	FAC 006	60688184	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-05-02 00:00:00	70.13	3.10	73.23	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.025
cmnhoyy1d01l1rkt4h6ea05b4	f8faab526b335fae36f10291c560c2d759a313bd3b9345ed7b4dbabdf76157a0	503301043	FS FS.2023	7881	\N	Ferragens e Ferramentas S Gonçalo Lda	2023-08-30 00:00:00	12.66	2.91	15.57	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.033
cmnhoyy1m01l2rkt4fw45r07x	4602bad7e1846716af5ba4e1b20f4e9130434722762939431abb8ecda6404a5a	505993082	FAC 006	60658279	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-02-27 00:00:00	64.71	2.86	67.57	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.042
cmnhoyy1v01l3rkt4jzmhsblo	33af0a95c10508cd28b1b60639a80d847c3ffd388439aa1000e9507e2a118d20	505993082	FAC 006	60745951	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-08-25 00:00:00	58.38	2.81	61.19	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.051
cmnhoyy2501l4rkt4latj614v	4c85fb2b282427c78bc404ee1e6f48715eb8ac00e4af337bd8aee59f0120692e	980245974	FAC 0240312023	0061461729	\N	Endesa Energia S a Sucursal Portugal	2023-09-07 00:00:00	18.15	2.78	20.93	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.061
cmnhoyy2f01l5rkt4nsaunv88	38be9d98506158f195691e4a0b1086669922ad53da66a63bbf7e5fca7f6e46c5	505993082	NCR 006	60760964	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-09-22 00:00:00	-35.53	-2.77	-38.30	Nota de crédito	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.071
cmnhoyy2p01l6rkt45xojj4o0	99897f54900b2c730749215d881c4e92016d41571739040aa6672aa2769eff0c	505993082	FAC 006	60760041	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-09-21 00:00:00	56.34	2.74	59.08	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.081
cmnhoyy3701l7rkt4wt3e7xdt	66def5b59569986de2adc3166f3ff62183dc1e9052ab8ef7cd690bb658318a13	980245974	FAC 0240312023	0061404751	\N	Endesa Energia S a Sucursal Portugal	2023-08-08 00:00:00	17.99	2.72	20.71	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.099
cmnhoyy3e01l8rkt4cc979qn3	e1916125cf88651e15e50f1022730ce77ea2efad01f542a572975cce07907248	502075090	FT 5012023	90900	\N	Arcol, S.A.	2023-12-14 00:00:00	11.73	2.70	14.43	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.106
cmnhoyy3o01larkt4tsal4c7o	4dbd58f241653e5e3f72b5307cd9fcfe9cfe5f2aa5c42e78d2379a630d1a0133	505993082	FAC 006	60730400	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-07-24 00:00:00	52.39	2.54	54.93	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.116
cmnhoyy3v01lbrkt4zvvcis4d	9e03ac99bc19d2418fdfe64e20a16910d390e0044d6067b66edd69bd7e893745	505993082	FAC 006	60715884	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-06-26 00:00:00	52.39	2.54	54.93	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.123
cmnhoyy4101lcrkt4hxeksqxm	4954361f622d94f8df4bfabcf09638198bfe8168d95faefe4ba49f21074593a5	980245974	NCR 0240312023	0063006063	\N	Endesa Energia S a Sucursal Portugal	2023-09-07 00:00:00	-9.96	-2.48	-12.44	Nota de crédito	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.129
cmnhoyy4701ldrkt45pwolcfc	9626e0ea8381688e220862ed56524e813b5d03858811bc4e04ffe2e06429a5e1	502011475	FS AAH033	486307	\N	Modelo Continente Hipermercados S A	2023-11-06 00:00:00	10.57	2.43	13.00	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.135
cmnhoyy4e01lerkt4inwj9oey	149dda4875c556b3bc3adca4bb33ce3d273075de19add4f7bf4f4dcf961a0305	506848558	FT 20230330601	000127	\N	Bcm Bricolage S A	2023-02-04 00:00:00	10.56	2.43	12.99	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.142
cmnhoyy4m01lgrkt46k3kg2hd	89284f9f090b077d1da6d9dd9595d6b497688055653b087752ff62835361c31b	505993082	FAC 006	60669762	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-03-22 00:00:00	51.83	2.41	54.24	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.15
cmnhoyy4t01lhrkt47fm08tpb	dbf75bb5ab4addbc859d736b74d3afd2c47f92a17ebdd7acf550afee16cf9e2b	505993082	NCR 006	60780152	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-10-31 00:00:00	-43.54	-2.38	-45.92	Nota de crédito	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.157
cmnhoyy5001lirkt4dpxtuc27	d7ea35ea74d3e770a24e60615144ab2b4c46c82d30b51546931f76fc70c8f04b	505993082	FAC 006	60809956	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-12-26 00:00:00	49.12	2.33	51.45	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.164
cmnhoyy5701ljrkt4j9vvy5wl	f1e38517cdd16c15915bb2f1feb3078d74da4ec7e678c3100fc52528c469a542	503789372	FAC 1302232	0019840	\N	Staples Portugal - Equipamento de Escritorio S A	2023-11-05 00:00:00	8.92	2.05	10.97	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.171
cmnhoyy5f01lkrkt49sbdmfa6	5f0180b408e2e9147f64aaf88559a1802b79d8660f0979c5069a9da678041c96	505993082	FAC 006	60796388	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-12-04 00:00:00	48.71	2.02	50.73	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.179
cmnhoyy5k01llrkt4g0cvckbp	3eadede996e61856b2ccf205121f66478ebc0a27d35a2a90231c46548a73412d	503834114	FS FS.2023	112	\N	Arlindo Augusto Pimenta & Filhos Lda	2023-01-21 00:00:00	8.46	1.95	10.41	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.184
cmnhoyy5r01lmrkt4kxs4bbm7	13949b03f189255eec831590e68a29b477cbba5af50a844ae7c37dde5b446370	505993082	FAC 006	60686211	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-04-26 00:00:00	41.87	1.92	43.79	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.191
cmnhoyy5y01lnrkt49vnab2n0	6921f2438ae6532dfc360f2d23863ad122f84ee2caa0a714bc1f41ff8aa53d14	505993082	FAC 006	60655815	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-02-20 00:00:00	41.48	1.89	43.37	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.198
cmnhoyy6601lorkt45047fsbt	ab5b15a5815433759d56a4d83d28374143b2f6655cc739f1fe55d29bad099012	504691031	FT 2023A0000	321393	\N	Ticket Line, S.A.	2023-09-04 00:00:00	7.92	1.82	9.74	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.206
cmnhoyy6a01lprkt4o0vig9ct	3e82bd53f22f87bb55e8448677b1e8f3a273c1e7b73ba0f491e623c411aa0d09	505416654	FAC 0091232023	0003731	\N	Ikea Portugal Moveis e Decoração Lda	2023-04-14 00:00:00	7.32	1.68	9.00	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.21
cmnhoyy6f01lqrkt4m489olon	0e64b5787c1b7e2edab985cbca22a58e3c56519b557904bd3b21e0da47807c2e	501659463	FR A2023	737	\N	Pedro Filipe e Jose Filipe Lda	2023-02-20 00:00:00	11.95	1.55	13.50	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.215
cmnhoyy6n01lrrkt4fws3xq1z	4ad0d73a072cfc9c5a16f20714e4056b6142001225e666a9461ceaa11998cd1a	505993082	FAC 006/60641137	JF5TR5V6 -60641137	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-01-20 00:00:00	35.76	1.53	37.29	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.223
cmnhoyy6t01lsrkt4e6ms4jbk	8d0d2af384b38bba2c58400d299c16bc9c3edcd72228963fd0e9963e0346adf1	506848558	FT 20230335101	002513	\N	Bcm Bricolage S A	2023-09-11 00:00:00	6.50	1.49	7.99	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.229
cmnhoyy7301lurkt4mmd294uh	6c3f088c488fc96d40a6ed03b01596b4f69956e79d78ef58a866f853af03220b	196627001	FS 22	2581	\N	Maria Helena Barbosa de Oliveira	2023-02-22 00:00:00	5.28	1.22	6.50	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.239
cmnhoyy7801lvrkt4m786qj3p	6a9d62d533d0a8a6e0496f389a9e8b3294108300e09051b7b3d7d75fc3fca960	505993082	FAC 006	60776921	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-10-23 00:00:00	29.59	1.15	30.74	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.244
cmnhoyy7c01lwrkt4hdxqknol	a5f0b2ff90c4c02b01424e1fb49298c1b3b31f7237959d0cfb195c865316c2ec	505993082	FAC 006	60776500	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-10-23 00:00:00	29.44	1.15	30.59	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.248
cmnhoyy7j01lxrkt4ckm5zylv	dbfb7287e2bb36b3d6c8824590a26f1d3c2f5ec03d98eb86897f53002e03abb0	506848558	FT 20230335301	002640	\N	Bcm Bricolage S A	2023-08-30 00:00:00	4.86	1.12	5.98	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.255
cmnhoyy7q01lzrkt4s3vnet05	dccea6b9897f8617292804de13c8ba47f2237a523ba054e695635ba9efe330cf	506848558	FT 20230335301	002939	\N	Bcm Bricolage S A	2023-10-03 00:00:00	4.06	0.93	4.99	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.262
cmnhoyy7x01m1rkt4e50kwi09	5b7039b872f98a6c95771221cfb1041eb62e3eda1964041616d33a727c53e1cb	506848558	FT 20230335301	003441	\N	Bcm Bricolage S A	2023-11-14 00:00:00	3.65	0.84	4.49	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.269
cmnhoyy8701m3rkt4mqduueau	ee74ec6e19e676e8a8377e2296e7ecceb71b0665990cbcd0db5c681c8cf526f0	505993082	FAC 006	60700147	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-05-24 00:00:00	22.96	0.65	23.61	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.279
cmnhoyy8e01m4rkt4otonlpql	2d8031d5becbf27948e9b1088eac4462b0ff9d3304c3a9e2149c304e8857df46	505993082	FAC 006	60745782	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-08-25 00:00:00	22.29	0.64	22.93	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.286
cmnhoyy8m01m5rkt4rgn8dpnh	b0cfb66962dfccae9d4bce2e9ae405b4bc59a1c6ae71e6885864ba0d7df73b2d	505993082	FAC 006	60670081	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-03-23 00:00:00	22.30	0.63	22.93	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.294
cmnhoyy8u01m6rkt4mfnl7r93	0aafd9fd57b5a6f5cd65934d223e23fd2ad0c719cbaa96cc0d56b5e7631f2d49	503301043	FS FS.2023	9013	\N	Ferragens e Ferramentas S Gonçalo Lda	2023-10-03 00:00:00	2.61	0.60	3.21	Fatura simplificada	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.302
cmnhoyy8z01m7rkt49mt54o4r	4f73c9ed9871d79afcc5813d1ac280cabcb61b34c77fd333f44821ebc8bfe94d	505993082	FAC 006	60641811	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-01-23 00:00:00	19.83	0.57	20.40	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.308
cmnhoyy9801m8rkt417emlj72	18b076befc6a83ce425ed02e4fbd57be7d5dcfd54b3e3d9eb2641d0f95cca025	505993082	FAC 006	60729915	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-07-24 00:00:00	19.59	0.56	20.15	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.316
cmnhoyy9f01m9rkt42nvp8lgh	40f8be158ac9e35faac7c630c45c4ef0cc4ffe296f65c016bbce934a73f51c8c	505993082	FAC 006	60685617	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-04-26 00:00:00	18.90	0.54	19.44	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.323
cmnhoyy9m01markt49mghk88q	8cd9af28305ab104c99d4faeb6ba98466ba24155359d69eaf987c38f6c73c32a	505993082	FAC 006	60655280	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-02-20 00:00:00	18.81	0.54	19.35	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.331
cmnhoyy9v01mbrkt48afkxc1h	7763f7dc3a789cca1ba2bf0896ba7af59cb81d20a594ed2b71e095fab956c57f	505993082	FAC 006	60715445	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-06-26 00:00:00	13.51	0.39	13.90	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.339
cmnhoyya601mcrkt4jn4lk93q	51282f97de73a6ffebd691974db9aad33e41c7dd3a0f2269ec305e0a6d6731e2	506848558	FT 20230335201	000396	\N	Bcm Bricolage S A	2023-02-13 00:00:00	1.21	0.28	1.49	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.35
cmnhoyyai01merkt49q5ewxzp	f0dd01898244559af8160fcd7b2f9caa2d0e4bddf5893edd6939872adc89b6cc	505993082	FAC 006	60715446	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2023-06-26 00:00:00	6.07	0.17	6.24	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.362
cmnhoyyap01mfrkt4oxfbxcm5	95a68fdee8b2223ab84d154149c498c4a5b0db99db826efbf51384b8d909e66d	501578455	FR150 150/7458	JFMXY9B6	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-06 00:00:00	0.00	0.01	0.01	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.369
cmnhoyyay01mgrkt4l4uz1732	91b795a3bb5880ddae5f47237ce9ec2635a0ea1db57f6302da5b81247b1e2fa5	514280956	FAC 109	1182971627	\N	Empresa Municipal de Ambiente do Porto e M S A	2023-12-20 00:00:00	24.68	0.00	24.68	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.378
cmnhoyyba01mirkt4z9yv7on3	3bb22563424d87d829d0f08e8cc96a1b168ed8246215cc520bc7f959ef2c059a	514280956	FAC 109	1182914171	\N	Empresa Municipal de Ambiente do Porto e M S A	2023-11-27 00:00:00	22.65	0.00	22.65	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.39
cmnhoyybj01mkrkt4ath3vo6k	78dfa2bb9b02905d0ad97a38b836f18be410dd4c8a7dfdb84d85da65dbf75d00	513204016	F1 F42A	4204838686	\N	Novo Banco S A	2023-11-23 00:00:00	17.50	0.00	18.20	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.399
cmnhoyybp01mlrkt4f0y3mgnc	a3b61bbff8d8aa59f4cbc7de3e9e0ee9c23e2ec791a1bf0e03cf9183baad7486	514280956	FAC 109	1182824226	\N	Empresa Municipal de Ambiente do Porto e M S A	2023-10-18 00:00:00	22.65	0.00	22.65	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.405
cmnhoyybz01mnrkt4supnsnvq	a3f10f0dc09e050e5a94857f68d67b9213f29d0e1e9b92fa11ebb765c287b5b7	501578455	FR110 110/19732	JFM5YJW4	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-10-03 00:00:00	0.00	0.00	0.00	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.415
cmnhoyyc401morkt4fys9u9hh	354d7dda9d20c8adecbbdceb26267b502f00a9b66369eef2b3d077d695b4712b	501578455	FR150 150/7705	JFMXY9B6	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-15 00:00:00	0.00	0.00	0.00	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.42
cmnhoyyca01mprkt4w62h34y3	742a13033672650bb138407ce81fa019e60661251495c4e14f66c8887fc2283e	501578455	FT101 101/26836	JFMB6MNW	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-12 00:00:00	0.00	0.00	0.00	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.426
cmnhoyycp01mqrkt4uwzn40vo	c97c4f9171d69aabce76766fe4531138a7cd5fa7a8dfe6cd3325a76771e55423	501578455	FR150 150/7413	JFMXY9B6	\N	Abilio Rodrigues Peixoto & Filhos S A	2023-09-05 00:00:00	0.00	0.00	0.00	Fatura-recibo	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.442
cmnhoyycw01mrrkt4kovmx6vx	a12e93139a0fb1bb5cde9198d39321405f2f4e5c12a688214d196ad594e6212e	513204016	F1 F42A	4202591596	\N	Novo Banco S A	2023-07-05 00:00:00	20.00	0.00	20.80	Fatura	cmnhoywp301fprkt4xogmq81l	2026-04-02 16:31:10.448
cmnhoz2ca01mtrkt4q5u4izjp	fdd14fd4bda5b79876e95bda767bb6532be4973564e2ca3e757c6c1ac714ee31	507432444	FT FT24_24	134	\N	Sampulau Lda	2024-10-21 00:00:00	2816.95	647.90	3464.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.61
cmnhoz2cg01murkt4q7al13uh	7eb23347ed1745450aef0a0f51c1f0c50edbe99a8e093d758141e4e1d7050d01	506848558	FT 20240080201	007120	\N	Bcm Bricolage S A	2024-07-31 00:00:00	1348.74	310.21	1658.95	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.616
cmnhoz2cq01mwrkt4eil1a54m	0828d3692e6d96b9323577075166a145a645834a594dc452c60505ad591f24ad	200235125	1 2024	19	\N	Jose Antonio Pereira Salgado	2024-10-11 00:00:00	1089.43	250.57	1340.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.626
cmnhoz2cv01mxrkt4bzfwilme	d45855ea77efc1a232cdf5608a5aaecae279244641b32455fcce1f41ea46db6a	508546702	FT 2024A1	371	\N	Norcana - Canalizações do Norte Lda	2024-12-23 00:00:00	1089.00	250.47	1339.47	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.631
cmnhoz2d401myrkt4pvoboxos	ca4beb0dcf19062ec8374bcdee5b1e2e05cfb03e0185085b479b24695efe4c11	502021420	1 2400	000300	\N	Manuel J S Peixoto e Cia Lda	2024-12-30 00:00:00	730.89	168.11	899.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.64
cmnhoz2dc01mzrkt4v3v7rkpj	a813b9497988b1d54c13e4363ef4c93099f461b6ccf44116478a78d8b2f6d240	506848558	FT 20240105501	007133	\N	Bcm Bricolage S A	2024-07-31 00:00:00	613.24	141.04	754.28	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.648
cmnhoz2do01n1rkt4ak7kvv6n	21aa93c24b1f902f65fa214390e5d34ebee806bfd106001a7b27fb503aa38ed9	505416654	FAC 0091322024	0018689	\N	Ikea Portugal Moveis e Decoração Lda	2024-08-18 00:00:00	549.03	126.26	675.29	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.66
cmnhoz2dy01n2rkt4vpwvwufh	584309a43bf0ef7e08c3cb26fbfaa397c3956e7c9ece31f2003a320dfc196209	503000000	FACTC 155124	485	\N	A M Industria de Colchões Lda	2024-08-08 00:00:00	506.00	116.38	622.38	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.67
cmnhoz2e601n3rkt4bcw8r997	5ef37982d403726aa03c1d192ff193cb6cd04cb3be49902202c37fe0987b7054	513767258	NC 2024DVRD11	12	\N	Lbks - Lisbon Bike Shop Unipessoal Lda	2024-07-20 00:00:00	-1697.17	-101.83	-1799.00	Nota de crédito	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.678
cmnhoz2ed01n4rkt4w2qefyje	f8cbcc18de9ba086b30883a1b63050d01380d5291ab8674755da7744217cf8fe	513767258	FT 2024RDFT1	424	\N	Lbks - Lisbon Bike Shop Unipessoal Lda	2024-07-19 00:00:00	1697.17	101.83	1799.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.685
cmnhoz2el01n5rkt4igejo4qe	4c994fe6d9a331c89fcdd2ea1e5826a285a5fcc5abe71a21fdb6f78497a6e40a	513767258	FT 12	31818	\N	Lbks - Lisbon Bike Shop Unipessoal Lda	2024-07-20 00:00:00	1650.94	99.06	1750.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.693
cmnhoz2es01n6rkt4xjntxr7b	564be1416c246b9f7569efe510aaff53d057e1ed2c140ce039bfbab62f9952c5	501689010	FR 13	47173	\N	J Correia e Filhos Lda	2024-08-19 00:00:00	389.83	89.66	479.49	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.7
cmnhoz2f001n7rkt49ncxol47	16fab93bf60b5141ec420e36b4e7e5163f224296f4fa9fd47ff73af252ccbfb9	502021420	1 2400	000194	\N	Manuel J S Peixoto e Cia Lda	2024-08-14 00:00:00	1318.87	79.13	1398.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.708
cmnhoz2f901n8rkt4bs94pkx2	d21bf628767b871b96d289c22f4338aaf5cdd19b2b8cc23405b54dbeaf00a87b	510772153	FR 2024	1164	\N	Deltacraft - Equipamentos e Serviços Tecnicos Lda	2024-12-18 00:00:00	325.20	74.80	400.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.717
cmnhoz2fp01n9rkt489ph5cyu	ced02852ddce3b70e14d2d00bfce2466ebee26516b503bfe9bcedf7f5469000f	503630330	FT BZM005	065164	\N	Worten - Equipamentos Para o Lar S A	2024-07-27 00:00:00	317.07	72.92	389.99	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.733
cmnhoz2g001nbrkt458hmsdpt	ef981cfedacdecdf017dd74edc1b55f6d2b49923b8682ff17252f519bedc01d0	503129771	FAC-N 1	51248	\N	Pensão Floresta Lda	2024-07-20 00:00:00	472.23	65.67	537.90	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.744
cmnhoz2g901ncrkt4nvwlazjc	2237fb685ace97702f2374d4ebf928f532346d5d56d554917ce1bc61780a0f3b	502888512	FR 00002	5099	\N	Brandão & Martins Lda	2024-07-21 00:00:00	339.48	49.07	388.55	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.753
cmnhoz2gg01ndrkt4jy4iqgut	f47c194e66192cee51079ae3b9558653f51805d1f6dd5a8826d7d83cd2650af2	505416654	FAC 4990422024	0014168	\N	Ikea Portugal Moveis e Decoração Lda	2024-08-24 00:00:00	211.38	48.62	260.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.76
cmnhoz2gl01nerkt4r6ilw1mx	97826878c21d0cc621f46fed094fe1e8168deb523a5d7b448fe3c2eb6e25266c	500076375	FR 1032200	38061	\N	Copta Companhia Portuguesa Turismo Algarve Sa	2024-08-09 00:00:00	283.68	40.32	324.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.765
cmnhoz2gz01nfrkt4y0ag6osp	394f17219a945f648d911e534c9de3308bc32ca08f4c22a9ccc53323b416430e	508546702	FT 2024A1	260	\N	Norcana - Canalizações do Norte Lda	2024-09-23 00:00:00	171.00	39.33	210.33	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.779
cmnhoz2h601ngrkt4tdo8tj81	aa73e2c382136d7eea6e71d01c917d00cd0748d6824c1a3e31d3336b5c581ecf	505416654	FAC 0090672024	0018448	\N	Ikea Portugal Moveis e Decoração Lda	2024-08-15 00:00:00	160.98	37.02	198.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.786
cmnhoz2ha01nhrkt4n5mmie6h	64d3308c5bfb558d8bcf9529705b062410d5f71881fa9646aaeef9850913a878	231578504	FACC-N 1	9221	\N	Monica Linda Ribeiro	2024-07-18 00:00:00	186.03	35.97	222.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.79
cmnhoz2hg01nirkt4rtnucz3d	c6196ef84fcc755f3d450c3c3325bbda3d142e131e865cdefbd3dd89eeeccf46	505416654	FAC 0091332024	0018409	\N	Ikea Portugal Moveis e Decoração Lda	2024-08-18 00:00:00	153.66	35.34	189.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.796
cmnhoz2hl01njrkt4z8000crh	70cf6248bea00701719dec2c9012c91d433487b07702850d249ab13774e8625a	516676180	FT FT24	135268	\N	Ibelectra Mercados Lda	2024-12-30 00:00:00	147.16	29.89	177.05	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.801
cmnhoz2hp01nkrkt44gxo5nj5	6dc192916f0a49fa06291332cfda7cccd8a0df31e87b18721deb7bc7c305b516	505416654	DEV 0090372024	0002966	\N	Ikea Portugal Moveis e Decoração Lda	2024-08-20 00:00:00	-129.27	-29.73	-159.00	Nota de crédito	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.805
cmnhoz2ht01nlrkt473vlxq49	59ac36128fdf42b50ecfb457d299149aeb3dabcd921853548d8652ad3f1a6261	508546702	FT 2024A1	338	\N	Norcana - Canalizações do Norte Lda	2024-11-25 00:00:00	125.00	28.75	153.75	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.809
cmnhoz2i001nmrkt4dw6uoukj	e5b6d3829078c5a237b5fefb6aaac82fe99c089e1c27f844dce3433b999f6854	503340855	FS 042800524	188975	\N	Lidl & Companhia	2024-12-03 00:00:00	117.07	26.92	143.99	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.816
cmnhoz2i801nnrkt4lp0ubo6o	952c3e12ac4a116fc8970097207985d97e53d9537ad5fad5766ebe51792a0359	517514419	1 2024	147	\N	Cardoso Carvalho & Silva Lda	2024-11-26 00:00:00	115.00	26.45	141.45	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.824
cmnhoz2ih01nprkt47mo93ei1	479845bb2d230731517835d80d56b3d1a6e25fb3cf3f12abe93ea5ed564a3c21	506848558	FT 20240015801	003530	\N	Bcm Bricolage S A	2024-07-31 00:00:00	111.05	25.54	136.59	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.833
cmnhoz2it01nrrkt4kdsbowyn	1032feca6cb24f5c2cd346993e6ed36e83b8e952e77b543dcb0c48c1d6391e7a	508700566	FT 8	11282	\N	Mountain Park - Empreendimentos Turisticos e Imobiliarios Lda	2024-07-21 00:00:00	391.51	24.29	415.80	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.845
cmnhoz2j201nsrkt4iizh4isk	4bb4accead40c437e22e41aee9fd0491345f2785e49b470a9634f14253fedfad	506848558	FT 20240085601	005554	\N	Bcm Bricolage S A	2024-08-12 00:00:00	104.06	23.93	127.99	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.854
cmnhoz2jf01nurkt4eo04gxrx	5437953b11594f3ac1d6ab5cae07047ca9710e99b0b6dc345df975064b8ba175	505416654	FAC 0091172024	0003013	\N	Ikea Portugal Moveis e Decoração Lda	2024-08-20 00:00:00	102.22	23.51	125.73	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.867
cmnhoz2jm01nvrkt4qkoj0ufm	a076120cbb1e99b60562a6a4c7f06fa2cb24c5ba1c42ddec7859963fba379913	516676180	FT FT24	133837	\N	Ibelectra Mercados Lda	2024-12-26 00:00:00	116.35	22.86	139.21	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.874
cmnhoz2jq01nwrkt4g8bw4i2i	c9e80fb2b1b42bb29aa55cc1740be0b80853de76e7775f56de78404109404f18	500389217	FT FT24002	50	\N	Mabera - Acabamentos Têxteis S.A.	2024-08-19 00:00:00	99.39	22.86	122.25	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.878
cmnhoz2ju01nxrkt4adzzb47q	11efb9be5f0fbb66a29e2fd174eddf6125d4e5e7a433a759900fcc3dc884181b	506848558	FT 20240115601	006071	\N	Bcm Bricolage S A	2024-07-31 00:00:00	95.77	22.03	117.80	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.882
cmnhoz2k701nzrkt4f6hv75a0	685351f202c69fa7143bcd456ffdc101b04d83ec529d52327d68972fe3ed8728	502022892	FT 0	046762	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-12-26 00:00:00	95.00	21.85	116.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.895
cmnhoz2kf01o1rkt4xqhw3f2k	144a04a7c63b62e8ed711abd754b6817995e430771898d373561d429ca3e1615	502022892	FT 0	046447	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-11-28 00:00:00	95.00	21.85	116.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.903
cmnhoz2kl01o3rkt4ydkqcaqb	d54f979c4e4bc95a194c2c40811b72257f196a2c889dfe26e83e2b846fd8d354	502022892	FT 0	046125	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-10-29 00:00:00	95.00	21.85	116.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.909
cmnhoz2kt01o5rkt4iyjigyd0	957f6696952afee2113cfa47097497dd9a5ed7a3f44237bf2d854a6d43189405	502022892	FT 0	045792	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-09-30 00:00:00	95.00	21.85	116.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.917
cmnhoz2l201o7rkt4l6d2jhar	3363d95e01a970b0c2f4dfb5ce5e9c8463889247580c492ac0cd3b13566a7adc	502022892	FT 0	045681	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-09-13 00:00:00	95.00	21.85	116.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.926
cmnhoz2la01o9rkt4gq71a083	e39ddb80619d166267e1d1b2b7fa7d1a9ee178f7080368ce77fed70a713f33a9	502022892	FT 0	045151	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-07-29 00:00:00	95.00	21.85	116.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.934
cmnhoz2lh01obrkt4upci17xa	41eff9f094bb4c4886bd983412e676b847490d1a0457924e694e6330097b62c8	517514419	1 2024	178	\N	Cardoso Carvalho & Silva Lda	2024-12-27 00:00:00	92.00	21.16	113.16	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.941
cmnhoz2lo01odrkt42b5kllh2	1a6798a57d62768301326d58f7c730a5850f6a3e8abfc0ea9ed823a18504e073	517514419	1 2024	125	\N	Cardoso Carvalho & Silva Lda	2024-10-31 00:00:00	92.00	21.16	113.16	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.948
cmnhoz2ly01ofrkt48x9efv7j	6d707d76685329f881ed5d0ee799fef5c3907156250ebff379d6baaca371abf1	503630330	FT AUM012	023941	\N	Worten - Equipamentos Para o Lar S A	2024-08-27 00:00:00	91.04	20.94	111.98	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.958
cmnhoz2m701ohrkt4h236szd3	18118079356fdca0607b25a47a107109ea0f283cad8e0a3d01bba54ad7ab0ff0	516969609	FR 02P2024	17	\N	Chef & Somm Food Concepts Lda	2024-07-19 00:00:00	142.86	20.89	163.75	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.967
cmnhoz2mf01oirkt4mihecyno	d9a97e562281e43704a46d00ce1505d56026e54a41fb1d6b8cc6a09cdeecc697	508038618	FAC-N 4	3150	\N	Soma Essencial Comercio de Artigos Para o Lar Lda	2024-07-26 00:00:00	76.67	17.63	94.30	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.975
cmnhoz2mn01ojrkt4h7v3xwnl	da88421162431e607411af30f7ac628622b7323f750531412653a6630c766df5	513715738	FR 1020200	229	\N	Acropole dos Sorrisos S A	2024-08-30 00:00:00	238.38	17.62	256.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.983
cmnhoz2mu01okrkt4q730waml	038b21fcb5369d41eb979180caecbeadd8f48bf91b1f0d23925384032f234d4b	980245974	FAC 0230312024	0057388230	\N	Endesa Energia S a Sucursal Portugal	2024-07-07 00:00:00	75.56	17.18	92.74	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.99
cmnhoz2n101olrkt4uqpaothc	89008b2960e9be0cf0bd769edb5892e35c225300de11746ab5b21e8ea5142281	513325417	G 1123-23P	135890	\N	Isaura & Lopes - Supermercados Lda	2024-12-28 00:00:00	72.28	16.63	88.91	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:15.997
cmnhoz2ne01onrkt4ish4m9c5	94cc5182f7c0dd75ab8e34e206c865b55b5b18d96edc67dbfb0b8519db9f4a1c	517514419	1 2024	101	\N	Cardoso Carvalho & Silva Lda	2024-10-01 00:00:00	72.00	16.56	88.56	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.01
cmnhoz2ns01oprkt436d3m6kh	8d264e1ec778cccc683dd1b12e7a91402d1910f3e237b67380aa614abe576267	502544180	FT 101	084288091	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-12-05 00:00:00	69.39	15.96	85.35	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.024
cmnhoz2ny01oqrkt4iqzrx1a1	284cf85c896bd7076e1af3df49e3471c5c657296d50b0b8239f6a950d2fe2bb9	502544180	FT 101	082586572	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-11-05 00:00:00	69.39	15.96	85.35	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.03
cmnhoz2o701orrkt4e0jxgxss	a5b888911b6c23ec9dac2cec23dee2be4d28fb7d8dacc0785799718a20069e8f	502544180	FT 101	080948001	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-10-05 00:00:00	69.39	15.96	85.35	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.039
cmnhoz2of01osrkt4d70dnrs0	dae4d56c8e25d82b33c23261891eeec970185c80ff3dd4aa9bf7b3374ec6076d	502544180	FT 101	079295341	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-09-05 00:00:00	69.39	15.96	85.35	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.047
cmnhoz2os01otrkt4qfisljgz	4f8b3cadea4e354da5a229994e478b09a77eac86de015f810d1ec10244361427	502544180	FT 101	077662545	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-08-05 00:00:00	69.39	15.96	85.35	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.06
cmnhoz2oy01ourkt43txh1hd4	91a82100b54498f4a40531f8a186d876cabc95b84b56d788ec3b12db5da7eb9f	502075090	FT FT24102	338	\N	Arcol, S.A.	2024-11-19 00:00:00	68.94	15.86	84.80	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.066
cmnhoz2p901owrkt4llsiytax	0e5437e76a963dbc471ba6422253970f4ae5910579d5de719c9f91329d91c502	513325417	G 1123-23P	132830	\N	Isaura & Lopes - Supermercados Lda	2024-12-12 00:00:00	65.20	14.99	80.19	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.077
cmnhoz2ph01oyrkt4ke4bwr0r	0b845255150155dcc2576789cd2ab3a70fd1f1083514525a92b0e7084a2368b4	500625980	FT 1541	009067	\N	Conforama Portugal - S A	2024-08-18 00:00:00	65.02	14.95	79.97	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.086
cmnhoz2pn01ozrkt4x2z1t7ev	076bfecd215eca974278621b2c9fdb6a1d12bd6f296ec2acf5a55592f10cc7dd	514606525	FTN 2	262	\N	Magalhães & Antunes Lda	2024-07-11 00:00:00	93.77	14.43	108.20	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.091
cmnhoz2ps01p0rkt4ufklve7z	1c76e4ce77e79865ff6bdaae4017fc2aa37e9c332036245e095c683b0fbf12e3	516676180	FT FT24	119653	\N	Ibelectra Mercados Lda	2024-11-28 00:00:00	77.06	13.95	91.01	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.096
cmnhoz2pz01p1rkt46t9osogb	da63a4dd834f9e565537b80b837f89368fc2e34689e67e2c0f348f9219774131	506848558	FT 20240335701	001774	\N	Bcm Bricolage S A	2024-09-06 00:00:00	58.76	13.51	72.27	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.103
cmnhoz2q801p3rkt4kvd7f1c3	95ea64e5ad2ab2d6eb6d581242000c5e5d1e5c74752c9c4f7b222566ea0ada45	516676180	FT FT24	120033	\N	Ibelectra Mercados Lda	2024-11-28 00:00:00	75.41	13.49	88.90	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.112
cmnhoz2qu01p4rkt4yyjzovn1	982c472ce5ae94245fae925568673fc859d894227d85cda45476367f7661608a	502075090	FT FT24103	69	\N	Arcol, S.A.	2024-07-18 00:00:00	59.09	13.08	72.17	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.134
cmnhoz2r401p6rkt4rhjxien9	3ee3159bb42cea27b44231d5016914c4d267e430aa0031e98ce9802804aae621	502544180	FT 101	076350071	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-07-05 00:00:00	56.79	13.06	69.85	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.144
cmnhoz2ra01p7rkt4vno3fy1s	4a4f77bed2f9575dcca51e52389b019987ad663d87882ba69eedea2db85baf8a	980245974	FAC 0230312024	0057687667	\N	Endesa Energia S a Sucursal Portugal	2024-12-07 00:00:00	54.88	12.42	67.30	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.15
cmnhoz2rj01p8rkt439ruv9p8	85063289a96861fdf2d07d384b0575063bdebb6261ce6a0e7b723cfcfb3eb290	502569948	FACC-N 1	28990	\N	Pastelaria e Restaurante Doce Parque Lda	2024-12-16 00:00:00	92.92	12.08	105.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.159
cmnhoz2rp01p9rkt4j364w9r6	6983dfaeef31377918c4f29d4e680419618ed4008e684b9b7e973b76140632ff	516676180	FT FT24	133506	\N	Ibelectra Mercados Lda	2024-12-26 00:00:00	72.01	11.81	83.82	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.165
cmnhoz2s001parkt4lcd6lj1e	b1fa47fa66ca971544ebf00135fcb1342b02e5e533b91c0f3ab9b17f72c701ce	514798726	FT 2A2402	1695	\N	34 Restaurantes, Lda	2024-10-24 00:00:00	80.54	10.96	91.50	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.176
cmnhoz2s901pcrkt4vw7h0oez	1983104bba845ac31d7faf61e53ac0ec1b1b2904dc5813bb62947ef2976ade48	503630330	FS AUM004	118864	\N	Worten - Equipamentos Para o Lar S A	2024-07-10 00:00:00	44.71	10.28	54.99	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.186
cmnhoz2si01perkt434dnn3qs	8e0f90b9710a9dfd03f14cab968272c7f9d744a3f1550a82b007f31ea0c51a23	504394029	24FT K2401	20000074009	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-07-10 00:00:00	42.11	9.69	51.80	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.194
cmnhoz2sm01pfrkt4omh9mi2r	b270befe2756be96201d49612da0929ad2f50aedff791fd18a4149dfd731e717	503630330	FS AUM008	006966	\N	Worten - Equipamentos Para o Lar S A	2024-11-15 00:00:00	40.64	9.35	49.99	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.198
cmnhoz2te01phrkt4ute9qsqr	e268ff9b3a5d4dff33baf5d87e8e72e3b767147828cdc8b3bc7f42f3728bab37	514606525	FTS 2	7492	\N	Magalhães & Antunes Lda	2024-08-25 00:00:00	70.20	9.30	79.50	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.226
cmnhoz2u001pirkt4ddocqf56	af43327b8aa5f8e31e6153ec382706b6e1b10b30a5d4feb4b1f1b0bf20922d9d	502558881	FS A24002	41261	\N	Empreendimentos Hoteleiros Norteportugal Unipessoal, Lda	2024-08-30 00:00:00	65.27	9.23	74.50	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.248
cmnhoz2uc01pjrkt40i6esjkz	dbc6bb425a49687be253188f2168f625b318f5cea533ea00ef8b00ce89024d39	502201657	FR FRG.2024	1125	\N	Centrocor Comercio Tintas e Ferramentas Lda	2024-12-12 00:00:00	39.57	9.10	48.67	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.26
cmnhoz2uq01plrkt4q65mbwrh	ce51bc2d06122cdef619a93dcfc90871e4259e55f34518aa02fd5cf6a445fb11	506848558	FT 20240335201	001548	\N	Bcm Bricolage S A	2024-12-11 00:00:00	39.02	8.97	47.99	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.274
cmnhoz2v101pnrkt4rkuac6aa	5ac7ec8f1b0ee3b99447f1e50a904821b6b6cc0e9a6becd837344b16df9231fd	509980171	FR01 2024	681	\N	Aderito Electronica Lda	2024-08-21 00:00:00	38.37	8.83	47.20	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.285
cmnhoz2v701porkt4dw5crfym	53e676a397b18ef07a4af1584337075db8d5d6a649ee01c4e90d2010879ffb32	514606525	FTN 2	296	\N	Magalhães & Antunes Lda	2024-10-24 00:00:00	57.66	8.22	65.88	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.291
cmnhoz2vd01pprkt4abpoce3g	d820c88b98795abaced84560118c3a0ac7029bf5cdc27bac8fd7135e6ad00b74	185613314	FTN 1	1483	\N	Rui Manuel Alves Madeira	2024-12-13 00:00:00	61.95	8.05	70.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.297
cmnhoz2vi01pqrkt40l1v72lb	aaf3cd4b429a9762efe2cfe2a0f62948213bed0c812a94afc0588914c89a7ee9	502604751	FT 202493	2825574	\N	Nos Comunicações S A	2024-12-24 00:00:00	34.73	7.99	42.72	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.302
cmnhoz2vp01prrkt4p93hl3kj	00fe7e69a859952ac2df4a6914fd031d3890c85736a61cb2a83d2b77c58239f2	502604751	FT 202493	2584458	\N	Nos Comunicações S A	2024-11-28 00:00:00	34.73	7.99	42.72	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.309
cmnhoz2vu01psrkt4o68p4jfr	bf150ce2541b79612333f8f2ae5b05056e634f9e55c1d36907ea6e8b3581e4d5	502604751	FT 202493	2325774	\N	Nos Comunicações S A	2024-10-24 00:00:00	34.73	7.99	42.72	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.314
cmnhoz2w001ptrkt4adupafsn	fe9d71663dec9614f812e0e0dc6975de9a7908ae1af021b39d68ab7eed076979	502604751	FT 202493	2071296	\N	Nos Comunicações S A	2024-09-24 00:00:00	34.73	7.99	42.72	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.32
cmnhoz2w601purkt4iex88ut5	73a52ce88b4e2a8731621007f9945daec5ad8e32aea637720593adc47f5a53c0	502604751	FT 202493	1819244	\N	Nos Comunicações S A	2024-08-26 00:00:00	34.73	7.99	42.72	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.326
cmnhoz2wb01pvrkt4hz8vfkeb	3ecc9e69c7130ad57691136b03dd1dc8eb527025bb8562ad713655c5d304c859	502604751	FT 202493	1567793	\N	Nos Comunicações S A	2024-07-24 00:00:00	34.73	7.99	42.72	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.331
cmnhoz2wi01pwrkt43ohx8z4m	363625b75c80eedc47e1ebb5e1da26b69b72105cf1497a8737b8490be47adb3d	516676180	FT FT24	118228	\N	Ibelectra Mercados Lda	2024-11-27 00:00:00	56.94	7.96	64.90	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.338
cmnhoz2wo01pxrkt4t5nc8tqx	c1611baf953f8f4aab00acf38169142f60ce3a96a51b16fe743b3a9dd37b55bc	516676180	FT FT24	094412	\N	Ibelectra Mercados Lda	2024-10-01 00:00:00	47.94	7.66	55.60	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.344
cmnhoz2ws01pyrkt4ttn6aogw	b148f5322cdca280572a1cb714ddb2063cb15ffb8bc98b0f544aba38836b7c52	502604751	FT 202492	3475761	\N	Nos Comunicações S A	2024-12-17 00:00:00	32.91	7.56	40.47	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.348
cmnhoz2wy01pzrkt4sdyxbzni	7ce12088c2f7c6b38853279b0ba084391044845f88ce0d2873a49fea7cef1b6e	502604751	FT 202492	3177338	\N	Nos Comunicações S A	2024-11-19 00:00:00	32.91	7.56	40.47	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.354
cmnhoz2x401q0rkt4bot39cjz	033c6440ee9eeeb770a10c3ea0f999415ff16df8f07d313c124d38dab8404130	502604751	FT 202492	2879056	\N	Nos Comunicações S A	2024-10-17 00:00:00	32.91	7.56	40.47	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.36
cmnhoz2x901q1rkt4rk1htabv	fa9d98f5723460d6d80af6ea1de3614dd892524f5b593dcd8b97051ffdd174a4	502604751	FT 202492	2523280	\N	Nos Comunicações S A	2024-09-17 00:00:00	32.91	7.56	40.47	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.365
cmnhoz2xf01q2rkt4199y5jex	4f895830f00e6815d80464687f1e8a6cfe53dc6d992c3377320997a232df6c1c	502604751	FT 202492	2291868	\N	Nos Comunicações S A	2024-08-19 00:00:00	32.91	7.56	40.47	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.372
cmnhoz2xm01q3rkt4hbyanu60	53ac1df357c6d4d67f6cd24739aedc03912ae5259866d6cad6232944436dde18	502604751	FT 202492	1997262	\N	Nos Comunicações S A	2024-07-17 00:00:00	32.91	7.56	40.47	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.378
cmnhoz2y001q4rkt4bscu4dsf	e1c4424f260e07b588f65f74049e093ec055106351acacf981d99b48623847d2	231578504	FACC-N 1	9437	\N	Monica Linda Ribeiro	2024-10-22 00:00:00	32.52	7.48	40.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.392
cmnhoz2y801q5rkt4hubluiww	c4d7ef481d48180fdc664bb5b89e05146096e0ac40f4354fa2936a856d6285d3	516676180	FT FT24	119652	\N	Ibelectra Mercados Lda	2024-11-28 00:00:00	43.07	7.30	50.37	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.4
cmnhoz2yk01q6rkt4a641oirp	15977fdb48c71054ce9b1d362995eae5ead5288d2dd725a055fdeb96e4948807	516676180	FT FT24	045071	\N	Ibelectra Mercados Lda	2024-07-02 00:00:00	44.32	7.20	51.52	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.412
cmnhoz2yz01q7rkt4ezqrucy0	0344608a57bd352c7588d5d393d08334e039e6cb0fa396d6a6c5401dcd6fbffe	513026002	FR ANTASFR	6552	\N	Brasão Acf, Lda	2024-12-21 00:00:00	47.04	6.86	53.90	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.427
cmnhoz2z801q8rkt4dlrxf12d	8e0c2940d1b5e24985ec80eea70d8ea9078e6219f27c23608dde0b348d260bad	515837652	F FR01	13529	\N	Muralha do Castelo Lda	2024-09-13 00:00:00	113.21	6.79	120.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.437
cmnhoz2zi01q9rkt4wz2fj95p	b04c6690b4ff1ff5541f9290b73e5c07b2065dfc27d26bbfd07ea449d4af5217	501241191	FS FS.2024	17856	\N	Drogaria da Ponte Lda	2024-12-18 00:00:00	29.48	6.78	36.26	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.446
cmnhoz30q01qarkt486jhfnja	b62b3ea217e6b0881aec3439c3fc2b4556811d27bcf355a2ac838346f93663f6	980245974	FAC 0230312024	0057568487	\N	Endesa Energia S a Sucursal Portugal	2024-10-08 00:00:00	29.73	6.64	36.37	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.49
cmnhoz30v01qbrkt4d53rqs75	50f363d54be66b848b4112c84517896393b0c4f2224de8571f3534fed3131140	980245974	FAC 0230312024	0057628198	\N	Endesa Energia S a Sucursal Portugal	2024-11-07 00:00:00	29.54	6.60	36.14	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.495
cmnhoz30z01qcrkt4xiawm7ap	b8cedb332b4d15068948915d3e9f0c3022fa9f628759799652f3198b2966eb96	980245974	FAC 0230312024	0057449364	\N	Endesa Energia S a Sucursal Portugal	2024-08-07 00:00:00	28.73	6.42	35.15	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.499
cmnhoz31401qdrkt4006g78tw	0fae2e96703f65b8540f6d5aac389fc16e83e14c82ffdd321917b2bf4d67ae57	506310221	FS 1020004	42338	\N	Terras de Pena Investimentos Hoteleiros S A	2024-09-14 00:00:00	47.40	6.40	53.80	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.504
cmnhoz31a01qerkt4ouz7bf80	2a94bcf00c7b29c5d9a7fa4b49d1a6b6703cc6042342ea7914bb8cff0a15ed42	515439240	FS DBF1	6729	\N	Requinte Prodigioso Lda	2024-12-09 00:00:00	43.22	6.03	49.25	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.51
cmnhoz31e01qfrkt4w5l6t2zb	23a81096ccb874036efd05a251f160fe137512a77fea4b8c195e26fdfb991627	515045519	FS 005	134639	\N	Trunfos D Outono Lda	2024-07-02 00:00:00	53.98	5.97	59.95	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.514
cmnhoz31i01qgrkt4spzc7epn	ad1b98cf78c5c8fbd4151aa2d837a43767e6451e3d4776a5f6f161790657c33b	500625980	FT 1541	009018	\N	Conforama Portugal - S A	2024-08-12 00:00:00	24.38	5.61	29.99	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.518
cmnhoz31m01qhrkt4ss4oa5en	cb871a2da2d6303232417a51c29b054ef155ab3e91220c2b91c5c8cddf3d4d51	501241191	FS FS.2024	17816	\N	Drogaria da Ponte Lda	2024-12-17 00:00:00	24.32	5.59	29.91	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.522
cmnhoz31r01qirkt4dze56zsk	bc30bc51a874031b00d7700c457c3fd1c062f120511390c910b86522160b1bf5	516676180	FT FT24	102432	\N	Ibelectra Mercados Lda	2024-10-21 00:00:00	41.33	5.53	46.86	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.527
cmnhoz31x01qjrkt4qh5hrr38	42a2e318afd8cf863d97581515bb67013b810e02a82d00aedfadcfea167a5e9d	516676180	FT FT24	106415	\N	Ibelectra Mercados Lda	2024-10-31 00:00:00	35.66	5.26	40.92	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.534
cmnhoz32101qkrkt4nvxq49xv	da73aecbded0a6eadbd6b88c1525e4089808ff5db935ad1b2901ada80d53190b	500506272	FS FS24	33374	\N	Irmaos Almeida Lda	2024-07-30 00:00:00	35.37	5.13	40.50	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.537
cmnhoz32701qlrkt4f46jg2ww	ea939763692e7c4fff8a78272997459c37c2856e667074c4c4342691fc237351	515837652	F FR01	14898	\N	Muralha do Castelo Lda	2024-12-13 00:00:00	84.91	5.09	90.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.543
cmnhoz32f01qmrkt4icb5701c	ab80c2198b5f03700f0995eefad742ac551669181323539e9d77a28f58f3e69f	505197200	FR BOL	9048	\N	Tempo Livre Fisical - Centro Comunitario de Desporto e Tempos Livres Ciprl	2024-10-16 00:00:00	84.91	5.09	90.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.551
cmnhoz32n01qnrkt414si9biq	049ca36cb40895c6ada6cc1b2dcf2a9cedd75fde6d1f15755e0eb26f3234e32f	980245974	FAC 0240312024	0061623069	\N	Endesa Energia S a Sucursal Portugal	2024-11-19 00:00:00	26.54	4.81	31.35	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.559
cmnhoz32t01qorkt4qviiijsh	ec2a27d1b5a86f702edea5f838b0c3faa8c2c1b8f733c2959b9aef41ed35a169	505353385	FS 002	15018	\N	Restaurante Linha Sul Lda	2024-08-03 00:00:00	32.71	4.69	37.40	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.565
cmnhoz33201qprkt477dxoipw	90c5839758d0e0695e27be55942a1a204ebab6c981fe1f080f6a95fe73158272	980245974	FAC 0240312024	0061569289	\N	Endesa Energia S a Sucursal Portugal	2024-10-21 00:00:00	25.51	4.64	30.15	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.574
cmnhoz33901qqrkt4k7ewpjg5	00f1fb535316a362cada898d1c21df908e2f15ff0d08ac4e7d7113a132e011fe	980245974	FAC 0240312024	0061680573	\N	Endesa Energia S a Sucursal Portugal	2024-12-19 00:00:00	25.02	4.61	29.63	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.581
cmnhoz33i01qrrkt4zyuv7mlw	77adca59612b8795bdb42aebdfdf24f1ca1386e20cef12b32f35a4f25b63f75d	510450024	FR 003	2292521	\N	Ifthenpay Lda	2024-09-30 00:00:00	19.58	4.50	24.08	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.591
cmnhoz33s01qtrkt4mz2zum3o	5007ebf138fc8a6779507aca8dae4c531deef37b4e8ac94b11cfd7661aaee7ba	980245974	FAC 0260312024	0069583681	\N	Endesa Energia S a Sucursal Portugal	2024-11-08 00:00:00	26.58	4.49	31.07	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.6
cmnhoz34201qurkt4yd91k1re	db8b853ff7dbc96a39633db302a715a3709ee22e518c8264749dba3c11571785	516676180	FT FT24	061019	\N	Ibelectra Mercados Lda	2024-07-31 00:00:00	33.29	4.45	37.74	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.61
cmnhoz34d01qvrkt4n5n6cabs	70d1d7f8add1a4d25f47a3c3ec60c2dc1a4e0928f9b0c60c4e92b9310a09ccc6	516676180	FT FT24	044804	\N	Ibelectra Mercados Lda	2024-07-02 00:00:00	31.99	4.37	36.36	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.621
cmnhoz34k01qwrkt4hsm9xtcf	d3466dba7a3c18a2b96ba4ecb10b2e6b143aad526158a54ba26f8b6cf1ebad99	980245974	FAC 0260312024	0069640168	\N	Endesa Energia S a Sucursal Portugal	2024-12-08 00:00:00	25.62	4.35	29.97	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.628
cmnhoz34r01qxrkt4yzf205hg	e863c016cf41f3e2c4dbb3b0c9677faa3cc001f3a70752cbd774e0e54a932469	980245974	FAC 0260312024	0069526974	\N	Endesa Energia S a Sucursal Portugal	2024-10-08 00:00:00	23.08	4.19	27.27	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.635
cmnhoz34z01qyrkt4q5oo3vgm	cc1fffc9612f3fe8f55e7bd99878f76ce37a13407a2df130479be1b4afa2abdb	980245974	FAC 0270312024	0073447307	\N	Endesa Energia S a Sucursal Portugal	2024-09-08 00:00:00	21.32	4.17	25.49	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.643
cmnhoz35901qzrkt4ulscgi2x	b527286970e72aa98716395683223a0c15151587e8b35cb7f7136a30889f9de4	516676180	FT FT24	076908	\N	Ibelectra Mercados Lda	2024-09-02 00:00:00	33.68	4.09	37.77	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.653
cmnhoz35f01r0rkt4vbtt5gsx	fe5730bd9f951470e98374f8a36fa16d4d8c8dfd57b78d04e4cc4c9400e8065e	980245974	FAC 0270312024	0073392368	\N	Endesa Energia S a Sucursal Portugal	2024-08-08 00:00:00	20.05	4.09	24.14	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.659
cmnhoz35j01r1rkt49dqfmfid	69052bb2ba292c6042181d212938663f848f80e7e3da269890cfb94cfe8ca301	502075090	FT FT24105	10	\N	Arcol, S.A.	2024-11-04 00:00:00	17.75	4.08	21.83	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.663
cmnhoz35t01r3rkt44c6fjg16	29ea29c47e2b0c0472b31245997ed2357be55160c234853d9c8b58aa3b51a673	980245974	FAC 0260312024	0069361420	\N	Endesa Energia S a Sucursal Portugal	2024-07-08 00:00:00	19.26	3.96	23.22	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.674
cmnhoz36001r4rkt4dp0gtkjp	85af811601f20e10143f656d1958ec27904fd81114858c8ef9f2cd0b69be374b	980245974	FAC 0250312024	0065501903	\N	Endesa Energia S a Sucursal Portugal	2024-09-18 00:00:00	19.27	3.85	23.12	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.68
cmnhoz36601r5rkt4pubemyz3	99efed6dd95dc85c9bd0aae3efadcc2af1e7f5e068e30596913e7d308a33f656	980245974	FAC 0250312024	0065443805	\N	Endesa Energia S a Sucursal Portugal	2024-08-18 00:00:00	19.10	3.84	22.94	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.686
cmnhoz36f01r6rkt48c7a37yb	52ec442d73039d9fec8a9218541f153cd0fe06b80141bf4f1fddf669cbaf29aa	507718666	FAC 009	94681432	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-11-27 00:00:00	63.40	3.80	67.20	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.695
cmnhoz36v01r8rkt4x6wxboef	656df0845d8394943fcfa894b58ab712c7c85918680b4fd2cb069fecd2b26417	503340855	FS 042800324	077158	\N	Lidl & Companhia	2024-09-16 00:00:00	16.24	3.73	19.97	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.711
cmnhoz37201r9rkt446c1je83	fe662cf0078a3072e7adc854a7ff78ac0800229dbe653ab5feb3398fd2468a30	516676180	FT FT24	094201	\N	Ibelectra Mercados Lda	2024-10-01 00:00:00	29.08	3.72	32.80	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.718
cmnhoz37701rarkt4acsz58do	c877ccf069e2f64ba04f38fbc907e0d19a89e9bde91d031479a49fef1b0e3ecd	980245974	FAC 0250312024	0065388242	\N	Endesa Energia S a Sucursal Portugal	2024-07-18 00:00:00	18.08	3.68	21.76	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.723
cmnhoz37i01rbrkt42zap80wc	1b9f70551da5e850ce559b48dd1ade31453bf9a4b79afd34ca9dec356451a267	513725407	FT 6A2401	7909	\N	Leves Instantes - Lda	2024-07-31 00:00:00	25.83	3.67	29.50	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.734
cmnhoz37n01rcrkt4avox2bia	28c30b5b3555ef104b8e92c619793faa2b34604a05f2b410743759891f09472b	507718666	FAC 009	94429474	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-08-19 00:00:00	59.85	3.59	63.44	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.739
cmnhoz37y01rerkt47t455tu6	85d49767c9db757e38b54c14b05ee20e6f2132738c24395376851ab4e337fc55	505993082	FAC 006	60932793	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-08-02 00:00:00	80.39	3.50	83.89	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.75
cmnhoz38501rfrkt44xrq9f3m	62bc03f8b8c6e4ad3e68833837acf06015a5a085f38e0f2fd3398582d28350ce	516676180	FT FT24	076553	\N	Ibelectra Mercados Lda	2024-09-02 00:00:00	25.47	3.49	28.96	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.757
cmnhoz38a01rgrkt475pqkij6	e0d32e98efc2f9599888d5789e07056764fcdccddfe0209abeeb89b9af6dfdad	516676180	FT FT24	088101	\N	Ibelectra Mercados Lda	2024-09-25 00:00:00	34.22	3.44	37.66	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.762
cmnhoz38p01rhrkt4echmkyhv	43fa22db47e9064f129119cbd0c159d278c1c46b19c89f6327e24eee89d91033	516676180	FT FT24	060757	\N	Ibelectra Mercados Lda	2024-07-31 00:00:00	25.24	3.42	28.66	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.777
cmnhoz38u01rirkt44zjw129h	dc1a9dd6b8ffc8e01456a939cd605412ef37ccf3118c457da4d077f119b330b7	510450024	FR 003	2322455	\N	Ifthenpay Lda	2024-11-30 00:00:00	14.68	3.38	18.06	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.783
cmnhoz39601rkrkt4rji8lmw1	14ab7cc4fcb43ed9befa1a0d0cfd11083205f7d8f66a7d61432b47b9bee04d77	510450024	FR 003	2307366	\N	Ifthenpay Lda	2024-10-31 00:00:00	14.68	3.38	18.06	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.794
cmnhoz39j01rmrkt4csscy60w	accff2a4760d4af0c4136de1346577ac6a1b2f70b60e9cbccd0f93b789dd3084	513146091	FS 35717112/495	JJKKC36G  -495	\N	Daufood Portugal Unipessoal Lda	2024-08-19 00:00:00	23.08	3.37	26.45	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.807
cmnhoz39r01rnrkt458y3j2dv	d8c4d70b61cd3603ffbcc41f1782881b04d7467de66bc5e6039ff6f84e48604a	505993082	FAC 006	60949812	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-09-02 00:00:00	74.24	3.25	77.49	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.815
cmnhoz39y01rorkt4qqhalqzo	2908812aa0b2d95476f1647ad61b89159a6eaceaa29541675e1230a276a17243	502201657	FR FRG.2024	1118	\N	Centrocor Comercio Tintas e Ferramentas Lda	2024-12-11 00:00:00	14.04	3.23	17.27	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.822
cmnhoz3a701rqrkt4cy0scsbf	67627a1b2589b72a62cf46d0e0ceca5c9c444a085e0c3ebbca7e651ec68fe578	505993082	FAC 006	60967364	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-09-30 00:00:00	73.58	3.23	76.81	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.831
cmnhoz3af01rrrkt43rvyt44r	fa8d6e25a2e405a4e88f57cc930eacc1d384e8bdc06f73cf47f4ebc788a9f6b7	510450024	FR 003	2337838	\N	Ifthenpay Lda	2024-12-31 00:00:00	13.98	3.22	17.20	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.839
cmnhoz3an01rtrkt4zaboteda	5e919a02b04ac5660f91f251d4441d48c6dc503f2fba85d8bd26ccba6eb8e2ae	507718666	FAC 009	94576679	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-10-18 00:00:00	51.78	3.11	54.89	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.847
cmnhoz3aw01rvrkt4lqmngoe5	d80252fa9dc85d8ff4e4e4680a3b24020abf58f26b7dff77429567311ba30439	507718666	FAC 009	94531555	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-09-27 00:00:00	51.78	3.11	54.89	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.856
cmnhoz3b401rxrkt4k62ynxp6	625b328fdd48a8e89fed5ec934333740a9fd8b1c876d22c6cbf00397c8bca6ab	507718666	FAC 009	94738525	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-12-19 00:00:00	51.59	3.09	54.68	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.864
cmnhoz3bf01rzrkt4vrbxohhg	e85669db9e89972c1430813ac262380ea2661e90bd9f61594882b68421d6624d	513146091	FS 35717112/99	JJKKC36G  -99	\N	Daufood Portugal Unipessoal Lda	2024-08-16 00:00:00	20.11	3.04	23.15	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.875
cmnhoz3bk01s0rkt49tficl1b	42834393b56327360bc7f2f4af3402a90276296e634960bfc110b1fe96c889b9	506848558	FT 20240335601	001859	\N	Bcm Bricolage S A	2024-07-08 00:00:00	13.24	3.04	16.28	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.88
cmnhoz3bv01s2rkt4m9ou5tbb	5d3dde7450cab32332f104618290e38701b7f9a2e4a11baad47d7fd11637632a	516676180	FT FT24	054235	\N	Ibelectra Mercados Lda	2024-07-22 00:00:00	29.67	2.93	32.60	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.891
cmnhoz3c001s3rkt4xj910x11	c6482d43e4c8d8e9b2f8d456f855f310d3a76b0d5f638d122f5c3ed58dcab97b	505993082	NCR 006	60985486	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-10-30 00:00:00	-50.14	-2.81	-52.95	Nota de crédito	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.896
cmnhoz3c801s4rkt41uxmasql	7a5fff7233e16396ab4f709c5cdc804195022a45ce777ca5bb84e4ffa80542c0	500829993	FS 08740602309071515	029093	\N	Pingo Doce Distribuicao Alimentar Sa	2024-08-17 00:00:00	19.24	2.70	21.94	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.904
cmnhoz3cd01s5rkt4s58384rl	df817eeca9a36205824b0606d5ea926afa094a30d876071efe929b39c97dbbe9	507718666	FAC 009	94353377	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-07-16 00:00:00	43.90	2.64	46.54	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.909
cmnhoz3cj01s7rkt4594xautv	29f1451b3f430b07ca8ecd2cdfe1951924433ecfe52b92772de3a9eaac785275	505993082	FAC 006	60999939	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-11-22 00:00:00	55.73	2.46	58.19	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.915
cmnhoz3cp01s8rkt487fcmoli	be24f22653055f92a02d27e213dbc0698fcdf778de1ac047fe83539bd444379d	980245974	NCR 0230312024	0059006092	\N	Endesa Energia S a Sucursal Portugal	2024-09-06 00:00:00	-9.83	-2.46	-12.29	Nota de crédito	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.921
cmnhoz3cv01s9rkt4nb6gjjjl	df06554c1588c7705b807d9ee99a7a16c414cfe0a5855455fdb14bf7ac49d39a	506848558	FT 20240335101	001133	\N	Bcm Bricolage S A	2024-12-12 00:00:00	10.56	2.43	12.99	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.927
cmnhoz3d101sbrkt4u7db3qvz	ff05a46b6950528768c4839f2ced15a2ab4aee6c413ace899fc8891b1eded9ba	510450024	FR 003	2278116	\N	Ifthenpay Lda	2024-08-31 00:00:00	10.49	2.41	12.90	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.933
cmnhoz3d701sdrkt4xo4x47t4	30b9e644f340cf3d0c3f5ebcfc8f7a405c7c9fe388056c55e3a9b1e17088c5dc	505416654	FAC 0090722024	0030871	\N	Ikea Portugal Moveis e Decoração Lda	2024-08-18 00:00:00	15.26	2.29	17.55	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.939
cmnhoz3dd01serkt4oy3dx700	fb061a83b5931a42e383e5acdbc3dcbf7c094d87e8540ee37210b7b8714fe00c	505993082	FAC 006	60982824	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-10-24 00:00:00	52.37	2.27	54.64	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.945
cmnhoz3di01sfrkt4e65xzh0a	58866bdb1d64cb3cb31b370e4fb52fa47fac53f2dabe05a31028be726871787a	506848558	FT 20240085101	005566	\N	Bcm Bricolage S A	2024-08-14 00:00:00	8.99	2.07	11.06	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.95
cmnhoz3dp01shrkt4d5ngfbue	c184869f06dcd0788c0b4e95809861545cc4a859a9db0ba94511053c815df4fa	505993082	FAC 006	61000190	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-11-22 00:00:00	48.94	2.05	50.99	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.957
cmnhoz3du01sirkt4ezs9ungx	a5c7401893b2f4296a34fd8a36a460dd7c0a32ad3cd50abb6a5b0039afb74af8	505993082	FAC 006	60963775	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-09-23 00:00:00	46.61	2.00	48.61	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.962
cmnhoz3e201sjrkt4u2kr0ehi	90f7edd7b4aa51218ff27d3e8b28af537327187a881e3f16b5555de5f715cc77	505993082	FAC 006	60946389	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-08-26 00:00:00	46.61	2.00	48.61	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.97
cmnhoz3e901skrkt4ws7xse3y	566e08a58d86521b973e2103f9c919950a8326bae06e99f9b859a7586fc26b4d	505993082	FAC 006	61019877	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-12-23 00:00:00	45.03	1.96	46.99	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.977
cmnhoz3eh01slrkt4znqg7of5	902ee8b4513c6810efc03cf5b36c8980c8b67eb91cc314cded12ffdf3ab35871	516676180	FT FT24	069765	\N	Ibelectra Mercados Lda	2024-08-21 00:00:00	26.45	1.92	28.37	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.985
cmnhoz3ep01smrkt4nhet5v9t	d79686b47d400e7813103f82dc9c1d456de7318de7ac3ea51565adb848ff20ab	501799168	FR 2024A6	2206	\N	Franova Materiais Construcao Francisco Novais e Cia Lda	2024-12-10 00:00:00	8.13	1.87	10.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.993
cmnhoz3ev01snrkt45fqi0nu0	1c6aa5bcf18c959f11e14986713b39afc9fcc62e5bbff097a7717abf44ce399e	505993082	FAC 006	61005081	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-12-02 00:00:00	44.91	1.82	46.73	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:16.999
cmnhoz3f301sorkt4b0f57zyq	3417086cde27d743355e3957f751bea1a9afc7c6bdacec8d1a214dcc9489010c	516372521	FR VI2024	3610	\N	Vanguardmirror - Unipessoal Lda	2024-08-07 00:00:00	7.32	1.68	9.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.007
cmnhoz3f901sprkt415a14x7u	dc8bd44f50ca951504aedad400ed093586551b4490558795d16beead8b60fe06	505993082	FAC 006	61024043	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-12-30 00:00:00	40.06	1.59	41.65	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.013
cmnhoz3fg01sqrkt4t0sxufxf	1ccd30a492e289d7ba27034c3476403cd316d06cdd4f8eda515b631c894cea6e	506848558	FT 20240335201	001683	\N	Bcm Bricolage S A	2024-12-27 00:00:00	6.58	1.51	8.09	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.02
cmnhoz3fr01ssrkt4qo2y7z57	22f4413ab06f7293e83b6484a1935b9bccd669839622f20f5488f38fe1f2e3c7	503630330	FS AUM004	129398	\N	Worten - Equipamentos Para o Lar S A	2024-10-07 00:00:00	6.50	1.49	7.99	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.031
cmnhoz3g001surkt458dovtfe	734850d142cae9489e40e5610c87a4938ac97ee97693f612568903f7fdb6124e	515899003	FRDT 24DT	5187	\N	Micael e Jacinta dos Santos Lda	2024-08-30 00:00:00	23.58	1.42	25.00	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.04
cmnhoz3g401svrkt49l9yr78p	d6aa3c0b7ed537c5d1662e748ab8f45fbbe5e3dc31f87c71cc30f21efe23ab3e	505993082	FAC 006	61020589	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-12-23 00:00:00	34.87	1.35	36.22	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.044
cmnhoz3g901swrkt43tjux6gf	326e0533748b2104e43591c136c5c40fec540d2ac6743b3eb8db219a62bc08ec	501241191	FS FS.2024	17786	\N	Drogaria da Ponte Lda	2024-12-17 00:00:00	5.88	1.35	7.23	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.049
cmnhoz3gf01sxrkt48kfod17o	365f0ad8089d99f6a26bc5d3e05e53d7162ea58cace32e58751ad1299329148a	505993082	FAC 006	60928460	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-07-24 00:00:00	36.99	1.28	38.27	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.055
cmnhoz3gk01syrkt4j9ifafg5	2efe6d2eebd906a153cec5b2013f5d920ebd9da1e9771e701ac013b3eb1bc6cc	505993082	FAC 006	60983055	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-10-24 00:00:00	35.43	1.25	36.68	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.06
cmnhoz3go01szrkt4hjvecl8s	529505fda24c1cfd9ad4557f65d5eed651c83b1c7e0f2c83eb570b300b87d8de	502669730	FR BOL	3346202	\N	Etnaga - Consultores Sistemas de Informação, Unipessoal, Lda	2024-10-16 00:00:00	5.40	1.24	6.64	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.064
cmnhoz3gt01t0rkt491z9li0j	82cbb09a2372aaf66ad66fbf2276f9eb77f7ded0eeaadd21fef434656643eb3d	505993082	FAC 006	60964340	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-09-23 00:00:00	33.06	1.19	34.25	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.069
cmnhoz3h001t1rkt4vsezkjo2	1dde4ec7bd5ab2bd16db203fc926e580fbdca5bde2e96215cef0a85b35a1ccb0	505993082	FAC 006	60946988	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-08-26 00:00:00	33.06	1.19	34.25	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.076
cmnhoz3h501t2rkt4j5v4dkde	4fef5ca03a936737941260923024eca2daeb084e0dd94f119e61b77eef7783f8	501526870	01 2T05012024	5898	\N	Livraria Bertrand - Sociedade de Comercio Livreiro S A	2024-12-21 00:00:00	15.66	0.94	16.60	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.081
cmnhoz3h901t3rkt49s080wqc	4e7bb860905f3e2aeec64f66ab72cd9537dc53ee575042e8d65da75d887d7efb	506452581	VDC 2024VDC295	17559	\N	Dstore Retail, S.A.	2024-08-12 00:00:00	4.06	0.93	4.99	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.085
cmnhoz3hf01t4rkt4ucfyx0nh	9b801e97588843a178485306b9d035e6cd40399e620832968efd0786cd22d6bc	506848558	FT 20240335501	002639	\N	Bcm Bricolage S A	2024-10-18 00:00:00	3.16	0.73	3.89	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.091
cmnhoz3hp01t6rkt45tagp8td	344f1a0b603f4ed9e6a36078caa2f3a32dd701541c77a7ad090b56368ae8461e	506848558	FT 20240335201	000878	\N	Bcm Bricolage S A	2024-09-23 00:00:00	2.76	0.63	3.39	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.101
cmnhoz3hz01t8rkt4beynge7i	7d14bdb14e078b3ab1b01ad5e3a668dac5b590999a8cda8cea7760371ccffc55	505993082	FAC 006	60929040	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-07-25 00:00:00	23.44	0.48	23.92	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.111
cmnhoz3i301t9rkt47l00j3a1	5e1dc4864e0bff3b344a148e2c2485c6fdb48dbc60a76b6687c1283e16eee91a	501291652	FR CPA2	20007	\N	Oliveiras Azevedos e Sereno Lda	2024-12-21 00:00:00	0.57	0.13	0.70	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.115
cmnhoz3ia01tarkt439nr15vh	c7609c46a63f49e08183f4dde17299afc5fa00fd0cda5d0780dcb9da779d5056	514280956	FAC 109	1183841080	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-12-19 00:00:00	22.69	0.00	22.69	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.122
cmnhoz3ij01tcrkt4ou3a1m2a	7d20e16afa56731426e6c41f5e792ffdfd67593064bc0793ff9d16c4dbf37e37	980420636	FR 009	005458148	\N	Zurich Insurance Europe Ag - Sucursal Em Portugal	2024-12-12 00:00:00	256.21	0.00	278.31	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.131
cmnhoz3is01tdrkt4alv5epaj	1b21019bac1ba8eb3ee99cc5328872a3e3a7d6754d938f03661365e6d58e6f12	513204016	FF FA1B	9501668505	\N	Novo Banco S A	2024-11-28 00:00:00	2.50	0.00	2.60	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.14
cmnhoz3j101terkt42rdasy1v	ef1dafb988ca8a81fa6205e4c0ab04ad7aee6d7ba7461d2078f5faae8517cd5a	514280956	FAC 109	1183784816	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-11-27 00:00:00	27.70	0.00	27.70	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.149
cmnhoz3jj01tgrkt4bna8jtim	c4e5a17c4e4887c55b07fdffff27f4b4db812346f6593928e00354eb60a50ee6	509038123	002 1	1443053	\N	Club a F Santos Turismo Lda	2024-11-15 00:00:00	2142.90	0.00	2142.90	Fatura-recibo	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.167
cmnhoz3jz01thrkt4nm55pulh	2831bb196476d91c33926314504b3cc2a9f1e7dc3f8a9c0d0749d1edfdfb01c9	514280956	FAC 109	1183681399	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-10-18 00:00:00	23.19	0.00	23.19	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.183
cmnhoz3kc01tjrkt4eo2tuly4	458f81d4d519809dcf6dd1cb9b54e8fbd94e10fff7cc4ff288257f071b72a2ea	516988891	FT 2024	80	\N	J Araujo & M Araujo Serralharia Lda	2024-10-11 00:00:00	1890.00	0.00	1890.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.196
cmnhoz3kg01tkrkt4wp5unyg8	19ad4afd0d9f00f8cb8017f01c670d2a3651ddbbe18775c48725d390b83f64ac	516988891	FT 2024	79	\N	J Araujo & M Araujo Serralharia Lda	2024-10-11 00:00:00	1850.00	0.00	1850.00	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.2
cmnhoz3kk01tlrkt41id0gutl	ddf0b6d3c51eb71ce5ec5edc48d28f7c7f984fd8c8f50c40421a03bb8c2e7ace	514280956	FAC 109	1183637230	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-09-27 00:00:00	23.19	0.00	23.19	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.204
cmnhoz3ku01tnrkt473b35bt0	8fcc7fb4003080c16129cfb0aee134828b6f355d2be0991e340e21bcce654655	130944920	FS FS.2024G	748	\N	Antonio Jorge Rodrigues Pereira	2024-08-27 00:00:00	60.00	0.00	60.00	Fatura simplificada	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.214
cmnhoz3l101torkt4ibns8lnu	6e98ab5d461d5cf236d63f9285fbfe40cbbe22db3876d4553dc7dae77160020a	514280956	FAC 109	1183536815	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-08-19 00:00:00	27.03	0.00	27.03	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.221
cmnhoz3lf01tqrkt41pcyen46	d9b4107d82b93fbe8ce70325c6b8adf70219e3dfd7d90325a95ef62b34d6b30f	514280956	FAC 109	1183461870	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-07-16 00:00:00	19.86	0.00	19.86	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.235
cmnhoz3lm01tsrkt4wq9q5061	1b0b6d8604ba33d5399265bf5fa9afdfa7f9cbd0d39dd9bc17c45a23a32103e7	513204016	F1 F42B	4203190741	\N	Novo Banco S A	2024-07-05 00:00:00	20.00	0.00	20.80	Fatura	cmnhoz2c501msrkt4vr8bhnw4	2026-04-02 16:31:17.242
cmnhozajr01turkt41mnn71ad	ed64d0309af5fa694c8bc0de165e2fa3120570d6cec25594af13484229e311b0	500387281	FR 24A	1034	\N	Corticas N S Lda	2024-03-19 00:00:00	2390.78	549.88	2940.66	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.247
cmnhozak001tvrkt4vv4kxf60	d3fbd0aa826e613f1d5ec7a0c62bbfcca45a3593a8ca669320e6b6fa61026731	200235125	1 2024	10	\N	Jose Antonio Pereira Salgado	2024-05-14 00:00:00	1706.80	392.56	2099.36	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.256
cmnhozakc01twrkt432n49qut	7ae001ab97d294c8b9974de1ee756a6b720d82c67c36d09ad60297e489216477	502021420	1 2400	000123	\N	Manuel J S Peixoto e Cia Lda	2024-05-23 00:00:00	1646.34	378.66	2025.00	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.268
cmnhozaky01txrkt4rv64zz9j	07c95e7c0ebf506de3a9c25954927da8611d1a0a4b6b0aecfb4d51a914559879	505816105	FACT 79SEC124	19	\N	Manuel F Campos Unipessoal Lda	2024-02-27 00:00:00	1490.00	342.70	1832.70	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.29
cmnhozal801tyrkt4d5xmnqbv	8ec155eee1626d0aae077d64862705b66ce7895b686a6d3c156c5dadc43d454d	516498550	FAT 90124	43	\N	Jucami - Confeções Lda	2024-02-10 00:00:00	1234.00	283.82	1517.82	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.3
cmnhozalh01tzrkt4xi82q35s	0bfb90d6e8773a7c23de153a9055d8a1718fc10a8f94b579cd7bca0401c77e2f	514332174	1 2401	000245	\N	Snst - Assistencia Tecnica e Intalações Especializadas Unipessoal Lda	2024-04-16 00:00:00	1215.00	279.45	1494.45	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.309
cmnhozalo01u0rkt4kre2nxtd	687cf846f39c6770b0e199c697760d7794f571b5836d4c394f930951f95f4179	505416654	FAE 58.2024.FAE.ED2	74026	\N	Ikea Portugal Moveis e Decoração Lda	2024-02-26 00:00:00	1192.68	274.32	1467.00	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.316
cmnhozalv01u1rkt4shuv8oh9	73de65284c133e85c5174e00d751b48b3e5f1fc46bcc974722f460a070cfc9bd	503000000	FACTC 155124	344	\N	A M Industria de Colchões Lda	2024-06-11 00:00:00	998.00	229.54	1227.54	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.323
cmnhozam101u2rkt4627a5bd1	4e5e48e76d42f9893eaa53fecb6abc45e137f25bdd0b706edc39fdec7c6f2ff5	508546702	FT 2024A1	102	\N	Norcana - Canalizações do Norte Lda	2024-04-04 00:00:00	2590.00	155.40	2745.40	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.329
cmnhozam601u3rkt40f9qvcqf	7199896c8b60539204395c89fa51c9899182ae52a06c51ce6057af3240041957	503638471	FR 2024A28	50878	\N	Castro Electronica Lda	2024-05-03 00:00:00	673.05	154.80	827.85	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.335
cmnhozamb01u4rkt4rqpy2o1c	4848d01f3f0126194948edd0ca56d52d2a5e3727a52798aee069300f64a8d4a5	502365846	FR 4	5197	\N	Madeitrofa Comercio Derivados de Madeiras Lda	2024-01-17 00:00:00	574.71	132.18	706.89	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.339
cmnhozamf01u5rkt45hdrry7y	497a8c3327f4a6e9131348ab22affdafaaa7945e4278f910cb00975069534bec	502021420	1 2400	000076	\N	Manuel J S Peixoto e Cia Lda	2024-03-23 00:00:00	560.16	128.84	689.00	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.343
cmnhozamk01u6rkt46858uuyo	6b6f2bfdcbb5e09b9e0e9ed222d17acd27b1ac5aae278ddf90d1980fe8fcb07c	501689010	FR 13	44973	\N	J Correia e Filhos Lda	2024-02-19 00:00:00	452.61	104.10	556.71	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.348
cmnhozamr01u7rkt426qgjkz9	0d16ef5dee84cf8fdba45b05bcf35e5271724a307d15650504ad8c651c1712cb	502365846	FR 4	5193	\N	Madeitrofa Comercio Derivados de Madeiras Lda	2024-01-16 00:00:00	385.88	88.75	474.63	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.355
cmnhozamw01u8rkt4jrfh4jz8	e25dd969fa88822d5d2862e68ba1575d6b584c84080a97c231c2baddf49e9a1e	502022892	FT 0	044048	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-03-28 00:00:00	375.00	86.25	461.25	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.36
cmnhozan601uarkt4kqy1301h	6feec7c6f4a9b43c3a14974eed2646fddd7c22055502a7285f7dc8ea9d493205	506848558	NC 20240330103	005561	\N	Bcm Bricolage S A	2024-03-18 00:00:00	-277.78	-63.89	-341.67	Nota de crédito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.37
cmnhozanj01ucrkt47dr75qvs	27e281201bef9fc3974a76dbb0fc693e783a0a8fd799c6be9690620d21e5ab17	506848558	FT 20240330101	002089	\N	Bcm Bricolage S A	2024-03-18 00:00:00	277.78	63.89	341.67	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.383
cmnhozans01uerkt447zdix7j	2ed4e1e564472e5a5b321ea3b5bb0cffde6bc87589c3d8b0848cb570a1f9f347	506848558	FT 20240330601	000664	\N	Bcm Bricolage S A	2024-03-01 00:00:00	277.78	63.89	341.67	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.392
cmnhozao701ugrkt4vjr8gnyr	6014bca295ff3032f2e970883eb685ce54e39c71ab2362f58816a10759302676	504394029	24FT K2401	20000051132	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-05-14 00:00:00	248.40	57.13	305.53	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.407
cmnhozaoo01uhrkt4q8p3ng87	732cdcbce0f9d14b0e7fbc8659e5a85891941a73b63b9d930f1d2cc7ef29d334	980245974	NCR 0200312024	0047001813	\N	Endesa Energia S a Sucursal Portugal	2024-01-31 00:00:00	-349.58	-56.02	-405.60	Nota de crédito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.424
cmnhozap001uirkt4wyfwjb1y	69782adea84ab3ba023a2768598dc5792ff6a30b1042e466e74faf18d2f92339	231578504	FACC-N 1	9091	\N	Monica Linda Ribeiro	2024-06-04 00:00:00	203.25	46.75	250.00	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.436
cmnhozap901ujrkt4ura8fbez	adeda1b3abc92156f063a558e5a06671614a64c37ee4ba713204ee925b8438eb	506848558	FT 20240066201	002530	\N	Bcm Bricolage S A	2024-04-29 00:00:00	123.32	28.36	151.68	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.445
cmnhozapl01ulrkt4ar8mhzc3	00f36f08e14d4ce295a2042e1502de4f4b8f8a830ca7d839af3993bf5e30a82d	980245974	FAC 0230312024	0057074536	\N	Endesa Energia S a Sucursal Portugal	2024-02-07 00:00:00	137.32	28.15	165.47	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.457
cmnhozapt01umrkt4ntjrxrwr	0108793c778b03ae5db09e862d2040844fc6bae9af9de523c4deabdd836de1e2	980245974	FAC 0230312024	0057092304	\N	Endesa Energia S a Sucursal Portugal	2024-02-16 00:00:00	116.06	23.57	139.63	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.465
cmnhozaq001unrkt4ck6rgoyy	9757d5ba6c640c34e49e3fb5d3d966cf03e0cfdb589066130933b7a6d608efd1	980245974	FAC 0230312024	0057013564	\N	Endesa Energia S a Sucursal Portugal	2024-01-08 00:00:00	98.46	22.46	120.92	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.472
cmnhozaq401uorkt48z63bhn8	67a453c10f7a2e937e9a13b2f6567865df08250395c8e215970b87bead8e2b46	502022892	FT 0	044817	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-06-27 00:00:00	95.00	21.85	116.85	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.476
cmnhozaqm01uqrkt4wk2i6tdw	7898bcb8652aca295408a3b2e70fd13fa4c857215016c653a521cbf18f770eb4	502022892	FT 0	044488	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-05-27 00:00:00	95.00	21.85	116.85	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.494
cmnhozaqy01usrkt4cub92waz	94e92f1e57ba367167f9b3ac51f334aa6f7af65cddef5fea539ade8eb45d9cfc	502022892	FT 0	044165	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-04-29 00:00:00	95.00	21.85	116.85	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.506
cmnhozar801uurkt4u1zba4os	c775beaa58031184b52c63ea118f49ebf6612b40c95a913a50b3ea5b84dca6cd	502022892	NC 0	000799	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-03-27 00:00:00	-95.00	-21.85	-116.85	Nota de crédito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.516
cmnhozark01uwrkt4mp2yksh0	8b73ca61cb5771c151ee7347cb18dbe7bd68e822fe9deb648adcec44a67eb19a	502022892	NC 0	000800	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-03-27 00:00:00	-95.00	-21.85	-116.85	Nota de crédito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.528
cmnhozart01uyrkt4g02j0m7m	5001db8baa5247dcdec3d2f299658bf437bcdcde44cedd5def206e50c141164c	502022892	FT 0	043535	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-02-28 00:00:00	95.00	21.85	116.85	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.537
cmnhozas201v0rkt46wzdts5w	c69022b1c2024162b0efdb28c893415d65a69b3798319dec56f7f71ba43d8ab4	502022892	FT 0	043203	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-01-30 00:00:00	95.00	21.85	116.85	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.546
cmnhozasl01v2rkt4liatfvuj	10981f94fbc33497c536ee360a965ee9a46db659f26c1cbb4e9990ad50bce7c2	980245974	FAC 0230312024	0057155999	\N	Endesa Energia S a Sucursal Portugal	2024-03-16 00:00:00	107.34	21.76	129.10	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.57
cmnhozat601v3rkt4ubbs0yq3	1435443762b0a8347cbe5ed5f6cc49b30a31aed0223004aa32a70471abc97e6d	980245974	FAC 0240312024	0061194972	\N	Endesa Energia S a Sucursal Portugal	2024-04-09 00:00:00	107.68	21.52	129.20	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.586
cmnhozath01v4rkt4ybtuo5wu	3f9b15430d51c523d83c99126fa7c932c5a9d845ce93bd7cd99e1b4b5dade5c2	502022892	NC 0	000798	\N	Gonçalvesconta - Contabilidade e Gestão de Empresas Unipessoal Lda	2024-03-27 00:00:00	-90.00	-20.70	-110.70	Nota de crédito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.597
cmnhozatu01v6rkt4xsgtu16w	fd4714e64222e6b82ae293f1c23c837c1b65ac42edcb8687a7a3951a4487eab8	980245974	FAC 0250312024	0065133482	\N	Endesa Energia S a Sucursal Portugal	2024-03-09 00:00:00	102.83	20.20	123.03	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.61
cmnhozatz01v7rkt4lgvgrf73	b095e5e5e94b1162978dfa4c7a9a221931fe186bb5e33bc5a4d49b6dcba60f4e	503630330	FT AUM004	024193	\N	Worten - Equipamentos Para o Lar S A	2024-04-27 00:00:00	84.85	19.51	104.36	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.615
cmnhozau801v9rkt4tsvxfiqw	31891b3dfbf9ef8b003f9755b85b4c7ec8b545b7706bb234a1b9675d009bf80a	980245974	FAC 0230312024	0057075650	\N	Endesa Energia S a Sucursal Portugal	2024-02-07 00:00:00	83.25	18.95	102.20	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.624
cmnhozaum01varkt4hswtgz7y	bf926c1c340e288a9647330c998e056b4b1f1f63b7576e7aa263b2d9b68a1a61	980245974	FAC 0240312024	0061066840	\N	Endesa Energia S a Sucursal Portugal	2024-02-05 00:00:00	94.46	18.72	113.18	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.638
cmnhozauu01vbrkt4u1tsrp6m	8a4438ec96f6782364986ddd81718def8f4b819716c99e5e8c15637f088028fd	504394029	24FT K2401	20000055339	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-05-22 00:00:00	78.12	17.97	96.09	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.646
cmnhozav001vcrkt4w830dg1i	7a050e6bc2af41e03d4f5b2d50b87bbf59e6d19f90e4a8c358227993e10f422b	980245974	FAC 0240312024	0061188095	\N	Endesa Energia S a Sucursal Portugal	2024-04-07 00:00:00	87.01	17.12	104.13	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.652
cmnhozav701vdrkt4ux1cee7v	a43f0036a55f8ced9ca51ca0a8fdc1b77aaf86e3768bfbfde860853858817a46	500221103	VD 2405A	005063	\N	Porto Editora, S.A.	2024-05-27 00:00:00	276.37	16.58	292.95	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.659
cmnhozavf01verkt4kp1shp6p	a93024887cad442eeb492850a157f9522ec9347431e46acc5aa40514677e8d12	980245974	FAC 0230312024	0057012491	\N	Endesa Energia S a Sucursal Portugal	2024-01-08 00:00:00	81.78	16.09	97.87	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.668
cmnhozavn01vfrkt4ijvwwlt0	c1967e85425809838239bfa5d6df3b44a63f96d4f23251ef2072621f621e7e29	980245974	FAC 0240312024	0061127916	\N	Endesa Energia S a Sucursal Portugal	2024-03-07 00:00:00	83.21	16.06	99.27	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.675
cmnhozavt01vgrkt4jwzfm91j	c23c09ffd77855031721a451d7f2e13860b7265b96d8b6f50dd99d4f37640aac	980245974	FAC 0250312024	0065008257	\N	Endesa Energia S a Sucursal Portugal	2024-01-06 00:00:00	76.92	15.36	92.28	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.681
cmnhozaw101vhrkt478is284j	274b1e1fde963729f1285c09bc08350d94a4ea08f1d4884686513a3d5ed3735f	505416654	FAC 0090672024	0012884	\N	Ikea Portugal Moveis e Decoração Lda	2024-06-11 00:00:00	66.66	15.34	82.00	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.689
cmnhozawd01virkt47s4cqehl	0e2e6e69f41eb90e8f5ed33426a11d77e4ee2e4e8562d2b302435a3b9a69d724	980245974	FAC 0230312024	0057305068	\N	Endesa Energia S a Sucursal Portugal	2024-05-27 00:00:00	76.19	14.74	90.93	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.701
cmnhozawn01vjrkt4arlaoaor	b830b82c0625d916c0bbf22e1663b38ae641563ad3f9c17201fbf7b03977a5eb	980245974	FAC 0230312024	0057262442	\N	Endesa Energia S a Sucursal Portugal	2024-05-06 00:00:00	73.40	13.80	87.20	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.711
cmnhozawz01vkrkt4rcfd2jyk	409714ecb86b6fbcf33541a0ca5cc8b0f991d8c0fa2af7b995ed174a17d271d7	980245974	FAC 0230312024	0057265828	\N	Endesa Energia S a Sucursal Portugal	2024-05-08 00:00:00	59.39	13.46	72.85	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.723
cmnhozax801vlrkt4a0ki81n6	da25b0afda2ec0daf75340fe9107ca49f41da9b9e96a12f9b6b24df3cde135d5	980245974	FAC 0230312024	0057168131	\N	Endesa Energia S a Sucursal Portugal	2024-03-22 00:00:00	60.03	12.68	72.71	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.732
cmnhozaxh01vmrkt44g4j2pu3	019191f42a0b8f4abefbab18da0b2376642f00382f086ecf0a2213d14bcb9e2a	980245974	FAC 0240312024	0061196633	\N	Endesa Energia S a Sucursal Portugal	2024-04-09 00:00:00	55.62	12.61	68.23	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.741
cmnhozaxu01vnrkt4wgfttco7	240ea3ac482e9a4921b0e003ee61a1d7c1950f213f742492a4e00b055533a8b6	502365846	FR 4	5198	\N	Madeitrofa Comercio Derivados de Madeiras Lda	2024-01-17 00:00:00	53.72	12.36	66.08	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.754
cmnhozay101vorkt4z8xezjr6	eed10a7daa9327227f98f34978f76920b6914db31792bb789cfeae5dda42485f	504258877	FR A24	45	\N	Branco-Tratado - Comércio e Indústria de Madeiras Lda	2024-01-17 00:00:00	52.80	12.14	64.94	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.761
cmnhozayb01vprkt4hmc8gk0b	1329bfca759511c38fe7b5e5b9590822c66bd639c9e11c771012f506888b1319	980245974	FAC 0230312024	0057265617	\N	Endesa Energia S a Sucursal Portugal	2024-05-08 00:00:00	67.14	12.00	79.14	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.771
cmnhozayk01vqrkt4rscbmxnb	6494d0df7e6368d517d3d07484477fbe6be62db67cdc175b9ec4ac1e4c34a311	980245974	FAC 0240312024	0061293458	\N	Endesa Energia S a Sucursal Portugal	2024-05-28 00:00:00	60.63	11.26	71.89	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.78
cmnhozayw01vrrkt42l5362fs	17ac051e6264c332d9655812712b92b812a6e0fc1e4f60e2437189088b0d3e13	504394029	24FT K2401	20000052230	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-05-14 00:00:00	42.11	9.69	51.80	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.792
cmnhozaz101vsrkt43enwemki	2485fed7aaf48ec03b21c4cc1201e3902c25c9129c99b975889c8e3f19beb585	504394029	24FT K2401	20000047201	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-05-02 00:00:00	42.11	9.69	51.80	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.797
cmnhozaz601vtrkt4krrnwven	21680c807dee6a3a9e5176ef9ece48abedc612c51c8e4705e734b8627af8a60c	504394029	24NC K2403	40000002566	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-04-24 00:00:00	-42.11	-9.69	-51.80	Nota de crédito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.802
cmnhozazd01vurkt4vsidaoxb	d68f40d81c515e21b3bd18d1d51fa2cfbda5b78e34f4ebb1f3f5d5165e2b6295	504394029	24FT K2401	20000043166	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-04-19 00:00:00	42.11	9.69	51.80	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.809
cmnhozazh01vvrkt49x4ntixd	33f3c53b907b06c470d5de0824162357ed8d938f6f2b3f5be492c74b7dcaab24	504394029	24FT K2401	20000041760	\N	E-Redes - Distribuição de Eletricidade, S.A.	2024-04-16 00:00:00	42.11	9.69	51.80	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.813
cmnhozazp01vwrkt4em21l8dq	6bad9a0ef8fd4c6bcc38c3956e109cc31f4c7951334625c2301bf2422eaa6cb0	980245974	FAC 0250312024	0065134506	\N	Endesa Energia S a Sucursal Portugal	2024-03-09 00:00:00	40.99	9.23	50.22	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.821
cmnhozazv01vxrkt4tnyfm7pb	5286ab4e8f5e79ab72b7a6615d9a312692accab512c3ea5e6ce815134e4af5ae	501768580	FR 1030500	50704	\N	Soc Hoteleira Seoane S A	2024-06-24 00:00:00	154.83	9.17	164.00	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.827
cmnhozb0101vyrkt408wqg5iu	7d10af7e82f87d793a55ad875a9dd963b867b0ea239f0a55f1f7aa9a65ec3f23	513973257	FS P1150001JYSKPT	048399	\N	Jysk Unipessoal Lda	2024-04-21 00:00:00	36.59	8.41	45.00	Fatura simplificada	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.833
cmnhozb0a01vzrkt4nc0o2dq9	69d117a3d48c47e970c9ecfa72c3e9a37841c2134092404e53421ddeb6b9da9b	980245974	FAC 0230312024	0057327290	\N	Endesa Energia S a Sucursal Portugal	2024-06-08 00:00:00	37.22	8.37	45.59	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.842
cmnhozb0f01w0rkt40d4j9ung	76e9d0c9885f91f5651f853c105e157a19616971cdf0d7445fa6a26181ef2035	516676180	FT FT24	026978	\N	Ibelectra Mercados Lda	2024-05-23 00:00:00	45.95	8.11	54.06	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.847
cmnhozb0m01w1rkt4brd4b2th	e2c0beeb2142b9d3541c2a8b89c5e91aa5fa8a5b91be414451d573c5f1101820	502604751	FT 202493	1317398	\N	Nos Comunicações S A	2024-06-25 00:00:00	34.73	7.99	42.72	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.854
cmnhozb0s01w2rkt4l6xc5x3e	647eaeacd3f5e69d9c54e6ebc2ff1a39d5ddac4656d3ef07fd13c445f481d7c7	502604751	FT 202493	1069121	\N	Nos Comunicações S A	2024-05-24 00:00:00	34.73	7.99	42.72	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.86
cmnhozb0y01w3rkt4pt62u451	7534da45b08641d854aed2cf0701fa562a7aa6387b6b1ad2e8d18d8fdb7108e3	502604751	FT 202493	823083	\N	Nos Comunicações S A	2024-04-24 00:00:00	34.73	7.99	42.72	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.866
cmnhozb1j01w4rkt4ln68mtyy	f175354221c3c122ba173e5e770294308d64866bbebbe7cc598204db4a5b44a8	502604751	FT 202493	577835	\N	Nos Comunicações S A	2024-03-26 00:00:00	34.73	7.99	42.72	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.887
cmnhozb1t01w5rkt4czbp2o1u	abe11857912163e28b3dc7cc4e33bb51f108553a62ac95f63e11862a5eac3bfc	502604751	FT 202493	330718	\N	Nos Comunicações S A	2024-02-26 00:00:00	34.73	7.99	42.72	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.897
cmnhozb2l01w6rkt4t8019d65	bd18078950c5b9b403d3642e9472281433ff305cf391e7f7ef5dd4ce0c736480	502544180	FT 101	072875882	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-05-05 00:00:00	34.71	7.98	42.69	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.925
cmnhozb3701w7rkt4faiypmvm	a7b88ee14f89ddba01f5ab165ad5bf222d590629b09c5bc3764a97bd6c12f2b5	502544180	FT 101	071208663	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-04-05 00:00:00	34.71	7.98	42.69	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.947
cmnhozb3v01w8rkt4docx57bu	752ec813ab2b33a7fe402d7a2328ff13a93215ce610ea2c94b8a3cc331bc23a2	502544180	FT 101	069601485	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-03-05 00:00:00	34.71	7.98	42.69	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.971
cmnhozb4a01w9rkt492hv06oz	fd1a266c61e429e51cb6644a1aa68a269d036967619b272a221bf91803d99591	505416654	FAS 58.2024.FAS.2024S0012	4741	\N	Ikea Portugal Moveis e Decoração Lda	2024-04-24 00:00:00	34.15	7.85	42.00	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.986
cmnhozb4i01warkt4tkd0ho35	9f24d4d5e4c4f3c2bc705d0990be3ded8ca46a53af709f52d47408b573a3a670	502604751	FT 202493	85917	\N	Nos Comunicações S A	2024-01-24 00:00:00	33.30	7.66	40.96	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:26.994
cmnhozb4s01wbrkt4vnhjpdlx	7cef360278dba5f3b399235aed59437d004b215f6582368d65f2e62fc67c9f34	505993082	FAC 006	60844806	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-02-29 00:00:00	164.72	7.63	172.35	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.004
cmnhozb5801wcrkt41jx9xjpj	39fcc82bdb674a8256341dd308453b5a4e7115402a27dfb7e91f3c1f1b5adf67	502544180	FT 101	067987405	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-02-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.02
cmnhozb5k01wdrkt4ated452b	ffadd554d62c6a3adb7147def1f81461dc650eb65feb36c1f8041df0f2e77b27	502544180	FT 101	066399014	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-01-05 00:00:00	33.16	7.63	40.79	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.032
cmnhozb5w01werkt4r1qe2ssq	2ad130421e950abb5f8b3e684fd37de581716d7f412acef25341b751b627c73c	516917927	F FCTREST	1661	\N	Vi-Fe Resort Lda	2024-03-27 00:00:00	58.41	7.59	66.00	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.044
cmnhozb6301wfrkt4zak2ss4q	b6a54907ebd27a29a613bc986f7e2c5253035267e237cc0d3e615ae2701cbfb4	502604751	FT 202492	1701198	\N	Nos Comunicações S A	2024-06-18 00:00:00	32.91	7.56	40.47	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.051
cmnhozb6b01wgrkt4jtmfpxf6	c2557fa1665b5b62045ef828d9a8f8f82c4452c12cdf9b2ff0b6c16fed4f11dc	502604751	FT 202492	1412466	\N	Nos Comunicações S A	2024-05-17 00:00:00	32.91	7.56	40.47	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.059
cmnhozb6m01whrkt4thnalvqd	6a8e59467b53f11232e346e44b09fab00855408fb7771f44348e00c19ab1b037	502604751	FT 202492	1120159	\N	Nos Comunicações S A	2024-04-17 00:00:00	32.91	7.56	40.47	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.07
cmnhozb7201wirkt4j1al1vm0	43cef2b0f77732d6946de01bebcbb72d9c7ad6bb5cdc751f22f534ea6502ff48	502604751	FT 202492	832966	\N	Nos Comunicações S A	2024-03-19 00:00:00	32.91	7.56	40.47	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.086
cmnhozb7801wjrkt48lxue2g2	9b65e1997b6e9ec23ffbfb073cf636b9895b3557cc3df6a21751e0ed23205ccf	502604751	FT 202492	545708	\N	Nos Comunicações S A	2024-02-19 00:00:00	32.91	7.56	40.47	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.092
cmnhozb7e01wkrkt4xo5avwrt	41f8131b0d95e04fa74377229ac2851f3ca04386ae0822bee95a9b9dba5704c6	516676180	FT FT24	038634	\N	Ibelectra Mercados Lda	2024-06-25 00:00:00	46.69	7.43	54.12	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.098
cmnhozb7t01wlrkt4ubbkcz3v	357e403df058a3fb339d6b0a1229acb9992049aa6c367949ba4f5f24a4415605	501689010	FR 13	45218	\N	J Correia e Filhos Lda	2024-03-13 00:00:00	32.15	7.39	39.54	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.113
cmnhozb7y01wmrkt45zzf77xf	dd50f41de405fd9c7b97d969968cb177cb301fc5a80878f251aca9da18a6f476	980245974	FAC 0240312024	0061029111	\N	Endesa Energia S a Sucursal Portugal	2024-01-16 00:00:00	43.54	7.37	50.91	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.118
cmnhozb8201wnrkt4r6ha184j	a1aefd3ddf857259c14b97f57d76389eda6b5da77096a655ca63f70e5bfa76f0	502544180	FT 101	074405521	\N	Vodafone Portugal - Comunicações Pessoais S A	2024-06-05 00:00:00	31.59	7.27	38.86	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.122
cmnhozb8601workt4hn2kyfpu	298f321d366127613098d32892e8906dcded1f8ebd6ec6727dee40cbd7c10aff	502604751	FT 202492	258255	\N	Nos Comunicações S A	2024-01-17 00:00:00	31.55	7.25	38.80	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.126
cmnhozb8e01wprkt4uwte82f6	a89ecfa95bc796887a94d0d2dde62ba6d4cbde2c7e01c3008e55d5cda299f30c	516676180	FT FT24	017670	\N	Ibelectra Mercados Lda	2024-04-22 00:00:00	38.18	6.61	44.79	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.134
cmnhozb8m01wqrkt457xeow8b	db98971d97f12feb863fcd7f6c64e26c8d84df4063583be43b3e162f8e5f5f33	500389217	FT FT24002	25	\N	Mabera - Acabamentos Têxteis S.A.	2024-03-28 00:00:00	19.50	4.48	23.98	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.142
cmnhozb8s01wrrkt4pswiec7c	48f40afa72e9c9e38389e0f34cec6203eef61213170034938b7d835f9b39b805	505993082	FAC 006	60858743	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-03-23 00:00:00	88.05	4.47	92.52	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.148
cmnhozb9101wsrkt4r5b37fxe	a9db58fbe255dbe132c88c781b28a7e695d817fa7eb2a12a97466c56e811d878	505416654	NCE 58.2024.NCE.ED2	11489	\N	Ikea Portugal Moveis e Decoração Lda	2024-04-22 00:00:00	-16.26	-3.74	-20.00	Nota de crédito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.157
cmnhozb9801wtrkt4o6aya8hw	9abc5df4af82325954817c7204dbe28236b4121dbce7baa212adf2f42accbfbc	505993082	FAC 006	60893243	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-05-24 00:00:00	77.65	3.73	81.38	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.164
cmnhozb9f01wurkt481d97qfd	51f30c4fc489092547b45006138f78431defa0a4c3bf6d92dfc4012313ebbcab	980245974	FAC 0270312024	0073285162	\N	Endesa Energia S a Sucursal Portugal	2024-06-09 00:00:00	18.32	3.72	22.04	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.171
cmnhozb9k01wvrkt4vi1o73s9	80dc980b27fbe2e76a88326f759146e10bdcddda042a7770bc2230828856a66c	505993082	FAC 006	60879463	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-05-02 00:00:00	84.58	3.71	88.29	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.176
cmnhozb9o01wwrkt4ubq9hh0a	396e265efc7b85684cb58aa7db60ff8852043c7e9d35c4123c33615b5c0d8737	980245974	FAC 0270312024	0073172091	\N	Endesa Energia S a Sucursal Portugal	2024-04-09 00:00:00	18.23	3.70	21.93	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.18
cmnhozb9t01wxrkt43fkojvp9	02b96e4e430d3dc1f33809c2d6943a009a7809ea0164586213bbe2d37825180a	980245974	FAC 0270312024	0073067529	\N	Endesa Energia S a Sucursal Portugal	2024-02-09 00:00:00	18.23	3.70	21.93	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.185
cmnhozba101wyrkt4ltiumzp9	e7c6b6b4369c41c1e7976932a2dcd541c1ea67cd198d0b533075630f9aa32cb9	980245974	FAC 0270312024	0073229611	\N	Endesa Energia S a Sucursal Portugal	2024-05-09 00:00:00	18.75	3.65	22.40	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.193
cmnhozba501wzrkt4nv1ksbdx	189eab5c34b7865d947d7576831c6b1b6b7d0ad5613ef2cb8c591053b404a60b	980245974	FAC 0260312024	0069208472	\N	Endesa Energia S a Sucursal Portugal	2024-04-19 00:00:00	20.13	3.63	23.76	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.197
cmnhozba901x0rkt4kzez8w7y	2a41349e3ba7bb9380d620d65a5a0211009bc386bee7c3fb041449f91b573078	980245974	FAC 0250312024	0065329649	\N	Endesa Energia S a Sucursal Portugal	2024-06-19 00:00:00	17.72	3.58	21.30	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.201
cmnhozbad01x1rkt44ujd4mjd	f7ea1db2409bf91da4f763caee9da1966261a5623c73484a9d2e312a923bcc93	980245974	FAC 0260312024	0069266911	\N	Endesa Energia S a Sucursal Portugal	2024-05-19 00:00:00	20.05	3.54	23.59	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.205
cmnhozbak01x2rkt4b6hctsw4	b72b31fd67d55617a171e4d131a921da57cdbbae36aa51d262dc476751ca9269	980245974	FAC 0270312024	0073122217	\N	Endesa Energia S a Sucursal Portugal	2024-03-09 00:00:00	17.62	3.50	21.12	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.212
cmnhozbas01x3rkt4gn7rqi8d	bef01840b59c326ee18a5114027fb8760eea73100446f19a5858a0a756ca9b07	980245974	FAC 0250312024	0065092644	\N	Endesa Energia S a Sucursal Portugal	2024-02-19 00:00:00	17.15	3.45	20.60	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.22
cmnhozbay01x4rkt405izpl6c	d9de3e06db9232f31f940d9483f5c42580b8c0649a805c7b9c99dd705d6f83e6	507718666	FAC 009	94087888	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-03-26 00:00:00	55.72	3.34	59.06	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.226
cmnhozbb501x6rkt47zgsmjo0	8a7dbc4a0fd6ef0751390d6540ef7014861a35cbf3a6c1137aeb393eb541d1df	502075090	FT 5012024	25986	\N	Arcol, S.A.	2024-04-13 00:00:00	14.34	3.30	17.64	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.233
cmnhozbbf01x8rkt4szgeu739	977adccd5dc3e7b641cc29fd7a7c7f2951f66e1942ccdc2f994d33749329de46	507718666	FAC 009	93988851	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-02-19 00:00:00	54.40	3.27	57.67	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.243
cmnhozbbm01xarkt4bbj30dyo	b1321b84af38a2cf372882e023f9d322593d73e719901e21c66993dc27da9b9f	505993082	FAC 006	60897206	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-06-04 00:00:00	74.24	3.25	77.49	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.25
cmnhozbbu01xbrkt4br6dnb6k	035f03b24198945a7006285b7dac56d267a97640d90ba8da5e89cd08a2b6e7f1	980245974	FAC 0280312024	0077009565	\N	Endesa Energia S a Sucursal Portugal	2024-01-10 00:00:00	16.31	3.25	19.56	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.258
cmnhozbc101xcrkt4cifquh1i	e24de6fa42c3b43f01de44bad9c734d39aa564f721971f1b9b176e189a399926	505993082	FAC 006	60875127	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-04-22 00:00:00	66.95	3.23	70.18	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.265
cmnhozbca01xdrkt49xay25ye	0568107eab646f2bf41b5e578a61927c9a3eeab5c1131c865a6cbb9bce7fc67a	507718666	FAC 009	94236472	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-05-31 00:00:00	53.30	3.20	56.50	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.274
cmnhozbci01xfrkt4yugrjni5	238cd6852580ca6b2b46d5aba4569b30898c661ee5a98ecbd43e9fe1581325a0	507718666	FAC 009	94296102	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-06-21 00:00:00	51.78	3.11	54.89	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.282
cmnhozbdc01xhrkt4cogh0557	474001abb2adc6a41c3f5f4e47d7412147703298a938f6ec238199e46e6478f0	507718666	FAC 009	94131271	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-04-16 00:00:00	51.78	3.11	54.89	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.312
cmnhozbdo01xjrkt482eiyaev	2ffde6eadb0000f0df1bc20752035abfea90c9a96c0bfba1b7c78ee3aa7b5546	505993082	FAC 006	60913266	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-06-28 00:00:00	69.36	3.02	72.38	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.324
cmnhozbe101xkrkt46ohp7dmq	5281a73a9ab64ffe702e794b722b7d790d9b3f1e9d50dd01460c479dd7120e0b	505993082	FAC 006	60910795	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-06-25 00:00:00	61.98	2.99	64.97	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.337
cmnhozbed01xlrkt4pc2k6g3p	9f29c7047f807f0482e5b31c95cd1a6503c02c74c191354ba9b233333dae733f	505993082	FAC 006	60862211	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-04-01 00:00:00	68.07	2.99	71.06	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.349
cmnhozbex01xmrkt4k1spe2hf	63b10247f1e46d0f89315f43e0d6300fd70f25d565d1ffd16f557a664da0f780	507718666	FAC 009	93941064	\N	Cmpeae - Empresa de Aguas e Energia do Municipio do Porto Em	2024-01-29 00:00:00	49.49	2.97	52.46	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.369
cmnhozbf901xorkt47g333czs	1b152ef3d91c50285e148a00e14074002e5c931fd83676e0d60ba9e33e2e6818	502061898	FR P24	127	\N	J J Pinto Lda	2024-01-22 00:00:00	12.76	2.94	15.70	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.381
cmnhozbfh01xprkt4efo7huyk	bdaf595c9304ebf6ebcefca4c23053a4bdc36af8427b69599ec92647a14fce79	980245974	FAC 0200312024	0045010594	\N	Endesa Energia S a Sucursal Portugal	2024-01-31 00:00:00	13.53	2.68	16.21	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.39
cmnhozbfn01xqrkt4tbvtiyt7	7ebcc83e7ebce1246649ded088c78cb308d7414e2e72d09ce87b40e8b99d8df6	505993082	FAC 006	60892817	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-05-23 00:00:00	57.33	2.51	59.84	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.395
cmnhozbfu01xrrkt4udb4skz2	a29a24a665d3f9e70a01a2828d7e6c31e16e9e0a33de7065237975d3d8eb17df	980245974	FAC 0250312024	0065152571	\N	Endesa Energia S a Sucursal Portugal	2024-03-19 00:00:00	13.12	2.51	15.63	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.402
cmnhozbg301xsrkt4h8bn58sy	9146291e14840ae6993392b8ee16dd980afc1f5b2b30ec424b473dd2f7479dce	505993082	FAC 006	60858157	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-03-21 00:00:00	50.78	2.22	53.00	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.411
cmnhozbga01xtrkt4i2rawx8w	39758d60e16c968852d89a3bb0e18ed2f96f75912a33b4d14628279cf9ae7a6e	505993082	FAC 006	60829960	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-02-03 00:00:00	50.83	2.08	52.91	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.418
cmnhozbgh01xurkt4044qs7k0	fc9dc8f4871dc0e85b69d3a919b8a0ce8916e4511769e61394090e125d0bc245	506848558	FT 20240330401	000923	\N	Bcm Bricolage S A	2024-01-19 00:00:00	8.93	2.06	10.99	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.425
cmnhozbgx01xwrkt44za1rrna	dc5b33a997623d0509ff03f01707bed686eb79b40b8df6305f373787afa1beb2	505993082	FAC 006	60875627	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-04-22 00:00:00	46.61	2.00	48.61	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.441
cmnhozbha01xxrkt4kyqmc13w	97d5e257fecf0e4b19995694d77a90ef2e411e9778f64c14e2e43f8615902e19	505993082	FAC 006	60842072	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-02-23 00:00:00	45.82	1.98	47.80	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.454
cmnhozbhh01xyrkt49q7qht6y	d7b1e8098b28ea7cba8fd775b3f185a8bcd765cbfb3817a8b259a21c30da0dd6	505993082	FAC 006	60911544	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-06-25 00:00:00	45.03	1.96	46.99	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.461
cmnhozbhv01xzrkt4hx345ft7	cf9d094411296353100e928b344e2e4357539c1f9eb29783c52e293a74c6bca3	502021420	1 2400	000068	\N	Manuel J S Peixoto e Cia Lda	2024-03-19 00:00:00	30.00	1.80	31.80	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.475
cmnhozbi001y0rkt4uf6rlwqa	ea0de6713a7a08a1c5a1a61e8a296ab84ddd8f30616ca1f81d4deb9a2f3bb7e8	505993082	FAC 006	60842291	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-02-23 00:00:00	42.43	1.78	44.21	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.48
cmnhozbi801y1rkt4s8yykmxz	f497cebf64d6e173fe90a11c81334ee178bab0e8895a97978a7caa9a85fd1926	505993082	FAC 006	60812051	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-01-02 00:00:00	42.19	1.74	43.93	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.488
cmnhozbid01y2rkt47g3wak1n	a2cea5c2306e39e2a7e303c466b1ed3fa78b7201b511f5d2dc5da6b9d499eac7	505993082	FAC 006	60825083	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-01-23 00:00:00	39.42	1.50	40.92	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.493
cmnhozbii01y3rkt4h7fghbiu	5f3e17bf303e5dbf29d387624f5a3056895cd80a40f8150198833466e9a1a0b2	506848558	FT 20240330601	000174	\N	Bcm Bricolage S A	2024-01-17 00:00:00	6.09	1.40	7.49	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.498
cmnhozbit01y5rkt4n2tobt50	f7bdde5e1ad03076a5eea76e99344dca4bf6a09b6febe1d91e2332d1df3ebddc	505993082	FAC 006	60824996	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-01-23 00:00:00	36.25	1.29	37.54	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.509
cmnhozbj001y6rkt4c3ytrjil	1f3bad84bf941dcd2eac27b7eb99c8fa681b4c98894f4a5a314b3814e107f795	506848558	FT 20240335601	000440	\N	Bcm Bricolage S A	2024-02-19 00:00:00	1.37	0.32	1.69	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.516
cmnhozbjb01y8rkt4rzuyk3zn	75969d6afefa7118f5f64b06d3c55a5641e1c93685e8388e4d74af58978752ba	514280956	FAC 109	1183405316	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-06-21 00:00:00	23.19	0.00	23.19	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.527
cmnhozbjt01yarkt4nwbeozl1	ae2fd4c609889382211f282066437e13bf16899f413f2cc32f24adc145f2678e	514280956	FAC 109	1183346130	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-05-31 00:00:00	27.20	0.00	27.20	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.545
cmnhozbk601ycrkt4f64oaw0v	19e93ab930ed636032b6d7ff7bfd10020bca8fe10fcdfd5a471652882d22f230	505993082	NDB 000	1779718	\N	Vimagua Empresa de Agua e Saneamento de Guimarães e Vizela e I M Sa	2024-05-16 00:00:00	0.48	0.00	0.48	Nota de débito	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.558
cmnhozbke01ydrkt48mptkmvd	66f29fadc50c79748ff66b1e399207d81fc4fa116c1067edede63612c458560b	237923130	FR23/046	JF4ST6MH	\N	Nelson Davide de Oliveira Rodrigues	2024-04-30 00:00:00	520.00	0.00	520.00	Fatura-recibo	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.566
cmnhozbkn01yerkt4shc4veor	9ff5d76497e65cdccf84b6a0c20055d3ae720ca370f9c44677fc97602240bb0c	514280956	FAC 109	1183242244	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-04-16 00:00:00	23.19	0.00	23.19	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.575
cmnhozbl301ygrkt4f9i4imf5	ac454c34ca5288cb475d8fbcb187306ea04617bb3423d8a5a98760eddf71aba7	514280956	FAC 109	1183199460	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-03-26 00:00:00	24.86	0.00	24.86	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.591
cmnhozbli01yirkt4vp4fwrzb	d8ff415ee7fb79d52ebb29a9d7c9e86a23aa9a4bd7559d780b571d105f39a1f0	514280956	FAC 109	1183101103	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-02-19 00:00:00	23.54	0.00	23.54	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.606
cmnhozblu01ykrkt49ps5nukv	f89b950df9e2e71f2211ba8ee23de52f5421fc39255a87029a89d36b91655896	514280956	FAC 109	1183053601	\N	Empresa Municipal de Ambiente do Porto e M S A	2024-01-29 00:00:00	21.10	0.00	21.10	Fatura	cmnhozajl01ttrkt46ghhf8l7	2026-04-02 16:31:27.618
cmnflr31801zkhgt420bhkkur	8716b8af47360e4a175c28380230034624b3965135988f1df3cca60976f56f08	EMITIDA	FA EH_2026	70	41317182164	\N	2026-03-30 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.06
cmnflr31i01zlhgt46983xrhr	aa88066ede2804ed5da9f1fccc1b8e925f4d0e77ba846753535ae9e98fa50257	EMITIDA	FA EH_2026	55	266827560	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.07
cmnflr32401znhgt4ip535es6	07f8214a4103d61a19cef4bff8edb7684443de70dbc555bd002a3812955540a9	EMITIDA	FA EH_2026	65	260913375	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.092
cmnflr32j01zphgt42nqdc4p3	b080b2107f50d0be81520199c5fe67316904038c20847ec73bc9c4471440df9f	EMITIDA	FA EH_2026	60	254708528	\N	2026-03-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.107
cmnflr32v01zrhgt49ju2o1tz	63729c2f7dcda83242289368d86548bc5690ad2dcbd47d3cc756d9395b9488ef	EMITIDA	FA EH_2026	64	323867081	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.119
cmnflr33201zshgt4p0u0sag8	fefd3ea9fb96059b9019fb04b724f18da63c0af74d45ab217eb773fd9e053f91	EMITIDA	FA EH_2026	62	264947800	\N	2026-03-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.126
cmnflr33f01zuhgt44z2d4ait	05684aa31101278a266ff48fc638a2eb9ae854269b4dc4b65de19ae5f3d156a9	EMITIDA	FA EH_2026	56	263053725	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.139
cmnflr33p01zwhgt4j2wmor8z	1eb15cb0214cc9c02f1ed50332ef96d76bace1dc6879f75086595f04436d236a	EMITIDA	FA EH_2026	61	266475540	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.149
cmnflr33y01zyhgt47e8ry9ey	81371848b410d65ff673299df47a52460d0f7013ee016ef0ecbfde09f80bd7c6	EMITIDA	FA EH_2026	52	261803310	\N	2026-03-22 00:00:00	460.08	0.00	460.08	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.158
cmnflr3480200hgt49otg88rx	a3957156dfe465071fc8f4a0ffdd74f7ba49026ffe59ae8a00266fded0de0f3d	EMITIDA	FA EH_2026	66	262305330	\N	2026-03-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.168
cmnflr34k0202hgt4gqgq099d	5ebb1baa4ef55617368e23c6f9880b4edd29c0667976189959081a379529c6ab	EMITIDA	FA EH_2026	54	274734338	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.18
cmnflr34y0204hgt4vuzmzdet	0e6b8223f3033d02a50fc3d2f37b854659a9e3135a7da7a254f08347e8ed4be2	EMITIDA	FA EH_2026	69	260754145	\N	2026-03-22 00:00:00	550.00	0.00	550.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.194
cmnflr35a0206hgt44bho6433	bf3d3b23675c9bd7b3173572a98d6543d0ed62b7ab407875b85dd1367ebd1ea1	EMITIDA	FA EH_2026	59	261849450	\N	2026-03-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.206
cmnflr35m0208hgt4tl92dirf	cf2b2b48ff1f93cbd99a83ddf41928c7b143ac4417a82a5e0af25b2dbb31aa4b	EMITIDA	FA EH_2026	51	255364962	\N	2026-03-22 00:00:00	357.84	0.00	357.84	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.218
cmnflr35z020ahgt4jsyg9zl3	ad905057d387ee88e0fb215cbccee6ed7a5933cc1fa53624abb70f356c900a5a	EMITIDA	FA EH_2026	63	259933015	\N	2026-03-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.231
cmnflr36a020chgt4eyd630if	8beab53fd6ecd2f93ea5eb2f01bfd27fee58df03c86a9852febd34258564d3e1	EMITIDA	FA EH_2026	57	266588255	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.242
cmnflr36m020ehgt4iz5pm5kq	631a4cfb07edcdd89e9595e845e9f68043ae77399888cc1c9dcd60645f64e3c3	EMITIDA	FA EH_2026	67	261748955	\N	2026-03-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.254
cmnflr36w020ghgt4f990j9i7	3aef0be8474190a30e75939ef7b5452c0790c552955f2b5c9d1bbc9dfcc8e378	EMITIDA	FA EH_2026	49	262961512	\N	2026-03-22 00:00:00	364.55	0.00	364.55	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.264
cmnflr378020ihgt42fpejzo4	ca6fb20e1f4dda9c4786845eeec0fd72336cea808036e2da4db1f98e44e25f4f	EMITIDA	FA EH_2026	53	256125627	\N	2026-03-22 00:00:00	460.08	0.00	460.08	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.276
cmnflr37i020khgt46t3cqksv	d10a10a6c2f11f2bbc8b79af7ce43cf4b9408ad9ba5225d4c9c706caf646d2e9	EMITIDA	FA EH_2026	48	244984883	\N	2026-03-22 00:00:00	364.55	0.00	364.55	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.286
cmnflr37t020mhgt4q9b6yikf	e061a042c7ef9b704624348571e791c6fa5253c7e843f9135131ab06893e12f0	EMITIDA	FA EH_2026	58	261598619	\N	2026-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.297
cmnflr384020ohgt4fl7a7niw	a748cc6b7801c207386063e0c3b6f4ed2a313a9aec7280d0a5d8dd36ef13a6b2	EMITIDA	FA EH_2026	50	258449233	\N	2026-03-22 00:00:00	511.20	0.00	511.20	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.308
cmnflr38d020qhgt4hgvr8r1r	3f8441943768a8a19e4230ecc08ca7b655aab1a8fbd1bec6298a70e32c3ee8a8	EMITIDA	FA EH_2026	68	265435463	\N	2026-03-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.317
cmnflr38o020shgt41j926u73	79729f120ce2dcdf0da44bf215fd0a4fa24450f31b7ddd20898fd4a4d2aec537	EMITIDA	FA EH_2026	46	41317182164	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.328
cmnflr38s020thgt4yksdti1s	d52cdf4142a046171d183b20da3c6c85a8c5a65c0e40d1edf0138e327b6239f3	EMITIDA	FA EH_2026	38	264947800	\N	2026-02-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.332
cmnflr392020vhgt40kp97gct	31d3f5b2d321874d38434638560ac2411232aa57badbad0a4f66f235b3de05a2	EMITIDA	FA EH_2026	32	263053725	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.342
cmnflr39a020xhgt4b4dixvm2	73a5920c45ba13313308a632d406823b4a3b6665b2a6b289a652b75433a0b345	EMITIDA	FA EH_2026	37	266475540	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.35
cmnflr39k020zhgt4ltg4vlby	bd33694cca0d0f333572f31abf2f821098233d25f2b48f0546b1b57e9e822b65	EMITIDA	FA EH_2026	45	323867081	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.361
cmnflr39p0210hgt4ozmm888d	51a1da098e77db7dc3d73beee967454c3b4044c861b6c7dc94bdf92c9012b846	EMITIDA	FA EH_2026	24	244984883	\N	2026-02-22 00:00:00	364.55	0.00	364.55	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.365
cmnflr39y0212hgt4281edkfb	f8eb4a0f952e471c8faed78b1d47a0d3fcc73a082698daa16662134bd0d0db0d	EMITIDA	FA EH_2026	29	256125627	\N	2026-02-22 00:00:00	460.08	0.00	460.08	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.374
cmnflr3a80214hgt4nkd6d2cg	614c29e6860b06c9fa3fdff82900daec40b05cbc65205a61407ddb9a6e15a220	EMITIDA	FA EH_2026	43	262305330	\N	2026-02-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.384
cmnflr3ai0216hgt4tdatgiyn	1b4c8e2b91b8d826ce63a2256f17641ee3b080bc7c03693ad1d89e7853923bea	EMITIDA	FA EH_2026	39	259933015	\N	2026-02-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.394
cmnflr3aq0218hgt46mglt3jc	d8b8072a6a4ba30c348f224cb36bcd687d74eae2b8b94a33280cd45f127373b9	EMITIDA	FA EH_2026	26	258449233	\N	2026-02-22 00:00:00	511.20	0.00	511.20	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.402
cmnflr3b2021ahgt4uwbtgg8t	705e304552353cdcfa9df1dad94a170f1552ee7af6637e63ad2d11ef011e93d8	EMITIDA	FA EH_2026	25	262961512	\N	2026-02-22 00:00:00	364.55	0.00	364.55	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.414
cmnflr3bj021chgt4n74m3ruc	3a57cbd60be6898bbef5150f1f1c2102b0979c50b1588aae5de97d22ff767927	EMITIDA	FA EH_2026	40	260754145	\N	2026-02-22 00:00:00	550.00	0.00	550.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.431
cmnflr3bz021ehgt4jiqj3ccs	b7896817994737dc67ac557b3e2f9aae737a0d9e1f7782e3066c58e045c6d775	EMITIDA	FA EH_2026	30	274734338	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.447
cmnflr3ce021ghgt4mvzpgqnj	1e38f945dfa14d81e26094c87abbb05eddf52c7880f258b9688b24c89ed36e6c	EMITIDA	FA EH_2026	36	254708528	\N	2026-02-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.462
cmnflr3ct021ihgt4he4boc6l	100ffab4423759d28e248883760c00cece31904d330d8ee925514a9f804b54fb	EMITIDA	FA EH_2026	27	255364962	\N	2026-02-22 00:00:00	357.84	0.00	357.84	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.477
cmnflr3d7021khgt4pfohsxdx	3fdecfd56e1e8e5c1212539db3a6408c576f135c41a8acabaa9f950f26647703	EMITIDA	FA EH_2026	42	261748955	\N	2026-02-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.491
cmnflr3dh021mhgt40i789hvm	744f0e1518ecde9270391b6fe85afe5171b137313e832333a4bc4688cdc5068e	EMITIDA	FA EH_2026	41	265435463	\N	2026-02-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.501
cmnflr3du021ohgt4s51zu8ng	ae99e9779a8080f61fd393cf99cf506e4884058fe0000f560c0257bbb610158d	EMITIDA	FA EH_2026	35	261849450	\N	2026-02-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.514
cmnflr3e4021qhgt4hzb4spox	79b155cdd9cfa35b74d6f1b5e4abf5996b1dea80e7468214a5202d51b94eb8df	EMITIDA	FA EH_2026	34	261598619	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.524
cmnflr3ee021shgt4esp7u1re	4ce4b417ff4c25584a814ade5bdf3d1a40bb1c0cddf274d7005b541ef355d65c	EMITIDA	FA EH_2026	33	266588255	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.534
cmnflr3ep021uhgt4x1id084d	a7dca17aad33ff13ed9d27fb2e056e261e4c70115747fae04ad7a441a6e0889e	EMITIDA	FA EH_2026	31	266827560	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.545
cmnflr3f4021whgt4fnu6hes9	d9d73e62675c3f8f8116e19d7159e8b15523912cc89553a95a30734d503acc41	EMITIDA	FA EH_2026	44	260913375	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.561
cmnflr3fi021yhgt4wd0rkhb1	d596664b0bd2abadd7484a526961684b7ac5b316392477511ddec43234d6d985	EMITIDA	FA EH_2026	28	261803310	\N	2026-02-22 00:00:00	460.08	0.00	460.08	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.574
cmnflr3g10220hgt4ez1dw23q	e58a9af94e65a600d8fc1e65b488b5742d9b5637adc1229ba991e070e0eb1069	EMITIDA	FA EH_2026	47	41317182164	\N	2026-02-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.593
cmnflr3g80221hgt4gj8k6dzt	6681fc4d6f7b42b63a1ad63118d56ec51d21a60592c8bc13c8af16dad9ca1df1	EMITIDA	FA EH_2026	22	323867081	\N	2026-01-28 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.6
cmnflr3gh0222hgt4bobiwywf	b3a45b5542186b9138343b5f42faa7c808e43c132ed107c1f491bfb02c97c3ac	EMITIDA	FA EH_2026	23	323867081	\N	2026-01-28 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.609
cmnflr3go0223hgt40cvwlzrd	2583ad1a57ba60ba2aa13972b1d45ffa99bb3a5f87a2cdcbdaa759ca50cf9719	EMITIDA	FA EH_2026	16	259933015	\N	2026-01-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.616
cmnflr3h40225hgt4yugkml85	addd5ac81f80ad70e1897565a043e69d5fafca2cb2e1f334c8425473a040de56	EMITIDA	FA EH_2026	17	260754145	\N	2026-01-22 00:00:00	550.00	0.00	550.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.632
cmnflr3hf0227hgt49eipjgpc	808102b75109d51fc41553f3ecbd8345d7eb213186d286b3ceeaa40a31f2fc8d	EMITIDA	FA EH_2026	19	261748955	\N	2026-01-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.643
cmnflr3ho0229hgt4ghfh5q9i	275b5245eef88f8994db95dd9ef93c59d6b7fd9f34cb3b1b58fe8adc27034302	EMITIDA	FA EH_2026	9	263053725	\N	2026-01-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.652
cmnflr3hz022bhgt4v4yb7zv4	7abf08f262118c97a00177fe247211c66e56d30297f3c9fcffae9285205ee4a5	EMITIDA	FA EH_2026	10	266588255	\N	2026-01-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.663
cmnflr3ic022dhgt4k4s8s2ik	f5e37b885c672a656c7ee6c83aa50820492e848d3a4cf18e0624307bb87983db	EMITIDA	FA EH_2026	3	258449233	\N	2026-01-22 00:00:00	511.20	0.00	511.20	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.676
cmnflr3ik022fhgt4vaoki6qv	4628d5b6d6efb48e4c158e62eed554f53ff3c5a3f5d404ce9cd09c2d5102e41e	EMITIDA	FA EH_2026	11	261598619	\N	2026-01-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.684
cmnflr3iv022hhgt4bqzfgdui	4186b120655116342b2c6d9a0ea60ca22037219aa5561df1a590eb1b549d59f2	EMITIDA	FA EH_2026	8	266827560	\N	2026-01-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.695
cmnflr3j5022jhgt4xoixar6w	46ae21ffbd55bc20f3029b23ce2b52a76f1c96166ce469ef65fda69af5b80b82	EMITIDA	FA EH_2026	1	244984883	\N	2026-01-22 00:00:00	364.55	0.00	364.55	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.705
cmnflr3jg022lhgt45t9am92c	146f63e3737e9574c90d486f06d416da3ade817394aef9026f1729922e3049e2	EMITIDA	FA EH_2026	15	264947800	\N	2026-01-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.716
cmnflr3js022nhgt47crpuopb	5e9ef647aeb3f5508c23a28184d00cbb0bdb5dc435b6f6d7dcedb9edcbd467f3	EMITIDA	FA EH_2026	4	255364962	\N	2026-01-22 00:00:00	357.84	0.00	357.84	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.728
cmnflr3k0022phgt4y3svfi67	a7d44dfe7dfccf2eb558b2070f57ce10c487531104d0341cb5427020f42e1844	EMITIDA	FA EH_2026	12	261849450	\N	2026-01-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.736
cmnflr3kb022rhgt4018jgxcc	f45f65b9c77865cdd8a35fe17b29cd6cbd7f4b403a3d34a33803ba678ad8b46a	EMITIDA	FA EH_2026	7	274734338	\N	2026-01-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.747
cmnflr3kl022thgt4cs06amvh	b906d91f8d50475945a866abb47b70ccee8bbb17973188c391981d9250731f84	EMITIDA	FA EH_2026	20	262305330	\N	2026-01-22 00:00:00	425.00	0.00	425.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.757
cmnflr3ku022vhgt4g8d91n0r	8ceae95165cc068b3b42dc6427560adb8ef5759e2045e061302a798b158b58bf	EMITIDA	FA EH_2026	14	266475540	\N	2026-01-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.766
cmnflr3l8022xhgt4qz2ywk9u	6810aea1e7ddce526e180cfbb18a7992656181bcbbd9735879f46631a9baad57	EMITIDA	FA EH_2026	5	261803310	\N	2026-01-22 00:00:00	460.08	0.00	460.08	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.78
cmnflr3lh022zhgt4uqexgrn3	fcd444f914c848b8bfe3b827422eb7baaaaf19bcbc0c06d826c364e7b558b6ec	EMITIDA	FA EH_2026	6	256125627	\N	2026-01-22 00:00:00	460.08	0.00	460.08	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.789
cmnflr3lr0231hgt4rfdfetv8	f6cb40e9e0307c39c0ebff3ff41f8cc5d12f8002bddee3de48909fd30f695904	EMITIDA	FA EH_2026	18	265435463	\N	2026-01-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.799
cmnflr3m20233hgt4jt09tm1x	c4d6392cccfb774ea5d1e4d0ddb685ccc8b3b207b084f38dbea2b29468946add	EMITIDA	FA EH_2026	2	262961512	\N	2026-01-22 00:00:00	364.55	0.00	364.55	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.81
cmnflr3ma0235hgt4g8kxleqn	18ec82ed01caac3949ee8a6a6f416b511d5ca1e7687131a6accf6a437e873dea	EMITIDA	FA EH_2026	21	260913375	\N	2026-01-22 00:00:00	375.00	0.00	375.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.818
cmnflr3mk0237hgt4pvu5ackw	b93d67f16d0bd725abf6adbc221154cc8ad86a460c9947d108cda72c4f922980	EMITIDA	FA EH_2026	13	254708528	\N	2026-01-22 00:00:00	500.00	0.00	500.00	Fatura	cmnflr30z01zjhgt4ejj7ly3x	2026-04-01 05:25:32.828
cmnhp0i77029wrkt4wtzd893f	99caf1366cb1623ee005d8651d6c232121a932ac4d6bec0569d2373d7f52a7e1	EMITIDA	FA EH_2024	80	248797239	\N	2024-11-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.819
cmnhozzrv01ynrkt41owlg2od	010dfd4a5cdbb9b1161f9bbaae72bdcbe49bddf09b460e99b87a8f153dfcddf3	EMITIDA	FA A	2	999999990	\N	2020-12-07 00:00:00	300.00	0.00	300.00	Fatura	cmnhozzrl01ymrkt4414mu5i5	2026-04-02 16:31:58.939
cmnfle2g901i3hgt4iy48t3z9	e4238b6ff487c93d517155d78afd5c04c91d0fdd9eaa0fb30783098bbedc4feb	EMITIDA	FA EH_2025	251	261849450	\N	2025-12-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.777
cmnfle2go01i4hgt4pko8nw89	8d8fd2a0342a23f4678805f2d7055f416b1efba087e844ecae95ba5c1e7e1a99	EMITIDA	FA EH_2025	254	264947800	\N	2025-12-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.792
cmnfle2gx01i5hgt4t9jq8d0h	9dfbbc6b40db8ca1a69aba218672ec3818fd86eecbfea727b1e7ba14a36d82c5	EMITIDA	FA EH_2025	246	274734338	\N	2025-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.801
cmnfle2h801i6hgt40rqll630	e9b385addb4b18561494c146e866bf86026abe99d8131a8cfb0b019586c3171b	EMITIDA	FA EH_2025	244	261803310	\N	2025-12-22 00:00:00	460.08	0.00	460.08	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.813
cmnfle2hw01i7hgt4e5mp88j4	14ca1d29aab2008e54943159a958fe99303699969d56cd9d5de1c2a393e04df8	EMITIDA	FA EH_2025	243	255364962	\N	2025-12-22 00:00:00	357.84	0.00	357.84	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.836
cmnfle2ic01i8hgt4fxxj0lm8	34efe097653d957a72b1fe1dca7b192a51b1388ff429462a269f3a9d296e7c65	EMITIDA	FA EH_2025	239	244984883	\N	2025-12-22 00:00:00	364.55	0.00	364.55	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.852
cmnfle2il01i9hgt4yligve4a	c392c4008f41d27968f9814a672f41f3fbd7a76d02d4b132fed264f161061adf	EMITIDA	FA EH_2025	255	259933015	\N	2025-12-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.861
cmnfle2iz01iahgt4k2q2p03c	96fcd6eb32df3b10c717d49a36cd0817d78119a5128ab5ebfc1b3e8ad927af72	EMITIDA	FA EH_2025	241	270909028	\N	2025-12-22 00:00:00	313.35	0.00	313.35	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.875
cmnfle2ja01ibhgt4rek6g2sy	4aeeae176839dd74a5ecabce057fa04298a6a5af52896cb1c5049a72b72efef8	EMITIDA	FA EH_2025	240	262961512	\N	2025-12-22 00:00:00	364.55	0.00	364.55	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.886
cmnfle2js01ichgt4u8m3z1yv	f5a6a574043974856d2dfeeb7613a205ba8b136829eb171b79a8999422acf341	EMITIDA	FA EH_2025	248	263053725	\N	2025-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.904
cmnfle2ka01idhgt400c54s5x	29d76938e9e834a1fe13c16626e043bb9f7553d6f2acdf9cef78281456d5b2ae	EMITIDA	FA EH_2025	247	266827560	\N	2025-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.922
cmnfle2kr01iehgt4saqqa99b	bde1f5cea443b893f3847f43cee6c76dcd906e68eb77b1f1883997001749a276	EMITIDA	FA EH_2025	253	266475540	\N	2025-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:24.939
cmnfle2mk01ifhgt41ivl241m	98a48c35a84f80e8b753ab221f761d24c767013063afe4b9b9648da3004e09d6	EMITIDA	FA EH_2025	257	265435463	\N	2025-12-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.004
cmnfle2o001ighgt47s5hlmfb	daf4681cf070026a9edea12dbf55ca32ce03da0626adefb509b7ee3ffdac2ac5	EMITIDA	FA EH_2025	242	258449233	\N	2025-12-22 00:00:00	511.20	0.00	511.20	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.056
cmnfle2ou01ihhgt4rc5o8x3l	212cc9730e995cd2689ddffc1cc27a0be12e0f81b41127a647f47f9991ffd745	EMITIDA	FA EH_2025	250	261598619	\N	2025-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.086
cmnfle2pf01iihgt49wx4c2bi	f6570abca3d304c7b756b63788244c674165d42beea7b609eca588b0b7cd3cd9	EMITIDA	FA EH_2025	258	261748955	\N	2025-12-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.107
cmnfle2px01ijhgt4sod4omb0	900fbb8129856cc43fed99db2bfb79a17f46d80980b958283b5c85f99fd44968	EMITIDA	FA EH_2025	260	260913375	\N	2025-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.125
cmnfle2q901ikhgt4qq8gpio3	7bf772c5ab4629dc5a015c91c716e3cdc072659d66618ec485967817ab5e3e47	EMITIDA	FA EH_2025	259	262305330	\N	2025-12-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.137
cmnfle2qp01ilhgt42q4aw5n9	88bc1be958dbe93bb5c6e4239b46515da311e41c4ad94e3320f56d4f7d00bd7c	EMITIDA	FA EH_2025	249	266588255	\N	2025-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.153
cmnfle2qz01imhgt47ssn5lpq	60a74e645c8561150272161e9d49edcaeafe0296fd13e209c9dd42cdfe09e6be	EMITIDA	FA EH_2025	256	260754145	\N	2025-12-22 00:00:00	550.00	0.00	550.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.163
cmnfle2ra01inhgt4ee2nqmdg	2f72407e74581c0f9cf2505d2887208690f774b25c6cd4465637939827eead62	EMITIDA	FA EH_2025	245	256125627	\N	2025-12-22 00:00:00	460.08	0.00	460.08	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.174
cmnfle2rk01iohgt4frjaqozg	b0800595a70704a91921ead7de198b807bb496275a621d04728f1fc87b285feb	EMITIDA	FA EH_2025	252	254708528	\N	2025-12-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.184
cmnfle2rs01iphgt4nfqyw5rp	f390cec0220fcb7307439f4d5d2e66719c8630716145440af1631e52360454d9	EMITIDA	NC EH_2025	18	223482900	\N	2025-11-29 00:00:00	-80.00	0.00	-80.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.192
cmnfle2s101iqhgt4yal4qtp7	0df7be59378bc70bcdaf8fe670828d619796f81eb890d298939bf25f79b08b24	EMITIDA	FA EH_2025	229	261849450	\N	2025-11-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.201
cmnfle2s801irhgt4g3ebyqow	9da27d4cfc33b958ea2dc2d92138fd6636afcbd18ca9718dc9423b3a51266ab0	EMITIDA	FA EH_2025	218	270909028	\N	2025-11-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.208
cmnfle2sg01ishgt4kvy38lgr	dc9f5a75aa91fc35c35191af268e4dd983199faccd36fce691f44e9919bb1c69	EMITIDA	FA EH_2025	216	244984883	\N	2025-11-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.216
cmnfle2so01ithgt4m3oa03mw	e8e5e290faad7c400353fdadb5c48c2de7e5c942e431dd13a2dca32aea7c824b	EMITIDA	FA EH_2025	236	261748955	\N	2025-11-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.224
cmnfle2sy01iuhgt4hr14x6iz	f5d0b4e8517463f06effe218cd0e4bdf1ce4f2b67fe7de733b71b6f4fb338ced	EMITIDA	FA EH_2025	235	265435463	\N	2025-11-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.235
cmnfle2t801ivhgt430671vj1	8998cd964e387ac86edf27579d870c1a30a817cd76c85d94557723793c746e87	EMITIDA	FA EH_2025	225	266827560	\N	2025-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.244
cmnfle2ti01iwhgt48ljuiopy	28f82320a5ab03e1d77d42d786c924214ddb31508fa7298b1a9ec09f9ae68f48	EMITIDA	FA EH_2025	230	254708528	\N	2025-11-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.254
cmnfle2tp01ixhgt41e2ah3wy	0f58d2c3e7b0a16c9376f67cb51a26eee4a28cc4eca7c190cd6ca7adf6e6c77c	EMITIDA	FA EH_2025	221	261803310	\N	2025-11-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.261
cmnfle2ty01iyhgt4ahzp3tlz	cbefed4c8229cfd38c49c157d2e5dfba98cbd4347b767e1bb5ba67cd9265fa2e	EMITIDA	FA EH_2025	232	264947800	\N	2025-11-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.27
cmnfle2u501izhgt428pus36j	c4c43fe4ea150e539c8cff27714b22599111a27d21a4ea4a5f7f700700b5d73c	EMITIDA	FA EH_2025	219	258449233	\N	2025-11-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.277
cmnfle2ug01j0hgt43m99yn2j	9c3d121d774c6dbbab67bf392e902f66b7eb714ccd5a395ebaf193435638ae56	EMITIDA	FA EH_2025	238	260913375	\N	2025-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.288
cmnfle2un01j1hgt4ihpml9wl	ce51a941ecac6cdae3bef8d9a5b8cf18c675cee93828044c5b6cc9cc01f35447	EMITIDA	FA EH_2025	222	223482900	\N	2025-11-22 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.296
cmnfle2uw01j2hgt45yvzw957	6cdf79b6e0abad6abb3e90ac32cde34549dc5bd4e7e9088034e3c10ed4a83f28	EMITIDA	FA EH_2025	233	259933015	\N	2025-11-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.304
cmnfle2v201j3hgt48he6hvz6	6ec70e6f6bbe28feb3d019c5822b0318f4a6d37c138be65e71e5eff231c28ba0	EMITIDA	FA EH_2025	228	261598619	\N	2025-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.31
cmnfle2va01j4hgt4fjfm0on6	199497a6c95c114c48cea733401dd7a39b8c87a886516d9676ee4a723f963c3a	EMITIDA	FA EH_2025	226	263053725	\N	2025-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.318
cmnfle2vf01j5hgt4n9he4uag	d78664e60f2eb8ef5a01a7fdb398318d2a13b48d11fc0e87c11afcce3404a0fe	EMITIDA	FA EH_2025	220	255364962	\N	2025-11-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.323
cmnfle2vk01j6hgt4lkfmzx33	901a1022d4b60a3703dd8e3bc13adb24f2ff8d7098ca65f86e81a586c2faa715	EMITIDA	FA EH_2025	237	262305330	\N	2025-11-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.328
cmnfle2vr01j7hgt4xpdya45r	49541713b135dc520bc3ae13c985dae9bc7bfdf6ed90bbbdd660bc60cf32a2e0	EMITIDA	FA EH_2025	231	266475540	\N	2025-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.335
cmnfle2vw01j8hgt4xjwm2sc1	70a08eb002d0ab1ad0985eef6d3e06cbeb6c416824914779b6f3e23e6839b96b	EMITIDA	FA EH_2025	224	274734338	\N	2025-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.34
cmnfle2w201j9hgt4rq591t5k	67f8c97c65dbf982f84895240b5e7672cfcd38582b75529b305b68142825babc	EMITIDA	FA EH_2025	223	256125627	\N	2025-11-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.346
cmnfle2wa01jahgt4tjmgbo0z	211afed0c808d85fda88e5e2e929d202537b830fbe95ff62ae6734d5a1be4312	EMITIDA	FA EH_2025	234	260754145	\N	2025-11-22 00:00:00	550.00	0.00	550.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.354
cmnfle2wf01jbhgt427v9m2mw	ccde11814ed3c3d5f28db77980b9db1a8877d926a927f991add8edf21cf73e77	EMITIDA	FA EH_2025	227	266588255	\N	2025-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.36
cmnfle2wm01jchgt4c52oatyt	aec89183341f66a7967afb8527a0f1369a6a8b3b8e95f40cf748f63e9a73ba64	EMITIDA	FA EH_2025	217	262961512	\N	2025-11-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.366
cmnfle2wr01jdhgt4hdjdy46q	6721688bc566de938b67387a41a6284f34e50169378df7359cbef38a877c6215	EMITIDA	FA EH_2025	201	274734338	\N	2025-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.371
cmnfle2wv01jehgt4bpuuyqdx	92ef942fac47872e4c55962a19ba45206128174a01876d6e1cc1e06205d6e87b	EMITIDA	FA EH_2025	197	255364962	\N	2025-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.375
cmnfle2x101jfhgt441c931mx	13824baf4d28bfffc80b5527929061479a7c868313452b58480204a67f2e01f0	EMITIDA	FA EH_2025	196	258449233	\N	2025-10-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.381
cmnfle2x701jghgt4vg2aligz	13093371f52e752f8b6ca32da2cca0d968d41aef320dcb8a0d3bfb6945f7354d	EMITIDA	FA EH_2025	208	266475540	\N	2025-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.387
cmnfle2xd01jhhgt4unmjf3cb	f0550f1dc130f69fbcf09366316c562706ca0bf836df2d3635a31154f239115c	EMITIDA	FA EH_2025	214	262305330	\N	2025-10-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.393
cmnfle2xk01jihgt44gt3yfdw	65e6433bcb91f4542956a9225c845d05dfc11f31c9ff97311c17dfe36ceebc14	EMITIDA	FA EH_2025	213	261748955	\N	2025-10-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.4
cmnfle2xq01jjhgt43aldbtmy	ffb8e7c7c5c366f89b28cab4083ff478929a928ef3573fa3632b44557680a389	EMITIDA	FA EH_2025	205	261598619	\N	2025-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.406
cmnfle2xw01jkhgt4z9v4yp0l	f5dea428a5065d6eb509e8fc9af3bd2433a819bb1fc804cc8a04baaaf8087098	EMITIDA	FA EH_2025	211	260754145	\N	2025-10-22 00:00:00	550.00	0.00	550.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.412
cmnfle2y301jlhgt48el2saom	4db1d8bd7e34a1e1754979f940afc4c00ed763e82151f8f30c0961b12e6a1264	EMITIDA	FA EH_2025	203	263053725	\N	2025-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.419
cmnfle2y801jmhgt4j5l6waiu	c07bb27ee6bb358c67f844a8ef314ddf2286c7835132071fe1140fc6d976088a	EMITIDA	FA EH_2025	202	266827560	\N	2025-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.424
cmnfle2yd01jnhgt4ltb43578	0fc223d413f6d1b22c5bbb66d752dc8ae05cc83f4de1a7642fde5770efaae028	EMITIDA	FA EH_2025	199	223482900	\N	2025-10-22 00:00:00	112.00	0.00	112.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.43
cmnfle2yl01johgt40o8a1ap0	91052898675a1f6786f821629c407e427be586236d1f494bde9d88cb478d5c2b	EMITIDA	FA EH_2025	195	270909028	\N	2025-10-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.437
cmnfle2yr01jphgt4uxv9fbn5	e6552070156c9caf1db5aae91673034062f71c39ae0e20f8d29aafb8d7c1f247	EMITIDA	FA EH_2025	212	265435463	\N	2025-10-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.443
cmnfle2yy01jqhgt4ic97palt	7a3f8a44756bf7020dfacf4779c3a6bf22f041078bc7b8123094e71f6f1a5f75	EMITIDA	FA EH_2025	210	259933015	\N	2025-10-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.45
cmnfle2z501jrhgt4wjhqr7yc	46db0b75d88cf1d8002182dc986e30a1dd1951e01ae92da6366f270b1cea79b5	EMITIDA	FA EH_2025	206	261849450	\N	2025-10-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.457
cmnfle2zg01jshgt42ku2f558	8e6d134e8d87670fecf82e7cd3005a60d214b7b0fb9dce7f7d08ce0d19262975	EMITIDA	FA EH_2025	194	262961512	\N	2025-10-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.468
cmnfle2zq01jthgt4arlacnz6	18692c4c80961b2498d3d23f46bfdae17e9c8604103b3ed64508b43e600a83f5	EMITIDA	FA EH_2025	193	244984883	\N	2025-10-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.478
cmnfle2zz01juhgt4r3p2jr3a	c7ef2175a8f4501676b7621de5e2e60ab88084016917d715f3cfff6fd9920b79	EMITIDA	FA EH_2025	204	266588255	\N	2025-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.487
cmnfle30601jvhgt4nfet1ht4	ba92ead5f2788bd1b3b714bd12ddb0391af454ffaa2dca4996857ee22b8dba9b	EMITIDA	FA EH_2025	209	264947800	\N	2025-10-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.494
cmnfle30g01jwhgt4ep9va1wn	6e3a975fc44aa5d6955389cc64e2fdb3f67d75a90e75103cfe0d458cb988185a	EMITIDA	FA EH_2025	200	256125627	\N	2025-10-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.504
cmnfle30n01jxhgt42f1fdioe	6a21c0273d62a99248eb460fb8f34bff05e77893d4062c1245d93366614f394d	EMITIDA	FA EH_2025	198	261803310	\N	2025-10-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.511
cmnfle30w01jyhgt4zeufg5n9	66b4d44f4ca8060bb6cc92a9c66fc205d35b2b702cfca245a1f2355d5aff33cd	EMITIDA	FA EH_2025	207	254708528	\N	2025-10-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.52
cmnfle31301jzhgt44zvgrl6i	d4132d31232f7157646a93bb28e532a1f4b8c88622459b5147a01e6cd4a808c0	EMITIDA	FA EH_2025	215	260913375	\N	2025-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.527
cmnfle31e01k0hgt4jouy8qqr	34072ee7311147054bddfc900539009ae6e163cd31a0b9cf8ba065d2f1162535	EMITIDA	NC EH_2025	17	248797239	\N	2025-10-03 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.538
cmnfle31j01k1hgt4mroedhid	7088b57293a003cefffd215214e3cac8a8debc860332254949d190bd83fefca4	EMITIDA	FA EH_2025	192	261748955	\N	2025-09-25 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.543
cmnfle31q01k2hgt4curjf1af	94ca8a36cb22e929760b90589272f5c9ee644798924bfaeee886c0d537c80f29	EMITIDA	FA EH_2025	191	223482900	\N	2025-09-22 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.55
cmnfle31w01k3hgt4qwi9k50k	af8c153a9068ebdd7d668156d6b7186e2224818d7b3070aa6862fe06b9370811	EMITIDA	FA EH_2025	185	262961512	\N	2025-09-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.556
cmnfle32101k4hgt4d3c313yc	0213c0b3d500a15543a2858845dca166688227d342a79b81da5ffbe4155df847	EMITIDA	FA EH_2025	179	259933015	\N	2025-09-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.561
cmnfle32801k5hgt4e9p2o4z8	f9a1688b2951a2b0e14eb5fd52d46116ed65a47c7ce9fa3e30d8815ebfd43dfb	EMITIDA	FA EH_2025	181	255364962	\N	2025-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.568
cmnfle32d01k6hgt4pfs3bafs	e5bd4c78363967e82bf4a6f5bbfaf76d5aa4c5f2b2e78a4f8a47e2cee1152a22	EMITIDA	FA EH_2025	177	266588255	\N	2025-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.573
cmnfle32j01k7hgt4nrzx7gm7	1200641f7301f77f2721ea5f1827a456c9cd9a686ae4437a38bb9fd20abccc2f	EMITIDA	FA EH_2025	172	258449233	\N	2025-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.579
cmnfle32q01k8hgt4wuh1654v	d09b0b6b0e93bf6c64dd919a73219e7a0f010f5c435c135b2db7b66025ede384	EMITIDA	FA EH_2025	183	262305330	\N	2025-09-22 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.586
cmnfle32v01k9hgt4pt41ev3q	89856e70ebf92b2bdb477603e2477fd2a707ed118d2ef1c1a96b3d71adfdc6d7	EMITIDA	FA EH_2025	170	254708528	\N	2025-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.591
cmnfle32z01kahgt4ub3zng63	c333737e99aca6a1e7870bd173f8ff500ef460bc0fbb3c9302037d6b29044034	EMITIDA	FA EH_2025	188	263053725	\N	2025-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.595
cmnfle33501kbhgt4lb5t0jj4	b47b1694d8854f47e5126ee25d9d01e7c5199ef1ead88c4c4c99c3acea563d1b	EMITIDA	FA EH_2025	180	266827560	\N	2025-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.601
cmnfle33a01kchgt411hntm31	6e82b7bcaa5439a7b4472dfef6ff7f92a5c708bd7c24a2c70bc7d88bb62a28d2	EMITIDA	FA EH_2025	186	260913375	\N	2025-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.606
cmnfle33f01kdhgt4pk7q96vx	df2e025ca82d6b60dfcb4dbba1d7b195cf4e26d927b624d2d3aace66d07a732b	EMITIDA	FA EH_2025	176	261598619	\N	2025-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.611
cmnfle33l01kehgt4uxblbcwl	82e719eccc5c7b7e1ebef9bd481fa052b99b7c43e87ac16d68514cef438173cf	EMITIDA	FA EH_2025	168	244984883	\N	2025-09-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.617
cmnfle33p01kfhgt4bvkaarxn	fdc3ea86ce7c837a95d9c56134be19b153db2e65f2fc8b3baa7920027dc914c0	EMITIDA	FA EH_2025	190	264947800	\N	2025-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.622
cmnfle33u01kghgt4ax1knpdr	37c5aff5e5fa27dc4159547704e9feec7c4f5b43f42de048eb0bbbb2f84312b9	EMITIDA	FA EH_2025	173	265435463	\N	2025-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.626
cmnfle34101khhgt4vo7vvfn4	0a3fce8c7f8125e1dc76de2acf3f11e1e0a7b34ae70e4481a2ee61ab12bab1a7	EMITIDA	FA EH_2025	189	260754145	\N	2025-09-22 00:00:00	550.00	0.00	550.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.633
cmnfle34701kihgt4ll9b8s1z	10763c2e48f98823abffe9fd5b92511a2d19aea33066dfe53899a2537a0cca48	EMITIDA	FA EH_2025	178	266475540	\N	2025-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.639
cmnfle34c01kjhgt4gg3ig6nb	65d1b21224c94659672a12d9bc3678198cb6e6898039cb022724a4626ad0418b	EMITIDA	NC EH_2025	16	258449233	\N	2025-09-22 00:00:00	-500.00	0.00	-500.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.644
cmnfle34j01kkhgt4fhvi2b9i	71c34cf35bb4aab373906b8ef144a990787e45608202e5108b8dfd39f9c81283	EMITIDA	FA EH_2025	171	258449233	\N	2025-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.651
cmnfle34o01klhgt40t8sezmt	a6ca2191b1e6658ea095904047f7672b4fb798a83b11f358ed68187dab8bd9ef	EMITIDA	FA EH_2025	175	256125627	\N	2025-09-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.656
cmnfle34u01kmhgt4wb3venkk	0088b27f285fcc5cf5fe08950584ae482515a6079463df2f297db190c2f7e47b	EMITIDA	FA EH_2025	187	274734338	\N	2025-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.662
cmnfle35101knhgt4n6yh33q5	a9e6585567473ac19680a42a8b3dbc36b7b9fecd73673eca885aee850651b40c	EMITIDA	FA EH_2025	169	261849450	\N	2025-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.669
cmnfle35601kohgt4gytz96av	51ea91802403e0b82e12e447c86adb759cff434067fc3737894acc5cd203c890	EMITIDA	FA EH_2025	182	270909028	\N	2025-09-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.674
cmnfle35b01kphgt4kilepjuc	d926b8815341bdc77fc829ed2eee6031c033fcf0191edf6c4c7fb154213410c0	EMITIDA	FA EH_2025	174	261803310	\N	2025-09-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.679
cmnfle35i01kqhgt4xrj7wxa1	4f5dd447d77dcb2d2625d94095ed6f760c7d8054c7636fef63c2f7c233c50d3c	EMITIDA	NC EH_2025	14	252916077	\N	2025-09-08 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.686
cmnfle35o01krhgt4jakw5ac1	cf9335b8685c3632aa750853fa974ae14fbdbccb0233a7818c7b24beabaeb1b9	EMITIDA	NC EH_2025	15	266277055	\N	2025-09-08 00:00:00	-450.00	0.00	-450.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.692
cmnfle35v01kshgt4cg2r8660	3ac50bce113b87ed71a6908c4bd6905587ce835fe118e41315af2c1845c660e6	EMITIDA	FA EH_2025	167	260913375	\N	2025-09-04 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.699
cmnfle36101kthgt4imet3u1x	b1a9ba97a9cbd03364fa3cc43495402c291f48fa7ad963a11662fc3610eef9c7	EMITIDA	FA EH_2025	166	260913375	\N	2025-09-04 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.705
cmnfle36601kuhgt4u7ssg3m0	3c28c6bac7dc20b063229635d6151590fa717ef75212e4479f9036a5d0f48222	EMITIDA	FA EH_2025	164	264947800	\N	2025-09-03 00:00:00	1000.00	0.00	1000.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.71
cmnfle36d01kvhgt43q7pos33	ea4a370f2fe8812d1515e4edf08c64c0369efe9153666925477f393496b7d8b0	EMITIDA	FA EH_2025	165	264947800	\N	2025-09-03 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.717
cmnfle36m01kwhgt43nive3ld	4161999be034fc328dbcca85e14b773308a46ab508a4cfd8be46f40355a046c7	EMITIDA	NC EH_2025	13	167775014	\N	2025-08-29 00:00:00	-0.50	0.00	-0.50	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.726
cmnfle36u01kxhgt4mmiv0gc4	57f5ff2b4d33e30c9b6f3d490ed1dc975e7af8d86cb5a428d745d1f89d48a880	EMITIDA	FA EH_2025	163	167775014	\N	2025-08-28 00:00:00	0.50	0.00	0.50	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.734
cmnfle36z01kyhgt4qgsm8mbz	a4b8628f405d8507154fe32b1336fa23f93b68de176ae2d34ae605d9622fc8f9	EMITIDA	FA EH_2025	162	167775014	\N	2025-08-28 00:00:00	0.50	0.00	0.50	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.739
cmnfle37601kzhgt4sxn3am7n	a127bca24a983813f59cb8e6557da75ab3b3f436766b3cef6f91a8caf7395953	EMITIDA	FA EH_2025	160	262305330	\N	2025-08-27 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.746
cmnfle37d01l0hgt4jhczbzzm	a213aadc43c84cbad409206ae99beb6dae95d4af269b1491bf2f3a060a9ad03c	EMITIDA	FA EH_2025	161	262305330	\N	2025-08-27 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.753
cmnfle37i01l1hgt43pkcczbs	c4a454ed5e5fdf6bff5b3cae42ab14f08e579e060815b1fe89d6b9de2b91ba52	EMITIDA	FA EH_2025	156	265435463	\N	2025-08-26 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.758
cmnfle37m01l2hgt49njywe7j	07dbf91c383fdf120607d36f179cb0580cc5f661c1d0bcfad38e0825d9d10fed	EMITIDA	FA EH_2025	153	260754145	\N	2025-08-26 00:00:00	1000.00	0.00	1000.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.762
cmnfle37s01l3hgt49evli4vq	71357a4365386b9e024dd7de000771a317a3492f92b3608b70ed8ce2ed4c15e0	EMITIDA	FA EH_2025	154	260754145	\N	2025-08-26 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.768
cmnfle37x01l4hgt4l4kn6adp	6884286cbd245afaeffa2512b0d6132e0f55d3c10f7565ea8e951bb841fa126b	EMITIDA	FA EH_2025	158	261748955	\N	2025-08-26 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.773
cmnfle38101l5hgt4qqo3dx32	1f234b9dd31c485048edb0091c1886451a057638059b50d88139c540045d8a3f	EMITIDA	NC EH_2025	12	260754145	\N	2025-08-26 00:00:00	-500.00	0.00	-500.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.777
cmnfle38801l6hgt4to66plnr	eec2f4cda5444308eb8873cf72aed22dbc775c15bdfdcb56afaec73d695a54d1	EMITIDA	FA EH_2025	159	261748955	\N	2025-08-26 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.784
cmnfle38f01l7hgt4ep3zober	488fd3d2e8127cc37d30f37c8f83c88b61016057da79b583cea4ec16f26ece5b	EMITIDA	FA EH_2025	155	260754145	\N	2025-08-26 00:00:00	550.00	0.00	550.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.791
cmnfle38k01l8hgt4znwuznnx	d76cc590fd838fd85f4a7fe0ad8261787ecfc49bf896e093fa348c24c32377f0	EMITIDA	FA EH_2025	157	265435463	\N	2025-08-26 00:00:00	1000.00	0.00	1000.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.796
cmnfle38q01l9hgt4l7ow11lc	42b810e42e807857e92be29d96ef1d36811d8cc4491004332df26a08fbfa6a79	EMITIDA	FA EH_2025	150	266475540	\N	2025-08-25 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.802
cmnfle38v01lahgt4sgxdp05c	fb797fb33c161f62a0674c23fac527b58651d673029897d1b6e94daaee85bc15	EMITIDA	FA EH_2025	149	266475540	\N	2025-08-25 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.807
cmnfle38z01lbhgt4lamytklo	78a384eec56384140d8ac3787d53fd0ee545d9b07906c2bb6bcf189cd0830256	EMITIDA	FA EH_2025	152	259933015	\N	2025-08-25 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.811
cmnfle39901lchgt4v2b0b368	4df74638ee41d454f5a40ed82de30b00963a49bd104c1348b42a773a3cfe8ced	EMITIDA	FA EH_2025	151	259933015	\N	2025-08-25 00:00:00	425.00	0.00	425.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.821
cmnfle39e01ldhgt4n93ge469	c54082407baadbce713db630cf77506fe85c5bb047423c2112d5b9252a4eff18	EMITIDA	FA EH_2025	145	261849450	\N	2025-08-24 00:00:00	1000.00	0.00	1000.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.826
cmnfle39l01lehgt444eu0qup	c54160248b0049a7bf4068453659aa0dbfc3ec11a45dfbace6e3bc9884cb2ac1	EMITIDA	FA EH_2025	146	261849450	\N	2025-08-24 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.833
cmnfle39q01lfhgt4jbojv0kn	ee6fc81fd8130f8b7424c5fbed05857210686a4299e974d8e3d1e3ae04eb2293	EMITIDA	FA EH_2025	138	266827560	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.838
cmnfle39u01lghgt491le2d6v	30414b51be245f13b9418a2d2c28d458ea869c5d0aed0217ef70fe96cd3036d9	EMITIDA	FA EH_2025	140	263053725	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.842
cmnfle39x01lhhgt4n637ccua	4a29340a331d91ac4e76c84e6e9e7b08e56539d469b327a432878b9fd04b64c8	EMITIDA	FA EH_2025	139	263053725	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.845
cmnfle3a401lihgt4ihkonk9e	412234db5f09ccdd546b10bd5cc31971f188f0de8aad5502c807a37eeda391ff	EMITIDA	FA EH_2025	137	266827560	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.852
cmnfle3a801ljhgt4h7malnjb	120e1a2d134903a63ebfd434d34357537770cace8d7b2c1ba047fca4ef543b2d	EMITIDA	FA EH_2025	147	266588255	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.856
cmnfle3ac01lkhgt4kbav4z0l	1347386e765eee2fcf14e658579c572ede04096583f61e96fbec2f7f1b08d8c9	EMITIDA	FA EH_2025	144	254708528	\N	2025-08-24 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.86
cmnfle3aj01llhgt4mmvp0lbv	9f429962b803b453e0a8645044390fe16baf98f37380b7030af6c72f47a4a4b8	EMITIDA	FA EH_2025	148	266588255	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.867
cmnfle3ap01lmhgt4e5fs2i6j	45e6f8c3b6babb4f5af3a8fb5a7a855e0efed88d17f1e8ee9560011ee1313ce1	EMITIDA	FA EH_2025	143	254708528	\N	2025-08-24 00:00:00	1000.00	0.00	1000.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.873
cmnfle3at01lnhgt48nbo9rfy	4922a4690b84c9dd7d6f872af28f21df4faa622e500212812453de731236a9cf	EMITIDA	FA EH_2025	142	261598619	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.877
cmnfle3b101lohgt4g8yrr1ts	9003d084707cf20879ee08b2555edfc76c708245a4787ae2e451d8fd27a5e86a	EMITIDA	FA EH_2025	141	261598619	\N	2025-08-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.885
cmnfle3b501lphgt4q2t6tq6h	8578762886c6f0816f6d0116b189c8e6605bb4442468234dc63162d4d96bcb40	EMITIDA	FA EH_2025	135	256125627	\N	2025-08-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.889
cmnfle3ba01lqhgt4ilj75rq0	59ebb66c229f18c46452316bc413e93d42ceb84fe1080164b2f03ab80a27a587	EMITIDA	FA EH_2025	134	223482900	\N	2025-08-22 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.894
cmnfle3bg01lrhgt4x57g7ai9	53262aff7d32d1388d33dd8d10ecba974a4cc4f66f5ab2a32babdaf938aee711	EMITIDA	FA EH_2025	131	258449233	\N	2025-08-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.9
cmnfle3bl01lshgt4frj4w659	6c2ba9ed3c36dbc7cf7bc8bd3314df9e3225b5941b44ac8bda5d912cc110ecd8	EMITIDA	FA EH_2025	127	244984883	\N	2025-08-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.905
cmnfle3bp01lthgt4n9eky924	99f157b26730b0546b6ff1f701f437d0182c6882d13724a4e41f864d838aa909	EMITIDA	FA EH_2025	136	274734338	\N	2025-08-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.909
cmnfle3bv01luhgt4qxbpyzoj	b3cc48a1786f4b4399e02ebd89fe82d627283b2b46df675c67764dcfa11076fa	EMITIDA	FA EH_2025	132	255364962	\N	2025-08-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.915
cmnfle3c001lvhgt4j2imahdi	a62a09d4cdbfcf421cf3e1e0d7241f2494c9a2dfb0f8b4b3d516521c4bae52f3	EMITIDA	FA EH_2025	133	261803310	\N	2025-08-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.92
cmnfle3c401lwhgt4v03j6e1a	6667500a211e5d25f8b21f3b6c02380ec68a0da905f2d02ba6daba6550e1a3aa	EMITIDA	FA EH_2025	130	270909028	\N	2025-08-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.924
cmnfle3c801lxhgt4iz4ffvct	2598e29e4293cdb5e8646c39a195087c4b801d22fd60fef2327fd4d10b85d76a	EMITIDA	FA EH_2025	129	248797239	\N	2025-08-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.928
cmnfle3ce01lyhgt4x1ms21ou	cc75d41753f508cd8b58802237702d59979dc02825d461e6eac212a5901fd6bc	EMITIDA	FA EH_2025	128	262961512	\N	2025-08-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.934
cmnfle3ci01lzhgt4cprfebph	280d2c6f9392381f9524dbaa706ac1a23138aab648bb45cd1567f569aac07ca6	EMITIDA	NC EH_2025	11	253278716	\N	2025-08-20 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.938
cmnfle3cm01m0hgt4e4w2b38t	dec4c4439443ba98bb9429ba0b8b35c403da5b246a144c0b8f3293b5194f9f1e	EMITIDA	NC EH_2025	10	261803310	\N	2025-08-03 00:00:00	-450.00	0.00	-450.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.942
cmnfle3cq01m1hgt4xqev24f3	75494402e94760f3ea900e9d5b55ddc22a3aad110829f8d77641c6ed7bf0d620	EMITIDA	FA EH_2025	126	274734338	\N	2025-07-24 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.946
cmnfle3cv01m2hgt49549xayg	acd4853fc8c42d50875c3e31b66c416f537bfdadf572f2c7acf2909ac79ab876	EMITIDA	FA EH_2025	118	257665072	\N	2025-07-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.951
cmnfle3cz01m3hgt41vvsr6c6	f499cd143760424569e80a768f31f612e51802204351eb17c0469105dea20aac	EMITIDA	FA EH_2025	117	258449233	\N	2025-07-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.955
cmnfle3d301m4hgt4dvblrfaz	e778a5279cdff56bb82e95fae3c3b048ab841ee5ee7702b839a8929437a02093	EMITIDA	FA EH_2025	123	223482900	\N	2025-07-22 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.959
cmnfle3d701m5hgt4ysbfdnlp	32f39c8a1776ba2567004df987b30738d3075baab072e9d23824c3f8682ec578	EMITIDA	FA EH_2025	115	248797239	\N	2025-07-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.963
cmnfle3dd01m6hgt4ecn0raj7	e254990119861e91dcf298b787b8b2f86fc6a86530cb210650962895aa2743c6	EMITIDA	FA EH_2025	119	259676136	\N	2025-07-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.969
cmnfle3dh01m7hgt45nr2ihjv	69a7a3af4d4803421944c6cacc56d2fad6a2d5470b9766eeb8045c0fb931ca68	EMITIDA	FA EH_2025	116	270909028	\N	2025-07-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.973
cmnfle3dk01m8hgt4ebxw85x4	5ec06d9b1f9be03b8063c4c6e454869311b01c246bc414970c8b920f8cf23535	EMITIDA	NC EH_2025	8	257665072	\N	2025-07-22 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.976
cmnfle3do01m9hgt4dkkbqox8	9ddf5ecd511ff329258b0eb3823dc055117c17b1f87d39c6fb137c1a49f7b054	EMITIDA	FA EH_2025	113	244984883	\N	2025-07-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.98
cmnfle3du01mahgt4rh2hy6rl	6b53f6aad86aefc511e098a26903157b829d1d737b5e8b6cc18c391384e0793e	EMITIDA	FA EH_2025	122	261803310	\N	2025-07-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.986
cmnfle3dy01mbhgt420c4a6tu	34b84dbda197b30ddbc9b12b1fd91fe1b5d2208517436bf00681553903442938	EMITIDA	FA EH_2025	121	258836989	\N	2025-07-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.99
cmnfle3e501mchgt4rr9080so	c2224395cfca91e7fd88bed6f00dd6f9e77ba0b7913197ad84a2ed5ef16c05d6	EMITIDA	FA EH_2025	124	266277055	\N	2025-07-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:25.997
cmnfle3eb01mdhgt4obnnj6p5	d1cf43786224337afa455e33039bb0cced5800fc57f9f78bf96b2f199000c428	EMITIDA	FA EH_2025	120	255364962	\N	2025-07-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.003
cmnfle3ef01mehgt4eby4gzl1	c0ad97eee6db08e0703920ae800728a7acbf633f345589f1669179b6032268b2	EMITIDA	FA EH_2025	125	256125627	\N	2025-07-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.007
cmnfle3ei01mfhgt40n2ezje9	08ed530f2f9fe1d9215b771472fb24f95cf35ac445dd3b13d413573e51f57ca6	EMITIDA	NC EH_2025	9	258836989	\N	2025-07-22 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.01
cmnfle3eo01mghgt4dzz0z2nl	478ee158d109381ac20cbc8f23b55668cdceba358137a67d69a3af21f4207ddf	EMITIDA	FA EH_2025	114	262961512	\N	2025-07-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.016
cmnfle3es01mhhgt4wi58vmfv	c06699b6b6d3d5dbf4132bf161b75f61535113dd30ce093a1495035fc335fdb4	EMITIDA	NC EH_2025	7	257665072	\N	2025-07-17 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.02
cmnfle3ew01mihgt42nd0bdh5	8c8b2c117701eeb3976f0841c936ee33ff90192717b6fd15c1904328610ef68a	EMITIDA	NC EH_2025	6	262387085	\N	2025-07-17 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.024
cmnfle3f101mjhgt4acmrdevr	d25eef1a8286588a7c4fcac1e08fea4a6438633c3aa5d2f39e56744d1a58b0d6	EMITIDA	NC EH_2025	5	257675841	\N	2025-07-08 00:00:00	-400.00	0.00	-400.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.029
cmnfle3f701mkhgt4rs35pmgj	668a37121ff08d392dc053ad272e48a2d4a76af31399ede2fa1c4f2ecdaeabdf	EMITIDA	FA EH_2025	112	270909028	\N	2025-07-02 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.035
cmnfle3fb01mlhgt42iz60erq	012b5747af1f756dfd6e862044a007f93b511e032bde896f0f90d0177134dcd8	EMITIDA	FA EH_2025	106	261803310	\N	2025-06-25 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.039
cmnfle3ff01mmhgt42saxwx3z	d67d68824b4c36d3fbae34ff32b5bcb5b276d5ba1f82ef364dab343844c036a9	EMITIDA	FA EH_2025	108	256125627	\N	2025-06-25 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.043
cmnfle3fj01mnhgt49zguzyvq	80fd874ab19b582e9107c5dda45785619b09c6f343a688cd9c1ab0563f0649f4	EMITIDA	FA EH_2025	105	258449233	\N	2025-06-25 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.047
cmnfle3fo01mohgt4g8lb2zr4	81de168e983b666a92f449b814522ea8622c08e1193662cc47d699af5a999780	EMITIDA	FA EH_2025	101	244984883	\N	2025-06-25 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.052
cmnfle3fs01mphgt4fkhf0gh3	e31d0207b1b9f0b68de61fb01c3284b6b0e7f0b11ddb9440bce52f97156ae667	EMITIDA	FA EH_2025	110	255364962	\N	2025-06-25 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.056
cmnfle3fv01mqhgt4fhqhyqwq	d1269d597d4b5fa18d50cd67236c26dc34638b73043a9c2bf1b2d6951f281821	EMITIDA	FA EH_2025	102	248797239	\N	2025-06-25 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.059
cmnfle3g001mrhgt463ypk763	001849a55be610b2db0a193daf549d52cf891374634a134cae128480481261e2	EMITIDA	FA EH_2025	111	252916077	\N	2025-06-25 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.064
cmnfle3g501mshgt4sgxeax7w	d6fba936186ba819c03189034a8466aef6f28dd0e42a6f1134c3f30163c35687	EMITIDA	FA EH_2025	103	259676136	\N	2025-06-25 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.069
cmnfle3g901mthgt4fsmq5vcz	7832009598983f88189bd8ccc81ec16e95cce26f735711ca3b17e7c38130c300	EMITIDA	FA EH_2025	104	223482900	\N	2025-06-25 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.073
cmnfle3ge01muhgt4ny4sp0t5	b56c2f3bf76720d77116587db75eaf396b10b04cf8acd145d32453e273e2a31e	EMITIDA	FA EH_2025	107	266277055	\N	2025-06-25 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.078
cmnfle3gk01mvhgt4e198sao3	dfffe39772eed4f38558fb1b8cf96f9f5ab7a98091a53c3dea8b6457cdc69677	EMITIDA	FA EH_2025	109	262961512	\N	2025-06-25 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.084
cmnfle3gr01mwhgt4vxiwxtgh	92a275f4a4c44b433f91a7bd6d5c6bf62f7a46354c40579f47e0b0d5d55be803	EMITIDA	NC EH_2025	4	267439130	\N	2025-06-17 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.091
cmnfle3gv01mxhgt4pdq5paki	83845ac07f6daf29c6934649e6639def007be09537ad480d1a585717392e0ed7	EMITIDA	FA EH_2025	100	257675841	\N	2025-05-31 00:00:00	200.00	0.00	200.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.095
cmnfle3h201myhgt444r4yn27	e0f41c92fad0561f44bdb455d0f1fb3274da48616bcc4bc45a34634ca4e0ee73	EMITIDA	FA EH_2025	99	330615254	\N	2025-05-26 00:00:00	1800.00	0.00	1800.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.102
cmnfle3h701mzhgt432rcd7k9	0d43b0d9a5273e2e4fa2b3cee8f650525e0911a448ddd37a6ee8e8624d758a16	EMITIDA	FA EH_2025	86	262961512	\N	2025-05-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.107
cmnfle3hb01n0hgt4fm1adoy1	d22a73665442de710342cdf8fbbf5709cce26a87897a117bfee25c250be35ee8	EMITIDA	FA EH_2025	88	270909028	\N	2025-05-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.111
cmnfle3hh01n1hgt4mox1sz16	34991f66864210112ea7df20799b33bc32b6b50c65ca6e0a51bc404c2c186905	EMITIDA	FA EH_2025	89	255364962	\N	2025-05-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.117
cmnfle3hm01n2hgt4yqws425z	25b0361264203ecebfff9125f84b48755afe396f240275e61b2de1647dae444d	EMITIDA	FA EH_2025	83	248797239	\N	2025-05-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.122
cmnfle3hp01n3hgt4pq2j710s	d819b214c6de8ac9f3aaf64c6384d63c072746b86125ea852831ed1362825c9c	EMITIDA	FA EH_2025	97	261803310	\N	2025-05-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.125
cmnfle3hs01n4hgt4bkwb3sdm	a2e3d5aa44dcaab4793c15344610ff4d1dc27aa48fc37ac08b67444475b86dd5	EMITIDA	FA EH_2025	98	258449233	\N	2025-05-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.128
cmnfle3hx01n5hgt460x6pg8q	66068806d5f9c22ec7e56724585abca37794e07455a0ea51e0f37100eb4fda3f	EMITIDA	FA EH_2025	85	257665072	\N	2025-05-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.133
cmnfle3i101n6hgt4h0nkp7gi	84337986d559979c1e068e972e70600489e8b0d453f65df7232580e40e323721	EMITIDA	FA EH_2025	95	256125627	\N	2025-05-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.137
cmnfle3i501n7hgt4d4c6xob8	c9d654177f213691a5ea0690e0c809ff5d59e4cdceda4e86f817cc5bb6c02ae9	EMITIDA	FA EH_2025	93	258836989	\N	2025-05-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.141
cmnfle3i801n8hgt4k8l2y55g	3e2cddbab26678108774a511fa83961086abb701b272be616e9d120eb2c039ab	EMITIDA	FA EH_2025	92	262387085	\N	2025-05-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.144
cmnfle3ie01n9hgt4a9gozsw0	8ff4b5548304350bb8fc2c7c75c9940a0e7274a5fceb142d77d480cfe7ecce44	EMITIDA	FA EH_2025	87	252916077	\N	2025-05-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.15
cmnfle3il01nahgt4rva29i0h	1c4f275ead15e7a00d49482923aaca1973412f1393f1d1e76b1a31a973878a03	EMITIDA	FA EH_2025	84	244984883	\N	2025-05-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.157
cmnfle3ir01nbhgt4jy6i83qe	21a042109aeb012df6b4966cf1f94cf0068a63b62dcfb4667904d9ed4d909f03	EMITIDA	FA EH_2025	96	266277055	\N	2025-05-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.163
cmnfle3iy01nchgt4xnakai5w	dea1d91c87575289cab3a49a2df5bcf834b3abe7eea48c6a6400faa30b6abb02	EMITIDA	FA EH_2025	82	259676136	\N	2025-05-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.17
cmnfle3j401ndhgt4i1zt5fti	f843007a20644dbae36833c993e82ab54a21cd908abc9a80ef47652355dfec2f	EMITIDA	FA EH_2025	90	267439130	\N	2025-05-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.176
cmnfle3jb01nehgt4ni9vo2v8	3b70eb5c54efdb1ca7a9f2f03baa0d564d1b2e1bc57b72ed0ac97afcf3ee2547	EMITIDA	FA EH_2025	81	223482900	\N	2025-05-22 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.183
cmnfle3ji01nfhgt4t0mgxqyp	560a2f3e253788fbf0d5de00fb1c80ca5aec0362bfa57faece381da66722e824	EMITIDA	FA EH_2025	94	253278716	\N	2025-05-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.19
cmnfle3jn01nghgt4ckf25fxl	138ace89e38ef169cd30042bc787051ed63f45fc9cab8c1855b3e2dfffa371cd	EMITIDA	FA EH_2025	80	330742213	\N	2025-05-01 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.195
cmnfle3jv01nhhgt4osju75up	8f17ba16cd9997bfa60c3dc7b8bdab1244a93cf6a208eaf7cb02d0fe2a3e1825	EMITIDA	FA EH_2025	77	248797239	\N	2025-04-24 00:00:00	335.84	6.75	342.59	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.203
cmnfle3k001nihgt470peisp0	357be09a35099087de523ca7ffe756d830f97d2c8496e698b71bc8cdc5473c25	EMITIDA	FA EH_2025	78	244984883	\N	2025-04-24 00:00:00	386.92	6.75	393.67	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.208
cmnfle3k601njhgt4hiyj6e6u	3533942548e1ff30a3cc3ba8833dbf0f42291a44eade003d6cc1b1857d50ffdb	EMITIDA	FA EH_2025	76	259676136	\N	2025-04-24 00:00:00	379.36	6.75	386.11	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.214
cmnfle3kd01nkhgt40lx4m2f9	0934fafe8b2b86cc12ef21aa01ee9c1899cbb5db95f3f4f8bc9c97d940907fe9	EMITIDA	FA EH_2025	79	257665072	\N	2025-04-24 00:00:00	379.36	6.75	386.11	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.221
cmnfle3kk01nlhgt4n61miyen	23e90ac88531ae66efedee4eda36d26fa2bc267971715aeb09d3e57a82e10cb4	EMITIDA	FA EH_2025	66	267439130	\N	2025-04-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.228
cmnfle3kt01nmhgt4vflrhv3l	b5caa81ecf94d5f05ec33ae60709067c2ccce576939e17a01839845f68db14b9	EMITIDA	FA EH_2025	75	256125627	\N	2025-04-23 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.237
cmnfle3kz01nnhgt4tgxdy037	95350def71cb10759aa222bdc2c5161440e72f9f0b6e1565d5f3499b5ee52e72	EMITIDA	FA EH_2025	70	262387085	\N	2025-04-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.243
cmnfle3l601nohgt4ku2xe423	dfa6fd924e86ac379238127735ffad6e6989ea364c9eb017100f2061e1e88ce2	EMITIDA	FA EH_2025	65	257675841	\N	2025-04-23 00:00:00	400.00	0.00	400.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.25
cmnfle3le01nphgt4wel7vs62	9b767035ce5d4e936e2be5b5493d4fb85407e2ad323a3dd0cc9110e233655235	EMITIDA	FA EH_2025	74	266277055	\N	2025-04-23 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.258
cmnfle3lo01nqhgt4vxm3i8z6	67fcaef5900f8f8fa1922cd68e1b3eac1293b9a8b3fa3000bf692216e8a6ba0a	EMITIDA	FA EH_2025	62	252916077	\N	2025-04-23 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.268
cmnfle3lx01nrhgt4nbckyhq9	35eda08df2282c89a501c280a3a093da659a633ffe509cd86903286fa08c5ad5	EMITIDA	FA EH_2025	69	253278716	\N	2025-04-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.277
cmnfle3m501nshgt4vegw5urd	e7b8b1221a35023a11b3d59c739a779ba8a8eb0d171528604af5d97504338bed	EMITIDA	FA EH_2025	63	270909028	\N	2025-04-23 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.285
cmnfle3mc01nthgt43e6ywnai	0083b264b87310ddd3958f89ed412762ac1bfcd3788bf2ad387eb0e3d1d71684	EMITIDA	FA EH_2025	72	261803310	\N	2025-04-23 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.292
cmnfle3ml01nuhgt4s2h0de5u	f6888fae40e99069fc79db05544a156ca2b7e8a2d22225a1e15fd27e3b35cb78	EMITIDA	FA EH_2025	73	223482900	\N	2025-04-23 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.301
cmnfle3mt01nvhgt47j17joov	3dfedf7bbf5aa4213719d54dd37532767415d9ecd4adb2de8aa003b9591e332f	EMITIDA	FA EH_2025	61	262961512	\N	2025-04-23 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.309
cmnfle3n401nwhgt47skts24p	bbb4f3086d39a76215c983a5d8b033bccd8087a2778068d6b4f7474179d53aa2	EMITIDA	FA EH_2025	68	255364962	\N	2025-04-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.32
cmnfle3nb01nxhgt4wmw9puri	6c98402c38ed29fbc21150c86d8b7d1fc8679ee41fcb03104644a858ed6f8ea1	EMITIDA	FA EH_2025	67	258449233	\N	2025-04-23 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.327
cmnfle3nl01nyhgt448c50s0w	5b88fd2148a72d0c7856bc3612244fdc8bdf678995f6b62b4f92f5343884bd0a	EMITIDA	FA EH_2025	71	258836989	\N	2025-04-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.337
cmnfle3nt01nzhgt41izmpfnh	ad513afa2d6b547f61d178cf387f4d08498865fbb84a546333cf01fb5007c25d	EMITIDA	FA EH_2025	54	253278716	\N	2025-03-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.345
cmnfle3o101o0hgt4oqbg4yp5	49efc79264638d4284f0e6e0ecf498b7cee5630e6c7404125937d405896f0450	EMITIDA	FA EH_2025	44	248797239	\N	2025-03-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.353
cmnfle3o801o1hgt4f9wgq6x8	14c1d927fb4ff731a7d1d47bc177bbfca27e47efc6b0b6307c4ce20e5b283e7d	EMITIDA	FA EH_2025	45	252916077	\N	2025-03-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.36
cmnfle3oh01o2hgt48ye5a16p	4337fb180141a4b4b28c057aa64f54a8060bbf0b600c32bacaccd539fb0fcfed	EMITIDA	FA EH_2025	50	258449233	\N	2025-03-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.369
cmnfle3oo01o3hgt4iawrch0f	fa84db2aa2b99e732b646dc6bb75afda05e4c777c387b2071d2934ab7bed4ee0	EMITIDA	FA EH_2025	47	234850876	\N	2025-03-22 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.376
cmnfle3ow01o4hgt4wq636pop	aac4a925a711328a42be601e856cb1d93f715fcbed43c7a1e6c97e864330c13e	EMITIDA	FA EH_2025	48	257675841	\N	2025-03-22 00:00:00	400.00	0.00	400.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.384
cmnfle3p301o5hgt4u268uoy5	26175bd6f84fd8c18c0f99a293d0574a7cbc434501ae35b6993fc721c4ab8139	EMITIDA	FA EH_2025	43	262961512	\N	2025-03-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.391
cmnfle3p801o6hgt4r6g3mnjq	705f8ebea8d17add0bb347ace707502cba0c4ca6f07367361f6367505d4f9a17	EMITIDA	FA EH_2025	57	261803310	\N	2025-03-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.396
cmnfle3ph01o7hgt4dc5jlwvj	44dae2893c11b0c2badbecd0ad64ff27d2a62162fadb47ae6faa324208b3e211	EMITIDA	FA EH_2025	58	223482900	\N	2025-03-22 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.405
cmnfle3pn01o8hgt4gpfy0lvy	998ea557ef7c7405c78d36d0dfcc991c7db74eec1a61fb1d1ea7f66e340ea2d7	EMITIDA	FA EH_2025	59	266277055	\N	2025-03-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.411
cmnfle3pw01o9hgt45q5fmrlb	45fd2eac1d718832b3179d862add0216e182bb96c882b7fa5d288a8a36dfb8a6	EMITIDA	FA EH_2025	53	255364962	\N	2025-03-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.42
cmnfle3q401oahgt4bne1o7dz	16e6650626434fa359c9b55ee2692f89e17ecc58e51a29d5e77634fc3a32e9f3	EMITIDA	FA EH_2025	49	267439130	\N	2025-03-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.428
cmnfle3qc01obhgt4wkn74mrk	62d99e8686258d757a2b91b564a5ec7b96bafffe25d5bad32242a41bd79b0748	EMITIDA	FA EH_2025	46	270909028	\N	2025-03-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.436
cmnfle3qi01ochgt4wsy8m3xi	9cb10d8b7312a45e9280610321686202ab81705e4e2d151468af90f0d67a9c44	EMITIDA	FA EH_2025	60	256125627	\N	2025-03-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.442
cmnfle3qq01odhgt4vvu0weid	4769ff6ecda4c7da7f8bc88188d83943a43d384a4b3bd8667b7ce89000940e7e	EMITIDA	FA EH_2025	56	262387085	\N	2025-03-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.451
cmnfle3qx01oehgt416x343yv	955c9d68eff3bc4e0c41bd792770aeae900f95745c115c5daf2f460113493962	EMITIDA	FA EH_2025	55	258836989	\N	2025-03-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.457
cmnfle3r501ofhgt4rn0n1dx8	e2613ddf44d26f9e6005bdfd03f8159ec30220cc036164bba43c9297428643ef	EMITIDA	FA EH_2025	52	259676136	\N	2025-03-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.465
cmnfle3rb01oghgt4b58mj8cc	65968c19d5063eae240a122fb6e378ce9438ba0bf00669444e16077fbc525445	EMITIDA	FA EH_2025	51	257665072	\N	2025-03-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.471
cmnfle3rg01ohhgt4x7g0x7dc	09ae0f19d686adb2a9dfee59b830771266171ecf87ceb7cc1e9424e836d76676	EMITIDA	FA EH_2025	42	244984883	\N	2025-03-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.476
cmnfle3ro01oihgt4flg9udcu	73a4352799efa79b03065687b7b1e0ee7ded685fef5b0e1854d043a0d59118d1	EMITIDA	NC EH_2025	3	255497393	\N	2025-03-10 00:00:00	-1000.00	0.00	-1000.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.484
cmnfle3rw01ojhgt4m1f90793	d1fff102ea26b9b2ec9e8d94947dbaad95781c1cb947dc55144670fe43dc0239	EMITIDA	FA EH_2025	41	255497393	\N	2025-03-10 00:00:00	125.00	28.75	153.75	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.492
cmnfle3s401okhgt4fjpbcze0	5deb962290049ab76b9f077c57ed35844d935cb8dd44e276695c2cfed8be2256	EMITIDA	FA EH_2025	24	259676136	\N	2025-02-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.5
cmnfle3s901olhgt4ljrojw80	7ed647fb659293df5b3dd84a8b19eb529ceb88e47a55147c9d8400cdbc649637	EMITIDA	FA EH_2025	34	262387085	\N	2025-02-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.505
cmnfle3sf01omhgt4a42qi7ts	5529d75c42a0641f067500c603df146a2b4ed45a534d78e0534236901d05e52f	EMITIDA	FA EH_2025	32	267439130	\N	2025-02-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.511
cmnfle3so01onhgt40m5u20yj	f5b63b1218b25f8783898451895033f85b86096961f0a8e864fd0bd73287d89b	EMITIDA	FA EH_2025	40	258449233	\N	2025-02-23 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.52
cmnfle3su01oohgt4n2oq5hiy	c6e2b2e0839ddaf0f2476be1ae8962fc2f4008022565179630b7f20539e83e20	EMITIDA	FA EH_2025	33	257675841	\N	2025-02-23 00:00:00	400.00	0.00	400.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.526
cmnfle3t201ophgt47gdr9ga6	03c6e4d7697f0b3d9f99b0cbc854ca615b2f6e4a49942e314f5e6e4332fb64b8	EMITIDA	FA EH_2025	35	258836989	\N	2025-02-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.534
cmnfle3t801oqhgt43q7xl61n	864180aa98b03d823fd60c662edf93ad51f634c5a22cccbdd5fe3a6ff196c327	EMITIDA	FA EH_2025	22	257665072	\N	2025-02-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.54
cmnfle3td01orhgt49sfmaf1e	ec3adb5302f1f8831c3b027f41ce2fbbc24110f4a3c7e01607300e70ef2ea731	EMITIDA	FA EH_2025	30	270909028	\N	2025-02-23 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.545
cmnfle3tl01oshgt4erdcq4dl	747d1d7c49073023b9e65829a291962dca3bbc3e5476dab51f3fc6b156cda7c7	EMITIDA	FA EH_2025	27	262961512	\N	2025-02-23 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.553
cmnfle3tq01othgt443yaztpl	67a1267e52ad8276c260ccaf86021a6f8611be85e7b1d0ce43f74a1e4d92d95f	EMITIDA	FA EH_2025	28	234850876	\N	2025-02-23 00:00:00	375.00	0.00	375.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.558
cmnfle3tz01ouhgt4d1yqofko	2986269f48c66485c3bbb8ec9fdebafd090b5bd50cca0f7e4ee60f8084235254	EMITIDA	FA EH_2025	25	248797239	\N	2025-02-23 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.567
cmnfle3u801ovhgt4umuuv4ir	62ea147f7674f5bf7c9a30ae7d4ef2935a9dde6b6fe905d16dc99f664c17b6d3	EMITIDA	FA EH_2025	23	223482900	\N	2025-02-23 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.576
cmnfle3uh01owhgt46e4f6wdo	c6577bc89814e810ab2cb5c16addddd0fa74336242bb71b90ee6aeb6ee659b02	EMITIDA	FA EH_2025	31	255364962	\N	2025-02-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.585
cmnfle3uo01oxhgt47yco5ddu	71f3e01f40565db1b080179c65a518c1477609ac334401b8d9f424db8b1335ec	EMITIDA	FA EH_2025	26	244984883	\N	2025-02-23 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.592
cmnfle3uw01oyhgt42acbpu7o	02d200876f40f2068e9c6b7d583e4b61e70c3b10a18453f8b6c70386bd52068b	EMITIDA	FA EH_2025	39	261803310	\N	2025-02-23 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.6
cmnfle3v101ozhgt49we50qqi	522e715f26d96b6a27fe1f0abbba9fb3cf651b9c144097a79efcb50e100146d2	EMITIDA	FA EH_2025	38	266277055	\N	2025-02-23 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.605
cmnfle3v801p0hgt455jbtr7d	a8731deff660452b8c4cdcb37ed6babaf4063daf31da0843a1836813e6ce536e	EMITIDA	FA EH_2025	29	252916077	\N	2025-02-23 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.612
cmnfle3vg01p1hgt4dkiywdjq	d23a6318ab994fb120eb20eb3eba5692e93ff33f25177230d19c1de59e2b3a31	EMITIDA	FA EH_2025	37	256125627	\N	2025-02-23 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.62
cmnfle3vl01p2hgt41g6axixq	bc5cef2991d74754b4d0c3dca7307e5d18e6c328895811501e1aa5f7ab536383	EMITIDA	FA EH_2025	36	253278716	\N	2025-02-23 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.625
cmnfle3vr01p3hgt4sh5p0hyr	9f7f3a9e108f723cd97dc08a0e4b439bc55272cb5ab62a43c45f784cfa8092bf	EMITIDA	FA EH_2025	21	257675841	\N	2025-01-27 00:00:00	340.00	0.00	340.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.631
cmnfle3vx01p4hgt4pwjcu1hg	89f9fdea0ab6ec9cbbc635d8029fcebd86b5022635dfc8f383a064a6b3553e28	EMITIDA	NC EH_2025	2	257675841	\N	2025-01-27 00:00:00	-400.00	0.00	-400.00	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.637
cmnfle3w201p5hgt4uztnj9o9	0a2dc7812feeb68eea01499c88096f93a0b5d9a412ff66a8836f58164e8a3fd9	EMITIDA	NC EH_2025	1	234850876	\N	2025-01-24 00:00:00	-383.10	0.00	-383.10	Nota de crédito	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.642
cmnfle3w801p6hgt4x3l9b1m7	58d3f8b47eaf06bef01126df186f1227ae1908caba89ddd3f86a16c91c7df9ea	EMITIDA	FR EH_2025	1	234850876	\N	2025-01-24 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.648
cmnfle3we01p7hgt4tj95rwe3	01cfa04d62340b36fb678002d0656845d535b7b300ca17571dd87b81394e9fc1	EMITIDA	FA EH_2025	17	262387085	\N	2025-01-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.654
cmnfle3wj01p8hgt4cjejbt39	48020eb6c31b5e4a24b5321186637dae5598435a0976d5fe9f37052012252c76	EMITIDA	FA EH_2025	3	248797239	\N	2025-01-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.659
cmnfle3wp01p9hgt4ln0pzphx	60210f8beb44ecefaeedda23435ec60640de8594fa1340ba83e75a30a7ab1b24	EMITIDA	FA EH_2025	4	252916077	\N	2025-01-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.665
cmnfle3ww01pahgt4k4npze0c	5bfffab507de06f9ee22de79e9c7e5fac810053fa10442092d85a29a2cdec4f3	EMITIDA	FA EH_2025	12	255364962	\N	2025-01-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.672
cmnfle3x201pbhgt433b7tued	25b05ab8d97129e7391d87e9b3d5ed86162d13434474f31f61268ec78a376d5a	EMITIDA	FA EH_2025	7	257675841	\N	2025-01-22 00:00:00	400.00	0.00	400.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.678
cmnfle3x801pchgt4msgglhpf	1528a38b8a3a671560f371663a9b8c0bf4dca93d916338d1bd8d369e6eef0d2f	EMITIDA	FA EH_2025	10	257665072	\N	2025-01-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.684
cmnfle3xe01pdhgt4yyrvi71q	e3b6903ab3e2318025e39d325fc4e5b3bec384960939aa06aa6c1c57333f9aa5	EMITIDA	FA EH_2025	5	270909028	\N	2025-01-22 00:00:00	306.48	0.00	306.48	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.69
cmnfle3xj01pehgt4oh8hyfhu	995d354e9f3e29479a84afb9bcda9d91f67260f6c39eddb5108f157e58a67c3c	EMITIDA	FA EH_2025	9	258449233	\N	2025-01-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.695
cmnfle3xp01pfhgt4n1jiz4kr	02943ae1b238f159a3241cefa637f80d0dc564e497473553f7a9459ed94feb66	EMITIDA	FA EH_2025	14	223482900	\N	2025-01-22 00:00:00	80.00	0.00	80.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.701
cmnfle3xu01pghgt4gfj7qjis	82c0a936ac6cc58eb2a7528222133ba48780f849518ab4f7c6de55752edafbac	EMITIDA	FA EH_2025	6	234850876	\N	2025-01-22 00:00:00	383.10	0.00	383.10	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.706
cmnfle3xz01phhgt4d8h7ecfv	61e12dd6e387c8cd05653e0c187e04ffefb46a959af80f1c5769165abfc34ee2	EMITIDA	FA EH_2025	8	267439130	\N	2025-01-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.711
cmnfle3y501pihgt4a41aras5	679c40a713c25603217ffd3390b1298992889c5a74f273b66811541296d1216f	EMITIDA	FA EH_2025	13	253278716	\N	2025-01-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.717
cmnfle3ya01pjhgt438bfbi69	c50693fa3da7e8dc382bd8e371679f1512cece4c50781cc76992fe8ac53bb612	EMITIDA	FA EH_2025	1	244984883	\N	2025-01-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.723
cmnfle3yf01pkhgt4yotq1rff	7f0af89fb6024e36211b0a7efca4fd55ff6f191ac28aaf47de94439f5563f1ab	EMITIDA	FA EH_2025	15	258836989	\N	2025-01-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.727
cmnfle3yl01plhgt4f5yizik4	455b9017146d0e6756287982a0c0169ea5868c9744fa2fd4d1d206c5318abab5	EMITIDA	FA EH_2025	16	255497393	\N	2025-01-22 00:00:00	500.00	0.00	500.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.733
cmnfle3yq01pmhgt4eprx4eu4	148bb28b87f1a84b59698dfe98d33caf60702b1b048463fdb4234a5484160a40	EMITIDA	FA EH_2025	18	261803310	\N	2025-01-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.738
cmnfle3yv01pnhgt48ecqd8gh	35694fea8e27c92cbe4ce57a3c1cdbf088703da397874f5a71cdfa5202abb1dc	EMITIDA	FA EH_2025	20	256125627	\N	2025-01-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.743
cmnfle3z301pohgt40nlkb0dy	4aa4e953737e9836043931ee6b265aa796367b1ee0742012fb916e2271e6aad4	EMITIDA	FA EH_2025	2	262961512	\N	2025-01-22 00:00:00	357.56	0.00	357.56	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.751
cmnfle3z801pphgt4ewnpwocs	5a3bf8da30f447ebde9cc383d014d603e4745c62876e19eead8e772340902446	EMITIDA	FA EH_2025	19	266277055	\N	2025-01-22 00:00:00	450.00	0.00	450.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.756
cmnfle3zc01pqhgt4idfzebdt	0890403cadf199cc01c103f20bc46892fb0cbaa7eba70c2054b1b63716d5354f	EMITIDA	FA EH_2025	11	259676136	\N	2025-01-22 00:00:00	350.00	0.00	350.00	Fatura	cmnfle2f801i2hgt4fyhs4ggj	2026-04-01 05:15:26.76
cmnhozzsb01yorkt4kiw5vbsd	2172637f007f6ad09de45a4124b85c32236329a20539541aadd1120971fe8715	EMITIDA	FA A	3	999999990	\N	2020-12-07 00:00:00	300.00	0.00	300.00	Fatura	cmnhozzrl01ymrkt4414mu5i5	2026-04-02 16:31:58.955
cmnhozzsl01yprkt4nmr4y4oi	22b0d0f960cf0a0a885268d8d74ad03c52b685fb49acb20f9b38951fcc6d748f	EMITIDA	FA A	1	999999990	\N	2020-11-27 00:00:00	300.00	0.00	300.00	Fatura	cmnhozzrl01ymrkt4414mu5i5	2026-04-02 16:31:58.965
cmnhp03tj01yrrkt4wnyp4nrd	0a92ea55c44952012aea437f301e4d0f80ea2c19867b9fe253960fa94c51ebac	EMITIDA	FR EXPHIST	36	244984883	\N	2021-12-03 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.183
cmnhp03ud01ytrkt4amoqvl6t	26a1edb34bfed91be849868fbbe1e09dd05a4ae5bd6c5a8f3048dec93930fb93	EMITIDA	FR EXPHIST	34	224974963	\N	2021-12-03 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.213
cmnhp03ui01yurkt4nnzk4pup	e2e00d5e7e126429554c458b53906e78eeabdb5b18bc47127228b3025dc6c5cd	EMITIDA	FR EXPHIST	37	264769953	\N	2021-12-03 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.218
cmnhp03uo01yvrkt4vlcakiea	7b9af29e41bef21b2191a839ea7ac60805038d90c8fe3527f78a4c037f60f6e5	EMITIDA	FR EXPHIST	35	251114996	\N	2021-12-03 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.224
cmnhp03uv01ywrkt4ancsv4h4	db51009359dee43de5a814e3f62f3f3088bf43d42e5cadd5426d608e2d6851eb	EMITIDA	FR EXPHIST	33	307451348	\N	2021-12-03 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.231
cmnhp03v101yxrkt4m4vo7pp5	fd9c4dc7c08152c1a7fc815830af38bf8349fd7d81a7d7b8144a6f5a1cf577d2	EMITIDA	FR EXPHIST	29	272868906	\N	2021-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.238
cmnhp03v701yyrkt4afkiacqk	9916ca5c31cc0c0782be0b24fe94f9c1f3f4f4b54abb93ccd065f338da3d01b6	EMITIDA	FR EXPHIST	28	224974963	\N	2021-11-02 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.243
cmnhp03vb01yzrkt4bi9hqder	bfa9a5934058191848466040e3c782dcf5c5ccf41c736613a7757ce99b759524	EMITIDA	FR EXPHIST	31	244984883	\N	2021-11-02 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.247
cmnhp03vo01z1rkt4ujrgpt5d	3cb074f372598b4f3e93ea60cecc9cd0e4edb259671c3aaa8c2203c57615d9a5	EMITIDA	FR EXPHIST	30	251114996	\N	2021-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.26
cmnhp03vu01z2rkt4qjokz37r	47d3b0e1cb248752e5cd2c795518409b13c98343ced5db575a04a5c455c24988	EMITIDA	FR EXPHIST	32	264769953	\N	2021-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.266
cmnhp03w301z3rkt4u8hfo189	8c2e65819339b1de6106c0f1ef04741b94fc53afa585fafac6bbe55aa26793ba	EMITIDA	FR EXPHIST	27	307451348	\N	2021-10-22 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.275
cmnhp03w901z4rkt4mqt262ig	c0c022328e1b5a44db00a6c7a5a1c3b55f88e81e1d2e3fea6df773efa7acee67	EMITIDA	FR EXPHIST	26	251114996	\N	2021-10-18 00:00:00	150.00	0.00	150.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.281
cmnhp03wh01z5rkt47dlm6hvv	e471402b28dd72a4dc85cfeaa4c6c384f1897dbfa49bc9e1f538fdc122e49f21	EMITIDA	FR EXPHIST	25	244984883	\N	2021-10-08 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.289
cmnhp03wt01z7rkt4803l0a33	12b4c9310440d66e861740915174bacdc6a2bf9048ee3db3c9936ee594288938	EMITIDA	FR EXPHIST	24	224974963	\N	2021-10-08 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.301
cmnhp03x001z8rkt4rx3c23wb	c2c56480c364983f3b69ff579c753b04321c4c5b488655d205b647a481e097ad	EMITIDA	NCP EXPHIST	1	264769953	\N	2021-09-30 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.308
cmnhp03xb01z9rkt4qtzwrf57	e341a9e301b63a72639dfcc0a7cd4cbe2f61346afa0485536b69b8df864697f5	EMITIDA	FR EXPHIST	23	264769953	\N	2021-09-30 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.319
cmnhp03xm01zarkt4ufq65bzo	7ae893ebf74ad96963a342ed88c24239513c62c01b4ad4c2f3661ceae09fcd41	EMITIDA	FR EXPHIST	20	264769953	\N	2021-09-29 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.33
cmnhp03xu01zbrkt4deihuxtz	a14a3a04b6be00a337f28ef6b6bd1c0a2eb04d53d7c52ff996463fcda60333c8	EMITIDA	FR EXPHIST	21	253023548	\N	2021-09-29 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.338
cmnhp03y001zcrkt43drrdtca	d7309bae8418f6c09d327f2ed4ed1b1121fe90de61e8a71100456b99c4c871ab	EMITIDA	FR EXPHIST	22	272868906	\N	2021-09-29 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.344
cmnhp03y401zdrkt4g59m19o2	0cb9bfabd0e5dcb257039dada0b2eb7211402c4e056fa75773721e73e96d2831	EMITIDA	FR EXPHIST	19	\N	\N	2021-09-25 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.348
cmnhp03y801zerkt4975r5xil	bd50789432c266df0869879b1ecca446aff097b6697f9375a36885ba0ac67119	EMITIDA	FR EXPHIST	17	221761144	\N	2021-09-06 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.352
cmnhp03ye01zfrkt4ctk74zum	e9c2e1bea14c17599c3dbe59e3620d54bf6a35f41735f7a52c5e48bb4470ea2d	EMITIDA	FR EXPHIST	18	224974963	\N	2021-09-06 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.358
cmnhp03yj01zgrkt49tzm7tlg	1b3a858a086d1763bcb5fa3e4716de022a28ed0f3cae320851fb7a176cc1b0fa	EMITIDA	FR EXPHIST	15	221761144	\N	2021-08-05 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.363
cmnhp03ym01zhrkt48g4tir48	178a41197e38706266300be709671616dc090912884bad7dc19e71d92cc5e972	EMITIDA	FR EXPHIST	16	224974963	\N	2021-08-05 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.366
cmnhp03yq01zirkt4s1ppvrxn	a5995b9a7cc404aff1b98bd608236aeb445a04465789044fb29c773f0571263a	EMITIDA	FR EXPHIST	13	221761144	\N	2021-07-01 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.37
cmnhp03yv01zjrkt4jq3v6hgh	46de0bb9c2c6449e4b19d38dc4bb4ce1afaadf6b478884505bd989d19b6679e6	EMITIDA	FR EXPHIST	14	224974963	\N	2021-07-01 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.375
cmnhp03z201zkrkt4dbfj1ru3	2e3dd95f1c01ce90fb7b9f8322476f66c96ed4b2cc85e27b2616c5ef97b79c2e	EMITIDA	FR EXPHIST	12	224974963	\N	2021-06-02 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.382
cmnhp03z901zlrkt48wi556yd	5783663aa3b0c6e6ac773ba8aa481fbd107f5530863a121bff5f282cca2168dc	EMITIDA	FR EXPHIST	11	221761144	\N	2021-06-01 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.389
cmnhp03ze01zmrkt404vl8orf	493770d7d7889c8f6839588ca419d8fc1e6c97ccfdbcd2416bfa0b396106e45f	EMITIDA	FR EXPHIST	10	221761144	\N	2021-05-09 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.394
cmnhp03zi01znrkt4yi0uh4f4	79540215c68b979f0feb9231c3f0230b6f736e4a2cb0a7503c1c094146713650	EMITIDA	FR EXPHIST	9	224974963	\N	2021-05-09 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.398
cmnhp03zq01zorkt4ssnhq8tq	8e7c15e5ba734d3a52e50de7efceb853543c2ff2509e512dcccdd56aa6e9c363	EMITIDA	FR EXPHIST	7	224974963	\N	2021-04-12 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.406
cmnhp03zw01zprkt49hahw08k	ded3dbd3f6265a7080101e4f838b939d0556d691e8dc7e5e87ed223ea2229662	EMITIDA	FR EXPHIST	8	221761144	\N	2021-04-12 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.412
cmnhp040301zqrkt4xic3fr96	99b936d39526e375fbf0c913e58de5f2cd7747c1375e18276f3566f632f521e1	EMITIDA	FR EXPHIST	6	304817341	\N	2021-03-16 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.419
cmnhp040b01zrrkt4p08itfsp	6f439c8aa16d8c0e20db65006e2cd225a942a1dba43c53f6c47a56ea8c8538b3	EMITIDA	FR EXPHIST	5	221761144	\N	2021-03-01 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.427
cmnhp040j01zsrkt49d67pf2j	5a969ac260ab593838fdb7979fc33feeb3a24d6d1959cad8fee8853251ad7695	EMITIDA	FR EXPHIST	4	224974963	\N	2021-02-25 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.435
cmnhp040t01ztrkt419yyde0j	4d2c7ab8b6c59c45537934166211a762774dffb79cbbb4ea2c87f39eeee74ea9	EMITIDA	FR EXPHIST	3	999999990	\N	2021-02-07 00:00:00	600.00	0.00	600.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.445
cmnhp041201zurkt4v3y6z5qk	35f79c25a2c19dd39e1358a6060d6a4d4ed83e156d83e13fef22971b37dba809	EMITIDA	FR EXPHIST	1	224974963	\N	2021-02-07 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.454
cmnhp041901zvrkt421ikm8xw	fe42ddb78c50c5594dbcba03828ea7ac9024541adde37c07f9eef54d61426559	EMITIDA	FR EXPHIST	2	221761144	\N	2021-02-07 00:00:00	250.00	0.00	250.00	Fatura-recibo	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.461
cmnhp041f01zwrkt406ynv766	5898c757bab372493dde5e611273e946a468891d220058e34ea894390c8fc0bd	EMITIDA	FA A	4	276178068	\N	2021-01-11 00:00:00	250.00	0.00	250.00	Fatura	cmnhp03te01yqrkt47eqf4zgl	2026-04-02 16:32:04.467
cmnhp08k101zyrkt4hhb2f37j	4570d1f5855a68d473102fd66fb34ad0df69fe61670ae309e2ff741d185d6453	EMITIDA	FR EH_2022	84	226804747	\N	2022-12-31 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.322
cmnhp08k701zzrkt4d0dnkl9n	0e679f7d4241f032dbfdb2acacd14226df9b53685f47af7d7f81fcf1e9df8818	EMITIDA	FR EH_2022	86	243483627	\N	2022-12-31 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.327
cmnhp08kd0200rkt4mbbo89fp	83a00ec92f69cded77dac5ea74d752af242239ae93bfd37a220b1569de3b5680	EMITIDA	FR EH_2022	85	251701212	\N	2022-12-31 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.333
cmnhp08kl0201rkt4vonk5jtk	d66246c3fa878c5fb36c9f97d2d8c0636af919fda786532463d90730d05571da	EMITIDA	FR EH_2022	92	262961512	\N	2022-12-31 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.341
cmnhp08kv0203rkt4u82wmnyq	fe69d1ced4d5a317159b25b66feaccd1c4124e764b1047636c3a259ea62916ca	EMITIDA	FR EH_2022	88	244984883	\N	2022-12-31 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.351
cmnhp08l70205rkt4cpu2hi4g	a99c4a51c0de79b9437b104d70a53d50331c677a0d2642fe87aff0cfbcf9ad63	EMITIDA	FR EH_2022	91	249613018	\N	2022-12-31 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.363
cmnhp08ld0206rkt4xhogv82j	274758db67823a8983446622819d8932631fbec571684140835867c5ac462503	EMITIDA	FR EH_2022	90	252916077	\N	2022-12-31 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.369
cmnhp08lo0208rkt4idtgpm0r	02c4e535e62a1d8700cbab7e972f44273279126a7d1ab21315df1c34a7a1a617	EMITIDA	FR EH_2022	89	270909028	\N	2022-12-31 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.38
cmnhp08m3020arkt4v3r3y1ie	cdcea8abb2c68097aec2c520724fc04a9117fe6199a2814a53cdf168396738fd	EMITIDA	FR EH_2022	87	251114996	\N	2022-12-31 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.395
cmnhp08md020brkt4gn95oj07	28b6cdb1d484187720c8308681d734e5691af2ec9b18dacf85dc27f475d897d8	EMITIDA	FR EH_2022	74	226804747	\N	2022-12-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.405
cmnhp08ml020crkt4szq8v8b8	60630bc554d707d78313385add4853d83ff3bb56b2f38f53d2033df67c821db4	EMITIDA	FR EH_2022	77	251114996	\N	2022-12-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.413
cmnhp08mu020drkt4qo2jtsgd	c86700bfb48a0317ecdaf6ea8ce56f9a816dc07a55ed0b879d96ca1fa24c4f1d	EMITIDA	FR EH_2022	81	252916077	\N	2022-12-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.422
cmnhp08na020frkt4ajnp2vxr	2403d8ae75f2d950fd6c62f37b2a1b075d05db1419caffc9b7df6b122b0107a2	EMITIDA	FR EH_2022	80	270909028	\N	2022-12-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.438
cmnhp08np020hrkt4nxu14cco	9577ab4ce19cc490c8c7a981578d53e38c7a8ca772ff6b6da5a005d007ade35c	EMITIDA	FR EH_2022	76	243483627	\N	2022-12-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.453
cmnhp08nx020irkt4loii5nks	26096b0d1337a238dd7f77b8a4cd7f8d9951cbffd94dd275f5daf53da6286f91	EMITIDA	FR EH_2022	83	262961512	\N	2022-12-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.461
cmnhp08o8020krkt4aa6tolci	b013def76a2f6297cb75f540d587cc2821d08079e513048dcff9ca51b32e5c2e	EMITIDA	FR EH_2022	82	249613018	\N	2022-12-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.472
cmnhp08ok020lrkt4acp5fyqk	dd14853301a676723edcf898a16673fb5c8eb7fa3e0c4f46e5a908bf42140e34	EMITIDA	FR EH_2022	79	248797239	\N	2022-12-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.484
cmnhp08ox020nrkt4n8itlmun	63684c4aa40d84d119b10662df578237ef295e429c0fea307c15003c1add018b	EMITIDA	FR EH_2022	78	244984883	\N	2022-12-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.497
cmnhp08pa020prkt4szsmoicy	c61fd5093f977c581d5ddf2edc2c21b4d85e69b0dcb0ace738a1d83c57b2f0ab	EMITIDA	FR EH_2022	75	251701212	\N	2022-12-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.51
cmnhp08pf020qrkt4pm73kn3a	c51a908a54109ab87d1696d0a9479417a9806e23df41a7b7a0caa9f61b12a698	EMITIDA	FR EH_2022	68	251701212	\N	2022-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.515
cmnhp08pw020rrkt48nxftdaq	01cd6a3adc88fdd405d2dcd24401e951b7af8d5b8767e11cc03d7c741fd0324c	EMITIDA	FR EH_2022	66	249613018	\N	2022-11-02 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.532
cmnhp08qc020srkt4fm2l6imm	d53e8c875206c377cde9823a13bd73cf6c4972add98f12c9d2aade6d6314063b	EMITIDA	FR EH_2022	65	252916077	\N	2022-11-02 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.548
cmnhp08qt020urkt4qbvt00ue	cddb1894bd090c8f5e882036e5dc91b767cb5fd6ab2d5391369d61b36a53b976	EMITIDA	FR EH_2022	64	270909028	\N	2022-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.565
cmnhp08rc020wrkt4we18s9da	c31c1f67e6a8c9f73bc46f3b1dc859034f1503c8730e2d8705362cb27c92bdb8	EMITIDA	FR EH_2022	73	244984883	\N	2022-11-02 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.584
cmnhp08s1020yrkt49p6frpz1	455048baac679868532410b566ca5dba0db162a8d3fcffd89b6fa5f9f5f99a22	EMITIDA	FR EH_2022	69	226804747	\N	2022-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.609
cmnhp08sb020zrkt46tv7sh7t	16967f61de373113551ebd6c603fa0bbd2d528062a845f105dc207a7ca36a1e7	EMITIDA	FR EH_2022	67	248797239	\N	2022-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.619
cmnhp08sv0211rkt4xugvgavd	8db67e9fe96b664d0a972f99f6ab989c587eb846f11dc4cfeb63d1912581e2f6	EMITIDA	FR EH_2022	72	251114996	\N	2022-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.639
cmnhp08t40212rkt4p4erdchw	0634d74988ff85ceeb86bb5331b6427dba40ca4ee0edc10df31bfd52f585ae83	EMITIDA	FR EH_2022	71	243483627	\N	2022-11-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.648
cmnhp08tb0213rkt433bq5yig	3c45141dd374514c871fa9edf44a587fc3f498eefba95b6b2c4b6b7f681193bd	EMITIDA	FR EH_2022	70	262961512	\N	2022-11-02 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.655
cmnhp08tn0215rkt46p761o3v	94ed58aba6c864b816b37094aff4cd774191a62b52c65bf33a1386dc0abacd52	EMITIDA	FR EH_2022	63	516369652	\N	2022-10-18 00:00:00	1200.00	0.00	1200.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.667
cmnhp08uc0216rkt4uo52pekf	d3f02f4bfa413d5e0d3d6fa4013215c540c1c2cb62df220695ae5af53b70a213	EMITIDA	FR EH_2022	62	270909028	\N	2022-10-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.692
cmnhp08us0218rkt455uf7dcd	992fff1fba5d534f366766af49da33b2c4572d422bcfdf2ecaeeee3c5a871215	EMITIDA	FR EH_2022	52	516369652	\N	2022-10-04 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.708
cmnhp08uw0219rkt4ga8tgnpv	a5ce4d46bd989e4c2147022604e069cb9285574a62338e4a4870ad5ae23ebf72	EMITIDA	FR EH_2022	56	251114996	\N	2022-10-04 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.712
cmnhp08v3021arkt40wf6q6dv	03e536e079dbb959b7f00ac8fa65719df1b31bd4abd17f7e0beeaf5118e217e5	EMITIDA	FR EH_2022	53	226804747	\N	2022-10-04 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.719
cmnhp08vb021brkt4yo968kt9	0b5139ae2cdaa6dc0d58c83f71a1b2bddd39bed59cc52d8cbadb282cd45d3832	EMITIDA	FR EH_2022	54	251701212	\N	2022-10-04 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.727
cmnhp08vn021crkt47psomgzy	ec4b20122e60126da49261b2055b7a1b44e7b906c98251672467954d20aa0afd	EMITIDA	FR EH_2022	59	249613018	\N	2022-10-04 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.739
cmnhp08vu021drkt4siua4rpu	9f23e0446fafa69a835c862830879d38a14a6c876c73ddbea3374faf12564c69	EMITIDA	NCP EH_2022	2	252916077	\N	2022-10-04 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.746
cmnhp08w6021frkt4xeghrjbo	6aa904a0b746f8e9836796220dc17283b0157c88f61c3840af55e0b6759935de	EMITIDA	FR EH_2022	60	262961512	\N	2022-10-04 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.758
cmnhp08wq021hrkt4ybk7ftig	77f22b99ba4030e55bae4bb5692ab065f9848e214246359476dd0b107f982463	EMITIDA	FR EH_2022	57	244984883	\N	2022-10-04 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.778
cmnhp08x9021jrkt4i6okazzj	bbf8540710f7f770cc84848a2b44aa7500768a4203fa2a8d79c1b32631cd95ce	EMITIDA	FR EH_2022	55	243483627	\N	2022-10-04 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.797
cmnhp08xj021krkt4mp5yssx2	0bf91fdd7a8fc1efb131fabc6557e02bf96b56eae80635f64c7499bce0e05318	EMITIDA	FR EH_2022	61	252916077	\N	2022-10-04 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.807
cmnhp08y4021mrkt4kr5cthot	27d8d7acfea1fee13fb30405f372a591f1410f281cffe6669f0ca12fa3d99afd	EMITIDA	FR EH_2022	58	252916077	\N	2022-10-04 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.828
cmnhp08zd021orkt410dp6unx	642bd5a9afbeccdb4c30dd714daae75aff8e5417eef5d6a0b18e7908f668cc97	EMITIDA	FR EH_2022	51	516369652	\N	2022-10-04 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.873
cmnhp08zl021prkt411keoafd	f7bc796b114dc67e32338aed7aa7e3f1c59473c84dee023b031547f6286bd6be	EMITIDA	FR EH_2022	49	270909028	\N	2022-09-19 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.881
cmnhp0905021rrkt4qo1r8dwb	66a0d36ccf877b53c6fe660a731da51cb1c31a6e47ec20456396473c9e87e0a8	EMITIDA	FR EH_2022	50	270909028	\N	2022-09-19 00:00:00	150.00	0.00	150.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.901
cmnhp090u021trkt4o40gs4h4	d270248ffabcb9f1a5cdf2a44cd1beac722351ecdb124b2944e7fabc2d5853bd	EMITIDA	FR EH_2022	44	248797239	\N	2022-09-18 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.926
cmnhp091e021vrkt4ae7rksje	86b7b149c6285e24c971299b1b2a70648f296ac1473caaa9a59ba0184959c70b	EMITIDA	FR EH_2022	46	249613018	\N	2022-09-18 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.946
cmnhp091n021wrkt40vpolk0j	2e05ed290365c5a3de0d3baf04cf508003809a8d56376e5f458ffa420f68d76e	EMITIDA	FR EH_2022	45	249613018	\N	2022-09-18 00:00:00	175.00	0.00	175.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.955
cmnhp0925021xrkt4cj1pztpj	d3a913747bed8f217524e4875f3af067c55b0b39d47e7594e788d5c8057f801a	EMITIDA	FR EH_2022	43	248797239	\N	2022-09-18 00:00:00	150.00	0.00	150.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:10.973
cmnhp094p021zrkt4zjdi2vsr	caa8d40384ab79ce727ea798d9126b763057c7d15f85ccbc21b82e1c5347297e	EMITIDA	FR EH_2022	42	248797239	\N	2022-09-18 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.065
cmnhp095y0221rkt4h7ddrv8i	72025eab4d00a4747f0c5cdf547a39a796eefe5fa2bf435d9e92c09ad8c147bc	EMITIDA	FR EH_2022	48	252916077	\N	2022-09-18 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.11
cmnhp096q0223rkt4iwnej23i	093e462ba888d27644e621dd07a720f54f10ce0b9f08daba9264db2f21b3dda9	EMITIDA	FR EH_2022	47	252916077	\N	2022-09-18 00:00:00	175.00	0.00	175.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.138
cmnhp097r0225rkt4ph6tew5m	5c9db57120a229cd48e4547212d3f3f07978c77f870d62b9f58c16194e5ac7c9	EMITIDA	FR EH_2022	41	262961512	\N	2022-09-08 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.175
cmnhp09890227rkt4wfpvnyb2	1cb0f7ecf003d4d82be4b057ca7b1d8eda282ebace67f77865b41454b6a63d06	EMITIDA	FR EH_2022	40	243483627	\N	2022-09-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.193
cmnhp098i0228rkt4nbbg9gii	12ba2aba4117e499b8a19a01840cfca112d13e533c6857a5bf85320a0cfce956	EMITIDA	FR EH_2022	39	226804747	\N	2022-09-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.203
cmnhp098x0229rkt4xufag9vv	5238fc08d0a24b9b72f2586d686f042b13c7b98ac02b2ce106401f5b8c3b5370	EMITIDA	FR EH_2022	38	251114996	\N	2022-09-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.217
cmnhp099d022arkt4nh4aeeil	35b1390a867be3fd4c8741ca9c9b7a6043626759eca8b8d3621c0e8d625a505d	EMITIDA	FR EH_2022	37	244984883	\N	2022-09-05 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.233
cmnhp099y022crkt41vdkjx2a	8db0f1a1379d0d6169e6a72562d84e7ed1b3e4423307da6d810dc3160e9bc5d7	EMITIDA	FR EH_2022	35	226804747	\N	2022-08-25 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.254
cmnhp09a7022drkt4w9gp6uc6	96835f3607a16ab43c022580048961f1d05ed479a0276342e25b58acff9d64db	EMITIDA	FR EH_2022	36	226804747	\N	2022-08-25 00:00:00	200.00	0.00	200.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.263
cmnhp09ae022erkt4u35zcnk0	628b717f897638632c7b58083f0733efac077eedca2015e56e95b54028828e9f	EMITIDA	FR EH_2022	34	251701212	\N	2022-08-25 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.27
cmnhp09ap022frkt4g5gq5pu1	2586ae019671ff0aca9f65f9c14db3749c0475cd0e75792b584081329816c590	EMITIDA	FR EH_2022	33	251701212	\N	2022-08-25 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.281
cmnhp09b1022grkt4v88epgvj	2db9380c54bb7ebed54208820273b7930c1f3b3ddbfa85a54bf3cba031a87608	EMITIDA	NC EH_2022	1	\N	\N	2022-08-12 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.293
cmnhp09ba022hrkt42t23tehi	5ee7680b3ab88816b0165bcd6b7ba858f595552bbdd9f92f241acf52daf527a1	EMITIDA	FR EH_2022	30	262961512	\N	2022-08-12 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.302
cmnhp09bu022jrkt4mve5iy1p	7b964a4493976569de519a60b5ad6fd43f88efe1b209f27c8860eef3a026a823	EMITIDA	FR EH_2022	31	243483627	\N	2022-08-12 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.323
cmnhp09c3022krkt4cdxcf9b8	c65817a98dc766265673013a901555c096067e3d8963cd7e8b20c3d6a1c22e2c	EMITIDA	FR EH_2022	29	251114996	\N	2022-08-12 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.331
cmnhp09cd022lrkt4x2p04030	ad3393ce697fd4f1f518a5a972951cabdaaaebc5d76b12482133e31db751bdae	EMITIDA	FR EH_2022	28	244984883	\N	2022-08-12 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.341
cmnhp09ct022nrkt47wy3hzpp	ac3978c77b9ea4d2a3f1cc98ef00fa43fe1d1afaffb61203c6b0c5f10d80d26f	EMITIDA	FR EH_2022	32	243483627	\N	2022-08-12 00:00:00	200.00	0.00	200.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.357
cmnhp09d2022orkt4kt2oqfmy	be165a95c75129ba4df65362f8cde1e3e0fc718c9ebc51e40711f6fcdd8a7e29	EMITIDA	FR EH_2022	23	\N	\N	2022-07-05 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.367
cmnhp09dc022prkt4vfahbyyb	c62b30923859b946858e7fb83d13df2f3ada7e9ed2201f6b558dd13ee86eef69	EMITIDA	FR EH_2022	27	264769953	\N	2022-07-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.376
cmnhp09dp022qrkt42ngvjd5g	88774bc5716088c3a2a18fd120dde5cc0e68507c892e8dbc02f7c46b6c587d57	EMITIDA	FR EH_2022	25	251114996	\N	2022-07-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.389
cmnhp09dx022rrkt4tdtavw5s	86d749b0d3118fdd63f6f4dfe0e7102cf9d2b6a2291cef8e474e47acc8850768	EMITIDA	FR EH_2022	26	264769953	\N	2022-07-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.397
cmnhp09e6022srkt4dn5hjbfx	7776fe0a432a8c02ac70df39d3233bb844bc9c7022e55a08bc4f8e514f78b662	EMITIDA	FR EH_2022	24	244984883	\N	2022-07-05 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.406
cmnhp09el022urkt4a83q5ooy	4fa3c11c1330ccf1290fd8321cbcddf1fe89fcd098063f6938205d87359d1006	EMITIDA	FR EH_2022	22	\N	\N	2022-06-01 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.421
cmnhp09et022vrkt4b0mbhqyk	e58216546c44587936dba25e91841a1e9d27cce08010b2b92bc2f8474008a27e	EMITIDA	FR EH_2022	20	251114996	\N	2022-06-01 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.429
cmnhp09f4022wrkt419o8hhs0	71a45271430dc6ab7fadadc2068d84d752d602cfc86dd78c3503638bde11acf9	EMITIDA	FR EH_2022	21	244984883	\N	2022-06-01 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.44
cmnhp09fh022yrkt4qvrtq8hv	7191e94df00b502c404dec02f9be88a9340fecd25d2f22bd1db6f17b6576fc28	EMITIDA	FR EH_2022	17	244984883	\N	2022-05-09 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.453
cmnhp09fu0230rkt43uf0r1u2	8fbc8017357aab49b48fef87616f7aa008f42a4726af1ed8c4033f1e41f09d88	EMITIDA	FR EH_2022	19	251114996	\N	2022-05-09 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.466
cmnhp09g20231rkt4fscm791r	f53fc559b6397923f8fa76fefa2b6f4585c42dc6a0857c014aa8a453d39a0052	EMITIDA	FR EH_2022	18	264769953	\N	2022-05-09 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.474
cmnhp09g90232rkt4rqjgr01c	830899d6a18f6efdf48c57e020e16fa0308a588249e3997e92aaa2e88b049279	EMITIDA	FR EH_2022	14	251114996	\N	2022-04-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.481
cmnhp09gi0233rkt4ucfe8t32	1d6f6b368d8e44885b8f5af6243db7f16ff25cbe6cc3154492d7f9317c6eb2ec	EMITIDA	FR EH_2022	16	244984883	\N	2022-04-05 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.49
cmnhp09gx0235rkt4rp3tuol6	04792b8a02d8177d1911062ad676c0782f7613089c99a526e9c52ccce0c8433e	EMITIDA	FR EH_2022	15	264769953	\N	2022-04-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.505
cmnhp09h60236rkt4ks6hpp63	a93670ec48dc7e978a2830eb92db9f8762784e7d9e6bac4d80bc705a27339b1c	EMITIDA	FR EH_2022	9	307451348	\N	2022-03-02 00:00:00	162.50	0.00	162.50	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.514
cmnhp09hh0237rkt4xh5q77cj	376fd08ad31f09136bcb16c599438b52f3e6ded48411bb822dea37a58a8538eb	EMITIDA	FR EH_2022	13	251114996	\N	2022-03-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.525
cmnhp09ho0238rkt45t7ppxyu	9071f83ab539a26f34aceee8fbd40dd6d2b15520a56293369f813b4e6dc0411f	EMITIDA	NCP EH_2022	1	251114996	\N	2022-03-02 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.532
cmnhp09hx0239rkt4bl4pxghh	63542043135a16def09aa923417759ab203b66721c6cf0bb9e06f4524fcd26ba	EMITIDA	FR EH_2022	11	244984883	\N	2022-03-02 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.541
cmnhp09if023brkt40mx4acab	f9d06906ea8b18dc8b27874171e95e3f98fb83f21fd02e29059b0301113f906b	EMITIDA	FR EH_2022	10	251114996	\N	2022-03-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.559
cmnhp09ir023crkt4dnvrurzr	b60cf2477f91a2b9ae0571a2a5c57ec81b514b8818e674755ae3aeccea00ba60	EMITIDA	FR EH_2022	12	264769953	\N	2022-03-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.572
cmnhp09jm023drkt4d3ubfq6p	f7deb7c8e419696400ae27a46d54c99be9f7be2da00f140b0612f9eb5a4f49e3	EMITIDA	FR EH_2022	6	244984883	\N	2022-02-02 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.602
cmnhp09kb023frkt4l73k5gze	5cf509a46a3831b99f6295efc0fc368f63aaf1076195e91e0fd26ecb0b0bdad9	EMITIDA	FR EH_2022	8	307451348	\N	2022-02-02 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.627
cmnhp09kj023grkt4sffig18n	1c406b1f37ffc04cd5d78322492570d41477aa6a62b46f8ca32455a4064b1264	EMITIDA	FR EH_2022	7	251114996	\N	2022-02-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.635
cmnhp09kq023hrkt4dxin1aol	a6ba89141929e3133300ff252ecaf2c66764ba741340426666ab159f326d67a9	EMITIDA	FR EH_2022	5	264769953	\N	2022-02-02 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.642
cmnhp09kw023irkt4vk2u2pa2	048439291a445752028bd3508a8783bb1e9545d22e4bf370432a0870bcd9e951	EMITIDA	FR EH_2022	1	307451348	\N	2022-01-05 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.648
cmnhp09l4023jrkt4d7l9x2qt	f6abcb7669ce719cad567fb29d846d29988acacc8e30c90247fe90979f990990	EMITIDA	FR EH_2022	4	264769953	\N	2022-01-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.656
cmnhp09lb023krkt401yuzw34	bc90c9346c814b47d636fad25317ae34f62b029be9e11c735fb8aafe0e5f0d85	EMITIDA	FR EH_2022	2	251114996	\N	2022-01-05 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.663
cmnhp09lj023lrkt44mtch0x1	1ca9f453e0b9ccbcaaf92e5150f50728e37d2aa8e2f5a14456834bf3912b2067	EMITIDA	FR EH_2022	3	244984883	\N	2022-01-05 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp08jw01zxrkt4airoy563	2026-04-02 16:32:11.671
cmnhp0dff023orkt4pejmcoff	88af2deae1d5f19f52bf7562557c8852c5e9c71c7dd9090fcff0ab20559d2c30	EMITIDA	FA EH_2023	1	509950540	\N	2023-12-28 00:00:00	30000.00	6900.00	36900.00	Fatura	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.635
cmnhp0dfp023prkt4o81j7ich	1f57be7a3f9d544b665c1e0516853331938c2bfd1b5df4b99dd9ab148956720d	EMITIDA	FR EH_2023	115	252916077	\N	2023-12-21 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.645
cmnhp0dg5023rrkt4ozr3xwf6	28cb576d75c9b73fb5bf9d5c95534291b953269f8e02b84cf1e0d421ba1c66be	EMITIDA	FR EH_2023	117	262961512	\N	2023-12-21 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.661
cmnhp0dgo023trkt4gcwqx60e	dfb923bc0120636aed516f00abf9297a548166fa84d557dde17dcdef3d92c1df	EMITIDA	FR EH_2023	116	234850876	\N	2023-12-21 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.68
cmnhp0dh3023vrkt4bxp2m5he	760a321410a3ab79249769cc86fe9a33fdd422efedd0a0fab6e9e1614d75d0eb	EMITIDA	FR EH_2023	112	248538446	\N	2023-12-21 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.695
cmnhp0dha023wrkt4ij7ukvne	7bb99d6b2bb14e367cde6910c4ffbe3bff1c9b827b19f527047fa4a2319a0353	EMITIDA	FR EH_2023	111	248797239	\N	2023-12-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.702
cmnhp0dhl023yrkt40is5k8gj	f6794577fb61875ca5048648066b0170502f4581920e0a31e0cd49738b208c9d	EMITIDA	FR EH_2023	110	244984883	\N	2023-12-21 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.713
cmnhp0di20240rkt43e0rs0iu	2ac23b0bad824e950a853822eb62dd2820a995c524025db96cdba3ecdcda29e0	EMITIDA	FR EH_2023	109	251114996	\N	2023-12-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.73
cmnhp0dia0241rkt4j3e3zdbo	710deaa1d74c40edf4bf9479142b4bea661329f2cbda5aff3de2122336f0da5e	EMITIDA	FR EH_2023	114	270909028	\N	2023-12-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.738
cmnhp0diq0243rkt4lxijx7nk	e24201e4a9b1754f4fe39ce564eb6188155e312f410086cf6600d5dc3e4615a3	EMITIDA	FR EH_2023	113	248538446	\N	2023-12-21 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.754
cmnhp0dix0244rkt4p9l3hpmz	17580fb12720152a5777dc5a7c00ee4c769adfb9b6796761c2825250c78f5fcb	EMITIDA	FR EH_2023	108	226804747	\N	2023-12-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.761
cmnhp0dj50245rkt45s8howpa	33481383fe61a9a499359311ade3c9cda374cb73499582a8dfe0cb1a485c99b2	EMITIDA	FR EH_2023	106	516369652	\N	2023-11-20 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.769
cmnhp0djc0246rkt42bing7tr	c44de6379e0b737831b84896189bb73e92a7e9e204e939c968d0e670c8af3451	EMITIDA	FR EH_2023	104	234850876	\N	2023-11-20 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.776
cmnhp0djo0248rkt4qw6m36t3	3398473f1316843968d4a9bd50fee7e2c7be8344051bf25430edf33a46ea1a4a	EMITIDA	FR EH_2023	103	252916077	\N	2023-11-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.788
cmnhp0dk1024arkt44i2pym32	477ac455baf9538502d5b7b2424996ab5ea53fe91523c4153d86e3ff0f2b5461	EMITIDA	FR EH_2023	102	270909028	\N	2023-11-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.801
cmnhp0dkm024crkt4c5xx1uzu	238fcff82b21228d435903c11a932b718d7c336731d46ff6cf9139b174cd7315	EMITIDA	FR EH_2023	99	251114996	\N	2023-11-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.822
cmnhp0dku024drkt4bm7ekvne	864dc8976365250d3282ee5833d2260e035c831806f17bbcecf5c9640985397a	EMITIDA	FR EH_2023	105	262961512	\N	2023-11-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.83
cmnhp0dlb024frkt4xipawdx5	1838019fe41d34cc7adb7b82643301c24c6be9514bab9ba48106ae0d210e7252	EMITIDA	FR EH_2023	101	248797239	\N	2023-11-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.847
cmnhp0dls024hrkt4a092vd9v	88503d5ed31911a322a5ae26c3832e85b1645f038f114419269ac5c420e96c91	EMITIDA	FR EH_2023	100	244984883	\N	2023-11-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.864
cmnhp0dme024jrkt4otpxjj01	5f7d5d155f0cc4ab2a80f83cebca4e52a3fe4a8000e16225ede9e764d8c35a08	EMITIDA	FR EH_2023	98	226804747	\N	2023-11-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.886
cmnhp0dmn024krkt46ftj2o9a	0b578da2d45a0749eb82116f519ea78a364369da71d4d5be3451d6e961eb4c68	EMITIDA	FR EH_2023	107	516369652	\N	2023-11-20 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.895
cmnhp0dn0024lrkt4xux5yn9e	6ec3d3278a9663d82dd96eca962a70932259bf838cfb820eb84814f144894eed	EMITIDA	FR EH_2023	89	226804747	\N	2023-10-19 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.908
cmnhp0dn8024mrkt4floy7k3m	816c302c2f94fd91a12d9c2190a35f2d0d58d0f3809b84c9529cc6bbe27a91da	EMITIDA	FR EH_2023	93	248538446	\N	2023-10-19 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.916
cmnhp0dnk024nrkt43me63ili	1fe912cf8256f3e39d0db21afc0ba9f5a6ce370405e479871469f3448e180cb3	EMITIDA	FR EH_2023	94	270909028	\N	2023-10-19 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.928
cmnhp0do5024prkt4mvbd3qff	63e22ee810cc36787629d163b656677153d39a2d912068b3c23813fe70a3222b	EMITIDA	FR EH_2023	92	248797239	\N	2023-10-19 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.949
cmnhp0doq024rrkt48rh2hcjy	b70e579c5ba134667ced56db771b8ffd3bcc6dbff456c7f494e272e53880bf36	EMITIDA	FR EH_2023	90	251114996	\N	2023-10-19 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.97
cmnhp0dp0024srkt482kgk0r4	2af6255e9168fcf11bb83f389575d24c0904c988604880b87f4293e0360c8822	EMITIDA	FR EH_2023	97	262961512	\N	2023-10-19 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:16.98
cmnhp0dq3024urkt46yyq7sdp	427275877c63635ab68c73fa326a6e90b567bfe08241b9347b0d5746ec4ac84b	EMITIDA	FR EH_2023	96	234850876	\N	2023-10-19 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.019
cmnhp0ds9024wrkt4jbabtktm	c0c03c3b67afdf44d1363a75a925d563af3036e3c9b178c5df7d0180c643045e	EMITIDA	FR EH_2023	95	252916077	\N	2023-10-19 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.097
cmnhp0e1w024yrkt4ymjbj6sw	65ed18e4363f5e62212796575059020a0397193a361d20ee35220f58fe58ba3d	EMITIDA	FR EH_2023	91	244984883	\N	2023-10-19 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.444
cmnhp0e2f0250rkt4418lykgq	6b9feff287f2cc6f96beac1e2104cd6bbef5266dcbb20a397c4804eb6633c54b	EMITIDA	FR EH_2023	86	516369652	\N	2023-09-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.463
cmnhp0e2n0251rkt45e2u10ti	cd4f7337dd3776add975a1b098be97fb54fde787ef53426144304b394534a2ae	EMITIDA	FR EH_2023	88	516369652	\N	2023-09-13 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.472
cmnhp0e2u0252rkt4pexbbal7	f3a6f5d9d250b653b0f16729776e8ef9326ceb6e7408d4a79ce69fb369be5a81	EMITIDA	FR EH_2023	87	516369652	\N	2023-09-13 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.478
cmnhp0e320253rkt4e1o3gkq9	0ea048e170ea08147a3c0df74c38bb9af2e8b1837e72f13208c3610cfd600c00	EMITIDA	FR EH_2023	77	226804747	\N	2023-09-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.486
cmnhp0e390254rkt4l0gju368	17d33f6f8fd4c0148f757a509ad8273029bf8637e5a3d62242945916103b67f6	EMITIDA	FR EH_2023	85	248538446	\N	2023-09-07 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.494
cmnhp0e3f0255rkt4m0olw9n2	3eb25e728f6542d30dce7fd7d3786146863f8721549b3211ea527a427aaa4afc	EMITIDA	FR EH_2023	80	248797239	\N	2023-09-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.499
cmnhp0e3w0257rkt4s3lewquv	ab8a45f09eef92da3172d969fb3ea9915d9bc44b2a31d7cd8c77e6237b0c055c	EMITIDA	FR EH_2023	79	244984883	\N	2023-09-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.516
cmnhp0e4c0259rkt4j2k3wq7e	a8930b1e2dc8c0556d3656d4505d05f20c271266634a60420b3cc290b3571c4f	EMITIDA	FR EH_2023	83	234850876	\N	2023-09-07 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.532
cmnhp0e4r025brkt41hq9txq2	7bc287e0288f0e7e7fab9b57a6f9f628e2ee4eab4b24ec003a4f7953534b408b	EMITIDA	FR EH_2023	78	251114996	\N	2023-09-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.547
cmnhp0e4z025crkt4ilfwtvvo	327cf95ded34631fae67c83aaf4a041232be5132467ef2e276f6d3ed82e43d40	EMITIDA	FR EH_2023	84	262961512	\N	2023-09-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.555
cmnhp0e5c025erkt4dqeo5g0x	bdefddc9a5cefbe9c669a293967b432329974f82656a748af8521e6d4e8546ad	EMITIDA	FR EH_2023	82	252916077	\N	2023-09-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.568
cmnhp0e5q025grkt4t4hzcjhz	90f81aa99602d7580b08cb42a01dbe18087f015a2e0640689d7e27bbe6c8008d	EMITIDA	FR EH_2023	81	270909028	\N	2023-09-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.582
cmnhp0e64025irkt41t25yc2x	d45c6a03901d8a5a329a3725d09d549cc392f1d01d4b2b440606659bae3423d7	EMITIDA	FR EH_2023	75	248538446	\N	2023-08-23 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.596
cmnhp0e6d025jrkt4q4tyyo10	9a66630a3e07de3db63226faa570b889fa28b3c6e5744a6145f460ef19392e8a	EMITIDA	FR EH_2023	76	248538446	\N	2023-08-23 00:00:00	108.00	0.00	108.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.605
cmnhp0e6l025krkt4g9vg16oc	11efc744ce1cfff1093e009393697788b66d57a0801172c54f5a117a09dce9a6	EMITIDA	FR EH_2023	74	248797239	\N	2023-08-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.613
cmnhp0e6y025mrkt4fed6eirw	1d402a6fa6297f1ce4bd9d811f37726891f0f9ece05aea589cc20caddd18d18d	EMITIDA	FR EH_2023	73	270909028	\N	2023-08-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.626
cmnhp0e7o025orkt4mmqd6nl5	29bd11629564f33c17b13a1baef09b7f18c381e528d58e25787af243880fb330	EMITIDA	FR EH_2023	68	244984883	\N	2023-08-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.652
cmnhp0e84025qrkt4ob72rhty	59686a39b3bc7e8e0e768d49f7053d3663f4172e8afc521b10633aa2d5e101df	EMITIDA	FR EH_2023	67	251114996	\N	2023-08-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.668
cmnhp0e8d025rrkt4dmaz4ekc	4432fae46c243dc9db402374f66da71dc0c364f773639e5fc84c6b74da5ba754	EMITIDA	FR EH_2023	66	226804747	\N	2023-08-07 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.677
cmnhp0e8k025srkt403ob305l	e235a4c2f93359069ad4bd1794e9d03a2a29de866de5ac7c69538068194d8cb9	EMITIDA	FR EH_2023	72	234850876	\N	2023-08-07 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.684
cmnhp0e8y025urkt4je9cja5g	0b0167d92fa2c10ca4a3dbdbe888a86348c50323d247d5189435d59175617bfd	EMITIDA	FR EH_2023	71	234850876	\N	2023-08-07 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.698
cmnhp0e9d025wrkt447yfca4y	d72eaa98fa85d7b16eb07b17eb45f35c0efc85228178b2b796c8039a412fb0da	EMITIDA	FR EH_2023	70	262961512	\N	2023-08-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.713
cmnhp0e9t025yrkt424hazt0k	868c551686ed9529434c9b7e9d93564f7dcb90c8af7d59815bcc049e11ed8161	EMITIDA	FR EH_2023	69	252916077	\N	2023-08-07 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.729
cmnhp0ea60260rkt4vlxmvqhr	56a240f835e6dbe0a9cad46c2d0287b8c221cb474686878dc854c420d76cc579	EMITIDA	FR EH_2023	65	248797239	\N	2023-07-24 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.742
cmnhp0eai0262rkt4q6uwz3ji	a2a7cf7a52cdda0259e5894e137ef030bbc4c5b37f8ee9a5f5727b10f393984e	EMITIDA	FR EH_2023	64	270909028	\N	2023-07-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.754
cmnhp0eau0264rkt4puni1zor	b1a37cd91d4a80701340b12f20fbce94c95ee0c85cc040275f58822cc9f53582	EMITIDA	FR EH_2023	61	516369652	\N	2023-07-17 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.766
cmnhp0eb20265rkt4s7i3zi4n	3400886d2562b950f93e81ee63d09f3f6b28a2c59e2fa2d3c2bf468482e39ad5	EMITIDA	FR EH_2023	60	244984883	\N	2023-07-17 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.774
cmnhp0ebe0267rkt42jms5zau	3aa736642da045f9b7a5d36a1fbb998a3b9ec30b39aae5a110adc34a39972c60	EMITIDA	FR EH_2023	63	262961512	\N	2023-07-17 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.786
cmnhp0ebt0269rkt4gm1atrf2	86de64f72c08242293c7653852d6fcef828dc53bd8713d6811888e01beee6ae6	EMITIDA	FR EH_2023	58	251701212	\N	2023-07-17 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.801
cmnhp0ec1026arkt4j2q6e8kx	89e434250e26e149d4d50ae3c8a51df315e097d0a5a853e9622b196d1a3b14d9	EMITIDA	FR EH_2023	57	226804747	\N	2023-07-17 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.809
cmnhp0ec7026brkt488l1p0c8	9279d56aae4bd8e91b38cc65f782f22e8a386c3b94b16d0fba8727cae3da4ecc	EMITIDA	FR EH_2023	62	252916077	\N	2023-07-17 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.815
cmnhp0ecl026drkt4azizow59	258af1d4cd1492f84a2b737588ea40db43b3b7aebe600a0b7851dd565e478da8	EMITIDA	FR EH_2023	59	251114996	\N	2023-07-17 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.829
cmnhp0ect026erkt4fhpi5clb	0ca1117d7f975878058f88ee7c78385ebdbfcef100f1631c52509e9e6d2c1d69	EMITIDA	FR EH_2023	56	516369652	\N	2023-06-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.837
cmnhp0ed1026frkt4oijbdc10	e75b83ec2c1da8599422c5b8a6601d722a06dd51862cb24186eb9bb36eb9bae7	EMITIDA	FR EH_2023	53	252916077	\N	2023-06-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.845
cmnhp0ede026hrkt4jatn4oy6	399a2348e0156f0d1776fc615a72b56d4a6fa905e955965b1ef5baa7eaa0b28b	EMITIDA	FR EH_2023	49	251114996	\N	2023-06-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.858
cmnhp0edj026irkt4kyqy6itj	8cdd6b71457cff93069daf92ad974a54061a503d6e2048123e79f6ce34331bc5	EMITIDA	FR EH_2023	48	243483627	\N	2023-06-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.863
cmnhp0edq026jrkt4s9vfwh0c	79a2f9c10916c4c890d377069bee7d0b8d4738e15d4e422b8c0d0f65cc9f9a0d	EMITIDA	FR EH_2023	54	249613018	\N	2023-06-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.87
cmnhp0edw026krkt4nnea0v9d	5d88a94dd68e260cf363061c9fd479dda719cc179ad87be883f8a91210a7c3c0	EMITIDA	FR EH_2023	52	270909028	\N	2023-06-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.876
cmnhp0ee8026mrkt42jlgngq4	83d4bdd8e69ef0ecf93ee06e7b18ca1730f813bc25420b2830f7a080936c8354	EMITIDA	FR EH_2023	51	248797239	\N	2023-06-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.888
cmnhp0eem026orkt4mz8jg8ty	5823b81a0d66a26e23d9dafb0b50cdd937978182afbced2362c6222714bfd084	EMITIDA	FR EH_2023	50	244984883	\N	2023-06-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.902
cmnhp0eez026qrkt4nze6xzvn	f142c8b5e93969f2f3ac41cbf74603e976e8561f8d99521104d31f36ae42c693	EMITIDA	FR EH_2023	47	251701212	\N	2023-06-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.915
cmnhp0efi026rrkt4vhnun3iw	3a85446e1b94d4db18af2a02601a44b6ae11106413790c37e1f523b6f9147980	EMITIDA	FR EH_2023	46	226804747	\N	2023-06-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.934
cmnhp0efz026srkt4hmcyw986	801eca2cf81ddd9d3f6b66df26cac060134bc4dc72b23d372a01731f5307e7a3	EMITIDA	FR EH_2023	55	262961512	\N	2023-06-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.951
cmnhp0egk026urkt4c71cgzui	375d510c8b8250c5347802421f33b7c72d86d1f5f4c69f77560ff98134719a44	EMITIDA	FR EH_2023	41	516369652	\N	2023-05-08 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.973
cmnhp0egs026vrkt42gklrrp9	f818999ae648c767a8b7f3edff8a402abb0bd13149868201a4672c8f61281ebf	EMITIDA	FR EH_2023	43	252916077	\N	2023-05-08 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.98
cmnhp0eh5026xrkt4qdoytfsr	737dbced456cdc9739adcdb68718a4794c439d6f057a63942583976bc0611508	EMITIDA	FR EH_2023	39	244984883	\N	2023-05-08 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:17.993
cmnhp0ehk026zrkt45cxrm1lr	5fb4723694fe1e6ba6ec76b5bad1fb934bcaead850180ec7aa91157b938472ca	EMITIDA	FR EH_2023	45	262961512	\N	2023-05-08 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.008
cmnhp0ehy0271rkt4pn5job34	206d8275f84755cfee9989372586719060db57709a21d31b2de62b915e6b795f	EMITIDA	FR EH_2023	40	248797239	\N	2023-05-08 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.022
cmnhp0eid0273rkt4e8l6yjqa	0c53703c0d73d2c00845c52ece87f1098f2630b845b3e8d83419cdb22cd567ec	EMITIDA	FR EH_2023	38	251114996	\N	2023-05-08 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.037
cmnhp0eim0274rkt4x5xw4wgl	2054689cdf6682c537766b1a63f4534ba6f7f355af16a6427cbb705ad1d4cd29	EMITIDA	FR EH_2023	35	226804747	\N	2023-05-08 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.046
cmnhp0eiu0275rkt45r8l0m09	240170694bbb1ab31045259b034d1f9cc0dcd1b73cf58fb305b1ce853e7ae1f3	EMITIDA	FR EH_2023	44	249613018	\N	2023-05-08 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.054
cmnhp0ej10276rkt4rb69qnxk	d3f10189513c11f591c266903cab5445bc67fc5a05ab7411a3cfc050c9009e0c	EMITIDA	FR EH_2023	42	270909028	\N	2023-05-08 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.061
cmnhp0ejc0278rkt44dsns9hu	d27e14a37e00ef72558f7bb2d8e39b137d216665eb180a6748299079d265f604	EMITIDA	FR EH_2023	37	243483627	\N	2023-05-08 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.072
cmnhp0ejh0279rkt49swu611p	77622528c9b54250353cac6c39310e7813590d92962bd626743fb9c2659b3cb5	EMITIDA	FR EH_2023	36	251701212	\N	2023-05-08 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.077
cmnhp0ejm027arkt4xupn0bml	dee28534e6c627baffb90f60c2445054801ddb05b1e648abf182adc96e46744f	EMITIDA	FR EH_2023	34	516369652	\N	2023-04-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.082
cmnhp0ejt027brkt4hi5s94sq	d0c926223b0570f6148ecf84ee693a3c6acf178d07813aed14cb9e847046e690	EMITIDA	FR EH_2023	24	226804747	\N	2023-04-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.089
cmnhp0ejx027crkt4vf6h89qy	dcf905186021d06add0981867ab254e249a14d222dfbb09a2fa32d55774d9168	EMITIDA	FR EH_2023	31	252916077	\N	2023-04-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.093
cmnhp0ek9027erkt4tt9t40tc	e28939bd6035eace65e98f72bc1014a095aca4c795b4a6e37b1a448069cddee5	EMITIDA	FR EH_2023	27	251114996	\N	2023-04-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.105
cmnhp0eke027frkt4gl6je1sn	bbea74464e55c9b737c74f9bfc2a1cc2c3054fda35e41e9fb7801987eaad52fd	EMITIDA	FR EH_2023	26	243483627	\N	2023-04-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.11
cmnhp0ekj027grkt4yy37wzay	53237fa7d76c94add4ca25229878f339ed4990a6c2fc64e6ba8f0dda24b8bdd2	EMITIDA	FR EH_2023	32	249613018	\N	2023-04-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.115
cmnhp0ekr027hrkt4xgimz8vp	ca68ea92d1f957194024492e0231e7a5e6318d827754b1d83b3b25d7517d5387	EMITIDA	FR EH_2023	29	248797239	\N	2023-04-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.123
cmnhp0el5027jrkt4rbqap7jq	37f317ddfac97d977472c2c4d09765d8d1450bf9c138dd9d02b77337d3c8474b	EMITIDA	FR EH_2023	28	244984883	\N	2023-04-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.137
cmnhp0ele027lrkt4xya0wle7	d94c8225ff1649ee29f29f93291ae759a488a7524c8027080959c861dd609ac7	EMITIDA	FR EH_2023	33	262961512	\N	2023-04-13 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.146
cmnhp0els027nrkt48wrz5gxn	dd5a951e804420c55d91c16749879a71ce97de3bf3358258be616f1429a9aaf8	EMITIDA	FR EH_2023	30	270909028	\N	2023-04-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.16
cmnhp0em5027prkt47j4zk2zq	9eb116dae1980dbda0a2bc338e8bc0e4241c649c06ae5107b905ad9da4f5b1fa	EMITIDA	FR EH_2023	25	251701212	\N	2023-04-13 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.173
cmnhp0ema027qrkt4ckci45jq	c6c5f0d1fed0677708a8869936eebe47ed93913f4592001eb5240902b16aab03	EMITIDA	FR EH_2023	20	270909028	\N	2023-03-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.178
cmnhp0eml027srkt4hueo9atu	016637b8af54079c91afd6fca779b6c80e23d0691e6fb9877326cb492213038e	EMITIDA	NC EH_2023	1	270909028	\N	2023-03-20 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.189
cmnhp0emv027urkt4f9jsmb6v	d8854cb728bfce6c89a9aee1fdd85b30ecb42617f413c2ee37d02e9e0970af0d	EMITIDA	FR EH_2023	22	249613018	\N	2023-03-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.199
cmnhp0en4027vrkt4f322sgmn	1a5231e7e3ca9afeb6eb2d47242399a79ac00d5cb4519ca7c897a6d0b3fbd59a	EMITIDA	FR EH_2023	21	252916077	\N	2023-03-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.208
cmnhp0eng027xrkt4p8no8b1b	083bdb4d536bd74f9f834fd54123f9f6ef52c43bc49fb30ea09fdf50f6af552c	EMITIDA	FR EH_2023	19	270909028	\N	2023-03-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.22
cmnhp0ent027zrkt4jvz19a10	5663c1029146a8cda5fcfc9c28169024f232c99b6f701edc5119810721ed03b8	EMITIDA	FR EH_2023	18	248797239	\N	2023-03-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.233
cmnhp0eo60281rkt4wxd1n4p2	d1376a9f3d43addd04e648eaf22c2abd0f3f09af628fd66de1f413e4f947c007	EMITIDA	FR EH_2023	17	244984883	\N	2023-03-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.246
cmnhp0eok0283rkt4afrthzox	a426b3cfe86863367d05101d3409c25347df38f3276ceee4e99df8ff1bf99d30	EMITIDA	FR EH_2023	16	251114996	\N	2023-03-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.26
cmnhp0eos0284rkt4b4e3g7tb	cc4bc730a7838a5c908ca740a9140d3f0a5997b33a222e2bfbdff51ea809ae54	EMITIDA	FR EH_2023	15	243483627	\N	2023-03-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.269
cmnhp0ep30285rkt4imruh9zu	671165988b0bddad5589d0c5d4ad8b8d5ee57b694d479776c838edafb954fb4d	EMITIDA	FR EH_2023	13	226804747	\N	2023-03-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.279
cmnhp0epg0286rkt4oc0kmjnl	d79bd6361839ea0b9bcd476a2052712208d9b7ba4a0a4ba51a9d523e20db4803	EMITIDA	FR EH_2023	14	251701212	\N	2023-03-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.292
cmnhp0epp0287rkt4d559tdsv	74dc2f6f4e1de545267b46b4d382bd908a90bb3750dd58740c11fb71f4dc7add	EMITIDA	FR EH_2023	23	262961512	\N	2023-03-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.301
cmnhp0eq30289rkt48tixc1pj	223e08396c46abd6a31ff7719303a862a8aefa0372c4ffd7e8c9bb2c07f70585	EMITIDA	FR EH_2023	12	516369652	\N	2023-02-15 00:00:00	600.00	0.00	600.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.315
cmnhp0eqd028arkt4idu33kmx	f40012f85eb31c76c881cd83df8edc64b8625cb854d96036d97f96481cd5876e	EMITIDA	FR EH_2023	2	226804747	\N	2023-02-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.325
cmnhp0eqk028brkt4po0lswpn	9a69f8b573406d3e69275a8462bbe5d4cffc65d5a81c50e66d95a0797645738b	EMITIDA	FR EH_2023	10	249613018	\N	2023-02-14 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.332
cmnhp0equ028crkt4w10cigvd	7945138ee972e1f1db54b9c2c6601ac64ef0412c16b6908eac99ece19985eb4c	EMITIDA	FR EH_2023	8	270909028	\N	2023-02-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.342
cmnhp0erb028erkt4sp44sk83	d93ef0461802793049608e22ce66fc7bf3bfb6e687c81ee89e5eff8613d90f41	EMITIDA	FR EH_2023	6	244984883	\N	2023-02-14 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.359
cmnhp0ero028grkt4oqcd298d	37c2fb6752ed230ec64f9214f7b750ab052df095b3ba6ed06c588052ccf15cbc	EMITIDA	FR EH_2023	5	251114996	\N	2023-02-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.372
cmnhp0erv028hrkt4be4au4sa	b07ab27901d42a47de1755e006e9fcc93bdcea62b68427d26638b470c5911719	EMITIDA	FR EH_2023	4	243483627	\N	2023-02-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.379
cmnhp0es3028irkt4n132c9nr	f2e8de0d63bb894acf9ef6deabfc0ea8c83fce7d6606edb08ea3e0d4edba087b	EMITIDA	FR EH_2023	11	262961512	\N	2023-02-14 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.387
cmnhp0esg028krkt48db36bwr	62c0e2f61194edb00d36736f4db2cd77af5caa2e4526a6861f03312100c2eb3f	EMITIDA	FR EH_2023	9	252916077	\N	2023-02-14 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.4
cmnhp0est028mrkt4gxvimxci	c1d192d907797e8527d4c9a0f4d38ef18d3f6bed3aed9f0a354213a6e797875a	EMITIDA	FR EH_2023	7	248797239	\N	2023-02-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.413
cmnhp0et8028orkt4argta3j7	db0d7ad0a734dabb1b3ec1dbefd77b533286f0ba1ba1f3a2a876314542d47c1f	EMITIDA	FR EH_2023	3	251701212	\N	2023-02-14 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.428
cmnhp0etf028prkt4lb0s431v	c640644e20211ec49b74bbeb108acdd42a96a2d996e9035c5c7a463f4e6b910b	EMITIDA	FR EH_2023	1	248797239	\N	2023-01-03 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0df5023nrkt4caowg0x2	2026-04-02 16:32:18.435
cmnhp0hzy028srkt4ro8gq11w	ae8a7214f4d522990b7803bb2fee190ebe490849b46211f41876c00f272ca913	EMITIDA	FA EH_2024	99	255497393	\N	2024-12-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.558
cmnhp0i0c028urkt440qr0f8x	18c5f29aae6d5e0d802b57c2669cf3e400ed65402df68363c43b8deacdbb5812	EMITIDA	FA EH_2024	118	262387085	\N	2024-12-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.572
cmnhp0i0s028wrkt4wtq67izl	01d691d22e0ef3bcd5b4f2c21c09af9cd212c11366a43780c6b6589c390336a4	EMITIDA	FA EH_2024	103	258449233	\N	2024-12-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.588
cmnhp0i16028yrkt4dujlij4x	e713d9d445140ed030f4d75246700c3b01d5d4e3ed505d368e5c68c161df9f3b	EMITIDA	FA EH_2024	102	256125627	\N	2024-12-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.602
cmnhp0i1g0290rkt4aexrxzu0	7b43d79578663ffe6a15c59bcb74544a0e05c467628861aac2dcd3b73e8810c3	EMITIDA	FA EH_2024	120	267439130	\N	2024-12-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.612
cmnhp0i1r0292rkt4q5b3hcpo	67e659e1180681c85227448cbc5c62fcc362920cca0e314f17d3efcb125b5934	EMITIDA	FA EH_2024	119	258836989	\N	2024-12-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.623
cmnhp0i220294rkt4wkcgwc52	53b7f69b774730655f53bb994aa0c6e698c5544392fd09e750deecac6985ff34	EMITIDA	FA EH_2024	101	266277055	\N	2024-12-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.634
cmnhp0i2b0296rkt41e9p16a0	f118dee1665b48f3fca28c5e566190d1ad70136ed03a08f446b5701778a17c04	EMITIDA	FA EH_2024	107	252916077	\N	2024-12-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.643
cmnhp0i2r0298rkt4356neww2	4bcd1b2b44ae3401820eed120ba0324568ae3defb0634e505894a8540665b110	EMITIDA	FA EH_2024	111	259676136	\N	2024-12-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.659
cmnhp0i3f029arkt4dwl0wbxo	f75f155498aa9ec57ac7a2d8ae694df469fe5307dfd705e3b9456702ac491c4c	EMITIDA	FA EH_2024	110	257665072	\N	2024-12-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.683
cmnhp0i3t029crkt45kgpogs9	210ce3962c2262972261a929877d2b1342fdf0f6f658bdd2c97b9fcc8723cf15	EMITIDA	FA EH_2024	116	253278716	\N	2024-12-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.697
cmnhp0i49029erkt40oktys89	3afe8853389448165e87293b272a140996ea8bd4e61c0a2c84cc696967dd18be	EMITIDA	FA EH_2024	114	257675841	\N	2024-12-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.713
cmnhp0i4m029grkt4xjj0ngs9	418a834fadcba07d8bc68a3ad8869a9a085fbb5a9eaafde9341dafb243be9e45	EMITIDA	FA EH_2024	112	255364962	\N	2024-12-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.726
cmnhp0i4w029irkt4x06t4to2	45d16bc7a2b2e64613f53c35d1caa42330b96a86181a9e805196789b2f57f001	EMITIDA	FA EH_2024	109	234850876	\N	2024-12-22 00:00:00	375.00	0.00	375.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.736
cmnhp0i56029krkt4wddjew7g	1bfea812bbbbcc8f14091e426186c02659672f74c5b57badf48144f3eb803543	EMITIDA	FA EH_2024	113	223482900	\N	2024-12-22 00:00:00	80.00	0.00	80.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.746
cmnhp0i5i029mrkt4hdrgu2v0	9f5ebf2be9d562e19d16a3aad17d75d5571d9fc5879186214b36cc3d493388fb	EMITIDA	FA EH_2024	100	261803310	\N	2024-12-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.758
cmnhp0i5r029orkt4gzf2vf4l	28c17a6dfd2c1da5daa99784d8deae9fe3cdc2673876539bb3d6e38ce3876f36	EMITIDA	FA EH_2024	106	248797239	\N	2024-12-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.767
cmnhp0i62029qrkt4wa5691qf	a8e15fca8fb912f0fb99408b07b42d553329673db35f729df36f46df8010a271	EMITIDA	FA EH_2024	105	262961512	\N	2024-12-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.778
cmnhp0i6g029srkt4jz48ipnf	01d3228ef7b64c455429189ddab7411569f23104afbb2c5fbb1ed2b0e221da6c	EMITIDA	FA EH_2024	104	244984883	\N	2024-12-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.792
cmnhp0i6u029urkt4z2e8s4re	3b29fbfc25fc9e5b5a59da575fcc0db4f8e74a5a43d21b0db1c774b99fcf61b1	EMITIDA	FA EH_2024	108	270909028	\N	2024-12-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.806
cmnhp0i7k029yrkt4wfqc3pz1	80a392b44027c7c900cbc436aa50cbed3745b59f4d2edb3468beb4cfe41cf819	EMITIDA	FA EH_2024	95	253278716	\N	2024-11-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.832
cmnhp0i7y02a0rkt4rva4af58	c40710a9267d62614b632f9a0f570fab2113541eb93206501d0c0ad1ab2094fa	EMITIDA	FA EH_2024	82	270909028	\N	2024-11-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.846
cmnhp0i8d02a2rkt4tgop7yqj	a1c735ccf1d6ed1d1558a0d641ad280c760234626555acf4e38737a1d0e159b2	EMITIDA	FA EH_2024	92	256125627	\N	2024-11-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.861
cmnhp0i8q02a4rkt4aimfbcwr	e7c7679fc169af9d9eec5556859abdaef22d9220db29886630410609d68cb019	EMITIDA	FA EH_2024	94	267439130	\N	2024-11-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.874
cmnhp0i9202a6rkt4214gfeb5	c46bdbd92af4dffb6535388158e763501821344e0e0ff93a63597e17d8d45fb6	EMITIDA	FA EH_2024	93	257675841	\N	2024-11-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.886
cmnhp0i9f02a8rkt4y17fzcgw	105422d6eac99c4f073ad9a38773cb86bc228149aa86c03840dfbec152c24724	EMITIDA	FA EH_2024	88	255497393	\N	2024-11-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.899
cmnhp0i9t02aarkt48ewi773s	6ababdbad17d9318b9a1684abb4c88e0fed4c608a89669119ea1193699740dba	EMITIDA	FA EH_2024	87	255364962	\N	2024-11-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.913
cmnhp0ia502acrkt442z4spgx	5edd7af93fdbd940c10f7855b0aa1119ce360c6a821434f02792138bdccbfa22	EMITIDA	FA EH_2024	83	234850876	\N	2024-11-22 00:00:00	375.00	0.00	375.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.925
cmnhp0iah02aerkt4j9qo29j6	f115723f8cc5420a14d103e1e8b7a38feaf8bc8968998d18e0127014e41805cd	EMITIDA	FA EH_2024	85	257665072	\N	2024-11-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.937
cmnhp0ib302agrkt40dyj8uhh	7b16f2162f1c464b1a8c99733f1df6189d75c0805b61128b2de795ffd07c0d2a	EMITIDA	FA EH_2024	97	262387085	\N	2024-11-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.959
cmnhp0ibx02airkt4vefq37rw	d2d4c37a8e830632c954100e12288dd0dc00bfa1fe9587e461771ea49e79be2c	EMITIDA	FA EH_2024	96	258836989	\N	2024-11-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:22.989
cmnhp0ich02akrkt4s92j148f	874933dac2033ec02bf5ba06737c37baeb3fdaba760464a3c1ecee14471c0b14	EMITIDA	FA EH_2024	89	261803310	\N	2024-11-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.009
cmnhp0id102amrkt4iqu0focr	a1b85d346fcba7183df8814c201209861820023bfb7f9f20c142fb5347454a98	EMITIDA	FA EH_2024	90	223482900	\N	2024-11-22 00:00:00	80.00	0.00	80.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.029
cmnhp0idv02aorkt41ugnspgv	e40155ec67f1b242b614129cca63d894d154883d3612ec46b9dc36369184e968	EMITIDA	FA EH_2024	86	259676136	\N	2024-11-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.059
cmnhp0ied02aqrkt4vef0d927	9fac8d04cebe5209efa453c3f0c85a482b98ad2dbdec7d7da727145a1696f348	EMITIDA	FA EH_2024	81	252916077	\N	2024-11-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.077
cmnhp0ies02asrkt45xo70nwf	19e1ad5e9d284e90508b5f8e033591ad0b204d92c4b22127ee0bb0ff9b2fee2f	EMITIDA	FA EH_2024	79	262961512	\N	2024-11-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.092
cmnhp0if702aurkt40fmrsjrb	aee5b61ef16d91e2a8eeb40c0ad7a59d76b85eb6d4ab117297989595eadb2757	EMITIDA	FA EH_2024	78	244984883	\N	2024-11-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.107
cmnhp0ifk02awrkt4tnus6oxs	b2e971a6ec177879f5fd9d2b8ce6008944d34669761859bdfa6ffa7eb447aaa6	EMITIDA	FA EH_2024	84	258449233	\N	2024-11-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.12
cmnhp0ifw02ayrkt4pejau9am	5b4537cbc04f4a8ed03d6d7aaad9eeed4502be4b8c7db44229c8f4dd3878ad68	EMITIDA	FA EH_2024	91	266277055	\N	2024-11-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.132
cmnhp0ig702b0rkt4kh8hrh0q	97790fa4bf955e4e431861d188ebc05eea97e3b1e3dbf16314ce3e257faf053f	EMITIDA	FA EH_2024	70	266277055	\N	2024-10-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.143
cmnhp0igl02b2rkt4ecnihlyu	bdc1cb54478be6c756ae7e441a1ce9c44046cb4f851de30d8bbb5a1a166346fb	EMITIDA	FA EH_2024	66	255364962	\N	2024-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.157
cmnhp0ih102b4rkt4eawynmjf	da9631cceb8eed93903be675c7a015c78ab37c99799bcae8186a948c681aa057	EMITIDA	FA EH_2024	60	252916077	\N	2024-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.173
cmnhp0ii202b6rkt4xzi3t9si	0aea15a70a08a1fdb08d4afd76c5aa2f48999e391638a220f476228c229fc43a	EMITIDA	FA EH_2024	59	248797239	\N	2024-10-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.21
cmnhp0iig02b8rkt4xtxjt7m5	c5e0837145fdd85b4fc34985a238bddeaff3a040eb0576e00a13c997c22754d0	EMITIDA	FA EH_2024	68	261803310	\N	2024-10-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.224
cmnhp0iiv02barkt4o4hwnwe3	f64444832edc913e3c87df05727a35bf08b261d15c63d953c163c0c4e1f2723b	EMITIDA	FA EH_2024	77	258836989	\N	2024-10-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.239
cmnhp0ijc02bcrkt45ymoc4ob	5fd5119f1741c9ce6dc068ad27fcfd5f5dd1b0d386e0552d897291800bc3a66a	EMITIDA	FA EH_2024	57	244984883	\N	2024-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.256
cmnhp0ijt02berkt4xmn34v5c	38e778dce12b2a5e3052a32acf4426ec91a078869d4c15f78db38c0fafa67ff8	EMITIDA	FA EH_2024	63	258449233	\N	2024-10-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.273
cmnhp0ik602bgrkt47f64s00r	15d1b49379ff7dfaf3cf2c774cf3d594933210c146f651c13ea6f12e2a64c679	EMITIDA	FA EH_2024	58	262961512	\N	2024-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.286
cmnhp0ikf02birkt4f9jvu1xl	4a69a1b63d2e28f1e76aa6165a33258cc1057c4699638b0f40a0b2bb004afab9	EMITIDA	FA EH_2024	67	255497393	\N	2024-10-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.295
cmnhp0ikq02bkrkt4l9i7a2c2	9a9fde80f7c489755bfaf715aba5b644ec060315d1509f2931682706d122cb44	EMITIDA	FA EH_2024	61	270909028	\N	2024-10-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.306
cmnhp0iky02bmrkt4m4u8gbxt	e975f469993271542f8f43a083b6f200b115200771011fb80e132da135987f9c	EMITIDA	FA EH_2024	74	253278716	\N	2024-10-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.314
cmnhp0il902borkt4nx4fiq4m	c275604f7d59bff1cf66fffcf0b170c5d54c188d32814e006425bab8e859df4d	EMITIDA	NC EH_2024	10	258836989	\N	2024-10-22 00:00:00	-350.00	0.00	-350.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.325
cmnhp0ilk02bqrkt4yejswyk4	272ac580fea678494c20e4f57fa152ce8a2a339a81435e2e7d10d21e14078267	EMITIDA	FA EH_2024	73	267439130	\N	2024-10-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.336
cmnhp0ilv02bsrkt41pkfpz8y	c795b4f3f1de68b9302e2b18cc607393ebd74220b9c8322fce1a2deb433d8eba	EMITIDA	FA EH_2024	65	259676136	\N	2024-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.347
cmnhp0im402burkt462o35laq	eb4188961059191634e9b9abbd00043a7f659783d28cd9fb68308c7745ea499f	EMITIDA	FA EH_2024	72	257675841	\N	2024-10-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.356
cmnhp0imh02bwrkt48c21p99t	ea5ae7b3fed9aea0f352c7bcd52c8df340c1bf968d4de87fe355b59858dba2fe	EMITIDA	FA EH_2024	64	257665072	\N	2024-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.369
cmnhp0ims02byrkt4qd4ffu6l	539589ea5b66a1b052f621662b0089607037346c8baa41012ed46aa9b72296cf	EMITIDA	FA EH_2024	71	256125627	\N	2024-10-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.38
cmnhp0in602c0rkt4dpudpb8l	8699713c821d56e34572c1a4580cdd12426614ffa6a9551ae81f12298d6d9856	EMITIDA	FA EH_2024	62	234850876	\N	2024-10-22 00:00:00	375.00	0.00	375.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.394
cmnhp0inl02c2rkt4wrvyf4vx	8734ccdb050fe1d7aafbe254ec475fa3a1a2cffaf50e4deffec831bb07e7398e	EMITIDA	FA EH_2024	69	223482900	\N	2024-10-22 00:00:00	80.00	0.00	80.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.409
cmnhp0iod02c4rkt4x8vev39d	991a347c281250e7c35c9e2c95ee9341ada24f3c7f8ea922a2fa1a6c6454c4b5	EMITIDA	FA EH_2024	76	262387085	\N	2024-10-22 00:00:00	262.50	0.00	262.50	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.437
cmnhp0ioz02c6rkt4to8nhnsf	20e042eb3ec4af77f01e5051e6f2666d5367787cee2bb685e93af47b0e13e7ba	EMITIDA	FA EH_2024	75	258836989	\N	2024-10-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.459
cmnhp0ipj02c8rkt45cgwd078	e74739e4cb2ce9dd5e4962afb3502842e4d55f619ce63786853f2f4236b27738	EMITIDA	FA EH_2024	56	259676136	\N	2024-09-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.479
cmnhp0iq602carkt4iwzfy1mm	d87c37520b4ea4b4bc74ee300e1b97e03804bff8ed4943c84b46f405b17e1630	EMITIDA	FA EH_2024	50	255497393	\N	2024-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.502
cmnhp0irw02ccrkt46wf00wr2	0cc4c0e161f11ba1c770a8d1a20dc0ec9300d7e8664d0cc5f805c985fb5be2b4	EMITIDA	FA EH_2024	46	257675841	\N	2024-09-22 00:00:00	400.00	0.00	400.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.564
cmnhp0is902cerkt4729sxnz0	0d0addbf957c8b13f7ee17141eccee920960b4d670dcb633e086c15b0ed887c5	EMITIDA	FA EH_2024	51	258449233	\N	2024-09-22 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.577
cmnhp0iso02cgrkt484pzqbne	3076db0414a43e970a5475ab8a35decd3e2ce55bbaaceb4320522458c5c416fe	EMITIDA	FA EH_2024	52	261803310	\N	2024-09-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.592
cmnhp0it502cirkt4e4cchh1h	e22740e73a41f11dc59bd378ea798ac03c40f9093c4e418eb1a4fd7e1b862c88	EMITIDA	FA EH_2024	42	253278716	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.609
cmnhp0itl02ckrkt48bgv9fhj	28c87b897a588c4dc1f87572a33af55de6801f9b2471ee12bbbaa73c34474015	EMITIDA	FA EH_2024	47	267439130	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.625
cmnhp0iu202cmrkt4e4nc741k	54ca2655c680a65fa3d765345ed4b4209c91bb5e11ee6e3ae298afa63fb1f1e1	EMITIDA	FA EH_2024	53	266277055	\N	2024-09-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.642
cmnhp0iuf02corkt4505aa95b	fffa4bbc97a0735602e32ce579527c9a36c3d4e60a105ec221e00abf975b061f	EMITIDA	FA EH_2024	55	223482900	\N	2024-09-22 00:00:00	80.00	0.00	80.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.655
cmnhp0iup02cqrkt4szs9h92b	f198d9b72cfc8edd603fff9efcffb366f15bf9f8967b5637c09e1fc9717b808b	EMITIDA	FA EH_2024	45	262387085	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.665
cmnhp0iv202csrkt428q2u4dh	fcd9e499a13dc917b5cc48ba0f71c222aa9b428d1ba4302399747515e6cb69b7	EMITIDA	FR EH_2024	81	252916077	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.678
cmnhp0ive02curkt4u21ongez	2a101f51dc1acac6374a3a44341636d2965ad6771b343867bb71ad2d5909aad6	EMITIDA	FA EH_2024	34	270909028	\N	2024-09-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.69
cmnhp0iw702cwrkt47976knua	ece16d4de6e290ac81943aa201f00fd143125be6c490cc841e7bd02ae309ebae	EMITIDA	FA EH_2024	35	270909028	\N	2024-09-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.719
cmnhp0iwm02cyrkt4k135qb7u	5ae677e90739393f5b6217cc6f721db7ec7a4727f772d4811c724d4315c38960	EMITIDA	FR EH_2024	83	262961512	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.735
cmnhp0ix202d0rkt4p4q2jipi	cc3cf7532c127e97e143d99e7275742ace4dbe27e94a89861a71212234164225	EMITIDA	FA EH_2024	37	248797239	\N	2024-09-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.75
cmnhp0ixg02d2rkt4l1np2me3	fd22d247e4a640bd9686447513da9dea62bc3fec1db065309bc59d6b1735bde5	EMITIDA	FA EH_2024	41	244984883	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.764
cmnhp0ixu02d4rkt4dn03huvu	dafb396f6fa01395a51d9f96d53e45e163f8c0d6f59d8b61e4cdd2ba93b4d9b7	EMITIDA	FR EH_2024	85	248797239	\N	2024-09-22 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.778
cmnhp0iy602d6rkt4473o5qet	c6aaf5ad5de880d2abead0beccf964650ff88f1051a06b1853ab36bbee77aeb2	EMITIDA	FA EH_2024	48	257665072	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.79
cmnhp0iyl02d8rkt4l39n2lqk	51046b9da5f3a9f3bdfd919c5a1290cc246561da7897bdd3d9b5c5b8d102dc49	EMITIDA	FA EH_2024	54	256125627	\N	2024-09-22 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.805
cmnhp0iyw02darkt4l48llw4l	ea0ca9d926386788c1cee27a831e58a684975e1b81374ea3276a3f62f4ff78ef	EMITIDA	FA EH_2024	49	255364962	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.816
cmnhp0iz902dcrkt49lubd5ub	b31b219637e94e2d733893528574cedf7d84a828e4bf3f189e0b9ef6dcb187dc	EMITIDA	FA EH_2024	43	258836989	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.829
cmnhp0izk02derkt4tqpm2ma0	cf85d8bbaee8d889213bd98f20efb3868311430d0c7d8efc4d7f0a36d1c18dea	EMITIDA	FA EH_2024	40	252916077	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.84
cmnhp0izs02dgrkt4gajhi0du	425c61b71fdcb98b4c22622ee89fcd980486788dfebfe933943238c733cd6033	EMITIDA	FA EH_2024	36	248797239	\N	2024-09-22 00:00:00	300.00	0.00	300.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.848
cmnhp0j0302dirkt4nes2fgj9	67c3c72290642711a300802f0a310014aa4374e5753b118053132a52a09fb95a	EMITIDA	FA EH_2024	38	262961512	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.859
cmnhp0j0b02dkrkt40rmitx1g	72de48ac6275b18ef068df4678e9b0e22ec2776bbb8142f16ef2df36e8498e32	EMITIDA	FA EH_2024	39	234850876	\N	2024-09-22 00:00:00	375.00	0.00	375.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.867
cmnhp0j0m02dmrkt4uaxdlvca	8958fa07dad86c29a37807c4697ca5fc8763a6e521e62d13ff12dd4c05993ef4	EMITIDA	FR EH_2024	84	244984883	\N	2024-09-22 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.878
cmnhp0j0y02dorkt472spikue	f2ef38c7d36e89b04b4e45bff1ee82c8b636975b36f45a34e9ba4932e6dba9a4	EMITIDA	FR EH_2024	82	234850876	\N	2024-09-22 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.89
cmnhp0j1d02dqrkt4c0321737	ed781c420fbc22fc27e90c1ad9b97d9dcb23dfade29817ed803be5c00c827ae4	EMITIDA	FA EH_2024	32	256125627	\N	2024-09-19 00:00:00	150.00	0.00	150.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.905
cmnhp0j1v02dsrkt46rg8w6vp	a002f765d3afe994dfac6eabe66f296c2d39340bb0a9f7ff881722c1708eb5c0	EMITIDA	FA EH_2024	33	256125627	\N	2024-09-19 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.923
cmnhp0j2a02durkt4io6cldwi	7fe1e7106ad7feeaed83db8edec900244011229ce0c88f4dc4f9f207d744e2a6	EMITIDA	FA EH_2024	31	266277055	\N	2024-09-18 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.938
cmnhp0j2n02dwrkt47dbboc1c	76f84ced0d67f9291f73ac5ac9a591b1364afb6c3ea4c328754502bb02f3bc7e	EMITIDA	FA EH_2024	30	266277055	\N	2024-09-18 00:00:00	150.00	0.00	150.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.951
cmnhp0j3102dyrkt4cs40q0f5	9567a479193143092100f4080d3018d10ef71f9228d1f69896a8fc968515c853	EMITIDA	FR EH_2024	80	226804747	\N	2024-09-16 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.965
cmnhp0j3902dzrkt426gglck8	b8a5e9aadb31b5e2ae6257b444fe969a98b6658eedb017dbc7e92f303cc36f64	EMITIDA	NC EH_2024	9	226804747	\N	2024-09-16 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.973
cmnhp0j3d02e0rkt4b2amvjf7	b60b31405f7024179cc1381652cba231439ee1e9c3f1d2e57c97a2a6ba1a00e1	EMITIDA	NC EH_2024	8	226804747	\N	2024-09-16 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.977
cmnhp0j3i02e1rkt44vkqorb6	1c8962e91c724dd6a2bae3f5b31966d667e9eea219b35aa7c7a813be514a09ed	EMITIDA	FA EH_2024	28	223482900	\N	2024-09-16 00:00:00	160.00	0.00	160.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.982
cmnhp0j3x02e3rkt436wmknmk	ee463eaa0821b6d490282c5f4fe5421b970061e7183e4df293b3ededb10e71ec	EMITIDA	FA EH_2024	29	223482900	\N	2024-09-16 00:00:00	40.00	0.00	40.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:23.997
cmnhp0j4602e5rkt42wom4be6	2627f532dc6e60bd47408f85beb13787b8cb88ead524b66daafabd249c1567cd	EMITIDA	FA EH_2024	26	261803310	\N	2024-09-15 00:00:00	450.00	0.00	450.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.006
cmnhp0j4h02e7rkt46d76j65m	b9ecd1cfe327fe34fce170ec53d5e5b0c2e1af10ef0deb3fb9c6a11746bbec5f	EMITIDA	FA EH_2024	27	261803310	\N	2024-09-15 00:00:00	225.00	0.00	225.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.017
cmnhp0j4p02e9rkt4krrtipeo	b5780aa2a4094c5ac33e00a587fb18233d5eb6cef615d47702e3ba82f501a83e	EMITIDA	FA EH_2024	25	262387085	\N	2024-09-15 00:00:00	175.00	0.00	175.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.025
cmnhp0j4z02ebrkt4y6tdxwe4	02c171c4ad4f38a8f047385e89ed26320bcf085e45144cc99a5f9c32830cd3e8	EMITIDA	FA EH_2024	24	262387085	\N	2024-09-15 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.035
cmnhp0j5902edrkt4rhedsghh	b2807c903dafa34a811267d7b6911b66cbc7efeedb95f2a6704cad69d1704204	EMITIDA	NC EH_2024	7	258449233	\N	2024-08-27 00:00:00	-1000.00	0.00	-1000.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.045
cmnhp0j5m02efrkt4wzczv2fq	1af3d44388d387e663ae1efbd9f0ec30aec04b81c1a44c01c77e043d9c6f4fa5	EMITIDA	FA EH_2024	23	258449233	\N	2024-08-27 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.059
cmnhp0j5z02ehrkt4qranaq5f	4122555a7ae65d0d46c59fbfc8cf4bba907cef6e6842e67d348db0078b64bc39	EMITIDA	FA EH_2024	22	255497393	\N	2024-08-27 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.071
cmnhp0j6a02ejrkt4qkedc10c	7297f8953f912c47d4ed6e2ab78dc398ea5d857fdfc732494dcbde0145c0db6b	EMITIDA	FA EH_2024	21	255497393	\N	2024-08-27 00:00:00	1000.00	0.00	1000.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.082
cmnhp0j6q02elrkt48imvk6rs	cb0e72a72b345592578684b07c10fe9ee800f2985b73d313c4cee19ffa8e36ff	EMITIDA	FA EH_2024	18	267439130	\N	2024-08-26 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.098
cmnhp0j7902enrkt4eeoj97e9	ea1ada39bbd2c75d5df0f6fd22261d18cd1e58924d40f2c5f2f4ab1ea7b63163	EMITIDA	FA EH_2024	20	258836989	\N	2024-08-26 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.117
cmnhp0j7q02eprkt43v733d0n	411be7ada19f81dbf330256fda3aaa256194deb3b21c062c2c1baf90d8a3aa4b	EMITIDA	FR EH_2024	79	226804747	\N	2024-08-26 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.134
cmnhp0j7w02eqrkt4dsgp9htn	ce35f29aa9aef69d6a144d59b5957f6bc229f9c8f495ecf50645629458ac8957	EMITIDA	FA EH_2024	19	258836989	\N	2024-08-26 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.14
cmnhp0j8702esrkt429p0g1oc	8b6796b32b760ca50cb92522ca01f8515e40d9aa69142a4bf5ffd0233537ea2a	EMITIDA	FA EH_2024	13	259676136	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.151
cmnhp0j8h02eurkt424bkslnw	00e26a2cff4c91421df9086d303c4d7d78bead8dd3a3529cd90abaa1b550f63a	EMITIDA	FA EH_2024	16	253278716	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.161
cmnhp0j8r02ewrkt4tql6p8vg	1c3b61e2bcdab76393cbe7be5738fb377e38d8f54fb82fe242de9e54db7226c5	EMITIDA	FA EH_2024	12	259676136	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.171
cmnhp0j9302eyrkt41blcko3y	815e5ee72a045a81b9c0e115a8a9a906fe86cefc9474043051189a94e626f28b	EMITIDA	FA EH_2024	14	255364962	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.183
cmnhp0j9h02f0rkt42y48y3xm	5f01f95d816f125bcbaad4ba1df0eb124c25c2baedff3b2e69cc9a5828c773b0	EMITIDA	FA EH_2024	8	257665072	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.197
cmnhp0j9s02f2rkt4m101zj1t	7a8a567757ec212c57ba774ca283b689d22cf527a28bb6f14c6ea68527b1a750	EMITIDA	FA EH_2024	6	258449233	\N	2024-08-25 00:00:00	1000.00	0.00	1000.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.208
cmnhp0ja202f4rkt4gx7y69il	15f658bb9933a020c06a9ac4ad2f7696724f6d59e3b3b5b371c0092fa79ff2f7	EMITIDA	FA EH_2024	9	257665072	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.218
cmnhp0jae02f6rkt489f5yvor	e3030839595ab0ae7eeda88655efd96b81f43ea063cc69a389b329a444a61fcf	EMITIDA	FA EH_2024	17	253278716	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.23
cmnhp0jaq02f8rkt4pvjey0t0	de170b48d30904e7f5d22a3abc11526fdc693519e4671b27983421e552c8eb6f	EMITIDA	FA EH_2024	15	255364962	\N	2024-08-25 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.242
cmnhp0jaz02farkt4fblr75f5	22079eb4b71496889955d82a941f00d02b2490c01fad083450f02a51cd701cf3	EMITIDA	FA EH_2024	10	257675841	\N	2024-08-25 00:00:00	400.00	0.00	400.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.251
cmnhp0jbe02fcrkt4i6okgsnr	d01a67f21a46307f0afa7b2ed27d80280eabae73bfa49c3d7648d894775898a5	EMITIDA	FA EH_2024	11	258449233	\N	2024-08-25 00:00:00	500.00	0.00	500.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.266
cmnhp0jbt02ferkt4hslzgn7e	6214ae2ee5a764c928f30ebcf7178ef5a303c396999170e4e2855b120f5fae35	EMITIDA	FA EH_2024	5	267439130	\N	2024-08-24 00:00:00	350.00	0.00	350.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.281
cmnhp0jc602fgrkt4ytqsug7c	a32c53090f8173945e4dbb08986dc2373118e2418a1478f5075845761035d00f	EMITIDA	NC EH_2024	6	516369652	\N	2024-08-21 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.294
cmnhp0jca02fhrkt49z2z3b94	6b396e9f8ac4fe8cc47aeae8a855b57636def3f184093d8aca5316bf06fee1fe	EMITIDA	FR EH_2024	77	244984883	\N	2024-08-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.298
cmnhp0jcm02fjrkt4kumu82n6	56362e47dc37c1a3a047c2b2f4952fb608a4b9002c0114e43f9353e78c5256a2	EMITIDA	FR EH_2024	74	262961512	\N	2024-08-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.31
cmnhp0jcw02flrkt4yulwlkwf	9e3735927f186b92e83f37b441e7cb83123f586655f7c337d209085facedd9a3	EMITIDA	FR EH_2024	73	234850876	\N	2024-08-20 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.32
cmnhp0jd602fnrkt4q59khw86	6b605999bffbab364ef0f6159fa2f118dec1a9e93a87d3a6cd7d29d89b24b7a7	EMITIDA	FR EH_2024	76	270909028	\N	2024-08-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.33
cmnhp0jdd02fprkt4nrrviies	496da51661738db8d69f185b3286865e21ed51452fd5ae964c9797fdaa051ae6	EMITIDA	FR EH_2024	78	248797239	\N	2024-08-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.337
cmnhp0jdo02frrkt4rwf1f7eg	396692a381b1130e5aa29c8164a64682d2a6bd3d6552c659306829750a7fa246	EMITIDA	FR EH_2024	75	252916077	\N	2024-08-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.348
cmnhp0jdy02ftrkt4513zt6h7	e7775ed46ffedd04b95575b8afd017b2bd2730a19f43e71ceff0703a192f2356	EMITIDA	NC EH_2024	5	248538446	\N	2024-08-20 00:00:00	-325.00	0.00	-325.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.358
cmnhp0je202furkt4i3ou6qqa	88df6e243218cca066f395ea5ff417dd47c6722c9b74a0900b400c0993821577	EMITIDA	FA EH_2024	2	257675841	\N	2024-08-15 00:00:00	400.00	0.00	400.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.362
cmnhp0jeg02fwrkt4p3b1eiyw	12d9c48c55789d108baae13418f6b954ead3a6fc1d227fc2f2146bd6cd1aede5	EMITIDA	FA EH_2024	3	257675841	\N	2024-08-15 00:00:00	400.00	0.00	400.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.376
cmnhp0jeu02fyrkt4pexao02e	89bbeb8d85a5d743192a09319951226ec5859344a752e7529714f1b9222ebe6e	EMITIDA	NC EH_2024	4	257675841	\N	2024-08-15 00:00:00	-400.00	0.00	-400.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.39
cmnhp0jf602g0rkt4nhtxqzms	bdf6b9764dcaca62c85921241ac4754d0c8ac56f96d54429a83f24e3b283df71	EMITIDA	FR EH_2024	67	516369652	\N	2024-07-29 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.402
cmnhp0jff02g1rkt4nmy2y6cm	f15ccf856227fab23a6c926c30c8c625aef7c8e289beb783ef48e8114bdb0825	EMITIDA	FR EH_2024	72	251114996	\N	2024-07-29 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.411
cmnhp0jfl02g2rkt4f66xqqo4	98c621908ade5974723075a7b0b15decd38a24baebfe8ea998a3c6e18721fc57	EMITIDA	FR EH_2024	69	252916077	\N	2024-07-29 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.417
cmnhp0jg302g4rkt4xydwb7tz	9c3504d25312c14b860f232a6dd32b63fd98a1da4f0025f5f8aef3bcca0a8dc0	EMITIDA	FR EH_2024	65	244984883	\N	2024-07-29 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.435
cmnhp0jgg02g6rkt4cbpvnwyg	99743803b292d8fb2a9490f76deda317a7f07ea4740556ac0b1456f4960e50e6	EMITIDA	NC EH_2024	3	244984883	\N	2024-07-29 00:00:00	-10.00	0.00	-10.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.448
cmnhp0jgr02g8rkt4ztedubkr	9f7a7c03f004dee02fabaa8f0178139ba4c3a0e6adfc421f1e86ff3e7a01bfbc	EMITIDA	FR EH_2024	66	226804747	\N	2024-07-29 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.459
cmnhp0jgv02g9rkt4pd0anh8w	ef3c5c53d96c5d7a1088438f096605f84acddbac33d9b7496384f6b4752029ab	EMITIDA	FR EH_2024	70	234850876	\N	2024-07-29 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.463
cmnhp0jh602gbrkt4sdrf2hzr	c1bd3821a3d1715d4cb6974a5e5a9304a5c06ee3d7e94d24a2bba32afbe97b16	EMITIDA	FR EH_2024	71	262961512	\N	2024-07-29 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.474
cmnhp0jhj02gdrkt4egfjiu4n	098df4507788ae9938a7d2c6c974effc7d8f75b446d20819469235b35b30313e	EMITIDA	FR EH_2024	68	270909028	\N	2024-07-29 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.487
cmnhp0jhu02gfrkt4a3xywkgl	f8848ae01789abcaa22bec5b054dd9c628cd8f64b82fbdaddc4c57145cff0466	EMITIDA	FA EH_2024	1	244984883	\N	2024-06-27 00:00:00	10.00	0.00	10.00	Fatura	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.498
cmnhp0ji602ghrkt427kok8d3	b3a351e160a40c9507327558e76734c654e7cf2aae882c9c2d2099f7e91e47bb	EMITIDA	FR EH_2024	58	270909028	\N	2024-06-26 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.51
cmnhp0jii02gjrkt479rw92pu	e9c9a2ec9b2c6e8073ade15672473d7ac9f28c1d293cd0011aa74b24afedf957	EMITIDA	FR EH_2024	54	248538446	\N	2024-06-26 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.522
cmnhp0jio02gkrkt4yrspacbr	e3e620ac6be11cdc99c17078268fcb80bb180ca8513932aa00e2299842711b83	EMITIDA	FR EH_2024	64	244984883	\N	2024-06-26 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.528
cmnhp0jj302gmrkt4ovnynyw0	a3f53a1d8e05438e4ab5aa7d864f79aa938a4874ab6d4da6a171755dd148f344	EMITIDA	FR EH_2024	63	251114996	\N	2024-06-26 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.543
cmnhp0jjb02gnrkt4tal84o8g	4a671cdd42d7ecda5d2bdaef807ee286969ffa513a067f6b736a2c8b7ee258b9	EMITIDA	FR EH_2024	62	262961512	\N	2024-06-26 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.551
cmnhp0jjq02gprkt4d4cmov6p	7dee1d1ca3593be151f42f794ad6e5d9c1681e418d1ef3805da24e882de70872	EMITIDA	FR EH_2024	60	248797239	\N	2024-06-26 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.566
cmnhp0jk502grrkt4e61o9l4o	e90bca6a0bde35e480dac1ed3f292bb851cec13cb0403c635c1a72c4559cc478	EMITIDA	FR EH_2024	59	252916077	\N	2024-06-26 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.581
cmnhp0jki02gtrkt4ln1x4auq	b6aed2f89e4317ca738223338a73d1f1fce3082e34f06fb76a41ec57a1960812	EMITIDA	FR EH_2024	55	234850876	\N	2024-06-26 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.594
cmnhp0jkq02gvrkt4yk3rydz8	ec966a73c429b091b6b33ea8b2902a9fbb0434e4e4d67b8177aaf1e1e6ee9937	EMITIDA	FR EH_2024	61	226804747	\N	2024-06-26 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.602
cmnhp0jkx02gwrkt4jlew0ge3	4fedf7ed858d15829771dc39afb1c9948a0d7e4f2c5c2516fc1858f30ed45e83	EMITIDA	FR EH_2024	57	516369652	\N	2024-06-26 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.609
cmnhp0jl202gxrkt4hsizyyam	3160ac0a2f2b3adb2a39e90e9cd1b17d339974daf3c2f386c803b27f26ae8e62	EMITIDA	FR EH_2024	46	516369652	\N	2024-05-11 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.614
cmnhp0jl702gyrkt4xgyb331s	7c5154c461adffa21460e107106f4ab30e890ae43328f53ea2349b739b9fad3c	EMITIDA	FR EH_2024	52	251114996	\N	2024-05-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.619
cmnhp0jlc02gzrkt466lrpie1	0e18cc74ceb03dc662610c875550c9ba0c393a89d49f9752547f3b3bcb651ed5	EMITIDA	FR EH_2024	47	270909028	\N	2024-05-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.624
cmnhp0jlp02h1rkt46kmgrxdf	f3f26f560cd053950a98c6342d2181c6f2c2f77d5be7a599a579dca3602363a6	EMITIDA	FR EH_2024	48	252916077	\N	2024-05-11 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.637
cmnhp0jmg02h3rkt4solwtkhy	8bc749f8263322c091bc1c11bd9f97fa36d08a27732c0cceff372c3f8ebc7381	EMITIDA	FR EH_2024	44	248538446	\N	2024-05-11 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.664
cmnhp0jmn02h4rkt46f92cs9u	67d7d3337829b36160b5b6213a7285fb88f1fb8f3bfc7f04e60a6d0cc295395b	EMITIDA	FR EH_2024	53	244984883	\N	2024-05-11 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.671
cmnhp0jn002h6rkt4cqj5ktk4	36abca05a2f0ccc45c4ac53043eb3d86e75b3accef01c4725deae1bfe2b36e67	EMITIDA	FR EH_2024	51	262961512	\N	2024-05-11 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.684
cmnhp0jne02h8rkt40jpfw5to	989bb249af30d6e2882dd915fd2473853cb16905ec845e016e784fb8a5d52694	EMITIDA	FR EH_2024	49	248797239	\N	2024-05-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.698
cmnhp0jnq02harkt4bryw07ro	05c677c4d57e65b53af571c7809cc74e51e0f693fdbdb9a30a13985976038e36	EMITIDA	FR EH_2024	50	226804747	\N	2024-05-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.71
cmnhp0jnv02hbrkt4q8qazilp	1e1441aa97c3e780004911c9fe8e0d0063e7961d481338a14f84ef02bd1c9566	EMITIDA	FR EH_2024	45	234850876	\N	2024-05-11 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.715
cmnhp0jo802hdrkt4yeljdmdh	a7d783bd87011410b143fa9b6d29288b31bae26114fa2cef3ec09cddad47b1a4	EMITIDA	FR EH_2024	36	516369652	\N	2024-04-24 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.728
cmnhp0joe02herkt4y3mae9md	4d0b8e9c096e0d1b7df2a1ab1a14b4142a2558fab162aa35182472cbec28b9e3	EMITIDA	FR EH_2024	38	252916077	\N	2024-04-24 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.734
cmnhp0joq02hgrkt4bvt5imy0	f129bf4264ef340f0cb683081000db5d6473b661114af4a5a4148a55e6ca59f5	EMITIDA	FR EH_2024	37	270909028	\N	2024-04-24 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.746
cmnhp0jp202hirkt465ilkedv	04df0b277093740940b7425238c0be310dca2a96cf5652bb75eaffdbf22fb097	EMITIDA	FR EH_2024	42	251114996	\N	2024-04-24 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.758
cmnhp0jp802hjrkt4swu99kqz	6330bfdbf2d6ae096a98446e40b123bfa7b77a0a4ede5b1aa18e2b8102b28e7f	EMITIDA	FR EH_2024	40	226804747	\N	2024-04-24 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.764
cmnhp0jpd02hkrkt4l0orgkpt	93022d34bd84aec7cb7c39ff24a0942c9662d4acb5e2716a3fffba89effd0e99	EMITIDA	FR EH_2024	39	248797239	\N	2024-04-24 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.769
cmnhp0jpq02hmrkt4kc88ku51	905e56d1c588d93cad3ef620df78fe64df8395a03588e1d130adaeae6b52e36b	EMITIDA	FR EH_2024	35	234850876	\N	2024-04-24 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.782
cmnhp0jq002horkt4ve112r8v	a00c3e790e02d721ba64b0452201ef05329a3bc18414977d1e3f0374a8e8df78	EMITIDA	FR EH_2024	34	248538446	\N	2024-04-24 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.792
cmnhp0jq702hprkt45yhj5j7i	07169615a54019274af76fee53cd447188e7cef3007fd2334c1d69f93cd41e9e	EMITIDA	FR EH_2024	41	262961512	\N	2024-04-24 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.799
cmnhp0jqi02hrrkt443vu88fb	6ec5b2af4fdcd5a9f508bc44732e254184c8070c91ac4ac14f041d8ed3affc0f	EMITIDA	FR EH_2024	43	244984883	\N	2024-04-24 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.81
cmnhp0jqw02htrkt4h4b9oni1	2b0daee4242d85a409299d7fc47f1778598d9361be4f9cd69fc3078ae17d6b35	EMITIDA	FR EH_2024	24	516369652	\N	2024-03-21 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.824
cmnhp0jr102hurkt413ajndqc	57f3ccfa0e55563b8efae2fb695a4b8ab398c916dc7eca134f4884cb98d73d46	EMITIDA	FR EH_2024	30	262961512	\N	2024-03-21 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.829
cmnhp0jre02hwrkt45o321qxd	e163d49f5431e114954d28a806a6142ef1476d3726cd8818ad526e2de303a46a	EMITIDA	FR EH_2024	31	251114996	\N	2024-03-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.842
cmnhp0jrj02hxrkt44tniqa1r	936af938682433f2cfebd9e4090c7683e0f2d4ab4b0fa41c23883ae818758de4	EMITIDA	FR EH_2024	27	248797239	\N	2024-03-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.847
cmnhp0jrx02hzrkt48q9dvh8q	422c6bcf858b8e364d4fa9e31636d8ca37848430e92aeaf935aa6080f2638593	EMITIDA	NC EH_2024	1	248797239	\N	2024-03-21 00:00:00	-300.00	0.00	-300.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.861
cmnhp0jsc02i1rkt40zb0d18w	089b1dfa40a4db1fadb53f855c26e71fc6f83d22844284372577d47a3a5feb2a	EMITIDA	FR EH_2024	29	226804747	\N	2024-03-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.876
cmnhp0jsi02i2rkt4gbj1y5lt	121bbc0a4e8febb7404609f4cb28104caca065cb9c5c2e9bfc8ee80924c425d2	EMITIDA	FR EH_2024	32	244984883	\N	2024-03-21 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.882
cmnhp0jsv02i4rkt43q1u7ys3	583fb9dd835589ffefecad1dc852947692f25797edb5b0b36ff92043569cff91	EMITIDA	FR EH_2024	28	248797239	\N	2024-03-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.895
cmnhp0jt402i6rkt40w5k2tgk	091039a43dc547db8d8af1094eb0dacc453c31f70a93003e7b9896b010ef4eb7	EMITIDA	FR EH_2024	25	270909028	\N	2024-03-21 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.904
cmnhp0jtf02i8rkt4i2ivlzgb	4a74ad2382ffebf213a346d6676ea9cc3eef89638a86c9f83be9244ddb7a4582	EMITIDA	FR EH_2024	23	234850876	\N	2024-03-21 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.915
cmnhp0jto02iarkt4wre5up31	1004111a4dc40bdeed25edb43e87ad81ddf1e5ce4853c40f2c2adf6dc507f8e3	EMITIDA	FR EH_2024	22	248538446	\N	2024-03-21 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.924
cmnhp0jtt02ibrkt419o2la49	3b64ce2616aa76020c7426c67277ece8fce30461fed3d2646a30038cb802f664	EMITIDA	FR EH_2024	26	252916077	\N	2024-03-21 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.93
cmnhp0ju102idrkt46p4j2gw9	c5dd7c23a98801bc4c5c54b7a6ffe2385d0a3212e2b8f13173dc30f340f1b807	EMITIDA	FR EH_2024	33	516369652	\N	2024-03-21 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.937
cmnhp0ju502ierkt45sysf8ql	ffce08200e951025d18813472c2584bdc061b3b59428c60300ff5f1f74de6d4b	EMITIDA	NC EH_2024	2	516369652	\N	2024-03-21 00:00:00	-325.00	0.00	-325.00	Nota de crédito	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.941
cmnhp0ju902ifrkt4zbff73dj	10e0ee962f1e71d681747d68b16cfaca6d360081261f832965530332e68d6243	EMITIDA	FR EH_2024	14	516369652	\N	2024-02-20 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.945
cmnhp0jud02igrkt4zzhd0rwp	8e6f2149b67263b63b0f0c82120ed699db4c63a33e26b29c2967484df8b29266	EMITIDA	FR EH_2024	21	244984883	\N	2024-02-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.949
cmnhp0jup02iirkt4leb2lzlq	8e6b36748eee720d7eee8bf2e89f894c639beb963e56bf3f45b5e9cb3be0c237	EMITIDA	FR EH_2024	18	226804747	\N	2024-02-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.961
cmnhp0jut02ijrkt4xqsh7acf	dbf01e63ae52f04eedee2428d3147f20a94218e0f5543c1477270dbd936b33a6	EMITIDA	FR EH_2024	12	248538446	\N	2024-02-20 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.965
cmnhp0juy02ikrkt4b8r2ay5m	0a0ee2f277e1542a11ccd57619c55a82724e477ccf32eef6e9d72f92ab52b935	EMITIDA	FR EH_2024	19	262961512	\N	2024-02-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.97
cmnhp0jvb02imrkt4mkpl0bwb	3bf1340e52defa95e137ff3b5f987ea89d15d1925135c6d9f6b92de054ea5241	EMITIDA	FR EH_2024	15	270909028	\N	2024-02-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:24.983
cmnhp0jvt02iorkt48oxmve99	316376523741ba21d0f9f7395fbebbfa5ad02edec2d017a40566951f76879289	EMITIDA	FR EH_2024	20	251114996	\N	2024-02-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.001
cmnhp0jw002iprkt4a7kv7lsg	059665337043ee49f103634f93419e6331586d294718f9c1e57eed613158165a	EMITIDA	FR EH_2024	16	252916077	\N	2024-02-20 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.008
cmnhp0jwj02irrkt459f8nq1b	38c699927a3331a71f004bb897dd56d0fd12034bb9dc9c5d3d9d7ae9727f0093	EMITIDA	FR EH_2024	17	248797239	\N	2024-02-20 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.027
cmnhp0jwz02itrkt40q5te9u4	7b70c20153d5c51d545e3a1004e91c503dafb6b04b671ca3b3701e2d8b3141a9	EMITIDA	FR EH_2024	13	234850876	\N	2024-02-20 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.043
cmnhp0jxd02ivrkt4p465adw1	9effe8fc0ccfc72d3f1a0bf2da883e1233922e5aeaaa81bf395b677efd1e14ee	EMITIDA	FR EH_2024	10	516369652	\N	2024-01-11 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.057
cmnhp0jxh02iwrkt4blkcgrvw	a02e515a6b248903d3430419cd828756bd591a2fe0ed7a0a90f7ac2eb8afd77b	EMITIDA	FR EH_2024	11	516369652	\N	2024-01-11 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.061
cmnhp0jxl02ixrkt40c9b5m33	d436c9455bf8de981dd4dbb07b9ad5b92e38bc368acde48d569356920a3f1f53	EMITIDA	FR EH_2024	4	248797239	\N	2024-01-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.065
cmnhp0jxw02izrkt45h1m9jtv	5ed1ff7bb8337e07aeb71deb360b418d5fc83114c691a3f1c1ff430e5afc0ec4	EMITIDA	FR EH_2024	9	262961512	\N	2024-01-11 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.076
cmnhp0jy502j1rkt4fnfnv076	7a7a0b0d20e2751743295e35e0e9daf79910ec78db15ff70cb80013d36f2b6f0	EMITIDA	FR EH_2024	7	252916077	\N	2024-01-11 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.085
cmnhp0jyg02j3rkt4v0jgspoq	a5a8dffb2652422a97b9fa629f8e07befd237eac3779500cd57b0960162899cc	EMITIDA	FR EH_2024	6	270909028	\N	2024-01-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.096
cmnhp0jys02j5rkt4o2wo2js2	db0dcd83e32ba17f64f32c20798ce05833911cf6fba9cad2c89139fca5c5b5a0	EMITIDA	FR EH_2024	2	251114996	\N	2024-01-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.108
cmnhp0jyz02j6rkt43jcqafe5	388d5bc778b79af5fab89b6b95ea5771930e59de23a388e4b8a28b5658197d79	EMITIDA	FR EH_2024	5	248538446	\N	2024-01-11 00:00:00	325.00	0.00	325.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.115
cmnhp0jz402j7rkt4xpeh8rlu	dcb8b12351929f0523e82deafb6d295ef8f334d3f52d84dd1e6f84bebf139958	EMITIDA	FR EH_2024	1	226804747	\N	2024-01-11 00:00:00	300.00	0.00	300.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.12
cmnhp0jz702j8rkt4y7goq8bu	ac7d3c2a6b84ff462bfdefccad775851a3a05f27259e1dece19be215cf18bc1b	EMITIDA	FR EH_2024	3	244984883	\N	2024-01-11 00:00:00	350.00	0.00	350.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.123
cmnhp0jzh02jarkt43puqk4fu	85886c455952b122d6136bb694013a9bbecad6a9992ff6ab605d95fc9f975199	EMITIDA	FR EH_2024	8	234850876	\N	2024-01-11 00:00:00	375.00	0.00	375.00	Fatura-recibo	cmnhp0hzo028rrkt4lo5m445x	2026-04-02 16:32:25.133
\.


--
-- Data for Name: fracoes; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.fracoes (id, "imovelId", nome, renda, "nifInquilino", estado, "criadoEm", "atualizadoEm", "dataEntradaMercado") FROM stdin;
cmnfkrcpl00zxhgt4sxtmnh6n	cmnfh60wc001ejot4uioz8q1l	Quarto D	364.55	\N	OCUPADO	2026-04-01 04:57:44.985	2026-04-01 19:18:58.522	\N
cmnfkp2vg00zmhgt4890h7c56	cmnfjeb71002lrgt453z02rn6	Suite A	500.00	\N	OCUPADO	2026-04-01 04:55:58.924	2026-04-01 04:55:58.924	\N
cmnfkp8nw00znhgt4wtrtzofm	cmnfjeb71002lrgt453z02rn6	Suite B	500.00	\N	OCUPADO	2026-04-01 04:56:06.429	2026-04-01 04:56:06.429	\N
cmnfkpf0u00zohgt40qewt2f3	cmnfjeb71002lrgt453z02rn6	Suite C	500.00	\N	OCUPADO	2026-04-01 04:56:14.67	2026-04-01 04:56:14.67	\N
cmnfkpkhd00zphgt4elqe9l29	cmnfjeb71002lrgt453z02rn6	Suite D	500.00	\N	OCUPADO	2026-04-01 04:56:21.745	2026-04-01 04:56:21.745	\N
cmnfkpq1m00zqhgt4hjec3t2c	cmnfjeb71002lrgt453z02rn6	Suite E	500.00	\N	OCUPADO	2026-04-01 04:56:28.954	2026-04-01 04:56:28.954	\N
cmnfkpwhq00zrhgt4kwye95fl	cmnfjeb71002lrgt453z02rn6	Suite F	500.00	\N	OCUPADO	2026-04-01 04:56:37.31	2026-04-01 04:56:37.31	\N
cmnfkq1wt00zshgt4nv418741	cmnfjeb71002lrgt453z02rn6	Suite G	500.00	\N	OCUPADO	2026-04-01 04:56:44.333	2026-04-01 04:56:44.333	\N
cmnfkr0x200zvhgt4bdrsp2u0	cmnfh60wc001ejot4uioz8q1l	Quarto C	375.00	\N	OCUPADO	2026-04-01 04:57:29.702	2026-04-01 04:57:29.702	\N
cmnfkr6pe00zwhgt4j7vbb5vx	cmnfh60wc001ejot4uioz8q1l	Quarto E	375.00	\N	OCUPADO	2026-04-01 04:57:37.202	2026-04-01 04:57:37.202	\N
cmnfkrvw300zyhgt403qbk0s6	cmnfig5t40005rgt4visli2qu	Quarto A	375.00	\N	OCUPADO	2026-04-01 04:58:09.843	2026-04-01 04:58:09.843	\N
cmnfks14q00zzhgt47kj8x90e	cmnfig5t40005rgt4visli2qu	Quarto B	375.00	\N	OCUPADO	2026-04-01 04:58:16.634	2026-04-01 04:58:16.634	\N
cmnfks7y90100hgt4htds26dj	cmnfig5t40005rgt4visli2qu	Quarto C	375.00	\N	OCUPADO	2026-04-01 04:58:25.473	2026-04-01 04:58:25.473	\N
cmnfksd8d0101hgt4l62jg4a7	cmnfig5t40005rgt4visli2qu	Quarto D	425.00	\N	OCUPADO	2026-04-01 04:58:32.317	2026-04-01 04:58:32.317	\N
cmnfkskbx0102hgt4wp2stj9s	cmnfig5t40005rgt4visli2qu	Quarto E	375.00	\N	OCUPADO	2026-04-01 04:58:41.517	2026-04-01 04:58:41.517	\N
cmnfkt2br0103hgt4yaylhkk7	cmnfig5t40005rgt4visli2qu	Estudio A	550.00	\N	OCUPADO	2026-04-01 04:59:04.839	2026-04-01 04:59:04.839	\N
cmnfkt8q40104hgt41ma5h63p	cmnfig5t40005rgt4visli2qu	Estudio B	500.00	\N	OCUPADO	2026-04-01 04:59:13.133	2026-04-01 04:59:13.133	\N
cmnfkv17r010ahgt4x5dtkz2a	cmnfjiu0f002trgt4r83oahan	Quarto A	375.00	\N	OCUPADO	2026-04-01 05:00:36.711	2026-04-01 05:00:36.711	\N
cmnfkv8t7010bhgt4yrqs8e67	cmnfjiu0f002trgt4r83oahan	Quarto B	375.00	\N	OCUPADO	2026-04-01 05:00:46.556	2026-04-01 05:00:46.556	\N
cmnfkvenc010chgt44uzjdcc6	cmnfjiu0f002trgt4r83oahan	Quarto C	375.00	\N	OCUPADO	2026-04-01 05:00:54.12	2026-04-01 05:00:54.12	\N
cmnfkvkyn010dhgt4qymxazu8	cmnfjiu0f002trgt4r83oahan	Quarto D	375.00	\N	OCUPADO	2026-04-01 05:01:02.303	2026-04-01 05:01:02.303	\N
cmnfkvrla010ehgt4pntoyk13	cmnfjiu0f002trgt4r83oahan	Quarto E	375.00	\N	OCUPADO	2026-04-01 05:01:10.894	2026-04-01 05:01:10.894	\N
cmnfl616e01cdhgt468d1xir6	cmnfjiu0f002trgt4r83oahan	Garagem	80.00	\N	VAGO	2026-04-01 05:09:09.878	2026-04-01 05:09:09.878	\N
cmnfkqspm00zuhgt4hu2eqk4l	cmnfh60wc001ejot4uioz8q1l	Quarto B	375.00	\N	OCUPADO	2026-04-01 04:57:19.066	2026-04-01 05:25:08.842	\N
cmnfkqexq00zthgt4g4n1fbfy	cmnfh60wc001ejot4uioz8q1l	Quarto A	357.84	\N	OCUPADO	2026-04-01 04:57:01.214	2026-04-01 19:18:29.273	\N
cmnfku5zh0106hgt4klnrz5xu	cmnfj5zjx002grgt4zqkobyno	Quarto B	375.00	\N	OCUPADO	2026-04-01 04:59:56.237	2026-04-05 02:47:48.179	2026-04-01 00:00:00
cmnfkufn20107hgt4u4vq6obm	cmnfj5zjx002grgt4zqkobyno	Quarto C	425.00	\N	OCUPADO	2026-04-01 05:00:08.75	2026-04-05 02:47:50.115	2026-04-01 00:00:00
cmnfkunfy0108hgt41qvo5s53	cmnfj5zjx002grgt4zqkobyno	Quarto D	425.00	\N	OCUPADO	2026-04-01 05:00:18.862	2026-04-05 02:47:51.791	2026-04-01 00:00:00
cmnfkty6s0105hgt4qszjg3r8	cmnfj5zjx002grgt4zqkobyno	Quarto A	357.84	\N	OCUPADO	2026-04-01 04:59:46.132	2026-04-05 02:47:57.778	2026-04-01 00:00:00
\.


--
-- Data for Name: imoveis; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.imoveis (id, codigo, nome, tipo, morada, localizacao, "nifProprietario", estado, ativo, "criadoEm", "atualizadoEm", "areaMt2", "valorPatrimonial", ordem) FROM stdin;
cmnffta06000068t4x50l5rq5	CC-GERAL	Despesas Gerais	GERAL	\N	Administracao	\N	ACTIVO	t	2026-04-01 02:39:16.71	2026-04-01 02:39:16.71	\N	\N	0
cmnffta0i000168t4xgj7zfsl	CC-PESSOAL	Despesas Pessoais	PESSOAL	\N	Pessoal	\N	ACTIVO	t	2026-04-01 02:39:16.722	2026-04-01 02:39:16.722	\N	\N	0
cmnfdbzv5000k4wt4uzpxi943	LOJ-001	Loja Setubal	LOJA	\N	Setubal	\N	VAGO	f	2026-04-01 01:29:51.185	2026-04-01 03:17:28.494	\N	\N	0
cmnfdbzuu000j4wt4dys7zrmm	MOR-001	Moradia Cascais	MORADIA	\N	Cascais	\N	ACTIVO	f	2026-04-01 01:29:51.174	2026-04-01 03:17:31.769	\N	\N	0
cmnfdbzuj000i4wt44f7hzkv8	APT-001	Apt. Chiado 3 Dto	APARTAMENTO	\N	Lisboa	\N	ACTIVO	f	2026-04-01 01:29:51.163	2026-04-01 03:52:22.926	\N	\N	0
cmnfh60wc001ejot4uioz8q1l	FA2D	Francisco Agra 2D	APARTAMENTO	Rua Francisco Agra, 882, 2º Direito	Guimarães	167775014	ACTIVO	t	2026-04-01 03:17:11.053	2026-04-05 03:17:43.021	130.00	200000.00	0
cmnfig5t40005rgt4visli2qu	FA4D	Francisco Agra 4D	APARTAMENTO	Rua Francisco Agra 882, 4º D	Guimarães	167775014	ACTIVO	t	2026-04-01 03:53:03.592	2026-04-05 03:17:43.027	150.00	200000.00	1
cmnfjiu0f002trgt4r83oahan	TP3D	Teixeira Pascoais 3D	APARTAMENTO	Rua de Teixeira Pascoais 3D	Guimarães	16777006	ACTIVO	t	2026-04-01 04:23:07.888	2026-04-05 03:17:43.03	90.00	200000.00	2
cmnfjeb71002lrgt453z02rn6	Circ3D	Circunvalação 3D	APARTAMENTO	Estrada da Circunvalação 8732 	Porto	167775006	ACTIVO	t	2026-04-01 04:19:36.877	2026-04-05 03:17:43.034	150.00	300000.00	3
cmnfj5zjx002grgt4zqkobyno	SC2D	Sacadura Cabral 2D	APARTAMENTO	Rua de Sacadura Cabral, 10D	Pedrouços	167775014	ACTIVO	t	2026-04-01 04:13:08.541	2026-04-05 03:17:43.038	80.00	200000.00	4
cmng2hy95002yrkt4805y33j9	EMCH	Egas Moniz - Centro Histórico	MORADIA	Rua Egas Monuz	Guimarães	167775010	EM_OBRAS	t	2026-04-01 13:14:19.433	2026-04-05 03:17:43.041	\N	\N	5
\.


--
-- Data for Name: importacoes; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.importacoes (id, filename, "hashFicheiro", periodo, "tipoFicheiro", "totalFaturas", novas, duplicadas, pendentes, "criadoEm") FROM stdin;
cmnhoyc72010rrkt4ib8yu53b	2020.csv	78ade2ec77a327736c3fa9dd8dd9286458ee136bb37092a550da4a7a0e31fed7	2020-06 a 2020-12	RECEBIDAS	62	62	0	50	2026-04-02 16:30:41.726
cmnhoyhc2012urkt4fajo4txy	2021.csv	fc8c37a2307e8c03b1785810d326728c995570b5ef325794b5871ce0519a3657	2021-01 a 2021-12	RECEBIDAS	132	132	0	85	2026-04-02 16:30:48.386
cmnhoyppc017urkt4owu6dinb	2022.csv	4fb7440fe058674f78a1b02b0aace16f48c9e8c51f3405ccc0765f9f6efff98c	2022-01 a 2022-12	RECEBIDAS	217	217	0	152	2026-04-02 16:30:59.232
cmnhoywp301fprkt4xogmq81l	2023.csv	59fcc024cf53ee732bbf03f8584cb4d12157463316932d86e7d90356dee840af	2023-01 a 2023-12	RECEBIDAS	219	219	0	184	2026-04-02 16:31:08.295
cmnhoz2c501msrkt4vr8bhnw4	2024S1.csv	c88648f81e1f8f152cb102dcd0737e858223a2af4a12a7c8d4c701280ca0ec26	2024-07 a 2024-12	RECEBIDAS	199	199	0	146	2026-04-02 16:31:15.605
cmnhozajl01ttrkt46ghhf8l7	2024S2.csv	d4478d58ba41763196d7f7b7d9a44708ca800849060a2b07bda14d59608b7550	2024-01 a 2024-06	RECEBIDAS	142	142	0	112	2026-04-02 16:31:26.241
cmnhozzrl01ymrkt4414mu5i5	2020.csv	ca2069b4d1b2d34bb038dd7b37586c60c3834fdfa4091e9078653965a5994618	2020-11 a 2020-12	EMITIDAS	3	3	0	3	2026-04-02 16:31:58.929
cmnfle2f801i2hgt4fyhs4ggj	2025.csv	40e753b47e2848463fcd366301638d601bb64b623ce9af02bf13d1654776945f	2025-01 a 2025-12	EMITIDAS	276	276	0	276	2026-04-01 05:15:24.74
cmnflr30z01zjhgt4ejj7ly3x	e-fatura.csv	355c53d6d36f157f4db529cd46c882f3566ff52c1bbfeb79145f083863aa3c48	2026-01 a 2026-03	EMITIDAS	70	70	0	7	2026-04-01 05:25:32.051
cmnfm204v023khgt4ictgupot	2026.csv	8d12fe24699890fec6a8f0ae38b1d91ef1e446826e781e429ac3567ece912968	2026-01 a 2026-03	RECEBIDAS	77	77	0	77	2026-04-01 05:34:01.519
cmng38y0r003trkt4np4hq3pa	2025-1.csv	98a12ba7633d220c9d6422b1e971c0c238149a28332dcaeec9f4dca9b60741c0	2025-01 a 2025-07	RECEBIDAS	289	289	0	197	2026-04-01 13:35:18.843
cmng3b82800efrkt4f31fpqiz	2025S1.csv	657a89b0713462ac52dcfebf01556de7d21f120be7d3fdbd9df4ef67571ad0a5	2025-01 a 2025-06	RECEBIDAS	247	0	247	0	2026-04-01 13:37:05.168
cmng3betp00lbrkt4ugvuvo54	2025S2.csv	afe0301da9c3f5d5fc6447e341909ecaad36c2067b7bc3a8380df2a557e13b82	2025-07 a 2025-12	RECEBIDAS	221	179	42	135	2026-04-01 13:37:13.933
cmnhp03te01yqrkt47eqf4zgl	2021.csv	a99424799aa574af840682d03d9838c54470e62f3f79472df9b77860cf555395	2021-01 a 2021-12	EMITIDAS	39	39	0	36	2026-04-02 16:32:04.178
cmnhp08jw01zxrkt4airoy563	2022.csv	6e2fe9ce222addabba8678ba7ff26c56de76fcbfddaaa93abd9e2ef6c5704e50	2022-01 a 2022-12	EMITIDAS	95	95	0	57	2026-04-02 16:32:10.317
cmnhp0df5023nrkt4caowg0x2	2023.csv	fe48049f4b4c3f867387b7f69cad3c85dd3b78916b63ed077012ff4923fe6d8c	2023-01 a 2023-12	EMITIDAS	119	119	0	55	2026-04-02 16:32:16.625
cmnhp0hzo028rrkt4lo5m445x	2024.csv	9f3cb8d96346d48edeebd45535d601036c8a97a2e45273ce39591e0c6491ff7d	2024-01 a 2024-12	EMITIDAS	208	208	0	36	2026-04-02 16:32:22.548
\.


--
-- Data for Name: lancamentos_manuais; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.lancamentos_manuais (id, "tipoDoc", "numeroDoc", fornecedor, "nifFornecedor", "imovelId", "rubricaId", "dataDoc", "valorSemIva", "taxaIva", "totalComIva", recorrente, periodicidade, "dataFim", notas, "criadoEm", "atualizadoEm", "fracaoId", "retencaoFonte", "valorRetencao") FROM stdin;
cmng0rubk0000rkt4rzqbznl6	RECIBO_VERDE	5846319/1	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2024-09-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:26:01.664	2026-04-01 12:26:01.664	\N	25	227.50
cmng0rue20001rkt4y771etcb	RECIBO_VERDE	5846319/2	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2024-10-02 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:26:01.754	2026-04-01 12:26:01.754	\N	25	227.50
cmng0rufh0002rkt4flmg1q4w	RECIBO_VERDE	5846319/3	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2024-11-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:26:01.806	2026-04-01 12:26:01.806	\N	25	227.50
cmng0rugv0003rkt445i97bdk	RECIBO_VERDE	\N	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2024-12-02 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:26:01.855	2026-04-01 12:26:01.855	\N	25	227.50
cmng11g050004rkt4vmb60cc7	RECIBO_VERDE	5846319/5	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-01-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:29.669	2026-04-01 12:33:29.669	\N	25	227.50
cmng11g280005rkt43pooga88	RECIBO_VERDE	5846319/6	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-02-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:29.744	2026-04-01 12:33:29.744	\N	25	227.50
cmng11g3h0006rkt4mnc674qe	RECIBO_VERDE	5846319/7	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-03-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:29.789	2026-04-01 12:33:29.789	\N	25	227.50
cmng11g4j0007rkt45yyb8i7s	RECIBO_VERDE	5846319/8	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-04-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:29.828	2026-04-01 12:33:29.828	\N	25	227.50
cmng11g620008rkt4845om8r9	RECIBO_VERDE	5846319/9	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-05-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:29.882	2026-04-01 12:33:29.882	\N	25	227.50
cmng11g7g0009rkt4z8n5ia9z	RECIBO_VERDE	5846319/10	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-06-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:29.932	2026-04-01 12:33:29.932	\N	25	227.50
cmng11g8m000arkt4z7zqr9qp	RECIBO_VERDE	5846319/11	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-07-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:29.974	2026-04-01 12:33:29.974	\N	25	227.50
cmng11gah000brkt4py7kgzzw	RECIBO_VERDE	5846319/12	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-08-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:30.041	2026-04-01 12:33:30.041	\N	25	227.50
cmng11gbs000crkt4eexdphzu	RECIBO_VERDE	5846319/13	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-09-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:30.088	2026-04-01 12:33:30.088	\N	25	227.50
cmng11gd1000drkt4q8tvvpbf	RECIBO_VERDE	5846319/14	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-10-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:30.133	2026-04-01 12:33:30.133	\N	25	227.50
cmng11gej000erkt4qp5tsn1r	RECIBO_VERDE	5846319/15	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-11-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:30.187	2026-04-01 12:33:30.187	\N	25	227.50
cmng11gfm000frkt45h4fq609	RECIBO_VERDE	5846319/16	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2025-12-01 00:00:00	910.00	0	910.00	f	\N	\N	\N	2026-04-01 12:33:30.226	2026-04-01 12:33:30.226	\N	25	227.50
cmng1b3ml000grkt4wzx9hsfg	RECIBO_VERDE	4431223/41	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-01-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.189	2026-04-01 12:41:00.189	\N	25	166.01
cmng1b3oi000hrkt4qgphadf6	RECIBO_VERDE	4431223/42	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-02-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.258	2026-04-01 12:41:00.258	\N	25	166.01
cmng1b3pu000irkt4cbiwyt8p	RECIBO_VERDE	4431223/43	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-03-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.306	2026-04-01 12:41:00.306	\N	25	166.01
cmng1b3r6000jrkt46fh2v596	RECIBO_VERDE	4431223/44	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-04-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.354	2026-04-01 12:41:00.354	\N	25	166.01
cmng1b3sh000krkt481ktag2y	RECIBO_VERDE	4431223/45	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-05-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.401	2026-04-01 12:41:00.401	\N	25	166.01
cmng1b3tq000lrkt45x2rsyp9	RECIBO_VERDE	4431223/46	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-06-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.446	2026-04-01 12:41:00.446	\N	25	166.01
cmng1b3v8000mrkt4vqru5ypp	RECIBO_VERDE	4431223/47	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-07-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.5	2026-04-01 12:41:00.5	\N	25	166.01
cmng1b3wj000nrkt4r5cdl59n	RECIBO_VERDE	4431223/48	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-08-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.547	2026-04-01 12:41:00.547	\N	25	166.01
cmng1b3xq000orkt4br62ksin	RECIBO_VERDE	4431223/49	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-09-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.59	2026-04-01 12:41:00.59	\N	25	166.01
cmng1b3z6000prkt4c0l1mplk	RECIBO_VERDE	4431223/50	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-10-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.642	2026-04-01 12:41:00.642	\N	25	166.01
cmng1b40y000qrkt4w4ee3r9q	RECIBO_VERDE	4431223/51	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-11-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.706	2026-04-01 12:41:00.706	\N	25	166.01
cmng1b42g000rrkt4s4axumas	RECIBO_VERDE	4431223/52	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2025-12-01 00:00:00	664.04	23	816.77	f	\N	\N	\N	2026-04-01 12:41:00.761	2026-04-01 12:41:00.761	\N	25	166.01
cmng1e6gr000srkt4l279zsgk	RECIBO_VERDE	4431223/1	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2021-10-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:43:23.835	2026-04-01 12:43:23.835	\N	25	162.50
cmng1e6ib000trkt4k7clhbky	RECIBO_VERDE	4431223/2	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2021-11-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:43:23.891	2026-04-01 12:43:23.891	\N	25	162.50
cmng1e6j6000urkt4qzkk2kvr	RECIBO_VERDE	4431223/3	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2021-12-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:43:23.922	2026-04-01 12:43:23.922	\N	25	162.50
cmng1hrfd000vrkt48kshgmfp	RECIBO_VERDE	4431223/4	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-01-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:10.969	2026-04-01 12:46:10.969	\N	25	162.50
cmng1hrgt000wrkt4gpxh9vry	RECIBO_VERDE	4431223/5	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-02-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.021	2026-04-01 12:46:11.021	\N	25	162.50
cmng1hrif000xrkt4n8hwigdc	RECIBO_VERDE	4431223/6	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-03-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.079	2026-04-01 12:46:11.079	\N	25	162.50
cmng1hrjw000yrkt4yefbmu8r	RECIBO_VERDE	4431223/7	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-04-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.132	2026-04-01 12:46:11.132	\N	25	162.50
cmng1hrld000zrkt43k9pgh1i	RECIBO_VERDE	4431223/8	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-05-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.185	2026-04-01 12:46:11.185	\N	25	162.50
cmng1hrmt0010rkt4ftcre209	RECIBO_VERDE	4431223/9	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-06-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.237	2026-04-01 12:46:11.237	\N	25	162.50
cmng1hroj0011rkt4germlxzj	RECIBO_VERDE	4431223/10	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-07-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.299	2026-04-01 12:46:11.299	\N	25	162.50
cmng1hrqd0012rkt4jaecc14x	RECIBO_VERDE	4431223/11	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-08-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.366	2026-04-01 12:46:11.366	\N	25	162.50
cmng1hrrv0013rkt480s5oux2	RECIBO_VERDE	4431223/12	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-09-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.419	2026-04-01 12:46:11.419	\N	25	162.50
cmng1hrth0014rkt4m56aw2xo	RECIBO_VERDE	4431223/13	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-10-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.477	2026-04-01 12:46:11.477	\N	25	162.50
cmng1hruo0015rkt40iyy283d	RECIBO_VERDE	4431223/14	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-11-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.52	2026-04-01 12:46:11.52	\N	25	162.50
cmng1hrwj0016rkt4m200hme6	RECIBO_VERDE	4431223/15	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2022-12-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:46:11.587	2026-04-01 12:46:11.587	\N	25	162.50
cmng1lxt90017rkt43993z7c8	RECIBO_VERDE	4431223/16	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-01-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:25.869	2026-04-01 12:49:25.869	\N	25	162.50
cmng1lxuw0018rkt4rxedbjwn	RECIBO_VERDE	4431223/17	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-02-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:25.928	2026-04-01 12:49:25.928	\N	25	162.50
cmng1lxw60019rkt4nxgx4zje	RECIBO_VERDE	4431223/18	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-03-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:25.974	2026-04-01 12:49:25.974	\N	25	162.50
cmng1lxxm001arkt4ee8peop1	RECIBO_VERDE	4431223/19	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-04-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.026	2026-04-01 12:49:26.026	\N	25	162.50
cmng1lxyk001brkt4sivp0opy	RECIBO_VERDE	4431223/20	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-05-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.06	2026-04-01 12:49:26.06	\N	25	162.50
cmng1lxzc001crkt47o0mkvyg	RECIBO_VERDE	4431223/21	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-06-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.088	2026-04-01 12:49:26.088	\N	25	162.50
cmng1ly08001drkt4s8mxnaag	RECIBO_VERDE	4431223/22	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-07-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.12	2026-04-01 12:49:26.12	\N	25	162.50
cmng1ly1o001erkt45y2dmuo1	RECIBO_VERDE	4431223/23	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-08-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.172	2026-04-01 12:49:26.172	\N	25	162.50
cmng1ly33001frkt4ow7dtxdv	RECIBO_VERDE	4431223/24	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-09-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.223	2026-04-01 12:49:26.223	\N	25	162.50
cmng1ly52001grkt48nz9lrdp	RECIBO_VERDE	4431223/25	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-10-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.294	2026-04-01 12:49:26.294	\N	25	162.50
cmng1ly6r001hrkt4612le8s1	RECIBO_VERDE	4431223/26	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-11-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.356	2026-04-01 12:49:26.356	\N	25	162.50
cmng1ly83001irkt48owapwg7	RECIBO_VERDE	4431223/27	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2023-12-12 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:49:26.403	2026-04-01 12:49:26.403	\N	25	162.50
cmng1phcg001jrkt4puee9eil	RECIBO_VERDE	4431223/28	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-01-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.152	2026-04-01 12:52:11.152	\N	25	162.50
cmng1phdv001krkt4iffoqdor	RECIBO_VERDE	4431223/29	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-02-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.203	2026-04-01 12:52:11.203	\N	25	162.50
cmng1phes001lrkt4kmhp31bo	RECIBO_VERDE	4431223/30	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-03-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.236	2026-04-01 12:52:11.236	\N	25	162.50
cmng1phfy001mrkt4g66uhoh8	RECIBO_VERDE	4431223/31	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-04-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.278	2026-04-01 12:52:11.278	\N	25	162.50
cmng1phh8001nrkt41bynuhei	RECIBO_VERDE	4431223/33	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-05-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.324	2026-04-01 12:52:11.324	\N	25	162.50
cmng1phk4001orkt4icrahj3x	RECIBO_VERDE	4431223/34	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-06-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.428	2026-04-01 12:52:11.428	\N	25	162.50
cmng1phl9001prkt4a0lmgxet	RECIBO_VERDE	4431223/35	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-07-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.469	2026-04-01 12:52:11.469	\N	25	162.50
cmng1phm5001qrkt4708wbpar	RECIBO_VERDE	4431223/36	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-08-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.501	2026-04-01 12:52:11.501	\N	25	162.50
cmng1pho1001rrkt4tzuarx9r	RECIBO_VERDE	4431223/37	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-09-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.569	2026-04-01 12:52:11.569	\N	25	162.50
cmng1phpg001srkt4fbvb7gee	RECIBO_VERDE	4431223/38	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-10-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.62	2026-04-01 12:52:11.62	\N	25	162.50
cmng1phra001trkt4y8weyoi9	RECIBO_VERDE	4431223/39	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-11-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.686	2026-04-01 12:52:11.686	\N	25	162.50
cmng1pht2001urkt429x6rcc2	RECIBO_VERDE	4431223/40	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2024-12-01 00:00:00	650.00	0	650.00	f	\N	\N	\N	2026-04-01 12:52:11.75	2026-04-01 12:52:11.75	\N	25	162.50
cmng1ufsr001vrkt4t6b6j5ak	RECIBO_VERDE	3906968/1	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2022-10-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 12:56:02.427	2026-04-01 12:56:02.427	\N	25	250.00
cmng1ufug001wrkt4o7ai7gjc	RECIBO_VERDE	3906968/2	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2022-11-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 12:56:02.488	2026-04-01 12:56:02.488	\N	25	250.00
cmng1ufva001xrkt42mxd7min	RECIBO_VERDE	3906968/3	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2022-12-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 12:56:02.518	2026-04-01 12:56:02.518	\N	25	250.00
cmng21bc5001yrkt4grabi9xf	RECIBO_VERDE	3906968/7	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2026-01-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 13:01:23.237	2026-04-01 13:01:23.237	\N	25	250.00
cmng21bea001zrkt4nphlaus7	RECIBO_VERDE	3906968/8	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2026-02-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 13:01:23.314	2026-04-01 13:01:23.314	\N	25	250.00
cmng21bf40020rkt45fkt7sn5	RECIBO_VERDE	3906968/9	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2026-03-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 13:01:23.344	2026-04-01 13:01:23.344	\N	25	250.00
cmng21bgm0021rkt4outiccpj	RECIBO_VERDE	3906968/4	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2025-10-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 13:01:23.398	2026-04-01 13:01:23.398	\N	25	250.00
cmng21bit0022rkt4ojb11zho	RECIBO_VERDE	3906968/5	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2025-11-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 13:01:23.477	2026-04-01 13:01:23.477	\N	25	250.00
cmng21bki0023rkt403hsykq4	RECIBO_VERDE	3906968/6	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2025-12-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-01 13:01:23.538	2026-04-01 13:01:23.538	\N	25	250.00
cmng25cxu0024rkt41tr4ud7c	RECIBO_VERDE	4867641/7	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2026-01-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:04:31.938	2026-04-01 13:04:31.938	\N	25	200.00
cmng25czj0025rkt4lt6p902c	RECIBO_VERDE	4867641/8	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2026-02-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:04:31.999	2026-04-01 13:04:31.999	\N	25	200.00
cmng25d0d0026rkt4re5ve5r0	RECIBO_VERDE	4867641/9	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2026-03-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:04:32.029	2026-04-01 13:04:32.029	\N	25	200.00
cmng25d1j0027rkt4aqyaecrb	RECIBO_VERDE	4867641/1	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2022-10-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:04:32.071	2026-04-01 13:04:32.071	\N	25	200.00
cmng25d2v0028rkt4a55aqeww	RECIBO_VERDE	4867641/2	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2022-11-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:04:32.119	2026-04-01 13:04:32.119	\N	25	200.00
cmng25d450029rkt4kminrmp4	RECIBO_VERDE	4867641/3	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2022-12-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:04:32.165	2026-04-01 13:04:32.165	\N	25	200.00
cmng26c2l002arkt46za5grc0	RECIBO_VERDE	4867641/4	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2025-10-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:05:17.47	2026-04-01 13:05:17.47	\N	25	200.00
cmng26c45002brkt44sxf34yd	RECIBO_VERDE	4867641/5	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2025-11-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:05:17.525	2026-04-01 13:05:17.525	\N	25	200.00
cmng26c52002crkt4xr952oy4	RECIBO_VERDE	4867641/6	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2025-12-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-01 13:05:17.558	2026-04-01 13:05:17.558	\N	25	200.00
cmnl7cnd100001gt4sqr878rg	RECIBO_VERDE	5846319/17	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2026-01-01 00:00:00	931.84	0	931.84	f	\N	\N	\N	2026-04-05 03:29:00.997	2026-04-05 03:29:00.997	\N	25	232.96
cmnl7cnf100011gt4nimeoeex	RECIBO_VERDE	5846319/18	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2026-02-01 00:00:00	931.84	0	931.84	f	\N	\N	\N	2026-04-05 03:29:01.069	2026-04-05 03:29:01.069	\N	25	232.96
cmnl7cng900021gt4i15suko3	RECIBO_VERDE	5846319/19	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2026-03-01 00:00:00	931.84	0	931.84	f	\N	\N	\N	2026-04-05 03:29:01.113	2026-04-05 03:29:01.113	\N	25	232.96
cmnl7cnhm00031gt4r65prcny	RECIBO_VERDE	5846319/20	João Ferreira	167775006	cmnfjeb71002lrgt453z02rn6	cmnfdbzu6000g4wt4502k0iv8	2026-04-01 00:00:00	931.84	0	931.84	f	\N	\N	\N	2026-04-05 03:29:01.162	2026-04-05 03:29:01.162	\N	25	232.96
cmnl7ijey00041gt4ybendiof	RECIBO_VERDE	4431223/53	João Ferreira	167775014	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2026-01-01 00:00:00	678.90	0	678.90	f	\N	\N	\N	2026-04-05 03:33:35.818	2026-04-05 03:33:35.818	\N	25	169.73
cmnl7ijh100051gt4it8swt7p	RECIBO_VERDE	4431223/54	João Ferreira	167775014	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2026-02-01 00:00:00	678.90	0	678.90	f	\N	\N	\N	2026-04-05 03:33:35.893	2026-04-05 03:33:35.893	\N	25	169.73
cmnl7iji700061gt4ytzkh2ok	RECIBO_VERDE	4431223/55	João Ferreira	167775014	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2026-03-01 00:00:00	678.90	0	678.90	f	\N	\N	\N	2026-04-05 03:33:35.935	2026-04-05 03:33:35.935	\N	25	169.73
cmnl7ijjd00071gt44me1lo5c	RECIBO_VERDE	4431223/56	João Ferreira	167775006	cmnfjiu0f002trgt4r83oahan	cmnfdbzu6000g4wt4502k0iv8	2026-04-01 00:00:00	678.90	0	678.90	f	\N	\N	\N	2026-04-05 03:33:35.977	2026-04-05 03:39:44.665	\N	25	169.73
cmnl7njtd00081gt4id5p845m	RECIBO_VERDE	3906968/10	João Carlos Ferreira	167775014	cmnfig5t40005rgt4visli2qu	cmnfdbzu6000g4wt4502k0iv8	2026-04-01 00:00:00	1000.00	0	1000.00	f	\N	\N	\N	2026-04-05 03:37:29.617	2026-04-05 03:40:49.419	\N	25	250.00
cmnl7sjwy00091gt4hp4ia0ga	RECIBO_VERDE	4867641/10	João Carlos Ferreira	167775014	cmnfh60wc001ejot4uioz8q1l	cmnfdbzu6000g4wt4502k0iv8	2026-04-01 00:00:00	800.00	0	800.00	f	\N	\N	\N	2026-04-05 03:41:23.026	2026-04-05 03:41:23.026	\N	25	200.00
\.


--
-- Data for Name: nif_imovel_map; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.nif_imovel_map (id, "nifEntidade", "imovelId", "rubricaId", ativo, "criadoEm", "fracaoId") FROM stdin;
cmnflek8b01pthgt4lu7r5jn3	261849450	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:15:47.819	cmnfkp2vg00zmhgt4890h7c56
cmnflezam01q1hgt4u77ze9rz	264947800	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:16:07.342	cmnfkt2br0103hgt4yaylhkk7
cmnflfdti01q9hgt4qp12wh31	274734338	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:16:26.166	cmnfkvrla010ehgt4pntoyk13
cmnflfs5a01qhhgt476qjpx1y	261803310	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:16:44.734	cmnfkpkhd00zphgt4elqe9l29
cmnflg4s301qwhgt4oqk6ultp	255364962	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:17:01.107	cmnfkqexq00zthgt4g4n1fbfy
cmnflgi3001rahgt47giesgo5	244984883	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:17:18.348	cmnfkvenc010chgt44uzjdcc6
cmnflgtpi01rohgt4pjdum7d2	259933015	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:17:33.414	cmnfksd8d0101hgt4l62jg4a7
cmnflh4op01rwhgt4zgvgpyd5	270909028	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:17:47.641	cmnfkqspm00zuhgt4hu2eqk4l
cmnflhdrx01sahgt4bzgcxios	262961512	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:17:59.421	cmnfkr6pe00zwhgt4j7vbb5vx
cmnflhpcs01sohgt4myov59b6	263053725	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:18:14.428	cmnfkvrla010ehgt4pntoyk13
cmnflhyub01swhgt4zb7evscl	266827560	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:18:26.723	cmnfkskbx0102hgt4wp2stj9s
cmnfli9bk01t4hgt4so852r8d	266475540	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:18:40.304	cmnfks7y90100hgt4htds26dj
cmnflik0v01tchgt4mokxi4kj	265435463	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:18:54.175	cmnfkpwhq00zrhgt4kwye95fl
cmnflium601tkhgt4wsffy0vz	258449233	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:19:07.902	cmnfkpf0u00zohgt40qewt2f3
cmnflj5aj01u0hgt4zpj212fl	261598619	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:19:21.739	cmnfkrvw300zyhgt403qbk0s6
cmnfljfst01u8hgt4qb1mtf5l	261748955	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:19:35.357	cmnfkrcpl00zxhgt4sxtmnh6n
cmnfljprp01ughgt461aggdge	260913375	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:19:48.277	cmnfkv17r010ahgt4x5dtkz2a
cmnflk03p01uohgt4j81ixyd8	262305330	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:20:01.669	cmnfkr0x200zvhgt4bdrsp2u0
cmnflkb3u01uwhgt4fiip7q8g	266588255	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:20:15.93	cmnfks14q00zzhgt47kj8x90e
cmnflklvy01v4hgt4fp449e2z	260754145	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:20:29.902	cmnfkt8q40104hgt41ma5h63p
cmnflkuqs01vehgt40g5vxwvi	256125627	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:20:41.38	cmnfkq1wt00zshgt4nv418741
cmnfll5x101vshgt47oxou41f	254708528	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:20:55.861	cmnfkp8nw00znhgt4wtrtzofm
cmnfllfkl01w0hgt4gcpmhyxd	223482900	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:21:08.373	cmnfl616e01cdhgt468d1xir6
cmnfllsr301wehgt4hm418fgp	248797239	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:21:25.455	cmnfkvkyn010dhgt4qymxazu8
cmnflm4tc01wphgt4zgxus5q9	252916077	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:21:41.088	cmnfkr0x200zvhgt4bdrsp2u0
cmnflmewa01wyhgt4aqe3zefh	266277055	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:21:54.154	cmnfkpwhq00zrhgt4kwye95fl
cmnflmlkc01x8hgt45rvpdv7f	167775014	cmnffta06000068t4x50l5rq5	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:22:02.796	\N
cmnflmvnt01xdhgt49xpq74a7	253278716	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:22:15.881	cmnfkrvw300zyhgt403qbk0s6
cmnfln7xz01xlhgt4ihvkigjs	257665072	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:22:31.799	cmnfkvkyn010dhgt4qymxazu8
cmnflni1101xvhgt46w4yi31c	259676136	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:22:44.869	cmnfkvrla010ehgt4pntoyk13
cmnflnr6o01y4hgt424f06m85	258836989	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:22:56.736	cmnfks7y90100hgt4htds26dj
cmnflo08501ydhgt4781hqzjc	262387085	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:23:08.453	cmnfks14q00zzhgt47kj8x90e
cmnfloas701ylhgt4kvg17kzr	257675841	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:23:22.135	cmnfksd8d0101hgt4l62jg4a7
cmnfloiqm01yvhgt4j7k0nxck	267439130	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:23:32.446	cmnfkskbx0102hgt4wp2stj9s
cmnfloupa01z3hgt4skkxunh2	330615254	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:23:47.95	cmnfkp2vg00zmhgt4890h7c56
cmnflp5gx01z6hgt44gn4myzi	330742213	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:24:01.905	cmnfkpq1m00zqhgt4hjec3t2c
cmnflpndw01z9hgt4k56q4ydo	234850876	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:24:25.124	cmnfkrcpl00zxhgt4sxtmnh6n
cmnflpx1t01zghgt411rhzz3s	255497393	cmnfjeb71002lrgt453z02rn6	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:24:37.649	cmnfkp2vg00zmhgt4890h7c56
cmnflrokm023bhgt4p2l8b78u	41317182164	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:25:59.974	cmnfkqspm00zuhgt4hu2eqk4l
cmnflrzkg023ghgt40ke8iftq	323867081	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-01 05:26:14.224	cmnfkv8t7010bhgt4yrqs8e67
cmnfm2hu4025shgt4peewwezy	503630330	cmnffta06000068t4x50l5rq5	cmnfdbztl000d4wt43vq268qd	t	2026-04-01 05:34:24.46	\N
cmnfm2vd9025vhgt4r3jgcs4t	510450024	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	t	2026-04-01 05:34:41.998	\N
cmnfm361k0260hgt4bk9y62vu	502022892	cmnffta06000068t4x50l5rq5	cmnfdbzt9000b4wt41cdb6n2l	t	2026-04-01 05:34:55.832	\N
cmnfm4niu0268hgt4tgv2weit	513325417	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	t	2026-04-01 05:36:05.142	\N
cmnfm6m7d026chgt4xi0gsizt	514280956	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	t	2026-04-01 05:37:36.745	\N
cmnfm4cv90264hgt4aa8d4x44	516222201	cmnfig5t40005rgt4visli2qu	cmnfdbzsf00064wt4plz0ps6i	t	2026-04-01 05:35:51.333	\N
cmnfm7qcv026hhgt421xnspbt	516520741	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	t	2026-04-01 05:38:28.783	\N
cmnfm88ma026khgt4ufmjpnyo	514798726	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	t	2026-04-01 05:38:52.45	\N
cmnfm8lwq026nhgt4auoinp2b	506848558	cmnfj5zjx002grgt4zqkobyno	cmnfdbzsl00074wt4lub1r7uv	t	2026-04-01 05:39:09.674	\N
cmnfm8v0l026uhgt49xgc9z7i	515373842	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	t	2026-04-01 05:39:21.477	\N
cmnfmav2r026yhgt42s4ixf2u	500393729	cmnffta06000068t4x50l5rq5	cmnfdbzsr00084wt4mln9j5z9	t	2026-04-01 05:40:54.867	\N
cmnfmb8ba0271hgt4jb4o0m0x	509520561	cmnfj5zjx002grgt4zqkobyno	cmnfdbzt9000b4wt41cdb6n2l	t	2026-04-01 05:41:12.022	\N
cmng2zdo40037rkt4wo5dscv8	518417948	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	t	2026-04-01 13:27:52.564	\N
cmng346xn003jrkt4q7oraagv	502201657	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	t	2026-04-01 13:31:37.115	\N
cmng38kwe003rrkt4x9706vjl	517514419	cmnfjeb71002lrgt453z02rn6	cmnfdbztf000c4wt4bw3u07ib	t	2026-04-01 13:35:01.838	\N
cmngeo9ls00x1rkt4786qwkgc	516697030	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	t	2026-04-01 18:55:09.472	\N
cmngeoxmh00x4rkt47mgvpizi	507718666	cmnfjeb71002lrgt453z02rn6	cmnfdbzsx00094wt4dm87uxvd	t	2026-04-01 18:55:40.601	\N
cmngerpgb00xwrkt4bdgni6ql	502075090	cmnffta06000068t4x50l5rq5	cmnfdbztf000c4wt4bw3u07ib	t	2026-04-01 18:57:49.979	\N
cmnges9rd00yarkt47vj0xmbz	515337498	cmnffta06000068t4x50l5rq5	cmnfdbzsl00074wt4lub1r7uv	t	2026-04-01 18:58:16.297	\N
cmnho3dja00zirkt405uqyxvr	516527835	cmnffta06000068t4x50l5rq5	cmnfdbzs200044wt42619eodz	t	2026-04-02 16:06:37.126	\N
cmnhq9rhw02jerkt4tvr3wse7	226804747	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 17:07:34.388	cmnfkrvw300zyhgt403qbk0s6
cmnhqa2sl02k9rkt4byupyoie	516369652	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 17:07:49.03	cmnfkqexq00zthgt4g4n1fbfy
cmnhqaztc02kzrkt4z9bhgd8v	251114996	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 17:08:31.824	cmnfkv17r010ahgt4x5dtkz2a
cmnhr9tm702m2rkt4iuwxtb4h	251701212	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 17:35:36.752	cmnfks14q00zzhgt47kj8x90e
cmnhra9k202mgrkt4fjxf39eo	243483627	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 17:35:57.41	cmnfkskbx0102hgt4wp2stj9s
cmnhranig02murkt4dm9xjyz8	249613018	cmnfh60wc001ejot4uioz8q1l	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 17:36:15.496	cmnfkrcpl00zxhgt4sxtmnh6n
cmnhrd2qy02n7rkt47jwxnh2g	248538446	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 17:38:08.554	cmnfkvrla010ehgt4pntoyk13
cmnhtjh2o00026st4amrrizf0	264769953	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 18:39:06.288	cmnfkvkyn010dhgt4qymxazu8
cmnhtjtzs000g6st4nuzx4mpj	307451348	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 18:39:23.032	cmnfksd8d0101hgt4l62jg4a7
cmnhtk5nh000n6st49taxbq8i	224974963	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 18:39:38.141	cmnfksd8d0101hgt4l62jg4a7
cmnhtkhl000106st4i3bhfx2f	272868906	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 18:39:53.604	cmnfks14q00zzhgt47kj8x90e
cmnhtkt0o00146st4y75uk8p5	253023548	cmnfjiu0f002trgt4r83oahan	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 18:40:08.424	cmnfkv8t7010bhgt4yrqs8e67
cmnhtl37600176st4yrn0fv9i	221761144	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 18:40:21.618	cmnfksd8d0101hgt4l62jg4a7
cmnhtlul0001h6st4v83xaob3	304817341	cmnfig5t40005rgt4visli2qu	cmnfdbzrv00034wt4lccmw9wp	t	2026-04-02 18:40:57.108	cmnfks14q00zzhgt47kj8x90e
\.


--
-- Data for Name: rubricas; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.rubricas (id, codigo, nome, tipo, ordem) FROM stdin;
cmnfdbzrv00034wt4lccmw9wp	REC	Receita	RECEITA	0
cmnfdbzs200044wt42619eodz	CMB	Combustivel	GASTO	1
cmnfdbzsa00054wt4rildbdz8	CAF	Compras de Ativo Fixo	GASTO	2
cmnfdbzsf00064wt4plz0ps6i	COM	Comunicacoes	GASTO	3
cmnfdbzsl00074wt4lub1r7uv	CRP	Conservacao e Reparacao	GASTO	4
cmnfdbzsr00084wt4mln9j5z9	DES	Deslocacoes e Estadas	GASTO	5
cmnfdbzsx00094wt4dm87uxvd	AGU	Gastos de Agua	GASTO	6
cmnfdbzt4000a4wt4u1f07hjs	ELE	Gastos de Electricidade	GASTO	7
cmnfdbzt9000b4wt41cdb6n2l	HON	Honorarios e Comissoes	GASTO	8
cmnfdbztf000c4wt4bw3u07ib	LHC	Limpeza Higiene e Conforto	GASTO	9
cmnfdbztl000d4wt43vq268qd	MAT	Material de Escritorio	GASTO	10
cmnfdbztr000e4wt4u3dc57us	SEG	Seguros	GASTO	11
cmnfdbzu0000f4wt4ceh7ug18	GAS	Gastos de Gas	GASTO	12
cmnfdbzu6000g4wt4502k0iv8	RDA	Rendas e Alugueres	GASTO	13
cmnfdbzub000h4wt4ywojkc87	OUT	Outros Gastos	GASTO	14
cmnhqeg5v0000vst4rvnok7mb	RJB	Receita (Juros Bancarios)	RECEITA	-4
cmnhqeg660001vst48gwpb387	RSV	Receita (Prestacao Servicos)	RECEITA	-3
cmnhqeg6i0002vst43uto3kxx	RDV	Receita (Outras Receitas)	RECEITA	-2
\.


--
-- Data for Name: utilizadores; Type: TABLE DATA; Schema: public; Owner: imoveo
--

COPY public.utilizadores (id, nome, email, "passwordHash", role, ativo, "criadoEm", "atualizadoEm", "ultimoLogin") FROM stdin;
cmnfdbzr600014wt4op9j12we	Gestor	gestor@imoveo.local	$2b$12$.ljDbJ/giFRDz2yN0..6n.Cq.xYGNVtiTDz276H4QD1tTd2IgixCe	GESTOR	t	2026-04-01 01:29:51.042	2026-04-01 01:29:51.042	\N
cmnfdbzrk00024wt44c2oj30j	Operador	operador@imoveo.local	$2b$12$.ljDbJ/giFRDz2yN0..6n.Cq.xYGNVtiTDz276H4QD1tTd2IgixCe	OPERADOR	t	2026-04-01 01:29:51.056	2026-04-01 01:29:51.056	\N
cmnfdbzqp00004wt4nqca6dsi	Administrador	admin@imoveo.local	$2b$12$.ljDbJ/giFRDz2yN0..6n.Cq.xYGNVtiTDz276H4QD1tTd2IgixCe	ADMIN	t	2026-04-01 01:29:51.026	2026-04-01 02:45:24.692	2026-04-01 02:45:24.692
\.


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: configuracoes configuracoes_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.configuracoes
    ADD CONSTRAINT configuracoes_pkey PRIMARY KEY (id);


--
-- Name: entidades entidades_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.entidades
    ADD CONSTRAINT entidades_pkey PRIMARY KEY (id);


--
-- Name: fatura_classificacao fatura_classificacao_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.fatura_classificacao
    ADD CONSTRAINT fatura_classificacao_pkey PRIMARY KEY (id);


--
-- Name: faturas faturas_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.faturas
    ADD CONSTRAINT faturas_pkey PRIMARY KEY (id);


--
-- Name: fracoes fracoes_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.fracoes
    ADD CONSTRAINT fracoes_pkey PRIMARY KEY (id);


--
-- Name: imoveis imoveis_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.imoveis
    ADD CONSTRAINT imoveis_pkey PRIMARY KEY (id);


--
-- Name: importacoes importacoes_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.importacoes
    ADD CONSTRAINT importacoes_pkey PRIMARY KEY (id);


--
-- Name: lancamentos_manuais lancamentos_manuais_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.lancamentos_manuais
    ADD CONSTRAINT lancamentos_manuais_pkey PRIMARY KEY (id);


--
-- Name: nif_imovel_map nif_imovel_map_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.nif_imovel_map
    ADD CONSTRAINT nif_imovel_map_pkey PRIMARY KEY (id);


--
-- Name: rubricas rubricas_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.rubricas
    ADD CONSTRAINT rubricas_pkey PRIMARY KEY (id);


--
-- Name: utilizadores utilizadores_pkey; Type: CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.utilizadores
    ADD CONSTRAINT utilizadores_pkey PRIMARY KEY (id);


--
-- Name: configuracoes_chave_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX configuracoes_chave_key ON public.configuracoes USING btree (chave);


--
-- Name: entidades_nif_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX entidades_nif_key ON public.entidades USING btree (nif);


--
-- Name: fatura_classificacao_faturaId_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX "fatura_classificacao_faturaId_key" ON public.fatura_classificacao USING btree ("faturaId");


--
-- Name: faturas_dataFatura_idx; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE INDEX "faturas_dataFatura_idx" ON public.faturas USING btree ("dataFatura");


--
-- Name: faturas_hashFatura_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX "faturas_hashFatura_key" ON public.faturas USING btree ("hashFatura");


--
-- Name: faturas_nifDestinatario_idx; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE INDEX "faturas_nifDestinatario_idx" ON public.faturas USING btree ("nifDestinatario");


--
-- Name: faturas_nifEmitente_idx; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE INDEX "faturas_nifEmitente_idx" ON public.faturas USING btree ("nifEmitente");


--
-- Name: faturas_nifEmitente_serieDoc_numeroDoc_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX "faturas_nifEmitente_serieDoc_numeroDoc_key" ON public.faturas USING btree ("nifEmitente", "serieDoc", "numeroDoc");


--
-- Name: imoveis_codigo_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX imoveis_codigo_key ON public.imoveis USING btree (codigo);


--
-- Name: importacoes_hashFicheiro_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX "importacoes_hashFicheiro_key" ON public.importacoes USING btree ("hashFicheiro");


--
-- Name: lancamentos_manuais_dataDoc_idx; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE INDEX "lancamentos_manuais_dataDoc_idx" ON public.lancamentos_manuais USING btree ("dataDoc");


--
-- Name: lancamentos_manuais_imovelId_idx; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE INDEX "lancamentos_manuais_imovelId_idx" ON public.lancamentos_manuais USING btree ("imovelId");


--
-- Name: nif_imovel_map_nifEntidade_idx; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE INDEX "nif_imovel_map_nifEntidade_idx" ON public.nif_imovel_map USING btree ("nifEntidade");


--
-- Name: nif_imovel_map_nifEntidade_imovelId_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX "nif_imovel_map_nifEntidade_imovelId_key" ON public.nif_imovel_map USING btree ("nifEntidade", "imovelId");


--
-- Name: rubricas_codigo_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX rubricas_codigo_key ON public.rubricas USING btree (codigo);


--
-- Name: utilizadores_email_key; Type: INDEX; Schema: public; Owner: imoveo
--

CREATE UNIQUE INDEX utilizadores_email_key ON public.utilizadores USING btree (email);


--
-- Name: fatura_classificacao fatura_classificacao_faturaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.fatura_classificacao
    ADD CONSTRAINT "fatura_classificacao_faturaId_fkey" FOREIGN KEY ("faturaId") REFERENCES public.faturas(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fatura_classificacao fatura_classificacao_fracaoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.fatura_classificacao
    ADD CONSTRAINT "fatura_classificacao_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES public.fracoes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fatura_classificacao fatura_classificacao_imovelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.fatura_classificacao
    ADD CONSTRAINT "fatura_classificacao_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES public.imoveis(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fatura_classificacao fatura_classificacao_rubricaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.fatura_classificacao
    ADD CONSTRAINT "fatura_classificacao_rubricaId_fkey" FOREIGN KEY ("rubricaId") REFERENCES public.rubricas(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: faturas faturas_importacaoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.faturas
    ADD CONSTRAINT "faturas_importacaoId_fkey" FOREIGN KEY ("importacaoId") REFERENCES public.importacoes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fracoes fracoes_imovelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.fracoes
    ADD CONSTRAINT "fracoes_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES public.imoveis(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lancamentos_manuais lancamentos_manuais_fracaoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.lancamentos_manuais
    ADD CONSTRAINT "lancamentos_manuais_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES public.fracoes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: lancamentos_manuais lancamentos_manuais_imovelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.lancamentos_manuais
    ADD CONSTRAINT "lancamentos_manuais_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES public.imoveis(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lancamentos_manuais lancamentos_manuais_rubricaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.lancamentos_manuais
    ADD CONSTRAINT "lancamentos_manuais_rubricaId_fkey" FOREIGN KEY ("rubricaId") REFERENCES public.rubricas(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: nif_imovel_map nif_imovel_map_fracaoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.nif_imovel_map
    ADD CONSTRAINT "nif_imovel_map_fracaoId_fkey" FOREIGN KEY ("fracaoId") REFERENCES public.fracoes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: nif_imovel_map nif_imovel_map_imovelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.nif_imovel_map
    ADD CONSTRAINT "nif_imovel_map_imovelId_fkey" FOREIGN KEY ("imovelId") REFERENCES public.imoveis(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: nif_imovel_map nif_imovel_map_nifEntidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.nif_imovel_map
    ADD CONSTRAINT "nif_imovel_map_nifEntidade_fkey" FOREIGN KEY ("nifEntidade") REFERENCES public.entidades(nif) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: nif_imovel_map nif_imovel_map_rubricaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: imoveo
--

ALTER TABLE ONLY public.nif_imovel_map
    ADD CONSTRAINT "nif_imovel_map_rubricaId_fkey" FOREIGN KEY ("rubricaId") REFERENCES public.rubricas(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict fHwJw9kpTgjEa2vTUA5t2uWzQnppzqxBwI0jMHsI9MzcZNDhmOSoLpS15DUdLAC

