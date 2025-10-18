###############################################################################
# ADC-Agents-Team - Providers Configuration
# Versão Final - Outubro 2025
###############################################################################

terraform {
  required_version = ">= 1.6"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
    github = {
      source  = "integrations/github" 
      version = "~> 6.2"
    }
    linear = {
      source  = "terraform-community-providers/linear"
      version = "~> 0.1.1"
    }
    gdrive = {
      source  = "hanneshayashi/gdrive"
      version = "~> 1.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.4"
    }
  }
  
  backend "gcs" {
    # Configure o backend conforme necessário
    # bucket = "seu-bucket-terraform-state"
    # prefix = "adc-agents-team"
  }
}

provider "google" {
  project     = var.google_project_id
  region      = var.region
  credentials = file(var.google_credentials_file)
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "linear" {
  api_key = var.linear_api_key
}

provider "gdrive" {
  service_account = file(var.google_credentials_file)
  impersonation   = var.impersonation_email
}