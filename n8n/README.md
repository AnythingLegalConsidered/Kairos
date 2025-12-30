# n8n/ - Workflows d'orchestration

> Workflows n8n pour l'automatisation du traitement RSS et IA.

## Structure

```
n8n/
├── README.md           # CE FICHIER
├── prompts.json        # Prompts IA pour Gemma (resume, pertinence, tags)
├── exemple             # Exemple de workflow (reference)
└── workflows/
    ├── rss_processor.json      # Workflow principal
    ├── rss_processor_test.json # Version de test
    └── cleanup.json            # Nettoyage des vieux articles
```

## Workflows disponibles

| Workflow | Fichier | Declenchement | Description |
|----------|---------|---------------|-------------|
| **RSS Processor** | `rss_processor.json` | Toutes les heures + Webhook | Fetch RSS, traitement IA, insertion DB |
| **Cleanup** | `cleanup.json` | Tous les jours a 3h | Supprime articles > 30j |
| **Notifications** | `notifications.json` | Tous les jours a 8h | Digest email quotidien |

---

## Configuration initiale

### 1. Demarrer l'infrastructure

```bash
cd docker
docker-compose up -d
```

### 2. Acceder a n8n

- **URL**: http://localhost:5678
- **Login**: admin
- **Password**: kairos2024

### 3. Configurer la variable d'environnement

Dans n8n, allez dans **Settings > Variables** et creez:

| Variable | Valeur |
|----------|--------|
| `SUPABASE_SERVICE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1sb2NhbCIsInJvbGUiOiJzZXJ2aWNlX3JvbGUiLCJleHAiOjE5ODM4MTI5OTZ9.CvGPVcSrdWNqg71tF_g4YKevVDnN4F2WdoXh3ce0T7k` |

> **Note**: Cette cle est une cle de demo. En production, generez une cle avec votre propre `JWT_SECRET`.

### 4. Importer les workflows

1. Dans n8n, cliquez sur **"..."** > **Import from File**
2. Selectionnez chaque fichier JSON dans `n8n/workflows/`:
   - `rss_processor.json`
   - `cleanup.json`
   - `notifications.json`
3. **Activez** chaque workflow apres l'import

---

## Architecture des workflows

### RSS Processor (Principal)

```
Cron (1h) / Webhook
       |
       v
[Get Active Topics] --> RPC get_active_topics_with_feeds
       |
       v
[Split Topics] --> Pour chaque topic
       |
       v
[Extract Feeds] --> Pour chaque RSS feed
       |
       v
[Fetch RSS] --> Recupere les articles
       |
       v
[Parse Articles] --> Nettoie HTML, extrait metadata
       |
       v
[Dedupe URLs] --> Evite les doublons
       |
       v
[Insert Article] --> POST /articles (Supabase)
       |
       v
[IA - Resume] --> Ollama gemma3:4b
       |
       v
[IA - Pertinence] --> Score 0-100
       |
       v
[IA - Sentiment] --> positive/neutral/negative
       |
       v
[Update Article] --> PATCH avec resultats IA
```

### Cleanup

```
Cron (3h) / Webhook
       |
       +---> [Delete > 30 jours] --> RPC cleanup_old_articles
       |
       +---> [Delete archives > 90j] --> DELETE /articles
       |
       v
[Merge Results] --> Resume final
```

### Notifications

```
Cron (8h) / Webhook          Cron (1h)
       |                          |
       v                          v
[Articles >= 80%]         [Articles >= 90%]
       |                          |
       v                          v
[Generate Digest HTML]    [Generate Alert]
       |
       v
[Send Email] (desactive par defaut)
```

---

## Endpoints Webhook

Apres activation des workflows, les webhooks suivants sont disponibles:

| Workflow | URL Webhook |
|----------|-------------|
| RSS Processor | `http://localhost:5678/webhook/rss-process` |
| Cleanup | `http://localhost:5678/webhook/cleanup` |
| Notifications | `http://localhost:5678/webhook/send-digest` |

### Tester manuellement

```bash
# Declencher le traitement RSS
curl -X POST http://localhost:5678/webhook/rss-process

# Declencher le cleanup
curl -X POST http://localhost:5678/webhook/cleanup

# Declencher le digest
curl -X POST http://localhost:5678/webhook/send-digest
```

---

## Troubleshooting

### Erreur "SUPABASE_SERVICE_KEY not found"

1. Dans n8n: **Settings > Variables**
2. Ajoutez `SUPABASE_SERVICE_KEY` avec la valeur JWT

### Erreur de connexion a Ollama

1. Verifiez que le conteneur est demarre:
   ```bash
   docker ps | grep ollama
   ```
2. Verifiez que le modele est telecharge:
   ```bash
   docker exec kairos-ollama ollama list
   ```
3. Si le modele manque:
   ```bash
   docker exec kairos-ollama ollama pull gemma3:4b
   ```

### Erreur de connexion a PostgreSQL

1. Verifiez le conteneur:
   ```bash
   docker ps | grep kairos-db
   ```
2. Verifiez les logs:
   ```bash
   docker logs kairos-db
   ```

### Les articles ne sont pas inseres

1. Verifiez qu'il y a des topics actifs avec des feeds RSS
2. Testez l'API directement:
   ```bash
   curl -X POST http://localhost:3001/rpc/get_active_topics_with_feeds \
     -H "apikey: SERVICE_ROLE_KEY" \
     -H "Authorization: Bearer SERVICE_ROLE_KEY"
   ```

---

## Configuration Email (Optionnel)

Pour activer les notifications par email:

1. Configurez SMTP dans `docker/.env`:
   ```
   SMTP_HOST=smtp.example.com
   SMTP_PORT=587
   SMTP_USER=your-email@example.com
   SMTP_PASS=your-password
   ```

2. Dans le workflow **Notifications**, activez le noeud "Envoyer Email"

3. Configurez les credentials SMTP dans n8n:
   - **Settings > Credentials > Add Credential > SMTP**

---

## Mise a jour des workflows

Si vous modifiez les fichiers JSON:

1. Supprimez le workflow existant dans n8n
2. Re-importez le fichier modifie
3. Re-activez le workflow

Les workflows ne se synchronisent pas automatiquement avec les fichiers JSON.

---

## Prompts IA (prompts.json)

Le fichier `prompts.json` centralise tous les prompts utilises par l'IA :

| Prompt | Description | Output |
|--------|-------------|--------|
| `summary` | Resume d'article en 2-3 phrases | Texte francais |
| `relevance` | Score de pertinence | Nombre 0-100 |
| `tags` | Generation de tags | Liste separee par virgules |

### Parametres du modele

```json
{
  "model": "gemma3:4b",
  "temperature": 0.3,
  "num_predict": 200,
  "top_p": 0.9
}
```

### Modifier un prompt

1. Editer `prompts.json`
2. Mettre a jour le noeud correspondant dans le workflow n8n
3. Tester avec quelques articles
4. Exporter le workflow modifie

---

## Integration avec Supabase

Les workflows utilisent l'API REST Supabase via Kong :

```
URL: http://kairos-kong:8000
Auth: Bearer {{ $env.SUPABASE_SERVICE_KEY }}
```

### Endpoints utilises

| Methode | Endpoint | Usage |
|---------|----------|-------|
| POST | `/rest/v1/rpc/get_active_topics_with_feeds` | Liste des topics |
| POST | `/rest/v1/articles` | Insertion d'article |
| PATCH | `/rest/v1/articles?id=eq.{id}` | Mise a jour IA |
| DELETE | `/rest/v1/articles?...` | Cleanup |

---

## Integration avec Ollama

L'IA locale est accessible via :

```
URL: http://kairos-ollama:11434
Endpoint: POST /api/generate
Model: gemma3:4b
```

### Format de requete

```json
{
  "model": "gemma3:4b",
  "prompt": "...",
  "stream": false,
  "options": {
    "temperature": 0.3,
    "num_predict": 200
  }
}
```
