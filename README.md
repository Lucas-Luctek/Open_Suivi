# Postulo — Suivi de recherche d'emploi

![Licence](https://img.shields.io/badge/licence-GPL%20v3-blue)
![Python](https://img.shields.io/badge/python-3.10%2B-blue)
![Flask](https://img.shields.io/badge/flask-2.3%2B-green)

**Postulo** est un logiciel libre de suivi de recherche d'emploi, auto-hébergé, développé en Python/Flask avec SQLite.  
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
bash <(curl -fsSL https://raw.githubusercontent.com/VOTRE_USERNAME/postulo/main/install.sh)
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
git clone https://github.com/VOTRE_USERNAME/postulo.git
cd postulo
chmod +x setup.sh && sudo ./setup.sh
```

### Accès après installation

```
http://IP_DU_SERVEUR:5050
Login : admin / (mot de passe choisi)
```

---

## Configuration

Le fichier `.env` (créé automatiquement depuis `.env.example`) :

| Variable | Description | Défaut |
|---|---|---|
| `SECRET_KEY` | Clé secrète Flask (auto-générée) | — |
| `COMPANY_NAME` | Nom de l'application | Postulo |
| `PORT` | Port d'écoute | 5050 |
| `FLASK_DEBUG` | Mode debug (false en prod) | false |

La clé API OpenAI se configure dans l'interface : **Admin → Personnalisation**.

---

## Commandes utiles

```bash
# Statut du service
systemctl status postulo

# Redémarrer
systemctl restart postulo

# Logs en direct
journalctl -u postulo -f

# Sauvegarde manuelle
python3 backup.py
```

---

## Structure du projet

```
postulo/
├── app.py              # Application Flask principale
├── backup.py           # Sauvegarde automatique de la BDD
├── requirements.txt    # Dépendances Python
├── setup.sh            # Script d'installation
├── install.sh          # Bootstrap (clone + setup)
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
