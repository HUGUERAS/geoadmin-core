resource "google_artifact_registry_repository" "imagens" {
  provider = google-beta

  project       = var.id_projeto
  location      = var.regiao
  repository_id = var.nome_repositorio_imagens
  description   = "Imagens Docker oficiais do GeoAdmin Core"
  format        = "DOCKER"
  labels        = local.labels_padrao

  depends_on = [google_project_service.necessarios]
}
