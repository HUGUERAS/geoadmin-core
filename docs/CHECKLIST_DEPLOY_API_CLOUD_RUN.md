# Checklist — Deploy da API no Cloud Run

## Objetivo

Publicar o backend oficial do `GeoAdmin Core` no `Google Cloud Run`, mantendo `Supabase` como banco, auth e storage.

## Artefatos deste PR

- [backend/Dockerfile](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\Dockerfile)
- [backend/.gcloudignore](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\.gcloudignore)
- [scripts/deploy_api_cloud_run.ps1](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\scripts\deploy_api_cloud_run.ps1)
- [deploy-api-cloud-run.yml](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.github\workflows\deploy-api-cloud-run.yml)

## GitHub variables necessarias

- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCP_ARTIFACT_REGISTRY_REPOSITORY`
- `CLOUD_RUN_SERVICE`
- `CLOUD_RUN_RUNTIME_SERVICE_ACCOUNT`
- `PUBLIC_APP_URL`
- `SUPABASE_URL`
- `SUPABASE_BUCKET_ARQUIVOS_PROJETO`
- `ALLOWED_ORIGINS`
- `ALLOWED_HOSTS`
- `CLOUD_RUN_MIN_INSTANCES` opcional
- `CLOUD_RUN_MAX_INSTANCES` opcional

## GitHub secrets necessarios

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT`
- `SUPABASE_KEY`

## Permissoes minimas esperadas

### Service account de deploy

- `roles/run.admin`
- `roles/iam.serviceAccountUser` sobre a runtime service account
- `roles/artifactregistry.writer` ou superior no repositório
- `roles/cloudbuild.builds.editor` ou permissao equivalente para disparar build
- `roles/secretmanager.admin` ou conjunto equivalente para criar segredo, adicionar versao e ajustar IAM

### Service account de runtime

- `roles/secretmanager.secretAccessor` para ler `SUPABASE_KEY`

## Tarefas do responsavel de cloud

1. Garantir acesso ao projeto `GCP`
2. Habilitar `Cloud Run`, `Cloud Build`, `Artifact Registry` e `Secret Manager`
3. Configurar `Workload Identity Federation` para o GitHub Actions
4. Criar ou validar a service account do deploy
5. Criar ou validar a service account de runtime do `Cloud Run`
6. Preencher as `vars` e `secrets` do repositório
7. Rodar o workflow manual `Deploy API (Cloud Run)`

## Tarefas do responsavel de aplicacao

1. Confirmar `SUPABASE_URL`
2. Confirmar bucket `SUPABASE_BUCKET_ARQUIVOS_PROJETO`
3. Definir `PUBLIC_APP_URL` com:
   - domínio final da web no `Vercel`
4. Definir `ALLOWED_ORIGINS` com:
   - dominio final do Vercel
   - preview relevante, se necessario
5. Definir `ALLOWED_HOSTS` com:
   - `localhost`
   - `127.0.0.1`
   - `*.run.app` ou domínio customizado da API
   - outros hosts oficiais da API, se necessario

## Execucao local com gcloud

```powershell
$env:GCP_PROJECT_ID="seu-project-id"
$env:GCP_REGION="us-central1"
$env:GCP_ARTIFACT_REGISTRY_REPOSITORY="geoadmin"
$env:CLOUD_RUN_SERVICE="geoadmin-api"
$env:CLOUD_RUN_RUNTIME_SERVICE_ACCOUNT="geoadmin-api@seu-project-id.iam.gserviceaccount.com"
$env:PUBLIC_APP_URL="https://SEU-WEB.vercel.app"
$env:SUPABASE_URL="https://SEU_PROJECT_ID.supabase.co"
$env:SUPABASE_KEY="SUA_SERVICE_ROLE_KEY"
$env:SUPABASE_BUCKET_ARQUIVOS_PROJETO="arquivos-projeto"
$env:ALLOWED_ORIGINS="https://SEU-WEB.vercel.app"
$env:ALLOWED_HOSTS="localhost,127.0.0.1,*.run.app"

powershell -ExecutionPolicy Bypass -File .\scripts\deploy_api_cloud_run.ps1
```

## Validacao minima apos deploy

1. `GET /health`
2. `GET /projetos`
3. `GET /projetos/{id}`
4. upload basico em rota que use storage
5. geracao documental

## Observacao de automacao

O workflow e o script local fazem smoke test em `/health` logo apos o deploy. Se esse passo falhar, trate o deploy como incompleto mesmo que a imagem ja tenha sido publicada.

## Observacao

Esse fluxo mantem `Supabase` como camada de persistencia oficial. Ele troca apenas o host da API para uma casa escalavel e definitiva e exige `PUBLIC_APP_URL` para que os magic links apontem para a web correta.
