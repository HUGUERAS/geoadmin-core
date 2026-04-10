variable "nome_segredo_supabase_key" {
  description = "Nome do segredo Secret Manager com a service role do Supabase."
  type        = string
  default     = "SUPABASE_KEY"
}

variable "nome_segredo_anthropic_api_key" {
  description = "Nome do segredo opcional para Anthropic."
  type        = string
  default     = "ANTHROPIC_API_KEY"
}

variable "nome_segredo_openai_api_key" {
  description = "Nome do segredo opcional para OpenAI."
  type        = string
  default     = "OPENAI_API_KEY"
}

variable "bootstrap_secret_versions" {
  description = "Quando true, cria versoes dos segredos usando os valores informados nas variaveis sensiveis."
  type        = bool
  default     = false
}

variable "segredos_ja_criados" {
  description = "Use true quando as versoes dos segredos ja existem manualmente no projeto GCP."
  type        = bool
  default     = false
}

variable "valor_supabase_key" {
  description = "Valor bootstrap do segredo SUPABASE_KEY. Nao commitar."
  type        = string
  sensitive   = true
  default     = ""
}

variable "valor_anthropic_api_key" {
  description = "Valor bootstrap opcional do segredo ANTHROPIC_API_KEY. Nao commitar."
  type        = string
  sensitive   = true
  default     = ""
}

variable "valor_openai_api_key" {
  description = "Valor bootstrap opcional do segredo OPENAI_API_KEY. Nao commitar."
  type        = string
  sensitive   = true
  default     = ""
}
