# Plano de Execucao — Cloud Run + Vercel + Supabase

## Objetivo

Remover a `Railway` da arquitetura oficial de producao e fechar a integracao final do `GeoAdmin Core` com esta topologia:

- `web`: `Vercel`
- `api`: `Google Cloud Run`
- `banco/auth/storage`: `Supabase`
- `mobile`: `Expo/EAS` consumindo a mesma API definitiva

## Resultado esperado

Ao final da migracao:

- `web` e `APK` chamam a mesma API publica
- a URL da API entra por ambiente, sem `proxy` hardcoded para `Railway`
- builds publicados falham cedo se `EXPO_PUBLIC_API_BASE_URL` nao estiver definida
- os fallbacks de URL ficam restritos ao desenvolvimento local
- o backend sobe por container em `Cloud Run`
- `Supabase` continua como fonte oficial de banco, auth e storage

## Entregas ja preparadas neste repositorio

- `backend/Dockerfile`
- `backend/.dockerignore`
- `mobile/.env.example`
- `backend/.env.example` com defaults de `Cloud Run`
- `mobile/lib/api.ts` preparado para URL final via `EXPO_PUBLIC_API_BASE_URL`
- `.github/workflows/deploy-web.yml` validando `EXPO_PUBLIC_API_BASE_URL`
- `scripts/vercel-output-config.json` sem proxy fixo para `Railway`

## Segredos e variaveis

### GitHub Actions

- `VERCEL_TOKEN`
- `EXPO_PUBLIC_API_BASE_URL`

### Cloud Run

- `PUBLIC_APP_URL`
- `SUPABASE_URL`
- `SUPABASE_KEY`
- `SUPABASE_BUCKET_ARQUIVOS_PROJETO`
- `ALLOWED_ORIGINS`
- `ALLOWED_HOSTS`
- `EXPOSE_API_DOCS=false`
- `DEBUG_ERRORS=false`

### EAS / mobile

- `EXPO_PUBLIC_API_BASE_URL`

## Ordem de execucao recomendada

### PR-01 — Foundation de arquitetura

Escopo:

- preparar backend para `Cloud Run`
- remover dependencia estrutural de `proxy -> Railway`
- padronizar URL da API por ambiente
- documentar a execucao

Responsavel sugerido:

- engenharia de aplicacao

### PR-02 — Deploy da API no Cloud Run

Escopo:

- criar projeto/servico no `GCP`
- buildar a imagem do backend
- publicar no `Artifact Registry`
- subir `Cloud Run`
- configurar variaveis e segredos
- configurar `PUBLIC_APP_URL` para os magic links
- validar `/health`

Responsavel sugerido:

- infra / cloud

Dependencias:

- `PR-01`

### PR-03 — Corte do web para a API definitiva

Escopo:

- definir `EXPO_PUBLIC_API_BASE_URL` no `GitHub Actions`
- rodar deploy web no `Vercel`
- validar chamadas do navegador contra o `Cloud Run`
- validar `CORS`

Responsavel sugerido:

- frontend / devops

Dependencias:

- `PR-01`
- `PR-02`

### PR-04 — Corte do APK para a API definitiva

Escopo:

- configurar `EXPO_PUBLIC_API_BASE_URL` no `EAS`
- gerar build `preview`
- validar login, listagem, detalhe e upload

Responsavel sugerido:

- mobile

Dependencias:

- `PR-02`

### PR-05 — Validacao ponta a ponta

Escopo:

- web -> `Cloud Run` -> `Supabase`
- APK -> `Cloud Run` -> `Supabase`
- magic link
- geracao documental
- uploads
- rotas de calculo

Responsavel sugerido:

- QA / produto tecnico

Dependencias:

- `PR-03`
- `PR-04`

### PR-06 — Aposentadoria da Railway

Escopo:

- remover segredos/variaveis antigas
- retirar referencias residuais a `Railway`
- desligar deploy antigo

Responsavel sugerido:

- infra / dono do ambiente

Dependencias:

- `PR-05`

## Checklist do Claudio

### Infra GCP

- criar ou escolher projeto `GCP`
- habilitar `Cloud Run`
- habilitar `Artifact Registry`
- autenticar `gcloud`
- publicar primeira imagem do backend
- subir `Cloud Run` em modo publico controlado

### Supabase

- confirmar `SUPABASE_URL`
- confirmar `SUPABASE_KEY` de backend
- confirmar bucket `arquivos-projeto`

### Vercel / GitHub

- garantir `VERCEL_TOKEN`
- definir `PUBLIC_APP_URL` no backend com a URL pública do frontend
- definir `EXPO_PUBLIC_API_BASE_URL` com a URL publica do `Cloud Run`
- reexecutar workflow `Deploy Web (Vercel)`
- confirmar que a web publicada nao carrega mais fallback para `Railway`

### EAS

- definir `EXPO_PUBLIC_API_BASE_URL`
- garantir o valor no ambiente `preview` e `production`
- gerar novo build `preview`

## Observacoes operacionais

- `mobile/lib/api.ts` agora aceita fallback automatico so em runtime local (`Expo Go`, emulador Android e gateway web local)
- web publicada sem `EXPO_PUBLIC_API_BASE_URL` passa a falhar com erro explicito em vez de voltar para a `Railway`
- build mobile publicado sem `EXPO_PUBLIC_API_BASE_URL` passa a falhar com erro explicito em vez de chamar `localhost`

## Comandos base

### Build local do backend para Cloud Run

```powershell
cd backend
docker build -t geoadmin-api .
docker run --rm -p 8080:8080 --env-file .env geoadmin-api
```

### Exemplo de deploy no Cloud Run

```powershell
gcloud builds submit backend --tag REGION-docker.pkg.dev/PROJECT_ID/geoadmin/geoadmin-api:latest
gcloud run deploy geoadmin-api `
  --image REGION-docker.pkg.dev/PROJECT_ID/geoadmin/geoadmin-api:latest `
  --region REGION `
  --platform managed `
  --allow-unauthenticated `
  --set-env-vars SUPABASE_URL=...,SUPABASE_BUCKET_ARQUIVOS_PROJETO=arquivos-projeto,PUBLIC_APP_URL=https://SEU-WEB.vercel.app,ALLOWED_ORIGINS=https://SEU-WEB.vercel.app,ALLOWED_HOSTS=localhost,127.0.0.1,*.run.app,EXPOSE_API_DOCS=false,DEBUG_ERRORS=false `
  --set-secrets SUPABASE_KEY=SUPABASE_KEY:latest
```

## Criterio de aceite

- `GET /health` responde no `Cloud Run`
- `GET /projetos` responde na web publicada
- `GET /projetos/{id}` responde na web publicada
- `preview APK` aponta para a mesma API
- magic links do backend apontam para a web publica correta
- nenhuma chamada de producao depende de `Railway`
