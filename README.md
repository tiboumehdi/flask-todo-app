## 🚀 CI/CD et Déploiement

Ce projet utilise un pipeline CI/CD GitHub Actions complet pour automatiser le processus de développement, test, analyse de sécurité et déploiement.

### Pipeline GitHub Actions

Notre pipeline comprend les étapes suivantes :

#### 1. Build et Test (Job `build`)
- **Lint du code** : Analyse avec Flake8, Black et isort
- **Tests unitaires** : Exécutés avec pytest et génération de rapport de couverture
- **Vérification de qualité** : Application des standards de codage

#### 2. Analyse de Sécurité (Jobs `security`, `container-scan`)
- **SAST (Static Application Security Testing)** : CodeQL, SonarCloud, Bandit, Semgrep
- **SCA (Software Composition Analysis)** : OWASP Dependency-Check, Safety, pip-audit
- **Scan d'image Docker** : Trivy, Dockle, Snyk
- **Détection des secrets** : TruffleHog, GitLeaks

#### 3. Package (Job `package`)
- **Build d'image Docker** : Construction multi-architecture (amd64/arm64)
- **Push vers Registry** : Publication sur GitHub Container Registry
- **Génération de métadonnées** : Tags et labels pour les images

#### 4. Déploiement (Job `deploy`)
- **Ansible** : Exécution de playbooks pour le déploiement automatisé
- **Environnements** : Configuration spécifique selon l'environnement (production/staging)
- **Vérification de santé** : Tests post-déploiement pour confirmer le bon fonctionnement

### Options de Déploiement

Le pipeline prend en charge deux méthodes de déploiement :

1. **SSH depuis GitHub Actions** : Connexion directe aux serveurs via SSH
2. **Runner auto-hébergé** : Exécution des jobs de déploiement sur un runner dans votre infrastructure

### Configuration et Utilisation

- **Documentation détaillée** : Consultez le [guide du pipeline CI/CD](docs/PIPELINE.md)
- **Configuration Ansible** : Playbooks disponibles dans le dossier `ansible/`
- **Runner auto-hébergé** : Instructions d'installation dans [SELF_HOSTED_RUNNER.md](docs/SELF_HOSTED_RUNNER.md)## 🔒 Sécurité

Ce projet intègre plusieurs niveaux d'analyse de sécurité pour détecter et prévenir les vulnérabilités :

### Pipeline de Sécurité Complet 

Notre pipeline CI/CD GitHub Actions comprend les analyses suivantes :

#### 1. Analyse Statique du Code (SAST)
- **CodeQL** : Analyse approfondie pour détecter les vulnérabilités et erreurs de code
- **SonarCloud** : Plateforme d'analyse continue de la qualité et sécurité
- **Bandit** : Outil spécifique à Python pour les problèmes de sécurité
- **Semgrep** : Détection de vulnérabilités basée sur des motifs (OWASP Top 10)

#### 2. Analyse des Dépendances (SCA)
- **OWASP Dependency-Check** : Vérifie les CVEs dans les dépendances
- **Safety** : Scanner de vulnérabilités pour packages Python
- **pip-audit** : Scanner basé sur la base de données PyPI
- **Snyk** : Analyse avancée des dépendances et conteneurs

#### 3. Sécurité des Conteneurs
- **Trivy** : Scanner de vulnérabilités pour images Docker
- **Dockle** : Vérification des bonnes pratiques Docker
- **Grype** : Scanner de vulnérabilités Anchore

#### 4. Détection de Secrets
- **TruffleHog** : Détection de secrets et informations sensibles
- **GitLeaks** : Scanner pour secrets dans l'historique Git

### Badges de Sécurité

[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=votre-nom-utilisateur_flask-todo-app&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=votre-nom-utilisateur_flask-todo-app)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=votre-nom-utilisateur_flask-todo-app&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=votre-nom-utilisateur_flask-todo-app)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=votre-nom-utilisateur_flask-todo-app&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=votre-nom-utilisateur_flask-todo-app)

### Outils et Documentation

- **[Guide des outils de sécurité](docs/SECURITY_TOOLS.md)** : Explications des outils utilisés
- **[Guide des rapports](docs/SECURITY_REPORTS_GUIDE.md)** : Comment interpréter les rapports
- **[Politique de sécurité](SECURITY.md)** : Procédure de signalement des vulnérabilités
- **[Script d'analyse locale](scripts/security_scan.sh)** : Exécutez des analyses sans CI/CD## 🔄 Intégration Continue

Ce projet utilise GitHub Actions pour l'intégration continue et le déploiement continu.

### Pipeline CI/CD

Le pipeline exécute automatiquement les tâches suivantes :

#### Job de Build et Test
- **Linting avec Flake8** : Vérifie la conformité du code aux standards PEP 8
- **Formatage avec Black** : S'assure que le code suit un style cohérent
- **Vérification des imports avec isort** : Contrôle l'ordre des imports
- **Tests unitaires avec pytest** : Exécute la suite de tests automatisés
- **Rapport de couverture** : Génère et publie un rapport de couverture de code

#### Job de Docker (exécuté uniquement sur main et develop)
- **Construction de l'image Docker** : Utilise Docker Buildx pour des builds optimisés
- **Publication de l'image** : Pousse l'image vers GitHub Container Registry
- **Mise en cache** : Utilise le cache GitHub Actions pour accélérer les builds futurs

### Badges de statut

- ![CI/CD Pipeline](https://github.com/votre-nom-utilisateur/flask-todo-app/actions/workflows/ci-cd.yml/badge.svg) : Indique le statut du dernier build
- ![codecov](https://codecov.io/gh/votre-nom-utilisateur/flask-todo-app/branch/main/graph/badge.svg) : Montre le pourcentage de couverture de code

### Exécution locale des tests

Vous pouvez exécuter les tests localement avec :

```bash
# Installation des dépendances de test
pip install pytest pytest-flask pytest-cov

# Exécution des tests avec rapport de couverture
pytest --cov=. --cov-report=term
```# Flask Todo App - Gestionnaire de Tâches

[![CI/CD Pipeline](https://github.com/votre-nom-utilisateur/flask-todo-app/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/votre-nom-utilisateur/flask-todo-app/actions/workflows/ci-cd.yml)
[![codecov](https://codecov.io/gh/votre-nom-utilisateur/flask-todo-app/branch/main/graph/badge.svg)](https://codecov.io/gh/votre-nom-utilisateur/flask-todo-app)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Une application web robuste et élégante de gestion de tâches, développée avec le framework Flask et la bibliothèque SQLAlchemy. Cette application représente une solution simple mais complète pour la gestion personnelle ou professionnelle des tâches quotidiennes.

## 📋 Périmètre Fonctionnel

Cette application de liste de tâches offre les fonctionnalités suivantes :

### Gestion des Tâches
- **Création de tâches** : Ajout rapide de nouvelles tâches avec une interface intuitive
- **Visualisation** : Affichage clair des tâches avec leur statut et date de création
- **Modification** : Édition du contenu des tâches existantes
- **Suppression** : Retrait définitif des tâches de la liste
- **Gestion du statut** : Marquage des tâches comme terminées ou non terminées avec indication visuelle

### Interface Utilisateur
- **Design responsive** : Interface adaptée à tous les appareils (ordinateurs, tablettes, smartphones)
- **Expérience utilisateur optimisée** : Navigation intuitive et actions rapides
- **Feedback visuel** : Indication claire du statut des tâches (terminées/non terminées)
- **Organisation chronologique** : Affichage des tâches par ordre de création (plus récentes en premier)

### Architecture Technique
- **Base de données** : Stockage persistant dans SQLite avec ORM SQLAlchemy
- **Backend robuste** : Développé avec Flask, un framework Python léger et puissant
- **Frontend élégant** : Interface utilisateur en HTML/CSS avec Jinja2 pour le templating
- **Structure MVC** : Organisation du code suivant le modèle Modèle-Vue-Contrôleur

## 🖼️ Capture d'écran

![Capture d'écran de l'application](screenshot.png)

## 🐳 Déploiement avec Docker

Cette application est entièrement conteneurisée avec Docker, offrant une méthode de déploiement simple et reproductible.

### Caractéristiques de la conteneurisation

- **Build multi-stage** : Optimise la taille de l'image finale
- **Image légère basée sur Alpine** : Minimise la surface d'attaque et l'empreinte disque
- **Utilisateur dédié non-root** : Améliore la sécurité en limitant les privilèges
- **Port non-privilégié** : Utilise le port 8080 au lieu de ports privilégiés (<1024)
- **Volumes persistants** : Stockage des données de la base SQLite en dehors du conteneur
- **Healthchecks** : Surveillance de l'état de l'application
- **Gestion des logs** : Configuration avancée pour une rotation des logs efficace

### Déploiement avec Docker

```bash
# Construction de l'image
docker build -t flask-todo-app .

# Lancement du conteneur
docker run -d --name flask-todo \
  -p 8080:8080 \
  -v $(pwd)/data:/app/data \
  flask-todo-app
```

### Déploiement avec Docker Compose

```bash
# Lancement de l'application
docker-compose up -d

# Vérification des logs
docker-compose logs -f

# Arrêt de l'application
docker-compose down
```

### Script utilitaire

Un script `docker.sh` est fourni pour simplifier les opérations Docker :

```bash
# Rendre le script exécutable
chmod +x docker.sh

# Construire l'image
./docker.sh build

# Démarrer l'application
./docker.sh start

# Voir les logs
./docker.sh logs

# Arrêter l'application
./docker.sh stop

# Obtenir de l'aide
./docker.sh help
```

### Sécurité

L'image Docker de cette application suit les bonnes pratiques de sécurité :

- **Build multi-stage** : Minimise les vulnérabilités potentielles
- **Utilisateur non-root** : Limite les privilèges dans le conteneur
- **Tini comme init system** : Gère correctement les processus et les signaux
- **Image de base minimale** : Réduit la surface d'attaque
- **Définition explicite des permissions** : Contrôle strict des accès aux fichiers


## 🗂️ Structure du Projet

```
flask-todo-app/
├── app.py                # Application Flask principale avec routes et logique métier
├── requirements.txt      # Dépendances du projet
├── .gitignore           # Configuration des fichiers à ignorer par Git
├── LICENSE              # Licence du projet
├── README.md            # Documentation du projet
└── templates/           # Dossier des templates HTML (vues)
    ├── index.html       # Page principale avec la liste des tâches
    └── update.html      # Page de modification des tâches
```

## 💾 Modèle de Données

L'application utilise un modèle de données simple mais efficace :

### Table `Todo`
- `id` : Identifiant unique de la tâche (clé primaire)
- `content` : Contenu textuel de la tâche (limité à 200 caractères)
- `completed` : Statut de la tâche (terminée ou non)
- `date_created` : Date et heure de création de la tâche

## 🔄 API et Routes

L'application expose les routes suivantes :

| Route | Méthode | Description |
|-------|---------|-------------|
| `/` | GET | Affiche la liste de toutes les tâches |
| `/` | POST | Ajoute une nouvelle tâche |
| `/delete/<id>` | GET | Supprime une tâche spécifique |
| `/complete/<id>` | GET | Change le statut d'une tâche (terminée/non terminée) |
| `/update/<id>` | GET | Affiche le formulaire d'édition d'une tâche |
| `/update/<id>` | POST | Enregistre les modifications d'une tâche |

## 🧪 Limitations Actuelles et Évolutions Possibles

- **Authentification** : Pas de système d'utilisateurs (application mono-utilisateur)
- **Catégorisation** : Pas de classement des tâches par catégories ou priorités
- **Notifications** : Pas de rappels ou d'alertes pour les tâches
- **Recherche** : Pas de fonctionnalité de recherche dans les tâches
- **API REST** : Pas d'API pour l'intégration avec d'autres applications

Ces fonctionnalités pourront être ajoutées dans les futures versions de l'application.

## 🔧 Technologies Utilisées

- **[Flask](https://flask.palletsprojects.com/)** (2.3.3) : Framework web Python léger
- **[SQLAlchemy](https://www.sqlalchemy.org/)** (2.0.21) : ORM Python pour la gestion de base de données
- **[Flask-SQLAlchemy](https://flask-sqlalchemy.palletsprojects.com/)** (3.1.1) : Extension Flask pour intégrer SQLAlchemy
- **[SQLite](https://www.sqlite.org/)** : Système de gestion de base de données légère
- **[Jinja2](https://jinja.palletsprojects.com/)** (3.1.2) : Moteur de templates pour Python
- **HTML5/CSS3** : Structure et style de l'interface utilisateur

## 🤝 Contribution

Ce projet utilise des règles de protection de branches pour assurer la qualité du code. Voici le processus de contribution :

1. **Forkez le projet** : Créez votre propre copie du dépôt sur GitHub
2. **Clonez votre fork** : `git clone https://github.com/votre-username/flask-todo-app.git`
3. **Créez une branche** pour votre fonctionnalité : `git checkout -b feature/nouvelle-fonctionnalite`
4. **Développez votre fonctionnalité** en suivant les conventions de code du projet
5. **Testez** vos modifications pour vous assurer qu'elles fonctionnent correctement
6. **Committez vos changements** avec des messages clairs : `git commit -m 'Ajoute une nouvelle fonctionnalité'`
7. **Poussez vers votre fork** : `git push origin feature/nouvelle-fonctionnalite`
8. **Ouvrez une Pull Request** vers la branche principale du projet
9. **Attendez la revue de code** - votre PR doit être approuvée par au moins un reviewer
10. Une fois approuvée, un mainteneur **mergera votre PR** dans la branche principale

### Règles de protection des branches

Ce projet utilise des règles de protection des branches pour garantir la qualité du code :

- Toutes les modifications doivent passer par des Pull Requests
- Chaque PR nécessite au moins une approbation avant le merge
- Les tests automatisés doivent passer avec succès
- La branche doit être à jour avec la branche principale avant le merge

Ces règles nous aident à maintenir un code de haute qualité et à faciliter la collaboration entre contributeurs.

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.