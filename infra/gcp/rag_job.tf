resource "google_cloud_run_v2_job" "rag" {
  count = var.criar_job_rag ? 1 : 0

  name                = var.nome_job_rag
  location            = var.regiao
  deletion_protection = false

  template {
    task_count = var.rag_task_count

    template {
      service_account = google_service_account.rag_runtime.email
      timeout         = "${var.rag_timeout_segundos}s"
      max_retries     = var.rag_max_retries

      containers {
        image   = local.imagem_rag
        command = length(var.rag_comando) > 0 ? var.rag_comando : null
        args    = length(var.rag_args) > 0 ? var.rag_args : null

        resources {
          limits = {
            cpu    = var.rag_cpu
            memory = var.rag_memoria
          }
          startup_cpu_boost = true
        }

        dynamic "env" {
          for_each = local.envs_rag
          content {
            name  = env.key
            value = env.value
          }
        }

        env {
          name = "SUPABASE_KEY"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.segredos["SUPABASE_KEY"].secret_id
              version = "latest"
            }
          }
        }

        dynamic "env" {
          for_each = var.injetar_openai_no_rag ? { OPENAI_API_KEY = google_secret_manager_secret.segredos["OPENAI_API_KEY"].secret_id } : {}
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = env.value
                version = "latest"
              }
            }
          }
        }

        dynamic "env" {
          for_each = var.injetar_anthropic_no_rag ? { ANTHROPIC_API_KEY = google_secret_manager_secret.segredos["ANTHROPIC_API_KEY"].secret_id } : {}
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = env.value
                version = "latest"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    google_artifact_registry_repository.imagens,
    google_secret_manager_secret_iam_member.rag_runtime_supabase,
    google_secret_manager_secret_iam_member.rag_runtime_openai,
    google_secret_manager_secret_iam_member.rag_runtime_anthropic,
    google_secret_manager_secret_version.bootstrap,
  ]

  lifecycle {
    precondition {
      condition     = var.segredos_ja_criados || (var.bootstrap_secret_versions && trimspace(var.valor_supabase_key) != "")
      error_message = "Para criar o job de RAG, crie antes uma versao do segredo SUPABASE_KEY manualmente ou use bootstrap_secret_versions=true com valor_supabase_key."
    }

    precondition {
      condition     = !var.injetar_openai_no_rag || var.segredos_ja_criados || (var.bootstrap_secret_versions && trimspace(var.valor_openai_api_key) != "")
      error_message = "OPENAI_API_KEY foi solicitado no job de RAG, mas o segredo ainda nao existe."
    }

    precondition {
      condition     = !var.injetar_anthropic_no_rag || var.segredos_ja_criados || (var.bootstrap_secret_versions && trimspace(var.valor_anthropic_api_key) != "")
      error_message = "ANTHROPIC_API_KEY foi solicitado no job de RAG, mas o segredo ainda nao existe."
    }
  }
}

resource "google_cloud_run_v2_job_iam_member" "agendador_rag_run" {
  count = var.criar_job_rag && var.agendar_job_rag ? 1 : 0

  project  = var.id_projeto
  location = var.regiao
  name     = google_cloud_run_v2_job.rag[0].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.agendador_rag[0].email}"
}

resource "google_cloud_scheduler_job" "rag" {
  count = var.criar_job_rag && var.agendar_job_rag ? 1 : 0

  name             = "${var.nome_job_rag}-schedule"
  description      = "Dispara o Cloud Run Job de reindexacao do RAG do GeoAdmin"
  schedule         = var.cron_job_rag
  time_zone        = var.time_zone_job_rag
  attempt_deadline = "320s"

  http_target {
    http_method = "POST"
    uri         = "https://run.googleapis.com/v2/projects/${var.id_projeto}/locations/${var.regiao}/jobs/${google_cloud_run_v2_job.rag[0].name}:run"

    headers = {
      "Content-Type" = "application/json"
    }

    body = base64encode("{}")

    oauth_token {
      service_account_email = google_service_account.agendador_rag[0].email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }

  depends_on = [google_cloud_run_v2_job_iam_member.agendador_rag_run]
}
