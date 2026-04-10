resource "google_project_service" "necessarios" {
  for_each = local.servicos_necessarios

  project            = var.id_projeto
  service            = each.value
  disable_on_destroy = false
}
