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

## Proxima aplicacao pendente

### PR #3 — Add Cloud Run deployment automation

- **Branch:** `codex/cloud-run-api-automation`
- **Base:** `codex/cloud-run-cutover-foundation` (branch do PR #1)
- **Status:** Aguardando aplicacao
- **Conteudo esperado:** Workflow GitHub Actions para deploy Cloud Run, script PowerShell local, .gcloudignore, checklist operacional
