#!/bin/sh
set -e

# Génère et persiste une SECRET_KEY si elle n'existe pas encore
if [ ! -f /data/.secret_key ]; then
    python3 -c "import secrets; print(secrets.token_hex(32))" > /data/.secret_key
    echo "[OpenSuivi] SECRET_KEY générée et sauvegardée dans /data/.secret_key"
fi
export SECRET_KEY=$(cat /data/.secret_key)

# Initialise les fichiers statiques dans le volume au premier démarrage
if [ ! -f /app/static/.initialized ]; then
    echo "[OpenSuivi] Initialisation des fichiers statiques..."
    cp -rn /app/static_default/. /app/static/
    touch /app/static/.initialized
fi

# Crée les répertoires de données si absents
mkdir -p /data/uploads /data/backups

PORT=${PORT:-5050}

# 1 worker pour éviter les doublons APScheduler, 4 threads pour la concurrence
exec gunicorn \
    --bind "0.0.0.0:${PORT}" \
    --workers 1 \
    --threads 4 \
    --worker-class gthread \
    --timeout 120 \
    --access-logfile - \
    app:app
