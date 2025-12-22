const http = require('http');

const apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2MTcyODYyOC02ZWMyLTRkNDUtYjQyNC1lYjY0NzY5MTA2NDMiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MzQxMDUzfQ.5plgMIrCy-GFT2GV2-cj_YzsFgjB6YwMw8Pp_oc3-T4';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1sb2NhbCIsInJvbGUiOiJzZXJ2aWNlX3JvbGUiLCJleHAiOjE5ODM4MTI5OTZ9.CvGPVcSrdWNqg71tF_g4YKevVDnN4F2WdoXh3ce0T7k';

function httpRequest(method, path, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : '';
    const req = http.request({
      hostname: 'localhost',
      port: 5678,
      path: path,
      method: method,
      headers: {
        'X-N8N-API-KEY': apiKey,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

const extractFeedsCode = `
// n8n converts array responses into multiple items
// So we use $input.all() to get all topics
const items = $input.all();
const results = [];

for (const item of items) {
  const topic = item.json;
  if (!topic || !topic.rss_feeds) continue;

  const feeds = topic.rss_feeds || [];
  for (const feedUrl of feeds) {
    results.push({
      json: {
        topic_id: topic.topic_id,
        user_id: topic.user_id,
        topic_name: topic.topic_name,
        feed_url: feedUrl
      }
    });
  }
}

if (results.length === 0) {
  return [{ json: { error: 'No feeds found' } }];
}
return results;
`;

const parseArticlesCode = `
const items = $input.all();
const feedInfo = $('Extract Feeds').first().json;
const results = [];

for (const item of items) {
  if (!item.json.link || !item.json.title) continue;

  let content = item.json.content || item.json.description || '';
  content = content.replace(/<[^>]*>/g, ' ').replace(/\\s+/g, ' ').trim().substring(0, 3000);

  results.push({
    json: {
      topic_id: feedInfo.topic_id,
      user_id: feedInfo.user_id,
      title: item.json.title.trim(),
      url: item.json.link,
      content: content,
      published_date: item.json.pubDate || new Date().toISOString(),
      source: feedInfo.feed_url.split('/')[2] || 'Unknown'
    }
  });
}
return results.slice(0, 10);
`;

(async () => {
  console.log('Suppression des workflows existants...');
  const list = await httpRequest('GET', '/api/v1/workflows');
  for (const wf of list.data.data || []) {
    await httpRequest('DELETE', '/api/v1/workflows/' + wf.id);
    console.log('  Supprime:', wf.name);
  }

  console.log('\nCreation du workflow RSS...');
  const rssWorkflow = {
    name: 'Kairos RSS Processor',
    nodes: [
      {
        parameters: { httpMethod: 'POST', path: 'rss-process', options: {} },
        id: 'webhook',
        name: 'Webhook',
        type: 'n8n-nodes-base.webhook',
        typeVersion: 2,
        position: [0, 0],
        webhookId: 'kairos-rss'
      },
      {
        parameters: {
          rule: { interval: [{ field: 'hours', hoursInterval: 1 }] }
        },
        id: 'schedule',
        name: 'Toutes les heures',
        type: 'n8n-nodes-base.scheduleTrigger',
        typeVersion: 1.2,
        position: [0, 200]
      },
      {
        parameters: {
          method: 'POST',
          url: 'http://kairos-rest:3000/rpc/get_active_topics_with_feeds',
          sendHeaders: true,
          headerParameters: {
            parameters: [
              { name: 'apikey', value: SERVICE_KEY },
              { name: 'Authorization', value: 'Bearer ' + SERVICE_KEY },
              { name: 'Content-Type', value: 'application/json' }
            ]
          },
          options: {}
        },
        id: 'getTopics',
        name: 'Get Topics',
        type: 'n8n-nodes-base.httpRequest',
        typeVersion: 4.2,
        position: [250, 100]
      },
      {
        parameters: { jsCode: extractFeedsCode },
        id: 'extractFeeds',
        name: 'Extract Feeds',
        type: 'n8n-nodes-base.code',
        typeVersion: 2,
        position: [500, 100]
      },
      {
        parameters: {
          url: '={{ $json.feed_url }}',
          options: {}
        },
        id: 'fetchRss',
        name: 'Fetch RSS',
        type: 'n8n-nodes-base.rssFeedRead',
        typeVersion: 1.1,
        position: [750, 100],
        continueOnFail: true
      },
      {
        parameters: { jsCode: parseArticlesCode },
        id: 'parseArticles',
        name: 'Parse Articles',
        type: 'n8n-nodes-base.code',
        typeVersion: 2,
        position: [1000, 100]
      },
      {
        parameters: {
          method: 'POST',
          url: 'http://kairos-rest:3000/articles',
          sendHeaders: true,
          headerParameters: {
            parameters: [
              { name: 'apikey', value: SERVICE_KEY },
              { name: 'Authorization', value: 'Bearer ' + SERVICE_KEY },
              { name: 'Content-Type', value: 'application/json' },
              { name: 'Prefer', value: 'resolution=ignore-duplicates,return=representation' }
            ]
          },
          sendBody: true,
          specifyBody: 'json',
          jsonBody: '={{ JSON.stringify({ topic_id: $json.topic_id, user_id: $json.user_id, title: $json.title, url: $json.url, content: $json.content, published_date: $json.published_date, source: $json.source, read_status: false, bookmarked: false }) }}',
          options: {}
        },
        id: 'insertArticle',
        name: 'Insert Article',
        type: 'n8n-nodes-base.httpRequest',
        typeVersion: 4.2,
        position: [1250, 100],
        continueOnFail: true,
        onError: 'continueRegularOutput'
      }
    ],
    connections: {
      'Webhook': { main: [[{ node: 'Get Topics', type: 'main', index: 0 }]] },
      'Toutes les heures': { main: [[{ node: 'Get Topics', type: 'main', index: 0 }]] },
      'Get Topics': { main: [[{ node: 'Extract Feeds', type: 'main', index: 0 }]] },
      'Extract Feeds': { main: [[{ node: 'Fetch RSS', type: 'main', index: 0 }]] },
      'Fetch RSS': { main: [[{ node: 'Parse Articles', type: 'main', index: 0 }]] },
      'Parse Articles': { main: [[{ node: 'Insert Article', type: 'main', index: 0 }]] }
    },
    settings: { executionOrder: 'v1' }
  };

  const result = await httpRequest('POST', '/api/v1/workflows', rssWorkflow);
  if (result.status === 200) {
    console.log('  Cree avec ID:', result.data.id);
    const act = await httpRequest('POST', '/api/v1/workflows/' + result.data.id + '/activate');
    console.log('  Active:', act.status === 200 ? 'OK' : 'Erreur');
  } else {
    console.log('  Erreur:', result.data.message || result.data);
  }

  console.log('\nTest du workflow...');
  const testReq = http.request({
    hostname: 'localhost',
    port: 5678,
    path: '/webhook/rss-process',
    method: 'POST'
  }, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
      console.log('  Reponse:', body);

      // Attendre et verifier
      setTimeout(async () => {
        const execs = await httpRequest('GET', '/api/v1/executions');
        const lastExec = execs.data.data?.[0];
        if (lastExec) {
          console.log('\nDerniere execution:');
          console.log('  Status:', lastExec.status);
          console.log('  Duree:', lastExec.stoppedAt ?
            (new Date(lastExec.stoppedAt) - new Date(lastExec.startedAt)) + 'ms' : 'En cours');
        }
        console.log('\nTermine!');
      }, 5000);
    });
  });
  testReq.end();
})();
