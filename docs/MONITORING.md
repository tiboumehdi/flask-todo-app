# Guide de Surveillance et Journalisation pour Flask Todo App

Ce document décrit la configuration de surveillance et journalisation mise en place pour l'application Flask Todo, ainsi que les différentes options disponibles pour le monitoring en production.

## Vue d'ensemble

L'application intègre un système complet de surveillance et journalisation :

1. **Healthchecks** : Endpoints dédiés pour vérifier l'état de l'application
2. **Journalisation structurée** : Logs au format JSON pour une analyse facilitée
3. **Métriques Prometheus** : Instrumentation pour mesurer les performances
4. **Tableau de bord Grafana** : Visualisation des métriques et des logs
5. **Alertes** : Configuration d'alertes basées sur les métriques

## Healthchecks

L'application expose deux endpoints de healthcheck :

### `/health` - Healthcheck basique

Fournit un statut simple de l'application, idéal pour les vérifications par Docker ou Kubernetes.

```json
{
  "status": "ok",
  "timestamp": "2025-05-14T12:34:56.789Z",
  "version": "1.0.0",
  "environment": "production",
  "database": "ok"
}
```

### `/health/details` - Healthcheck détaillé

Fournit des informations détaillées sur tous les composants de l'application, avec des métriques supplémentaires.

```json
{
  "status": "ok",
  "timestamp": "2025-05-14T12:34:56.789Z",
  "version": "1.0.0",
  "environment": "production",
  "python_version": "3.11.4",
  "components": {
    "database": {
      "status": "ok",
      "type": "sqlite"
    },
    "filesystem": {
      "status": "ok",
      "writable": true
    },
    "disk": {
      "status": "ok",
      "free_percent": 78.5
    }
  },
  "metrics": {
    "tasks_total": 42,
    "tasks_completed": 15,
    "tasks_pending": 27,
    "db_errors": 0
  }
}
```

## Journalisation structurée

L'application utilise un format de journalisation JSON structuré, ce qui facilite l'analyse et l'intégration avec des outils comme Loki ou ELK.

### Format des logs

```json
{
  "timestamp": "2025-05-14T12:34:56.789Z",
  "level": "INFO",
  "logger": "flask-todo",
  "message": "Nouvelle tache creee: Acheter du lait",
  "module": "app",
  "function": "index",
  "line": 123,
  "host": "web-server-1",
  "application": "flask-todo"
}
```

### Configuration des logs

La configuration des logs peut être ajustée via des variables d'environnement :

- `LOG_LEVEL` : Niveau de log (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- `LOG_FILE` : Chemin vers le fichier de log (en plus de stdout)

## Métriques Prometheus

L'application expose des métriques Prometheus sur l'endpoint `/metrics`. Ces métriques incluent :

### Métriques HTTP

- `flask_http_requests_total` : Nombre total de requêtes HTTP (labels: method, endpoint, status)
- `flask_http_request_duration_seconds` : Durée des requêtes en secondes (labels: method, endpoint)

### Métriques métier

- `flask_todo_tasks_total` : Nombre total de tâches (labels: status - "total", "completed", "pending")
- `flask_todo_database_errors_total` : Nombre total d'erreurs de base de données

### Métriques d'application

- `flask_todo_app_info` : Informations sur l'application (version, environnement, etc.)

## Options de surveillance

Plusieurs options sont disponibles pour la surveillance en production :

### 1. Stack Local (Prometheus + Grafana + Loki)

Un docker-compose est fourni pour déployer rapidement une stack de surveillance complète :

```bash
docker-compose -f docker-compose-monitoring.yml up -d
```

Cette stack inclut :
- Prometheus : Collecte et stockage des métriques
- Grafana : Visualisation des métriques et des logs
- Loki : Agrégation et requêtage des logs
- Promtail : Collecte des logs

Le tableau de bord Grafana préconfigué est accessible sur http://localhost:3000 (admin/admin).

### 2. Grafana Cloud (Managed Service)

Pour une solution sans infrastructure à gérer, vous pouvez utiliser Grafana Cloud (tier gratuit disponible) :

1. Créez un compte sur Grafana Cloud
2. Configurez l'agent Grafana pour envoyer les métriques et les logs
3. Importez le tableau de bord fourni

Voir la documentation détaillée dans [GRAFANA_CLOUD_INTEGRATION.md](GRAFANA_CLOUD_INTEGRATION.md).

### 3. Autres solutions de monitoring

L'application peut également s'intégrer avec :

- **Datadog** : Via l'agent Datadog et les bibliothèques d'intégration
- **New Relic** : Via l'agent New Relic Python
- **ELK Stack** : Pour l'agrégation et l'analyse des logs
- **CloudWatch** : Pour le déploiement sur AWS

## Configuration Docker

Le Dockerfile a été optimisé pour la journalisation et le monitoring :

- Logs dirigés vers stdout/stderr pour être capturés par Docker
- Healthcheck configuré via HEALTHCHECK
- Variables d'environnement pour la configuration des métriques

## Alertes

Des alertes peuvent être configurées dans Grafana pour surveiller :

1. **Disponibilité de l'application** : Healthcheck échoué
2. **Latence élevée** : P95 des temps de réponse > seuil
3. **Taux d'erreur** : Pourcentage de requêtes en erreur > seuil
4. **Erreurs de base de données** : Toute erreur de base de données

## Bonnes pratiques

1. **Journalisation** :
   - Ne pas exposer d'informations sensibles dans les logs
   - Utiliser les niveaux de log appropriés
   - Mettre en place une rotation des logs

2. **Métriques** :
   - Surveiller à la fois les métriques techniques et métier
   - Conserver l'historique pour analyser les tendances
   - Configurer des alertes avec des seuils appropriés

3. **Healthchecks** :
   - Vérifier tous les composants critiques
   - Configurer des timeouts appropriés
   - Implémenter des vérifications profondes pour la détection précoce des problèmes