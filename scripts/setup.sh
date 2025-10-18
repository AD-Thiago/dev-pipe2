#!/bin/bash

###############################################################################
# ADC-Agents-Team - Setup Script
# Versão Final - Outubro 2025
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Check if running from correct directory
if [[ ! -f "terraform/main.tf" ]]; then
    print_error "Setup script must be run from project root directory"
    print_error "Expected files: terraform/main.tf, .env.example"
    exit 1
fi

print_header "ADC-Agents-Team Pipeline Setup"

echo "🚀 Iniciando configuração do pipeline automatizado..."
echo "📋 Este script vai verificar dependências e configurar o ambiente"
echo ""

# Check dependencies
print_header "Verificando Dependências"

# Check Terraform
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2)
    print_success "Terraform encontrado: $TERRAFORM_VERSION"
else
    print_error "Terraform não encontrado. Instale: https://terraform.io/downloads"
    exit 1
fi

# Check gcloud
if command -v gcloud &> /dev/null; then
    GCLOUD_VERSION=$(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null || echo "unknown")
    print_success "Google Cloud CLI encontrado: $GCLOUD_VERSION"
else
    print_error "gcloud CLI não encontrado. Instale: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    print_success "Git encontrado: $GIT_VERSION"
else
    print_error "Git não encontrado. Instale git"
    exit 1
fi

# Check jq (optional but recommended)
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    print_success "jq encontrado: $JQ_VERSION"
else
    print_warning "jq não encontrado (opcional). Instale para melhor experiência"
fi

# Check Python (for Cloud Functions)
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_success "Python3 encontrado: $PYTHON_VERSION"
else
    print_warning "Python3 não encontrado. Necessário para desenvolvimento local das Cloud Functions"
fi

print_header "Configuração de Ambiente"

# Check for .env file
if [[ ! -f ".env" ]]; then
    if [[ -f ".env.example" ]]; then
        print_status "Copiando .env.example para .env"
        cp .env.example .env
        print_warning "IMPORTANTE: Edite o arquivo .env com suas configurações!"
        print_status "Variáveis que devem ser configuradas:"
        echo "  - GOOGLE_PROJECT_ID"
        echo "  - GOOGLE_CREDENTIALS_FILE"
        echo "  - IMPERSONATION_EMAIL"
        echo "  - GITHUB_TOKEN"
        echo "  - GITHUB_OWNER"
        echo "  - YOUR_EMAIL"
        echo "  - LINEAR_API_KEY (opcional)"
        echo ""
        read -p "Pressione Enter depois de configurar o .env..." -r
    else
        print_error "Arquivo .env.example não encontrado"
        exit 1
    fi
else
    print_success ".env já existe"
fi

# Load environment variables
if [[ -f ".env" ]]; then
    print_status "Carregando variáveis de ambiente"
    set -a
    source .env
    set +a
fi

# Validate required environment variables
print_header "Validando Configurações"

REQUIRED_VARS=(
    "PROJECT_NAME"
    "GOOGLE_PROJECT_ID"
    "GOOGLE_CREDENTIALS_FILE"
    "GITHUB_TOKEN"
    "GITHUB_OWNER"
    "YOUR_EMAIL"
)

MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then
        MISSING_VARS+=("$var")
    else
        print_success "$var configurado"
    fi
done

if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    print_error "Variáveis obrigatórias não configuradas:"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    print_error "Configure essas variáveis no arquivo .env"
    exit 1
fi

# Check Google credentials file
if [[ ! -f "$GOOGLE_CREDENTIALS_FILE" ]]; then
    print_error "Arquivo de credenciais Google não encontrado: $GOOGLE_CREDENTIALS_FILE"
    print_status "Para obter o arquivo de credenciais:"
    echo "  1. Acesse Google Cloud Console"
    echo "  2. Vá para IAM & Admin > Service Accounts"
    echo "  3. Crie ou selecione uma Service Account"
    echo "  4. Gere uma nova chave JSON"
    echo "  5. Salve como $GOOGLE_CREDENTIALS_FILE"
    exit 1
else
    print_success "Arquivo de credenciais encontrado"
fi

# Validate Google Cloud project
print_status "Verificando projeto Google Cloud"
if gcloud projects describe "$GOOGLE_PROJECT_ID" &>/dev/null; then
    print_success "Projeto Google Cloud válido: $GOOGLE_PROJECT_ID"
else
    print_error "Projeto Google Cloud não encontrado ou sem acesso: $GOOGLE_PROJECT_ID"
    print_status "Verifique:"
    echo "  - Se o projeto existe"
    echo "  - Se você tem permissões"
    echo "  - Se está autenticado: gcloud auth login"
    exit 1
fi

# Test GitHub token
print_status "Verificando GitHub token"
GITHUB_USER=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user | jq -r '.login' 2>/dev/null || echo "error")
if [[ "$GITHUB_USER" != "error" && "$GITHUB_USER" != "null" ]]; then
    print_success "GitHub token válido para usuário: $GITHUB_USER"
else
    print_error "GitHub token inválido ou sem permissões"
    print_status "Para gerar um token:"
    echo "  1. Vá para GitHub Settings > Developer settings > Personal access tokens"
    echo "  2. Generate new token (classic)"
    echo "  3. Selecione scopes: repo, workflow, admin:org"
    exit 1
fi

print_header "Inicializando Terraform"

cd terraform

# Terraform init
print_status "Executando terraform init"
if terraform init; then
    print_success "Terraform inicializado"
else
    print_error "Falha ao inicializar Terraform"
    exit 1
fi

# Terraform validate
print_status "Validando configuração Terraform"
if terraform validate; then
    print_success "Configuração Terraform válida"
else
    print_error "Configuração Terraform inválida"
    exit 1
fi

# Terraform plan
print_status "Gerando plano Terraform"
if terraform plan \
    -var="project_name=$PROJECT_NAME" \
    -var="google_project_id=$GOOGLE_PROJECT_ID" \
    -var="google_credentials_file=../$GOOGLE_CREDENTIALS_FILE" \
    -var="impersonation_email=${IMPERSONATION_EMAIL:-admin@example.com}" \
    -var="github_token=$GITHUB_TOKEN" \
    -var="github_owner=$GITHUB_OWNER" \
    -var="your_email=$YOUR_EMAIL" \
    -var="linear_api_key=${LINEAR_API_KEY:-}" \
    -var="notification_email=${NOTIFICATION_EMAIL:-}" \
    -var="slack_webhook_url=${SLACK_WEBHOOK_URL:-}" \
    -out=tfplan; then
    print_success "Plano Terraform gerado"
else
    print_error "Falha ao gerar plano Terraform"
    exit 1
fi

cd ..

print_header "Setup Completo!"

print_success "✅ Todas as dependências verificadas"
print_success "✅ Configurações validadas"
print_success "✅ Terraform inicializado"
print_success "✅ Plano de execução gerado"

echo ""
print_status "Próximos passos:"
echo "  1. Revise o plano: terraform show terraform/tfplan"
echo "  2. Execute o deploy: ./scripts/deploy.sh"
echo "  3. Configure Perplexity Pro Space conforme instruções"
echo "  4. Inicie o pipeline: 'L1 - INICIAR PIPELINE PRO'"
echo ""

print_success "🚀 Setup concluído com sucesso!"
print_status "Pipeline ADC-Agents-Team pronto para deploy"

echo ""
echo "📋 Resumo das configurações:"
echo "  Projeto: $PROJECT_NAME"
echo "  Google Cloud: $GOOGLE_PROJECT_ID"
echo "  GitHub: $GITHUB_OWNER"
echo "  Owner: $YOUR_EMAIL"
echo ""

print_status "Para fazer o deploy agora, execute: ./scripts/deploy.sh"

exit 0