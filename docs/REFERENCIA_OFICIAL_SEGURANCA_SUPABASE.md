# GeoAdmin Pro — Referência Oficial de Segurança, Supabase e Continuidade de Contexto

## Propósito

Este documento passa a ser a referência principal para:

- baseline de segurança do projeto
- configuração oficial do Supabase
- backlog prioritário de hardening
- ferramentas obrigatórias e recomendadas
- protocolo de continuidade quando a janela de contexto estiver se aproximando do limite

## Regra de Ouro

Após qualquer compactação de contexto, o **primeiro documento a ser lido** deve ser este:

- [REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)

Só depois dele devem ser lidos, conforme necessário:

- [AGENTS.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\AGENTS.md)
- [BASELINE_OFICIAL_AMBIENTE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\BASELINE_OFICIAL_AMBIENTE.md)
- [CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md)
- [MODELO_DADOS_BASE_CANONICA.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\MODELO_DADOS_BASE_CANONICA.md)
- [ESTRUTURA_OFICIAL_GEOADMIN_CORE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\ESTRUTURA_OFICIAL_GEOADMIN_CORE.md)
- [PERFIL_AGENTE_BANCO_DADOS.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\PERFIL_AGENTE_BANCO_DADOS.md)
- [TASKS_BANCO_FUNCIONAMENTO_REAL.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\TASKS_BANCO_FUNCIONAMENTO_REAL.md)
- [GOVERNANCA_SEGURANCA.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\GOVERNANCA_SEGURANCA.md)
- [HARDENING_MINIMO_CORE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\HARDENING_MINIMO_CORE.md)
- artefatos ativos da sprint atual

## Regra Operacional de Banco

Sempre que a tarefa tocar banco de dados, persistência, schema, migrations, `Supabase`, `database.types.ts`, contratos dependentes do banco ou qualquer entidade persistida do domínio, o agente padrão obrigatório é:

- [db-manager.agent.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.github\agents\db-manager.agent.md)

E, para auditoria, entendimento ou validação de schema, a skill obrigatória é:

- [geoadmin-schema-audit](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.codex\skills\geoadmin-schema-audit\SKILL.md)

Regra prática:

- `mudou dado persistido?` chama
- `mudou contrato dependente do banco?` chama
- `mudou só layout ou copy?` não precisa

## Protocolo de Janela de Contexto

Quando a conversa estiver se aproximando de `70%` da janela de contexto, a regra operacional é:

1. parar de abrir novas frentes simultâneas
2. atualizar este documento se houver mudança estrutural relevante
3. registrar o estado ativo das trilhas, riscos e decisões já tomadas
4. consolidar o que foi feito em um resumo de handoff curto
5. evitar continuar “de memória” quando a compressão já estiver próxima

Objetivo:

- reduzir risco de alucinação
- preservar decisões de arquitetura
- garantir que segurança e Supabase continuem coerentes entre turnos

## Resumo Executivo

Estado atual do projeto:

- o backend `FastAPI` está funcional localmente
- a web local do `GeoAdmin Core` está funcional em `http://127.0.0.1:8000`
- a trilha web local validou `GET /projeto`, `GET /health` e `GET /projetos` via gateway
- o backend local do `GeoAdmin Core` ainda depende de `Python 3.12.x` ou `3.13.x`
- o projeto Supabase oficial foi vinculado ao CLI em `infra`
- os tipos do banco já podem ser gerados e foram materializados localmente
- a base canônica nova já tem diretrizes explícitas para `registro_imobiliario_ampliado`, `responsavel_tecnico_oficial` e separação entre `endereco_residencial_ou_correspondencia` e `endereco_do_imovel_rural`
- a baseline oficial de ambiente foi registrada em [BASELINE_OFICIAL_AMBIENTE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\BASELINE_OFICIAL_AMBIENTE.md)
- a subida local do núcleo foi formalizada em [CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md)

Principais riscos atuais:

- validação de autenticação ainda depende de chamada remota ao Supabase em cada requisição protegida
- não existe ainda uma camada formal de autorização por objeto
- rate limiting ainda é em memória e não serve como proteção de produção
- fluxo de `magic link` ainda precisa de endurecimento estrutural
- trilha de migrations local e remoto ainda não está reconciliada
- existem fallbacks locais e stubs que precisam sair da trilha de produção, consolidados em [TASKS_BANCO_FUNCIONAMENTO_REAL.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\TASKS_BANCO_FUNCIONAMENTO_REAL.md)
- o backend do núcleo usa `pyproj==3.7.2`, compatível com `Python 3.12`, `3.13` e `3.14`

## Onde Estamos

### Backend

Arquivos centrais:

- [backend/main.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\main.py)
- [backend/middleware/auth.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\middleware\auth.py)
- [backend/middleware/limiter.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\middleware\limiter.py)
- [backend/routes/documentos.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\routes\documentos.py)
- [backend/routes/projetos.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\routes\projetos.py)

Hardening já aplicado:

- docs da API fechadas por padrão via `EXPOSE_API_DOCS=false`
- `TrustedHostMiddleware` adicionado ao backend
- erros `500` deixaram de vazar detalhe interno por padrão
- modo dev proxy controlado por variável de ambiente

### Frontend / Mobile / Web

Arquivos centrais:

- [mobile/lib/api.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\lib\api.ts)
- [mobile/lib/db.web.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\lib\db.web.ts)
- [mobile/app/(tabs)/projeto/index.tsx](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\app\(tabs)\projeto\index.tsx)
- [mobile/app/(tabs)/projeto/[id].tsx](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\app\(tabs)\projeto\[id].tsx)

Estado atual:

- token de autenticação fica só em memória no cliente, o que é melhor do que persistir em `localStorage`
- `db.web.ts` usa `localStorage` apenas para cache operacional e último projeto, não para credenciais
- a web local foi estabilizada com um gateway único para evitar ruído de CORS durante desenvolvimento

### Supabase

Configuração oficial:

- workdir do CLI: `infra`
- config do CLI: [infra/supabase/config.toml](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\config.toml)
- vínculo do projeto: [infra/supabase/.temp/project-ref](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\.temp\project-ref)
- migrations versionadas: [infra/supabase/migrations](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\migrations)
- tipos gerados do banco: [infra/supabase/database.types.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\database.types.ts)

Estado atual:

- CLI autenticado
- projeto oficial vinculado
- backend local já consegue responder `GET /projetos` usando o projeto remoto

## Análise Ponto a Ponto

### 1. Autenticação

O que temos:

- dependência central em [auth.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\middleware\auth.py)
- possibilidade de desligar auth em dev com `AUTH_OBRIGATORIO=false`
- validação atual via `supabase.auth.get_user(token)`

Risco:

- alto custo e alta dependência externa por requisição
- maior superfície de falha operacional
- ainda não existe política formal de sessão, expiração e revogação para todos os fluxos

O que deve ser feito:

- migrar para validação local de JWT/JWKS quando viável
- definir matriz de papéis e permissões por domínio
- separar claramente `rotas públicas`, `rotas autenticadas`, `rotas administrativas` e `rotas de cliente`

Ferramentas:

- Supabase Auth
- verificação JWT/JWKS
- testes automatizados de auth

### 2. Autorização

O que temos:

- autenticação no nível do router para boa parte das rotas protegidas

Risco:

- autenticação não é autorização
- ainda falta checagem formal de acesso por `projeto`, `área`, `cliente`, `documento`, `arquivo`, `protocolo`

O que deve ser feito:

- criar autorização por objeto
- formalizar ownership interno e externo
- impedir que um token válido enxergue qualquer registro fora do seu escopo

Ferramentas:

- dependências FastAPI por recurso
- testes de permissão
- RLS futura no Supabase para clientes diretos

### 3. Perímetro HTTP da API

O que temos:

- `CORS` configurado
- `TrustedHostMiddleware` aplicado
- erro `500` genérico por padrão
- docs fechadas por padrão

Risco:

- regex de CORS ainda é permissiva para cenários de preview
- precisa haver política explícita por ambiente

O que deve ser feito:

- fechar `ALLOWED_ORIGINS` e `ALLOWED_HOSTS` por ambiente
- reduzir dependência de wildcard em produção
- revisar todas as rotas públicas expostas

Ferramentas:

- envs por ambiente
- revisão de deploy Railway/Vercel

### 4. Anti-abuso e Rate Limit

O que temos:

- limitador customizado em memória em [limiter.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\middleware\limiter.py)

Risco:

- proteção insuficiente em produção
- não é distribuído
- não resiste a múltiplas instâncias

O que deve ser feito:

- migrar para Redis/Upstash ou outra camada distribuída
- aplicar limites em:
  - `magic links`
  - uploads
  - geração documental
  - rotas públicas
  - fluxos de cliente

Ferramentas:

- Redis ou Upstash
- métricas de abuso

### 5. Magic Links e Portal do Cliente

O que temos:

- geração de `magic link`
- histórico de eventos
- portal externo separado do dossiê interno

Risco:

- tokens ainda exigem endurecimento adicional
- precisa haver política clara de expiração, revogação, auditoria e consumo único quando aplicável

O que deve ser feito:

- revisar se o token deve permanecer persistido em texto puro
- avaliar hash de token em banco
- ampliar trilha de auditoria
- reforçar rate limit e validade curta

Ferramentas:

- tabelas de auditoria
- testes de fluxo do cliente

### 6. Uploads, Arquivos e Documentos

O que temos:

- fluxo documental funcional
- bucket previsto no Supabase
- geração e leitura de documentos no backend

Risco:

- uploads são área clássica de abuso
- ainda faltam regras mais fortes de MIME, tamanho, nome lógico, storage path e visibilidade

O que deve ser feito:

- validar tipo e tamanho no backend
- nunca confiar apenas na extensão
- separar uploads internos, uploads do cliente e artefatos gerados
- definir políticas do bucket e nomes canônicos de storage

Ferramentas:

- Supabase Storage
- validação MIME
- antivírus futuro se o fluxo crescer

### 7. Frontend / Web

O que temos:

- `api.ts` centralizado
- token em memória
- cache web em `localStorage` apenas para dados operacionais

Risco:

- versão web futura exigirá headers de segurança no edge
- qualquer futura autenticação direta no browser deve evitar segredos e storage inseguro

O que deve ser feito:

- manter segredo só no backend
- formalizar política de headers:
  - `Content-Security-Policy`
  - `X-Content-Type-Options`
  - `Referrer-Policy`
  - `Permissions-Policy`
- continuar evitando persistência de token sensível em `localStorage`

Ferramentas:

- configuração de headers em Vercel
- revisão contínua da camada web

### 8. Observabilidade e Auditoria

O que temos:

- logs básicos
- eventos de magic link

Risco:

- pouca rastreabilidade para incidentes e comprovação operacional

O que deve ser feito:

- padronizar logs estruturados
- criar auditoria para:
  - geração de documentos
  - geração e consumo de magic link
  - download de artefatos
  - mudanças de protocolo
  - uploads críticos

Ferramentas:

- logs estruturados
- Sentry ou equivalente
- observabilidade de plataforma

### 9. Dependências e Supply Chain

O que temos:

- `npm ci` funcional
- ambiente Python funcional

Risco:

- dependências JS já reportaram vulnerabilidades no audit local
- ainda não existe rotina formal de varredura no repositório

O que deve ser feito:

- instituir revisão recorrente de dependências
- travar pipelines de segurança mínimas
- corrigir vulnerabilidades com priorização por impacto real

Ferramentas:

- `npm audit`
- `pip-audit`
- `semgrep`
- `bandit`
- GitHub Dependabot ou equivalente

### 10. Supabase como plataforma oficial

O que temos:

- projeto oficial vinculado
- `config.toml` local criado
- migrations locais versionadas
- tipos gerados do banco disponíveis

Risco:

- histórico remoto e histórico local de migrations ainda não estão reconciliados
- isso impede `push/pull` cego de schema

O que deve ser feito:

- revisar a divergência entre:
  - migrations remotas antigas (`001`, `002`, ... timestamps)
  - migrations locais atuais (`014` a `024`)
- definir procedimento oficial de mudança de schema
- decidir se a trilha local será “baseline nova” ou se haverá reconciliação histórica

Ferramentas:

- `supabase migration list --workdir infra`
- `supabase db pull --workdir infra`
- revisão manual de schema
- diff controlado

## Ferramentas Obrigatórias

### Já ativas

- Supabase CLI
- Python
- npm / Node
- Expo
- Uvicorn
- curl

### Devem entrar no fluxo

- `pip-audit`
- `npm audit`
- `semgrep`
- `bandit`
- `pytest`

### Fortemente recomendadas

- Sentry
- Redis ou Upstash para rate limit distribuído
- gestor de segredos da equipe
- observabilidade de deploy e runtime

## Configuração Oficial do Supabase

### Decisão

O projeto oficial do banco é o vinculado em `infra`.

Comandos oficiais:

```bash
supabase projects list --workdir infra
supabase migration list --workdir infra
supabase gen types typescript --linked --schema public --workdir infra > infra/supabase/database.types.ts
```

### Regras

- nunca usar `service_role` no frontend
- `SUPABASE_KEY` do backend deve existir apenas em `.env` local ou variável de ambiente do deploy
- qualquer acesso futuro direto do cliente ao Supabase deve usar `publishable/anon key` com RLS
- sempre que houver acesso direto do cliente ao banco, habilitar e forçar RLS nas tabelas multi-tenant relevantes
- schema e migrations devem continuar em `infra/supabase`

### Buckets e políticas

Bucket atual esperado:

- `arquivos-projeto`

Planejamento mínimo:

- política separada para artefatos internos
- política separada para uploads de cliente
- política separada para documentos gerados
- trilha de retenção e remoção lógica

## Plano de Ação Prioritário

### P0 — imediato

- formalizar este documento como referência principal
- manter backend local ligado ao projeto oficial do Supabase
- substituir rate limit em memória por solução distribuída
- introduzir autorização por objeto
- revisar endurecimento do `magic link`
- reconciliar estratégia de migrations

### P1 — próxima fase

- validação local de JWT/JWKS
- auditoria estruturada
- policies mais fortes de storage
- headers de segurança na web pública
- geração recorrente de tipos do banco

### P2 — futura

- RLS completa para cenários com cliente acessando dados direto do Supabase
- observabilidade unificada
- pipeline de segurança automatizada em CI

## Estado Atual que Deve Ser Preservado

- backend local: `http://127.0.0.1:8001`
- web local: `http://127.0.0.1:8000`
- Supabase oficial vinculado em `infra`
- documento oficial pós-compactação: este arquivo

## Checklist de Reentrada

Ao retomar o trabalho em outro turno:

1. ler este documento
2. confirmar se o backend local responde `GET /health`
3. confirmar se `supabase projects list --workdir infra` mostra o projeto oficial vinculado
4. só então abrir backlog, telas, pacotes de agente ou novas implementações
