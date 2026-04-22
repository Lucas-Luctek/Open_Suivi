#!/bin/bash
# ============================================================
# Postulo — Script de bootstrap (installation depuis zéro)
# Usage : bash <(curl -fsSL https://raw.githubusercontent.com/VOTRE_USERNAME/postulo/main/install.sh)
# ============================================================

set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║         Installation de Postulo       ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Dépendances système ─────────────────────────────────────
echo "─── Dépendances système ───"
apt-get update -qq
apt-get install -y git curl
echo "  ✓ git et curl installés."
echo ""

# ── Clonage du dépôt ────────────────────────────────────────
echo "─── Téléchargement de Postulo ───"
INSTALL_DIR="$HOME/postulo"
if [ -d "$INSTALL_DIR" ]; then
    echo "  Le dossier $INSTALL_DIR existe déjà, mise à jour..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    git clone https://github.com/VOTRE_USERNAME/postulo.git "$INSTALL_DIR"
fi
echo "  ✓ Dépôt prêt dans $INSTALL_DIR"
echo ""

# ── Lancement de l'installation ─────────────────────────────
cd "$INSTALL_DIR"
chmod +x setup.sh
./setup.sh
