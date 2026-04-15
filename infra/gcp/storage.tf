resource "google_storage_bucket" "meu_bucket" {
  name                        = "${var.id_projeto}-arquivos-gerais"
  location                    = var.regiao
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  labels = local.labels_padrao

  versioning {
    enabled = true
  }
}