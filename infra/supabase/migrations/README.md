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
| 025 | Magic link canonico |

## Convencao

- Nomeacao: `NNN_descricao_curta.sql` (3 digitos, underscore, snake_case)
- Cada migracao deve ser idempotente quando possivel (`IF NOT EXISTS`)
- Testar localmente com `supabase db reset` antes de aplicar em producao
