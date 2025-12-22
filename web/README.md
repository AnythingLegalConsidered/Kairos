# Kairos Web Interface

## 🚀 Démarrer le serveur web

### Option 1 : Python HTTP Server (Recommandé)

```bash
cd c:\Pro\Ecole\Veille\web
python -m http.server 8000
```

Puis ouvrez : **http://localhost:8000**

### Option 2 : Live Server (VSCode)

1. Installez l'extension "Live Server" dans VSCode
2. Clic droit sur `index.html` → "Open with Live Server"

## 📄 Pages disponibles

- **[index.html](http://localhost:8000/index.html)** - Page d'accueil
- **[login.html](http://localhost:8000/login.html)** - Connexion (Supabase Auth)
- **[topic-setup.html](http://localhost:8000/topic-setup.html)** - Créer un nouveau topic
- **[dashboard.html](http://localhost:8000/dashboard.html)** - Liste des articles

## ⚙️ Configuration

Le fichier `config.js` configure automatiquement :
- **Mode LOCAL** : `http://127.0.0.1:54321` (PostgREST)
- **Mode CLOUD** : Ajoutez `?mode=cloud` à l'URL

## 🔗 Services requis

Assurez-vous que Docker est lancé avec :

```bash
docker compose up -d
```

Services nécessaires :
- **PostgREST** : http://localhost:54321
- **Supabase Studio** : http://localhost:54323
- **n8n** : http://localhost:5678

## 🎨 Fonctionnalités

- ✅ Navigation cohérente sur toutes les pages
- ✅ Menu utilisateur (email + déconnexion)
- ✅ Connexion/déconnexion automatique
- ✅ Thème "Papier & Encre" apaisant
- ✅ Design responsive

## 📝 Fichiers

- `style.css` - Styles globaux partagés
- `config.js` - Configuration Supabase
- `auth-menu.js` - Menu utilisateur partagé
