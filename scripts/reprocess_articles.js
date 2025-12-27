const http = require('http');
const { Client } = require('pg');

const OLLAMA_HOST = 'localhost';
const OLLAMA_PORT = 11434;
const TOPIC_NAME = 'Fusion Nucléaire';
const KEYWORDS = 'fusion, nucléaire, nuclear, fusion';

async function callOllama(prompt, system, numPredict = 8) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      model: 'gemma3:4b',
      prompt: prompt,
      system: system,
      stream: false,
      options: { temperature: 0.3, num_predict: numPredict }
    });

    const req = http.request({
      hostname: OLLAMA_HOST,
      port: OLLAMA_PORT,
      path: '/api/generate',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          resolve(json.response || '');
        } catch(e) { resolve(''); }
      });
    });
    req.on('error', reject);
    req.setTimeout(120000);
    req.write(data);
    req.end();
  });
}

async function getRelevanceScore(title, content) {
  const prompt = `Tu dois noter la PERTINENCE de cet article par rapport au sujet de veille.

SUJET DE VEILLE: ${TOPIC_NAME}
MOTS-CLES DU SUJET: ${KEYWORDS}

ARTICLE A EVALUER:
Titre: ${title}
Contenu: ${content.substring(0, 1500)}

INSTRUCTIONS:
Donne une note PRECISE entre 0 et 100 (pas une note sur 5 ou 10).

Exemples de notes attendues:
- Un article 100% sur le sujet = 92 ou 87 ou 95
- Un article partiellement lie = 58 ou 63 ou 71
- Un article peu lie = 34 ou 41 ou 28
- Un article sans rapport = 12 ou 8 ou 15

ATTENTION: Ne reponds PAS par 1, 2, 3, 4 ou 5. Reponds par un nombre entre 0 et 100.

TA NOTE (un seul nombre entre 0 et 100):`;

  const system = 'Tu es un evaluateur. Tu donnes une note de pertinence entre 0 et 100. Tu reponds UNIQUEMENT par un nombre entier. Exemples de reponses valides: 73, 45, 88, 91, 34, 67.';

  const response = await callOllama(prompt, system, 8);
  const match = response.match(/\d+/);
  return match ? Math.min(100, Math.max(0, parseInt(match[0]))) : 50;
}

async function getSummary(title, content) {
  const prompt = `Resume cet article en 2-3 phrases concises en francais. Concentre-toi sur les informations cles.

Titre: ${title}
Contenu: ${content.substring(0, 3000)}`;

  const system = 'Tu es un assistant specialise dans le resume. Tu reponds en francais, de maniere concise.';
  return await callOllama(prompt, system, 200);
}

async function getTags(title, summary) {
  const prompt = `Genere 3 a 5 tags pertinents pour cet article. Tags en minuscules, separes par virgules.

Titre: ${title}
Resume: ${summary}`;

  const system = 'Tu generes des tags pertinents en minuscules, separes par des virgules.';
  const response = await callOllama(prompt, system, 50);

  return response
    .split(',')
    .map(t => t.trim().toLowerCase().replace(/[^a-zàâäéèêëïîôùûüç0-9-\s]/g, '').trim())
    .filter(t => t.length > 0 && t.length < 30)
    .slice(0, 5);
}

async function main() {
  const client = new Client({
    host: 'localhost',
    port: 5432,
    database: 'postgres',
    user: 'postgres',
    password: 'your-super-secret-password-change-me'
  });

  await client.connect();
  console.log('Connected to database');

  const result = await client.query(
    'SELECT id, title, content FROM articles WHERE relevance_score IS NULL ORDER BY created_at DESC'
  );

  console.log(`Found ${result.rows.length} articles to process`);

  for (let i = 0; i < result.rows.length; i++) {
    const article = result.rows[i];
    console.log(`\n[${i + 1}/${result.rows.length}] Processing: ${article.title.substring(0, 50)}...`);

    try {
      // Get summary
      console.log('  - Generating summary...');
      const summary = await getSummary(article.title, article.content || article.title);

      // Get relevance score
      console.log('  - Calculating relevance...');
      const score = await getRelevanceScore(article.title, summary || article.content || article.title);
      console.log(`  - Score: ${score}`);

      // Get tags
      console.log('  - Generating tags...');
      const tags = await getTags(article.title, summary);
      console.log(`  - Tags: ${tags.join(', ')}`);

      // Update database
      await client.query(
        'UPDATE articles SET relevance_score = $1, summary = $2, tags = $3 WHERE id = $4',
        [score, summary, tags, article.id]
      );
      console.log('  - Updated!');

      // Small delay to not overload Ollama
      await new Promise(r => setTimeout(r, 500));

    } catch (error) {
      console.error(`  - Error: ${error.message}`);
    }
  }

  await client.end();
  console.log('\nDone!');
}

main().catch(console.error);
