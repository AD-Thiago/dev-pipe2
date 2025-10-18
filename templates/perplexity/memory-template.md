# Memória Persistente - ${project_name} Pipeline

**Versão:** 1.0.0  
**Criado em:** ${creation_date}  
**Drive Folder:** https://drive.google.com/drive/folders/${drive_folder_id}

## Estágio Atual
- ${stages[0].id}: ${stages[0].title}

## Agentes
%{ for id, agent in agents }
- **${id}:** ${agent.name} (${agent.role})  
  Personalidade: ${agent.personality}  
  Skills: ${join(agent.skills, ", ")}
%{ endfor }

## Próximos Passos
1. Aprovar issue ${stages[0].id} no Linear  
2. Aguardar trigger automático para ${stages[1].id}  

## Histórico de Decisões
- [${creation_date}] Pipeline inicializado

