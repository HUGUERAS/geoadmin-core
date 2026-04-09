# GeoAdmin Pro — Plano de Migração para o Novo Repositório `GeoAdmin Core`

## Objetivo

Traduzir a decisão de criar o novo repositório `geoadmin-core` em um plano operacional de migração.

Este documento responde:

- o que migra do repositório atual
- o que migra com limpeza
- o que não deve migrar
- o que deve virar projeto separado depois
- em que ordem a migração deve acontecer

## Regra principal

O novo `GeoAdmin Core` deve nascer com:

- código útil e canônico
- documentação viva realmente usada
- infraestrutura oficial
- schema e contratos oficiais

Ele não deve nascer carregando:

- legado confuso
- build gerado
- cache local
- material exploratório sem uso no core
- dados operacionais reais brutos

## Matriz de migração por área

### Raiz do repositório atual

#### Migrar

- [AGENTS.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\AGENTS.md)
- [README.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\README.md)
- [vercel.json](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\vercel.json)
- [.gitignore](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\.gitignore)

#### Não migrar para o núcleo oficial

- [BACKLOG_PILOTO_CONDOMINIAL.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\BACKLOG_PILOTO_CONDOMINIAL.md)
- [PLANO_PILOTO_CONDOMINIAL_120_LOTES.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\PLANO_PILOTO_CONDOMINIAL_120_LOTES.md)
- [PLAYBOOK_AGENTES_PILOTO_CONDOMINIAL.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\PLAYBOOK_AGENTES_PILOTO_CONDOMINIAL.md)
- [SPRINT_CODE_REVIEW.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\SPRINT_CODE_REVIEW.md)
- [CHECKLIST_LANCAMENTO_PILOTO.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\CHECKLIST_LANCAMENTO_PILOTO.md)
- [CLAUDE.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\CLAUDE.md)
- [.claude](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\.claude)
- [.cursorrules](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\.cursorrules)

### Backend

#### Migrar com alta prioridade

- `backend/main.py`
- `backend/middleware/`
- `backend/routes/`
- `backend/integracoes/`
- `backend/schemas/`
- `backend/tests/`
- `backend/.env.example`

#### Migrar com limpeza

- `backend/static/`
  - manter:
    - `backend/static/formulario_cliente.html`
    - `backend/static/templates/carta_confrontacao.docx`
  - revisar necessidade de:
    - `backend/static/geoadmin_web.html`
- `backend/scripts/`
  - manter só scripts administrativos realmente úteis ao core
  - revisar:
    - `importar_pontos.py`
    - `migrar_versao_antiga.py`
  - não promover diretamente:
    - `indexar_normas.py` se ele já apontar mais para futuro RAG do que para o core

#### Não migrar

- `backend/uploads/`
- `backend/__pycache__/`

### Mobile

#### Migrar com alta prioridade

- `mobile/app/`
- `mobile/components/`
- `mobile/constants/`
- `mobile/lib/`
- `mobile/styles/`
- `mobile/types/`
- `mobile/assets/`

#### Migrar com limpeza

- revisar a tela:
  - [mobile/extras/rag.tsx](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\extras\rag.tsx)
  - decisão recomendada: **não promover agora** para o core oficial

#### Não migrar

- `mobile/dist/`
- `mobile/node_modules/`
- `.expo/` local

### Infra

#### Migrar com alta prioridade

- `infra/supabase/migrations/`
- `infra/supabase/config.toml`
- `infra/supabase/database.types.ts`

#### Migrar com limpeza

- remover qualquer vínculo local transitório de ambiente
- não carregar lixo operacional do CLI

#### Não migrar

- `infra/supabase/.temp/`

### Documentação

#### Migrar para o núcleo oficial

- [docs/REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)
- [docs/TASKS_BANCO_FUNCIONAMENTO_REAL.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\TASKS_BANCO_FUNCIONAMENTO_REAL.md)
- [docs/MODELO_DADOS_BASE_CANONICA.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\MODELO_DADOS_BASE_CANONICA.md)
- [docs/BASE_CANONICA_IMPLEMENTACAO.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\BASE_CANONICA_IMPLEMENTACAO.md)
- [docs/GOVERNANCA_SEGURANCA.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\GOVERNANCA_SEGURANCA.md)
- [docs/MAPA_TELAS_E_ROTAS.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\MAPA_TELAS_E_ROTAS.md)
- [docs/MATRIZ_OPERACIONAL_TELAS_V1.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\MATRIZ_OPERACIONAL_TELAS_V1.md)
- [docs/BACKLOG_TECNICO_TELAS_V1.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\BACKLOG_TECNICO_TELAS_V1.md)
- [docs/ESTRUTURA_OFICIAL_GEOADMIN_CORE.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\ESTRUTURA_OFICIAL_GEOADMIN_CORE.md)
- [docs/PLANO_MIGRACAO_GEOADMIN_CORE.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\PLANO_MIGRACAO_GEOADMIN_CORE.md)

#### Migrar só se continuarem úteis ao núcleo

- [docs/PERFIL_AGENTE_BANCO_DADOS.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\PERFIL_AGENTE_BANCO_DADOS.md)
- [docs/PLANO_AGENTES_BASE_CANONICA.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\PLANO_AGENTES_BASE_CANONICA.md)
- [docs/MATRIZ_COBERTURA_DADOS_SEAPA.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\MATRIZ_COBERTURA_DADOS_SEAPA.md)

#### Não migrar para o núcleo oficial

- [docs/PROTOTIPO_HTML_FASE1.html](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\PROTOTIPO_HTML_FASE1.html)
- [docs/PACK_TELAS_MODELO.html](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\PACK_TELAS_MODELO.html)
- [docs/MAPA_MENTAL_GEOADMIN.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\MAPA_MENTAL_GEOADMIN.md)
- [docs/HUB_CONHECIMENTO_GEOADMIN.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\HUB_CONHECIMENTO_GEOADMIN.md)
- [docs/LISTA_MESTRE_TELAS.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\LISTA_MESTRE_TELAS.md)
- `docs/specs/` que forem de fase exploratória e não de operação do core

### Automação de agentes e skills

#### Migrar

- [.github/agents/db-manager.agent.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\.github\agents\db-manager.agent.md)
- [.codex/skills/geoadmin-schema-audit/SKILL.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\.codex\skills\geoadmin-schema-audit\SKILL.md)

#### Migrar com revisão

- demais regras locais do repositório, apenas se continuarem úteis ao novo núcleo

### Scripts de apoio fora do core

#### Manter fora do `GeoAdmin Core` por enquanto

- `bridge/`
  - recomendação: tratar como utilitário separado, ou como futuro repositório `geoadmin-bridge`
- `web-demo/`
  - recomendação: não promover ao núcleo oficial

## Classificação final por decisão

### Levar inteiro

- `backend/routes`
- `backend/integracoes`
- `backend/middleware`
- `backend/schemas`
- `backend/tests`
- `mobile/app`
- `mobile/components`
- `mobile/constants`
- `mobile/lib`
- `mobile/styles`
- `mobile/types`
- `infra/supabase/migrations`

### Levar limpo

- `backend/static`
- `backend/scripts`
- `docs/`
- `.github/`
- `.codex/`

### Não levar

- `mobile/dist`
- `mobile/node_modules`
- `backend/uploads`
- caches locais
- `.temp` do Supabase
- materiais exploratórios sem uso operacional

### Separar em projeto próprio depois

- `bridge/`
- trilha de `RAG`
- demos soltas

## Ordem recomendada de execução

### Fase 1 — Fundação do novo repo

1. criar o repositório `geoadmin-core`
2. promover o scaffold de `blueprints/geoadmin-core/` para a raiz do novo repo
3. copiar apenas os arquivos de governança e documentação canônica

### Fase 2 — Núcleo técnico

1. migrar `backend/`
2. migrar `mobile/`
3. migrar `infra/`
4. migrar `scripts/` úteis

### Fase 3 — Limpeza estrutural

1. remover `dist`, caches, uploads e artefatos locais
2. remover documentação redundante
3. deixar um README de operação simples e oficial

### Fase 4 — Banco oficial do core

1. definir o novo Supabase oficial do `geoadmin-core`
2. estabilizar a linha de migrations
3. regenerar `database.types.ts`
4. alinhar `.env.example` e scripts de bootstrap

### Fase 5 — Corte de oficialidade

O novo repo assume o papel oficial quando tiver:

- banco oficial válido
- auth mínima endurecida
- storage oficial sem fallback silencioso
- contratos válidos
- telas núcleo consumindo a base real
- smoke tests dos fluxos críticos

## Resultado esperado

Ao final da migração:

- o `GeoAdmin Core` vira o repositório oficial do produto
- o repositório atual deixa de ser o centro do sistema
- o banco e os contratos passam a evoluir num núcleo mais limpo
- o futuro `RAG` pode nascer separado sem contaminar o core
