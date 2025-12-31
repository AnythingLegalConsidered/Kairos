# web/ - Frontend Vanilla JS

> Interface utilisateur de Kairos - HTML/CSS/JS sans framework.
>
> **Version:** 0.5.0 | **Derniere MAJ:** 31/12/2024

## En un coup d'oeil

- **8 pages HTML** : Landing, Login, Dashboard, Topics, Articles, Sources, Kanban, Reset
- **6 modules JS** : config, auth-menu, toast, theme, intelligence, sw (PWA)
- **PWA** : Installable + mode offline
- **Theme** : Clair/Sombre avec persistence

## Structure

```
web/
├── index.html          # Landing page
├── login.html          # Connexion / inscription
├── reset-password.html # Reinitialisation mot de passe
├── dashboard.html      # Liste articles + filtres + export (2346 lignes)
├── topic-setup.html    # CRUD topics + selection RSS
├── article-detail.html # Vue detaillee + highlights + similaires (823 lignes)
├── sources.html        # Bibliotheque 114 sources RSS (v0.3)
├── kanban.html         # Vue Kanban drag & drop (v0.5)
├── config.js           # Configuration Supabase (local/cloud)
├── auth-menu.js        # Menu utilisateur + logout
├── toast.js            # Notifications toast (180 lignes)
├── theme.js            # Mode sombre + persistence (111 lignes)
├── intelligence.js     # Tendances + similaires + highlights (v0.4)
├── sw.js               # Service Worker PWA (v0.5)
├── manifest.json       # PWA manifest (v0.5)
├── style.css           # Styles globaux + variables CSS
└── icons/              # Icones PWA 192x512
```

## Pages

| Page | URL | Description | Version |
|------|-----|-------------|---------|
| Accueil | `/index.html` | Landing page, presentation | v0.1 |
| Login | `/login.html` | Authentification Supabase | v0.1 |
| Reset Password | `/reset-password.html` | Reinitialisation MDP | v0.1 |
| Dashboard | `/dashboard.html` | Articles + filtres + tendances + export | v0.1+ |
| Topic Setup | `/topic-setup.html` | CRUD topics + feeds RSS | v0.1 |
| Article Detail | `/article-detail.html?id=...` | Detail + highlights + similaires | v0.1+ |
| **Sources** | `/sources.html` | Bibliotheque 114 sources RSS | **v0.3** |
| **Kanban** | `/kanban.html` | Vue 4 colonnes + drag & drop | **v0.5** |

## Architecture frontend

### Authentification
- **Supabase Auth** via CDN (@supabase/supabase-js)
- **JWT stocke** en localStorage par Supabase
- **Protection des pages** : redirection vers login si non connecte

### Configuration (config.js)
```javascript
const SUPABASE_URL = 'http://localhost:8000';
const SUPABASE_ANON_KEY = 'eyJ...';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

### Modules JavaScript partages

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `config.js` | ~20 | Configuration Supabase (URL, cles, client) |
| `auth-menu.js` | ~80 | Menu utilisateur (email + logout + redirect) |
| `toast.js` | 180 | Notifications toast (success/error/warning/info) |
| `theme.js` | 111 | Toggle mode sombre + localStorage + preference systeme |
| `intelligence.js` | 197 | Tendances, similaires, highlights, scoring perso (v0.4) |
| `sw.js` | ~100 | Service Worker: cache network-first, offline (v0.5) |

## Design System

### Theme "Papier & Encre"
- Couleurs douces et apaisantes
- Mode sombre complet
- Police system-ui

### Variables CSS principales

```css
:root {
  --bg-primary: #faf9f7;
  --text-primary: #2c2c2c;
  --accent: #6b8e7b;
  --border: #e0ddd5;
}

[data-theme="dark"] {
  --bg-primary: #1a1a1a;
  --text-primary: #e0e0e0;
  --accent: #8fb39f;
  --border: #333;
}
```

## Fonctionnalites par page

### Dashboard (v0.1+)
- Filtrage par topic, statut, sentiment, tags
- Recherche full-text (debounced 300ms)
- Tri par date, pertinence
- Export CSV/JSON
- Skeleton loaders pendant chargement
- Optimistic UI (bookmark, mark as read)
- **Widget tendances** (v0.4) : tags trending 24h
- **Badge "Trending"** sur articles populaires

### Topic Setup (v0.1)
- CRUD complet des topics
- Gestion des mots-cles FR/EN
- Selection de feeds RSS depuis catalogue
- Activation/desactivation

### Article Detail (v0.1+)
- Vue complete avec resume IA
- Score de pertinence (badge colore 0-100)
- Tags IA automatiques
- **Highlights** (v0.4) : phrases cles extraites
- **Articles similaires** (v0.4) : recommandations par tags
- Actions : bookmark, archive, lien original

### Sources (v0.3)
- Catalogue de 114 sources RSS (42 FR + 72 EN)
- Filtres par categorie (8) et langue
- Recherche par nom
- Ajouter source a un topic existant
- Systeme de favoris sources

### Kanban (v0.5)
- Vue 4 colonnes : A lire, En cours, Lu, Archive
- Drag & drop HTML5 natif (pas de librairie)
- Compteurs par colonne
- **Raccourcis clavier** :
  - `j/k` : Navigation haut/bas
  - `m` : Marquer lu
  - `b` : Bookmarker
  - `a` : Archiver
  - `1-4` : Deplacer vers colonne

### PWA (v0.5)
- Installation sur mobile/desktop
- Mode offline : articles caches disponibles
- Service Worker avec strategie network-first

## Accessibilite

- ARIA labels sur les elements interactifs
- Roles semantiques (main, nav, article)
- Focus visible
- Contraste suffisant

## API Supabase utilisees

### Authentification
```javascript
supabase.auth.signInWithPassword({ email, password })
supabase.auth.signUp({ email, password })
supabase.auth.signOut()
supabase.auth.getSession()
```

### Donnees
```javascript
// Topics
supabase.from('topics').select('*')
supabase.from('topics').insert({...})
supabase.from('topics').update({...}).eq('id', id)
supabase.from('topics').delete().eq('id', id)

// Articles
supabase.from('articles').select('*, topics(name)')
supabase.from('articles').update({ bookmarked: true }).eq('id', id)

// Sources (v0.3)
supabase.from('rss_sources').select('*')
supabase.from('user_favorite_sources').insert({ source_id })
```

### Fonctions RPC (v0.4+)
```javascript
// Tendances
supabase.rpc('get_trending_tags', { hours_ago: 24 })

// Articles similaires
supabase.rpc('get_similar_articles', { article_id, max_results: 5 })

// Kanban (v0.5)
supabase.rpc('get_kanban_articles', { p_topic_id })
supabase.rpc('move_article_status', { p_article_id, p_new_status })
```

## Developpement local

### Option 1 : Nginx Docker (recommande)
```bash
cd docker && docker-compose up nginx
# Frontend sur http://localhost:3000
```

### Option 2 : Python HTTP Server
```bash
cd web
python -m http.server 3000
```

### Option 3 : Live Server VSCode
1. Installer l'extension "Live Server"
2. Clic droit sur `index.html` > "Open with Live Server"

## Conventions de code

- **Vanilla JS** - Pas de framework, pas de build step
- **ES6+** - Modules, arrow functions, async/await
- **Inline scripts** - JS dans les fichiers HTML pour simplicite
- **BEM-like CSS** - Classes descriptives (.article-card, .filter-bar)

## Debug

```javascript
// Verifier la session
const { data: { session } } = await supabase.auth.getSession();
console.log('User:', session?.user);

// Verifier les requetes
supabase.from('articles').select('*').then(console.log);
```
