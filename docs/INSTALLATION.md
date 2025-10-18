# Instalação e Configuração - ADC-Agents-Team

## Pré-requisitos

1. **Terraform** v1.6+  
2. **Python** 3.11+  
3. **gcloud CLI** configurado  
4. **Git**  
5. **Credenciais Google** (Service Account JSON)  
6. **Access Token GitHub**  
7. **API Key Linear** (opcional)  

## Passos

```bash
# 1. Clone
git clone https://github.com/AD-Thiago/dev-pipe2.git
cd dev-pipe2/terraform

# 2. Configure variáveis
cp ../.env.example .env

# Edite .env com suas configurações:
# - GOOGLE_PROJECT_ID
# - GOOGLE_CREDENTIALS_FILE
# - IMPERSONATION_EMAIL
# - GITHUB_TOKEN
# - GITHUB_OWNER
# - LINEAR_API_KEY (opcional)
# - YOUR_EMAIL

# 3. Terraform init & apply
terraform init
terraform apply -auto-approve

# 4. Ver outputs
terraform output quick_start_guide
terraform output deployment_summary
```

## Troubleshooting

Ver `terraform output troubleshooting` para guias de problemas comuns.

## Configuração Perplexity Pro

1. Crie um Space no Perplexity Pro
2. Use as custom instructions do output `perplexity_configuration`
3. Faça upload dos arquivos de configuração listados
4. Inicie com: `L1 - INICIAR PIPELINE PRO`

## Estrutura de Arquivos

- `terraform/` - Infraestrutura como código
- `functions/` - Código das Cloud Functions
- `templates/` - Templates para recursos
- `docs/` - Documentação do projeto

## Suporte

Para problemas técnicos, verifique:
1. Logs das Cloud Functions no Google Cloud Console
2. GitHub Actions logs
3. Terraform outputs para troubleshooting