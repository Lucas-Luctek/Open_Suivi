#!/bin/bash
# ============================================================
# OpenSuivi — Script de bootstrap (installation depuis zéro)
# Usage : bash <(curl -fsSL https://raw.githubusercontent.com/Lucas-Luctek/Open_Suivi/main/install.sh)
# ============================================================

set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║         Installation de OpenSuivi       ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Dépendances système ─────────────────────────────────────
echo "─── Dépendances système ───"
apt-get update -qq
apt-get install -y git curl
echo "  ✓ git et curl installés."
echo ""

# ── Clonage du dépôt ────────────────────────────────────────
echo "─── Téléchargement de OpenSuivi ───"
INSTALL_DIR="$HOME/opensuivi"
if [ -d "$INSTALL_DIR" ]; then
    echo "  Le dossier $INSTALL_DIR existe déjà, mise à jour..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    git clone https://github.com/Lucas-Luctek/Open_Suivi.git "$INSTALL_DIR"
fi
echo "  ✓ Dépôt prêt dans $INSTALL_DIR"
echo ""

# ── Lancement de l'installation ─────────────────────────────
cd "$INSTALL_DIR"
chmod +x setup.sh
./setup.sh
