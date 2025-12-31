# supabase/ - Backend Supabase

> Configuration et schema de la base de donnees PostgreSQL avec Row Level Security.
>
> **Version:** 0.5.0 | **Derniere MAJ:** 31/12/2024

## En un coup d'oeil

- **7 migrations** : Schema initial -> Kanban (v0.5)
- **6 tables** : topics, articles, rss_sources, user_preferences, user_favorite_sources, user_tag_preferences
- **10+ fonctions RPC** : Stats, tendances, similaires, kanban
- **RLS actif** : Isolation stricte par user_id
- **114 sources RSS** : Catalogue pre-rempli (seed.sql)

## Structure

```
supabase/
├── config.toml              # Configuration Supabase CLI
├── seed.sql                 # Donnees initiales (114 sources RSS)
├── migrations/              # Migrations SQL numerotees
│   ├── 001_initial_schema.sql    # Tables principales (topics, articles)
│   ├── 002_rls_policies.sql      # Politiques de securite RLS
│   ├── 003_functions.sql         # Fonctions et triggers PostgreSQL
│   ├── 004_notification_logs.sql # Table logs notifications
│   ├── 005_source_library.sql    # Favoris + suggestions (v0.3)
│   ├── 006_intelligence.sql      # Tendances + highlights (v0.4)
│   └── 007_kanban_reading.sql    # Statut reading + fonctions (v0.5)
└── functions/               # Edge Functions Deno
    ├── trigger-n8n/         # Declenche le workflow RSS
    └── cleanup-articles/    # Nettoie les vieux articles
```

## Schema de la base de donnees

### Tables principales

```
┌─────────────────┐     ┌─────────────────┐
│     topics      │     │   rss_sources   │
├─────────────────┤     ├─────────────────┤
│ id (PK)         │     │ id (PK)         │
│ user_id (FK)    │     │ name            │
│ name            │     │ url (UNIQUE)    │
│ keywords_fr[]   │     │ category        │
│ keywords_en[]   │     │ language        │
│ rss_feeds[]     │     │ active          │
│ active          │     └─────────────────┘
└────────┬────────┘
         │ 1:N
         v
┌─────────────────┐     ┌─────────────────────┐
│    articles     │     │  user_preferences   │
├─────────────────┤     ├─────────────────────┤
│ id (PK)         │     │ id (PK)             │
│ topic_id (FK)   │     │ user_id (FK,UNIQUE) │
│ title           │     │ theme               │
│ content         │     │ email_digest        │
│ summary (IA)    │     │ notify_high_relevance│
│ url (UNIQUE/topic)    └─────────────────────┘
│ relevance_score │
│ sentiment       │
│ tags[]          │
│ read_status     │
│ bookmarked      │
└─────────────────┘
```

### Types ENUM

```sql
sentiment_type:    'positive' | 'neutral' | 'negative'
read_status_type:  'unread' | 'read' | 'archived' | 'reading' (v0.5)
source_category:   'technology' | 'science' | 'business' | 'security'
                   | 'ai_ml' | 'programming' | 'design' | 'startup' | 'other'
```

### Colonnes ajoutees par version

| Version | Table | Colonnes |
|---------|-------|----------|
| v0.2 | articles | `tags[]` |
| v0.3 | - | `user_favorite_sources` (nouvelle table) |
| v0.4 | articles | `highlights[]` |
| v0.4 | - | `user_tag_preferences` (nouvelle table) |
| v0.5 | articles | `read_status = 'reading'` (nouveau statut) |

## Row Level Security (RLS)

Toutes les tables ont RLS active. Les politiques garantissent :

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| topics | own | own | own | own |
| articles | via topic owner | via topic owner | via topic owner | via topic owner |
| rss_sources | all | service_role | service_role | service_role |
| user_preferences | own | own | own | own |

**"own"** = `user_id = auth.uid()` ou via topic appartenant a l'utilisateur

## Fonctions RPC disponibles

### Core (v0.1)

| Fonction | Description | Params |
|----------|-------------|--------|
| `get_active_topics_with_feeds()` | Topics actifs avec leurs feeds | - |
| `get_user_stats(p_user_id)` | Statistiques utilisateur | UUID |
| `cleanup_old_articles(days_to_keep)` | Supprime vieux articles | INTEGER |
| `search_articles(search_query, p_topic_id)` | Recherche full-text | TEXT, UUID |
| `get_topic_stats(p_topic_id)` | Stats d'un topic | UUID |

### Sources (v0.3)

| Fonction | Description | Params |
|----------|-------------|--------|
| `suggest_sources(keywords, lang, max)` | Suggestions par mots-cles | TEXT[], TEXT, INT |

### Intelligence (v0.4)

| Fonction | Description | Params |
|----------|-------------|--------|
| `get_trending_tags(hours_ago)` | Tags trending sur N heures | INT (default 24) |
| `get_similar_articles(article_id, max)` | Articles similaires par tags | UUID, INT |
| `get_user_top_tags(p_user_id, max)` | Tags preferes utilisateur | UUID, INT |

### Kanban (v0.5)

| Fonction | Description | Params |
|----------|-------------|--------|
| `get_kanban_articles(p_topic_id)` | Articles groupes par statut | UUID |
| `move_article_status(p_article_id, p_new_status)` | Deplacer article | UUID, TEXT |

## Edge Functions

### trigger-n8n
- **But** : Declencher le workflow RSS Processor
- **Endpoint** : POST /functions/v1/trigger-n8n
- **Auth** : JWT requis

### cleanup-articles
- **But** : Supprimer les articles expires
- **Endpoint** : POST /functions/v1/cleanup-articles
- **Auth** : Service Role requis

## Migrations

### Creer une nouvelle migration

```bash
# Nommer avec le prochain numero
# Format: NNN_description_courte.sql
touch migrations/005_new_feature.sql
```

### Contenu type d'une migration

```sql
-- =============================================================================
-- KAIROS - Description de la migration
-- =============================================================================
-- Migration: 005_new_feature.sql
-- Description: Ajoute la fonctionnalite X
-- =============================================================================

-- Vos modifications SQL ici
ALTER TABLE articles ADD COLUMN new_field TEXT;

-- Index si necessaire
CREATE INDEX idx_articles_new_field ON articles(new_field);
```

## Commandes utiles

```bash
# Se connecter a PostgreSQL
docker exec -it kairos-db psql -U postgres

# Executer une migration manuellement
docker exec -i kairos-db psql -U postgres < migrations/005_new_feature.sql

# Tester les politiques RLS
docker exec -i kairos-db psql -U postgres < ../scripts/test-rls.sql

# Reset complet de la base
docker exec -i kairos-db psql -U postgres < ../scripts/init-db.sql
```

## Acces

- **PostgreSQL direct** : localhost:5432 (postgres/postgres)
- **Supabase Studio** : http://localhost:3002
- **API REST (PostgREST)** : http://localhost:8000/rest/v1/
- **Auth (GoTrue)** : http://localhost:8000/auth/v1/
