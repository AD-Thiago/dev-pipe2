# ${project_name} - ADC-Agents-Team Pipeline

## 📋 Descrição do Projeto

${project_description}

## 🎯 Objetivos

- Desenvolver aplicação LLM completa usando pipeline automatizado
- Utilizar time especializado de 9 agentes AI (L1-L9)
- Implementar DevOps e CI/CD desde o início
- Entregar MVP funcional em ${project_duration_days} dias

## 👥 Time

**Product Owner:** ${your_name} (${your_email})

### Agentes AI Especializados:

%{ for id, agent in agents }
- **${id}:** ${agent.avatar} ${agent.name}
  - Função: ${agent.role}
  - Departamento: ${agent.department}
  - Skills: ${join(agent.skills, ", ")}
%{ endfor }

## 🚀 Pipeline (${length(stages)} Estágios)

### 📋 Planejamento (L1-L3)
1. **L1**: Definição de Requisitos e Escopo
2. **L2**: Arquitetura e Design Técnico  
3. **L3**: Design de Interface e UX

### 💻 Desenvolvimento (L4-L6)
4. **L4**: Implementação Backend (No-Code)
5. **L5**: Implementação Frontend (Vibe Coding)
6. **L6**: Testes e Validação

### 🚀 Deploy & Docs (L7-L9)
7. **L7**: Deploy e CI/CD
8. **L8**: Monitoramento e Observabilidade
9. **L9**: Documentação e Handoff

## 🔄 Automação

- **Estágios Auto-Aprovados:** ${join(auto_approve_stages, ", ")}
- **Requer Aprovação Manual:** ${join([for s in stages : s.id if !contains(auto_approve_stages, s.id)], ", ")}

## 📂 Recursos

- **Google Drive:** https://drive.google.com/drive/folders/${drive_folder_id}
- **GitHub Repository:** ${github_repo}
- **Webhook URL:** ${webhook_url}
- **Automation Core:** ${automation_url}

## ⏱️ Timeline

- **Início:** ${creation_date}
- **Conclusão Estimada:** ${target_completion}
- **Duração:** ${project_duration_days} dias

## 🎯 Critérios de Sucesso

- [ ] Todos os 9 estágios completados
- [ ] Aplicação LLM funcional deployada
- [ ] Documentação completa
- [ ] Pipeline CI/CD operacional
- [ ] Monitoramento ativo

## 🔗 Links Importantes

- [Instruções Perplexity](${perplexity_instructions_url})
- [Memory Template](${memory_template_url})
- [Agent Personalities](${agent_personalities_url})
- [Automation Config](${automation_config_url})

---

*Este projeto é gerenciado pelo ADC-Agents-Team Pipeline v1.0.0*