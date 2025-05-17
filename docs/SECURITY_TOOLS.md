# Outils de Sécurité dans le Pipeline CI/CD

Ce document décrit les différents outils de sécurité intégrés dans notre pipeline CI/CD GitHub Actions et explique comment interpréter leurs résultats.

## Tableau Récapitulatif des Outils de Sécurité

| Catégorie | Outil | Description | Fichier de Résultat |
|-----------|------|-------------|---------------------|
| **SAST (Static Application Security Testing)** | CodeQL | Analyse statique avancée de GitHub | GitHub Security Tab |
| | SonarCloud | Analyse de qualité et sécurité du code | SonarCloud Dashboard |
| | Bandit | Analyse de sécurité spécifique à Python | bandit-results.sarif |
| | Semgrep | Analyse de motifs de code pour les vulnérabilités | semgrep-results.sarif |
| **SCA (Software Composition Analysis)** | OWASP Dependency-Check | Analyse des dépendances pour les CVE connus | reports/dependency-check-report.html |
| | Safety | Scanner de vulnérabilités pour packages Python | safety-report.json |
| | pip-audit | Scanner de vulnérabilités Python basé sur PyPI | pip-audit-report.json |
| | Snyk | Analyse de dépendances multi-langage | snyk-results.sarif |
| **Container Security** | Trivy | Scanner de vulnérabilités pour conteneurs | trivy-results.sarif |
| | Dockle | Linter pour les bonnes pratiques Docker | dockle-results.sarif |
| | Grype | Scanner de vulnérabilités d'Anchore | anchore-results.sarif |
| **Secret Scanning** | TruffleHog | Détection de secrets et informations sensibles | Console output |
| | GitLeaks | Scanner de fuites de secrets dans Git | GitLeaks report |

## Détails des Outils par Catégorie

### 1. SAST (Analyse Statique de Sécurité)

#### CodeQL
- **Description** : L'outil d'analyse statique de code de GitHub qui détecte les vulnérabilités et problèmes de qualité
- **Avantages** : Détecte des vulnérabilités complexes, s'intègre nativement à GitHub
- **Comment voir les résultats** : GitHub Security tab → Code scanning alerts
- **Types de vulnérabilités détectées** : Injections SQL, XSS, CSRF, fuites de mémoire, etc.

#### SonarCloud
- **Description** : Plateforme d'analyse continue de la qualité et de la sécurité du code
- **Avantages** : Analyse complète (bugs, vulnérabilités, code smells), rapports détaillés
- **Comment voir les résultats** : Dashboard SonarCloud (lien dans les actions GitHub)
- **Types de vulnérabilités détectées** : Vulnérabilités de sécurité, bugs, problèmes de maintenabilité

#### Bandit
- **Description** : Outil d'analyse statique spécifique à Python pour trouver des problèmes de sécurité courants
- **Avantages** : Léger, spécifique à Python, facile à configurer
- **Comment voir les résultats** : GitHub Security tab → Code scanning alerts (catégorie bandit)
- **Types de vulnérabilités détectées** : Utilisation de fonctions dangereuses, problèmes de validation, etc.

#### Semgrep
- **Description** : Outil d'analyse basé sur des règles pour détecter des vulnérabilités
- **Avantages** : Règles personnalisables, prend en charge l'OWASP Top 10
- **Comment voir les résultats** : GitHub Security tab → Code scanning alerts (catégorie semgrep)
- **Types de vulnérabilités détectées** : OWASP Top 10, problèmes spécifiques au langage

### 2. SCA (Analyse de Composition Logicielle)

#### OWASP Dependency-Check
- **Description** : Identifie les dépendances du projet et vérifie les CVEs connues
- **Avantages** : Base de données de vulnérabilités étendue, rapports détaillés
- **Comment voir les résultats** : Artifact "dependency-check-report" → HTML report
- **Types de vulnérabilités détectées** : Vulnérabilités connues (CVEs) dans les dépendances

#### Safety
- **Description** : Scanner de vulnérabilités spécifique aux packages Python
- **Avantages** : Léger, facile à utiliser, spécifique à Python
- **Comment voir les résultats** : Artifact "safety-report" → JSON file
- **Types de vulnérabilités détectées** : Vulnérabilités connues dans les packages Python

#### pip-audit
- **Description** : Scanner de vulnérabilités Python basé sur la base de données de sécurité PyPI
- **Avantages** : Utilise des sources de données officielles, bien maintenu
- **Comment voir les résultats** : Artifact "pip-audit-report" → JSON file
- **Types de vulnérabilités détectées** : Vulnérabilités publiées dans la base de données de sécurité PyPI

#### Snyk
- **Description** : Plateforme complète d'analyse de dépendances et de conteneurs
- **Avantages** : Base de données propriétaire, mises à jour fréquentes, interface utilisateur riche
- **Comment voir les résultats** : GitHub Security tab → Code scanning alerts (catégorie snyk)
- **Types de vulnérabilités détectées** : Vulnérabilités dans les dépendances, licences, configurations

### 3. Sécurité des Conteneurs

#### Trivy
- **Description** : Scanner de vulnérabilités open-source pour conteneurs et systèmes de fichiers
- **Avantages** : Rapide, complet, facile à intégrer
- **Comment voir les résultats** : GitHub Security tab → Code scanning alerts (catégorie trivy)
- **Types de vulnérabilités détectées** : OS packages, vulnérabilités des dépendances, problèmes de configuration

#### Dockle
- **Description** : Linter pour les images Docker basé sur les bonnes pratiques
- **Avantages** : Vérifie les bonnes pratiques CIS Benchmark
- **Comment voir les résultats** : GitHub Security tab → Code scanning alerts (catégorie dockle)
- **Types de vulnérabilités détectées** : Mauvaises configurations, permissions, utilisateur root, etc.

#### Grype (Anchore)
- **Description** : Scanner de vulnérabilités de conteneurs par Anchore
- **Avantages** : Base de données de vulnérabilités régulièrement mise à jour, analyses détaillées
- **Comment voir les résultats** : GitHub Security tab → Code scanning alerts (catégorie anchore)
- **Types de vulnérabilités détectées** : Vulnérabilités OS et applications dans les images de conteneurs

### 4. Détection de Secrets

#### TruffleHog
- **Description** : Détecte les secrets, clés API, credentials dans le code
- **Avantages** : Détection de haute précision, analyse d'historique Git
- **Comment voir les résultats** : Logs de l'action GitHub dans le workflow
- **Types de vulnérabilités détectées** : API keys, tokens, credentials, clés privées

#### GitLeaks
- **Description** : Scanner de secrets Git avancé
- **Avantages** : Règles personnalisables, support multi-format
- **Comment voir les résultats** : Logs de l'action GitHub dans le workflow
- **Types de vulnérabilités détectées** : Secrets, credentials, tokens dans tout l'historique Git

## Comment réagir aux alertes

### Prioritisation des vulnérabilités

1. **Critique** : Vulnérabilités qui permettent l'exécution de code à distance, l'accès non autorisé ou la fuite de données sensibles
2. **Haute** : Vulnérabilités qui peuvent conduire à une compromission partielle du système
3. **Moyenne** : Problèmes qui pourraient être exploités dans certaines circonstances
4. **Faible** : Problèmes mineurs ou théoriques avec un impact limité

### Processus de correction

1. **Triage** : Évaluer la validité et la sévérité de l'alerte
2. **Correction** : Mettre à jour les dépendances, corriger le code ou modifier la configuration
3. **Vérification** : Relancer les scans pour confirmer que la vulnérabilité est résolue
4. **Documentation** : Documenter la vulnérabilité et la solution pour référence future

## Configuration et personnalisation

Chaque outil peut être personnalisé via les fichiers de configuration suivants :

- **Bandit** : `.bandit` (configuration des règles et exclusions)
- **SonarCloud** : `sonar-project.properties` (configuration de l'analyse)
- **Trivy** : Paramètres dans le workflow (sévérité, format, etc.)
- **Semgrep** : Configuration dans le workflow (règles OWASP)

## Rapports de sécurité périodiques

Un rapport de sécurité est généré automatiquement chaque semaine, combinant les résultats de tous les outils. Ce rapport est disponible comme artifact GitHub et peut être téléchargé depuis l'exécution du workflow.

## Liens utiles

- [GitHub Security Features](https://docs.github.com/en/code-security)
- [SonarCloud Documentation](https://docs.sonarcloud.io/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Snyk Documentation](https://docs.snyk.io/)