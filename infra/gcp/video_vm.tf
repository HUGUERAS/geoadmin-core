resource "google_compute_instance" "video_gpu" {
  count = var.criar_vm_video ? 1 : 0

  name                      = var.nome_vm_video
  machine_type              = var.tipo_maquina_vm_video
  zone                      = var.zona_vm_video
  allow_stopping_for_update = true
  tags                      = var.tags_vm_video
  labels                    = local.labels_padrao

  boot_disk {
    auto_delete = false

    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disco_boot_vm_video_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = var.rede_vm_video
    subnetwork = var.subrede_vm_video != "" ? var.subrede_vm_video : null

    dynamic "access_config" {
      for_each = var.habilitar_ip_publico_vm_video ? [1] : []
      content {}
    }
  }

  guest_accelerator {
    type  = var.tipo_gpu_vm_video
    count = var.quantidade_gpu_vm_video
  }

  scheduling {
    automatic_restart           = false
    on_host_maintenance         = "TERMINATE"
    preemptible                 = var.usar_spot_vm_video
    provisioning_model          = var.usar_spot_vm_video ? "SPOT" : "STANDARD"
    instance_termination_action = var.usar_spot_vm_video ? "STOP" : null
  }

  service_account {
    email  = google_service_account.vm_video[0].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = local.startup_script_vm_video

  depends_on = [google_project_service.necessarios]
}
