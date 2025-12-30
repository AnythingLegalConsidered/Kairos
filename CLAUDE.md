# CLAUDE.md - Guide pour Claude Code

> Ce fichier est lu automatiquement par Claude Code pour comprendre le projet Kairos.

## Vue d'ensemble du projet

**Kairos** est une plateforme de veille technologique intelligente qui :
- Agrege des articles via des flux RSS
- Les traite avec une IA locale (Ollama/Gemma) pour resume, pertinence et tags
- Permet de filtrer, rechercher et exporter les articles

**Stack technique** : Vanilla JS (frontend) + Supabase (backend) + n8n (orchestration) + Ollama (IA locale)

## Architecture

```
Frontend (Vanilla JS)  -->  Supabase (PostgreSQL + Auth + REST API)
                                      |
                                      v
                              n8n (Workflows)  -->  Ollama (Gemma 3:4b)
```

## Structure du projet

```
Kairos/
├── CLAUDE.md           # CE FICHIER - Instructions pour Claude Code
├── docker/             # Infrastructure Docker (docker-compose, kong, nginx)
├── supabase/           # Backend: migrations SQL, fonctions Edge, config
├── n8n/                # Workflows d'orchestration et prompts IA
├── web/                # Frontend: pages HTML, CSS, JS (Vanilla)
├── scripts/            # Scripts utilitaires (setup, tests, maintenance)
├── docs/               # Documentation technique et rapports de tests
├── PLAN_PROJET.md      # Plan detaille du projet avec phases et changelog
└── ROADMAP.md          # Evolutions futures planifiees (v0.2 a v1.0)
```

## Conventions de code

### Frontend (web/)
- **Vanilla JS uniquement** - Pas de framework (React, Vue, etc.)
- **Un fichier HTML par page** avec JS inline ou modules separes
- **CSS partage** dans `style.css` + variables CSS pour le theming
- **Supabase client** via CDN, configure dans `config.js`

### Backend (supabase/)
- **PostgreSQL 15** avec extensions uuid-ossp et pg_trgm
- **Row Level Security (RLS)** sur toutes les tables - isolation par user_id
- **Migrations numerotees** : `001_*.sql`, `002_*.sql`, etc.
- **Fonctions RPC** pour les operations complexes (voir `003_functions.sql`)

### Workflows (n8n/)
- **JSON exports** des workflows n8n
- **Prompts IA** centralises dans `prompts.json`
- **Variables d'environnement** : utiliser `{{ $env.VAR_NAME }}`

## Base de donnees - Tables principales

| Table | Description | Cle |
|-------|-------------|-----|
| `topics` | Sujets de veille avec mots-cles et feeds RSS | user_id |
| `articles` | Articles recuperes et analyses par l'IA | topic_id |
| `rss_sources` | Catalogue global de sources RSS | - |
| `user_preferences` | Preferences utilisateur (theme, notifs) | user_id |
| `notification_logs` | Historique des notifications envoyees | - |

## Types PostgreSQL

```sql
sentiment_type: 'positive' | 'neutral' | 'negative'
read_status_type: 'unread' | 'read' | 'archived'
source_category: 'technology' | 'science' | 'business' | 'security' | 'ai_ml' | 'programming' | 'design' | 'startup' | 'other'
```

## Commandes utiles

### Demarrer l'environnement
```bash
cd docker && docker-compose up -d
```

### Acces aux services
- Frontend: http://localhost:3000
- Supabase Studio: http://localhost:3002
- n8n: http://localhost:5678 (admin/kairos2024)
- API REST: http://localhost:8000
- Ollama: http://localhost:11434

### Scripts disponibles (scripts/)
```bash
./setup.sh          # Premier lancement (telecharge Gemma ~3.3 Go)
./start.sh          # Demarrer les services
./stop.sh           # Arreter les services
./reset.sh          # Reset complet de la base
./import-workflows.sh  # Importer les workflows n8n
```

## Workflows n8n

| Workflow | Declenchement | Action |
|----------|---------------|--------|
| RSS Processor | Cron 1h + Webhook | Fetch RSS -> Parse -> IA -> Save |
| Cleanup | Cron 3h | Supprime articles > 30 jours |
| Notifications | Cron 8h | Digest email (desactive par defaut) |

## Regles pour Claude Code

### Lors de la creation de fichiers
- **Toujours ajouter un commentaire en tete** expliquant le role du fichier
- Format: `// fichier.js - Description courte du role`

### Lors de modifications SQL
- **Creer une nouvelle migration** numerotee (ex: `005_new_feature.sql`)
- **Ne jamais modifier** les migrations existantes en production
- **Tester les politiques RLS** avec `scripts/test-rls.sql`

### Lors de modifications frontend
- **Respecter le design existant** - Theme "Papier & Encre"
- **Utiliser les variables CSS** definies dans `style.css`
- **Tester le mode sombre** (toggle dans le header)

### Lors de modifications n8n
- **Exporter le workflow** en JSON apres modification
- **Documenter les changements** dans `n8n/README.md`

## Variables d'environnement cles

```bash
# Supabase
JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# n8n
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=kairos2024

# Ports
FRONTEND_PORT=3000
KONG_HTTP_PORT=8000
N8N_PORT=5678
OLLAMA_PORT=11434
```

## Points d'attention

1. **RLS actif** - Toutes les requetes doivent inclure le JWT utilisateur
2. **Ollama local** - Le modele Gemma 3:4b doit etre telecharge (3.3 Go)
3. **Pas de hot-reload n8n** - Les workflows JSON ne se synchronisent pas automatiquement
4. **Supabase local** - Les cles JWT sont des cles de demo, pas pour la production

## Liens vers documentation detaillee

- Architecture complete: [PLAN_PROJET.md](./PLAN_PROJET.md)
- Evolutions futures: [ROADMAP.md](./ROADMAP.md)
- Tests et rapports: [docs/TESTS.md](./docs/TESTS.md)
- Workflows n8n: [n8n/README.md](./n8n/README.md)
