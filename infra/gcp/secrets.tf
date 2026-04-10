resource "google_secret_manager_secret" "segredos" {
  for_each = local.segredos

  secret_id = each.value

  replication {
    auto {}
  }

  labels = local.labels_padrao

  depends_on = [google_project_service.necessarios]
}

resource "google_secret_manager_secret_version" "bootstrap" {
  for_each = var.bootstrap_secret_versions ? local.segredos_bootstrap_ativos : toset([])

  secret      = google_secret_manager_secret.segredos[each.value].name
  secret_data = local.segredos_bootstrap[each.value]
}

resource "google_secret_manager_secret_iam_member" "api_runtime_supabase" {
  secret_id = google_secret_manager_secret.segredos["SUPABASE_KEY"].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api_runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "rag_runtime_supabase" {
  secret_id = google_secret_manager_secret.segredos["SUPABASE_KEY"].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.rag_runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "rag_runtime_openai" {
  count = var.injetar_openai_no_rag ? 1 : 0

  secret_id = google_secret_manager_secret.segredos["OPENAI_API_KEY"].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.rag_runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "rag_runtime_anthropic" {
  count = var.injetar_anthropic_no_rag ? 1 : 0

  secret_id = google_secret_manager_secret.segredos["ANTHROPIC_API_KEY"].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.rag_runtime.email}"
}
