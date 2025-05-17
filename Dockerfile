# Dockerfile multi-stage pour Flask Todo App
# Utilise des images légères Alpine et un utilisateur dédié non-root

# ---------------------------------------------
# Stage 1: Base pour la construction de l'application
# ---------------------------------------------
FROM python:3.11-alpine AS builder

# Installation des dépendances système nécessaires à la construction
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    openssl-dev \
    cargo

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement les fichiers nécessaires pour installer les dépendances
COPY requirements.txt .

# Créer un environnement virtuel et installer les dépendances
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ---------------------------------------------
# Stage 2: Image finale légère
# ---------------------------------------------
FROM python:3.11-alpine AS final

# Ajout de labels informatifs selon les bonnes pratiques
LABEL maintainer="Votre Nom <votre.email@example.com>"
LABEL version="1.0.0"
LABEL description="Flask Todo App - Application de gestion de tâches"

# Définir les variables d'environnement pour l'encodage
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONIOENCODING=UTF-8

# Variables d'environnement pour Prometheus (en mode multiprocessus avec Gunicorn)
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus_multiproc
ENV METRICS_PORT=9090

# Installation des packages nécessaires uniquement pour l'exécution
RUN apk add --no-cache \
    tini \
    sqlite \
    curl \
    ca-certificates \
    tzdata \
    bash

# Créer un utilisateur dédié non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Définir le répertoire de travail
WORKDIR /app

# Copier l'environnement virtuel de l'étape de construction
COPY --from=builder /app/venv /app/venv

# Copier les fichiers de l'application
COPY --chown=appuser:appgroup app.py .
COPY --chown=appuser:appgroup templates ./templates

# Créer les répertoires nécessaires et donner les permissions à l'utilisateur
RUN mkdir -p /app/data /app/logs ${PROMETHEUS_MULTIPROC_DIR} && \
    chown -R appuser:appgroup /app/data /app/logs ${PROMETHEUS_MULTIPROC_DIR} && \
    chmod 755 ${PROMETHEUS_MULTIPROC_DIR}

# Configurer le chemin de l'environnement virtuel
ENV PATH="/app/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080 \
    FLASK_ENV=production \
    SQLALCHEMY_DATABASE_URI="sqlite:////app/data/todo.db" \
    LOG_LEVEL=INFO \
    LOG_FILE="/app/logs/app.log"

# Vérification de santé
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Passer à l'utilisateur non-root
USER appuser

# Exposer les ports (application et métriques)
EXPOSE 8080 9090

# Utiliser tini comme point d'entrée pour gérer les signaux et les processus zombies
ENTRYPOINT ["/sbin/tini", "--"]

# Démarrer l'application avec Gunicorn comme serveur WSGI
CMD gunicorn --bind 0.0.0.0:${PORT} \
    --workers 2 \
    --threads 4 \
    --worker-tmp-dir /dev/shm \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level ${LOG_LEVEL} \
    --worker-class gthread \
    "app:app"