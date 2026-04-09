---
name: geoadmin-schema-audit
description: "Use esta skill sempre que precisar auditar, validar ou entender o schema do banco do GeoAdmin Pro. Inclui: mapeamento das tabelas e relações principais, consultas de auditoria SQL prontas para uso, detecção de inconsistências como FKs sem índice, tabelas sem RLS, campos críticos nullable e desalinhamento entre banco e contratos (`backend/schemas/contratos_v1.py`, `mobile/types/contratos-v1.ts`, `infra/supabase/database.types.ts`). Use antes de qualquer migration estrutural, ao investigar bugs de dado, ou ao integrar nova funcionalidade que toque o banco."
---

# GeoAdmin Pro — Schema Audit

## Regra de Entrada

Antes de usar esta skill, leia nesta ordem:

1. `docs/REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md`
2. `AGENTS.md`
3. `docs/PERFIL_AGENTE_BANCO_DADOS.md`
4. `infra/supabase/database.types.ts` quando a auditoria depender do schema atual

Base de verdade do schema:

- primeiro: banco real e `infra/supabase/database.types.ts`
- depois: migrations em `infra/supabase/migrations/`
- por fim: contratos em `backend/schemas/contratos_v1.py` e `mobile/types/contratos-v1.ts`

Não assuma campos, FKs ou policies só porque existiram em versões anteriores do projeto.

## Mapa de Entidades e Relações

```text
projetos
  ├── projeto_clientes ──→ clientes
  ├── areas_projeto
  │     └── area_clientes ──→ clientes
  ├── confrontantes
  ├── confrontacoes_revisadas
  ├── documentos
  ├── documentos_gerados
  ├── arquivos_projeto
  ├── eventos_magic_link
  ├── eventos_cartograficos
  └── geometrias

clientes
  ├── projeto_clientes
  ├── area_clientes
  ├── documentos
  └── eventos_magic_link
```

Observações importantes do schema atual:

- `areas_projeto` já é tabela oficial do Supabase. Não tratar como JSON local por padrão.
- `projeto_clientes` e `area_clientes` são as bridges canônicas para vínculo de pessoas.
- `eventos_magic_link` usa `expira_em` e `tipo_evento`; não presuma coluna `usado`.
- `confrontacoes_revisadas` referencia `confronto_id`, não `confrontante_id`.
- `documentos` hoje guarda metadados de arquivo e visibilidade; não presuma `status` nessa tabela sem checar o banco.

## Consultas de Auditoria — SQL Editor do Supabase

### 1. Saúde geral do banco

```sql
SELECT
  c.relname AS tablename,
  c.relrowsecurity AS rls_ativo,
  COALESCE(s.n_live_tup, 0)::bigint AS linhas_estimadas,
  pg_size_pretty(pg_total_relation_size(c.oid)) AS tamanho_total
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_stat_user_tables s ON s.relid = c.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
ORDER BY COALESCE(s.n_live_tup, 0) DESC, c.relname;
```

### 2. FKs sem índice correspondente

Heurística inicial para detectar colunas de FK sem índice dedicado.

```sql
WITH fk_cols AS (
  SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS referenced_table
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
  JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.table_schema = ccu.table_schema
  WHERE tc.table_schema = 'public'
    AND tc.constraint_type = 'FOREIGN KEY'
)
SELECT
  fk.table_name,
  fk.column_name,
  fk.referenced_table,
  fk.constraint_name
FROM fk_cols fk
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_indexes pi
  WHERE pi.schemaname = 'public'
    AND pi.tablename = fk.table_name
    AND pi.indexdef ILIKE '%' || fk.column_name || '%'
)
ORDER BY fk.table_name, fk.column_name;
```

### 3. Policies RLS por tabela

```sql
SELECT
  tablename,
  policyname,
  cmd,
  roles::text,
  qual AS using_clause,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, cmd, policyname;
```

### 4. Tabelas com RLS habilitado e sem policy

```sql
SELECT c.relname AS tablename
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relrowsecurity = true
  AND NOT EXISTS (
    SELECT 1
    FROM pg_policies p
    WHERE p.schemaname = 'public'
      AND p.tablename = c.relname
  )
ORDER BY c.relname;
```

### 5. Campos críticos nullable

```sql
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND is_nullable = 'YES'
  AND column_name IN (
    'projeto_id',
    'cliente_id',
    'area_id',
    'status',
    'tipo',
    'papel',
    'storage_path'
  )
ORDER BY table_name, column_name;
```

### 6. Magic links — estado operacional do schema atual

Como o schema atual registra eventos e não um booleano `usado`, a leitura deve ser aproximada por `tipo_evento` e `expira_em`.

```sql
SELECT
  COUNT(*) FILTER (
    WHERE deleted_at IS NULL
      AND token IS NOT NULL
      AND expira_em IS NOT NULL
      AND expira_em > NOW()
      AND COALESCE(tipo_evento, '') NOT IN ('consumido', 'usado', 'expirado')
  ) AS potencialmente_ativos,
  COUNT(*) FILTER (
    WHERE deleted_at IS NULL
      AND COALESCE(tipo_evento, '') IN ('consumido', 'usado')
  ) AS consumidos,
  COUNT(*) FILTER (
    WHERE deleted_at IS NULL
      AND expira_em IS NOT NULL
      AND expira_em <= NOW()
  ) AS expirados,
  COUNT(*) FILTER (WHERE deleted_at IS NULL) AS total
FROM eventos_magic_link;
```

### 7. Documentos e arquivos — completude por projeto

```sql
SELECT
  p.id,
  p.nome,
  COUNT(DISTINCT d.id) AS documentos,
  COUNT(DISTINCT a.id) AS arquivos_cartograficos
FROM projetos p
LEFT JOIN documentos d
  ON d.projeto_id = p.id
 AND d.deleted_at IS NULL
LEFT JOIN arquivos_projeto a
  ON a.projeto_id = p.id
 AND a.deleted_at IS NULL
WHERE p.deleted_at IS NULL
GROUP BY p.id, p.nome
ORDER BY documentos DESC, arquivos_cartograficos DESC, p.nome;
```

### 8. Cobertura aproximada de revisão de confrontações

Como o schema atual não tem FK direta `confrontante_id` em `confrontacoes_revisadas`, a auditoria é por projeto.

```sql
SELECT
  c.projeto_id,
  COUNT(DISTINCT c.id) AS total_confrontantes,
  COUNT(DISTINCT cr.id) AS revisoes_registradas
FROM confrontantes c
LEFT JOIN confrontacoes_revisadas cr
  ON cr.projeto_id = c.projeto_id
 AND cr.deleted_at IS NULL
WHERE c.deleted_at IS NULL
GROUP BY c.projeto_id
HAVING COUNT(DISTINCT c.id) > COUNT(DISTINCT cr.id);
```

## Checklist de Saúde — Antes de Produção

### Schema e integridade

```text
[ ] Todas as tabelas críticas têm PK estável, preferencialmente UUID com gen_random_uuid()
[ ] FKs críticas têm índice correspondente
[ ] Campos obrigatórios têm NOT NULL explícito
[ ] Campos de status usam CHECK ou domínio controlado
[ ] Sem coluna duplicada com semântica ambígua
[ ] Timestamps operacionais usam TIMESTAMPTZ
[ ] Colunas JSON críticas têm fronteira de uso clara e não escondem relacionamento relacional
```

### RLS e segurança

```text
[ ] Toda tabela exposta por acesso direto ao banco tem RLS analisado
[ ] Não há tabela com RLS habilitado e zero policies
[ ] Policies foram revisadas para anon vs authenticated
[ ] Dados sensíveis de cliente não estão liberados por engano
[ ] eventos_magic_link mantém trilha auditável e expiração coerente
[ ] Nenhuma credencial foi embutida em migration SQL
```

### Persistência

```text
[ ] Não há dado técnico salvo apenas em disco efêmero do Railway
[ ] Uploads relevantes usam Storage e metadados persistidos no banco
[ ] geometrias, áreas, documentos e vínculos cliente-projeto estão em tabelas oficiais
```

### Migrations

```text
[ ] `supabase migration list --workdir infra` está reconciliado
[ ] Toda migration nova tem nome claro e isolado
[ ] Nenhuma migration já aplicada em remoto foi editada
[ ] `infra/supabase/database.types.ts` foi regenerado após mudança estrutural
```

### Contratos

```text
[ ] Campos novos do banco estão refletidos em `backend/schemas/contratos_v1.py`
[ ] Campos novos do banco estão refletidos em `mobile/types/contratos-v1.ts`
[ ] Backend não assume campos ausentes no schema atual
[ ] Frontend não assume campos ausentes no schema atual
```

## Verificação de Contratos — Banco ↔ Código

Arquivos obrigatórios para comparação:

- `infra/supabase/database.types.ts`
- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`
- rotas consumidoras em `backend/routes/`

### Campos críticos por tabela

| Tabela | Campos mínimos esperados |
|---|---|
| `projetos` | `id`, `nome`, `status`, `criado_em` |
| `clientes` | `id`, `nome`, `cpf` ou `cpf_cnpj`, `criado_em` |
| `projeto_clientes` | `id`, `projeto_id`, `cliente_id`, `papel` |
| `areas_projeto` | `id`, `projeto_id`, `nome`, `origem_tipo` |
| `area_clientes` | `id`, `area_id`, `cliente_id`, `papel` |
| `confrontantes` | `id`, `projeto_id`, `nome`, `lado` |
| `documentos` | `id`, `nome_arquivo`, `storage_path`, `tipo` |
| `eventos_magic_link` | `id`, `projeto_id`, `canal`, `tipo_evento`, `criado_em` |

## Diagnóstico de Bug — Dado Ausente ou Incorreto

### Roteiro de investigação

```text
1. Verificar se o dado existe no banco
   → SELECT * FROM <tabela> WHERE id = '<uuid>' LIMIT 1;

2. Verificar se há filtro por soft delete
   → checar `deleted_at IS NULL`

3. Verificar se RLS ou grant está bloqueando
   → comparar leitura com papel real da aplicação

4. Verificar se a migration correspondente foi aplicada
   → supabase migration list --workdir infra

5. Verificar se o backend está filtrando ou serializando errado
   → backend/routes/<modulo>.py

6. Verificar se `database.types.ts` e contratos estão alinhados
   → infra/supabase/database.types.ts
   → backend/schemas/contratos_v1.py
   → mobile/types/contratos-v1.ts

7. Verificar se a divergência vem de coluna legada ou relação duplicada
   → exemplo: cliente direto em `projetos` vs bridges `projeto_clientes`/`area_clientes`
```

## Anti-padrões de Schema — Detectar e Corrigir

| Anti-padrão | Como identificar | Correção |
|---|---|---|
| FK sem índice | Consulta 2 | `CREATE INDEX IF NOT EXISTS` |
| Tabela com RLS habilitado mas zero policies | Consulta 4 | criar policy ou revisar se RLS deve estar ativo |
| Campo crítico nullable | Consulta 5 | `ALTER TABLE ... ALTER COLUMN ... SET NOT NULL` |
| Status sem regra | `\d <tabela>` ou migrations | `CHECK (...)` ou enum controlado |
| Timestamp sem fuso | `information_schema.columns` | migrar para `TIMESTAMPTZ` |
| Relação escondida em JSON | leitura de JSON críticos | extrair para tabela própria quando virar vínculo |
| Campo legado competindo com bridge oficial | comparar `cliente_id` direto vs bridges | definir fonte canônica e documentar |

## Comandos Oficiais

```bash
supabase migration list --workdir infra
supabase db connect --workdir infra
supabase gen types typescript --linked --schema public --workdir infra > infra/supabase/database.types.ts
```

Dentro do `psql`:

```sql
\dt public.*
\d public.projetos
\d public.projeto_clientes
\d public.areas_projeto
\d+ public.documentos
\di public.*
```

Para consulta crítica:

```sql
EXPLAIN ANALYZE
SELECT *
FROM confrontantes
WHERE projeto_id = '<uuid>'
  AND deleted_at IS NULL;
```

## Definition of Done

Uma auditoria de schema só está concluída quando:

- o mapa atual das entidades foi conferido contra `database.types.ts` ou banco real
- as consultas de auditoria aplicáveis foram executadas ou descartadas com justificativa
- riscos de integridade, segurança e performance ficaram explícitos
- impactos em migrations e contratos foram registrados
- a próxima ação recomendada ficou clara
