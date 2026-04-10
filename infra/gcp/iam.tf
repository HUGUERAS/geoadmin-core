resource "google_service_account" "deploy_ci" {
  account_id   = "geoadmin-deploy"
  display_name = "GeoAdmin CI Deploy"
  description  = "Service account para GitHub Actions e deploys."
}

resource "google_service_account" "api_runtime" {
  account_id   = "geoadmin-api"
  display_name = "GeoAdmin API Runtime"
  description  = "Runtime da API no Cloud Run."
}

resource "google_service_account" "rag_runtime" {
  account_id   = "geoadmin-rag"
  display_name = "GeoAdmin RAG Runtime"
  description  = "Runtime do job de RAG."
}

resource "google_service_account" "agendador_rag" {
  count = var.agendar_job_rag ? 1 : 0

  account_id   = "geoadmin-rag-scheduler"
  display_name = "GeoAdmin RAG Scheduler"
  description  = "Service account usada pelo Cloud Scheduler."
}

resource "google_service_account" "vm_video" {
  count = var.criar_vm_video ? 1 : 0

  account_id   = "geoadmin-video"
  display_name = "GeoAdmin Video VM"
  description  = "Service account da VM GPU opcional."
}

resource "google_project_iam_member" "deploy_ci_papeis" {
  for_each = toset([
    "roles/artifactregistry.writer",
    "roles/cloudbuild.builds.editor",
    "roles/run.admin",
    "roles/secretmanager.admin",
  ])

  project = var.id_projeto
  role    = each.value
  member  = "serviceAccount:${google_service_account.deploy_ci.email}"
}

resource "google_service_account_iam_member" "deploy_ci_assume_api" {
  service_account_id = google_service_account.api_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.deploy_ci.email}"
}

resource "google_service_account_iam_member" "deploy_ci_assume_rag" {
  service_account_id = google_service_account.rag_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.deploy_ci.email}"
}

resource "google_project_iam_member" "vm_video_logs" {
  count = var.criar_vm_video ? 1 : 0

  project = var.id_projeto
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_video[0].email}"
}
