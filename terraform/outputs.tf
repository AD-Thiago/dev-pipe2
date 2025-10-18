###############################################################################
# ADC-Agents-Team - Outputs
# Versão Final - Outubro 2025
###############################################################################

output "deployment_summary" {
  description = "Resumo completo do deployment"
  value = {
    status = "✅ ADC-AGENTS-TEAM PIPELINE 100% OPERACIONAL"
    version = "1.0.0"
    deployed_at = local.creation_timestamp
    
    project = {
      name = var.project_name
      description = var.project_description
      environment = var.environment
      product_owner = var.your_name
      estimated_duration = "${var.project_duration_days} dias"
      target_completion = local.target_completion
    }
  }
}

output "ai_agents_team" {
  description = "Time completo de agentes AI com todas as informações"
  value = {
    total_agents = length(local.pipeline_agents)
    
    agents = {
      for stage_id, agent in local.pipeline_agents : stage_id => {
        name = agent.name
        email = agent.email
        avatar = agent.avatar
        role = agent.role
        department = agent.department
        personality = agent.personality
        skills = agent.skills
        bio = agent.bio
        methodology = agent.methodology
        tools = agent.tools
        communication_style = agent.communication_style
        favorite_quote = agent.favorite_quote
      }
    }
    
    assignments = {
      for stage in local.pipeline_stages : 
      "${stage.id} - ${stage.title}" => {
        agent_name = local.pipeline_agents[stage.agent].name
        agent_role = local.pipeline_agents[stage.agent].role
        estimate = stage.estimate
        auto_proceed = stage.auto_proceed
      }
    }
  }
}

output "google_cloud_resources" {
  description = "Recursos do Google Cloud Platform"
  value = {
    project_id = var.google_project_id
    region = var.region
    
    drive = {
      main_folder_id = gdrive_folder.main_project_folder.id
      main_folder_url = "https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}"
      total_folders = length(gdrive_folder.main_folders) + length(gdrive_folder.sub_folders) + 1
      structure = {
        for name, folder in gdrive_folder.main_folders : name => {
          id = folder.id
          url = "https://drive.google.com/drive/folders/${folder.id}"
        }
      }
      config_file_id = gdrive_file.project_config.id
      memory_template_id = gdrive_file.memory_template.id
    }
    
    cloud_functions = {
      webhook_handler = {
        name = google_cloudfunctions_function.webhook_handler.name
        url = google_cloudfunctions_function.webhook_handler.https_trigger_url
        runtime = "python311"
        memory = "512MB"
        timeout = "540s"
      }
      apps_script_proxy = {
        name = google_cloudfunctions_function.apps_script_proxy.name
        url = google_cloudfunctions_function.apps_script_proxy.https_trigger_url
        runtime = "python311"
        memory = "256MB"
      }
      automation_core = {
        name = google_cloudfunctions_function.automation_core.name
        url = google_cloudfunctions_function.automation_core.https_trigger_url
        runtime = "python311"
        memory = "1024MB"
      }
    }
    
    storage = {
      functions_bucket = google_storage_bucket.functions_source.name
      artifacts_bucket = google_storage_bucket.artifacts.name
    }
  }
}

output "github_repository" {
  description = "Informações do repositório GitHub"
  value = {
    name = "dev-pipe2"
    url = "https://github.com/AD-Thiago/dev-pipe2"
    clone_url = "https://github.com/AD-Thiago/dev-pipe2.git"
    
    workflows = {
      pipeline_automation = ".github/workflows/llm-pipeline-auto.yml"
      stage_deployment = ".github/workflows/stage-deployment.yml"
    }
    
    secrets_configured = length(github_actions_secret.secrets)
  }
}

output "automation_urls" {
  description = "URLs para automação e integrações"
  value = {
    webhook_handler = local.webhook_url
    apps_script_proxy = local.apps_script_url
    automation_core = local.automation_url
    
    integration_endpoints = {
      linear_webhook = "${local.webhook_url}/linear"
      github_webhook = "${local.webhook_url}/github"
      manual_trigger = "${local.automation_url}/trigger"
      health_check = "${local.webhook_url}/health"
    }
  }
  sensitive = false
}

output "perplexity_configuration" {
  description = "Configuração completa para Perplexity Pro Space"
  value = {
    space_setup = {
      name = "🤖 ${var.project_name} - ADC AI Agents Team"
      description = "Pipeline automatizado de desenvolvimento LLM com time especializado de agentes AI"
      model_recommendation = "Claude 3.5 Sonnet (recomendado) ou GPT-4o"
      pro_search = "SEMPRE ATIVADO"
    }
    
    custom_instructions = templatefile("${path.module}/../templates/perplexity/custom-instructions.txt", {
      project_name = var.project_name
      project_description = var.project_description
      webhook_url = local.webhook_url
      automation_url = local.automation_url
      drive_folder_id = gdrive_folder.main_project_folder.id
      drive_url = "https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}"
      github_repo = "https://github.com/AD-Thiago/dev-pipe2"
      agents = local.pipeline_agents
      stages = local.pipeline_stages
      auto_approve_stages = join(", ", var.auto_approve_stages)
    })
    
    files_to_upload = [
      {
        name = "project-configuration.json"
        source = "Google Drive: ${gdrive_file.project_config.id}"
        description = "Configuração completa do projeto e integrações"
      },
      {
        name = "perplexity-memory-template.md"
        source = "Google Drive: ${gdrive_file.memory_template.id}"
        description = "Template de memória persistente para o pipeline"
      },
      {
        name = "agent-personalities.json"
        source = "Google Drive: ${gdrive_file.agent_personalities.id}"
        description = "Personalidades completas de todos os agentes"
      }
    ]
    
    conversation_starters = [
      "🚀 L1 - ${local.pipeline_agents["L1"].name}, iniciar análise de requisitos",
      "🏢️ L2 - ${local.pipeline_agents["L2"].name}, projetar arquitetura",
      "📊 Mostrar status atual do pipeline e próximo agente",
      "👥 Listar todos os agentes e suas especialidades",
      "❓ Explicar workflow completo do pipeline"
    ]
    
    settings = {
      pro_search = true
      search_focus = "development tools, AI platforms, best practices"
      output_format = "structured and detailed"
      tone = "professional but practical"
      domain_priority = [
        "lennysnewsletter.com",
        "docs.perplexity.ai",
        "github.com",
        "linear.app",
        "googleapis.com"
      ]
    }
  }
}

output "quick_start_guide" {
  description = "Guia rápido para começar a usar o pipeline"
  value = {
    step_1 = {
      title = "Acessar Google Drive"
      action = "Abra https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}"
      description = "Verifique a estrutura de pastas e arquivos de configuração"
    }
    
    step_2 = {
      title = "Configurar Perplexity Pro Space"
      action = "Crie um Space e use as custom_instructions do output 'perplexity_configuration'"
      description = "Faça upload dos 3 arquivos listados em files_to_upload"
    }
    
    step_3 = {
      title = "Revisar GitHub Repository"
      action = "Clone https://github.com/AD-Thiago/dev-pipe2.git"
      description = "Revise workflows e estrutura do projeto"
    }
    
    step_4 = {
      title = "Iniciar Pipeline"
      action = "No Perplexity Space, digite: 'L1 - INICIAR PIPELINE PRO'"
      description = "O sistema iniciará automaticamente o primeiro estágio"
    }
  }
}

output "monitoring_and_alerts" {
  description = "Configuração de monitoramento e alertas"
  value = {
    monitoring_enabled = var.enable_monitoring
    notifications_enabled = var.enable_notifications
    
    notification_channels = {
      email = var.notification_email != "" ? var.notification_email : "not configured"
      slack = var.slack_webhook_url != "" ? "configured" : "not configured"
    }
    
    alert_policies = var.enable_monitoring ? {
      function_errors = "Alert when error rate > 5%"
      budget_threshold = "Alert at ${var.budget_alert_threshold} USD/month"
    } : {}
    
    dashboards = {
      cloud_console = "https://console.cloud.google.com/functions/list?project=${var.google_project_id}"
      github_actions = "https://github.com/AD-Thiago/dev-pipe2/actions"
    }
  }
}

output "cost_estimate" {
  description = "Estimativa de custos mensais"
  value = {
    google_cloud = {
      cloud_functions = "~$0.50/mês (free tier: 2M invocações grátis)"
      cloud_storage = "~$0.10/mês (para < 5GB)"
      drive_api = "Gratuito (dentro dos limites)"
      estimated_total = "< $1.00/mês para uso típico"
    }
    
    third_party = {
      github_private_repo = "Incluído no plano GitHub"
      linear_api = "Gratuito (dentro dos limites do plano)"
      perplexity_pro = "$20/mês (necessário para recursos avançados)"
    }
    
    total_estimated = "~$21/mês (principalmente Perplexity Pro)"
    
    notes = [
      "Custos baseados em uso típico de desenvolvimento",
      "Google Cloud Free Tier cobre maioria dos recursos",
      "Custos podem variar com escala e uso intensivo"
    ]
  }
}

output "next_actions" {
  description = "Próximas ações recomendadas"
  value = [
    "✅ 1. Terraform apply completado com sucesso",
    "📁 2. Abra Google Drive: https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}",
    "🔧 3. Clone repositório: git clone https://github.com/AD-Thiago/dev-pipe2.git",
    "🤖 4. Configure Perplexity Pro Space (veja output 'perplexity_configuration')",
    "📤 5. Faça upload dos arquivos de configuração no Space",
    "🚀 6. Inicie pipeline: 'L1 - INICIAR PIPELINE PRO'",
    "👥 7. Convide colaboradores se necessário",
    "📊 8. Configure notificações adicionais se desejado",
    "🎯 9. Comece a desenvolver sua aplicação LLM!"
  ]
}

output "terraform_state" {
  description = "Informações do estado Terraform"
  value = {
    resources_created = {
      google_apis_enabled = length(local.required_google_apis)
      google_buckets = 2
      google_functions = 3
      drive_folders = length(gdrive_folder.main_folders) + length(gdrive_folder.sub_folders) + 1
      drive_files = 3
      github_secrets = length(github_actions_secret.secrets)
      github_files = 4
    }
    
    terraform_version = "1.6+"
    providers_used = [
      "hashicorp/google ~> 5.40",
      "integrations/github ~> 6.2",
      "hanneshayashi/gdrive ~> 1.2"
    ]
    
    managed_by_terraform = true
  }
}

output "troubleshooting" {
  description = "Guia de troubleshooting comum"
  value = {
    webhook_not_working = {
      issue = "Webhook não está recebendo eventos"
      solutions = [
        "Verifique se Cloud Function está deployada: ${local.webhook_url}",
        "Teste manualmente: curl -X POST ${local.webhook_url}/health",
        "Verifique logs: gcloud functions logs read ${google_cloudfunctions_function.webhook_handler.name}"
      ]
    }
    
    perplexity_not_responding = {
      issue = "Perplexity não está acessando configurações"
      solutions = [
        "Verifique se arquivos foram uploaded no Space",
        "Confirme Pro Search está ativado",
        "Teste custom instructions manualmente",
        "Recarregue o Space se necessário"
      ]
    }
    
    github_actions_failing = {
      issue = "GitHub Actions workflows falhando"
      solutions = [
        "Verifique secrets configurados: https://github.com/AD-Thiago/dev-pipe2/settings/secrets/actions",
        "Confirme permissões do GitHub Token",
        "Revise logs em: https://github.com/AD-Thiago/dev-pipe2/actions",
        "Valide YAML syntax dos workflows"
      ]
    }
    
    drive_permissions = {
      issue = "Problemas de permissão no Google Drive"
      solutions = [
        "Verifique impersonation email: ${var.impersonation_email}",
        "Confirme Service Account tem permissões Domain-Wide Delegation",
        "Teste acesso manual à pasta: https://drive.google.com/drive/folders/${gdrive_folder.main_project_folder.id}",
        "Revise credenciais em: ${var.google_credentials_file}"
      ]
    }
    
    support = {
      documentation = "Veja docs/ para guias detalhados"
      logs = "gcloud functions logs read [FUNCTION_NAME] --limit 50"
      health_check = "${local.webhook_url}/health"
    }
  }
}