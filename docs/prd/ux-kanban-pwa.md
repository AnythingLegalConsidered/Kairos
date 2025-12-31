# PRD : v0.5.0 - Vue Kanban & PWA

> Version : 1.0 | Date : 31/12/2024 | Statut : En cours

---

## 1. Résumé

**Objectif** : Améliorer l'expérience de lecture avec une vue Kanban et transformer Kairos en PWA.

**Problème** : La vue liste actuelle ne permet pas de visualiser facilement le workflow de lecture. Les utilisateurs n'ont pas d'accès mobile optimisé.

**Valeur** : Workflow de lecture plus intuitif + app installable sur mobile/desktop.

---

## 2. État actuel

- Dashboard affiche les articles en liste avec filtres
- `read_status` enum existant : `unread`, `read`, `archived`
- Pas de vue workflow/Kanban
- Pas de PWA (manifest, service worker)
- Pas de raccourcis clavier

```
Fichiers concernés :
- web/dashboard.html (vue liste actuelle)
- web/style.css (styles globaux)
- supabase/migrations/001_initial_schema.sql (enum read_status)
```

---

## 3. Solution proposée

### 3.1 Vue Kanban

4 colonnes représentant le workflow de lecture :

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   À LIRE    │  EN COURS   │     LU      │   ARCHIVÉ   │
│   (unread)  │ (reading)*  │   (read)    │  (archived) │
├─────────────┼─────────────┼─────────────┼─────────────┤
│  Article 1  │  Article 3  │  Article 5  │  Article 7  │
│  Article 2  │             │  Article 6  │             │
│             │             │             │             │
└─────────────┴─────────────┴─────────────┴─────────────┘

* "reading" = nouveau statut à ajouter
```

**Comportement :**
- Drag & drop entre colonnes
- Clic sur article → ouvre le détail
- Double-clic → ouvre URL externe
- Compteur d'articles par colonne
- Filtre par topic en sidebar (comme dashboard)

### 3.2 Raccourcis clavier

| Touche | Action |
|--------|--------|
| `j` / `↓` | Article suivant |
| `k` / `↑` | Article précédent |
| `o` / `Enter` | Ouvrir article |
| `m` | Marquer lu/non lu |
| `b` | Toggle bookmark |
| `a` | Archiver |
| `1-4` | Déplacer vers colonne 1-4 |
| `?` | Afficher aide raccourcis |

### 3.3 PWA

- Manifest pour installation
- Service worker pour cache
- Mode hors-ligne (lecture articles cachés)
- Icônes 192x192 et 512x512

---

## 4. Implémentation technique

### 4.1 Fichiers à modifier/créer

| Fichier | Type | Détail |
|---------|------|--------|
| `web/kanban.html` | Nouveau | Page vue Kanban |
| `web/kanban.js` | Nouveau | Logique drag & drop + raccourcis |
| `web/style.css` | Modification | Styles Kanban |
| `web/manifest.json` | Nouveau | Manifest PWA |
| `web/sw.js` | Nouveau | Service Worker |
| `supabase/migrations/007_reading_status.sql` | Nouveau | Ajout status 'reading' |
| Navigation (toutes pages) | Modification | Lien vers Kanban |

### 4.2 Modification base de données

```sql
-- Ajouter le statut 'reading' à l'enum
ALTER TYPE read_status_type ADD VALUE IF NOT EXISTS 'reading' AFTER 'unread';
```

### 4.3 API utilisées

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| PATCH | `/rest/v1/articles?id=eq.{id}` | Mettre à jour read_status |

---

## 5. Plan d'implémentation

1. [x] Créer PRD
2. [ ] Migration SQL : ajouter 'reading' à l'enum
3. [ ] Créer `kanban.html` avec structure HTML
4. [ ] Implémenter drag & drop natif (HTML5)
5. [ ] Ajouter raccourcis clavier
6. [ ] Créer `manifest.json` + icônes
7. [ ] Créer Service Worker
8. [ ] Mettre à jour navigation
9. [ ] Tests manuels

---

## 6. Risques et questions ouvertes

| Risque / Question | Impact | Mitigation |
|-------------------|--------|------------|
| Performance avec beaucoup d'articles | Moyen | Limiter à 50 articles par colonne, pagination |
| Drag & drop sur mobile | Moyen | Utiliser touch events en fallback |
| Service worker cache stale | Faible | Stratégie network-first pour API |

---

## 7. Critères de validation

- [ ] Drag & drop fonctionne entre les 4 colonnes
- [ ] Articles persistent leur statut après refresh
- [ ] Raccourcis clavier fonctionnent
- [ ] PWA installable sur Chrome/Edge
- [ ] Mode hors-ligne affiche les articles cachés
- [ ] Navigation mise à jour sur toutes les pages
- [ ] Fonctionne en mode clair et sombre

---

## 8. Notes

Approche : Vanilla JS avec HTML5 Drag & Drop API natif (pas de librairie externe).

*PRD Kairos v0.5.0*
