# scripts/ - Scripts utilitaires

> Scripts d'installation, de maintenance et de test pour Kairos.
>
> **Version:** 0.5.0 | **Derniere MAJ:** 31/12/2024

## En un coup d'oeil

- **8 scripts shell** : setup, start, stop, reset, test, import (Windows + Unix)
- **4 scripts Node.js** : reprocess, fix_encoding, fix_emojis, create-workflows
- **2 scripts SQL** : init-db, test-rls
- **Prerequis** : Docker, Node.js (pour scripts JS)

## Scripts disponibles

### Installation et demarrage

| Script | Windows | Linux/Mac | Description |
|--------|---------|-----------|-------------|
| Setup | `setup.bat` | `setup.sh` | Premier lancement complet |
| Start | `start.bat` | `start.sh` | Demarrer les services |
| Stop | `stop.bat` | `stop.sh` | Arreter les services |
| Reset | `reset.bat` | `reset.sh` | Reset complet (DB + volumes) |

### Workflows n8n

| Script | Windows | Linux/Mac | Description |
|--------|---------|-----------|-------------|
| Import workflows | `import-workflows.bat` | `import-workflows.sh` | Importe les workflows JSON dans n8n |

### Base de donnees

| Fichier | Description |
|---------|-------------|
| `init-db.sql` | Script d'initialisation complet de la DB |
| `test-rls.sql` | Tests des politiques Row Level Security |

### Maintenance des donnees

| Script | Description |
|--------|-------------|
| `reprocess_articles.js` | Re-traite les articles avec l'IA (Node.js) |
| `fix_encoding.js` | Corrige les problemes d'encodage UTF-8 |
| `fix_emojis.js` | Nettoie les emojis mal encodes |
| `create-workflows.js` | Genere les workflows n8n via API |

### Tests

| Script | Windows | Linux/Mac | Description |
|--------|---------|-----------|-------------|
| Test infra | `test-infrastructure.bat` | `test-infrastructure.sh` | Teste tous les services Docker |

## Usage

### Premier lancement

```bash
# Windows
cd scripts
setup.bat

# Linux/Mac
cd scripts
chmod +x *.sh
./setup.sh
```

Le script `setup` effectue :
1. Demarrage des containers Docker
2. Attente de la disponibilite des services
3. Telechargement du modele Gemma 3:4b (~3.3 Go)
4. Import des workflows n8n
5. Creation d'un utilisateur de test

### Utilisation quotidienne

```bash
# Demarrer
./start.sh   # ou start.bat

# Arreter
./stop.sh    # ou stop.bat
```

### Maintenance

```bash
# Re-traiter les articles sans resume
node reprocess_articles.js

# Tester l'infrastructure
./test-infrastructure.sh
```

### Reset complet

```bash
# ATTENTION: Supprime toutes les donnees
./reset.sh
```

## Scripts Node.js

Ces scripts necessitent Node.js et le package `pg` :

```bash
npm install pg
```

### reprocess_articles.js
Re-traite les articles dont le resume est vide ou mal genere :
- Appelle l'API Ollama pour regenerer les resumes
- Met a jour les scores de pertinence
- Regenere les tags

### fix_encoding.js / fix_emojis.js
Corrige les problemes d'encodage dans les titres et contenus d'articles.

## Variables d'environnement

Les scripts utilisent les variables de `docker/.env` :

```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=kairos2024
```

## Logs et debug

Les scripts affichent leur progression en console. Pour plus de details :

```bash
# Voir les logs Docker pendant l'execution
docker-compose -f ../docker/docker-compose.yml logs -f
```
