# Configuration for GitHub Runner Self-Hosted
# Instructions pour configurer un runner auto-hébergé pour GitHub Actions

## Prérequis

- Un serveur Linux (Ubuntu 20.04+ recommandé)
- Accès SSH avec privilèges sudo
- Docker installé
- Ansible installé
- Au moins 2GB de RAM et 1 CPU
- Connectivité réseau vers GitHub et vos serveurs de déploiement

## Installation du runner auto-hébergé

### 1. Préparation du serveur

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer les dépendances nécessaires
sudo apt install -y curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev

# Installer Docker si non présent
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Installer Ansible si non présent
if ! command -v ansible &> /dev/null; then
    sudo apt install -y ansible
fi

# Créer un utilisateur dédié pour le runner
sudo useradd -m -s /bin/bash github-runner
sudo usermod -aG docker github-runner
```

### 2. Configuration du runner dans GitHub

1. Dans votre dépôt GitHub, accédez à `Settings > Actions > Runners`
2. Cliquez sur `New self-hosted runner`
3. Sélectionnez `Linux` comme système d'exploitation
4. Suivez les instructions pour télécharger et configurer le runner

### 3. Installation et configuration du runner

```bash
# Se connecter en tant qu'utilisateur github-runner
sudo su - github-runner

# Créer le répertoire pour le runner
mkdir actions-runner && cd actions-runner

# Télécharger le package du runner (remplacer TOKEN et URL par les valeurs fournies par GitHub)
curl -o actions-runner-linux-x64-2.305.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.305.0/actions-runner-linux-x64-2.305.0.tar.gz

# Extraire le package
tar xzf ./actions-runner-linux-x64-2.305.0.tar.gz

# Configurer le runner (remplacer TOKEN et URL par les valeurs fournies par GitHub)
./config.sh --url https://github.com/votre-nom-utilisateur/flask-todo-app --token TOKEN --labels self-hosted,production --unattended

# Installer le service
sudo ./svc.sh install
sudo ./svc.sh start

# Vérifier l'état du service
sudo ./svc.sh status
```

### 4. Configuration pour Ansible

```bash
# Créer les dossiers pour Ansible
mkdir -p ~/.ansible/roles

# Configurer SSH pour l'accès aux serveurs de déploiement
mkdir -p ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config

# Générer une paire de clés SSH pour le déploiement
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Afficher la clé publique à ajouter sur les serveurs de déploiement
cat ~/.ssh/id_rsa.pub
```

### 5. Configuration des labels pour les environnements

Pour le pipeline GitHub Actions, nous utilisons des labels pour cibler les runners spécifiques à chaque environnement. Vous pouvez configurer des runners dédiés pour chaque environnement :

**Runner de Production**
```bash
./config.sh --url https://github.com/votre-nom-utilisateur/flask-todo-app --token TOKEN --labels self-hosted,production --unattended
```

**Runner de Staging**
```bash
./config.sh --url https://github.com/votre-nom-utilisateur/flask-todo-app --token TOKEN --labels self-hosted,staging --unattended
```

## Sécurité

### Bonnes pratiques de sécurité

1. **Isolation** : Utilisez un serveur dédié pour chaque runner.
2. **Mise à jour régulière** : Mettez à jour régulièrement le runner et le système.
3. **Rotation des clés** : Changez périodiquement les clés SSH.
4. **Pare-feu** : Configurez le pare-feu pour limiter l'accès.
5. **Secrets** : Ne stockez pas de secrets directement sur le runner.

### Configuration du firewall

```bash
# Configurer ufw (Uncomplicated Firewall)
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

## Maintenance

### Mise à jour du runner

```bash
# Arrêter le service
sudo ./svc.sh stop

# Télécharger la nouvelle version
curl -o actions-runner-linux-x64-[VERSION].tar.gz -L https://github.com/actions/runner/releases/download/v[VERSION]/actions-runner-linux-x64-[VERSION].tar.gz

# Extraire et installer
tar xzf ./actions-runner-linux-x64-[VERSION].tar.gz
./config.sh --url https://github.com/votre-nom-utilisateur/flask-todo-app --token TOKEN --labels self-hosted,[environment] --unattended --replace

# Redémarrer le service
sudo ./svc.sh start
```

### Logs et dépannage

```bash
# Vérifier les logs du runner
cat ~/actions-runner/_diag/Runner_*.log

# Vérifier les logs du service
sudo journalctl -u actions.runner.*

# Redémarrer le service en cas de problème
sudo ./svc.sh restart
```

## Intégration avec le pipeline CI/CD

Pour utiliser le runner auto-hébergé dans votre workflow GitHub Actions, assurez-vous que le job spécifie les bons labels :

```yaml
jobs:
  deploy:
    runs-on: [self-hosted, production]  # Utilise le runner avec les labels "self-hosted" et "production"
    
    # Le reste de la configuration du job...
```

Cette configuration permettra d'exécuter le job de déploiement sur votre runner auto-hébergé plutôt que sur les runners fournis par GitHub.