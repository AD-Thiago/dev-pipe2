###############################################################################
# ADC-Agents-Team - Variables Definition
# Versão Final - Outubro 2025
###############################################################################

variable "project_name" {
  description = "Nome do projeto LLM (sem espaços, apenas letras, números, hífens e underscores)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.project_name))
    error_message = "Project name deve conter apenas letras, números, hífens e underscores."
  }
}

variable "project_description" {
  description = "Descrição detalhada do projeto"
  type        = string
  default     = "Pipeline automatizado de desenvolvimento de aplicações LLM com agentes especializados"
}

variable "your_name" {
  description = "Seu nome (Product Owner / Tech Lead)"
  type        = string
  default     = "Thiago Cruz"
}

variable "your_email" {
  description = "Seu email Linear (deve ter conta existente no Linear)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.your_email))
    error_message = "Email deve ser válido."
  }
}

variable "google_project_id" {
  description = "ID do projeto Google Cloud Platform"
  type        = string
}

variable "google_credentials_file" {
  description = "Caminho para arquivo de credenciais Google (Service Account JSON)"
  type        = string
  default     = "./credentials.json"
}

variable "impersonation_email" {
  description = "Email para impersonation no Google Drive (geralmente admin da organização)"
  type        = string
}

variable "github_token" {
  description = "Personal Access Token do GitHub com permissões: repo, workflow, admin:org"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "Usuário ou organização GitHub"
  type        = string
}

variable "linear_api_key" {
  description = "API Key do Linear (https://linear.app/settings/api)"
  type        = string
  sensitive   = true
}

variable "linear_organization_id" {
  description = "ID da organização Linear"
  type        = string
}

variable "region" {
  description = "Região Google Cloud para deploy de recursos"
  type        = string
  default     = "us-central1"
}

variable "timezone" {
  description = "Timezone para configurações de time Linear"
  type        = string
  default     = "America/Sao_Paulo"
}

variable "project_duration_days" {
  description = "Duração estimada do projeto em dias"
  type        = number
  default     = 7
}

variable "enable_monitoring" {
  description = "Habilitar monitoramento avançado com Cloud Monitoring"
  type        = bool
  default     = true
}

variable "enable_notifications" {
  description = "Habilitar notificações por email/Slack"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email para receber notificações do sistema"
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "URL do webhook Slack para notificações (opcional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "environment" {
  description = "Ambiente de deployment (dev, staging, production)"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment deve ser: dev, staging ou production."
  }
}

variable "budget_alert_threshold" {
  description = "Threshold de orçamento mensal em USD para alertas"
  type        = number
  default     = 50
}

variable "auto_approve_stages" {
  description = "Lista de estágios que podem ser aprovados automaticamente"
  type        = list(string)
  default     = ["L3", "L5", "L7", "L8"]
}

variable "tags" {
  description = "Tags para organização de recursos"
  type        = map(string)
  default     = {
    Project     = "ADC-Agents-Team"
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}