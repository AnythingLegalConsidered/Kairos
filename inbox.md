# Inbox - Gestion des taches Kairos

> Systeme de priorisation : Easy (direct) | Medium (planifie) | Hard (PRD requis)
>
> **Version actuelle** : 0.5.0 | **Derniere MAJ** : 31/12/2024

---

## Comment utiliser ce fichier

| Difficulte | Action | Exemple |
|------------|--------|---------|
| **Easy** | Faire immediatement, supprimer de la liste | Fix typo, ajout console.log, petite correction CSS |
| **Medium** | Planifier, faire quand disponible | Nouvelle fonctionnalite simple, refactoring leger |
| **Hard** | Creer un PRD dans `docs/prd/`, puis implementer | Nouvelle feature majeure, changement d'architecture |

### Apres chaque session

1. **Mettre a jour les notes de session** (en bas de ce fichier)
2. **Mettre a jour CHANGELOG.md** si modification significative
3. **Mettre a jour le README du dossier** si nouveau fichier

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
| v0.5.0 - Vue Kanban + PWA | `docs/prd/ux-kanban-pwa.md` | **Implémenté** ✅ |

---

## Archive (terminé)

- [x] v0.1.0 - MVP complet (22/12/2024)
- [x] v0.2.0 - Tags, TLDR, score pertinence (22/12/2024)
- [x] v0.3.0 - Bibliothèque de sources (30/12/2024)
- [x] v0.4.0 - Intelligence avancée (31/12/2024)
- [x] v0.5.0 - Vue Kanban + PWA (31/12/2024)

---

## Notes de session

> Espace pour noter ce qu'on fait pendant une session de travail.
> Copier le template ci-dessous pour chaque nouvelle session.

### Template de session

```markdown
### Session du JJ/MM/AAAA

**Objectif** : [Ce que tu voulais faire]

**Realise** :
- [ ] Tache 1
- [ ] Tache 2

**Fichiers modifies** :
- `path/to/file.ext` : description

**A faire ensuite** :
- [ ] Prochaine etape

**Notes** :
- Observations, problemes rencontres, decisions prises
```

---

### Session du 31/12/2024 (soir)

**Objectif** : Mettre en place systeme de maintenance du contexte

**Realise** :
- [x] Creer CHANGELOG.md avec historique v0.1-v0.5
- [x] Mettre a jour CLAUDE.md avec section "Maintenir le contexte"
- [x] Mettre a jour tous les README des dossiers
- [x] Creer README pour docs/prd/ et tests/

**Fichiers modifies** :
- `CHANGELOG.md` : cree - historique complet
- `CLAUDE.md` : section maintenance contexte
- `inbox.md` : template session + instructions
- `web/README.md` : v0.3-v0.5 features
- `supabase/README.md` : migrations 005-007
- `n8n/README.md` : prompt highlights
- `docker/README.md` : acces rapide
- `scripts/README.md` : vue d'ensemble
- `docs/README.md` : tests Vitest + PRDs
- `docs/prd/README.md` : cree
- `tests/README.md` : cree

**A faire ensuite** :
- [ ] Documenter les composants existants (toast.js, auth-menu.js, theme.js)

---

### Session du 31/12/2024 (apres-midi)

**Realise** :
- **v0.4.0 Intelligence Avancee implementee** :
  - `006_intelligence.sql` : table user_tag_preferences, colonne highlights, fonctions RPC
  - `intelligence.js` : module JS pour tendances, articles similaires, highlights
  - Widget tendances sur le dashboard (tags trending 24h)
  - Badge "Trending" sur les articles concernes
  - Articles similaires sur la page de detail
  - Section highlights (phrases cles) sur la page de detail
  - Scoring personnalise base sur l'historique de lecture
  - Prompt "highlights" ajoute a prompts.json
  - PRD cree : docs/prd/intelligence-avancee.md

- **v0.5.0 Vue Kanban + PWA implementee** :
  - `007_kanban_reading.sql` : ajout status 'reading', fonctions RPC Kanban
  - `kanban.html` : nouvelle page Kanban avec 4 colonnes
  - Drag & drop natif HTML5 entre colonnes
  - Raccourcis clavier : j/k navigation, m marquer lu, b favori, a archiver, 1-4 deplacer
  - PWA : `manifest.json` + `sw.js` (service worker avec cache offline)
  - PRD cree : docs/prd/ux-kanban-pwa.md

---

### Session du 30/12/2024

**Realise** :
- Mis en place le systeme de gestion des taches (inbox.md, template PRD)
- Configure ESLint pour le projet
- Corrige 3 warnings ESLint dans `auth-menu.js`
- **v0.3.0 Implementee** :
  - `seed.sql` : 114 sources RSS (40 -> 114)
  - `005_source_library.sql` : table favoris + fonctions RPC
  - `sources.html` : nouvelle page bibliotheque complete
  - Navigation mise a jour sur 4 pages

---

*Derniere mise a jour : 31 decembre 2024*
