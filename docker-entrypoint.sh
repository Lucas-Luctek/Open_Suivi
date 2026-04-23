#!/bin/sh
set -e

# Initialise les fichiers statiques dans le volume au premier démarrage
if [ ! -f /app/static/.initialized ]; then
    echo "[OpenSuivi] Initialisation des fichiers statiques..."
    cp -rn /app/static_default/. /app/static/
    touch /app/static/.initialized
fi

# Crée les répertoires de données si absents
mkdir -p /data/uploads /data/backups

exec python app.py
