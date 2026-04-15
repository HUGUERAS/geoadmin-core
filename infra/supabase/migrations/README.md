# Migracoes SQL — GeoAdmin Core

## Numeracao

As migracoes neste diretorio comecam em `014` porque as migracoes `001` a `013`
foram aplicadas no repositorio de origem (`GeoAdmin-Pro` monorepo original) antes
da criacao do `geoadmin-core`.

O esquema base (tabelas `projetos`, `pontos`, `clientes`, etc.) ja existia em
producao quando este repositorio foi criado por copia controlada.

## Sequencia atual

| Migracao | Descricao |
|---|---|
| 014 | Documentos GPRF |
| 015 | Base estavel |
| 016 | Geometrias referencia cliente |
| 017 | Areas projeto (Supabase) |
| 018 | Enderecos imovel |
| 019 | Projeto clientes |
| 020 | Arquivos projeto |
| 021 | Area clientes lotes |
| 022 | Eventos magic link |
| 023 | Eventos cartograficos |
| 024 | Confrontacoes revisadas |
| 025 | Magic link canonico (backfill projeto_clientes + views) — P0.6 |
| 026 | Magic link token_usado_em [SEC-02] |
| 027 | Reconciliacao e baseline estrutural — P0.1 |
| 028 | Fase 4 portal cliente |
| 029 | Base canonica tabelas (responsaveis_tecnicos, imoveis, etc.) |
| 030 | Migrar dados legado |
| 031 | Limpar schema legado |
| 032 | Autorizacao por objeto — P1.2 (criado_por_user_id em projetos, RLS) |

## P0.1 — Reconciliacao do historico de migrations

### Diagnostico atual

O `npx supabase migration list --workdir infra` mostra divergencia entre:
- Local: `014` a `032` (este repositorio)
- Remoto: `001-013` (aplicados no repo de origem) + timestamps `202603...` (Supabase Cloud)

### Estrategia canonica decidida (migration 027)

As migrations `014-031` representam o delta local aplicado ao projeto oficial
`jrlrlsotwsiidglcbifo`. O historico remoto inclui as migrations de origem `001-013`.

**Procedimento para reconciliar (CONSULTAR RESPONSAVEL ANTES DE EXECUTAR):**

```bash
# 1. Listar estado atual (local e remoto)
npx supabase migration list --workdir infra

# 2. Marcar as migrations locais como aplicadas no historico remoto
#    (substituir NNN pelo ID de cada migration da lista local)
npx supabase migration repair --workdir infra --status applied 014_documentos_gprf
# ... repetir para cada migration 014 a 032

# 3. Verificar apos reparo
npx supabase migration list --workdir infra

# 4. Regenerar tipos apos reconciliacao
npx supabase gen types typescript --linked --schema public --workdir infra \
    > infra/supabase/database.types.ts
```

**Risco:** executar `db push` ou `db pull` sem reconciliacao pode causar
conflito ou replicacao de DDL. O `repair` e o caminho seguro.

**Criterio de aceite (P0.1):**
- `npx supabase migration list --workdir infra` sem divergencia entre local e remoto
- `database.types.ts` regenerado a partir da base reconciliada
- Procedimento documentado (este README)

## Convencao

- Nomeacao: `NNN_descricao_curta.sql` (3 digitos, underscore, snake_case)
- Cada migracao deve ser idempotente quando possivel (`IF NOT EXISTS`)
- Testar localmente com `supabase db reset` antes de aplicar em producao
- Nao executar `db push` / `db pull` sem antes confirmar o alinhamento via `migration list`
