output "artifact_registry_repository" {
  description = "Nome do repositorio Docker no Artifact Registry."
  value       = google_artifact_registry_repository.imagens.repository_id
}

output "artifact_registry_host" {
  description = "Host Docker do Artifact Registry."
  value       = "${var.regiao}-docker.pkg.dev"
}

output "imagem_api" {
  description = "URI esperada da imagem da API."
  value       = local.imagem_api
}

output "imagem_rag" {
  description = "URI esperada da imagem do job de RAG."
  value       = local.imagem_rag
}

output "email_service_account_deploy_ci" {
  description = "Service account sugerida para GitHub Actions e deploys."
  value       = google_service_account.deploy_ci.email
}

output "email_service_account_api_runtime" {
  description = "Service account de runtime da API."
  value       = google_service_account.api_runtime.email
}

output "email_service_account_rag_runtime" {
  description = "Service account de runtime do job de RAG."
  value       = google_service_account.rag_runtime.email
}

output "nomes_segredos" {
  description = "Segredos criados no Secret Manager."
  value       = { for nome, recurso in google_secret_manager_secret.segredos : nome => recurso.secret_id }
}

output "url_api_cloud_run" {
  description = "URL publica da API, quando o servico Cloud Run estiver habilitado."
  value       = var.criar_servico_api ? google_cloud_run_v2_service.api[0].uri : null
}

output "nome_job_rag" {
  description = "Nome do Cloud Run Job de RAG, quando habilitado."
  value       = var.criar_job_rag ? google_cloud_run_v2_job.rag[0].name : null
}

output "vm_video_nome" {
  description = "Nome da VM GPU opcional, quando habilitada."
  value       = var.criar_vm_video ? google_compute_instance.video_gpu[0].name : null
}

output "vm_video_ip_publico" {
  description = "IP publico efemero da VM GPU, quando habilitada."
  value = var.criar_vm_video && var.habilitar_ip_publico_vm_video ? try(
    google_compute_instance.video_gpu[0].network_interface[0].access_config[0].nat_ip,
    null
  ) : null
}
