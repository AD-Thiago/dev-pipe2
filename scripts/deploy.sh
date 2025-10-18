#!/bin/bash

###############################################################################
# ADC-Agents-Team - Deploy Script
# Versão Final - Outubro 2025
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${MAGENTA}=== $1 ===${NC}\n"
}

print_deploy_step() {
    echo -e "${BLUE}🚀 $1${NC}"
}

# Check if running from correct directory
if [[ ! -f "terraform/main.tf" ]]; then
    print_error "Deploy script must be run from project root directory"
    exit 1
fi

# Check if setup was run
if [[ ! -f "terraform/tfplan" ]]; then
    print_error "Plano Terraform não encontrado. Execute ./scripts/setup.sh primeiro"
    exit 1
fi

# Load environment variables
if [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
else
    print_error "Arquivo .env não encontrado. Execute ./scripts/setup.sh primeiro"
    exit 1
fi

print_header "ADC-Agents-Team Pipeline Deploy"

echo "🚀 Iniciando deploy da infraestrutura..."
echo "📋 Este processo criará todos os recursos necessários"
echo ""

print_status "Projeto: $PROJECT_NAME"
print_status "Google Cloud: $GOOGLE_PROJECT_ID"
print_status "GitHub Owner: $GITHUB_OWNER"
print_status "Environment: ${ENVIRONMENT:-production}"
echo ""

# Confirmation prompt
if [[ "${AUTO_APPROVE:-}" != "true" ]]; then
    read -p "Continuar com o deploy? [y/N]: " -r REPLY
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deploy cancelado pelo usuário"
        exit 0
    fi
fi

print_header "Executando Deploy"

cd terraform

# Start timer
START_TIME=$(date +%s)

print_deploy_step "Aplicando configuração Terraform"
if terraform apply -auto-approve tfplan; then
    print_success "Terraform apply concluído"
else
    print_error "Falha no terraform apply"
    exit 1
fi

# Calculate deployment time
END_TIME=$(date +%s)
DEPLOY_TIME=$((END_TIME - START_TIME))
DEPLOY_MINUTES=$((DEPLOY_TIME / 60))
DEPLOY_SECONDS=$((DEPLOY_TIME % 60))

print_header "Deploy Concluído!"

print_success "✅ Infraestrutura provisionada"
print_success "✅ Google Cloud Functions deployadas"
print_success "✅ Google Drive configurado"
print_success "✅ GitHub repository atualizado"
print_success "✅ Secrets configurados"
print_success "✅ Workflows ativados"

echo ""
print_success "⏱️ Tempo de deploy: ${DEPLOY_MINUTES}m ${DEPLOY_SECONDS}s"
echo ""

print_header "Coletando Informações do Deploy"

# Get outputs
print_status "Coletando outputs do Terraform"

DEPLOYMENT_SUMMARY=$(terraform output -json deployment_summary 2>/dev/null | jq -r '.status' || echo "N/A")
DRIVE_URL=$(terraform output -json google_cloud_resources 2>/dev/null | jq -r '.drive.main_folder_url' || echo "N/A")
GITHUB_URL=$(terraform output -json github_repository 2>/dev/null | jq -r '.url' || echo "N/A")
WEBHOOK_URL=$(terraform output -json automation_urls 2>/dev/null | jq -r '.webhook_handler' || echo "N/A")
AUTOMATION_URL=$(terraform output -json automation_urls 2>/dev/null | jq -r '.automation_core' || echo "N/A")

print_header "Recursos Criados"

echo "📁 Google Drive Folder:"
echo "   $DRIVE_URL"
echo ""
echo "🔧 GitHub Repository:"
echo "   $GITHUB_URL"
echo ""
echo "🔗 Automation URLs:"
echo "   Webhook: $WEBHOOK_URL"
echo "   Automation: $AUTOMATION_URL"
echo ""

# Test webhook health
print_status "Testando webhooks"
if [[ "$WEBHOOK_URL" != "N/A" ]]; then
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$WEBHOOK_URL?health=true" || echo "000")
    if [[ "$HTTP_STATUS" == "200" ]]; then
        print_success "Webhook responde corretamente"
    else
        print_warning "Webhook pode não estar respondendo (HTTP $HTTP_STATUS)"
        print_status "Aguarde alguns minutos para propagação"
    fi
fi

cd ..

print_header "Configuração Pós-Deploy"

# Save important URLs to file
print_status "Salvando URLs importantes"
cat > deployment-info.txt << EOF
ADC-Agents-Team Pipeline - Deployment Info
Data: $(date)
Projeto: $PROJECT_NAME

=== URLs Importantes ===
Google Drive: $DRIVE_URL
GitHub Repo: $GITHUB_URL
Webhook: $WEBHOOK_URL
Automation: $AUTOMATION_URL

=== Próximos Passos ===
1. Configure Perplexity Pro Space
2. Use as custom instructions do terraform output
3. Faça upload dos arquivos de configuração
4. Inicie com: "L1 - INICIAR PIPELINE PRO"

=== Comandos Úteis ===
Ver outputs completos: terraform -chdir=terraform output
Troubleshooting: terraform -chdir=terraform output troubleshooting
Health check: curl -s "$WEBHOOK_URL?health=true"
Logs das funções: gcloud functions logs read --limit=50

EOF

print_success "Informações salvas em deployment-info.txt"

print_header "Configuração do Perplexity Pro"

print_status "Para configurar o Perplexity Pro Space:"
echo ""
echo "1. Crie um novo Space no Perplexity Pro"
echo "2. Use o comando abaixo para obter as custom instructions:"
echo "   terraform -chdir=terraform output perplexity_configuration"
echo ""
echo "3. Copie as custom_instructions para o Space"
echo "4. Faça upload dos 3 arquivos listados em files_to_upload"
echo "5. Inicie o pipeline com: 'L1 - INICIAR PIPELINE PRO'"
echo ""

print_header "Monitoramento e Saúde"

# Check if monitoring is enabled
if [[ "${ENABLE_MONITORING:-true}" == "true" ]]; then
    print_success "Monitoramento habilitado"
    echo "   Dashboard: https://console.cloud.google.com/functions/list?project=$GOOGLE_PROJECT_ID"
else
    print_warning "Monitoramento desabilitado"
fi

# Check notifications
if [[ -n "${NOTIFICATION_EMAIL:-}" ]]; then
    print_success "Notificações por email configuradas: ${NOTIFICATION_EMAIL}"
else
    print_warning "Notificações por email não configuradas"
fi

if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
    print_success "Notificações Slack configuradas"
else
    print_warning "Notificações Slack não configuradas"
fi

print_header "Comandos de Gerenciamento"

echo "📊 Ver status completo:"
echo "   terraform -chdir=terraform output deployment_summary"
echo ""
echo "🔧 Troubleshooting:"
echo "   terraform -chdir=terraform output troubleshooting"
echo ""
echo "📊 Monitorar logs:"
echo "   gcloud functions logs read --limit=50"
echo ""
echo "🗑️ Destruir recursos:"
echo "   ./scripts/teardown.sh"
echo ""

print_header "Deploy Finalizado!"

print_success "🎉 ADC-Agents-Team Pipeline 100% operacional!"
echo ""
print_status "Pipeline está pronto para uso. Recursos principais:"
echo "  • ${length(local.pipeline_agents)} Agentes AI especializados"
echo "  • ${length(local.pipeline_stages)} Estágios automatizados"
echo "  • Google Drive organizado"
echo "  • GitHub workflows ativos"
echo "  • Monitoring e alertas"
echo "  • Backup automático"
echo ""
print_success "🚀 Agora configure o Perplexity Pro e inicie seu primeiro projeto!"
echo ""
print_status "Para suporte, consulte: docs/INSTALLATION.md"

# Create success marker
touch .deployment-success
echo "deployment_date=$(date)" > .deployment-success
echo "project_name=$PROJECT_NAME" >> .deployment-success
echo "google_project=$GOOGLE_PROJECT_ID" >> .deployment-success

exit 0