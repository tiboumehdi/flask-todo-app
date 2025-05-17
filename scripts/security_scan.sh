#!/bin/bash
# Script pour analyser manuellement la sécurité du projet Flask Todo App

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Répertoires
REPORTS_DIR="security_reports"
TEMP_DIR="security_temp"

# Création des répertoires pour les rapports
mkdir -p ${REPORTS_DIR}
mkdir -p ${TEMP_DIR}

echo -e "${YELLOW}=== Analyse de sécurité de Flask Todo App ===${NC}"
echo -e "${YELLOW}Rapports stockés dans: ${REPORTS_DIR}${NC}"
echo ""

# Vérification des prérequis
check_prereqs() {
  echo -e "${YELLOW}Vérification des outils requis...${NC}"
  
  # Python
  if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 non trouvé. Veuillez l'installer.${NC}"
    exit 1
  fi
  
  # Docker
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker non trouvé. Veuillez l'installer pour les analyses d'image.${NC}"
    echo -e "${YELLOW}Continuons avec les analyses de code uniquement...${NC}"
    DOCKER_AVAILABLE=false
  else
    DOCKER_AVAILABLE=true
  fi
  
  # Création d'un environnement virtuel pour les outils Python
  python3 -m venv ${TEMP_DIR}/venv
  source ${TEMP_DIR}/venv/bin/activate
  
  # Installation des outils de sécurité
  echo -e "${YELLOW}Installation des outils d'analyse de sécurité...${NC}"
  pip install --quiet safety bandit pip-audit semgrep
  
  echo -e "${GREEN}Configuration terminée.${NC}"
  echo ""
}

# Analyse des dépendances avec Safety
run_safety() {
  echo -e "${YELLOW}Analyse des dépendances avec Safety...${NC}"
  safety check -r requirements.txt --output text > ${REPORTS_DIR}/safety_report.txt
  safety check -r requirements.txt --output json > ${REPORTS_DIR}/safety_report.json
  echo -e "${GREEN}Analyse Safety terminée. Rapport disponible dans ${REPORTS_DIR}/safety_report.txt${NC}"
  echo ""
}

# Analyse des dépendances avec pip-audit
run_pip_audit() {
  echo -e "${YELLOW}Analyse des dépendances avec pip-audit...${NC}"
  pip-audit -r requirements.txt -o ${REPORTS_DIR}/pip_audit_report.txt
  pip-audit -r requirements.txt -f json -o ${REPORTS_DIR}/pip_audit_report.json
  echo -e "${GREEN}Analyse pip-audit terminée. Rapport disponible dans ${REPORTS_DIR}/pip_audit_report.txt${NC}"
  echo ""
}

# Analyse statique avec Bandit
run_bandit() {
  echo -e "${YELLOW}Analyse du code avec Bandit...${NC}"
  bandit -r . -x "venv,${TEMP_DIR},tests" -o ${REPORTS_DIR}/bandit_report.html -f html
  bandit -r . -x "venv,${TEMP_DIR},tests" -o ${REPORTS_DIR}/bandit_report.json -f json
  echo -e "${GREEN}Analyse Bandit terminée. Rapport disponible dans ${REPORTS_DIR}/bandit_report.html${NC}"
  echo ""
}

# Analyse avec Semgrep
run_semgrep() {
  echo -e "${YELLOW}Analyse du code avec Semgrep (règles OWASP)...${NC}"
  semgrep --config=p/owasp-top-ten --output ${REPORTS_DIR}/semgrep_report.txt
  echo -e "${GREEN}Analyse Semgrep terminée. Rapport disponible dans ${REPORTS_DIR}/semgrep_report.txt${NC}"
  echo ""
}

# Analyse Docker avec Trivy (si Docker est disponible)
run_trivy() {
  if [ "$DOCKER_AVAILABLE" = true ]; then
    echo -e "${YELLOW}Construction de l'image Docker pour analyse...${NC}"
    docker build -t flask-todo-app:security-scan .
    
    echo -e "${YELLOW}Analyse de l'image Docker avec Trivy...${NC}"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}/${REPORTS_DIR}:/reports aquasec/trivy image --format template --template "@/reports/html.tpl" -o /reports/trivy_report.html flask-todo-app:security-scan
    
    echo -e "${GREEN}Analyse Trivy terminée. Rapport disponible dans ${REPORTS_DIR}/trivy_report.html${NC}"
    echo ""
  else
    echo -e "${YELLOW}Docker non disponible. Analyse Trivy ignorée.${NC}"
    echo ""
  fi
}

# Génération d'un rapport de synthèse
generate_summary() {
  echo -e "${YELLOW}Génération du rapport de synthèse...${NC}"
  
  cat > ${REPORTS_DIR}/summary_report.md << EOL
# Rapport de Sécurité - Flask Todo App

Date de l'analyse: $(date)

## Résumé des analyses

| Outil | Statut | Rapport détaillé |
|-------|--------|------------------|
| Safety | Terminé | [Rapport Safety](safety_report.txt) |
| pip-audit | Terminé | [Rapport pip-audit](pip_audit_report.txt) |
| Bandit | Terminé | [Rapport Bandit](bandit_report.html) |
| Semgrep | Terminé | [Rapport Semgrep](semgrep_report.txt) |
EOL

  if [ "$DOCKER_AVAILABLE" = true ]; then
    cat >> ${REPORTS_DIR}/summary_report.md << EOL
| Trivy | Terminé | [Rapport Trivy](trivy_report.html) |
EOL
  else
    cat >> ${REPORTS_DIR}/summary_report.md << EOL
| Trivy | Non exécuté (Docker indisponible) | N/A |
EOL
  fi

  cat >> ${REPORTS_DIR}/summary_report.md << EOL

## Prochaines étapes recommandées

1. Examinez les rapports pour identifier les vulnérabilités critiques ou élevées
2. Priorisez les corrections selon la sévérité et l'exploitabilité
3. Corrigez les vulnérabilités identifiées
4. Exécutez une nouvelle analyse pour confirmer les corrections

## Ressources additionnelles

- [Guide d'interprétation des rapports de sécurité](../docs/SECURITY_REPORTS_GUIDE.md)
- [Documentation des outils de sécurité](../docs/SECURITY_TOOLS.md)
- [Politique de sécurité](../SECURITY.md)
EOL

  echo -e "${GREEN}Rapport de synthèse généré: ${REPORTS_DIR}/summary_report.md${NC}"
  echo ""
}

# Nettoyage
cleanup() {
  echo -e "${YELLOW}Nettoyage de l'environnement...${NC}"
  deactivate
  rm -rf ${TEMP_DIR}
  
  if [ "$DOCKER_AVAILABLE" = true ]; then
    docker rmi flask-todo-app:security-scan >/dev/null 2>&1 || true
  fi
  
  echo -e "${GREEN}Nettoyage terminé.${NC}"
  echo ""
}

# Template HTML pour Trivy
create_trivy_template() {
  cat > ${REPORTS_DIR}/html.tpl << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trivy Scan Results</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; color: #333; }
    h1 { color: #2c3e50; border-bottom: 2px solid #eee; padding-bottom: 10px; }
    h2 { color: #3498db; margin-top: 30px; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
    th, td { text-align: left; padding: 12px; }
    th { background-color: #3498db; color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    .critical { color: #e74c3c; font-weight: bold; }
    .high { color: #e67e22; font-weight: bold; }
    .medium { color: #f39c12; }
    .low { color: #27ae60; }
    .unknown { color: #7f8c8d; }
    .summary { background-color: #eee; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
  </style>
</head>
<body>
  <h1>Trivy Vulnerability Scan Report</h1>
  <div class="summary">
    <p><strong>Target:</strong> {{ .Target }}</p>
    <p><strong>Total Vulnerabilities:</strong>
      <span class="critical">Critical: {{ .Vulnerabilities.Critical }}</span>,
      <span class="high">High: {{ .Vulnerabilities.High }}</span>,
      <span class="medium">Medium: {{ .Vulnerabilities.Medium }}</span>,
      <span class="low">Low: {{ .Vulnerabilities.Low }}</span>,
      <span class="unknown">Unknown: {{ .Vulnerabilities.Unknown }}</span>
    </p>
  </div>

  {{ range .Results }}
    <h2>{{ .Type }} ({{ .Target }})</h2>
    {{ if gt (len .Vulnerabilities) 0 }}
      <table>
        <tr>
          <th>Package</th>
          <th>Vulnerability ID</th>
          <th>Severity</th>
          <th>Installed Version</th>
          <th>Fixed Version</th>
          <th>Description</th>
        </tr>
        {{ range .Vulnerabilities }}
          <tr>
            <td>{{ .PkgName }}</td>
            <td>{{ .VulnerabilityID }}</td>
            <td class="{{ lower .Severity }}">{{ .Severity }}</td>
            <td>{{ .InstalledVersion }}</td>
            <td>{{ .FixedVersion }}</td>
            <td>{{ .Description }}</td>
          </tr>
        {{ end }}
      </table>
    {{ else }}
      <p>No vulnerabilities found.</p>
    {{ end }}
  {{ end }}
</body>
</html>
EOL
}

# Exécution principale
main() {
  check_prereqs
  create_trivy_template
  run_safety
  run_pip_audit
  run_bandit
  run_semgrep
  run_trivy
  generate_summary
  cleanup
  
  echo -e "${GREEN}=== Analyse de sécurité terminée ===${NC}"
  echo -e "${GREEN}Tous les rapports sont disponibles dans le répertoire: ${REPORTS_DIR}${NC}"
  echo -e "${GREEN}Consultez le rapport de synthèse: ${REPORTS_DIR}/summary_report.md${NC}"
}

# Exécution du script
main