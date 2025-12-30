# Roadmap Kairos

> Évolutions planifiées pour la plateforme de veille intelligente

---

## Légende

| Priorité | Difficulté | Statut |
|----------|------------|--------|
| 🔴 Haute | 🟢 Facile | ⬜ À faire |
| 🟠 Moyenne | 🟡 Moyenne | 🔄 En cours |
| 🟢 Basse | 🔴 Complexe | ✅ Terminé |

---

## v0.2.0 - Enrichissement IA & Tags

> Objectif : Rendre le traitement IA plus visible et utile

| Priorité | Difficulté | Fonctionnalité | Description |
|----------|------------|----------------|-------------|
| 🔴 | 🟢 | **Tags automatiques** | Générer 5 mots-clés par article via l'IA |
| 🔴 | 🟢 | **Vue TLDR** | Afficher résumé + tags + score en vue condensée |
| 🔴 | 🟡 | **Filtrage par tags** | Filtrer/trier les articles par tags |
| 🔴 | 🟢 | **Score de pertinence visible** | Afficher le score IA de manière prominente (badge coloré) |
| 🟠 | 🟢 | **Temps de lecture** | Estimer et afficher le temps de lecture |

**Détails techniques :**
- Modifier le prompt IA pour extraire 5 tags pertinents
- Stocker les tags en JSONB dans la table `articles`
- Créer un index GIN pour recherche rapide sur les tags
- Nouvelle vue dashboard avec cards TLDR

---

## v0.3.0 - Bibliothèque de Sources

> Objectif : Offrir un catalogue riche de sources RSS prêtes à l'emploi

| Priorité | Difficulté | Fonctionnalité | Description |
|----------|------------|----------------|-------------|
| 🔴 | 🟡 | **Catalogue FR** | 50+ sources françaises par catégorie |
| 🔴 | 🟡 | **Catalogue EN** | 50+ sources anglophones par catégorie |
| 🟠 | 🟢 | **Catégorisation** | Tech, Business, Science, Politique, etc. |
| 🟠 | 🟢 | **Ajout en 1 clic** | Ajouter une source du catalogue à un topic |
| 🟠 | 🟡 | **Suggestion de sources** | Recommander des sources selon les mots-clés du topic |

**Sources à intégrer :**

*Français :*
- Tech : Le Monde Informatique, 01net, Numerama, Next INpact, Frandroid, Korben
- Business : Les Echos, BFM Business, Capital, Challenges
- Science : Futura Sciences, Science & Vie, Pour la Science
- Généraliste : Le Monde, Le Figaro, Libération, France Info

*Anglais :*
- Tech : TechCrunch, Ars Technica, The Verge, Wired, Hacker News, MIT Tech Review
- Business : Bloomberg, Reuters, Financial Times, Forbes
- Science : Nature, Science Daily, New Scientist
- Dev : Dev.to, Lobsters, InfoQ, DZone

---

## v0.4.0 - Intelligence Avancée

> Objectif : Exploiter l'IA pour des insights plus profonds

| Priorité | Difficulté | Fonctionnalité | Description |
|----------|------------|----------------|-------------|
| 🟠 | 🟡 | **Détection de tendances** | Alerter quand un sujet apparaît dans plusieurs sources |
| 🟠 | 🟡 | **Articles similaires** | Recommander des articles connexes |
| 🟠 | 🔴 | **Highlights automatiques** | Extraire et surligner les passages clés |
| 🟢 | 🔴 | **Scoring personnalisé** | Adapter le score selon l'historique de lecture |
| 🟢 | 🔴 | **Fact-checking basique** | Croiser les infos entre sources multiples |

**Détails techniques :**
- Clustering des articles par similarité sémantique
- Tracking des sujets sur fenêtre glissante (24h/7j)
- Embeddings pour articles similaires (optionnel: pgvector)

---

## v0.5.0 - Expérience Utilisateur

> Objectif : Améliorer l'interface et le workflow de lecture

| Priorité | Difficulté | Fonctionnalité | Description |
|----------|------------|----------------|-------------|
| 🟠 | 🟡 | **Vue Kanban** | Colonnes : À lire → En cours → Lu → Archivé |
| 🟠 | 🟢 | **Raccourcis clavier** | Navigation rapide (j/k, m pour marquer lu, b pour bookmark) |
| 🟠 | 🟡 | **Newsletter digest** | Email quotidien/hebdo avec top articles |
| 🟢 | 🟡 | **PWA** | Application installable + notifications push |
| 🟢 | 🟢 | **Lecture hors-ligne** | Cache des articles pour lecture sans connexion |

---

## v0.6.0 - Collaboration & Partage

> Objectif : Permettre le travail en équipe sur la veille

| Priorité | Difficulté | Fonctionnalité | Description |
|----------|------------|----------------|-------------|
| 🟢 | 🟡 | **Topics partagés** | Partager une veille avec des collaborateurs |
| 🟢 | 🟢 | **Annotations** | Ajouter des notes personnelles sur les articles |
| 🟢 | 🟡 | **Export Notion/Obsidian** | Formats compatibles avec les outils de PKM |
| 🟢 | 🟡 | **API publique** | REST API pour intégrations externes |
| 🟢 | 🔴 | **Webhooks** | Notifier des services externes (Slack, Discord, Teams) |

---

## v1.0.0 - Production Ready

> Objectif : Déploiement cloud et stabilité

| Priorité | Difficulté | Fonctionnalité | Description |
|----------|------------|----------------|-------------|
| 🟠 | 🟡 | **Supabase Cloud** | Migration vers Supabase hébergé |
| 🟠 | 🟡 | **n8n Cloud** | Migration des workflows |
| 🟠 | 🟡 | **HuggingFace API** | Remplacer Ollama local par API cloud |
| 🟠 | 🟢 | **Frontend hébergé** | Vercel/Netlify/GitHub Pages |
| 🟢 | 🔴 | **Multi-modèles IA** | Choix du modèle (Gemma, Mistral, Llama, GPT) |

---

## Backlog (idées futures)

- [ ] Import OPML (fichiers de flux RSS)
- [ ] Extension navigateur pour sauvegarder des articles
- [ ] Résumé audio (TTS) des articles
- [ ] Traduction automatique des articles
- [ ] Dashboard analytics (stats de lecture, sources les plus utiles)
- [ ] Mode "focus" - une seule source à la fois
- [ ] Intégration calendrier (bloquer du temps pour la veille)
- [ ] Gamification (streaks de lecture, badges)

---

## Changelog

### v0.3.0 (30/12/2024) ✅
- Bibliothèque de sources : 114 sources RSS (42 FR + 72 EN)
- Nouvelle page `sources.html` avec filtres et recherche
- Système de favoris (table + fonctions RPC)
- Fonction `suggest_sources()` pour suggestions par mots-clés
- Catégories : Technology, AI/ML, Programming, Security, Science, Business, Startup, Design
- Navigation mise à jour sur toutes les pages

### v0.2.0 (22/12/2024) ✅
- Tags automatiques générés par l'IA
- Vue TLDR avec résumé condensé
- Score de pertinence visible (badge coloré)
- Filtrage par tags

### v0.1.0 (22/12/2024) ✅
- Infrastructure Docker (Supabase, n8n, Ollama, Nginx)
- Backend complet avec RLS
- Workflows n8n (RSS, Cleanup, Notifications)
- Frontend avec dashboard, filtres, export, mode sombre
- Tests : 32/32 passés

---

*Dernière mise à jour : 30 décembre 2024*
