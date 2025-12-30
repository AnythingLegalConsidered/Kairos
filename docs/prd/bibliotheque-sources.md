# PRD : Bibliothèque de Sources RSS (v0.3.0)

> Version : 1.1 | Date : 30/12/2024 | Statut : Validé

---

## 1. Résumé

**Objectif** : Offrir un catalogue riche de 100+ sources RSS prêtes à l'emploi, facilement explorable.

**Problème** : Actuellement, les utilisateurs doivent connaître les URLs RSS ou se limiter aux ~40 sources pré-configurées. Pas de moyen simple de découvrir de nouvelles sources pertinentes.

**Valeur** : Réduire la friction pour démarrer une veille. L'utilisateur peut construire sa veille en quelques clics sans chercher des flux RSS.

---

## 2. État actuel

### Ce qui existe
- **Table `rss_sources`** : 40 sources dans `seed.sql`
- **Catégories** : 9 types (technology, science, business, security, ai_ml, programming, design, startup, other)
- **Langues** : FR et EN supportés
- **UI** : Sélection intégrée dans `topic-setup.html` avec tabs par catégorie

### Limitations
- Pas de page dédiée pour explorer le catalogue
- Pas de recherche dans les sources
- Pas de suggestions basées sur les mots-clés du topic
- Nombre de sources insuffisant (40 vs 100+ cible)

```
Fichiers concernés :
- supabase/seed.sql (données sources)
- supabase/migrations/001_initial_schema.sql (table rss_sources)
- web/topic-setup.html (UI sélection actuelle)
```

---

## 3. Solution proposée

### 3.1 Nouvelles fonctionnalités

| Feature | Priorité | Description |
|---------|----------|-------------|
| Catalogue étendu | Haute | 100+ sources (50 FR + 50 EN minimum) |
| Page bibliothèque | Haute | Page dédiée `/sources.html` pour explorer |
| Recherche | Moyenne | Recherche par nom/description dans le catalogue |
| Suggestions | Moyenne | Recommander des sources selon mots-clés du topic |
| Favoris sources | **Haute** | Marquer des sources comme favorites |

### 3.2 Parcours utilisateur

**Scénario 1 : Explorer le catalogue**
1. L'utilisateur clique sur "Bibliothèque" dans la nav
2. Il voit toutes les sources groupées par catégorie
3. Il peut filtrer par langue (FR/EN/Toutes)
4. Il peut rechercher par nom
5. Il clique sur "+" pour ajouter à un topic existant

**Scénario 2 : Suggestions lors de création de topic**
1. L'utilisateur entre "Intelligence Artificielle" comme topic
2. Le système suggère automatiquement : OpenAI Blog, Google AI Blog, Towards Data Science...
3. L'utilisateur coche celles qui l'intéressent

### 3.3 Maquette UI - Page Bibliothèque

```
┌─────────────────────────────────────────────────────────────────┐
│  [Logo] Kairos          Accueil | Bibliothèque | Dashboard      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bibliothèque de Sources RSS                                    │
│  ───────────────────────────                                    │
│                                                                 │
│  [🔍 Rechercher une source...]     [FR ▼] [EN ▼] [Toutes]      │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 💻 Technologie (24)                              [▼]    │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ ○ TechCrunch          Technology news...        [+ Add] │   │
│  │ ○ The Verge           Tech, science, art...     [+ Add] │   │
│  │ ○ 01net          FR   Actualités high-tech      [+ Add] │   │
│  │ ...                                                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 🤖 IA & Machine Learning (12)                    [▼]    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 🔒 Sécurité (8)                                  [▼]    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Implémentation technique

### 4.1 Fichiers à modifier/créer

| Fichier | Action | Détail |
|---------|--------|--------|
| `supabase/seed.sql` | Modifier | Ajouter 60+ nouvelles sources |
| `web/sources.html` | **Créer** | Nouvelle page bibliothèque |
| `web/topic-setup.html` | Modifier | Ajouter suggestions IA |
| `supabase/migrations/005_source_suggestions.sql` | **Créer** | Fonction suggestion par mots-clés |
| `web/style.css` | Modifier | Styles pour la nouvelle page |

### 4.2 Nouvelles sources à ajouter

**Français (à compléter pour atteindre 50+) :**
- Tech : Next INpact, Korben, MacGeneration, iPhon.fr
- Business : Les Echos, BFM Business, Capital, Challenges, L'Usine Digitale
- Science : Science & Vie, Pour la Science, La Recherche
- Généraliste : Le Monde Tech, Le Figaro Tech, Libération Sciences
- Politique/Société : France Culture, France Inter

**Anglais (à compléter pour atteindre 50+) :**
- Tech : Engadget, CNET, ZDNet, VentureBeat, The Register
- Business : Bloomberg Tech, Reuters Tech, Fortune Tech
- Science : Scientific American, Quanta Magazine, Nautilus
- Dev : InfoQ, DZone, Lobsters, Changelog

### 4.3 Fonction suggestion (PostgreSQL)

```sql
-- Suggère des sources basées sur les mots-clés
CREATE OR REPLACE FUNCTION suggest_sources(
    keywords TEXT[],
    lang VARCHAR(5) DEFAULT NULL,
    max_results INTEGER DEFAULT 10
) RETURNS SETOF rss_sources AS $$
BEGIN
    RETURN QUERY
    SELECT rs.*
    FROM rss_sources rs
    WHERE rs.active = true
      AND (lang IS NULL OR rs.language = lang)
      AND (
          rs.name ILIKE ANY(SELECT '%' || k || '%' FROM unnest(keywords) k)
          OR rs.description ILIKE ANY(SELECT '%' || k || '%' FROM unnest(keywords) k)
          OR rs.category::text ILIKE ANY(SELECT '%' || k || '%' FROM unnest(keywords) k)
      )
    ORDER BY rs.name
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;
```

---

## 5. Plan d'implémentation

1. [ ] **Étendre le catalogue** : Ajouter 60+ sources dans `seed.sql`
2. [ ] **Créer la migration** : Fonction `suggest_sources()`
3. [ ] **Créer `sources.html`** : Page bibliothèque avec filtres
4. [ ] **Modifier `topic-setup.html`** : Intégrer suggestions automatiques
5. [ ] **Ajouter styles** : CSS pour la nouvelle page
6. [ ] **Mettre à jour nav** : Ajouter lien "Bibliothèque"
7. [ ] **Tests** : Vérifier filtres, recherche, ajout à topic
8. [ ] **Documentation** : Mettre à jour README si nécessaire

---

## 6. Risques et questions ouvertes

| Risque / Question | Impact | Mitigation |
|-------------------|--------|------------|
| URLs RSS obsolètes | Moyen | Vérifier manuellement chaque URL avant ajout |
| Performance recherche | Faible | Index GIN sur name/description si lent |
| Certaines sources bloquent le fetch | Moyen | Tester avec n8n avant d'ajouter |

### Questions pour validation

1. **Page dédiée ou intégration ?** Créer `sources.html` séparé ou enrichir `topic-setup.html` ?
2. **Favoris ?** Implémenter les favoris sources maintenant ou reporter à v0.4.0 ?
3. **Sources communautaires ?** Permettre aux utilisateurs de proposer des sources ?

---

## 7. Critères de validation

- [ ] 100+ sources dans le catalogue (50 FR + 50 EN minimum)
- [ ] Page bibliothèque fonctionnelle avec filtres langue/catégorie
- [ ] Recherche par nom fonctionne
- [ ] Suggestions affichées dans topic-setup basées sur mots-clés
- [ ] Ajout d'une source à un topic en 1 clic
- [ ] Mode sombre supporté sur nouvelle page

---

## 8. Notes de review

### Décisions validées (30/12/2024)

| Question | Décision |
|----------|----------|
| Page dédiée vs intégration ? | **Page dédiée `sources.html`** |
| Favoris maintenant ? | **Oui, inclus dans v0.3.0** |
| Sources communautaires ? | **Non, catalogue curated uniquement** |

### Ajustements au plan

- Ajouter table `user_favorite_sources` pour les favoris
- Ajouter bouton "favori" sur chaque source dans la bibliothèque
- Filtrer par "Mes favoris" dans la page sources

---

*PRD créé le 30/12/2024 - Validé le 30/12/2024*
