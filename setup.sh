#!/bin/bash
# ============================================================
# OpenSuivi — Script d'installation
# Testé sur Debian 12 / Ubuntu 22.04+
# ============================================================

set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║         Installation de OpenSuivi       ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Mot de passe admin ───────────────────────────────────
echo "─── Compte administrateur ───"
while true; do
    read -s -p "Choisissez le mot de passe admin (min. 6 caractères) : " ADMIN_PASS
    echo ""
    if [ ${#ADMIN_PASS} -lt 6 ]; then
        echo "  Mot de passe trop court, réessayez."
        continue
    fi
    read -s -p "Confirmez le mot de passe : " ADMIN_PASS2
    echo ""
    if [ "$ADMIN_PASS" != "$ADMIN_PASS2" ]; then
        echo "  Les mots de passe ne correspondent pas, réessayez."
    else
        break
    fi
done
echo "  ✓ Mot de passe enregistré."
echo ""

# ── 2. Port ─────────────────────────────────────────────────
echo "─── Port de l'application ───"
read -p "Port d'écoute [5050 par défaut] : " APP_PORT
APP_PORT=${APP_PORT:-5050}
echo "  ✓ Port : $APP_PORT"
echo ""

# ── 3. Python 3 ─────────────────────────────────────────────
echo "─── Vérification de Python 3 ───"
if ! command -v python3 &>/dev/null; then
    echo "  Python3 non trouvé. Installation..."
    apt-get update -qq && apt-get install -y python3
fi
PYTHON_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
apt-get install -y "python${PYTHON_VER}-venv" -qq
echo "  ✓ $(python3 --version)"
echo ""

# ── 4. Bibliothèques système (WeasyPrint) ───────────────────
echo "─── Bibliothèques système ───"
apt-get install -y -qq \
    libpango-1.0-0 libpangoft2-1.0-0 libpangocairo-1.0-0 \
    libcairo2 libffi-dev shared-mime-info fonts-liberation
apt-get install -y -qq libgdk-pixbuf-2.0-0 2>/dev/null || \
apt-get install -y -qq libgdk-pixbuf2.0-0 2>/dev/null || true
echo "  ✓ Bibliothèques installées."
echo ""

# ── 5. Environnement virtuel ────────────────────────────────
echo "─── Environnement virtuel ───"
if [ ! -f "venv/bin/activate" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
echo "  ✓ Environnement virtuel prêt."
echo ""

# ── 6. Dépendances Python ───────────────────────────────────
echo "─── Installation des dépendances Python ───"
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "  ✓ Dépendances installées."
echo ""

# ── 7. Fichier .env ─────────────────────────────────────────
echo "─── Configuration ───"
if [ ! -f ".env" ]; then
    cp .env.example .env
fi
SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
sed -i "s/changez-cette-cle-en-production-svp/$SECRET/" .env
if grep -q "^PORT=" .env; then
    sed -i "s/^PORT=.*/PORT=$APP_PORT/" .env
else
    echo "PORT=$APP_PORT" >> .env
fi
echo "  ✓ Fichier .env configuré."
echo ""

# ── 8. Initialisation de la base de données ─────────────────
echo "─── Initialisation de la base de données ───"
python3 - <<PYEOF
import sys, os
if os.path.exists('.env'):
    for line in open('.env'):
        line = line.strip()
        if line and not line.startswith('#') and '=' in line:
            k, v = line.split('=', 1)
            os.environ.setdefault(k.strip(), v.strip())
from app import init_db
import sqlite3
from werkzeug.security import generate_password_hash
init_db()
conn = sqlite3.connect('opensuivi.db')
c = conn.cursor()
hashed = generate_password_hash('${ADMIN_PASS}')
c.execute("UPDATE users SET password = ? WHERE username = 'admin'", (hashed,))
conn.commit()
conn.close()
print("  ✓ Base de données initialisée.")
PYEOF

# ── 9. Service systemd ──────────────────────────────────────
echo "─── Service systemd ───"
INSTALL_DIR="$(pwd)"
cat > /etc/systemd/system/opensuivi.service <<EOF
[Unit]
Description=OpenSuivi — Suivi de recherche d'emploi
After=network.target

[Service]
User=root
WorkingDirectory=${INSTALL_DIR}
EnvironmentFile=${INSTALL_DIR}/.env
ExecStart=${INSTALL_DIR}/venv/bin/python3 ${INSTALL_DIR}/app.py
Restart=always
RestartSec=5
SyslogIdentifier=opensuivi
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable opensuivi --quiet
systemctl restart opensuivi
echo "  ✓ Service OpenSuivi démarré et activé au démarrage."

# ── 10. Rotation des logs journald ─────────────────────────
echo "─── Rotation des logs ───"
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/opensuivi.conf <<'JEOF'
[Journal]
SystemMaxUse=200M
SystemMaxFileSize=50M
MaxFileSec=2month
JEOF
systemctl restart systemd-journald 2>/dev/null || true
echo "  ✓ Journaux limités à 200 Mo, rotation toutes les 2 mois."
echo ""

echo "╔══════════════════════════════════════════════════╗"
echo "║           Installation terminée !                ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                  ║"
echo "║  Commandes utiles :                              ║"
echo "║    systemctl status opensuivi                      ║"
echo "║    systemctl restart opensuivi                     ║"
echo "║    journalctl -u opensuivi -f                      ║"
echo "║                                                  ║"
printf "║  Accès : http://%-32s║\n" "$(hostname -I | awk '{print $1}'):$APP_PORT"
echo "║  Login  : admin  /  (mot de passe choisi)        ║"
echo "║                                                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
