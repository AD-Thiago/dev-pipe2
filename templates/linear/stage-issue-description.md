# ${stage.id}: ${stage.title}

## 🎯 Agente Responsável

**${agent.avatar} ${agent.name}** - ${agent.role}  
*${agent.department}*

### 🧠 Personalidade
${agent.personality}

### 💪 Skills Principais
%{ for skill in agent.skills }
- ${skill}
%{ endfor }

### 🛠️ Metodologias
%{ for method in agent.methodology }
- ${method}
%{ endfor }

### 💻 Ferramentas
%{ for tool in agent.tools }
- ${tool}
%{ endfor }

---

## 📋 Descrição do Estágio

${stage.description}

## 🎯 Objetivo Principal

%{ if stage.id == "L1" }
Capturar e estruturar a ideia inicial da aplicação LLM, definir MVP e criar backlog detalhado.
%{ endif }
%{ if stage.id == "L2" }
Projetar arquitetura técnica completa, definir stack tecnológico e planejar todas as integrações necessárias.
%{ endif }
%{ if stage.id == "L3" }
Criar wireframes, protótipos interativos e estabelecer design system consistente.
%{ endif }
%{ if stage.id == "L4" }
Implementar toda a lógica de negócio e integrações LLM usando plataformas no-code.
%{ endif }
%{ if stage.id == "L5" }
Construir interface completa usando vibe coding e ferramentas de IA para aceleração.
%{ endif }
%{ if stage.id == "L6" }
Implementar suite completa de testes automatizados e validar qualidade em todos os aspectos.
%{ endif }
%{ if stage.id == "L7" }
Configurar pipeline de deploy automatizado e publicar aplicação em ambiente de produção.
%{ endif }
%{ if stage.id == "L8" }
Implementar monitoramento abrangente, dashboards e sistema de alertas proativo.
%{ endif }
%{ if stage.id == "L9" }
Gerar documentação completa técnica e de usuário usando ferramentas de IA.
%{ endif }

## 📦 Deliverables

%{ for deliverable in stage.deliverables }
- [ ] ${deliverable}
%{ endfor }

## ✅ Critérios de Aceitação

%{ for criteria in stage.acceptance_criteria }
- [ ] ${criteria}
%{ endfor }

## 🔗 Dependências

%{ if length(stage.dependencies) > 0 }
%{ for dep in stage.dependencies }
- Estágio ${dep} deve estar completado
%{ endfor }
%{ else }
- Nenhuma dependência
%{ endif }

## 📈 Estimativa

**Story Points:** ${stage.estimate}  
**Prioridade:** ${stage.priority}  
**Marco:** ${stage.milestone}

## 🤖 Automação

%{ if stage.auto_proceed }
✅ **Este estágio é automatizado** - Avançará automaticamente após conclusão
%{ else }
📝 **Aprovação manual necessária** - Aguarda aprovação no Linear antes de prosseguir
%{ endif }

## 📂 Recursos de Apoio

%{ if length(stage.resources) > 0 }
%{ for resource in stage.resources }
- [Recurso](${resource})
%{ endfor }
%{ else }
- Recursos internos da equipe
%{ endif }

## 💬 Estilo de Comunicação

**${agent.name}** ${agent.communication_style}

> *"${agent.favorite_quote}"*

---

### 📝 Nota para o Agente

Siga sua personalidade e metodologias ao executar este estágio. Use suas ferramentas preferenciais e mantenha consistência com seu estilo de comunicação. Lembre-se: você é um especialista nesta área!

*Estágio criado automaticamente pelo ADC-Agents-Team Pipeline v1.0.0*