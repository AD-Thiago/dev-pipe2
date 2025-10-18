# Estrutura do Projeto - ${project_name}

**Data de Criação:** ${creation_timestamp}  
**Product Owner:** ${your_name} (${your_email})  
**Ambiente:** ${environment}  
**Versão:** 1.0.0

## 📁 Estrutura de Pastas Google Drive

### 💼 Pasta Principal

**ADC-Pipeline-${project_name}** (ID: ${drive_folder_id})
🔗 [Acessar Pasta](https://drive.google.com/drive/folders/${drive_folder_id})

```
ADC-Pipeline-${project_name}/
%{ for folder_name, config in drive_folder_structure }
├── ${folder_name}/
%{ for subfolder in config.subfolders }
│   ├── ${subfolder}/
%{ endfor }
│
%{ endfor }
```

### 📋 Descrição das Pastas

%{ for folder_name, config in drive_folder_structure }
#### ${folder_name}

%{ if folder_name == "L1-L3_Planning" }
**Finalidade:** Documentação da fase de planejamento do pipeline

- **L1-Requirements:** Análise de requisitos, user stories, MVP definition
- **L2-Architecture:** Diagramas de arquitetura, ADRs, especificações técnicas
- **L3-Design:** Wireframes, protótipos, design system, user flows
- **Research:** Pesquisa de mercado, referências, benchmarks
- **Meetings:** Atas de reuniões, decisões, alinhamentos
%{ endif }

%{ if folder_name == "L4-L6_Development" }
**Finalidade:** Artefatos da fase de desenvolvimento

- **L4-Backend:** Código backend, configurações no-code, integrações LLM
- **L5-Frontend:** Código frontend, componentes, assets visuais
- **L6-Testing:** Planos de teste, relatórios, scripts de automação
- **Code-Reviews:** Feedback de revisões de código
- **Spike-Solutions:** Investigações técnicas, POCs, experimentos
%{ endif }

%{ if folder_name == "L7-L9_Deploy" }
**Finalidade:** Deploy, monitoramento e documentação final

- **L7-Deploy:** Scripts de deploy, configurações CI/CD, release notes
- **L8-Monitoring:** Dashboards, alertas, métricas, incidents
- **L9-Documentation:** Manuais, guides, API docs, videos
- **Runbooks:** Procedimentos operacionais, troubleshooting
- **Post-Mortems:** Análises de incidentes, lições aprendidas
%{ endif }

%{ if folder_name == "Assets" }
**Finalidade:** Recursos compartilhados do projeto

- **Templates:** Templates reutilizáveis para documentação
- **Images:** Logos, ícones, screenshots, diagramas
- **Videos:** Screen recordings, demos, apresentações
- **Config-Files:** Arquivos de configuração, environments
- **Exports:** Exports de dados, relatórios, backups
%{ endif }

%{ if folder_name == "Automation" }
**Finalidade:** Arquivos de automação e orquestração

- **Scripts:** Scripts de automação, hooks, utilities
- **Logs:** Logs do sistema, execuções, debug info
- **Backups:** Backups automáticos, snapshots
- **Terraform-State:** Estados do Terraform, plans
- **CI-CD-Artifacts:** Artefatos de build, deploy, releases
%{ endif }

%{ if folder_name == "Team" }
**Finalidade:** Informações e recursos do time

- **Onboarding:** Materiais de integração de novos membros
- **Agent-Profiles:** Perfis detalhados dos agentes AI
- **Workflows:** Processos e workflows de trabalho
- **Retrospectives:** Retrospecitvas, feedback, melhorias
%{ endif }

%{ endfor }

## 📝 Arquivos de Configuração Principais

### automation-config.json
**Localização:** `/Automation/automation-config.json`  
**Finalidade:** Configuração completa do pipeline de automação

### project-configuration.json
**Localização:** `/Automation/project-configuration.json`  
**Finalidade:** Configuração geral do projeto e integrações

### agent-personalities.json
**Localização:** `/Team/agent-personalities.json`  
**Finalidade:** Personalidades completas dos agentes AI

### perplexity-memory-template.md
**Localização:** `/Automation/perplexity-memory-template.md`  
**Finalidade:** Template de memória persistente para Perplexity Pro

## 🔄 Workflows de Organização

### Criação Automática de Documentos

1. **Issue criada no Linear** → Webhook → Apps Script
2. **Apps Script** cria documento base na pasta correspondente
3. **Template aplicado** baseado no estágio (L1-L9)
4. **Link adicionado** à issue Linear automaticamente

### Organização por Estágio

- **L1-L3:** Documentos vão para `/L1-L3_Planning/[Estágio]/`
- **L4-L6:** Documentos vão para `/L4-L6_Development/[Estágio]/`
- **L7-L9:** Documentos vão para `/L7-L9_Deploy/[Estágio]/`

### Backup e Versionamento

- **Backup diário** às 02:00 UTC
- **Versionamento automático** para arquivos críticos
- **Retention policy** de ${current_env_config.retention_days} dias
- **Cleanup semanal** de arquivos temporários

## 🔗 Integrações

### Google Drive API
- **Permissões:** Read/Write em todas as pastas do projeto
- **Service Account:** Configurado via Terraform
- **Quotas:** Monitoradas automaticamente

### Apps Script
- **Functions:** Document creation, organization, backup
- **Triggers:** Time-based e event-based
- **Authentication:** OAuth2 com service account

### Webhook Integration
- **Linear Webhook:** ${webhook_url}
- **Events:** Issue creation, updates, completion
- **Security:** Signed requests, HTTPS only

## 📈 Métricas de Organização

### Storage Metrics
- **Uso atual:** Monitorado via Cloud Monitoring
- **Crescimento:** Estimado ~100MB por projeto
- **Cleanup:** Automático baseado em retention policy

### Access Patterns
- **Most accessed:** `/L1-L3_Planning/` (fase inicial)
- **Peak usage:** Durante desenvolvimento (L4-L6)
- **Long-term storage:** `/Assets/` e `/L9-Documentation/`

## 🔒 Segurança e Permissões

### Access Control
- **Product Owner:** Full access (Owner)
- **Service Account:** Automation access (Editor)
- **Team Members:** Shared access via links (Viewer/Commenter)

### Data Protection
- **Encryption:** At rest e in transit
- **Backup:** Multiple locations
- **Access logging:** Audit trail completo
- **Privacy:** Dados sensíveis em pastas restritas

## 🔧 Manutenção

### Limpeza Automática
- **Arquivos temporários:** Removidos semanalmente
- **Logs antigos:** Rotacionados mensalmente
- **Backups:** Retention de 90 dias
- **Cache:** Limpo automaticamente

### Health Checks
- **Storage quota:** Verificado diáriamente
- **API limits:** Monitorados em tempo real
- **Permissions:** Validados semanalmente
- **Integration status:** Health check a cada 5 minutos

---

## 📞 Suporte

**Em caso de problemas:**
1. Verifique logs em `/Automation/Logs/`
2. Consulte health status no monitoring dashboard
3. Execute script de diagnóstico: `scripts/diagnose.sh`
4. Contate: ${your_name} (${your_email})

**Recursos adicionais:**
- [Documentação Técnica](../docs/ARCHITECTURE.md)
- [Guia dos Agentes](../docs/AGENTS-GUIDE.md)
- [Troubleshooting](../docs/INSTALLATION.md)

---

*Estrutura criada e gerenciada pelo ADC-Agents-Team Pipeline v1.0.0*  
*Última atualização: ${creation_timestamp}*