# docker/ - Infrastructure Docker

> Configuration Docker Compose pour l'environnement de developpement local Kairos.

## Fichiers

| Fichier | Description |
|---------|-------------|
| `docker-compose.yml` | Orchestration de tous les services |
| `.env.example` | Template des variables d'environnement |
| `.env` | Variables d'environnement (non versionne) |
| `kong.yml` | Configuration de l'API Gateway Kong |
| `nginx/nginx.conf` | Configuration du serveur web frontend |

## Services deployes

| Service | Container | Port | Description |
|---------|-----------|------|-------------|
| **PostgreSQL** | kairos-db | 5432 | Base de donnees Supabase |
| **GoTrue** | kairos-auth | 9999 | Authentification Supabase |
| **PostgREST** | kairos-rest | 3001 | API REST auto-generee |
| **Kong** | kairos-kong | 8000 | API Gateway |
| **Studio** | kairos-studio | 3002 | Interface admin Supabase |
| **Meta** | kairos-meta | - | Metadata service |
| **n8n** | kairos-n8n | 5678 | Orchestration workflows |
| **Ollama** | kairos-ollama | 11434 | Serveur IA local |
| **Nginx** | kairos-frontend | 3000 | Serveur web frontend |

## Commandes

```bash
# Demarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f [service]

# Arreter tous les services
docker-compose down

# Reset complet (supprime les volumes)
docker-compose down -v
```

## Architecture reseau

Tous les services sont sur le reseau `kairos-network` et peuvent communiquer entre eux via leurs noms de container :

```
kairos-frontend (nginx)
       |
       v
kairos-kong (API Gateway) --> kairos-auth (GoTrue)
       |                  --> kairos-rest (PostgREST)
       v
kairos-db (PostgreSQL)

kairos-n8n --> kairos-db (via PostgREST)
           --> kairos-ollama (via HTTP)
```

## Volumes persistants

| Volume | Contenu |
|--------|---------|
| `supabase-db-data` | Donnees PostgreSQL |
| `n8n-data` | Configuration et workflows n8n |
| `ollama-data` | Modeles IA telecharges |

## Variables d'environnement importantes

```bash
# Copier le template
cp .env.example .env

# Variables cles a configurer
JWT_SECRET=           # Secret pour les tokens JWT (32+ chars)
POSTGRES_PASSWORD=    # Mot de passe PostgreSQL
N8N_BASIC_AUTH_PASSWORD=  # Mot de passe admin n8n
```

## GPU Support (Ollama)

Pour activer le support GPU NVIDIA, decommenter dans `docker-compose.yml` :

```yaml
ollama:
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
```

## Prerequis

- Docker Engine 20.10+
- Docker Compose v2+
- 8 Go de RAM minimum
- 10 Go d'espace disque (dont 3.3 Go pour Gemma)
