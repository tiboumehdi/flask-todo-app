# Guide d'Organisation Ansible

Ce document explique l'organisation des fichiers Ansible et la gestion des variables et secrets pour le déploiement de l'application Flask Todo.

## Structure des Dossiers

```
ansible/
├── flask-todo-deploy.yml      # Playbook principal de déploiement
├── .ansible-lint              # Configuration de ansible-lint
├── inventories/               # Inventaires pour chaque environnement
│   ├── production.yml
│   └── staging.yml
├── group_vars/                # Variables groupées par environnement
│   ├── all/                   # Variables communes à tous les environnements
│   │   ├── vars.yml           # Variables non sensibles
│   │   └── vault.yml          # Variables sensibles (chiffrées)
│   ├── production/
│   │   └── vars.yml           # Variables spécifiques à la production
│   └── staging/
│       └── vars.yml           # Variables spécifiques au staging
├── templates/                 # Templates Jinja2 pour les fichiers de configuration
│   ├── backup.sh.j2
│   ├── flask-env.j2
│   ├── logrotate.j2
│   └── node_exporter.j2
└── vars/                      # Variables spécifiques au système d'exploitation
    ├── Debian.yml
    ├── RedHat.yml
    └── default.yml
```

## Gestion des Variables

### Hiérarchie des Variables

Les variables sont organisées selon la hiérarchie suivante (du moins prioritaire au plus prioritaire) :

1. Variables par défaut (dans le playbook)
2. Variables globales (`group_vars/all/vars.yml`)
3. Variables spécifiques à l'environnement (`group_vars/production/vars.yml`)
4. Variables de ligne de commande (`-e` ou `--extra-vars`)

### Types de Variables

- **Variables communes** : Définies dans `group_vars/all/vars.yml`
- **Variables d'environnement** : Définies dans `group_vars/[environment]/vars.yml`
- **Variables OS** : Définies dans `vars/[distribution].yml`
- **Variables sensibles** : Chiffrées dans `group_vars/all/vault.yml`

## Gestion des Secrets

### Ansible Vault

Les secrets sont gérés avec Ansible Vault, qui permet de chiffrer des fichiers YAML contenant des données sensibles :

```bash
# Création d'un fichier chiffré
ansible-vault create group_vars/all/vault.yml

# Édition d'un fichier chiffré existant
ansible-vault edit group_vars/all/vault.yml

# Chiffrement d'un fichier existant
ansible-vault encrypt group_vars/all/vault.yml

# Déchiffrement d'un fichier chiffré
ansible-vault decrypt group_vars/all/vault.yml

# Affichage du contenu d'un fichier chiffré
ansible-vault view group_vars/all/vault.yml
```

### Mot de Passe Vault

Lors de l'exécution des playbooks, vous devez fournir le mot de passe Vault :

```bash
# Avec invite de mot de passe
ansible-playbook flask-todo-deploy.yml --ask-vault-pass

# Avec fichier de mot de passe (ne pas committer ce fichier dans Git!)
ansible-playbook flask-todo-deploy.yml --vault-password-file=.vault_pass

# Avec variable d'environnement
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
ansible-playbook flask-todo-deploy.yml
```

Dans GitHub Actions, le mot de passe Vault est stocké dans le secret `ANSIBLE_VAULT_PASSWORD`.

## Variables d'Environnement

Certaines variables peuvent également être fournies via des variables d'environnement :

```yaml
# Exemple d'utilisation dans le playbook
vars:
  registry_username: "{{ lookup('env', 'REGISTRY_USERNAME') | default(vault_registry_username) }}"
  registry_password: "{{ lookup('env', 'REGISTRY_PASSWORD') | default(vault_registry_password) }}"
```

Cette approche permet d'utiliser des variables d'environnement si elles sont disponibles, sinon de retomber sur les valeurs du vault.

## Meilleures Pratiques

1. **Ne jamais committer des secrets en clair** dans Git
2. **Utiliser ansible-vault** pour tous les secrets
3. **Séparer les variables** par fonction et environnement
4. **Préférer les templates** aux fichiers statiques pour une meilleure flexibilité
5. **Utiliser des noms descriptifs** pour les variables
6. **Commenter les variables** pour expliquer leur utilisation
7. **Définir des valeurs par défaut** pour les variables optionnelles
8. **Valider les variables requises** avec le module `assert`

## Execution des Playbooks

### En Local

```bash
# Exécution du playbook pour l'environnement de staging
ansible-playbook flask-todo-deploy.yml -i inventories/staging.yml --ask-vault-pass

# Exécution du playbook pour l'environnement de production
ansible-playbook flask-todo-deploy.yml -i inventories/production.yml --ask-vault-pass
```

### Via GitHub Actions

Le pipeline CI/CD utilise Ansible pour le déploiement, soit via SSH depuis le runner GitHub Actions, soit via un runner auto-hébergé.

La configuration pour GitHub Actions inclut :

1. Vérification du code Ansible avec `ansible-lint`
2. Chargement du mot de passe Vault depuis les secrets GitHub
3. Exécution du playbook avec les variables appropriées pour l'environnement