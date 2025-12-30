# docs/ - Documentation technique

> Documentation, plans de tests et rapports pour Kairos.

## Fichiers

| Fichier | Description |
|---------|-------------|
| `TESTS.md` | Plan de tests complet (infrastructure, auth, RLS, IA, frontend) |
| `RAPPORT_TESTS.md` | Resultats des tests executes (32/32 passes) |

## Plan de tests (TESTS.md)

Le plan couvre 6 categories :

### 1. Infrastructure Docker (9 tests)
- Demarrage des containers
- Connectivite reseau
- Volumes persistants
- Health checks

### 2. Authentification Supabase (4 tests)
- Inscription utilisateur
- Connexion/deconnexion
- Recuperation de session
- Tokens JWT

### 3. Row Level Security (3 tests)
- Isolation des donnees par utilisateur
- Acces interdit aux donnees d'autrui
- Service role bypass

### 4. Integration IA (3 tests)
- Disponibilite Ollama
- Generation de resume
- Score de pertinence

### 5. Frontend (6 tests)
- Rendu des pages
- Navigation
- Formulaires
- Mode sombre

### 6. Workflows n8n (7 tests)
- Import des workflows
- Declenchement RSS Processor
- Traitement des articles
- Cleanup automatique

## Rapport de tests (RAPPORT_TESTS.md)

Derniere execution : **21 decembre 2024**

| Categorie | Passes | Total | Status |
|-----------|--------|-------|--------|
| Infrastructure | 9 | 9 | OK |
| Authentification | 4 | 4 | OK |
| RLS | 3 | 3 | OK |
| Integration IA | 3 | 3 | OK |
| Frontend | 6 | 6 | OK |
| Workflows | 7 | 7 | OK |
| **TOTAL** | **32** | **32** | **100%** |

## Executer les tests

### Tests infrastructure
```bash
# Windows
scripts\test-infrastructure.bat

# Linux/Mac
./scripts/test-infrastructure.sh
```

### Tests RLS
```bash
docker exec -i kairos-db psql -U postgres < scripts/test-rls.sql
```

### Tests manuels frontend
1. Ouvrir http://localhost:3000
2. Suivre le plan dans TESTS.md section 5

## Ajouter de nouveaux tests

1. Documenter le test dans `TESTS.md`
2. Creer le script si automatisable
3. Executer et documenter les resultats dans `RAPPORT_TESTS.md`
