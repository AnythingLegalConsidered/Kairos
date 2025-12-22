# Plan de Tests Exhaustif - Kairos

Ce document contient tous les tests a effectuer pour valider le bon fonctionnement de la plateforme Kairos.

---

## 1. Tests Infrastructure Docker

### 1.1 Demarrage des services
- [ ] `docker-compose up -d` demarre sans erreur
- [ ] Tous les containers sont en status "healthy" ou "running"
- [ ] Les ports sont correctement exposes:
  - [ ] 3000 - Kong API Gateway
  - [ ] 5432 - PostgreSQL
  - [ ] 8000 - Supabase API
  - [ ] 5678 - n8n
  - [ ] 11434 - Ollama
  - [ ] 80 - Nginx (frontend)

### 1.2 Verification des containers
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Containers attendus:
- [ ] kairos-db (PostgreSQL)
- [ ] kairos-kong (API Gateway)
- [ ] kairos-auth (GoTrue)
- [ ] kairos-rest (PostgREST)
- [ ] kairos-n8n
- [ ] kairos-ollama
- [ ] kairos-nginx

### 1.3 Logs sans erreurs critiques
- [ ] `docker logs kairos-db` - pas d'erreur fatale
- [ ] `docker logs kairos-auth` - pas d'erreur fatale
- [ ] `docker logs kairos-n8n` - pas d'erreur fatale
- [ ] `docker logs kairos-ollama` - modele charge correctement

---

## 2. Tests Base de Donnees (Supabase/PostgreSQL)

### 2.1 Connexion
- [ ] Connexion via psql fonctionne
- [ ] Connexion via Supabase Studio fonctionne (si active)

### 2.2 Schema
Verifier l'existence des tables:
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
```

Tables attendues:
- [ ] users (geree par auth.users)
- [ ] topics
- [ ] articles
- [ ] rss_sources
- [ ] user_preferences

### 2.3 Colonnes des tables principales

**Table topics:**
- [ ] id (uuid, PK)
- [ ] user_id (uuid, FK -> auth.users)
- [ ] topic_name (text)
- [ ] description (text)
- [ ] rss_feeds (text[])
- [ ] active (boolean)
- [ ] created_at (timestamptz)
- [ ] updated_at (timestamptz)

**Table articles:**
- [ ] id (uuid, PK)
- [ ] user_id (uuid, FK)
- [ ] topic_id (uuid, FK -> topics)
- [ ] title (text)
- [ ] summary (text)
- [ ] content (text)
- [ ] source (text)
- [ ] url (text)
- [ ] published_date (timestamptz)
- [ ] relevance_score (integer 1-5)
- [ ] sentiment (text: positive/neutral/negative)
- [ ] read_status (boolean)
- [ ] bookmarked (boolean)
- [ ] tags (text[])
- [ ] created_at (timestamptz)

### 2.4 Index et performances
- [ ] Index sur articles.user_id existe
- [ ] Index sur articles.topic_id existe
- [ ] Index sur articles.created_at existe
- [ ] Index sur topics.user_id existe

---

## 3. Tests Politiques RLS (Row Level Security)

### 3.1 Preparation
Creer 2 utilisateurs de test:
- User A: test-a@kairos.local
- User B: test-b@kairos.local

### 3.2 Tests d'isolation

**Test 1: User A ne voit pas les topics de User B**
```sql
-- En tant que User A
SELECT * FROM topics WHERE user_id = '<user_b_id>';
-- Resultat attendu: 0 lignes
```
- [ ] PASSE

**Test 2: User A ne peut pas modifier les topics de User B**
```sql
-- En tant que User A
UPDATE topics SET topic_name = 'Hacked' WHERE user_id = '<user_b_id>';
-- Resultat attendu: 0 lignes affectees
```
- [ ] PASSE

**Test 3: User A ne peut pas supprimer les articles de User B**
```sql
-- En tant que User A
DELETE FROM articles WHERE user_id = '<user_b_id>';
-- Resultat attendu: 0 lignes affectees
```
- [ ] PASSE

**Test 4: User A peut creer ses propres topics**
- [ ] PASSE

**Test 5: User A peut modifier ses propres articles**
- [ ] PASSE

**Test 6: Acces anonyme refuse**
```sql
-- Sans authentification
SELECT * FROM topics;
-- Resultat attendu: Erreur ou 0 lignes
```
- [ ] PASSE

---

## 4. Tests Authentification

### 4.1 Inscription
- [ ] Inscription avec email valide fonctionne
- [ ] Inscription avec email invalide affiche erreur
- [ ] Inscription avec mot de passe < 6 caracteres refuse
- [ ] Confirmation des mots de passe differents affiche erreur
- [ ] Email de confirmation envoye (si configure)

### 4.2 Connexion
- [ ] Connexion avec credentials corrects fonctionne
- [ ] Connexion avec mauvais mot de passe affiche erreur
- [ ] Connexion avec email inexistant affiche erreur
- [ ] Redirection vers index.html apres connexion reussie
- [ ] Session persistee (refresh de page garde la connexion)

### 4.3 Deconnexion
- [ ] Bouton deconnexion visible quand connecte
- [ ] Clic sur deconnexion supprime la session
- [ ] Redirection vers index.html apres deconnexion
- [ ] Acces au dashboard redirige vers login si deconnecte

### 4.4 Reinitialisation mot de passe
- [ ] Lien "Mot de passe oublie" visible sur login
- [ ] Email de reinitialisation envoye (si SMTP configure)
- [ ] Page reset-password.html accessible via le lien email
- [ ] Nouveau mot de passe enregistre correctement
- [ ] Message d'erreur si lien expire/invalide

### 4.5 Protection des routes
- [ ] /dashboard.html redirige vers login si non connecte
- [ ] /topic-setup.html redirige vers login si non connecte
- [ ] /article-detail.html redirige vers login si non connecte

---

## 5. Tests Frontend - Page par Page

### 5.1 index.html (Accueil)
- [ ] Page charge sans erreur console
- [ ] Stats affichees (topics, articles, non lus)
- [ ] Stats affichent "-" si erreur de chargement
- [ ] Lien vers login si non connecte
- [ ] Menu utilisateur si connecte
- [ ] Toggle theme fonctionne
- [ ] Theme persiste apres refresh

### 5.2 login.html (Authentification)
- [ ] Onglets Connexion/Inscription fonctionnent
- [ ] Validation cote client (champs requis)
- [ ] Messages d'erreur clairs
- [ ] Spinner pendant le chargement
- [ ] Toast notifications fonctionnent
- [ ] Redirection si deja connecte

### 5.3 dashboard.html (Tableau de bord)
**Chargement:**
- [ ] Skeleton loaders visibles pendant chargement
- [ ] Stats chargent et s'affichent
- [ ] Liste des topics dans la sidebar
- [ ] Articles affiches dans la grille

**Filtres:**
- [ ] Filtre "Tous" affiche tous les articles
- [ ] Filtre "Non lus" affiche uniquement non lus
- [ ] Filtre "Pertinents" affiche score >= 4
- [ ] Filtre "Favoris" affiche bookmarked = true
- [ ] Filtres avances (date, score, sentiment) fonctionnent
- [ ] Bouton "Reinitialiser" remet les filtres par defaut
- [ ] Recherche filtre par titre et resume
- [ ] Debounce sur la recherche (pas de requete a chaque caractere)

**Pagination:**
- [ ] Pagination affichee si > articlesPerPage
- [ ] Navigation entre pages fonctionne
- [ ] Selection du nombre par page (5/10/20/50)
- [ ] Preference sauvegardee dans localStorage

**Actions articles:**
- [ ] Clic sur titre ouvre article-detail
- [ ] Bouton externe ouvre l'URL originale
- [ ] Toggle bookmark fonctionne (UI optimiste)
- [ ] Mark as read fonctionne (UI optimiste)
- [ ] Toast affiche en cas d'erreur
- [ ] Rollback si erreur serveur

**Gestion topics:**
- [ ] Bouton modifier ouvre le modal
- [ ] Modification du nom fonctionne
- [ ] Modification de la description fonctionne
- [ ] Ajout/suppression de flux RSS fonctionne
- [ ] Bouton supprimer ouvre confirmation
- [ ] Suppression (soft delete) fonctionne
- [ ] Loading state sur les boutons du modal

**Export:**
- [ ] Menu export s'ouvre au clic
- [ ] Export CSV telecharge le fichier
- [ ] Export JSON telecharge le fichier
- [ ] Fichiers contiennent les bonnes donnees
- [ ] Filtres appliques a l'export
- [ ] BOM UTF-8 present (ouverture Excel correcte)

**Accessibilite:**
- [ ] Navigation clavier fonctionne
- [ ] ARIA labels presents
- [ ] Focus visible sur elements interactifs

### 5.4 topic-setup.html (Creation topic)
- [ ] Formulaire charge correctement
- [ ] Champ nom obligatoire valide
- [ ] Selection des sources RSS par categorie
- [ ] Boutons "Tout FR" / "Tout EN" fonctionnent
- [ ] Ajout de source RSS personnalisee
- [ ] Validation URL (doit commencer par http)
- [ ] Detection doublons RSS
- [ ] Traduction IA fonctionne (si Ollama actif)
- [ ] Sauvegarde du topic fonctionne
- [ ] Redirection vers dashboard apres creation
- [ ] Toast de confirmation affiche

### 5.5 article-detail.html (Detail article)
- [ ] Article charge depuis l'URL (?id=xxx)
- [ ] Titre, source, date affiches
- [ ] Resume IA affiche
- [ ] Score de pertinence affiche
- [ ] Sentiment affiche avec badge
- [ ] Tags affiches (si presents)
- [ ] Bouton "Lire l'article" ouvre URL externe
- [ ] Toggle bookmark fonctionne
- [ ] Bouton partage fonctionne (Web Share API ou clipboard)
- [ ] Lien retour au dashboard fonctionne
- [ ] Message d'erreur si article non trouve

### 5.6 reset-password.html (Reinitialisation)
- [ ] Page accessible via lien email
- [ ] Formulaire de nouveau mot de passe
- [ ] Validation mot de passe >= 6 caracteres
- [ ] Confirmation mot de passe
- [ ] Message succes apres changement
- [ ] Redirection vers login
- [ ] Message erreur si lien invalide/expire

---

## 6. Tests Workflows n8n

### 6.1 Acces n8n
- [ ] Interface n8n accessible sur http://localhost:5678
- [ ] Connexion avec credentials configures
- [ ] Workflows importes visibles

### 6.2 Workflow RSS Processor
**Declenchement:**
- [ ] Trigger manuel fonctionne
- [ ] Trigger cron programme (verifier schedule)
- [ ] Trigger webhook fonctionne

**Execution:**
- [ ] Recuperation des topics actifs
- [ ] Fetch des flux RSS
- [ ] Parsing des articles
- [ ] Deduplication par URL
- [ ] Nettoyage HTML

**Integration IA:**
- [ ] Appel Ollama pour resume
- [ ] Appel Ollama pour score pertinence
- [ ] Appel Ollama pour sentiment
- [ ] Timeout respecte (60s resume, 30s autres)
- [ ] Fallback en cas d'erreur IA

**Sauvegarde:**
- [ ] Articles sauvegardes dans Supabase
- [ ] user_id correctement assigne
- [ ] topic_id correctement assigne
- [ ] Pas de doublons crees

### 6.3 Workflow Cleanup
- [ ] Suppression articles > 30 jours
- [ ] Conservation articles bookmarked
- [ ] Logs de suppression

### 6.4 Workflow Notifications (si configure)
- [ ] Detection articles haute pertinence
- [ ] Envoi email (si SMTP configure)

---

## 7. Tests Integration IA (Ollama)

### 7.1 Service Ollama
- [ ] Container kairos-ollama running
- [ ] API accessible sur http://localhost:11434
- [ ] Modele gemma3:4b charge

### 7.2 Test API directe
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "gemma3:4b",
  "prompt": "Bonjour, reponds en francais.",
  "stream": false
}'
```
- [ ] Reponse recue en < 60s
- [ ] Reponse coherente en francais

### 7.3 Tests prompts specifiques

**Resume:**
- [ ] Resume genere en 2-3 phrases
- [ ] Resume en francais
- [ ] Resume coherent avec le contenu

**Pertinence:**
- [ ] Score entre 0 et 100
- [ ] Score coherent avec les mots-cles

**Sentiment:**
- [ ] Valeur: positive, neutral, ou negative
- [ ] Sentiment coherent avec le contenu

---

## 8. Tests de Performance

### 8.1 Temps de chargement
- [ ] Page d'accueil < 2s
- [ ] Dashboard avec 100 articles < 3s
- [ ] Export 1000 articles < 5s

### 8.2 Memoire
- [ ] Utilisation memoire Docker stable
- [ ] Pas de memory leak sur refresh repetes

### 8.3 Requetes
- [ ] Debounce recherche effectif (1 requete/300ms max)
- [ ] Pas de requetes dupliquees

---

## 9. Tests de Securite

### 9.1 Authentification
- [ ] Tokens JWT expires apres duree configuree
- [ ] Refresh token fonctionne
- [ ] Pas de token dans les URLs

### 9.2 Injection
- [ ] XSS: contenu HTML echappe correctement
- [ ] SQL Injection: requetes parametrees

### 9.3 CORS
- [ ] Requetes cross-origin bloquees (sauf origines autorisees)

### 9.4 Donnees sensibles
- [ ] Mots de passe hashes (bcrypt)
- [ ] .env non commit dans git
- [ ] Credentials n8n securises

---

## 10. Tests Cross-Browser

### 10.1 Navigateurs desktop
- [ ] Chrome (derniere version)
- [ ] Firefox (derniere version)
- [ ] Safari (derniere version)
- [ ] Edge (derniere version)

### 10.2 Mobile
- [ ] Chrome Android
- [ ] Safari iOS
- [ ] Responsive design fonctionne

---

## 11. Tests Mode Sombre

- [ ] Toggle bascule correctement
- [ ] Preference sauvegardee
- [ ] Toutes les pages supportent le mode sombre
- [ ] Contraste suffisant (WCAG AA)
- [ ] Skeleton loaders adaptes au theme

---

## Rapport de Tests

| Section | Tests Passes | Tests Echoues | Notes |
|---------|--------------|---------------|-------|
| Docker | /7 | | |
| Base de donnees | /15 | | |
| RLS | /6 | | |
| Authentification | /15 | | |
| Frontend | /50+ | | |
| n8n | /15 | | |
| IA | /8 | | |
| Performance | /5 | | |
| Securite | /6 | | |
| Cross-browser | /6 | | |
| Mode sombre | /5 | | |

**Date des tests:** _______________
**Testeur:** _______________
**Version testee:** _______________

---

## Commandes utiles pour les tests

```bash
# Verifier les containers
docker ps

# Logs d'un container
docker logs kairos-db -f

# Connexion PostgreSQL
docker exec -it kairos-db psql -U postgres -d postgres

# Test API Ollama
curl http://localhost:11434/api/tags

# Test API Supabase
curl http://localhost:8000/rest/v1/topics -H "apikey: YOUR_ANON_KEY"

# Redemarrer un service
docker restart kairos-n8n
```
