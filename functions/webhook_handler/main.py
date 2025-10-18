"""
ADC-Agents-Team - Webhook Handler
Cloud Function para processar webhooks do Linear
Versão Final - Outubro 2025
"""

import os
import json
import logging
import traceback
from datetime import datetime
from typing import Dict, Any, Optional, List
import requests
from flask import Request, jsonify
import functions_framework

# Configuração de logging
logging.basicConfig(
    level=os.environ.get('LOG_LEVEL', 'INFO'),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Variáveis de ambiente
PROJECT_NAME = os.environ.get('PROJECT_NAME', 'unknown')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'production')
LINEAR_API_KEY = os.environ.get('LINEAR_API_KEY')
GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')
GITHUB_OWNER = os.environ.get('GITHUB_OWNER')
DRIVE_FOLDER_ID = os.environ.get('DRIVE_FOLDER_ID')
AUTO_APPROVE_STAGES = os.environ.get('AUTO_APPROVE_STAGES', 'L3,L5,L7,L8').split(',')
NOTIFICATION_EMAIL = os.environ.get('NOTIFICATION_EMAIL', '')
SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL', '')

# Constantes
LINEAR_API_URL = "https://api.linear.app/graphql"
GITHUB_API_URL = "https://api.github.com"

# Mapeamento de estágios
STAGE_SEQUENCE = ['L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7', 'L8', 'L9']

AGENT_INFO = {
    'L1': {'name': 'Alex Requirements', 'emoji': '🎯'},
    'L2': {'name': 'Sam Architecture', 'emoji': '🏢️'},
    'L3': {'name': 'Luna Design', 'emoji': '🎨'},
    'L4': {'name': 'Morgan Backend', 'emoji': '⚙️'},
    'L5': {'name': 'River Frontend', 'emoji': '💻'},
    'L6': {'name': 'Quinn Testing', 'emoji': '🔍'},
    'L7': {'name': 'Phoenix Deploy', 'emoji': '🚀'},
    'L8': {'name': 'Sage Monitor', 'emoji': '📊'},
    'L9': {'name': 'Echo Documentation', 'emoji': '📚'}
}


@functions_framework.http
def linear_webhook_handler(request: Request):
    """
    Handler principal para webhooks Linear
    """
    # CORS headers
    if request.method == 'OPTIONS':
        return handle_cors()
    
    # Health check
    if request.path == '/health' or request.args.get('health'):
        return jsonify({
            'status': 'healthy',
            'project': PROJECT_NAME,
            'environment': ENVIRONMENT,
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    
    try:
        # Validar método
        if request.method != 'POST':
            return jsonify({'error': 'Only POST requests allowed'}), 405
        
        # Parse request data
        try:
            data = request.get_json(force=True)
        except Exception as e:
            logger.error(f"Failed to parse JSON: {str(e)}")
            return jsonify({'error': 'Invalid JSON'}), 400
        
        if not data:
            return jsonify({'error': 'Empty request body'}), 400
        
        # Log incoming webhook
        logger.info(f"📨 Webhook received for {PROJECT_NAME}")
        logger.debug(f"Webhook data: {json.dumps(data, indent=2)}")
        
        # Roteamento baseado no tipo de evento
        event_type = data.get('type', 'unknown')
        action = data.get('action', 'unknown')
        
        logger.info(f"📋 Event: {event_type}, Action: {action}")
        
        # Processar diferentes tipos de eventos
        if event_type == 'InitializePipeline':
            return handle_initialization(data)
        elif event_type == 'Issue' and action == 'update':
            return handle_issue_update(data)
        elif event_type == 'Issue' and action == 'create':
            return handle_issue_create(data)
        elif event_type == 'Comment' and action == 'create':
            return handle_comment_create(data)
        elif event_type == 'IssueLabel':
            return handle_issue_label(data)
        else:
            logger.info(f"ℹ️ Unhandled event type: {event_type}/{action}")
            return jsonify({'status': 'ignored', 'reason': 'event_type_not_handled'}), 200
        
    except Exception as e:
        logger.error(f"❌ Error processing webhook: {str(e)}")
        logger.error(traceback.format_exc())
        
        # Notificar erro se configurado
        send_error_notification(e, data if 'data' in locals() else {})
        
        return jsonify({
            'error': str(e),
            'traceback': traceback.format_exc() if ENVIRONMENT != 'production' else None
        }), 500


def handle_cors():
    """Handle CORS preflight requests"""
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Max-Age': '3600'
    }
    return ('', 204, headers)


def handle_initialization(data: Dict[str, Any]):
    """
    Processa inicialização do pipeline
    """
    logger.info("🎯 Processing pipeline initialization")
    
    init_data = data.get('data', {})
    resources = init_data.get('resources', {})
    
    logger.info(f"✅ Pipeline initialized for: {init_data.get('project_name')}")
    logger.info(f"📁 Drive Folder: {resources.get('drive_folder_id')}")
    logger.info(f"🔧 GitHub Repo: {resources.get('github_repo')}")
    
    # Enviar notificação de inicialização
    message = f"""
🎉 **Pipeline {init_data.get('project_name')} Inicializado!**

📋 **Recursos Criados:**
• Google Drive: {resources.get('drive_url')}
• GitHub: {resources.get('github_url')}

👥 **Time:**
• Product Owner: {init_data.get('team', {}).get('product_owner')}
• Agentes AI: {init_data.get('team', {}).get('agents_count')}

🚀 **Próximos Passos:**
1. Configure Perplexity Pro Space
2. Inicie com 'L1 - INICIAR PIPELINE PRO'
3. Acompanhe progresso no Linear

Sistema 100% operacional e pronto para uso!
    """.strip()
    
    send_notification(
        title="Pipeline Inicializado",
        message=message,
        level="success"
    )
    
    return jsonify({
        'status': 'initialized',
        'project': init_data.get('project_name'),
        'resources': resources,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


def handle_issue_update(data: Dict[str, Any]):
    """
    Processa atualização de issue Linear
    """
    issue_data = data.get('data', {})
    issue_title = issue_data.get('title', '')
    issue_state = issue_data.get('state', {}).get('name', '')
    issue_id = issue_data.get('id', '')
    
    logger.info(f"📝 Issue updated: {issue_title}")
    logger.info(f"   State: {issue_state}")
    
    # Extrair estágio do título
    stage = extract_stage_from_title(issue_title)
    
    if not stage:
        logger.info("ℹ️ Issue não pertence ao pipeline")
        return jsonify({'status': 'ignored', 'reason': 'not_pipeline_issue'}), 200
    
    # Verificar se é aprovação de estágio
    if issue_state in ['Done', 'Completed', 'Approved']:
        logger.info(f"✅ Stage {stage} aprovado!")
        
        # Determinar próximo estágio
        next_stage = get_next_stage(stage)
        
        if not next_stage:
            logger.info("🎉 Pipeline completo!")
            send_notification(
                title=f"Pipeline {PROJECT_NAME} Completo!",
                message=f"Todos os 9 estágios foram concluídos com sucesso. 🎊",
                level="success"
            )
            return jsonify({
                'status': 'pipeline_completed',
                'completed_stage': stage
            }), 200
        
        # Verificar se pode auto-proceder
        can_auto = can_auto_proceed(next_stage)
        
        if can_auto:
            logger.info(f"🚀 Auto-proceeding to {next_stage}")
            
            # Trigger automação para próximo estágio
            trigger_result = trigger_next_stage_automation(
                PROJECT_NAME,
                next_stage,
                previous_stage=stage
            )
            
            # Notificar avanço automático
            agent_info = AGENT_INFO.get(next_stage, {})
            send_notification(
                title=f"Estágio {next_stage} Iniciado Automaticamente",
                message=f"{agent_info.get('emoji')} {agent_info.get('name')} está agora trabalhando no estágio {next_stage}.",
                level="info"
            )
            
            return jsonify({
                'status': 'auto_proceeded',
                'completed_stage': stage,
                'next_stage': next_stage,
                'automation_triggered': trigger_result
            }), 200
        else:
            logger.info(f"⏸️ {next_stage} requires manual approval")
            
            # Notificar que aprovação manual é necessária
            agent_info = AGENT_INFO.get(next_stage, {})
            send_notification(
                title=f"Aprovação Necessária - {next_stage}",
                message=f"{agent_info.get('emoji')} {agent_info.get('name')} aguarda sua aprovação no Linear para iniciar {next_stage}.",
                level="warning"
            )
            
            return jsonify({
                'status': 'awaiting_approval',
                'completed_stage': stage,
                'next_stage': next_stage,
                'requires_manual_approval': True
            }), 200
    
    return jsonify({'status': 'processed', 'stage': stage}), 200


def handle_issue_create(data: Dict[str, Any]):
    """
    Processa criação de nova issue
    """
    issue_data = data.get('data', {})
    issue_title = issue_data.get('title', '')
    
    logger.info(f"📌 New issue created: {issue_title}")
    
    return jsonify({'status': 'acknowledged'}), 200


def handle_comment_create(data: Dict[str, Any]):
    """
    Processa criação de comentário em issue
    """
    comment_data = data.get('data', {})
    comment_body = comment_data.get('body', '')
    
    logger.info(f"💬 New comment: {comment_body[:100]}...")
    
    # Aqui pode adicionar lógica para processar comandos via comentários
    # Exemplo: @bot deploy, @bot rollback, etc.
    
    return jsonify({'status': 'acknowledged'}), 200


def handle_issue_label(data: Dict[str, Any]):
    """
    Processa mudanças de labels em issues
    """
    logger.info("🏷️ Issue label changed")
    
    return jsonify({'status': 'acknowledged'}), 200


def extract_stage_from_title(title: str) -> Optional[str]:
    """
    Extrai estágio (L1, L2, etc.) do título da issue
    """
    import re
    match = re.search(r'(L\d+):', title)
    return match.group(1) if match else None


def get_next_stage(current_stage: str) -> Optional[str]:
    """
    Retorna o próximo estágio na sequência
    """
    try:
        current_index = STAGE_SEQUENCE.index(current_stage)
        if current_index < len(STAGE_SEQUENCE) - 1:
            return STAGE_SEQUENCE[current_index + 1]
    except ValueError:
        logger.error(f"Stage {current_stage} not found in sequence")
    
    return None


def can_auto_proceed(stage: str) -> bool:
    """
    Verifica se estágio pode ser automatizado
    """
    return stage in AUTO_APPROVE_STAGES


def trigger_next_stage_automation(
    project_name: str, 
    stage: str, 
    previous_stage: Optional[str] = None
) -> bool:
    """
    Trigger automação do próximo estágio via GitHub Actions
    """
    if not GITHUB_TOKEN or not GITHUB_OWNER:
        logger.warning("GitHub credentials not configured")
        return False
    
    try:
        repo_name = f"llm-app-{project_name.lower().replace('_', '-')}"
        
        # Endpoint do GitHub Actions workflow dispatch
        url = f"{GITHUB_API_URL}/repos/{GITHUB_OWNER}/{repo_name}/actions/workflows/llm-pipeline-auto.yml/dispatches"
        
        headers = {
            "Authorization": f"Bearer {GITHUB_TOKEN}",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json"
        }
        
        payload = {
            "ref": "main",
            "inputs": {
                "stage": stage,
                "project_name": project_name,
                "previous_stage": previous_stage or "",
                "auto_triggered": "true",
                "triggered_by": "linear_webhook",
                "timestamp": datetime.utcnow().isoformat()
            }
        }
        
        logger.info(f"Triggering GitHub Actions for {stage}")
        logger.debug(f"URL: {url}")
        logger.debug(f"Payload: {json.dumps(payload, indent=2)}")
        
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        
        if response.status_code == 204:
            logger.info(f"GitHub Actions triggered successfully for {stage}")
            return True
        else:
            logger.error(f"Failed to trigger GitHub Actions: {response.status_code}")
            logger.error(f"Response: {response.text}")
            return False
        
    except Exception as e:
        logger.error(f"Error triggering automation: {str(e)}")
        logger.error(traceback.format_exc())
        return False


def send_notification(
    title: str, 
    message: str, 
    level: str = "info"
) -> bool:
    """
    Envia notificações por email ou Slack
    """
    try:
        # Implementar lógica de notificação
        logger.info(f"Notification [{level.upper()}]: {title}")
        logger.info(f"Message: {message}")
        
        # Aqui você pode integrar com Slack, email, etc.
        if SLACK_WEBHOOK_URL:
            # Enviar para Slack
            pass
        
        if NOTIFICATION_EMAIL:
            # Enviar por email
            pass
        
        return True
        
    except Exception as e:
        logger.error(f"Failed to send notification: {str(e)}")
        return False


def send_error_notification(error: Exception, data: Dict[str, Any]) -> bool:
    """
    Envia notificação de erro
    """
    error_message = f"""
    ❌ **Erro no Pipeline {PROJECT_NAME}**
    
    **Erro:** {str(error)}
    **Timestamp:** {datetime.utcnow().isoformat()}
    **Environment:** {ENVIRONMENT}
    
    **Dados do evento:**
    ```json
    {json.dumps(data, indent=2)[:500]}...
    ```
    """
    
    return send_notification(
        title=f"Erro no Pipeline {PROJECT_NAME}",
        message=error_message,
        level="error"
    )