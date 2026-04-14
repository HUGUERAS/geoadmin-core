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
| 025 | Magic link canonico (backfill projeto_clientes + views) |
| 026 | Magic link token_usado_em [SEC-02] |
| 027 | Reconciliacao e baseline estrutural |

## Historico de origem

As migrations 001-013 foram aplicadas no repositorio de origem
(GeoAdmin-Pro monorepo) antes da criacao do geoadmin-core.
O projeto oficial vinculado e: jrlrlsotwsiidglcbifo

Para reconciliar o historico local vs remoto:

```bash
# 1. Listar estado atual (local e remoto)
npx supabase migration list --workdir infra

# 2. Reparar com a lista correta (consultar responsavel antes de executar)
npx supabase migration repair --workdir infra --status applied <migration_id>

# 3. Regenerar tipos apos reconciliacao
npx supabase gen types typescript --linked --schema public --workdir infra
```

NUNCA rodar db push / db pull sem antes confirmar o alinhamento.

## Convencao

- Nomeacao: `NNN_descricao_curta.sql` (3 digitos, underscore, snake_case)
- Cada migracao deve ser idempotente quando possivel (`IF NOT EXISTS`)
- Testar localmente com `supabase db reset` antes de aplicar em producao
