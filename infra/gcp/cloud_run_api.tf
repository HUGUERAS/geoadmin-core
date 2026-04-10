resource "google_cloud_run_v2_service" "api" {
  count    = var.criar_servico_api ? 1 : 0
  provider = google-beta

  name                 = var.nome_servico_api
  location             = var.regiao
  deletion_protection  = false
  ingress              = "INGRESS_TRAFFIC_ALL"
  invoker_iam_disabled = var.cloud_run_publico
  description          = "API oficial do GeoAdmin Core no Cloud Run"

  template {
    service_account                  = google_service_account.api_runtime.email
    timeout                          = "${var.cloud_run_timeout_segundos}s"
    max_instance_request_concurrency = var.cloud_run_concorrencia
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"

    scaling {
      min_instance_count = var.cloud_run_min_instancias
      max_instance_count = var.cloud_run_max_instancias
    }

    containers {
      image = local.imagem_api

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = var.cloud_run_cpu
          memory = var.cloud_run_memoria
        }
        startup_cpu_boost = true
      }

      dynamic "env" {
        for_each = local.envs_api
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
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    google_artifact_registry_repository.imagens,
    google_secret_manager_secret_iam_member.api_runtime_supabase,
    google_secret_manager_secret_version.bootstrap,
  ]

  lifecycle {
    precondition {
      condition     = length(var.allowed_origins) > 0
      error_message = "allowed_origins precisa ter pelo menos uma origem oficial antes de criar a API."
    }

    precondition {
      condition     = var.segredos_ja_criados || (var.bootstrap_secret_versions && trimspace(var.valor_supabase_key) != "")
      error_message = "Para criar a API, crie antes uma versao do segredo SUPABASE_KEY manualmente ou use bootstrap_secret_versions=true com valor_supabase_key."
    }
  }
}
