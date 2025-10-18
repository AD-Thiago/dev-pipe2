# Time Configuration - ADC-Agents-Team

## 📋 Configuração do Time Linear

**Nome do Time:** ${linear_team_key}-Team  
**Chave do Time:** ${linear_team_key}  
**Projeto:** ${project_name}  
**Organização:** ${linear_organization_id}

## 👥 Membros do Time

### Product Owner
- **Nome:** ${your_name}
- **Email:** ${your_email}
- **Função:** Product Owner / Tech Lead
- **Permissões:** Admin

### Agentes AI (Representados como Membros)

%{ for id, agent in agents }
#### ${agent.avatar} ${agent.name}
- **Email:** ${agent.email}
- **Função:** ${agent.role}
- **Departamento:** ${agent.department}
- **Especialidades:**
%{ for skill in agent.skills }
  - ${skill}
%{ endfor }
- **Bio:** ${agent.bio}
- **Estilo de Comunicação:** ${agent.communication_style}
- **Permissões:** Member
- **Assigned Stage:** ${id}

%{ endfor }

## 🏷️ Labels Padrão

### Labels por Estágio
%{ for id, agent in agents }
- **${id}**: ${agent.name} (${agent.role})
%{ endfor }

### Labels por Prioridade
- **P0**: Crítico / Bloqueador
- **P1**: Alta Prioridade
- **P2**: Média Prioridade
- **P3**: Baixa Prioridade

### Labels por Tipo
- **🐛 bug**: Correção de bug
- **✨ feature**: Nova funcionalidade
- **📝 docs**: Documentação
- **🚀 enhancement**: Melhoria
- **⚡ performance**: Otimização
- **🔒 security**: Segurança
- **🧪 experimental**: Experimental
- **🤖 ai-generated**: Gerado por IA

### Labels por Status
- **🔄 in-progress**: Em andamento
- **⏸️ blocked**: Bloqueado
- **✅ ready-review**: Pronto para review
- **🚀 deployed**: Deployado
- **❔ needs-info**: Precisa de informações

## 📅 Milestones

%{ for milestone_name, milestone in milestones }
### ${milestone_name}
- **Data Alvo:** ${milestone.target_date}
- **Descrição:** ${milestone.description}
- **Estágios Incluídos:** ${join(milestone.stages, ", ")}

%{ endfor }

## 🔄 Workflow States

### Estados Principais
1. **Backlog** - Issue criada, aguardando triagem
2. **Todo** - Pronta para ser iniciada
3. **In Progress** - Sendo trabalhada ativamente
4. **In Review** - Em revisão/validação
5. **Testing** - Em fase de testes
6. **Done** - Completada com sucesso
7. **Canceled** - Cancelada

### Transições Automáticas
- **Backlog → Todo:** Manual ou via webhook
- **Todo → In Progress:** Ao atribuir agente
- **In Progress → In Review:** Ao marcar deliverables completos
- **In Review → Testing:** Para estágios que requerem QA
- **Testing → Done:** Após aprovação de testes
- **Done → [Next Stage Todo]:** Via automação para estágios ${join(auto_approve_stages, ", ")}

## 🤖 Regras de Automação

### Estágios Automatizados
Os seguintes estágios avançam automaticamente:
%{ for stage_id in auto_approve_stages }
- **${stage_id}**: ${pipeline_agents[stage_id].name}
%{ endfor }

### Estágios Manuais
Os seguintes estágios requerem aprovação manual:
%{ for id, agent in agents }
%{ if !contains(auto_approve_stages, id) }
- **${id}**: ${agent.name}
%{ endif }
%{ endfor }

## 📊 Métricas e KPIs

### Velocity Tracking
- Story Points por Sprint
- Tempo médio por estágio
- Taxa de conclusão no prazo

### Quality Metrics
- Número de bugs por estágio
- Taxa de retrabalho
- Cobertura de testes

### Efficiency Metrics
- Tempo de ciclo por issue
- Tempo de espera entre estágios
- Taxa de automação bem-sucedida

## 🔗 Integrações

### Webhook Configuration
- **URL:** ${webhook_url}
- **Eventos:** Issue updates, label changes, state transitions
- **Autenticação:** Bearer token

### GitHub Integration
- **Repository:** ${github_repo}
- **Actions:** Automated deployments, testing
- **Sync:** Bidirectional issue sync

### Google Drive Integration
- **Folder:** https://drive.google.com/drive/folders/${drive_folder_id}
- **Sync:** Automatic document creation
- **Backup:** Daily automated backups

## 👥 Roles & Permissions

### Admin (Product Owner)
- Criar e editar projetos
- Gerenciar membros do time
- Configurar automações
- Aprovar estágios manuais

### Member (Agentes AI)
- Visualizar todas as issues
- Editar issues atribuidas
- Adicionar comentários
- Atualizar status

## 🔔 Notificações

### Email Notifications
- Issue assignments
- Status changes
- Milestone deadlines
- Automation failures

### Slack Integration (Opcional)
- Channel: #${project_name}-pipeline
- Daily standup summaries
- Critical alerts
- Deployment notifications

---

*Configuração gerada automaticamente pelo ADC-Agents-Team Pipeline v1.0.0*  
*Timezone: ${timezone}*  
*Criado em: ${creation_timestamp}*