# GeoAdmin Pro — Perfil do Agente de Banco de Dados

## Propósito

Este documento define o que um agente precisa ter para:

- compreender o banco de dados do projeto
- gerenciar mudanças com segurança
- testar alterações de schema e acesso a dados
- estabelecer e manter boas práticas de banco ao longo do tempo

Este agente é o responsável por manter o `Postgres + Supabase` como uma plataforma previsível, auditável e segura para o `GeoAdmin Pro`.

## Regra de Entrada

Antes de atuar em banco, este agente deve ler nesta ordem:

1. [REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)
2. [AGENTS.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\AGENTS.md)
3. este documento
4. [geoadmin-schema-audit](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.codex\skills\geoadmin-schema-audit\SKILL.md) quando a tarefa envolver auditoria, validação ou entendimento do schema

## Missão do Agente

O agente de banco deve garantir que o banco:

- reflita corretamente o domínio do produto
- preserve integridade e rastreabilidade
- não exponha dados indevidos
- escale com previsibilidade
- continue compatível com backend, mobile, web e integrações futuras

## Escopo

### Dentro do escopo

- schema do Postgres
- Supabase CLI
- migrations
- views, policies, grants e RLS
- tipos gerados do banco
- consultas críticas do backend
- índices, constraints e performance
- tabelas de auditoria, protocolos e eventos
- storage e metadados ligados ao banco

### Fora do escopo primário

- layout visual de telas
- regra de negócio puramente de frontend
- deploy geral do app
- geoprocessamento pesado fora do banco

## Stack e Pontos de Referência

### Banco e ferramenta

- Postgres via Supabase
- PostGIS no projeto oficial
- Supabase CLI

### Caminhos oficiais

- config do CLI: [infra/supabase/config.toml](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\config.toml)
- migrations: [infra/supabase/migrations](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\migrations)
- tipos gerados: [infra/supabase/database.types.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\database.types.ts)
- backend que consome o banco: [backend](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend)

### Comandos oficiais

```bash
supabase projects list --workdir infra
supabase migration list --workdir infra
supabase gen types typescript --linked --schema public --workdir infra > infra/supabase/database.types.ts
```

## O Que o Agente Precisa Compreender

### 1. Modelo de domínio do produto

O agente precisa entender pelo menos:

- `projetos`
- `clientes`
- `projeto_clientes`
- `areas_projeto`
- `area_clientes`
- `confrontantes`
- `documentos`
- `arquivos_projeto`
- `eventos_magic_link`
- `eventos_cartograficos`
- `confrontacoes_revisadas`

Ele deve saber distinguir:

- dado operacional interno
- dado sensível de cliente
- dado técnico/cartográfico
- dado documental
- dado histórico/auditável

### 2. Contratos de aplicação

O agente precisa conhecer os contratos que saem do backend para o app:

- [contratos_v1.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\schemas\contratos_v1.py)
- [contratos-v1.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\types\contratos-v1.ts)

Ele não pode modelar o banco ignorando os contratos reais do produto.

### 3. Fluxo técnico atual

O agente precisa saber:

- como o backend lê e grava no Supabase
- quais rotas são mais críticas
- quais fluxos ainda dependem de legado
- onde há acoplamento perigoso entre banco e regra de negócio

## O Que o Agente Precisa Ser Capaz de Fazer

### 1. Compreender schema e integridade

Deve conseguir:

- ler tabelas, relações e constraints
- validar integridade referencial
- detectar campos redundantes, ambíguos ou mal normalizados
- propor mudanças sem quebrar o domínio

### 2. Gerenciar migrations com segurança

Deve conseguir:

- criar migrations pequenas e reversíveis
- revisar histórico local x remoto
- identificar divergência de migration history
- orientar `repair`, `pull` e `push` com segurança
- evitar `db push` cego

### 3. Estabelecer políticas de segurança

Deve conseguir:

- aplicar princípio do menor privilégio
- desenhar RLS quando o acesso direto ao banco entrar no fluxo
- definir grants, roles e isolamento de dados
- separar claramente uso de `anon/publishable` e `service_role`

### 4. Melhorar performance

Deve conseguir:

- detectar necessidade de índices
- revisar N+1 e joins pesados
- avaliar `EXPLAIN`
- propor índices parciais, compostos ou por FK quando fizer sentido
- evitar schema que pareça simples, mas degrade com volume

### 5. Testar alterações

Deve conseguir:

- validar que migrations aplicam sem erro
- verificar compatibilidade com backend
- verificar compatibilidade com tipos gerados
- testar cenários de leitura e escrita críticos
- avaliar impacto em auth, documentos, protocolos e mapas

## Ferramentas Obrigatórias

- `supabase`
- `python`
- `pytest`
- `curl`
- `git`

## Ferramentas Recomendadas

- `EXPLAIN ANALYZE`
- `pg_stat_statements`
- `npm` para sincronizar tipos e consumidores TS
- `semgrep`
- `pip-audit`
- `bandit`

## Boas Práticas que o Agente Deve Impor

### Schema

- usar chaves primárias estáveis
- criar constraints explícitas
- indexar FKs relevantes
- evitar campos duplicados com semântica confusa
- versionar mudança de schema por migration

### Segurança

- nunca expor `service_role` ao cliente
- nunca assumir filtro da aplicação como substituto de RLS
- usar menor privilégio
- tratar documentos e PII como dados sensíveis
- preservar trilha auditável para eventos críticos

### Migrations

- uma intenção por migration
- nomes claros e ordenados
- sem editar migration já aplicada em remoto
- reconciliar histórico antes de avançar em produção

### Performance

- medir consultas críticas antes de otimizar no escuro
- revisar índices ao introduzir novos filtros e joins
- evitar leitura excessiva de colunas JSON sem critério
- preferir paginação e recortes explícitos

### Tipagem e integração

- regenerar [database.types.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\database.types.ts) quando houver mudança estrutural
- alinhar tipos do banco com contratos do backend e frontend
- não deixar o app “adivinhar” formato do dado

## Fluxo de Trabalho Esperado

### Antes da mudança

O agente deve:

- entender o problema de negócio
- localizar as tabelas afetadas
- revisar impacto em backend e contratos
- revisar histórico de migrations
- definir risco

### Durante a mudança

O agente deve:

- alterar schema de forma mínima e explícita
- documentar a intenção da mudança
- atualizar tipos quando necessário
- validar leitura e escrita dos fluxos afetados

### Depois da mudança

O agente deve:

- validar migrations
- validar rotas dependentes
- registrar riscos remanescentes
- atualizar documentação se a mudança for estrutural

## Checklist Operacional

Antes de aprovar uma mudança de banco, o agente deve conseguir responder:

- Qual problema de produto essa mudança resolve?
- Quais tabelas foram afetadas?
- Quais contratos de app serão impactados?
- Há risco para auth, documentos, magic link ou protocolos?
- Há migration nova?
- O histórico local e remoto está reconciliado?
- Os tipos do banco foram regenerados?
- Há índice, constraint ou policy faltando?
- Existe risco de vazamento ou acesso indevido?
- Existe teste mínimo dessa mudança?

## Definition of Done

Uma alteração de banco só deve ser considerada pronta quando:

- o schema está consistente
- a migration está versionada
- backend continua funcional
- tipos gerados estão atualizados quando necessário
- risco de segurança foi revisado
- o impacto em produção está explícito

## Anti-padrões que o Agente Deve Bloquear

- `db push` sem reconciliar histórico
- uso de `service_role` no frontend
- adicionar tabela sem constraints mínimas
- mudar schema sem migration
- guardar segredo no cliente
- depender só da aplicação para isolamento multi-tenant
- aprovar consulta crítica sem revisar índice e cardinalidade

## Entregáveis Esperados do Agente

Quando atuar, esse agente deve devolver pelo menos um destes artefatos:

- proposta de schema
- migration revisada
- análise de risco
- plano de reconciliação de migrations
- checklist de validação
- atualização dos tipos do banco
- recomendação de RLS, grants ou índices

## Aplicação ao Estado Atual do GeoAdmin Pro

Neste projeto, o agente de banco deve atuar com prioridade em:

1. reconciliação da trilha de migrations local x remota
2. baseline de auditoria e protocolos
3. endurecimento de `magic links`
4. estratégia futura de RLS
5. geração e uso disciplinado de `database.types.ts`

## Regra de Segurança

Mudanças em banco ligadas a qualquer um destes itens exigem revisão reforçada:

- autenticação
- autorização
- `magic links`
- uploads e storage
- documentos
- exportação técnica
- dados pessoais
- rotas públicas
