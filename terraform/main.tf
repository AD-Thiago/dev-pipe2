###############################################################################
# ADC-Agents-Team - Main Infrastructure
# Versão Final - Outubro 2025
###############################################################################

#-------------------#
# GOOGLE CLOUD APIs #
#-------------------#

resource "google_project_service" "required_apis" {
  for_each = toset(local.required_google_apis)
  
  project = var.google_project_id
  service = each.value
  
  disable_on_destroy = false
  disable_dependent_services = false
  
  timeouts {
    create = "30m"
    update = "40m"
  }
}

#-------------------#
# STORAGE BUCKETS   #
#-------------------#

# Bucket para source code das Cloud Functions
resource "google_storage_bucket" "functions_source" {
  depends_on = [google_project_service.required_apis]
  
  name          = "${var.google_project_id}-adc-functions-${local.unique_suffix}"
  location      = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
  
  labels = merge(var.tags, {
    purpose = "cloud-functions-source"
  })
}

# Bucket para logs e artifacts
resource "google_storage_bucket" "artifacts" {
  depends_on = [google_project_service.required_apis]
  
  name          = "${var.google_project_id}-adc-artifacts-${local.unique_suffix}"
  location      = var.region
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = local.current_env_config.retention_days
    }
    action {
      type = "Delete"
    }
  }
  
  labels = merge(var.tags, {
    purpose = "artifacts-storage"
  })
}

#-------------------#
# GOOGLE DRIVE      #
#-------------------#

# Pasta principal do projeto
resource "gdrive_folder" "main_project_folder" {
  depends_on = [google_project_service.required_apis]
  
  name      = "ADC-Pipeline-${var.project_name}"
  parent_id = "root"
}

# Pastas principais
resource "gdrive_folder" "main_folders" {
  for_each = local.drive_folder_structure
  
  name      = each.key
  parent_id = gdrive_folder.main_project_folder.id
}

# Subpastas
resource "gdrive_folder" "sub_folders" {
  for_each = merge([
    for main_folder, config in local.drive_folder_structure : {
      for subfolder in config.subfolders : 
      "${main_folder}/${subfolder}" => {
        name      = subfolder
        parent_id = gdrive_folder.main_folders[main_folder].id
      }
    }
  ]...)
  
  name      = each.value.name
  parent_id = each.value.parent_id
}

# Arquivo de configuração principal
resource "gdrive_file" "project_config" {
  name      = "project-configuration.json"
  parent_id = gdrive_folder.main_folders["Automation"].id
  
  content = jsonencode({
    version = "1.0.0"
    project = {
      name = var.project_name
      description = var.project_description
      environment = var.environment
      created_at = local.creation_timestamp
      target_completion = local.target_completion
    }
    team = {
      product_owner = {
        name = var.your_name
        email = var.your_email
      }
      agents = local.pipeline_agents
      total_members = length(local.pipeline_agents) + 1
    }
    integrations = {
      google_drive = {
        folder_id = gdrive_folder.main_project_folder.id
        folder_url = "https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}"
      }
      webhook_url = local.webhook_url
      apps_script_url = local.apps_script_url
      automation_url = local.automation_url
    }
    pipeline = {
      total_stages = length(local.pipeline_stages)
      total_story_points = sum([for s in local.pipeline_stages : s.estimate])
      auto_approve_stages = var.auto_approve_stages
      milestones = local.milestones
    }
    terraform = {
      managed = true
      version = "1.6+"
      state_location = "gcs"
    }
  })
}

# Template de memória para Perplexity
resource "gdrive_file" "memory_template" {
  name      = "perplexity-memory-template.md"
  parent_id = gdrive_folder.main_folders["Automation"].id
  
  content = templatefile("${path.module}/../templates/perplexity/memory-template.md", {
    project_name = var.project_name
    creation_date = local.creation_timestamp
    drive_folder_id = gdrive_folder.main_project_folder.id
    drive_url = "https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}"
    agents = local.pipeline_agents
    stages = local.pipeline_stages
  })
}

# Arquivo com personalidades dos agentes
resource "gdrive_file" "agent_personalities" {
  name      = "agent-personalities.json"
  parent_id = gdrive_folder.main_folders["Team"].id
  
  content = jsonencode({
    version = "1.0.0"
    project = var.project_name
    agents = local.pipeline_agents
    usage_instructions = "Use estas personalidades ao simular cada agente durante o pipeline. Cada agente deve manter consistência com sua personalidade, skills e communication_style."
  })
}

#-------------------#
# CLOUD FUNCTIONS   #
#-------------------#

# Webhook Handler Source
data "archive_file" "webhook_source" {
  type        = "zip"
  output_path = "${path.module}/../build/webhook-source-${local.unique_suffix}.zip"
  
  source_dir = "${path.module}/../functions/webhook_handler"
}

resource "google_storage_bucket_object" "webhook_source" {
  name   = "webhook-source-${local.unique_suffix}-${data.archive_file.webhook_source.output_md5}.zip"
  bucket = google_storage_bucket.functions_source.name
  source = data.archive_file.webhook_source.output_path
}

# Webhook Handler Function
resource "google_cloudfunctions_function" "webhook_handler" {
  depends_on = [google_project_service.required_apis]
  
  name        = local.webhook_function_name
  description = "Webhook handler for Linear integration - ${var.project_name}"
  runtime     = "python311"
  region      = var.region
  
  available_memory_mb   = 512
  timeout              = 540
  max_instances        = 10
  min_instances        = 0
  
  source_archive_bucket = google_storage_bucket.functions_source.name
  source_archive_object = google_storage_bucket_object.webhook_source.name
  
  trigger {
    event_type = "providers/cloud.firestore/eventTypes/document.write"
    resource   = "projects/${var.google_project_id}/databases/(default)/documents/webhooks/{messageId}"
  }
  
  entry_point = "linear_webhook_handler"
  
  environment_variables = {
    PROJECT_NAME     = var.project_name
    ENVIRONMENT      = var.environment
    LINEAR_API_KEY   = var.linear_api_key
    GITHUB_TOKEN     = var.github_token
    GITHUB_OWNER     = var.github_owner
    DRIVE_FOLDER_ID  = gdrive_folder.main_project_folder.id
    LOG_LEVEL        = local.current_env_config.log_level
    AUTO_APPROVE_STAGES = join(",", var.auto_approve_stages)
    NOTIFICATION_EMAIL = var.notification_email
    SLACK_WEBHOOK_URL = var.slack_webhook_url
  }
  
  labels = merge(var.tags, {
    function = "webhook-handler"
    project = local.project_id_clean
  })
}

# Apps Script Proxy Source
data "archive_file" "apps_script_source" {
  type        = "zip"
  output_path = "${path.module}/../build/apps-script-source-${local.unique_suffix}.zip"
  
  source_dir = "${path.module}/../functions/apps_script_proxy"
}

resource "google_storage_bucket_object" "apps_script_source" {
  name   = "apps-script-source-${local.unique_suffix}-${data.archive_file.apps_script_source.output_md5}.zip"
  bucket = google_storage_bucket.functions_source.name
  source = data.archive_file.apps_script_source.output_path
}

# Apps Script Proxy Function
resource "google_cloudfunctions_function" "apps_script_proxy" {
  depends_on = [google_project_service.required_apis]
  
  name        = local.apps_script_function_name
  description = "Apps Script proxy for Google Drive automation - ${var.project_name}"
  runtime     = "python311"
  region      = var.region
  
  available_memory_mb   = 256
  timeout              = 300
  max_instances        = 5
  
  source_archive_bucket = google_storage_bucket.functions_source.name
  source_archive_object = google_storage_bucket_object.apps_script_source.name
  
  trigger {
    event_type = "providers/cloud.firestore/eventTypes/document.write"
    resource   = "projects/${var.google_project_id}/databases/(default)/documents/automation/{messageId}"
  }
  
  entry_point = "apps_script_handler"
  
  environment_variables = {
    PROJECT_NAME = var.project_name
    DRIVE_FOLDER_ID = gdrive_folder.main_project_folder.id
    GOOGLE_CREDENTIALS = base64encode(file(var.google_credentials_file))
  }
  
  labels = merge(var.tags, {
    function = "apps-script-proxy"
    project = local.project_id_clean
  })
}

# Automation Core Source
data "archive_file" "automation_source" {
  type        = "zip"
  output_path = "${path.module}/../build/automation-source-${local.unique_suffix}.zip"
  
  source_dir = "${path.module}/../functions/automation_core"
}

resource "google_storage_bucket_object" "automation_source" {
  name   = "automation-source-${local.unique_suffix}-${data.archive_file.automation_source.output_md5}.zip"
  bucket = google_storage_bucket.functions_source.name
  source = data.archive_file.automation_source.output_path
}

# Automation Core Function
resource "google_cloudfunctions_function" "automation_core" {
  depends_on = [google_project_service.required_apis]
  
  name        = local.automation_function_name
  description = "Core automation engine - ${var.project_name}"
  runtime     = "python311"
  region      = var.region
  
  available_memory_mb   = 1024
  timeout              = 540
  max_instances        = 3
  
  source_archive_bucket = google_storage_bucket.functions_source.name
  source_archive_object = google_storage_bucket_object.automation_source.name
  
  trigger {
    event_type = "providers/cloud.firestore/eventTypes/document.write"
    resource   = "projects/${var.google_project_id}/databases/(default)/documents/pipeline/{messageId}"
  }
  
  entry_point = "automation_handler"
  
  environment_variables = {
    PROJECT_NAME = var.project_name
    LINEAR_API_KEY = var.linear_api_key
    GITHUB_TOKEN = var.github_token
    GITHUB_OWNER = var.github_owner
    WEBHOOK_URL = local.webhook_url
    DRIVE_FOLDER_ID = gdrive_folder.main_project_folder.id
    ARTIFACTS_BUCKET = google_storage_bucket.artifacts.name
  }
  
  labels = merge(var.tags, {
    function = "automation-core"
    project = local.project_id_clean
  })
}

# IAM permissions for Cloud Functions
resource "google_cloudfunctions_function_iam_member" "webhook_invoker" {
  project        = var.google_project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.webhook_handler.name
  
  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "apps_script_invoker" {
  project        = var.google_project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.apps_script_proxy.name
  
  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "automation_invoker" {
  project        = var.google_project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.automation_core.name
  
  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

#-------------------#
# GITHUB RESOURCES  #
#-------------------#

# GitHub Secrets
resource "github_actions_secret" "secrets" {
  for_each = {
    LINEAR_API_KEY        = var.linear_api_key
    GOOGLE_CREDENTIALS    = base64encode(file(var.google_credentials_file))
    GOOGLE_PROJECT_ID     = var.google_project_id
    PROJECT_NAME          = var.project_name
    WEBHOOK_URL           = local.webhook_url
    APPS_SCRIPT_URL       = local.apps_script_url
    AUTOMATION_URL        = local.automation_url
    DRIVE_FOLDER_ID       = gdrive_folder.main_project_folder.id
    ENVIRONMENT           = var.environment
    TERRAFORM_MANAGED     = "true"
    SLACK_WEBHOOK_URL     = var.slack_webhook_url
  }
  
  repository      = "dev-pipe2"
  secret_name     = each.key
  plaintext_value = each.value
}

# Repository Files
resource "github_repository_file" "readme" {
  repository = "dev-pipe2"
  branch     = "main"
  file       = "README.md"
  
  content = templatefile("${path.module}/../templates/github/README.md", {
    project_name = var.project_name
    project_description = var.project_description
    drive_url = "https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}"
    agents = local.pipeline_agents
    stages = local.pipeline_stages
    product_owner = var.your_name
  })
  
  commit_message = "Initial commit: Add comprehensive README"
  overwrite_on_create = true
}

resource "github_repository_file" "team_info" {
  repository = "dev-pipe2"
  branch     = "main"
  file       = "TEAM.md"
  
  content = templatefile("${path.module}/../templates/github/TEAM.md", {
    project_name = var.project_name
    agents = local.pipeline_agents
    product_owner = var.your_name
  })
  
  commit_message = "Add team and agents information"
  overwrite_on_create = true
}

resource "github_repository_file" "workflow_pipeline" {
  repository = "dev-pipe2"
  branch     = "main"
  file       = ".github/workflows/llm-pipeline-auto.yml"
  
  content = templatefile("${path.module}/../templates/github/workflows/llm-pipeline-auto.yml", {
    project_name = var.project_name
    webhook_url = local.webhook_url
    automation_url = local.automation_url
  })
  
  commit_message = "Add automated LLM pipeline workflow"
  overwrite_on_create = true
}

resource "github_repository_file" "workflow_deployment" {
  repository = "dev-pipe2"
  branch     = "main"
  file       = ".github/workflows/stage-deployment.yml"
  
  content = templatefile("${path.module}/../templates/github/workflows/stage-deployment.yml", {
    project_name = var.project_name
    stages = local.pipeline_stages
  })
  
  commit_message = "Add stage deployment workflow"
  overwrite_on_create = true
}

#-------------------#
# INITIALIZATION    #
#-------------------#

# Trigger inicialização automática
resource "null_resource" "initialize_pipeline" {
  depends_on = [
    gdrive_folder.main_project_folder,
    google_cloudfunctions_function.webhook_handler,
    google_cloudfunctions_function.automation_core
  ]
  
  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e
      
      echo "🚀 Iniciando pipeline ADC-Agents-Team..."
      
      echo ""
      echo "✅ Pipeline inicializado com sucesso!"
      echo ""
      echo "📋 Recursos criados:"
      echo "  📁 Google Drive: https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}"
      echo "  🔧 GitHub: https://github.com/AD-Thiago/dev-pipe2"
      echo ""
      echo "🔗 URLs de automação:"
      echo "  Webhook: ${local.webhook_url}"
      echo "  Automation: ${local.automation_url}"
      echo ""
      echo "🎯 Próximos passos:"
      echo "  1. Configure Perplexity Pro Space"
      echo "  2. Faça upload dos arquivos de configuração"
      echo "  3. Inicie com: 'L1 - INICIAR PIPELINE PRO'"
      echo ""
    EOT
    
    interpreter = ["bash", "-c"]
  }
  
  triggers = {
    project_name = var.project_name
    timestamp    = local.creation_timestamp
    environment  = var.environment
  }
}

#-------------------#
# MONITORING        #
#-------------------#

# Monitoring apenas se habilitado
resource "google_monitoring_notification_channel" "email" {
  count = var.enable_monitoring && var.notification_email != "" ? 1 : 0
  
  display_name = "ADC Pipeline Email Notifications"
  type         = "email"
  
  labels = {
    email_address = var.notification_email
  }
  
  enabled = true
}

resource "google_monitoring_alert_policy" "function_errors" {
  count = var.enable_monitoring ? 1 : 0
  
  display_name = "ADC Pipeline - Cloud Function Errors"
  combiner     = "OR"
  
  conditions {
    display_name = "Function error rate > 5%"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_function\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_count\" AND metric.label.status=\"error\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 5
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].id] : []
  
  alert_strategy {
    auto_close = "86400s"
  }
}