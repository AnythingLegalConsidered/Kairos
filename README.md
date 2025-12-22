# Kairos - Plateforme de Veille Intelligente

Kairos est une plateforme de veille technologique permettant de surveiller des sujets via des flux RSS, avec traitement IA pour résumer, catégoriser et noter la pertinence des articles.

## Fonctionnalités (v0.1.0 MVP)

- **Gestion de topics** : Créez des sujets de veille avec mots-clés et flux RSS
- **Agrégation RSS** : Collecte automatique des articles depuis vos sources
- **Traitement IA** : Résumé, score de pertinence et analyse de sentiment via Gemma 3:4b
- **Dashboard** : Interface pour consulter, filtrer et gérer vos articles
- **Export** : Exportez vos articles en CSV ou JSON
- **Mode sombre** : Interface adaptée à vos préférences

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     FRONTEND (Vanilla JS)                        │
│  dashboard.html | topic-setup.html | article-detail.html         │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SUPABASE (Backend)                          │
│  PostgreSQL | Auth (GoTrue) | REST API (PostgREST)               │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      N8N (Orchestration)                         │
│  RSS Processor | Cleanup | Notifications                         │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      OLLAMA (IA locale)                          │
│  Gemma 3:4b - Résumé, Pertinence, Sentiment                      │
└─────────────────────────────────────────────────────────────────┘
```

## Prérequis

- Docker & Docker Compose
- 8 Go de RAM minimum (pour Ollama + Gemma)
- 10 Go d'espace disque

## Installation

### 1. Cloner le repository

```bash
git clone https://github.com/votre-username/kairos.git
cd kairos
```

### 2. Configuration

```bash
# Copier le fichier d'environnement
cp docker/.env.example docker/.env

# Modifier les variables selon vos besoins
# (optionnel pour le développement local)
```

### 3. Lancement

**Linux/Mac:**
```bash
./scripts/setup.sh   # Premier lancement (télécharge Gemma ~3.3 Go)
./scripts/start.sh   # Lancements suivants
```

**Windows:**
```batch
scripts\setup.bat    # Premier lancement
scripts\start.bat    # Lancements suivants
```

### 4. Accès

- **Frontend** : http://localhost:8080
- **Supabase Studio** : http://localhost:3000
- **n8n** : http://localhost:5678

## Structure du projet

```
kairos/
├── docker/              # Configuration Docker
│   ├── docker-compose.yml
│   ├── .env.example
│   └── nginx/
├── supabase/            # Backend Supabase
│   ├── migrations/      # Schéma SQL
│   ├── functions/       # Edge Functions
│   └── seed.sql
├── n8n/                 # Workflows n8n
│   └── workflows/
├── web/                 # Frontend
├── scripts/             # Scripts utilitaires
└── docs/                # Documentation
```

## Workflows n8n

1. **RSS Processor** : Récupère les articles, les déduplique et les traite avec l'IA
2. **Cleanup** : Supprime les anciens articles (configuré à 30 jours)
3. **Notifications** : Alerte sur les articles à haute pertinence

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Frontend | HTML/CSS/JS (Vanilla) |
| Backend | Supabase (PostgreSQL + Auth) |
| Orchestration | n8n |
| IA | Ollama + Gemma 3:4b |
| Conteneurisation | Docker |

## Documentation

- [Plan du projet](PLAN_PROJET.md)
- [Tests](docs/TESTS.md)
- [Rapport de tests](docs/RAPPORT_TESTS.md)

## Roadmap

- [x] Phase 1-6 : MVP local fonctionnel
- [ ] Phase 7 : Déploiement cloud (Supabase Cloud, n8n Cloud, HuggingFace API)
- [ ] PWA et mode hors-ligne

## Licence

MIT

---

*Projet réalisé dans le cadre d'un projet scolaire*
