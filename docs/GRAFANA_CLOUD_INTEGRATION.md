Configurer l'intégration avec Grafana Cloud
Cette documentation explique comment configurer l'application Flask Todo pour envoyer des métriques à Grafana Cloud.

Étape 1 : Créer un compte Grafana Cloud
Rendez-vous sur Grafana Cloud et inscrivez-vous pour un compte gratuit
Une fois connecté, accédez à votre instance Grafana Cloud
Dans le menu latéral, cliquez sur "Connections" puis "Connect data" (ou "Data sources")
Recherchez et sélectionnez "Prometheus"
Étape 2 : Obtenir les informations d'accès
Dans votre configuration Prometheus sur Grafana Cloud, vous trouverez :

URL de l'API Prometheus (par exemple https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push)
ID utilisateur Grafana Cloud
Clé API (vous devrez peut-être en générer une nouvelle)
Ces informations sont nécessaires pour configurer l'agent Prometheus qui enverra les métriques à Grafana Cloud.

Étape 3 : Installer et configurer Prometheus Agent
Option 1 : Utiliser le conteneur Grafana Agent à côté de votre application
Créez un fichier docker-compose.yml qui inclut à la fois votre application et l'agent Grafana :

yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: flask-todo-app:latest
    container_name: flask-todo
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    environment:
      - FLASK_ENV=production
      - PORT=8080
      - METRICS_PORT=9090
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 5s

  grafana-agent:
    image: grafana/agent:latest
    container_name: grafana-agent
    restart: unless-stopped
    volumes:
      - ./grafana-agent-config.yaml:/etc/agent/agent.yaml
    command: ["--config.file=/etc/agent/agent.yaml"]
    depends_on:
      - app
Créez le fichier de configuration grafana-agent-config.yaml :

yaml
server:
  log_level: info

metrics:
  global:
    scrape_interval: 15s
    external_labels:
      cluster: 'flask-todo'
      environment: 'production'
  
  configs:
    - name: hosted-prometheus
      remote_write:
        - url: https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push
          basic_auth:
            username: "YOUR_GRAFANA_USER_ID"
            password: "YOUR_GRAFANA_API_KEY"
      
      scrape_configs:
        - job_name: flask-todo
          static_configs:
            - targets: ['app:9090']
              labels:
                app: 'flask-todo'
                service: 'web'
Option 2 : Configurer l'application pour envoyer directement les métriques
Ajoutez la bibliothèque prometheus-pushgateway aux dépendances :

pip install prometheus-pushgateway
Modifiez votre code pour envoyer les métriques périodiquement :

python
from prometheus_client import push_to_gateway
import threading
import time

def push_metrics():
    """Envoi périodique des métriques à Grafana Cloud."""
    while True:
        try:
            push_to_gateway(
                'https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push',
                job='flask-todo',
                registry=registry,
                handler=basic_auth_handler
            )
            logger.info("Métriques envoyées à Grafana Cloud")
        except Exception as e:
            logger.error(f"Erreur lors de l'envoi des métriques: {str(e)}")
        time.sleep(15)  # Envoi toutes les 15 secondes

def basic_auth_handler(url, method, timeout, headers, data):
    """Gestionnaire d'authentification pour Grafana Cloud."""
    import base64
    import urllib.request
    
    username = os.environ.get('GRAFANA_USER_ID')
    password = os.environ.get('GRAFANA_API_KEY')
    
    auth = base64.b64encode(f"{username}:{password}".encode()).decode()
    headers['Authorization'] = f'Basic {auth}'
    
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    return urllib.request.urlopen(request, timeout=timeout)

# Démarrer le thread d'envoi des métriques
if os.environ.get('GRAFANA_USER_ID') and os.environ.get('GRAFANA_API_KEY'):
    metrics_thread = threading.Thread(target=push_metrics, daemon=True)
    metrics_thread.start()
    logger.info("Thread d'envoi des métriques à Grafana Cloud démarré")
Étape 4 : Créer un tableau de bord dans Grafana Cloud
Dans votre instance Grafana, cliquez sur "+ Create" puis "Dashboard"
Ajoutez un nouveau panneau
Configurez les requêtes avec les métriques de votre application :
flask_http_requests_total - Nombre total de requêtes HTTP
flask_http_request_duration_seconds - Latence des requêtes HTTP
flask_todo_tasks_total - Nombre de tâches (par statut)
flask_todo_database_errors_total - Nombre d'erreurs de base de données
Exemple de requête PromQL pour le taux de requêtes :

rate(flask_http_requests_total[5m])
Étape 5 : Configurer des alertes
Dans votre tableau de bord, sélectionnez un panneau
Cliquez sur "Edit"
Allez dans l'onglet "Alert"
Configurez une alerte, par exemple :
Condition: Taux d'erreur HTTP supérieur à un certain seuil
Règle: sum(rate(flask_http_requests_total{status=~"5.."}[5m])) / sum(rate(flask_http_requests_total[5m])) > 0.01
Cette alerte se déclenche si plus de 1% des requêtes génèrent des erreurs 5xx
Ressources supplémentaires
Documentation Grafana Cloud
Documentation Prometheus
Requêtes PromQL
