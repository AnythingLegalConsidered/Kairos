# web/ - Frontend Vanilla JS

> Interface utilisateur de Kairos - HTML/CSS/JS sans framework.

## Structure

```
web/
├── index.html          # Page d'accueil / landing
├── login.html          # Connexion et inscription
├── reset-password.html # Reinitialisation mot de passe
├── dashboard.html      # Liste des articles avec filtres
├── topic-setup.html    # Creation/edition de topics
├── article-detail.html # Vue detaillee d'un article
├── config.js           # Configuration Supabase (URLs, cles)
├── auth-menu.js        # Composant menu utilisateur
├── theme.js            # Gestion du mode sombre
├── toast.js            # Notifications toast
└── style.css           # Styles globaux + variables CSS
```

## Pages

| Page | URL | Description |
|------|-----|-------------|
| Accueil | `/index.html` | Landing page, presentation |
| Login | `/login.html` | Authentification Supabase |
| Reset Password | `/reset-password.html` | Reinitialisation MDP |
| Dashboard | `/dashboard.html` | Liste articles + filtres + export |
| Topic Setup | `/topic-setup.html` | CRUD topics + feeds RSS |
| Article Detail | `/article-detail.html?id=...` | Vue complete article |

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

### Composants partages

| Fichier | Description |
|---------|-------------|
| `auth-menu.js` | Menu utilisateur (email + logout) |
| `theme.js` | Toggle mode sombre + persistence |
| `toast.js` | Notifications non-bloquantes |

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

## Fonctionnalites

### Dashboard
- Filtrage par topic, statut, sentiment
- Recherche full-text (debounced 300ms)
- Tri par date, pertinence
- Export CSV/JSON
- Skeleton loaders pendant chargement
- Optimistic UI (bookmark, mark as read)

### Topic Setup
- CRUD complet des topics
- Gestion des mots-cles FR/EN
- Ajout de feeds RSS
- Activation/desactivation

### Article Detail
- Vue complete avec resume IA
- Score de pertinence (badge colore)
- Tags IA
- Actions : bookmark, archive, lien original

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
