# Mapa de Promocao de Ambientes

## Objetivo

Evitar confusao entre:

- o que existe no Git
- o que esta publicado na web
- o que esta publicado na API
- o que ainda esta apenas em branch local ou remota

## Estado observado em 2026-04-13

| Camada | Ambiente | Origem conhecida | Commit/Revision conhecida | Status |
|---|---|---|---|---|
| Repo | `origin/main` | GitHub | `fd76c56` | atrasado em relacao a `main` local |
| Repo | `main` local | local | `53ea5b0` | ainda nao promovido para GitHub |
| Repo | branch ativa | `codex/deploy-config-guardrails` | `aece088` | sincronizada com `origin/codex/deploy-config-guardrails` |
| Web | Vercel producao | branch `codex/deploy-config-guardrails` | `a1c81f6` | `READY` |
| API | Cloud Run | deploy manual/workflow | revisao `geoadmin-api-00005-4hn` | online |
| Front alternativo | Firebase Hosting | nao tratado como trilha oficial principal | n/a | responde `200` |

## URLs conhecidas

- Vercel: `https://geo-admin-pro.vercel.app`
- Cloud Run: `https://geoadmin-api-800479022570.us-central1.run.app`
- Firebase: `https://geoadmin-core-2026.web.app`

## O que controla cada promocao

### Web

- workflow: [deploy-web.yml](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.github\workflows\deploy-web.yml)
- config Vercel: [vercel.json](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\vercel.json)
- saida prebuilt: [vercel-output-config.json](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\scripts\vercel-output-config.json)

Observacao:

- o workflow da web dispara em `main`
- a producao observada ainda aponta para commit de branch `codex/*`

### API

- workflow: [deploy-api-cloud-run.yml](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.github\workflows\deploy-api-cloud-run.yml)
- script local: [deploy_api_cloud_run.ps1](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\scripts\deploy_api_cloud_run.ps1)

Observacao:

- o workflow usa imagem taggeada com `GITHUB_SHA`
- o script local ainda usa `latest`
- isso reduz rastreabilidade de qual commit esta no Cloud Run

## Desalinhamentos atuais

1. `main` local ainda nao foi empurrada para `origin/main`
2. Vercel producao nao esta claramente alinhada ao `main`
3. Cloud Run esta online, mas sem rastreabilidade de SHA no caminho local
4. Cloud Run observado com configuracao de runtime que precisa ser endurecida antes da proxima promocao

## Regra operacional recomendada

1. `main` deve ser a linha oficial de promocao
2. web publicada deve sair de `main`
3. API publicada deve sair de workflow com SHA rastreavel
4. qualquer diferenca entre runtime implantado e contrato do repo precisa ser corrigida antes da proxima promocao

## Gate minimo antes da proxima promocao

- `origin/main` alinhada com `main`
- `scripts/validate_deploy_config.py` passando
- smoke test de:
  - `/health`
  - `/projetos`
  - `/projetos/{id}`
- revisao da configuracao de auth e exposicao publica do Cloud Run
