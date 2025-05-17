# Guide du Pipeline CI/CD

Ce document fournit des informations détaillées sur le pipeline CI/CD complet pour l'application Flask Todo.

## Vue d'ensemble

Notre pipeline CI/CD GitHub Actions est conçu pour couvrir l'ensemble du cycle de vie du développement logiciel, depuis la vérification du code jusqu'au déploiement en production, en passant par des analyses de sécurité approfondies.

```
Build → Security Analysis → Container Scan → Package → Deploy → Notification
```

## Structure et Jobs

### 1. Job `build`

Ce job effectue la validation de base du code source et les tests unitaires.

**Étapes clés :**
- Checkout du code source
- Installation des dépendances Python
- Lint avec Flake8 (vérification de conformité au PEP 8)
- Vérification du formatage avec Black
- Vérification de l'ordre des imports avec isort
- Exécution des tests unitaires avec pytest
- Génération du rapport de couverture

**Artefacts produits :**
- Rapport de couverture des tests (coverage.xml)

### 2. Job `security`

Ce job effectue des analyses de sécurité statique (SAST) sur le code source.

**Outils utilisés :**
- CodeQL (analyse approfondie de GitHub)
- SonarCloud (qualité et sécurité du code)
- Bandit (scanner de sécurité spécifique à Python)
- Semgrep (analyse basée sur les règles OWASP Top 10)

**Points analysés :**
- Vulnérabilités de code
- Failles de sécurité potentielles
- Mauvaises pratiques de codage
- Problèmes de qualité de code

### 3. Job `container-scan`

Ce job analyse l'image Docker générée pour détecter les vulnérabilités.

**Outils utilisés :**
- Trivy (scanner de vulnérabilités)
- Dockle (vérification des bonnes pratiques Docker)
- Snyk (analyse des dépendances dans le conteneur)

**Éléments analysés :**
- Vulnérabilités des packages OS
- Mauvaises configurations Docker
- Permissions et sécurité du conteneur

### 4. Job `package`

Ce job construit et publie l'image Docker dans le registry.

**Fonctionnalités :**
- Build multi-architecture (amd64/arm64)
- Tags automatiques basés sur la référence Git
- Publication sur GitHub Container Registry
- Labels explicites pour la traçabilité

**Types de tags générés :**
- Tag de branche (main, develop)
- Tag de version sémantique (pour les releases)
- Tag de commit (SHA court)
- Tag "latest" pour la branche par défaut

### 5. Job `deploy`

Ce job déploie l'application sur les environnements cibles via Ansible.

**Méthodes de déploiement :**
- SSH depuis le runner GitHub Actions
- Runner auto-hébergé (option alternative)

**Caractéristiques :**
- Playbooks Ansible réutilisables
- Déploiement conditionnel selon la branche
- Vérifications post-déploiement
- Gestion des environnements GitHub Actions

### 6. Job `notify`

Ce job envoie des notifications sur l'état du pipeline.

**Canaux de notification :**
- Slack (via webhook)
- Autres intégrations possibles (email, Teams, etc.)

## Déclencheurs du Pipeline

Le pipeline s'exécute automatiquement dans les cas suivants :

1. **Push sur les branches principales** :
   - `main` → Déploiement en production
   - `develop` → Déploiement en staging

2. **Pull Requests** :
   - Vers `main` ou `develop`
   - Exécute tous les jobs sauf `package` et `deploy`

3. **Planification** :
   - Tous les dimanches à minuit
   - Analyse de sécurité complète

4. **Manuel** :
   - Via le bouton "Run workflow" dans l'interface GitHub
   - Options pour sélectionner les jobs à exécuter

## Configuration et Secrets

### Secrets GitHub nécessaires

Ces secrets doivent être configurés dans les paramètres de votre dépôt :

| Secret | Description | Utilisé par |
|--------|-------------|-------------|
| `SONAR_TOKEN` | Token d'accès pour SonarCloud | Job `security` |
| `SNYK_TOKEN` | Token d'accès pour Snyk | Jobs `security` et `container-scan` |
| `DEPLOY_SSH_KEY` | Clé SSH privée pour le déploiement | Job `deploy` (méthode SSH) |
| `ANSIBLE_REPO_TOKEN` | Token GitHub pour accéder au dépôt des playbooks | Job `deploy` |
| `SLACK_WEBHOOK_URL` | URL du webhook Slack pour les notifications | Job `notify` |

### Variables d'environnement

Le pipeline utilise ces variables définies en haut du workflow :

```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  ANSIBLE_PLAYBOOK_REPO: votre-nom-utilisateur/ansible-playbooks
  ANSIBLE_PLAYBOOK_NAME: flask-todo-deploy.yml
```

## Personnalisation

### Modification des environnements de déploiement

Pour ajouter un nouvel environnement (par exemple, "testing") :

1. Créez un nouvel inventaire Ansible dans `ansible/inventories/testing.yml`
2. Ajoutez une condition dans le job `deploy` pour déterminer quand utiliser cet environnement
3. Créez l'environnement dans GitHub (Settings → Environments)

### Ajout d'outils de sécurité supplémentaires

Pour intégrer un nouvel outil de sécurité :

1. Ajoutez une nouvelle étape dans le job `security` ou `container-scan`
2. Configurez la génération de rapport au format SARIF si possible
3. Utilisez `github/codeql-action/upload-sarif@v2` pour publier les résultats

### Modification de la stratégie de déploiement

Pour changer la méthode de déploiement :

1. Commentez/décommentez les sections correspondantes dans le job `deploy`
2. Pour utiliser exclusivement des runners auto-hébergés, modifiez la directive `runs-on`

## Dépannage

### Erreurs courantes et solutions

| Erreur | Cause probable | Solution |
|--------|----------------|----------|
| Échec des tests | Regression dans le code | Exécutez les tests localement et corrigez les problèmes |
| Échec du linting | Non-respect des conventions | Utilisez `black` et `isort` localement |
| Échec de sécurité | Vulnérabilités détectées | Consultez les rapports détaillés dans l'onglet Security |
| Échec de build Docker | Problème dans le Dockerfile | Testez le build localement |
| Échec de déploiement | Problème de connexion ou de droits | Vérifiez les logs et les permissions SSH |

### Exécution locale du pipeline

Pour tester certaines parties du pipeline localement avant de committer :

```bash
# Lint et tests
flake8 . && black --check . && isort --check-only . && pytest

# Sécurité
bandit -r .
safety check -r requirements.txt

# Docker
docker build -t flask-todo-app:local .
trivy image flask-todo-app:local
```

## Bonnes pratiques

1. **Intégration continue** : Commitez et poussez fréquemment vers des branches de fonctionnalités
2. **Revue de code** : Utilisez les PR et les revues de code obligatoires avant fusion
3. **Sécurité continue** : Traitez les alertes de sécurité dès qu'elles apparaissent
4. **Tests automatisés** : Maintenez une couverture de tests élevée
5. **Documentation** : Documentez les changements dans le workflow CI/CD