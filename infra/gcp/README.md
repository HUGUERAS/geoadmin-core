# Infra GCP do GeoAdmin

Esta pasta concentra a base de infraestrutura como codigo para levar o `GeoAdmin Core` para a `Google Cloud` dentro de um budget inicial de aproximadamente `US$150/mes`.

## Arquitetura alvo

- `Firebase Hosting` para a versao web exportada do Expo
- `Cloud Run` para a API FastAPI
- `Artifact Registry` para imagens Docker
- `Secret Manager` para `SUPABASE_KEY` e chaves opcionais de IA
- `Cloud Run Job` para ingestao e reindexacao do `RAG`
- `Cloud Scheduler` opcional para disparar o job de `RAG`
- `Compute Engine Spot + GPU` opcional para video e modelos open sob demanda
- `Supabase` continua como banco, auth e storage oficiais

## O que este Terraform cria

- habilitacao de APIs essenciais da GCP
- repositorio Docker no Artifact Registry
- service accounts de deploy, runtime da API, runtime do RAG e scheduler
- segredos base no Secret Manager
- servico Cloud Run da API quando `criar_servico_api=true`
- job Cloud Run do RAG quando `criar_job_rag=true`
- scheduler do RAG quando `agendar_job_rag=true`
- VM Spot com GPU `L4` quando `criar_vm_video=true`

## Estrategia de bootstrap

O bootstrap foi separado em fases para evitar `terraform apply` falhando por imagem ainda nao publicada ou por segredo ainda inexistente.

### Fase 1

Use:

- `criar_servico_api=false`
- `criar_job_rag=false`
- `criar_vm_video=false`

Resultado:

- APIs habilitadas
- Artifact Registry pronto
- service accounts prontas
- segredos criados no Secret Manager

### Fase 2

Publique a imagem da API com o fluxo existente do repositorio:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy_api_cloud_run.ps1
```

Se preferir usar o Terraform para subir a API depois:

1. publique a imagem no Artifact Registry
2. garanta que a versao do segredo `SUPABASE_KEY` existe
3. altere `criar_servico_api=true`
4. rode `terraform apply`

### Fase 3

Para o `RAG`:

1. buildar a imagem `geoadmin-rag`
2. decidir se o job vai usar `OPENAI_API_KEY` e/ou `ANTHROPIC_API_KEY`
3. criar as versoes dos segredos
4. ativar `criar_job_rag=true`
5. ativar `agendar_job_rag=true` se quiser execucao recorrente

## Budget recomendado

- base serverless do app: `US$20-40/mes`
- folga de logs, storage e trafego: `US$10-30/mes`
- VM GPU Spot para video: ligar sob demanda

Nao deixe a VM GPU ligada 24/7 se o teto for `US$150/mes`.

## Variaveis sensiveis

Nao commite:

- `valor_supabase_key`
- `valor_openai_api_key`
- `valor_anthropic_api_key`
- qualquer `.tfvars` real

Use apenas:

- `terraform.tfvars.example` como modelo
- `terraform.tfvars` local fora do Git

## Observacoes praticas

- `Cloud Run` foi deixado como recurso opcional no bootstrap porque depende de imagem ja publicada.
- `Firebase Hosting` fica fora do Terraform nesta primeira versao para manter o apply simples. O deploy web pode ser feito via `firebase-tools`.
- o script `scripts/deploy_web_firebase.ps1` exige `EXPO_PUBLIC_API_BASE_URL` para evitar build web apontando sem querer para o fallback legado da Railway.
- a VM de video foi pensada para `ComfyUI`, `Diffusers`, `LTX-Video` ou `Wan2.1`; `Ollama` nao e a stack principal para gerar video.

## Passos sugeridos

```powershell
cd infra/gcp
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Se a maquina local ainda nao tiver Terraform instalado, use `terraform` via CI ou instale antes de aplicar.

## Bootstrap do GitHub Actions com GCP

Antes de rodar os workflows, configure a federacao OIDC do GitHub com:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_github_gcp_oidc.ps1 -ProjetoId "seu-projeto-gcp"
```

O script:

- habilita APIs base da automacao
- cria ou reutiliza a service account `geoadmin-deploy`
- cria o `Workload Identity Pool` e o provider OIDC do GitHub
- concede os papeis iniciais para bootstrap e deploy
- imprime os valores de `GitHub Variables` e `GitHub Secrets`

## Workflows do repositorio

- `.github/workflows/bootstrap-gcp-infra.yml`: bootstrap inicial da GCP sem criar API, RAG ou VM GPU
- `.github/workflows/deploy-api-cloud-run.yml`: builda a imagem e publica a API no Cloud Run
- `.github/workflows/deploy-web-firebase.yml`: builda a web do Expo e publica no Firebase Hosting

## Gotcha: heredoc dentro de bloco literal YAML

O step `Build terraform.auto.tfvars` do `bootstrap-gcp-infra.yml` monta o arquivo com um heredoc Python embutido em `run: |`. Na primeira versao o f-string tinha linhas na coluna 0 pra manter o HCL gerado sem indentacao parasita. O parser do GitHub rejeita isso: linhas com indentacao menor que a base do bloco literal encerram o bloco, e o YAML passa a ler o conteudo do f-string como novas chaves de mapping. A run falha instantaneamente, sem jobs, sem logs e sem check-runs.

Regra pra nao repetir:

- toda linha dentro de `run: |` precisa ter indentacao maior ou igual a base do bloco, inclusive linhas internas de heredocs
- pra gerar arquivos sem indentacao parasita, indente o template uniforme e envolva em `textwrap.dedent(f"""\ ... """)`
- listas HCL geradas dinamicamente: prefira one-line (`["a", "b"]`) em vez de multilinha, pra nao quebrar o `dedent`
- scripts embutidos que passarem de ~30 linhas: mova pra `scripts/` e chame com `run: python scripts/nome.py` em vez de embutir

Sintoma classico dessa familia de bug: run com `conclusion: failure`, `total_count: 0` em `/jobs`, `404` em `/logs`, zero check-runs, duracao zero. Sempre que aparecer, valide localmente antes de investigar secrets ou config:

```bash
python -c "import yaml; yaml.safe_load(open('.github/workflows/arquivo.yml'))"
```
