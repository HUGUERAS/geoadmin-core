# GeoAdmin Core

`GeoAdmin Core` é o núcleo oficial do produto GeoAdmin.

Este repositório existe para concentrar:

- backend oficial
- app mobile oficial
- versão web oficial derivada do mesmo núcleo
- infraestrutura oficial
- schema e migrations oficiais
- contratos oficiais
- documentação viva de operação

## Ponto de entrada arquitetural

O documento principal de arquitetura do produto é:

- [ARQUITETURA_OFICIAL_DO_PROJETO.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\ARQUITETURA_OFICIAL_DO_PROJETO.md)

## Documentos-base do núcleo

- [REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)
- [MODELO_DADOS_BASE_CANONICA.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\MODELO_DADOS_BASE_CANONICA.md)
- [BASE_CANONICA_IMPLEMENTACAO.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\BASE_CANONICA_IMPLEMENTACAO.md)
- [TASKS_BANCO_FUNCIONAMENTO_REAL.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\TASKS_BANCO_FUNCIONAMENTO_REAL.md)
- [GOVERNANCA_SEGURANCA.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\GOVERNANCA_SEGURANCA.md)
- [BASELINE_OFICIAL_AMBIENTE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\BASELINE_OFICIAL_AMBIENTE.md)
- [CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md)
- [HARDENING_MINIMO_CORE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\HARDENING_MINIMO_CORE.md)
- [PLANO_EXECUCAO_CLOUD_RUN_VERCEL_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\PLANO_EXECUCAO_CLOUD_RUN_VERCEL_SUPABASE.md)

## Partida rápida local

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap_local.ps1
```

Depois:

- backend local: `.\scripts\start_backend.ps1`
- web local: `.\scripts\start_web_gateway.ps1`
- expo: `.\scripts\start_expo.ps1`

## Escopo do núcleo

Entra aqui:

- transacional do produto
- topografia operacional
- georreferenciamento
- clientes
- confrontações
- documentos
- exportações técnicas
- banco e contratos

Fica fora por enquanto:

- RAG de normas e melhores práticas
- bridge/utilitários externos como produto separado
- demos e protótipos exploratórios

## Regra da transição

Este repositório nasceu por cópia controlada a partir do repositório de origem.

Isso significa:

- o repositório anterior continua preservado
- o `GeoAdmin Core` passa a ser o núcleo oficial em construção
- a migração é `copy-only`, nunca destrutiva
