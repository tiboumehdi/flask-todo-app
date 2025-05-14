# Application Flask de Liste de Tâches

Une application simple de liste de tâches développée avec Flask et SQLAlchemy.

## Fonctionnalités

- Ajouter de nouvelles tâches
- Marquer des tâches comme terminées ou non terminées
- Modifier les tâches existantes
- Supprimer des tâches
- Interface utilisateur responsive et intuitive

## Capture d'écran

![Capture d'écran de l'application](screenshot.png)

## Installation

1. Clonez ce dépôt 
   ```bash
   git clone httpsgithub.comvotre-nom-utilisateurflask-todo-app.git
   cd flask-todo-app
   ```

2. Créez un environnement virtuel et activez-le 
   ```bash
   python -m venv venv
   
   # Sur Windows
   venvScriptsactivate
   
   # Sur macOSLinux
   source venvbinactivate
   ```

3. Installez les dépendances 
   ```bash
   pip install -r requirements.txt
   ```

4. Lancez l'application 
   ```bash
   python app.py
   ```

5. Accédez à l'application dans votre navigateur à l'adresse `http127.0.0.15000`

## Structure du projet

```
flask-todo-app
├── app.py                # Application Flask principale
├── requirements.txt      # Dépendances du projet
└── templates            # Dossier des templates HTML
    ├── index.html        # Page principale avec la liste des tâches
    └── update.html       # Page de modification des tâches
```

## Technologies utilisées

- Flask
- SQLAlchemy
- SQLite
- HTMLCSS

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou à soumettre une pull request.

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.