# PRD : [Nom de la Feature]

> Version : 1.0 | Date : JJ/MM/AAAA | Statut : Draft / En review / Validé

---

## 1. Résumé

**Objectif** : Une phrase qui décrit ce qu'on veut accomplir.

**Problème** : Quel problème utilisateur ou technique on résout ?

**Valeur** : Pourquoi c'est important pour le projet ?

---

## 2. État actuel

Décrire brièvement comment ça fonctionne aujourd'hui (ou pourquoi ça n'existe pas).

```
Fichiers concernés actuellement :
- web/dashboard.html (si applicable)
- supabase/migrations/xxx.sql (si applicable)
- n8n/workflows/xxx.json (si applicable)
```

---

## 3. Solution proposée

### 3.1 Description fonctionnelle

Décrire le comportement attendu du point de vue utilisateur :
- L'utilisateur fait X...
- Le système répond Y...
- Le résultat est Z...

### 3.2 Maquette / Wireframe (optionnel)

```
┌─────────────────────────────┐
│  Schéma ASCII si utile      │
└─────────────────────────────┘
```

---

## 4. Implémentation technique

### 4.1 Fichiers à modifier

| Fichier | Type de modification | Détail |
|---------|---------------------|--------|
| `web/xxx.html` | Modification | Ajouter... |
| `supabase/migrations/00X_xxx.sql` | Nouveau | Créer table... |
| `n8n/workflows/xxx.json` | Modification | Ajouter noeud... |

### 4.2 Schéma base de données (si applicable)

```sql
-- Nouvelles tables ou colonnes
ALTER TABLE xxx ADD COLUMN yyy TYPE;
```

### 4.3 API / Endpoints (si applicable)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/rest/v1/xxx` | Récupérer... |
| POST | `/rest/v1/xxx` | Créer... |

---

## 5. Plan d'implémentation

Étapes ordonnées pour implémenter la feature :

1. [ ] Étape 1 : ...
2. [ ] Étape 2 : ...
3. [ ] Étape 3 : ...
4. [ ] Étape 4 : Tests
5. [ ] Étape 5 : Documentation

---

## 6. Risques et questions ouvertes

| Risque / Question | Impact | Mitigation |
|-------------------|--------|------------|
| Ex: Performance avec beaucoup de données | Moyen | Ajouter index, pagination |
| Ex: Compatibilité navigateurs | Faible | Tester sur Chrome/Firefox/Safari |

---

## 7. Critères de validation

- [ ] Fonctionnalité X fonctionne comme décrit
- [ ] Tests passent (si applicable)
- [ ] Pas de régression sur les features existantes
- [ ] Documentation mise à jour (si applicable)

---

## 8. Notes de review

> Espace pour noter les retours après review du PRD

_À compléter après discussion..._

---

*Template PRD Kairos - ~80 lignes*
