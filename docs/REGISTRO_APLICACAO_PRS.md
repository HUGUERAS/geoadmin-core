# Registro de Aplicacao de PRs — GeoAdmin Core

Historico de PRs aplicados neste workspace, com detalhes de cada operacao.

---

## PR #1 — Prepare Cloud Run and Vercel cutover foundation

- **Branch:** `codex/cloud-run-cutover-foundation`
- **Status:** Aplicado (clone direto do branch)
- **Commit base:** `a38eb99`
- **Data de aplicacao:** 2026-04-09

### Arquivos introduzidos/modificados

| Arquivo | Tipo | Descricao |
|---|---|---|
| `backend/Dockerfile` | Novo | Container Python 3.12 + proj-bin para Cloud Run (porta 8080) |
| `backend/.dockerignore` | Novo | Exclui cache, testes, .env do build Docker |
| `backend/.env.example` | Modificado | Adicionado `*.run.app` em ALLOWED_HOSTS |
| `backend/main.py` | Modificado | `*.run.app` nos hosts padrao |
| `mobile/lib/api.ts` | Modificado | URL da API via EXPO_PUBLIC_API_BASE_URL, fallback Railway |
| `mobile/.env.example` | Novo | Template com EXPO_PUBLIC_API_BASE_URL |
| `.github/workflows/deploy-web.yml` | Novo | Build Expo web + deploy Vercel, exige URL da API |
| `scripts/vercel-output-config.json` | Modificado | Removido proxy hardcoded Railway |
| `docs/PLANO_EXECUCAO_CLOUD_RUN_VERCEL_SUPABASE.md` | Novo | Plano operacional da migracao |

### Validacao

- Python syntax: OK (ast.parse)
- TypeScript: dependencias nao instaladas no momento do clone

---

## PR #2 — Fix project detail runtime and local web routing

- **Branch origem:** `codex/project-detail-runtime-fixes`
- **Metodo:** Cherry-pick do commit `277d490` sobre o branch do PR #1
- **Commit local:** `07d6cfe`
- **Data de aplicacao:** 2026-04-09

### Motivacao

Resolver erro 500 na rota de detalhe do projeto e estabilizar o roteamento web local para rotas dinamicas do Expo.

### Arquivos modificados

| Arquivo | Tipo | Descricao |
|---|---|---|
| `backend/routes/projetos.py` | Modificado | +2 helpers: `_resumo_confrontacoes` e `_prontidao_piloto` |
| `backend/tests/test_projetos_lotes.py` | Modificado | +2 testes para os novos helpers |
| `mobile/app/(tabs)/calculos/conversao.tsx` | Modificado | Tipagem para JsonObject, parseInt com radix 10 |
| `mobile/app/(tabs)/calculos/rotacao.tsx` | Modificado | Tipagem para JsonObject |
| `mobile/app/(tabs)/projeto/[id].tsx` | Modificado | Guard clause contra projeto null |
| `mobile/types/contratos-v1.ts` | Modificado | +4 interfaces dedicadas para resumos |
| `scripts/dev_web_gateway.py` | Modificado | Suporte a rotas dinamicas [id].html |

### Detalhes tecnicos

**Backend — _resumo_confrontacoes:**
- Itera confrontacoes e classifica por status (confirmada/descartada/pendente)
- Conta sobreposicoes e internas vs externas
- Retorna dict com totais agregados

**Backend — _prontidao_piloto:**
- Avalia 6 marcos do projeto (cliente nomeado, pontos, formularios, base oficial, lotes, confrontacoes)
- Calcula percentual: pronto_para_piloto (>=90%), operacao_assistida (>=50%), preparacao (<50%)

**Mobile — Tipagem fortalecida:**
- Substitui Record<string, unknown> por interfaces especificas em ProjetoDetalheApiV1
- Adiciona documentos_resumo como campo opcional

**Gateway — Rotas dinamicas:**
- Novo metodo _resolver_rota_dinamica percorre segmentos da URL
- Busca [param].html e diretorios [param]/ para resolver rotas Expo exportadas
- Fallback para index.html quando nenhuma rota dinamica e encontrada

### Validacao

- Python syntax: OK (ast.parse em projetos.py, main.py, dev_web_gateway.py)
- TypeScript: pendente (npm install em andamento)

---

## PR #3 — Add Cloud Run deployment automation

- **Branch origem:** `codex/cloud-run-api-automation`
- **Metodo:** Cherry-pick de 3 commits (`cae020e`, `9e311d1`, `7a6773c`) sobre o branch acumulado
- **Commits locais:** `43e237b`, `0ae3aaa`, `2c5fe7a`
- **Data de aplicacao:** 2026-04-09
- **Conflito resolvido:** README.md (links Windows vs relativos — mantidos relativos, adicionado checklist)

### Motivacao

Automatizar o deploy da API no Google Cloud Run com workflow GitHub Actions manual e script PowerShell local.

### Arquivos introduzidos/modificados

| Arquivo | Tipo | Descricao |
|---|---|---|
| `.github/workflows/deploy-api-cloud-run.yml` | Novo | Workflow manual: build Docker, push Artifact Registry, deploy Cloud Run, smoke test /health |
| `backend/.gcloudignore` | Novo | Exclui .env, .venv, tests, uploads do contexto Cloud Build |
| `scripts/deploy_api_cloud_run.ps1` | Novo | Script PowerShell local com -WhatIf, healthcheck, Secret Manager |
| `docs/CHECKLIST_DEPLOY_API_CLOUD_RUN.md` | Novo | Checklist operacional com vars, secrets, permissoes e validacao |
| `README.md` | Modificado | Adicionado link para checklist Cloud Run |

### Detalhes tecnicos

**Workflow deploy-api-cloud-run.yml:**
- Trigger manual (workflow_dispatch)
- Workload Identity Federation (sem chave de servico)
- Upsert SUPABASE_KEY no Secret Manager + bind IAM na runtime SA
- Build via Cloud Build, deploy via gcloud run deploy
- Smoke test /health com 5 retries
- Summary no GitHub com URL do servico

**Script deploy_api_cloud_run.ps1:**
- Suporte a -WhatIf (dry-run)
- Mesma logica do workflow mas para execucao local via gcloud
- Cleanup do arquivo temporario de secret

### Validacao

- Arquivos presentes e consistentes
- Links corrigidos para caminhos relativos
- README sem conflitos

---

## PR #4 — fix: harden auth uploads and magic links

- **Branch origem:** `codex/security-critical-hardening`
- **Metodo:** Cherry-pick do commit `b5b90a1` sobre o branch acumulado
- **Commit local:** `67bd314`
- **Data de aplicacao:** 2026-04-09
- **Conflitos resolvidos:**
  - `README.md` — links: mantido formato `docs/` do PR #4
  - `backend/Dockerfile` — USER: adotado `geoadmin` do PR #4 (removia `appuser` do nosso commit medio)

### Conteudo (pacote critico de seguranca)

| Item | Descricao |
|---|---|
| SEC-01 | AUTH_OBRIGATORIO=false ignorado em ambiente de implantacao |
| SEC-02 | Magic link invalidado apos uso e expiracao |
| SEC-03 | SVG do usuario substituido por SVG gerado a partir dos vertices |
| SEC-04 | Uploads com limite de tamanho, total por envio e whitelist de extensoes |
| SEC-05 | Dockerfile com usuario nao-root (geoadmin) |
| SEC-06 | .env.example sem formato de segredo real |
| SEC-07 | VERCEL_ORG_ID e PROJECT_ID como repo vars |
| EST-01 | README com links relativos validos |
| CORS | Wildcard vercel.app removido do default |

### Arquivos modificados (16 arquivos, +566/-73 linhas)

| Arquivo | Descricao |
|---|---|
| `backend/middleware/auth.py` | Bloqueia bypass de auth em producao |
| `backend/integracoes/projeto_clientes.py` | `invalidar_magic_link_participante()` novo |
| `backend/integracoes/areas_projeto.py` | Limite de upload por arquivo |
| `backend/integracoes/arquivos_projeto.py` | Whitelist de extensoes + limite total |
| `backend/routes/documentos.py` | SVG seguro gerado internamente, invalidacao de token |
| `backend/routes/projetos.py` | Validacao fortalecida nos resumos |
| `backend/main.py` | CORS restrito, wildcard Vercel removido do default |
| `backend/.env.example` | Placeholders sem formato de segredo |
| `backend/Dockerfile` | Usuario geoadmin (nao-root) |
| `.github/workflows/deploy-web.yml` | Vercel IDs como vars/secrets |
| `README.md` | Links relativos |
| `backend/tests/test_auth.py` | Novo: testa bloqueio de bypass em producao |
| + 4 testes atualizados | Upload, magic link, formulario |

### Validacao

- Python syntax: OK (7 arquivos verificados)
- Testes: 76 passed, 4 pre-existing failures (Supabase nao configurado), 1 skipped

---

## Proxima rodada pendente

### Bloco ALTO (9 itens restantes)

- SEC-09: Magic link validar proprietario do token
- SEC-10: Whitelist de extensoes + MIME validation
- SEC-11: Rate limiter aplicado em endpoints criticos
- EST-02: Dividir projetos.py (1.789 linhas) em sub-modulos
- EST-03: Extrair hooks das telas mobile gigantes
- EST-05: Completar mobile/.env.example
- UX-01: Eliminar 36+ any types no mobile
- UX-02: Validacao de entrada em tempo real nos calculos
- UX-03: Offline handling com fila de operacoes
