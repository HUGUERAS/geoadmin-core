locals {
  servicos_necessarios = toset([
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "compute.googleapis.com",
    "firebase.googleapis.com",
    "firebasehosting.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
  ])

  labels_padrao = merge(
    {
      aplicacao      = "geoadmin"
      ambiente       = var.ambiente
      gerenciado_por = "terraform"
      repositorio    = "geoadmin-core"
    },
    var.labels
  )

  imagem_api = "${var.regiao}-docker.pkg.dev/${var.id_projeto}/${var.nome_repositorio_imagens}/${var.nome_imagem_api}:${var.tag_imagem_api}"
  imagem_rag = "${var.regiao}-docker.pkg.dev/${var.id_projeto}/${var.nome_repositorio_imagens}/${var.nome_imagem_rag}:${var.tag_imagem_rag}"

  envs_api = merge(
    {
      APP_ENV                          = var.ambiente
      AUTH_OBRIGATORIO                 = tostring(var.auth_obrigatorio)
      SUPABASE_URL                     = var.supabase_url
      SUPABASE_BUCKET_ARQUIVOS_PROJETO = var.supabase_bucket_arquivos_projeto
      ALLOWED_ORIGINS                  = join(",", var.allowed_origins)
      ALLOWED_HOSTS                    = join(",", var.allowed_hosts)
      EXPOSE_API_DOCS                  = tostring(var.expor_docs_api)
      DEBUG_ERRORS                     = tostring(var.debug_errors)
    },
    var.allowed_origin_regex != "" ? {
      ALLOWED_ORIGIN_REGEX = var.allowed_origin_regex
    } : {},
    var.variaveis_ambiente_api
  )

  envs_rag = merge(
    {
      APP_ENV                          = var.ambiente
      SUPABASE_URL                     = var.supabase_url
      SUPABASE_BUCKET_ARQUIVOS_PROJETO = var.supabase_bucket_arquivos_projeto
    },
    var.variaveis_ambiente_job_rag
  )

  segredos = {
    SUPABASE_KEY      = var.nome_segredo_supabase_key
    ANTHROPIC_API_KEY = var.nome_segredo_anthropic_api_key
    OPENAI_API_KEY    = var.nome_segredo_openai_api_key
  }

  segredos_bootstrap = {
    SUPABASE_KEY      = var.valor_supabase_key
    ANTHROPIC_API_KEY = var.valor_anthropic_api_key
    OPENAI_API_KEY    = var.valor_openai_api_key
  }

  segredos_bootstrap_ativos = toset(compact([
    nonsensitive(var.valor_supabase_key) != "" ? "SUPABASE_KEY" : "",
    nonsensitive(var.valor_anthropic_api_key) != "" ? "ANTHROPIC_API_KEY" : "",
    nonsensitive(var.valor_openai_api_key) != "" ? "OPENAI_API_KEY" : "",
  ]))

  startup_script_vm_video = <<-EOT
    #!/usr/bin/env bash
    set -euxo pipefail
    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y ca-certificates curl docker.io git htop jq python3-pip python3-venv unzip

    systemctl enable docker
    systemctl start docker

    install -d -m 755 /opt/geoadmin
    cat >/opt/geoadmin/README.txt <<'EOF'
    Esta VM foi criada para workloads pontuais de video e modelos open.

    Recomendacao pratica:
    1. Instalar driver NVIDIA e NVIDIA Container Toolkit.
    2. Rodar ComfyUI ou Diffusers para LTX-Video / Wan2.1.
    3. Manter a VM desligada fora das janelas de geracao para caber no budget.

    Observacao:
    Ollama e util para LLM local, mas nao e a stack principal para gerar video.
    EOF
  EOT
}
