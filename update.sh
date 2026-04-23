#!/bin/bash
# ============================================================
# OpenSuivi — Script de mise à jour
# Usage : sudo bash update.sh
# ============================================================

set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       Mise à jour de OpenSuivi       ║"
echo "╚══════════════════════════════════════╝"
echo ""

INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$INSTALL_DIR"

# ── 1. Sauvegarde de la base de données ─────────────────────
echo "─── Sauvegarde de la base de données ───"
BACKUP_FILE="backups/opensuivi_avant_maj_$(date +%Y%m%d_%H%M%S).db"
mkdir -p backups
cp opensuivi.db "$BACKUP_FILE"
echo "  ✓ Sauvegarde : $BACKUP_FILE"
echo ""

# ── 2. Récupération du code ──────────────────────────────────
echo "─── Récupération de la dernière version ───"
git pull origin main
echo "  ✓ Code mis à jour."
echo ""

# ── 3. Mise à jour des dépendances Python ───────────────────
echo "─── Mise à jour des dépendances Python ───"
source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "  ✓ Dépendances à jour."
echo ""

# ── 4. Redémarrage du service ────────────────────────────────
echo "─── Redémarrage du service ───"
systemctl restart opensuivi
sleep 2
if systemctl is-active --quiet opensuivi; then
    echo "  ✓ Service redémarré avec succès."
else
    echo "  ✗ Erreur au démarrage ! Consultez : journalctl -u opensuivi -n 50"
    exit 1
fi
echo ""

echo "╔══════════════════════════════════════════════════╗"
echo "║           Mise à jour terminée !                 ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                  ║"
printf "║  Accès : http://%-32s║\n" "$(hostname -I | awk '{print $1}'):$(grep '^PORT=' .env | cut -d= -f2 || echo 5050)"
echo "║                                                  ║"
echo "║  En cas de problème, restaurez la sauvegarde :  ║"
printf "║  cp %-44s║\n" "$BACKUP_FILE opensuivi.db"
echo "║  puis : systemctl restart opensuivi             ║"
echo "║                                                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
