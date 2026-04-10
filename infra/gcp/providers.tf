provider "google" {
  project = var.id_projeto
  region  = var.regiao
  zone    = var.zona_principal
}

provider "google-beta" {
  project = var.id_projeto
  region  = var.regiao
  zone    = var.zona_principal
}

data "google_project" "atual" {
  project_id = var.id_projeto
}
