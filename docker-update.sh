#!/bin/bash
set -e

echo "=== Mise à jour OpenSuivi (Docker) ==="

# Sauvegarde de la BDD avant tout
echo ">>> Sauvegarde de la base de données..."
docker compose exec opensuivi python3 backup.py \
    && echo "    Sauvegarde OK" \
    || echo "    ⚠️  Sauvegarde impossible (conteneur arrêté ?)"

# Récupération du code
echo ">>> Récupération des mises à jour GitHub..."
git pull

# Rebuild et redémarrage
echo ">>> Reconstruction de l'image Docker..."
docker compose build --no-cache

echo ">>> Redémarrage du service..."
docker compose up -d

# Vérification
echo ">>> Vérification..."
sleep 8
docker compose ps

echo ""
echo "=== Mise à jour terminée ==="
