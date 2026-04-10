variable "criar_job_rag" {
  description = "Quando true, cria o Cloud Run Job para ingestao/reindexacao do RAG."
  type        = bool
  default     = false
}

variable "nome_job_rag" {
  description = "Nome do Cloud Run Job do RAG."
  type        = string
  default     = "geoadmin-rag-ingest"
}

variable "nome_imagem_rag" {
  description = "Nome da imagem Docker do job de RAG."
  type        = string
  default     = "geoadmin-rag"
}

variable "tag_imagem_rag" {
  description = "Tag da imagem Docker do job de RAG."
  type        = string
  default     = "latest"
}

variable "rag_cpu" {
  description = "CPU do job de RAG."
  type        = string
  default     = "1"
}

variable "rag_memoria" {
  description = "Memoria do job de RAG."
  type        = string
  default     = "2048Mi"
}

variable "rag_timeout_segundos" {
  description = "Timeout maximo do job de RAG."
  type        = number
  default     = 3600
}

variable "rag_task_count" {
  description = "Quantidade de tasks do job de RAG."
  type        = number
  default     = 1
}

variable "rag_max_retries" {
  description = "Quantidade maxima de retries do job de RAG."
  type        = number
  default     = 1
}

variable "rag_comando" {
  description = "Entrypoint opcional do container de RAG."
  type        = list(string)
  default     = []
}

variable "rag_args" {
  description = "Argumentos opcionais do container de RAG."
  type        = list(string)
  default     = []
}

variable "variaveis_ambiente_job_rag" {
  description = "Variaveis adicionais de ambiente para o job de RAG."
  type        = map(string)
  default     = {}
}

variable "injetar_openai_no_rag" {
  description = "Quando true, injeta OPENAI_API_KEY no job de RAG."
  type        = bool
  default     = false
}

variable "injetar_anthropic_no_rag" {
  description = "Quando true, injeta ANTHROPIC_API_KEY no job de RAG."
  type        = bool
  default     = false
}

variable "agendar_job_rag" {
  description = "Quando true, cria um Cloud Scheduler para executar o job de RAG."
  type        = bool
  default     = false
}

variable "cron_job_rag" {
  description = "Cron do Cloud Scheduler para o job de RAG."
  type        = string
  default     = "0 */6 * * *"
}

variable "time_zone_job_rag" {
  description = "Timezone do agendamento do job de RAG."
  type        = string
  default     = "America/Sao_Paulo"
}

variable "criar_vm_video" {
  description = "Quando true, cria a VM Spot opcional para geracao de video e modelos open."
  type        = bool
  default     = false
}

variable "nome_vm_video" {
  description = "Nome da VM de video."
  type        = string
  default     = "geoadmin-video-gpu"
}

variable "zona_vm_video" {
  description = "Zona da VM de video."
  type        = string
  default     = "us-central1-a"
}

variable "tipo_maquina_vm_video" {
  description = "Machine type da VM de video."
  type        = string
  default     = "g2-standard-4"
}

variable "tipo_gpu_vm_video" {
  description = "Tipo de GPU da VM de video."
  type        = string
  default     = "nvidia-l4"
}

variable "quantidade_gpu_vm_video" {
  description = "Quantidade de GPUs da VM de video."
  type        = number
  default     = 1
}

variable "disco_boot_vm_video_gb" {
  description = "Tamanho do disco de boot da VM de video."
  type        = number
  default     = 200
}

variable "usar_spot_vm_video" {
  description = "Quando true, cria a VM de video como Spot para reduzir custo."
  type        = bool
  default     = true
}

variable "rede_vm_video" {
  description = "Rede da VM de video."
  type        = string
  default     = "default"
}

variable "subrede_vm_video" {
  description = "Subrede opcional da VM de video."
  type        = string
  default     = ""
}

variable "habilitar_ip_publico_vm_video" {
  description = "Quando true, cria IP publico efemero na VM de video."
  type        = bool
  default     = true
}

variable "tags_vm_video" {
  description = "Network tags da VM de video."
  type        = list(string)
  default     = ["geoadmin", "video", "gpu"]
}
