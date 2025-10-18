"""
ADC-Agents-Team - Automation Core
Cloud Function para lógica central de orquestração do pipeline
Versão Final - Outubro 2025
"""

import os
import json
import logging
import traceback
from datetime import datetime
import requests
from flask import Request, jsonify
import functions_framework

# Logging
logging.basicConfig(level=os.environ.get('LOG_LEVEL', 'INFO'))
logger = logging.getLogger(__name__)

# Environment
PROJECT_NAME = os.environ.get('PROJECT_NAME')
LINEAR_API_KEY = os.environ.get('LINEAR_API_KEY')
GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')
GITHUB_OWNER = os.environ.get('GITHUB_OWNER')
WEBHOOK_URL = os.environ.get('WEBHOOK_URL')
DRIVE_FOLDER_ID = os.environ.get('DRIVE_FOLDER_ID')

LINEAR_API_URL = "https://api.linear.app/graphql"
GITHUB_API_URL = "https://api.github.com"


@functions_framework.http
def automation_handler(request: Request):
    """
    Lógica principal de automação de pipeline
    """
    if request.method == 'OPTIONS':
        return cors_preflight()
    
    try:
        data = request.get_json(force=True)
        action = data.get('action')
        payload = data.get('payload', {})
        
        logger.info(f"Automation Core Action: {action}")
        
        if action == 'trigger_stage':
            return trigger_stage(payload)
        elif action == 'sync_status':
            return sync_status(payload)
        else:
            return jsonify({'error': 'unknown action'}, 400)
    
    except Exception as e:
        logger.error(f"Automation Core Error: {e}")
        logger.error(traceback.format_exc())
        return jsonify({'error': str(e)}, 500)


def trigger_stage(payload):
    """
    Dispara workflow GitHub para estágio específico
    """
    stage = payload.get('stage')
    project_name = payload.get('project_name', PROJECT_NAME)
    
    if not stage:
        return jsonify({'error': 'stage required'}, 400)
    
    repo = f"{GITHUB_OWNER}/llm-app-{project_name.lower().replace('_', '-')}"
    workflow = "llm-pipeline-auto.yml"
    
    url = f"{GITHUB_API_URL}/repos/{repo}/actions/workflows/{workflow}/dispatches"
    headers = {
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    body = {
        "ref": "main",
        "inputs": {"stage": stage, "project_name": project_name}
    }
    
    resp = requests.post(url, json=body, headers=headers, timeout=10)
    
    if resp.status_code == 204:
        return jsonify({'status': 'triggered', 'stage': stage}, 200)
    else:
        return jsonify({'error': 'dispatch_failed', 'details': resp.text}, 500)


def sync_status(payload):
    """
    Sincroniza status de issues entre Linear e GitHub
    """
    # Placeholder para lógica de sincronização
    return jsonify({'status': 'sync_complete'}, 200)


def cors_preflight():
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type'
    }
    return ('', 204, headers)