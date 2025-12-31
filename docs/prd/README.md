# docs/prd/ - Product Requirements Documents

> Specifications detaillees des features majeures de Kairos.
>
> **Version:** 0.5.0 | **Derniere MAJ:** 31/12/2024

## En un coup d'oeil

- **3 PRDs implementes** : v0.3, v0.4, v0.5
- **Template disponible** : TEMPLATE.md
- **Workflow** : Tache Hard -> PRD -> Implementation -> Tests

## PRDs disponibles

| Fichier | Version | Feature | Statut |
|---------|---------|---------|--------|
| `bibliotheque-sources.md` | v0.3 | Catalogue sources RSS + favoris | Implemente |
| `intelligence-avancee.md` | v0.4 | Tendances + similaires + highlights | Implemente |
| `ux-kanban-pwa.md` | v0.5 | Vue Kanban + PWA + offline | Implemente |

## Quand creer un PRD ?

Creer un PRD pour toute tache classee **Hard** dans `inbox.md` :

| Difficulte | Action | Exemple |
|------------|--------|---------|
| Easy | Faire immediatement | Fix typo, CSS |
| Medium | Ajouter a inbox.md | Refactoring leger |
| **Hard** | **Creer un PRD** | Nouvelle feature majeure |

## Comment creer un PRD ?

1. Copier `TEMPLATE.md` avec un nom descriptif
2. Remplir toutes les sections :
   - Contexte et objectifs
   - Specifications techniques
   - Plan d'implementation
   - Criteres de validation
3. Faire review avant implementation
4. Implementer en suivant le plan
5. Mettre a jour le statut une fois termine

## Structure du template

```markdown
# PRD: Nom de la feature

## Contexte
Pourquoi cette feature ?

## Objectifs
- Objectif 1
- Objectif 2

## Specifications
### Backend (Supabase)
### Frontend (web/)
### Workflows (n8n/)

## Plan d'implementation
1. Etape 1
2. Etape 2

## Criteres de validation
- [ ] Test 1
- [ ] Test 2

## Changelog
- Date: Description
```

## Bonnes pratiques

1. **Granularite** : Un PRD = une feature coherente
2. **Testabilite** : Definir des criteres de validation clairs
3. **Independance** : Minimiser les dependances entre features
4. **Documentation** : Mettre a jour apres implementation
