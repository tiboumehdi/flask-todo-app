#!/bin/sh
# Script pour construire et démarrer l'application Flask Todo avec Docker

set -e

# Variables
IMAGE_NAME="flask-todo-app"
CONTAINER_NAME="flask-todo"
PORT=8080

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction d'aide
print_help() {
  echo "Script de gestion Docker pour Flask Todo App"
  echo ""
  echo "Usage:"
  echo "  $0 [commande]"
  echo ""
  echo "Commandes:"
  echo "  build       Construit l'image Docker"
  echo "  start       Démarre le conteneur"
  echo "  stop        Arrête le conteneur"
  echo "  restart     Redémarre le conteneur"
  echo "  logs        Affiche les logs du conteneur"
  echo "  shell       Ouvre un shell dans le conteneur"
  echo "  clean       Supprime le conteneur et l'image"
  echo "  help        Affiche ce message d'aide"
  echo ""
}

# Construction de l'image
build_image() {
  echo "${YELLOW}Construction de l'image Docker ${IMAGE_NAME}...${NC}"
  docker build -t ${IMAGE_NAME} .
  echo "${GREEN}Image construite avec succès !${NC}"
}

# Démarrage du conteneur
start_container() {
  if docker ps -a | grep -q ${CONTAINER_NAME}; then
    echo "${YELLOW}Le conteneur existe déjà. Arrêt du conteneur existant...${NC}"
    docker stop ${CONTAINER_NAME} > /dev/null 2>&1 || true
    docker rm ${CONTAINER_NAME} > /dev/null 2>&1 || true
  fi
  
  echo "${YELLOW}Démarrage du conteneur ${CONTAINER_NAME}...${NC}"
  docker run -d --name ${CONTAINER_NAME} \
    -p ${PORT}:8080 \
    -v $(pwd)/data:/app/data \
    --restart unless-stopped \
    ${IMAGE_NAME}
  
  echo "${GREEN}Application démarrée sur http://localhost:${PORT}${NC}"
}

# Arrêt du conteneur
stop_container() {
  echo "${YELLOW}Arrêt du conteneur ${CONTAINER_NAME}...${NC}"
  docker stop ${CONTAINER_NAME} > /dev/null 2>&1 || { echo "${RED}Le conteneur n'est pas en cours d'exécution.${NC}"; exit 1; }
  echo "${GREEN}Conteneur arrêté.${NC}"
}

# Affichage des logs
show_logs() {
  echo "${YELLOW}Affichage des logs du conteneur ${CONTAINER_NAME}...${NC}"
  docker logs -f ${CONTAINER_NAME}
}

# Ouverture d'un shell dans le conteneur
open_shell() {
  echo "${YELLOW}Ouverture d'un shell dans le conteneur ${CONTAINER_NAME}...${NC}"
  docker exec -it ${CONTAINER_NAME} /bin/sh
}

# Nettoyage complet
clean_all() {
  echo "${YELLOW}Suppression du conteneur ${CONTAINER_NAME}...${NC}"
  docker stop ${CONTAINER_NAME} > /dev/null 2>&1 || true
  docker rm ${CONTAINER_NAME} > /dev/null 2>&1 || true
  
  echo "${YELLOW}Suppression de l'image ${IMAGE_NAME}...${NC}"
  docker rmi ${IMAGE_NAME} > /dev/null 2>&1 || true
  
  echo "${GREEN}Nettoyage terminé.${NC}"
}

# Vérification si Docker est installé
if ! command -v docker > /dev/null 2>&1; then
  echo "${RED}Docker n'est pas installé ou n'est pas dans le PATH.${NC}"
  exit 1
fi

# Traitement des commandes
case "$1" in
  build)
    build_image
    ;;
  start)
    if ! docker image inspect ${IMAGE_NAME} > /dev/null 2>&1; then
      echo "${YELLOW}L'image n'existe pas encore. Construction...${NC}"
      build_image
    fi
    start_container
    ;;
  stop)
    stop_container
    ;;
  restart)
    stop_container || true
    start_container
    ;;
  logs)
    show_logs
    ;;
  shell)
    open_shell
    ;;
  clean)
    clean_all
    ;;
  help|*)
    print_help
    ;;
esac

exit 0