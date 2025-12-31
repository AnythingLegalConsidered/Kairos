# PRD : v0.4.0 - Intelligence Avancee

> Version : 1.0 | Date : 31/12/2024 | Statut : En cours

---

## 1. Resume

**Objectif** : Exploiter l'IA pour fournir des insights plus profonds sur les articles de veille.

**Probleme** : Actuellement, l'utilisateur recoit des articles avec un score de pertinence et des tags, mais il n'a pas de vision sur les tendances emergentes ni de recommandations personnalisees.

**Valeur** : Permettre une veille plus intelligente en detectant automatiquement les sujets chauds et en recommandant des articles similaires.

---

## 2. Etat actuel

L'IA genere deja pour chaque article :
- Un **resume** (2-3 phrases)
- Un **score de pertinence** (0-100)
- Des **tags** (3-5 mots-cles)

```
Fichiers concernes actuellement :
- n8n/prompts.json : Prompts pour summary, relevance, tags
- supabase/migrations/001_initial_schema.sql : Table articles avec tags[]
- supabase/migrations/003_functions.sql : Fonctions RPC existantes
- web/dashboard.html : Affichage des articles avec score et tags
```

---

## 3. Solution proposee

### 3.1 Fonctionnalites

| # | Fonctionnalite | Priorite | Description |
|---|----------------|----------|-------------|
| 1 | **Detection de tendances** | Haute | Identifier les tags qui apparaissent frequemment sur 24h/7j |
| 2 | **Articles similaires** | Haute | Recommander des articles avec tags communs |
| 3 | **Highlights automatiques** | Moyenne | Extraire 2-3 phrases cles de chaque article |
| 4 | **Scoring personnalise** | Basse | Booster le score selon les preferences de lecture |

### 3.2 Description fonctionnelle

#### 1. Detection de tendances
- Le systeme analyse les tags des articles des dernieres 24h et 7 jours
- Si un tag apparait dans 3+ articles de sources differentes = tendance
- Affichage d'un badge "Trending" sur le dashboard
- Widget "Tendances" en haut du dashboard

#### 2. Articles similaires
- Sur la page detail d'un article, afficher 3-5 articles similaires
- Similarite basee sur : tags communs, meme source, meme topic
- Algorithme de scoring : 2 pts par tag commun, 1 pt meme source

#### 3. Highlights automatiques
- Nouveau prompt IA pour extraire les phrases cles
- Stockage dans une nouvelle colonne `highlights` (JSONB)
- Affichage en surbrillance jaune sur la page detail

#### 4. Scoring personnalise
- Tracker les tags des articles lus par l'utilisateur
- Nouvelle table `user_tag_preferences` avec compteur par tag
- Booster le score de +10% si l'article contient un tag favori

### 3.3 Maquette Dashboard

```
+--------------------------------------------------+
|  TENDANCES (24h)                                 |
|  [#ia] [#cybersecurite] [#cloud]                |
+--------------------------------------------------+
|                                                  |
|  Articles du topic...                            |
|  +--------------------------------------------+  |
|  | [Trending] Article sur l'IA generative     |  |
|  | Score: 92 | Tags: ia, llm, openai          |  |
|  +--------------------------------------------+  |
|                                                  |
+--------------------------------------------------+
```

---

## 4. Implementation technique

### 4.1 Fichiers a modifier/creer

| Fichier | Type | Detail |
|---------|------|--------|
| `supabase/migrations/006_intelligence.sql` | Nouveau | Tables et fonctions pour tendances/preferences |
| `n8n/prompts.json` | Modification | Ajouter prompt "highlights" |
| `web/dashboard.html` | Modification | Widget tendances, badge trending |
| `web/article-detail.html` | Modification | Section articles similaires, highlights |
| `web/style.css` | Modification | Styles pour highlights et tendances |

### 4.2 Schema base de donnees

```sql
-- Table pour tracker les preferences utilisateur par tag
CREATE TABLE public.user_tag_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tag TEXT NOT NULL,
    read_count INTEGER DEFAULT 1,
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, tag)
);

-- Ajouter colonne highlights aux articles
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS
    highlights JSONB DEFAULT '[]';

-- Fonction pour detecter les tendances
CREATE FUNCTION get_trending_tags(hours INTEGER DEFAULT 24, min_occurrences INTEGER DEFAULT 3)
RETURNS TABLE (tag TEXT, occurrence_count BIGINT, source_count BIGINT);

-- Fonction pour articles similaires
CREATE FUNCTION get_similar_articles(article_uuid UUID, limit_count INTEGER DEFAULT 5)
RETURNS TABLE (id UUID, title TEXT, similarity_score INTEGER, ...);

-- Fonction pour mettre a jour les preferences de tags
CREATE FUNCTION update_tag_preferences(article_uuid UUID)
RETURNS void;
```

### 4.3 Nouveau prompt IA (highlights)

```json
{
  "highlights": {
    "description": "Extraction des phrases cles",
    "system": "Tu extrais les 2-3 phrases les plus importantes d'un article.",
    "template": "Extrait les 2-3 phrases les plus importantes de cet article. Reponds en JSON: {\"highlights\": [\"phrase1\", \"phrase2\", \"phrase3\"]}\n\nTitre: {title}\nContenu: {content}"
  }
}
```

---

## 5. Plan d'implementation

1. [x] Creer ce PRD
2. [ ] Migration SQL `006_intelligence.sql`
   - Table `user_tag_preferences`
   - Colonne `highlights` sur articles
   - Fonction `get_trending_tags()`
   - Fonction `get_similar_articles()`
   - Fonction `update_tag_preferences()`
3. [ ] Modifier `n8n/prompts.json` - ajouter prompt highlights
4. [ ] Modifier `web/dashboard.html` - widget tendances
5. [ ] Modifier `web/article-detail.html` - articles similaires + highlights
6. [ ] Modifier `web/style.css` - styles tendances/highlights
7. [ ] Tests de chaque fonctionnalite
8. [ ] Mise a jour ROADMAP.md et inbox.md

---

## 6. Risques et questions ouvertes

| Risque / Question | Impact | Mitigation |
|-------------------|--------|------------|
| Performance avec beaucoup d'articles | Moyen | Index GIN sur tags, limiter la fenetre temporelle |
| Highlights non pertinents | Faible | Fallback si l'IA echoue, afficher resume |
| Pas assez d'articles pour tendances | Faible | Afficher "Pas de tendance detectee" |

---

## 7. Criteres de validation

- [ ] Widget tendances affiche les tags trending sur 24h
- [ ] Badge "Trending" sur les articles concernes
- [ ] Page detail affiche 3-5 articles similaires
- [ ] Highlights affiches en surbrillance
- [ ] Score booste pour les tags preferes de l'utilisateur
- [ ] Pas de regression sur les features existantes
- [ ] Tests manuels passes

---

## 8. Notes de review

> Implementation en cours - 31/12/2024

---

*PRD Kairos v0.4.0 - Intelligence Avancee*
