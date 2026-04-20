# GeoAdmin Core — Baseline Oficial de Ambiente

## Objetivo

Este documento define a baseline operacional mínima para o `GeoAdmin Core` rodar localmente sem improviso.

## Estado atual validado

- `mobile/npm ci` validado no novo repo
- `mobile/npm run build:web` validado no novo repo
- `backend/.env` local copiado do ambiente funcional anterior para uso local
- `scripts/dev_web_gateway.py` ajustado para usar `http://127.0.0.1:8001` por padrão
- scripts locais criados:
  - [bootstrap_local.ps1](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\scripts\bootstrap_local.ps1)
  - [start_backend.ps1](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\scripts\start_backend.ps1)
  - [start_web_gateway.ps1](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\scripts\start_web_gateway.ps1)
  - [start_expo.ps1](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\scripts\start_expo.ps1)

## Versões e ferramentas

### Python

- backend aceita `Python 3.12.x`, `Python 3.13.x` ou `Python 3.14.x`
- `pyproj` foi atualizado para `3.7.2`, eliminando o bloqueio anterior de wheel no Windows

Inferência operacional:

- a baseline oficial do backend agora inclui `Python 3.14`

### Node / npm

- `Node v24.13.0` validado nesta máquina para `npm ci` e `npm run build:web`
- `npm 11.6.2` validado nesta máquina

### Supabase CLI

- `supabase 2.75.0` presente e utilizável
- workdir oficial: [infra/supabase](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase)

## Arquivos de execução obrigatórios

### Backend

- [backend/main.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\main.py)
- [backend/requirements.txt](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\requirements.txt)
- [backend/.env.example](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\.env.example)
- [backend/Dockerfile](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\Dockerfile)
- [backend/.gcloudignore](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\.gcloudignore)
- `backend/.env` local, não versionado

### Mobile / Web

- [mobile/package.json](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\package.json)
- [mobile/package-lock.json](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\package-lock.json)
- [mobile/app.json](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\app.json)
- [mobile/eas.json](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\eas.json)
- [mobile/metro.config.js](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\metro.config.js)
- [mobile/tsconfig.json](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\tsconfig.json)

### Infra

- [infra/supabase/config.toml](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\config.toml)
- [infra/supabase/migrations](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\migrations)
- [infra/supabase/database.types.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\database.types.ts)

## Portas oficiais do desenvolvimento local

- `8001` → backend FastAPI local
- `8000` → gateway web local
- `8081` → Expo dev server
- `54321` → Supabase local API, se usado
- `54322` → Supabase local DB, se usado

## Linha oficial atual

Linha oficial de produção:

- `Vercel` para a web publicada
- `Cloud Run` para a API publicada
- `Supabase` como banco, auth e storage oficiais

No desenvolvimento local:

- o backend local usa o `Supabase` oficial configurado em `backend/.env`
- a web local pode apontar para:
  - backend local em `http://127.0.0.1:8001`
  - ou backend remoto oficial, de forma explícita

## Restrições atuais conhecidas

- a trilha de migrations ainda precisa ser reconciliada
- a autenticação ainda valida token via chamada remota ao Supabase por requisição
- o rate limit ainda é em memória
- `Python 3.12`, `3.13` e `3.14` fazem parte da baseline válida do backend no estado atual
