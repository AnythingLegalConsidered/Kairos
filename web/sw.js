// sw.js - Kairos Service Worker
// Purpose: Enable PWA features (offline support, caching)
// Version: 0.5.0

const CACHE_NAME = 'kairos-v0.5.0';
const STATIC_ASSETS = [
    '/',
    '/index.html',
    '/dashboard.html',
    '/kanban.html',
    '/sources.html',
    '/topic-setup.html',
    '/article-detail.html',
    '/login.html',
    '/style.css',
    '/config.js',
    '/theme.js',
    '/toast.js',
    '/intelligence.js',
    '/manifest.json'
];

// External resources to cache
const EXTERNAL_ASSETS = [
    'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Merriweather:ital,wght@0,300;0,400;0,700;1,400&display=swap'
];

// ============================================
// INSTALL - Cache static assets
// ============================================
self.addEventListener('install', (event) => {
    console.log('[SW] Installing service worker...');

    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => {
                console.log('[SW] Caching static assets');
                return cache.addAll(STATIC_ASSETS);
            })
            .then(() => {
                // Skip waiting to activate immediately
                return self.skipWaiting();
            })
            .catch((error) => {
                console.error('[SW] Cache failed:', error);
            })
    );
});

// ============================================
// ACTIVATE - Clean old caches
// ============================================
self.addEventListener('activate', (event) => {
    console.log('[SW] Activating service worker...');

    event.waitUntil(
        caches.keys()
            .then((cacheNames) => {
                return Promise.all(
                    cacheNames
                        .filter((name) => name !== CACHE_NAME)
                        .map((name) => {
                            console.log('[SW] Deleting old cache:', name);
                            return caches.delete(name);
                        })
                );
            })
            .then(() => {
                // Take control of all pages immediately
                return self.clients.claim();
            })
    );
});

// ============================================
// FETCH - Network-first for API, Cache-first for static
// ============================================
self.addEventListener('fetch', (event) => {
    const { request } = event;
    const url = new URL(request.url);

    // Skip non-GET requests
    if (request.method !== 'GET') return;

    // Skip chrome-extension and other protocols
    if (!url.protocol.startsWith('http')) return;

    // API calls (Supabase) - Network first
    if (url.hostname.includes('supabase') || url.pathname.startsWith('/rest/')) {
        event.respondWith(networkFirst(request));
        return;
    }

    // Static assets - Cache first
    if (isStaticAsset(url.pathname)) {
        event.respondWith(cacheFirst(request));
        return;
    }

    // HTML pages - Network first with offline fallback
    if (request.headers.get('accept')?.includes('text/html')) {
        event.respondWith(networkFirstWithOffline(request));
        return;
    }

    // Everything else - Network first
    event.respondWith(networkFirst(request));
});

// ============================================
// CACHING STRATEGIES
// ============================================

// Cache first - for static assets
async function cacheFirst(request) {
    const cached = await caches.match(request);
    if (cached) {
        return cached;
    }

    try {
        const response = await fetch(request);
        if (response.ok) {
            const cache = await caches.open(CACHE_NAME);
            cache.put(request, response.clone());
        }
        return response;
    } catch (error) {
        console.error('[SW] Fetch failed:', error);
        return new Response('Offline', { status: 503 });
    }
}

// Network first - for API calls
async function networkFirst(request) {
    try {
        const response = await fetch(request);
        return response;
    } catch (error) {
        const cached = await caches.match(request);
        if (cached) {
            return cached;
        }
        return new Response(JSON.stringify({ error: 'Offline' }), {
            status: 503,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}

// Network first with offline page fallback
async function networkFirstWithOffline(request) {
    try {
        const response = await fetch(request);
        if (response.ok) {
            const cache = await caches.open(CACHE_NAME);
            cache.put(request, response.clone());
        }
        return response;
    } catch (error) {
        const cached = await caches.match(request);
        if (cached) {
            return cached;
        }

        // Return offline page
        const offlineHtml = `
            <!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Kairos - Hors ligne</title>
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        min-height: 100vh;
                        margin: 0;
                        background: #fefaf6;
                        color: #2c2416;
                        text-align: center;
                        padding: 2rem;
                    }
                    .offline-container {
                        max-width: 400px;
                    }
                    h1 { font-size: 3rem; margin-bottom: 1rem; }
                    p { color: #6b5c4c; line-height: 1.6; }
                    button {
                        margin-top: 2rem;
                        padding: 0.75rem 1.5rem;
                        background: #2c2416;
                        color: white;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 1rem;
                    }
                    button:hover { opacity: 0.9; }
                </style>
            </head>
            <body>
                <div class="offline-container">
                    <h1>🕐</h1>
                    <h2>Vous êtes hors ligne</h2>
                    <p>Kairos nécessite une connexion internet pour accéder à vos articles.</p>
                    <p>Vérifiez votre connexion et réessayez.</p>
                    <button onclick="location.reload()">Réessayer</button>
                </div>
            </body>
            </html>
        `;

        return new Response(offlineHtml, {
            status: 503,
            headers: { 'Content-Type': 'text/html' }
        });
    }
}

// ============================================
// HELPERS
// ============================================

function isStaticAsset(pathname) {
    const staticExtensions = ['.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.woff', '.woff2'];
    return staticExtensions.some(ext => pathname.endsWith(ext));
}

// ============================================
// BACKGROUND SYNC (for future use)
// ============================================

self.addEventListener('sync', (event) => {
    if (event.tag === 'sync-articles') {
        console.log('[SW] Background sync triggered');
        // Future: sync offline actions
    }
});

// ============================================
// PUSH NOTIFICATIONS (for future use)
// ============================================

self.addEventListener('push', (event) => {
    if (event.data) {
        const data = event.data.json();
        const options = {
            body: data.body,
            icon: '/icons/icon-192.png',
            badge: '/icons/icon-72.png',
            data: { url: data.url }
        };

        event.waitUntil(
            self.registration.showNotification(data.title, options)
        );
    }
});

self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    if (event.notification.data?.url) {
        event.waitUntil(
            clients.openWindow(event.notification.data.url)
        );
    }
});

console.log('[SW] Service worker loaded');
