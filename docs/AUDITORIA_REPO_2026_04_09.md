# Auditoria Completa — GeoAdmin Core
**Data:** 2026-04-09
**Escopo:** Estrutura, Seguranca, Usabilidade

---

## CRITICO — Corrigir imediatamente

### SEC-01: AUTH_OBRIGATORIO pode desabilitar auth em producao
- **Arquivo:** `backend/middleware/auth.py` (linhas 37-44)
- **Problema:** Variavel `AUTH_OBRIGATORIO=false` permite acesso anonimo total
- **Fix:** Validar no startup que producao NUNCA permite auth desabilitado

### SEC-02: Magic links nao sao invalidados apos uso
- **Arquivo:** `backend/integracoes/projeto_clientes.py` (linhas 542-570)
- **Problema:** Token continua valido apos consumo — permite reenvio infinito do formulario
- **Fix:** Limpar `magic_link_token` apos consumo em `documentos.py`

### SEC-03: SVG aceito sem sanitizacao — XSS possivel
- **Arquivo:** `backend/routes/documentos.py` (linhas 813-816)
- **Problema:** `croqui_svg` aceito direto do usuario pode conter `<script>`
- **Fix:** Sanitizar com `defusedxml` (ja esta no requirements.txt, mas nao e usado)

### SEC-04: Upload sem limite de tamanho
- **Arquivo:** `backend/integracoes/areas_projeto.py` (linhas 752-767)
- **Problema:** Nenhuma verificacao de tamanho por arquivo — DoS possivel
- **Fix:** Implementar limite (ex: 50MB/arquivo, 500MB/requisicao)

### SEC-05: Dockerfile roda como root
- **Arquivo:** `backend/Dockerfile`
- **Problema:** Sem `USER` definido — escalacao de privilegio em caso de RCE
- **Fix:** Adicionar `RUN useradd -m appuser` + `USER appuser`

### SEC-06: SUPABASE_KEY exemplo no .env.example
- **Arquivo:** `backend/.env.example` (linha 4)
- **Problema:** Token JWT ficticio como exemplo — padrao perigoso
- **Fix:** Substituir por placeholder `<INSERIR_VIA_SECRETS>`

### SEC-07: Vercel ORG/PROJECT IDs hardcoded no workflow
- **Arquivo:** `.github/workflows/deploy-web.yml` (linhas 50-51)
- **Problema:** IDs publicos — exposicao de infraestrutura
- **Fix:** Mover para `${{ secrets.VERCEL_ORG_ID }}`

### EST-01: README com links absolutos Windows quebrados
- **Arquivo:** `README.md`
- **Problema:** 12 links apontam para `C:\Users\User\.codex\worktrees\...`
- **Fix:** Trocar para caminhos relativos `./docs/ARQUIVO.md`

---

## ALTO — Corrigir em curto prazo

### SEC-08: CORS aceita qualquer subdominio Vercel
- **Arquivo:** `backend/main.py` (linhas 41-52)
- **Problema:** Regex `[a-z0-9\-]+\.vercel\.app` permite dominio de terceiros
- **Fix:** Whitelist de dominios especificos via ENV

### SEC-09: Magic link sem validacao de proprietario
- **Arquivo:** `backend/routes/documentos.py` (linhas 735-756)
- **Problema:** Qualquer pessoa com token valido acessa dados de outro cliente
- **Fix:** Validar que cliente logado e dono do token

### SEC-10: Validacao de tipo de arquivo apenas via extensao
- **Arquivo:** `backend/integracoes/areas_projeto.py` (linhas 71-72)
- **Problema:** Sem whitelist de extensoes, sem validacao de MIME type
- **Fix:** Lista de extensoes permitidas + verificacao de content-type

### SEC-11: Rate limiter nao aplicado em endpoints criticos
- **Arquivo:** `backend/middleware/limiter.py`
- **Problema:** `/formulario/cliente`, `/magic-links/lote` sem rate limit
- **Fix:** Aplicar limites (5/min formulario, 10/hora magic links)

### EST-02: projetos.py monolitico (1.789 linhas)
- **Arquivo:** `backend/routes/projetos.py`
- **Problema:** CRUD, areas, confrontacoes, arquivos, lotes num so arquivo
- **Fix:** Dividir em `routes/projetos/crud.py`, `areas.py`, `confrontacoes.py`, etc.

### EST-03: Telas mobile gigantes (1.000-1.500 linhas)
- **Arquivos:** `mapa/[id].tsx` (1.520), `projeto/[id].tsx` (1.291), `clientes/[id].tsx` (1.050)
- **Problema:** Logica geoespacial embutida nas telas
- **Fix:** Extrair hooks: `useMapTransform`, `useAreaCalculation`, `useGeodesics`

### EST-04: Missing __init__.py
- **Arquivos:** `backend/__init__.py`, `backend/routes/__init__.py`
- **Problema:** Pacotes Python sem init — imports inconsistentes
- **Fix:** Criar arquivos vazios

### EST-05: mobile/.env.example incompleto
- **Arquivo:** `mobile/.env.example`
- **Problema:** Apenas 1 variavel — falta `SUPABASE_URL`, `SUPABASE_KEY`
- **Fix:** Documentar todas as variaveis que `lib/api.ts` usa

### UX-01: 36+ ocorrencias de `any` type no mobile
- **Arquivos:** `calculos/index.tsx`, `area.tsx`, `projeto/[id].tsx`
- **Problema:** Quebra type-safety, erros so aparecem em runtime
- **Fix:** Usar tipos de `contratos-v1.ts` e `unknown` em catches

### UX-02: Validacao de entrada tardia nos calculos
- **Arquivos:** `calculos/area.tsx`, `conversao.tsx`
- **Problema:** Validacao so ocorre no clique — sem feedback em tempo real
- **Fix:** Validar onChange com mensagem inline

### UX-03: Offline handling parcial
- **Arquivos:** `projeto/index.tsx`, `lib/sync.ts`
- **Problema:** Cache existe mas sem fila de operacoes pendentes, sem indicador de sync
- **Fix:** Implementar fila offline + badge de sincronizacao

---

## MEDIO — Melhorias de manutencao

### EST-06: Cobertura de testes < 35%
- **Problema:** 8 modulos criticos em `integracoes/` (5.500+ linhas) sem testes
- **Modulos:** areas_projeto, arquivos_projeto, geoid, gerador_documentos, integracao_metrica, parser_landstar, projeto_clientes, referencia_cliente

### EST-07: Imports circulares / late-binding
- **Arquivos:** `areas_projeto.py:51`, `documentos.py:879`, `clientes/resumos.py:21`
- **Problema:** `from main import get_supabase` dentro de funcoes
- **Fix:** Injetar dependencia como argumento

### EST-08: Calculos geodesicos duplicados
- **Problema:** Haversine, azimute, area calculados tanto em `mapa/[id].tsx` quanto `routes/geo.py`
- **Fix:** Implementacao unica no servidor, consumir via API

### EST-09: Migracoes comecam em 014
- **Diretorio:** `infra/supabase/migrations/`
- **Problema:** Migracoes 001-013 ausentes (historico truncado de outro repo?)
- **Fix:** Documentar origem ou criar meta-arquivo

### EST-10: Scripts apenas PowerShell
- **Diretorio:** `scripts/`
- **Problema:** Sem equivalentes Bash/Zsh para Linux/Mac
- **Fix:** Criar versoes .sh cross-platform

### EST-11: database.types.ts no versionamento
- **Arquivo:** `infra/supabase/database.types.ts` (98 KB)
- **Problema:** Arquivo gerado automaticamente, polui diffs
- **Fix:** Gerar em CI/CD ou adicionar a .gitignore

### UX-04: Sem breadcrumb nas telas de calculo
- **Arquivo:** `app/(tabs)/_layout.tsx`
- **Problema:** 14 sub-telas sem indicacao de navegacao
- **Fix:** Adicionar ScreenHeader com contexto de navegacao

### UX-05: Formularios sem mascara de entrada
- **Arquivo:** `projeto/novo.tsx` (linhas 406-426)
- **Problema:** CPF, telefone sem formatacao automatica
- **Fix:** Implementar mascaras de input

### UX-06: Sem historico de calculos
- **Arquivos:** Todas as telas em `calculos/`
- **Problema:** Resultado perdido ao sair da tela
- **Fix:** Persistir historico local ou oferecer "Salvar resultado"

### SEC-12: Magic link usa UUID4 em vez de secrets.token_urlsafe
- **Arquivo:** `backend/integracoes/projeto_clientes.py:555`
- **Fix:** `token = secrets.token_urlsafe(32)` (256 bits vs 128)

### SEC-13: Sem HEALTHCHECK no Dockerfile
- **Arquivo:** `backend/Dockerfile`
- **Fix:** Adicionar `HEALTHCHECK` para Cloud Run

---

## PONTOS POSITIVOS (manter)

- Middleware auth/limiter bem estruturado
- Componentes mobile bem dimensionados (6-142 linhas)
- Separacao web/nativa com sufixo `.web.ts`
- Supabase SDK evita SQL injection por design
- `defusedxml` no requirements (falta usar)
- 26 documentos de arquitetura/governanca
- `fetchComTimeout` com 15s de timeout automatico
- Cache local SQLite para projetos
- Dependencias atualizadas (FastAPI 0.115.6, Expo 54)
- Tipagem contratual V1 em `contratos-v1.ts`

---

## METRICAS

| Categoria | Critico | Alto | Medio | Total |
|-----------|---------|------|-------|-------|
| Seguranca | 7 | 4 | 2 | 13 |
| Estrutura | 1 | 4 | 6 | 11 |
| Usabilidade | 0 | 3 | 3 | 6 |
| **Total** | **8** | **11** | **11** | **30** |
