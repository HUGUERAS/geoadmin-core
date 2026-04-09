# Checklist — Deploy da API no Cloud Run

## Objetivo

Publicar o backend oficial do `GeoAdmin Core` no `Google Cloud Run`, mantendo `Supabase` como banco, auth e storage.

## Artefatos deste PR

- [backend/Dockerfile](../backend/Dockerfile)
- [backend/.gcloudignore](../backend/.gcloudignore)
- [scripts/deploy_api_cloud_run.ps1](../scripts/deploy_api_cloud_run.ps1)
- [deploy-api-cloud-run.yml](../.github/workflows/deploy-api-cloud-run.yml)

## GitHub variables necessarias

- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCP_ARTIFACT_REGISTRY_REPOSITORY`
- `CLOUD_RUN_SERVICE`
- `CLOUD_RUN_RUNTIME_SERVICE_ACCOUNT`
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
3. Definir `ALLOWED_ORIGINS` com:
   - dominio final do Vercel
   - preview relevante, se necessario
4. Definir `ALLOWED_HOSTS` com:
   - `localhost`
   - `127.0.0.1`
   - `*.run.app`
   - outros hosts oficiais, se necessario

## Execucao local com gcloud

```powershell
$env:GCP_PROJECT_ID="seu-project-id"
$env:GCP_REGION="us-central1"
$env:GCP_ARTIFACT_REGISTRY_REPOSITORY="geoadmin"
$env:CLOUD_RUN_SERVICE="geoadmin-api"
$env:CLOUD_RUN_RUNTIME_SERVICE_ACCOUNT="geoadmin-api@seu-project-id.iam.gserviceaccount.com"
$env:SUPABASE_URL="https://SEU_PROJECT_ID.supabase.co"
$env:SUPABASE_KEY="SUA_SERVICE_ROLE_KEY"
$env:SUPABASE_BUCKET_ARQUIVOS_PROJETO="arquivos-projeto"
$env:ALLOWED_ORIGINS="https://SEU-WEB.vercel.app"
$env:ALLOWED_HOSTS="localhost,127.0.0.1,*.run.app,*.vercel.app"

powershell -ExecutionPolicy Bypass -File .\scripts\deploy_api_cloud_run.ps1
```

## Validacao minima apos deploy

1. `GET /health`
2. `GET /projetos`
3. `GET /projetos/{id}`
4. upload basico em rota que use storage
5. geracao documental

## Observacao

Esse fluxo mantem `Supabase` como camada de persistencia oficial. Ele troca apenas o host da API para uma casa escalavel e definitiva.
