#!/bin/bash

###############################################################################
# ADC-Agents-Team - Teardown Script
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

print_destroy_step() {
    echo -e "${RED}🗑️ $1${NC}"
}

# Check if running from correct directory
if [[ ! -f "terraform/main.tf" ]]; then
    print_error "Teardown script must be run from project root directory"
    exit 1
fi

# Load environment variables if available
if [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
fi

print_header "ADC-Agents-Team Pipeline Teardown"

print_warning "⚠️  ATENÇÃO: Este script irá DESTRUIR todos os recursos!"
print_warning "⚠️  Isto inclui:"
echo "    • Google Cloud Functions"
echo "    • Google Storage Buckets"
echo "    • Google Drive folders"
echo "    • GitHub Secrets"
echo "    • Todos os dados armazenados"
echo ""

# Show current project info if available
if [[ -n "${PROJECT_NAME:-}" ]]; then
    print_status "Projeto atual: ${PROJECT_NAME}"
fi
if [[ -n "${GOOGLE_PROJECT_ID:-}" ]]; then
    print_status "Google Cloud: ${GOOGLE_PROJECT_ID}"
fi
if [[ -n "${GITHUB_OWNER:-}" ]]; then
    print_status "GitHub Owner: ${GITHUB_OWNER}"
fi
echo ""

# Multiple confirmations for safety
print_warning "Esta ação é IRREVERSÍVEL!"
echo ""

read -p "Tem certeza que deseja destruir TODOS os recursos? [yes/NO]: " -r REPLY1
if [[ ! $REPLY1 == "yes" ]]; then
    print_status "Teardown cancelado"
    exit 0
fi

echo ""
print_error "CONFIRMAÇÃO FINAL"
read -p "Digite 'DESTROY' em maiúsculas para confirmar: " -r REPLY2
if [[ ! $REPLY2 == "DESTROY" ]]; then
    print_status "Teardown cancelado"
    exit 0
fi

echo ""
print_header "Iniciando Destruição"

# Start timer
START_TIME=$(date +%s)

cd terraform

# Check if terraform is initialized
if [[ ! -d ".terraform" ]]; then
    print_warning "Terraform não inicializado. Tentando inicializar..."
    if ! terraform init; then
        print_error "Falha ao inicializar Terraform"
        print_status "Você pode precisar destruir recursos manualmente:"
        echo "  1. Google Cloud Console: https://console.cloud.google.com"
        echo "  2. GitHub Settings: https://github.com/settings"
        echo "  3. Google Drive: https://drive.google.com"
        exit 1
    fi
fi

# Create destroy plan
print_destroy_step "Criando plano de destruição"
if terraform plan -destroy \
    -var="project_name=${PROJECT_NAME:-dev-pipe2}" \
    -var="google_project_id=${GOOGLE_PROJECT_ID:-}" \
    -var="google_credentials_file=../${GOOGLE_CREDENTIALS_FILE:-credentials.json}" \
    -var="impersonation_email=${IMPERSONATION_EMAIL:-admin@example.com}" \
    -var="github_token=${GITHUB_TOKEN:-}" \
    -var="github_owner=${GITHUB_OWNER:-}" \
    -var="your_email=${YOUR_EMAIL:-admin@example.com}" \
    -var="linear_api_key=${LINEAR_API_KEY:-}" \
    -var="notification_email=${NOTIFICATION_EMAIL:-}" \
    -var="slack_webhook_url=${SLACK_WEBHOOK_URL:-}" \
    -out=destroy-plan; then
    print_success "Plano de destruição criado"
else
    print_error "Falha ao criar plano de destruição"
    print_status "Tentando destruição sem plano..."
fi

# Execute destroy
print_destroy_step "Executando destruição dos recursos"
if [[ -f "destroy-plan" ]]; then
    if terraform apply -auto-approve destroy-plan; then
        print_success "Recursos destruídos via plano"
    else
        print_error "Falha na destruição via plano"
        print_status "Tentando terraform destroy direto..."
        terraform destroy -auto-approve \
            -var="project_name=${PROJECT_NAME:-dev-pipe2}" \
            -var="google_project_id=${GOOGLE_PROJECT_ID:-}" \
            -var="google_credentials_file=../${GOOGLE_CREDENTIALS_FILE:-credentials.json}" \
            -var="impersonation_email=${IMPERSONATION_EMAIL:-admin@example.com}" \
            -var="github_token=${GITHUB_TOKEN:-}" \
            -var="github_owner=${GITHUB_OWNER:-}" \
            -var="your_email=${YOUR_EMAIL:-admin@example.com}" \
            -var="linear_api_key=${LINEAR_API_KEY:-}" \
            -var="notification_email=${NOTIFICATION_EMAIL:-}" \
            -var="slack_webhook_url=${SLACK_WEBHOOK_URL:-}"
    fi
else
    terraform destroy -auto-approve \
        -var="project_name=${PROJECT_NAME:-dev-pipe2}" \
        -var="google_project_id=${GOOGLE_PROJECT_ID:-}" \
        -var="google_credentials_file=../${GOOGLE_CREDENTIALS_FILE:-credentials.json}" \
        -var="impersonation_email=${IMPERSONATION_EMAIL:-admin@example.com}" \
        -var="github_token=${GITHUB_TOKEN:-}" \
        -var="github_owner=${GITHUB_OWNER:-}" \
        -var="your_email=${YOUR_EMAIL:-admin@example.com}" \
        -var="linear_api_key=${LINEAR_API_KEY:-}" \
        -var="notification_email=${NOTIFICATION_EMAIL:-}" \
        -var="slack_webhook_url=${SLACK_WEBHOOK_URL:-}"
fi

cd ..

# Calculate teardown time
END_TIME=$(date +%s)
TEARDOWN_TIME=$((END_TIME - START_TIME))
TEARDOWN_MINUTES=$((TEARDOWN_TIME / 60))
TEARDOWN_SECONDS=$((TEARDOWN_TIME % 60))

print_header "Limpeza Pós-Teardown"

# Clean up local files
print_status "Limpando arquivos locais"

FILES_TO_CLEAN=(
    "terraform/.terraform.lock.hcl"
    "terraform/terraform.tfstate"
    "terraform/terraform.tfstate.backup"
    "terraform/tfplan"
    "terraform/destroy-plan"
    "deployment-info.txt"
    ".deployment-success"
)

for file in "${FILES_TO_CLEAN[@]}"; do
    if [[ -f "$file" ]]; then
        rm "$file"
        print_status "Removido: $file"
    fi
done

# Clean terraform directory
if [[ -d "terraform/.terraform" ]]; then
    rm -rf "terraform/.terraform"
    print_status "Removido: terraform/.terraform"
fi

# Optionally remove .env file
read -p "Remover arquivo .env? [y/N]: " -r REMOVE_ENV
if [[ $REMOVE_ENV =~ ^[Yy]$ ]]; then
    if [[ -f ".env" ]]; then
        rm ".env"
        print_status "Removido: .env"
    fi
else
    print_warning "Arquivo .env mantido (contém credenciais)"
fi

print_header "Teardown Concluído"

print_success "✅ Recursos do Google Cloud destruídos"
print_success "✅ GitHub Secrets removidos"
print_success "✅ Arquivos locais limpos"
print_success "✅ Estado Terraform resetado"

echo ""
print_success "⏱️ Tempo de teardown: ${TEARDOWN_MINUTES}m ${TEARDOWN_SECONDS}s"
echo ""

print_warning "IMPORTANTE: Verifique manualmente se restaram recursos:"
echo ""
echo "🔗 Google Cloud Console:"
echo "   https://console.cloud.google.com/functions/list?project=${GOOGLE_PROJECT_ID:-PROJECT_ID}"
echo "   https://console.cloud.google.com/storage/browser?project=${GOOGLE_PROJECT_ID:-PROJECT_ID}"
echo ""
echo "🔗 GitHub Settings:"
echo "   https://github.com/${GITHUB_OWNER:-OWNER}/dev-pipe2/settings/secrets/actions"
echo ""
echo "🔗 Google Drive:"
echo "   https://drive.google.com (procure por pastas ADC-Pipeline-*)"
echo ""

print_header "Recursos Possivelmente Remanescentes"

print_warning "Os seguintes recursos podem não ter sido removidos automaticamente:"
echo ""
echo "• Google Drive folders (podem estar na lixeira)"
echo "• Google Cloud APIs habilitadas"
echo "• IAM roles e service accounts"
echo "• GitHub repository (dev-pipe2)"
echo "• Linear projects e issues"
echo "• Perplexity Pro Space configurado"
echo ""

print_status "Para remoção completa, limpe esses recursos manualmente"

print_header "Reinicialização"

print_status "Para criar um novo pipeline:"
echo "  1. Configure novas credenciais se necessário"
echo "  2. Execute: ./scripts/setup.sh"
echo "  3. Execute: ./scripts/deploy.sh"
echo ""

print_success "🗑️ ADC-Agents-Team Pipeline removido com sucesso!"
print_status "Obrigado por usar o ADC-Agents-Team Pipeline"

exit 0