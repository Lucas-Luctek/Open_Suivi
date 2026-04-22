# Contexte du projet — Postulo (Suivi Recherche d'Emploi)

## Ce qu'est ce projet
Postulo est un logiciel libre de suivi de recherche d'emploi, auto-hébergé, développé en Python/Flask + SQLite.
Transformé à partir d'un CRM open source (Open_CRM), puis entièrement repensé pour la recherche d'emploi.
Multi-utilisateurs : chaque utilisateur a son propre suivi privé, l'admin gère les comptes.

## Stack technique
- Backend : Python / Flask
- Base de données : SQLite (fichier local `postulo.db`)
- Frontend : HTML/CSS/JS (templates Jinja2, pas de framework JS)
- Déploiement : Debian Linux, service systemd (`systemctl restart postulo`) — port **5050**
- Reverse proxy : Nginx (gère le HTTPS)
- Librairies : **APScheduler**, **WeasyPrint**, **openai**, **requests**, **beautifulsoup4**, **icalendar**, **openpyxl**

## Fichiers principaux
- `app.py` → logique principale Flask (~2400 lignes)
- `backup.py` → système de sauvegarde automatique
- `setup.sh` → script d'installation automatique
- `install.sh` → bootstrap (clone + setup depuis une VM vierge)
- `requirements.txt` → dépendances Python
- `templates/` → vues HTML (Jinja2)
- `static/` → style.css, favicon.svg, sw.js (service worker PWA)
- `uploads/` → pièces jointes + CV/LM des candidatures
- `backups/` → sauvegardes automatiques de postulo.db

## Méthode de travail — IMPORTANT
- On travaille **étape par étape**, une seule fonctionnalité à la fois
- Je fais des **snapshots VM** avant chaque grosse modification
- Redémarrer le serveur : `systemctl restart postulo`
- Vérifier les logs : `journalctl -u postulo -n 50`
- Le serveur tourne sur le **port 5050** (Nginx fait le proxy HTTPS)
- Ne jamais modifier plusieurs fichiers critiques en même temps

## Fonctionnalités implémentées (v1.0)

### Candidatures (`/base`)
- ✅ Liste paginée avec filtres (secteur, statut, type contrat, ville, tag, texte)
- ✅ Tri cliquable sur colonnes (entreprise, statut, relance, date envoi)
- ✅ Interface mobile : cartes (tableau masqué sur petit écran) avec date, statut, relance
- ✅ Badge rouge si date limite candidature dans ≤ 3 jours
- ✅ Détection de doublons en temps réel
- ✅ Remplissage automatique depuis URL/texte (GPT-4o-mini)
- ✅ Note rapide, archivage réversible (corbeille)
- ✅ Tags libres, pièces jointes par intervention, export PDF

### Fiche candidature (`/prospect/<id>`)
- ✅ Toutes les infos du poste (entreprise, poste, contrat, ville, dates, formation, référence)
- ✅ Import CV & lettre de motivation par candidature (PDF/DOC/DOCX, table `prospect_documents`)
- ✅ Outils IA : générateur LM, questions d'entretien, score de compatibilité
- ✅ Notes d'entretien structurées (champ texte libre)
- ✅ Tags, historique des contacts, historique des statuts, pièces jointes

### Statuts de candidature
`Candidature envoyée` → `Relance effectuée` → `Entretien téléphonique` → `Entretien présentiel` → `Test technique` → `Offre reçue` → `Refus` → `Désistement`

### Dashboard (`/`)
- ✅ KPIs : total, CV envoyés, entretiens, offres, taux de réponse
- ✅ Relances du jour / en retard
- ✅ Graphiques : répartition par statut et secteur

### Statistiques (`/stats`)
- ✅ KPIs avancés, graphiques barres, histogramme activité 12 semaines
- ✅ Export Excel + CSV

### Agenda (`/calendrier`)
- ✅ Vue mensuelle FullCalendar
- ✅ Abonnement iCal per-user (`webcal://` → iPhone / Google Calendar / Outlook)
- ✅ Token UUID unique par user dans `users.ical_token`

### Kanban (`/kanban`)
- ✅ Pipeline visuel par statut, drag & drop

### Multi-utilisateurs
- ✅ Inscription publique avec approbation admin
- ✅ Données 100% isolées par `user_id`
- ✅ Profil de recherche per-user (`user_settings`)
- ✅ Promotion / rétrogradation admin depuis l'interface
- ✅ Approved=0 → connexion impossible jusqu'à approbation

### PWA / Mobile
- ✅ Manifest dynamique (`/manifest.json`) — prend nom + couleur depuis admin
- ✅ Service Worker (`/sw.js`) — cache-first assets, network-first pages, fallback offline
- ✅ Page offline (`/offline`)
- ✅ Balises Apple + Android dans tous les templates
- ✅ Installable sur iPhone, Android, desktop (HTTPS via Nginx)
- ✅ Interface mobile : cartes dans la liste, boutons touch-friendly, font-size 16px

### Administration (`/admin`)
- ✅ Utilisateurs : approbation, reset mdp, promotion/rétrogradation, suppression
- ✅ Personnalisation : nom app, logo, favicon, couleurs, clé OpenAI
- ✅ Danger : téléchargement backup BDD, reset complet
- ✅ Journaux de connexion

### Sécurité
- ✅ Rate limiting login (5 tentatives / 5 min)
- ✅ CSRF sur tous les POST
- ✅ Isolation données par user_id sur toutes les requêtes
- ✅ Vérification propriété sur toutes les opérations par ID
- ✅ APScheduler : sauvegarde auto BDD à 2h du matin

---

## Architecture base de données (SQLite)

### Table `prospects`
| Colonne | Type | Description |
|---|---|---|
| id | INTEGER PK | Identifiant |
| user_id | INTEGER FK | Propriétaire |
| etablissement | TEXT | Nom de l'entreprise |
| contact | TEXT | Contact RH |
| telephone / email | TEXT | Coordonnées |
| adresse / code_postal / ville | TEXT | Localisation |
| categorie | TEXT | Secteur d'activité |
| statut | TEXT | Statut candidature |
| poste | TEXT | Intitulé du poste |
| type_contrat | TEXT | CDI / CDD / Stage / Alternance / Freelance |
| plateforme | TEXT | LinkedIn / Indeed / France Travail / Direct / Autre |
| mode_candidature | TEXT | Via plateforme / email / courrier / Direct |
| cv_envoye / lettre_envoyee | INTEGER | 0/1 |
| lien_offre | TEXT | URL de l'offre |
| reference_offre | TEXT | Référence offre |
| date_limite_candidature | DATE | Date limite pour postuler |
| date_debut | DATE | Date de début |
| duree_contrat | TEXT | Durée (ex : 2 ans) |
| formation_requise | TEXT | Niveau requis |
| commentaire | TEXT | Résumé de l'offre |
| notes_entretien | TEXT | Notes d'entretien |
| date_relance | DATE | Prochaine relance |
| date_ajout | TIMESTAMP | Date de création |
| archived | INTEGER | 0/1 — corbeille |

### Table `users`
| Colonne | Type | Description |
|---|---|---|
| id | INTEGER PK | Identifiant |
| username | TEXT UNIQUE | Nom d'utilisateur |
| password | TEXT | Hash Werkzeug |
| role | TEXT | admin / commercial |
| approved | INTEGER | 0=en attente, 1=approuvé |
| signature | TEXT | Signature optionnelle |
| ical_token | TEXT | Token UUID iCal |

### Autres tables
- `user_settings(user_id, key, value)` — profil recherche per-user
- `settings(key, value)` — paramètres globaux (company_name, couleurs, logo, openai_api_key)
- `interventions` — historique contacts par candidature
- `historique_statut` — traçabilité changements de statut
- `logs` — journal connexions/actions
- `evenements_perso` — événements agenda
- `tags` + `prospect_tags` — tags libres
- `intervention_attachments` — pièces jointes interventions
- `prospect_documents` — CV/LM par candidature (doc_type: 'cv' ou 'lm')

---

## Clé API OpenAI
- Stockée dans `settings` (globale, admin uniquement)
- Accessible via `get_openai_key()`
- Utilisée par : `/api/extract-offre`, `/api/generer-lm`, `/api/questions-entretien`, `/api/score-compat`
- Modèle utilisé : GPT-4o-mini

## Remplissage automatique des candidatures
- Champ URL ou texte → bouton "Analyser l'offre" → AJAX `/api/extract-offre`
- Flask scrape l'URL, supprime select/option/scripts, envoie ≤ 12 000 chars à GPT
- GPT extrait : entreprise, poste, ville, contrat, secteur, plateforme, référence, dates, etc.
- LinkedIn bloque le scraping → utiliser le mode texte (copier-coller)
