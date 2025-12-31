# Changelog

> Toutes les modifications notables du projet Kairos sont documentees ici.
>
> Format: [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)

---

## [0.5.0] - 2024-12-31

### Added
- **Kanban** : Nouvelle page `kanban.html` avec vue 4 colonnes
  - Colonnes : A lire, En cours, Lu, Archive
  - Drag & drop HTML5 natif (sans librairie)
  - Compteurs par colonne
- **Raccourcis clavier** (Kanban) :
  - `j/k` : Navigation haut/bas
  - `m` : Marquer lu
  - `b` : Bookmarker
  - `a` : Archiver
  - `1-4` : Deplacer vers colonne
- **PWA** : Application installable
  - `manifest.json` avec icones 192x512
  - `sw.js` Service Worker avec cache network-first
  - Mode offline pour articles caches
- **Backend** : Migration `007_kanban_reading.sql`
  - Nouveau statut `reading` dans enum `read_status_type`
  - Fonction `get_kanban_articles(topic_id)`
  - Fonction `move_article_status(article_id, status)`

### Changed
- Navigation mise a jour sur toutes les pages (lien Kanban)
- Icones PWA ajoutees dans `web/icons/`

### Files Modified
- `web/kanban.html` (cree)
- `web/manifest.json` (cree)
- `web/sw.js` (cree)
- `web/icons/` (cree)
- `supabase/migrations/007_kanban_reading.sql` (cree)
- `docs/prd/ux-kanban-pwa.md` (cree)

---

## [0.4.0] - 2024-12-31

### Added
- **Tendances** : Detection des tags trending sur 24h/7j
  - Widget tendances sur le dashboard
  - Badge "Trending" sur articles populaires
- **Articles similaires** : Recommandations par tags communs
  - Section sur la page article-detail.html
- **Highlights** : Extraction automatique des phrases cles
  - Nouveau prompt IA dans `prompts.json`
  - Affichage sur la page de detail
- **Scoring personnalise** : Boost selon historique de lecture
- **Backend** : Migration `006_intelligence.sql`
  - Table `user_tag_preferences`
  - Colonne `highlights[]` sur articles
  - Fonctions RPC : `get_trending_tags`, `get_similar_articles`, `get_user_top_tags`

### Files Modified
- `web/intelligence.js` (cree)
- `web/dashboard.html` (widget tendances)
- `web/article-detail.html` (highlights + similaires)
- `supabase/migrations/006_intelligence.sql` (cree)
- `n8n/prompts.json` (prompt highlights)
- `docs/prd/intelligence-avancee.md` (cree)

---

## [0.3.0] - 2024-12-30

### Added
- **Bibliotheque sources** : Nouvelle page `sources.html`
  - Catalogue de 114 sources RSS (42 FR + 72 EN)
  - Filtres par categorie (8) et langue
  - Recherche par nom
  - Ajouter source a un topic
- **Favoris sources** : Systeme de favoris utilisateur
- **Backend** : Migration `005_source_library.sql`
  - Table `user_favorite_sources`
  - Fonction `suggest_sources(keywords, lang, max)`

### Changed
- `seed.sql` : 40 → 114 sources RSS
- Navigation mise a jour (lien Sources)

### Files Modified
- `web/sources.html` (cree)
- `supabase/migrations/005_source_library.sql` (cree)
- `supabase/seed.sql` (114 sources)
- `docs/prd/bibliotheque-sources.md` (cree)

---

## [0.2.0] - 2024-12-22

### Added
- **Tags IA** : Generation automatique de 3-5 tags par article
- **Score pertinence** : Badge colore (0-100) visible sur les articles
- **Vue TLDR** : Resume condense des articles

### Changed
- Workflow n8n : ajout etape tags
- Dashboard : filtrage par tags

### Files Modified
- `n8n/workflows/rss_processor.json`
- `n8n/prompts.json` (prompt tags)
- `web/dashboard.html`

---

## [0.1.0] - 2024-12-22

### Added
- **Infrastructure Docker** : 9 containers (PostgreSQL, GoTrue, PostgREST, Kong, Studio, Meta, n8n, Ollama, Nginx)
- **Backend Supabase** :
  - Tables : topics, articles, rss_sources, user_preferences
  - RLS actif sur toutes les tables
  - Fonctions et triggers PostgreSQL
- **Workflows n8n** :
  - RSS Processor (fetch, parse, IA, save)
  - Cleanup (articles > 30j)
  - Notifications (digest email)
- **Frontend Vanilla JS** :
  - Pages : index, login, dashboard, topic-setup, article-detail, reset-password
  - Theme "Papier & Encre" (clair/sombre)
  - Composants : toast, theme, auth-menu
- **IA Ollama** : Gemma 3:4b pour resume, pertinence, sentiment
- **Tests** : 32/32 passes (100%)

### Files Created
- `docker/` : docker-compose.yml, kong.yml, nginx/
- `supabase/migrations/` : 001-004
- `supabase/seed.sql`
- `n8n/workflows/` : rss_processor.json, cleanup.json
- `n8n/prompts.json`
- `web/` : 6 pages HTML, 4 modules JS, style.css
- `scripts/` : setup, start, stop, reset, test
- `docs/` : TESTS.md, RAPPORT_TESTS.md

---

## Comment maintenir ce changelog

### Quand mettre a jour ?

| Action | Mettre a jour |
|--------|---------------|
| Nouvelle feature | Oui - section "Added" |
| Modification existant | Oui - section "Changed" |
| Correction bug | Oui - section "Fixed" |
| Suppression | Oui - section "Removed" |
| Refactoring interne | Non (sauf impact visible) |

### Format d'une entree

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- **Nom feature** : Description courte
  - Detail 1
  - Detail 2

### Changed
- Description du changement

### Fixed
- Description du fix

### Removed
- Ce qui a ete supprime

### Files Modified
- `path/to/file.ext` (cree|modifie|supprime)
```

### Conventions

1. **Version** : Semantic Versioning (MAJOR.MINOR.PATCH)
2. **Date** : Format ISO (YYYY-MM-DD)
3. **Langue** : Francais sans accents (pour compatibilite)
4. **Fichiers** : Lister les fichiers principaux modifies
