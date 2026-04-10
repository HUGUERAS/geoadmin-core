variable "id_projeto" {
  description = "ID do projeto GCP existente onde a infraestrutura do GeoAdmin sera criada."
  type        = string
}

variable "ambiente" {
  description = "Ambiente logico da infraestrutura."
  type        = string
  default     = "prod"
}

variable "regiao" {
  description = "Regiao principal para Cloud Run, Artifact Registry e jobs."
  type        = string
  default     = "us-central1"
}

variable "zona_principal" {
  description = "Zona principal para recursos zonais auxiliares."
  type        = string
  default     = "us-central1-a"
}

variable "labels" {
  description = "Labels adicionais aplicadas nos recursos."
  type        = map(string)
  default     = {}
}

variable "nome_repositorio_imagens" {
  description = "Nome do repositorio Docker no Artifact Registry."
  type        = string
  default     = "geoadmin"
}

variable "nome_imagem_api" {
  description = "Nome da imagem Docker da API no Artifact Registry."
  type        = string
  default     = "geoadmin-api"
}

variable "tag_imagem_api" {
  description = "Tag da imagem Docker da API."
  type        = string
  default     = "latest"
}

variable "nome_servico_api" {
  description = "Nome do servico Cloud Run da API."
  type        = string
  default     = "geoadmin-api"
}

variable "criar_servico_api" {
  description = "Quando true, cria o servico Cloud Run da API. Deixe false no bootstrap inicial."
  type        = bool
  default     = false
}

variable "cloud_run_publico" {
  description = "Quando true, deixa a URL da API publica."
  type        = bool
  default     = true
}

variable "cloud_run_min_instancias" {
  description = "Quantidade minima de instancias da API."
  type        = number
  default     = 0
}

variable "cloud_run_max_instancias" {
  description = "Quantidade maxima de instancias da API."
  type        = number
  default     = 3
}

variable "cloud_run_cpu" {
  description = "Limite de CPU do container da API."
  type        = string
  default     = "1"
}

variable "cloud_run_memoria" {
  description = "Limite de memoria do container da API."
  type        = string
  default     = "1024Mi"
}

variable "cloud_run_timeout_segundos" {
  description = "Timeout maximo por request da API."
  type        = number
  default     = 300
}

variable "cloud_run_concorrencia" {
  description = "Concorrencia maxima por instancia da API."
  type        = number
  default     = 80
}

variable "auth_obrigatorio" {
  description = "Controla AUTH_OBRIGATORIO na API."
  type        = bool
  default     = true
}

variable "expor_docs_api" {
  description = "Controla EXPOSE_API_DOCS na API."
  type        = bool
  default     = false
}

variable "debug_errors" {
  description = "Controla DEBUG_ERRORS na API."
  type        = bool
  default     = false
}

variable "supabase_url" {
  description = "URL do projeto Supabase oficial."
  type        = string
}

variable "supabase_bucket_arquivos_projeto" {
  description = "Bucket oficial de arquivos no Supabase Storage."
  type        = string
  default     = "arquivos-projeto"
}

variable "allowed_origins" {
  description = "Lista de origens CORS permitidas na API."
  type        = list(string)
  default     = []
}

variable "allowed_hosts" {
  description = "Lista de hosts aceitos pelo TrustedHostMiddleware."
  type        = list(string)
  default = [
    "localhost",
    "127.0.0.1",
    "*.run.app",
    "*.vercel.app",
    "*.web.app",
    "*.firebaseapp.com",
  ]
}

variable "allowed_origin_regex" {
  description = "Regex opcional para origens CORS controladas."
  type        = string
  default     = ""
}

variable "variaveis_ambiente_api" {
  description = "Variaveis adicionais de ambiente para a API."
  type        = map(string)
  default     = {}
}
