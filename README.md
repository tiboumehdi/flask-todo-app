# Flask Todo App - Gestionnaire de Tâches

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

## 🛠️ Installation et Déploiement

### Prérequis
- Python 3.8 ou supérieur
- Pip (gestionnaire de paquets Python)
- Git

### Étapes d'installation

1. **Clonez ce dépôt** :
   ```bash
   git clone https://github.com0/tiboumehdi/flask-todo-app.git
   cd flask-todo-app
   ```

2. **Créez un environnement virtuel et activez-le** :
   ```bash
   python -m venv venv
   
   # Sur Windows
   venv\Scripts\activate
   
   # Sur macOS/Linux
   source venv/bin/activate
   ```

3. **Installez les dépendances** :
   ```bash
   pip install -r requirements.txt
   ```

4. **Lancez l'application** :
   ```bash
   python app.py
   ```

5. **Accédez à l'application** dans votre navigateur à l'adresse `http://127.0.0.1:5000/`

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
2. **Clonez votre fork** : `git clone https://github.com/tiboumehdi/flask-todo-app.git`
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