# OpenSuivi — Suivi de recherche d'emploi

![Licence](https://img.shields.io/badge/licence-GPL%20v3-blue)
![Python](https://img.shields.io/badge/python-3.10%2B-blue)
![Flask](https://img.shields.io/badge/flask-2.3%2B-green)
[![Discord](https://img.shields.io/discord/1365734614434988133?label=Discord&logo=discord&logoColor=white&color=5865F2)](https://discord.gg/n24gDGYyPH)

**OpenSuivi** est un logiciel libre de suivi de recherche d'emploi, auto-hébergé, développé en Python/Flask avec SQLite.  
Multi-utilisateurs, assisté par IA (GPT-4o-mini), installable comme une vraie application mobile (PWA).

---

## Fonctionnalités

**Gestion des candidatures**
- Liste paginée avec filtres (statut, type de contrat, secteur, ville, tag, texte libre)
- Fiche candidature complète : entreprise, poste, contrat, dates, notes, historique
- Statuts : Envoyée → Relance → Entretien → Offre → Refus / Désistement
- Remplissage automatique depuis une URL ou un texte collé (via GPT-4o-mini)
- Badge date limite imminente (≤ 3 jours), badge relances en retard
- Import de CV et lettre de motivation par candidature (PDF, DOC, DOCX)
- Export PDF, export Excel (.xlsx), export CSV

**Outils IA (clé OpenAI requise)**
- Générateur de lettre de motivation personnalisée
- Suggestions de questions d'entretien probables
- Score de compatibilité profil / offre (0–100)

**Agenda & relances**
- Calendrier mensuel (FullCalendar)
- Abonnement iCal par utilisateur (iPhone, Google Calendar, Outlook)
- Badge compteur relances en retard dans la navbar

**Multi-utilisateurs**
- Inscription avec approbation admin
- Données 100 % isolées par utilisateur
- Profil de recherche personnel (type de contrat, niveau, localisation, etc.)
- Promotion / rétrogradation admin depuis l'interface

**Application mobile (PWA)**
- Installable sur iPhone, Android et desktop depuis le navigateur
- Fonctionne hors ligne (service worker)
- Interface mobile optimisée (cartes, touch-friendly)

**Administration**
- Personnalisation : nom de l'app, logo, favicon, couleurs
- Gestion des utilisateurs (approbation, réinitialisation mot de passe, promotion admin)
- Sauvegarde BDD manuelle et automatique (chaque nuit à 2h)
- Journaux de connexion

---

## Stack technique

| Composant | Technologie |
|---|---|
| Backend | Python 3.10+ / Flask |
| Base de données | SQLite |
| Templates | Jinja2 |
| CSS | Vanilla CSS (variables, dark mode) |
| IA | OpenAI GPT-4o-mini |
| PDF | WeasyPrint |
| Agenda | FullCalendar (CDN) |
| Graphiques | Chart.js (CDN) |
| PWA | Service Worker + Web App Manifest |

---

## Installation

### Pré-requis

- Debian 12 ou Ubuntu 22.04+
- Accès root ou sudo
- Connexion internet

### Installation en une commande

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Lucas-Luctek/Open_Suivi/main/install.sh)
```

Le script :
1. Installe git et les dépendances système
2. Clone le dépôt
3. Crée l'environnement Python virtuel
4. Installe les dépendances Python
5. Configure le fichier `.env` (clé secrète auto-générée)
6. Initialise la base de données
7. Crée et démarre le service systemd

Vous serez invité à choisir un **mot de passe admin** et un **port** (5050 par défaut).

### Installation manuelle

```bash
git clone https://github.com/Lucas-Luctek/Open_Suivi.git
cd opensuivi
chmod +x setup.sh && sudo ./setup.sh
```

### Accès après installation

```
http://IP_DU_SERVEUR:5050
Login : admin / (mot de passe choisi)
```

---

## Installation avec Docker

### Pré-requis

- [Docker](https://docs.docker.com/engine/install/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) v2+

### Démarrage rapide

```bash
git clone https://github.com/Lucas-Luctek/Open_Suivi.git
cd Open_Suivi
docker compose up -d
```

L'application est accessible sur : `http://IP_DU_SERVEUR:5050`  
Login par défaut : **admin / admin123** (à changer immédiatement dans le profil)

### Choisir le port

**Via fichier `.env`** (recommandé) :

```bash
cp .env.example .env
# Éditer .env et changer PORT=8080
docker compose up -d
```

**À la volée** :

```bash
PORT=8080 docker compose up -d
```

### Données persistantes

Les données sont stockées dans des volumes Docker gérés automatiquement :

| Volume | Contenu |
|---|---|
| `opensuivi_data` | Base de données + uploads + sauvegardes |
| `opensuivi_static` | Logo et favicon personnalisés |

Rien n'est perdu lors d'un redémarrage ou d'une mise à jour.

### Mise à jour (Docker)

```bash
sudo bash docker-update.sh
```

Le script sauvegarde automatiquement la base de données, récupère le code, reconstruit l'image et redémarre le service.

### HTTPS avec Nginx (production / PWA)

Pour activer HTTPS (requis pour installer l'app en PWA) :

1. Éditer `nginx/opensuivi.conf` et remplacer `votre-domaine.fr` par votre domaine
2. Obtenir le certificat SSL :

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot \
  certonly --webroot --webroot-path /var/www/certbot \
  --email votre@email.fr --agree-tos --no-eff-email \
  -d votre-domaine.fr
```

3. Démarrer avec Nginx :

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Commandes Docker utiles

```bash
# Voir les logs en direct
docker compose logs -f

# Arrêter
docker compose down

# Redémarrer
docker compose restart

# Sauvegarde manuelle de la BDD
docker compose exec opensuivi python3 backup.py
```

---

## Configuration

Le fichier `.env` (créé automatiquement depuis `.env.example`) :

| Variable | Description | Défaut |
|---|---|---|
| `SECRET_KEY` | Clé secrète Flask (auto-générée) | — |
| `COMPANY_NAME` | Nom de l'application | OpenSuivi |
| `PORT` | Port d'écoute | 5050 |
| `FLASK_DEBUG` | Mode debug (false en prod) | false |

La clé API OpenAI se configure dans l'interface : **Admin → Personnalisation**.

---

## Mise à jour

Pour mettre à jour OpenSuivi vers la dernière version :

```bash
cd ~/opensuivi
sudo bash update.sh
```

Le script de mise à jour :
1. **Sauvegarde automatiquement** la base de données avant toute modification
2. Récupère le dernier code depuis GitHub (`git pull`)
3. Met à jour les dépendances Python si nécessaire
4. Redémarre le service et vérifie qu'il tourne correctement

En cas de problème, la sauvegarde est dans `backups/` et la commande de restauration est affichée à la fin du script.

---

## Commandes utiles

```bash
# Statut du service
systemctl status opensuivi

# Redémarrer
systemctl restart opensuivi

# Logs en direct
journalctl -u opensuivi -f

# Sauvegarde manuelle
python3 backup.py
```

---

## Structure du projet

```
opensuivi/
├── app.py              # Application Flask principale
├── backup.py           # Sauvegarde automatique de la BDD
├── requirements.txt    # Dépendances Python
├── setup.sh            # Script d'installation
├── install.sh          # Bootstrap (clone + setup)
├── update.sh           # Script de mise à jour
├── .env.example        # Modèle de configuration
├── static/
│   ├── style.css       # Feuille de style globale
│   ├── favicon.svg     # Icône par défaut
│   └── sw.js           # Service Worker (PWA)
├── templates/          # Vues HTML (Jinja2)
├── uploads/            # Pièces jointes (créé automatiquement)
└── backups/            # Sauvegardes automatiques
```

---

## Licence

[GPL v3](LICENSE) — Libre d'utilisation, de modification et de redistribution.  
Toute redistribution doit rester sous la même licence open source.
