# Inbox - Gestion des tâches Kairos

> Système de priorisation : Easy (direct) | Medium (planifié) | Hard (PRD requis)

---

## Comment utiliser ce fichier

| Difficulté | Action | Exemple |
|------------|--------|---------|
| **Easy** | Faire immédiatement, supprimer de la liste | Fix typo, ajout console.log, petite correction CSS |
| **Medium** | Planifier, faire quand disponible | Nouvelle fonctionnalité simple, refactoring léger |
| **Hard** | Créer un PRD dans `docs/prd/`, puis implémenter | Nouvelle feature majeure, changement d'architecture |

---

## Easy (à faire maintenant)

_Rien pour l'instant_

---

## Medium (à planifier)

### Frontend
- [x] ~~Ajouter ESLint au projet~~ (fait le 30/12)
- [ ] Documenter les composants existants (toast.js, auth-menu.js, theme.js)

### Backend
- [ ] _Ajouter tes tâches backend ici_

### Workflow n8n
- [ ] _Ajouter tes tâches n8n ici_

---

## Hard (nécessite un PRD)

> Pour chaque tâche Hard, créer un fichier `docs/prd/NOM_FEATURE.md` basé sur le template

| Feature | PRD | Statut |
|---------|-----|--------|
| v0.3.0 - Bibliothèque de Sources | `docs/prd/bibliotheque-sources.md` | **Implémenté** ✅ |
| v0.4.0 - Intelligence Avancée | `docs/prd/intelligence-avancee.md` | **Implémenté** ✅ |
| v0.5.0 - Vue Kanban + PWA | `docs/prd/ux-kanban-pwa.md` | A créer |

---

## Archive (terminé)

- [x] v0.1.0 - MVP complet (22/12/2024)
- [x] v0.2.0 - Tags, TLDR, score pertinence (22/12/2024)
- [x] v0.3.0 - Bibliothèque de sources (30/12/2024)
- [x] v0.4.0 - Intelligence avancée (31/12/2024)

---

## Notes de session

> Espace pour noter ce qu'on fait pendant une session de travail

### Session du 30/12/2024
- Mis en place le système de gestion des tâches (inbox.md, template PRD)
- Configuré ESLint pour le projet
- **Tâche Easy testée** : Corrigé 3 warnings ESLint dans `auth-menu.js`
- **Tâche Hard testée** : PRD v0.3.0 Bibliothèque de Sources
- **v0.3.0 Implémentée** :
  - `seed.sql` : 114 sources RSS (40 → 114)
  - `005_source_library.sql` : table favoris + fonctions RPC
  - `sources.html` : nouvelle page bibliothèque complète
  - Navigation mise à jour sur 4 pages
  - ROADMAP.md mis à jour

---



### Session du 31/12/2024
- **v0.4.0 Intelligence Avancée implémentée** :
  - `006_intelligence.sql` : table user_tag_preferences, colonne highlights, fonctions RPC
  - `intelligence.js` : module JS pour tendances, articles similaires, highlights
  - Widget tendances sur le dashboard (tags trending 24h)
  - Badge "Trending" sur les articles concernés
  - Articles similaires sur la page de détail
  - Section highlights (phrases clés) sur la page de détail
  - Scoring personnalisé basé sur l'historique de lecture
  - Prompt "highlights" ajouté à prompts.json
  - PRD créé : docs/prd/intelligence-avancee.md
  - ROADMAP.md mis à jour
---

*Dernière mise à jour : 31 décembre 2024*
