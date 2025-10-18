# ADC-Agents-Team | ${project_name}

## Time de Desenvolvimento AI

**Product Owner:** ${product_owner}  

### Agentes AI

%{ for id, agent in agents }
## ${agent.avatar} ${agent.name} (Estágio ${id})
- Papel: ${agent.role}
- Personalidade: ${agent.personality}
- Skills: ${join(agent.skills,", ")}
- Bio: ${agent.bio}

%{ endfor }

---

*Este arquivo é gerado automaticamente pelo Terraform.*