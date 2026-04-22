const CACHE = 'opensuivi-v1';
const PRECACHE = ['/static/style.css', '/static/favicon.svg', '/offline'];

self.addEventListener('install', e => {
    e.waitUntil(caches.open(CACHE).then(c => c.addAll(PRECACHE)));
    self.skipWaiting();
});

self.addEventListener('activate', e => {
    e.waitUntil(
        caches.keys().then(keys =>
            Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
        )
    );
    self.clients.claim();
});

self.addEventListener('fetch', e => {
    if (e.request.method !== 'GET') return;
    const url = new URL(e.request.url);

    // Cache-first pour les assets statiques
    if (url.pathname.startsWith('/static/')) {
        e.respondWith(
            caches.match(e.request).then(cached => cached ||
                fetch(e.request).then(res => {
                    const clone = res.clone();
                    caches.open(CACHE).then(c => c.put(e.request, clone));
                    return res;
                })
            )
        );
        return;
    }

    // Network-first pour les pages dynamiques, fallback offline
    e.respondWith(
        fetch(e.request).catch(() =>
            caches.match(e.request).then(cached => cached || caches.match('/offline'))
        )
    );
});
