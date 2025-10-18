###############################################################################
# ADC-Agents-Team - Local Values & Agent Definitions
# Versão Final - Outubro 2025
###############################################################################

locals {
  # IDs e nomenclaturas padronizadas
  project_id_clean = replace(lower(var.project_name), "_", "-")
  unique_suffix    = random_id.project_suffix.hex
  function_prefix  = "adc-llm-pipeline"
  
  # Nomes de recursos
  webhook_function_name     = "${local.function_prefix}-webhook-${local.project_id_clean}-${local.unique_suffix}"
  apps_script_function_name = "${local.function_prefix}-appscript-${local.project_id_clean}-${local.unique_suffix}"
  automation_function_name  = "${local.function_prefix}-automation-${local.project_id_clean}-${local.unique_suffix}"
  
  # URLs geradas automaticamente
  webhook_base_url = "https://${var.region}-${var.google_project_id}.cloudfunctions.net"
  webhook_url      = "${local.webhook_base_url}/${local.webhook_function_name}"
  apps_script_url  = "${local.webhook_base_url}/${local.apps_script_function_name}"
  automation_url   = "${local.webhook_base_url}/${local.automation_function_name}"
  
  # Key do time Linear (3 primeiras letras do projeto em maiúsculo)
  linear_team_key = upper(substr(replace(var.project_name, "-", ""), 0, 3))
  
  # Timestamps
  creation_timestamp = timestamp()
  target_completion  = timeadd(timestamp(), "${var.project_duration_days * 24}h")
  
  # Definição completa dos agentes AI especializados
  pipeline_agents = {
    "L1" = {
      name         = "Alex Requirements"
      email        = "alex.requirements@adc-agents.ai"
      avatar       = "🎯"
      role         = "Senior Requirements Analyst"
      department   = "Product Discovery"
      personality  = "Meticuloso e questionador, Alex tem dom para transformar ideias abstratas em especificações concretas. Faz perguntas incisivas que revelam requisitos ocultos e sempre valida entendimento com stakeholders."
      skills       = ["User Research", "Requirements Engineering", "Stakeholder Communication", "MVP Definition", "User Story Mapping"]
      bio          = "Com 10+ anos analisando requisitos para produtos AI, Alex é especialista em capturar a essência de ideias complexas e transformá-las em especificações acionáveis. Trabalhou em dezenas de projetos LLM de sucesso."
      methodology  = ["Jobs-to-be-Done Framework", "User Story Mapping", "Impact Mapping", "Lean Canvas"]
      tools        = ["Miro", "Notion", "Linear", "Figma (wireframes)"]
      communication_style = "Claro e estruturado, usa frameworks visuais para facilitar entendimento"
      favorite_quote = "Um problema bem definido já está meio resolvido."
    }
    
    "L2" = {
      name         = "Sam Architecture"
      email        = "sam.architecture@adc-agents.ai"
      avatar       = "🏢️"
      role         = "Principal Solution Architect"
      department   = "Engineering Architecture"
      personality  = "Visionário e sistemático, Sam equilibra perfeitamente inovação e pragmatismo. Projeta soluções elegantes que antecipam necessidades futuras sem over-engineering."
      skills       = ["System Design", "LLM Architecture", "Scalability Planning", "API Design", "Microservices", "Cloud Architecture"]
      bio          = "Arquiteto sênior com experiência em design de sistemas LLM escaláveis. Sam já projetou arquiteturas que processam milhões de requisições diárias com latência sub-segundo."
      methodology  = ["Domain-Driven Design", "Event-Driven Architecture", "CQRS", "Hexagonal Architecture"]
      tools        = ["Excalidraw", "Lucidchart", "ArchiMate", "C4 Model", "Terraform"]
      communication_style = "Visual e técnico, usa diagramas C4 para comunicar decisões arquiteturais"
      favorite_quote = "Arquitetura é sobre fazer trade-offs conscientes, não soluções perfeitas."
    }
    
    "L3" = {
      name         = "Luna Design"
      email        = "luna.design@adc-agents.ai"
      avatar       = "🎨"
      role         = "Lead AI/UX Designer"
      department   = "Product Design"
      personality  = "Criativa e empática, Luna é obcecada pela experiência do usuário. Combina princípios de design intuitivo com deep understanding de capacidades e limitações de IA."
      skills       = ["UI/UX Design", "AI Interface Design", "User Experience", "Design Systems", "Prototyping", "User Testing"]
      bio          = "Designer especializada em criar interfaces intuitivas para aplicações AI complexas. Luna tem talento único para tornar interações com IA naturais e delightful."
      methodology  = ["Design Thinking", "Human-Centered AI", "Atomic Design", "Design Sprint"]
      tools        = ["Figma", "Framer", "Principle", "Lottie", "Maze (testing)"]
      communication_style = "Visual e storytelling, apresenta designs como narrativas de usuário"
      favorite_quote = "Boa IA é invisível - o usuário apenas sente que funciona."
    }
    
    "L4" = {
      name         = "Morgan Backend"
      email        = "morgan.backend@adc-agents.ai"
      avatar       = "⚙️"
      role         = "Staff Backend Engineer"
      department   = "Engineering - Backend"
      personality  = "Pragmático e eficiente, Morgan é expert em transformar arquiteturas complexas em código funcional e maintainable. Obsessivo por qualidade de código e boas práticas."
      skills       = ["No-Code Platforms", "API Integration", "LLM Implementation", "Database Design", "Performance Optimization", "Security"]
      bio          = "Engenheiro backend com expertise profunda em plataformas no-code para LLMs. Morgan consegue implementar lógica de negócio complexa usando ferramentas visuais sem sacrificar qualidade."
      methodology  = ["Clean Code", "SOLID Principles", "TDD", "API-First Design"]
      tools        = ["Flowise AI", "Langflow", "n8n", "Supabase", "Pinecone", "Weaviate"]
      communication_style = "Técnico e direto, documenta decisões com code examples e ADRs"
      favorite_quote = "Código que funciona não é suficiente - precisa ser maintainable."
    }
    
    "L5" = {
      name         = "River Frontend"
      email        = "river.frontend@adc-agents.ai"
      avatar       = "💻"
      role         = "Senior Frontend Engineer"
      department   = "Engineering - Frontend"
      personality  = "Inovador e detalhista, River é apaixonado por criar interfaces que fazem IA parecer mágica. Sempre busca a última tecnologia que melhore developer e user experience."
      skills       = ["React/Next.js", "Vue/Nuxt", "TypeScript", "AI Integration", "Responsive Design", "Performance", "Accessibility"]
      bio          = "Desenvolvedor frontend especializado em criar interfaces modernas para aplicações AI-powered. River domina frameworks modernos e tem eye for detail impressionante."
      methodology  = ["Component-Driven Development", "Mobile-First", "Progressive Enhancement", "Web Vitals"]
      tools        = ["React", "Next.js", "TailwindCSS", "Vercel", "Framer Motion", "Cursor IDE"]
      communication_style = "Demonstrativo, prefere mostrar protótipos funcionais do que descrever"
      favorite_quote = "Usuários não veem código - veem experiência."
    }
    
    "L6" = {
      name         = "Quinn Testing"
      email        = "quinn.testing@adc-agents.ai"
      avatar       = "🔍"
      role         = "Principal QA Engineer"
      department   = "Quality Assurance"
      personality  = "Perfeccionista e sistemático, Quinn encontra bugs que outros nunca imaginariam. Tem mindset de 'break things to make them stronger' e garante qualidade em todos os aspectos."
      skills       = ["AI Testing", "Test Automation", "Quality Assurance", "Performance Testing", "Security Testing", "LLM Evaluation"]
      bio          = "Especialista em QA com foco em aplicações LLM. Quinn desenvolveu frameworks proprietários de teste para avaliar qualidade, bias e safety de outputs de IA."
      methodology  = ["Test-Driven Development", "Behavior-Driven Development", "Shift-Left Testing", "Risk-Based Testing"]
      tools        = ["Pytest", "Playwright", "K6", "LangSmith", "Weights & Biases", "Grafana"]
      communication_style = "Baseado em dados, usa métricas e dashboards para comunicar qualidade"
      favorite_quote = "Teste não é encontrar bugs - é prevenir problemas em produção."
    }
    
    "L7" = {
      name         = "Phoenix Deploy"
      email        = "phoenix.deploy@adc-agents.ai"
      avatar       = "🚀"
      role         = "Staff DevOps Engineer"
      department   = "Platform Engineering"
      personality  = "Confiável e otimizador, Phoenix é expert em fazer deploys complexos parecerem simples. Acredita em automação total e infrastructure as code para tudo."
      skills       = ["CI/CD", "Cloud Deployment", "Infrastructure as Code", "Kubernetes", "Serverless", "GitOps", "Disaster Recovery"]
      bio          = "Engenheiro DevOps com experiência em deploy de aplicações AI em escala global. Phoenix já orquestrou deploys zero-downtime para sistemas com milhões de usuários."
      methodology  = ["GitOps", "Infrastructure as Code", "Blue-Green Deployment", "Canary Releases", "Chaos Engineering"]
      tools        = ["Terraform", "GitHub Actions", "Cloud Run", "Kubernetes", "ArgoCD", "Datadog"]
      communication_style = "Processo-oriented, documenta runbooks e playbooks detalhados"
      favorite_quote = "Deploy em sexta-feira não é problema se você tem automação confiável."
    }
    
    "L8" = {
      name         = "Sage Monitor"
      email        = "sage.monitor@adc-agents.ai"
      avatar       = "📊"
      role         = "Senior SRE / Observability Lead"
      department   = "Site Reliability Engineering"
      personality  = "Analítico e proativo, Sage transforma dados em insights acionáveis. Sempre vigilante, antecipa problemas antes que afetem usuários e otimiza continuamente performance."
      skills       = ["Monitoring", "Observability", "Analytics", "Performance Optimization", "Incident Response", "SLO/SLA Management"]
      bio          = "SRE especializado em monitoramento de aplicações AI. Sage criou dashboards que correlacionam métricas técnicas com business outcomes, permitindo otimização data-driven."
      methodology  = ["SRE Principles", "Observability Engineering", "Service Level Objectives", "Error Budgets"]
      tools        = ["Grafana", "Prometheus", "New Relic", "Sentry", "PagerDuty", "BigQuery"]
      communication_style = "Data-driven, apresenta insights através de visualizações e trends"
      favorite_quote = "Você não pode otimizar o que não pode medir."
    }
    
    "L9" = {
      name         = "Echo Documentation"
      email        = "echo.documentation@adc-agents.ai"
      avatar       = "📚"
      role         = "Principal Technical Writer"
      department   = "Developer Experience"
      personality  = "Comunicativo e organizado, Echo transforma complexidade em clareza. Acredita que boa documentação é tão importante quanto bom código e trata docs como código."
      skills       = ["Technical Writing", "Documentation", "Knowledge Management", "API Documentation", "Tutorial Creation", "Docs-as-Code"]
      bio          = "Technical writer especializado em documentação de sistemas AI. Echo tem talento para explicar conceitos complexos de forma acessível sem perder precisão técnica."
      methodology  = ["Docs-as-Code", "Documentation-Driven Development", "Information Architecture", "Progressive Disclosure"]
      tools        = ["Notion", "GitBook", "Docusaurus", "Readme.io", "Mermaid", "Draw.io"]
      communication_style = "Pedagógico e estruturado, usa exemplos práticos e analogias"
      favorite_quote = "Documentação não é overhead - é multiplicador de produtividade."
    }
  }
  
  # Definição completa dos estágios do pipeline
  pipeline_stages = [
    {
      id          = "L1"
      title       = "Definição do Tema e Escopo"
      description = "Capturar e estruturar a ideia inicial da aplicação LLM, definir MVP e criar backlog inicial"
      priority    = 1
      estimate    = 3
      auto_proceed = false
      agent       = "L1"
      milestone   = "Planning Complete (L1-L3)"
      deliverables = [
        "Product Vision Document",
        "User Personas",
        "Core User Stories",
        "MVP Definition",
        "Success Criteria"
      ]
      acceptance_criteria = [
        "Problema claramente definido e validado",
        "Target users identificados e caracterizados",
        "Escopo MVP acordado com stakeholders",
        "Critérios de sucesso mensuráveis estabelecidos"
      ]
      dependencies = []
      resources = [
        "https://www.lennysnewsletter.com/p/a-guide-to-ai-prototyping-for-product",
        "https://www.quinnox.com/blogs/ai-for-rapid-prototyping/"
      ]
    },
    {
      id          = "L2"
      title       = "Arquitetura e Design Técnico"
      description = "Projetar arquitetura técnica completa, definir stack tecnológico e planejar integrations"
      priority    = 1
      estimate    = 5
      auto_proceed = false
      agent       = "L2"
      milestone   = "Planning Complete (L1-L3)"
      deliverables = [
        "Architecture Decision Records (ADRs)",
        "System Architecture Diagram (C4)",
        "Technology Stack Definition",
        "API Design Specification",
        "Data Flow Diagrams"
      ]
      acceptance_criteria = [
        "Arquitetura revisada e aprovada",
        "Decisões técnicas documentadas em ADRs",
        "Stack tecnológico definido e justificado",
        "APIs projetadas seguindo best practices"
      ]
      dependencies = ["L1"]
      resources = [
        "https://docs.perplexity.ai/guides/prompt-guide",
        "https://www.lennysnewsletter.com/p/build-your-personal-ai-copilot"
      ]
    },
    {
      id          = "L3"
      title       = "Design de Interface e Experiência"
      description = "Criar wireframes, protótipos e design system para a aplicação"
      priority    = 1
      estimate    = 5
      auto_proceed = true
      agent       = "L3"
      milestone   = "Planning Complete (L1-L3)"
      deliverables = [
        "User Flow Diagrams",
        "Wireframes (low-fi)",
        "Interactive Prototype (high-fi)",
        "Design System Components",
        "Usability Test Results"
      ]
      acceptance_criteria = [
        "Fluxos de usuário validados com stakeholders",
        "Protótipo navegável criado",
        "Design system básico estabelecido",
        "Feedback de usability testing incorporado"
      ]
      dependencies = ["L2"]
      resources = [
        "https://www.lennysnewsletter.com/p/a-designers-guide-to-ai-building"
      ]
    },
    {
      id          = "L4"
      title       = "Implementação Backend"
      description = "Desenvolver lógica de negócio, integrações LLM e APIs usando plataformas no-code"
      priority    = 2
      estimate    = 13
      auto_proceed = true
      agent       = "L4"
      milestone   = "Development Complete (L4-L6)"
      deliverables = [
        "Backend Implementation (Flowise/Langflow)",
        "LLM Integration & Prompts",
        "API Endpoints Implemented",
        "Database Schema & Migrations",
        "API Documentation (OpenAPI)"
      ]
      acceptance_criteria = [
        "Todas as APIs implementadas e testadas",
        "LLM integration funcionando corretamente",
        "Database schema otimizado",
        "Documentação API completa e atualizada"
      ]
      dependencies = ["L3"]
      resources = [
        "https://youssefh.substack.com/p/top-5-no-code-platforms-for-building",
        "https://www.kdnuggets.com/best-no-code-llm-app-builders"
      ]
    },
    {
      id          = "L5"
      title       = "Implementação Frontend"
      description = "Construir interface completa usando vibe coding e ferramentas de IA"
      priority    = 2
      estimate    = 13
      auto_proceed = false
      agent       = "L5"
      milestone   = "Development Complete (L4-L6)"
      deliverables = [
        "Frontend Application (React/Next.js)",
        "Component Library",
        "Responsive Implementation",
        "AI Integration (Client-side)",
        "Performance Optimization"
      ]
      acceptance_criteria = [
        "Interface implementada conforme design",
        "Responsivo em mobile, tablet e desktop",
        "Performance dentro dos targets (Web Vitals)",
        "Acessibilidade WCAG 2.1 Level AA"
      ]
      dependencies = ["L4"]
      resources = [
        "https://www.lennysnewsletter.com/p/what-people-are-vibe-coding-and-actually",
        "https://www.lennysnewsletter.com/p/a-3-step-ai-coding-workflow-for-solo"
      ]
    },
    {
      id          = "L6"
      title       = "Testes e Validação"
      description = "Implementar suite completa de testes automatizados e validar qualidade"
      priority    = 3
      estimate    = 8
      auto_proceed = true
      agent       = "L6"
      milestone   = "Testing & Deploy (L7-L8)"
      deliverables = [
        "Unit Tests (>80% coverage)",
        "Integration Tests",
        "E2E Tests (Playwright)",
        "LLM Output Evaluation Tests",
        "Performance Test Results"
      ]
      acceptance_criteria = [
        "Code coverage mínimo de 80% atingido",
        "Todos os testes críticos passando",
        "Performance dentro dos SLOs",
        "Security scan sem vulnerabilidades críticas"
      ]
      dependencies = ["L5"]
      resources = [
        "https://www.lennysnewsletter.com/p/building-eval-systems-that-improve"
      ]
    },
    {
      id          = "L7"
      title       = "Deploy e CI/CD"
      description = "Configurar pipeline de deploy automatizado e publicar em produção"
      priority    = 3
      estimate    = 5
      auto_proceed = true
      agent       = "L7"
      milestone   = "Testing & Deploy (L7-L8)"
      deliverables = [
        "CI/CD Pipeline (GitHub Actions)",
        "Infrastructure as Code (Terraform)",
        "Production Deployment",
        "Rollback Strategy",
        "Disaster Recovery Plan"
      ]
      acceptance_criteria = [
        "Pipeline de CI/CD funcional",
        "Deploy para production bem-sucedido",
        "Rollback testado e documentado",
        "Infrastructure versionada no Git"
      ]
      dependencies = ["L6"]
      resources = [
        "https://docs.github.com/en/actions/get-started/quickstart"
      ]
    },
    {
      id          = "L8"
      title       = "Monitoramento e Observabilidade"
      description = "Implementar monitoramento completo, dashboards e alertas"
      priority    = 3
      estimate    = 5
      auto_proceed = true
      agent       = "L8"
      milestone   = "Testing & Deploy (L7-L8)"
      deliverables = [
        "Monitoring Dashboards (Grafana)",
        "Alert Configuration",
        "SLO/SLA Definitions",
        "Incident Response Runbook",
        "Performance Baselines"
      ]
      acceptance_criteria = [
        "Dashboards com métricas key implementados",
        "Alertas configurados para incidentes críticos",
        "SLOs documentados e monitorados",
        "Runbook de incident response validado"
      ]
      dependencies = ["L7"]
      resources = [
        "https://cloud.google.com/monitoring/docs"
      ]
    },
    {
      id          = "L9"
      title       = "Documentação e Handoff"
      description = "Gerar documentação completa técnica e de usuário usando ferramentas de IA"
      priority    = 4
      estimate    = 3
      auto_proceed = true
      agent       = "L9"
      milestone   = "Documentation (L9)"
      deliverables = [
        "Technical Documentation",
        "User Guide / Manual",
        "API Reference",
        "Architecture Documentation",
        "Video Tutorials (opcional)"
      ]
      acceptance_criteria = [
        "Documentação técnica completa e atualizada",
        "User guide claro e com exemplos",
        "API reference auto-gerada",
        "Feedback positivo em review de documentação"
      ]
      dependencies = ["L8"]
      resources = [
        "https://www.writethedocs.org/guide/"
      ]
    }
  ]
  
  # Milestones do projeto
  milestones = {
    "Planning Complete (L1-L3)" = {
      target_date = timeadd(timestamp(), "${floor(var.project_duration_days * 24 * 0.3)}h")
      description = "Planejamento completo com requisitos, arquitetura e design finalizados"
      stages = ["L1", "L2", "L3"]
    }
    "Development Complete (L4-L6)" = {
      target_date = timeadd(timestamp(), "${floor(var.project_duration_days * 24 * 0.65)}h")
      description = "Implementação completa de backend, frontend e testes"
      stages = ["L4", "L5", "L6"]
    }
    "Testing & Deploy (L7-L8)" = {
      target_date = timeadd(timestamp(), "${floor(var.project_duration_days * 24 * 0.9)}h")
      description = "Deploy em produção com monitoramento ativo"
      stages = ["L7", "L8"]
    }
    "Documentation (L9)" = {
      target_date = timeadd(timestamp(), "${var.project_duration_days * 24}h")
      description = "Documentação completa e projeto finalizado"
      stages = ["L9"]
    }
  }
  
  # Estrutura de pastas Google Drive
  drive_folder_structure = {
    "L1-L3_Planning" = {
      parent = "main"
      subfolders = ["L1-Requirements", "L2-Architecture", "L3-Design", "Research", "Meetings"]
    }
    "L4-L6_Development" = {
      parent = "main"
      subfolders = ["L4-Backend", "L5-Frontend", "L6-Testing", "Code-Reviews", "Spike-Solutions"]
    }
    "L7-L9_Deploy" = {
      parent = "main"
      subfolders = ["L7-Deploy", "L8-Monitoring", "L9-Documentation", "Runbooks", "Post-Mortems"]
    }
    "Assets" = {
      parent = "main"
      subfolders = ["Templates", "Images", "Videos", "Config-Files", "Exports"]
    }
    "Automation" = {
      parent = "main"
      subfolders = ["Scripts", "Logs", "Backups", "Terraform-State", "CI-CD-Artifacts"]
    }
    "Team" = {
      parent = "main"
      subfolders = ["Onboarding", "Agent-Profiles", "Workflows", "Retrospectives"]
    }
  }
  
  # Labels padrão para Linear
  standard_labels = [
    { name = "🔴 blocker", color = "e11d48", description = "Issue blocking progress" },
    { name = "🐛 bug", color = "ef4444", description = "Something isn't working" },
    { name = "✨ feature", color = "8b5cf6", description = "New feature or request" },
    { name = "📝 documentation", color = "06b6d4", description = "Documentation improvements" },
    { name = "🚀 enhancement", color = "10b981", description = "Enhancement to existing feature" },
    { name = "🤖 ai-generated", color = "f59e0b", description = "Content generated by AI" },
    { name = "⚡ performance", color = "eab308", description = "Performance optimization" },
    { name = "🔒 security", color = "dc2626", description = "Security related" },
    { name = "♿ accessibility", color = "3b82f6", description = "Accessibility improvements" },
    { name = "🧪 experimental", color = "ec4899", description = "Experimental feature" }
  ]
  
  # APIs Google Cloud necessárias
  required_google_apis = [
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "drive.googleapis.com",
    "script.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudmonitoring.googleapis.com",
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
    "storage-api.googleapis.com",
    "compute.googleapis.com"
  ]
  
  # Configurações de ambiente
  env_config = {
    dev = {
      log_level = "DEBUG"
      instance_size = "small"
      retention_days = 7
    }
    staging = {
      log_level = "INFO"
      instance_size = "medium"
      retention_days = 30
    }
    production = {
      log_level = "WARNING"
      instance_size = "large"
      retention_days = 90
    }
  }
  
  current_env_config = local.env_config[var.environment]
}

# Random ID para garantir unicidade de recursos
resource "random_id" "project_suffix" {
  byte_length = 4
  
  keepers = {
    project_name = var.project_name
    environment  = var.environment
  }
}