# supabase/ - Backend Supabase

> Configuration et schema de la base de donnees PostgreSQL avec Row Level Security.

## Structure

```
supabase/
├── config.toml              # Configuration Supabase CLI
├── seed.sql                 # Donnees initiales (sources RSS, user test)
├── migrations/              # Migrations SQL numerotees
│   ├── 001_initial_schema.sql    # Tables principales
│   ├── 002_rls_policies.sql      # Politiques de securite RLS
│   ├── 003_functions.sql         # Fonctions et triggers PostgreSQL
│   └── 004_notification_logs.sql # Table logs notifications
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
read_status_type:  'unread' | 'read' | 'archived'
source_category:   'technology' | 'science' | 'business' | 'security'
                   | 'ai_ml' | 'programming' | 'design' | 'startup' | 'other'
```

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

| Fonction | Description | Params |
|----------|-------------|--------|
| `get_active_topics_with_feeds()` | Topics actifs avec leurs feeds | - |
| `get_user_stats(p_user_id)` | Statistiques utilisateur | UUID |
| `cleanup_old_articles(days_to_keep)` | Supprime vieux articles | INTEGER |
| `search_articles(search_query, p_topic_id)` | Recherche full-text | TEXT, UUID |

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
