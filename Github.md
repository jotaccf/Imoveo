# IMOVEO — Workflow DevOps
> Prompt para Claude Code (VS Code Extension)
> Copia e cola no Claude Code após cada sessão de desenvolvimento.

---

## INSTRUÇÃO DE ARRANQUE

```
És o DevOps e Tech Lead do projecto Imoveo.
Lê o ficheiro IMOVEO_BUILD.md antes de começar.
Executa as seguintes operações de forma autónoma.
Aguarda confirmação de sucesso em cada passo.
```

---

## PASSO 1 — Analisar alterações

```bash
git status
git diff --stat
```

Analisa todos os ficheiros alterados e determina:
- Que funcionalidades foram adicionadas
- Que bugs foram corrigidos
- Que ficheiros de configuração mudaram
- Qual o tipo de alteração predominante (feature / fix / config / refactor)

Examina especificamente:
- `prisma/schema.prisma` — alterações ao modelo de dados
- `src/app/api/**` — novos endpoints ou alterações
- `src/components/**` — componentes UI novos ou alterados
- `src/lib/**` — lógica de negócio (xml-parser, deduplicacao, classificacao)
- `docker-compose*.yml` — alterações de infraestrutura
- `electron/**` — alterações à app desktop

---

## PASSO 2 — Determinar versão

Lê a versão actual:
```bash
grep '"version"' package.json
```

Com base nas alterações detectadas no Passo 1,
determina se o incremento deve ser:

```
PATCH (x.x.+1) — bug fixes, correcções de UI, ajustes de configuração
MINOR (x.+1.0) — nova funcionalidade compatível (novo ecrã, nova métrica, nova API)
MAJOR (+1.0.0) — alteração estrutural (schema BD incompatível, breaking API change)
```

Formato da versão Imoveo: `MAJOR.MINOR.PATCH`
Versão inicial: `1.0.0`

Propõe a nova versão com raciocínio claro.
**Aguarda confirmação antes de avançar.**

---

## PASSO 3 — Actualizar versão

Actualiza a versão em `package.json`:
```bash
# Exemplo: de 1.0.0 para 1.1.0
sed -i 's/"version": ".*"/"version": "X.X.X"/' package.json
```

Verificar que foi actualizado:
```bash
grep '"version"' package.json
```

---

## PASSO 4 — Actualizar CHANGELOG.md

Adiciona nova entrada no **topo** do `CHANGELOG.md`
com formato Keep a Changelog:

```markdown
## [X.X.X] — YYYY-MM-DD

### Added
- (lista de funcionalidades novas)

### Changed
- (lista de alterações a funcionalidades existentes)

### Fixed
- (lista de bugs corrigidos)

### Database
- (alterações ao schema Prisma ou migrations)

### Security
- (alterações de autenticação, permissões RBAC, SSL)

### Infrastructure
- (alterações Docker, Nginx, dnsmasq, scripts de instalação)
```

Usa apenas as secções relevantes.
**Não inventar — apenas o que foi efectivamente alterado.**

Se `CHANGELOG.md` não existir, criá-lo com:
```markdown
# Changelog — Imoveo
Todas as alterações notáveis a este projecto estão documentadas aqui.
Formato: [Keep a Changelog](https://keepachangelog.com/pt-PT/1.0.0/)

---
```

---

## PASSO 5 — Actualizar ROADMAP.md

No `ROADMAP.md`:

1. Marca como `[x]` todos os itens implementados
   nas alterações desta sessão

2. Se a versão actual ficou completa
   (todos os itens `[x]`):
   - Muda status de `🔄 In Development` para `✅ Released`
   - Adiciona a data de release

3. Se existe uma próxima versão no roadmap:
   - Muda status de `📋 Planned` para `🔄 In Development`
   - Actualiza Target date se necessário

4. Verifica se há itens novos a adicionar ao roadmap
   com base nas alterações feitas

Se `ROADMAP.md` não existir, criá-lo com estrutura base:

```markdown
# Imoveo — Roadmap

## v1.0.0 — Base ✅ Released
- [x] Setup Next.js + TypeScript + Tailwind
- [x] Schema Prisma completo
- [x] Autenticação NextAuth (RBAC 3 perfis)
- [x] Parser XML SAFT-PT + deduplicação
- [x] API Routes completa
- [x] Dashboard + todos os ecrãs
- [x] Docker Compose produção
- [x] Installer Ubuntu (server-setup.sh + install.sh)

## v1.1.0 — Análise financeira 🔄 In Development
Target: (data estimada)
- [ ] Módulo de métricas imobiliárias (yield, DSCR, ROI)
- [ ] Calculadora financeira integrada nos resultados
- [ ] Alertas automáticos por threshold de yield
- [ ] Relatório PDF com métricas financeiras

## v1.2.0 — Electron desktop 📋 Planned
Target: (data estimada)
- [ ] Electron wrapper com PostgreSQL embutido
- [ ] Instalador Windows (.exe NSIS)
- [ ] Instalador macOS (.dmg)
- [ ] Instalador Linux (.AppImage)
- [ ] Auto-updater via GitHub Releases

## v2.0.0 — Multi-empresa 📋 Planned
Target: (data estimada)
- [ ] Suporte multi-tenant
- [ ] Isolamento de dados por empresa
- [ ] Gestão de subscriptions
```

---

## PASSO 6 — Actualizar DEVLOG.md

Adiciona nova entrada de sessão em `DEVLOG.md`:

```markdown
## SESSÃO [N] — [data de hoje]

### O que foi feito
- (resumo das alterações desta sessão)

### Decisões técnicas tomadas
- (decisões de arquitectura ou implementação relevantes)

### Problemas encontrados e soluções
- (erros encontrados durante o desenvolvimento e como foram resolvidos)

### Alterações ao schema da BD
- (migrations criadas, tabelas alteradas)

### Estado actual
- ✅ Implementado: (lista)
- ⏳ Em curso: (lista)
- 📋 Pendente: (lista)

### Notas para a próxima sessão
- (contexto importante a não esquecer)
```

Se `DEVLOG.md` não existir, criá-lo agora.

---

## PASSO 7 — Correr testes

```bash
# Testes unitários e de integração
npm test

# Se houver falhas, mostrar detalhes completos
npm test -- --verbose 2>&1 | tail -50
```

Se algum teste falhar:
- **PARA imediatamente**
- Mostra o erro completo
- Corrige o problema
- Volta a correr os testes
- **Só avança quando todos passarem**

Se não houver testes escritos ainda:
```bash
# Verificar que o build compila sem erros
npm run build
```

---

## PASSO 8 — Verificar migrações Prisma pendentes

```bash
# Verificar se há alterações ao schema não migradas
npx prisma migrate status
```

Se houver migrações pendentes:
```bash
# Em desenvolvimento
npx prisma migrate dev --name "descricao_da_alteracao"

# Verificar que o cliente foi regenerado
npx prisma generate
```

---

## PASSO 9 — Commit

Verifica que `.env.local` e `.env.prod` **NÃO** estão nos ficheiros staged:
```bash
git status
```

Se aparecerem, remover:
```bash
git reset HEAD .env.local
git reset HEAD .env.prod
```

Verificar `.gitignore` inclui os ficheiros sensíveis:
```bash
grep -E "\.env" .gitignore
```

Adicionar todos os ficheiros:
```bash
git add .
git status  # confirmar o que vai no commit
```

Gerar mensagem de commit profissional seguindo
[Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "tipo(âmbito): descrição curta e clara

- detalhe 1
- detalhe 2
- detalhe 3

Version: X.X.X
Refs: #issue (se aplicável)
Signed-off-by: SEU_NOME"
```

**Tipos de commit Imoveo:**
```
feat      — nova funcionalidade
fix       — correcção de bug
refactor  — refactor sem mudança de comportamento
style     — alterações de UI/CSS sem lógica
docs      — documentação
test      — testes
chore     — manutenção, dependências, config
db        — alterações ao schema/migrations Prisma
infra     — Docker, Nginx, scripts de instalação
security  — autenticação, permissões, SSL
```

**Âmbitos Imoveo:**
```
auth, imoveis, faturas, lancamentos, resultados,
pendentes, mapeamento, utilizadores, xml-parser,
deduplicacao, dashboard, electron, installer, api
```

**Exemplos:**
```
feat(resultados): adicionar cálculo de yield líquida e DSCR
fix(xml-parser): corrigir separação série/número em formato A/2024/1
db(imoveis): adicionar campo area_m2 à tabela imoveis
infra(installer): adicionar suporte a Ubuntu 24.04
```

---

## PASSO 10 — Push para GitHub

```bash
git push origin dev
```

Se for uma release **MINOR ou MAJOR**:
```bash
git checkout main
git merge dev --no-ff -m "merge: release vX.X.X"
git push origin main
git checkout dev
```

---

## PASSO 11 — Criar Release (se aplicável)

**Só executar se o incremento for MINOR ou MAJOR.**
Para PATCH, saltar este passo.

```bash
# Criar tag anotada
git tag -a vX.X.X -m "Imoveo vX.X.X"
git push origin vX.X.X

# Criar release no GitHub
gh release create vX.X.X \
  --title "Imoveo vX.X.X — [nome descritivo da versão]" \
  --notes "$(cat << 'NOTES'
## O que há de novo em vX.X.X

(resumo das principais funcionalidades em linguagem não técnica)

## Alterações
(lista das alterações do CHANGELOG — copiar directamente)

## Instalação
Ver [README.md](README.md) para instruções de instalação.

### Instalação rápida (Ubuntu):
\`\`\`bash
# 1. Configurar servidor (uma vez)
curl -fsSL https://raw.githubusercontent.com/SEU_UTILIZADOR/imoveo/main/server-setup.sh | sudo bash

# 2. Instalar Imoveo
curl -fsSL https://raw.githubusercontent.com/SEU_UTILIZADOR/imoveo/main/install.sh | sudo bash
\`\`\`

**Stack:** Next.js 14 · PostgreSQL 16 · Docker
**Requer:** Ubuntu 22.04+ com Docker instalado
**Autor:** SEU_NOME
NOTES
)" \
  --repo SEU_UTILIZADOR/imoveo
```

Se for Release Candidate: adicionar `--prerelease`
Se for produção estável: não adicionar `--prerelease`

Para a **versão Electron** (quando chegar a v1.2.0):
```bash
# Fazer attach dos instaladores à release
gh release upload vX.X.X \
  dist/Imoveo\ Setup\ X.X.X.exe \
  dist/Imoveo-X.X.X.dmg \
  dist/Imoveo-X.X.X.AppImage \
  --repo SEU_UTILIZADOR/imoveo
```

---

## PASSO 12 — Resumo final

Apresenta resumo formatado da operação completa:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  IMOVEO — Resumo da sessão DevOps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMIT:
  Hash:    (git log --oneline -1)
  Branch:  (branch actual)
  Versão:  X.X.X → X.X.X

GITHUB:
  Push:    ✅ origin/dev
  URL:     https://github.com/SEU_UTILIZADOR/imoveo

DOCUMENTAÇÃO ACTUALIZADA:
  CHANGELOG.md     ✅ nova entrada adicionada
  ROADMAP.md       ✅ checklist actualizado
  DEVLOG.md        ✅ sessão registada
  package.json     ✅ versão actualizada

TESTES:
  Resultado:  ✅ X passed / ❌ X failed
  Coverage:   X%

MIGRAÇÕES PRISMA:
  Estado:  ✅ em dia / ⚠️ pendente

RELEASE:
  (se criada)  vX.X.X publicada ✅
               https://github.com/SEU_UTILIZADOR/imoveo/releases/tag/vX.X.X
  (se não)     PATCH — sem release necessária

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESSÃO:
  Branch:   dev
  Target:   vX.X.X — (nome da próxima versão)
  Pendente: (lista resumida dos próximos itens do roadmap)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Referências rápidas

### Comandos úteis durante desenvolvimento

```bash
# Ver estado dos containers Docker
docker compose -f docker-compose.yml ps

# Ver logs em tempo real
docker compose -f docker-compose.yml logs -f app

# Abrir Prisma Studio (interface visual da BD)
npx prisma studio

# Reset completo da BD de desenvolvimento
npm run db:reset

# Correr em modo desenvolvimento
npm run dev

# Correr app Electron em desenvolvimento
npm run electron:dev

# Build para produção
npm run build

# Build instaladores Electron
npm run electron:build
```

### Estrutura de branches Imoveo

```
main        — produção estável (só recebe merges de dev via release)
dev         — desenvolvimento activo (commits diários aqui)
feature/*   — funcionalidades maiores (merge para dev quando prontas)
fix/*       — hotfixes urgentes (merge para dev e main)
```

### Checklist de segurança antes de cada commit

```
[ ] .env.local não está staged
[ ] .env.prod não está staged
[ ] Nenhuma password hardcoded no código
[ ] Nenhum token ou chave API no código
[ ] NEXTAUTH_SECRET não está exposto
[ ] Ficheiros de upload não estão staged (/uploads/)
[ ] node_modules não está staged
```