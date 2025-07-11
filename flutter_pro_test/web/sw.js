/**
 * CareNow MVP - Service Worker for Production Caching
 * Implements advanced caching strategies for optimal performance
 */

const CACHE_VERSION = 'v1.0.0';
const CACHE_NAME = `carenow-cache-${CACHE_VERSION}`;
const RUNTIME_CACHE = `carenow-runtime-${CACHE_VERSION}`;

// Cache strategies
const CACHE_STRATEGIES = {
  CACHE_FIRST: 'cache-first',
  NETWORK_FIRST: 'network-first',
  STALE_WHILE_REVALIDATE: 'stale-while-revalidate',
  NETWORK_ONLY: 'network-only',
  CACHE_ONLY: 'cache-only'
};

// Resource patterns and their caching strategies
const CACHE_PATTERNS = [
  {
    pattern: /\.(?:png|jpg|jpeg|svg|gif|webp|ico)$/,
    strategy: CACHE_STRATEGIES.STALE_WHILE_REVALIDATE,
    maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
    maxEntries: 100
  },
  {
    pattern: /\.(?:js|css|woff|woff2|ttf|eot)$/,
    strategy: CACHE_STRATEGIES.CACHE_FIRST,
    maxAge: 365 * 24 * 60 * 60 * 1000, // 1 year
    maxEntries: 50
  },
  {
    pattern: /^https:\/\/fonts\.googleapis\.com/,
    strategy: CACHE_STRATEGIES.STALE_WHILE_REVALIDATE,
    maxAge: 365 * 24 * 60 * 60 * 1000, // 1 year
    maxEntries: 10
  },
  {
    pattern: /^https:\/\/fonts\.gstatic\.com/,
    strategy: CACHE_STRATEGIES.CACHE_FIRST,
    maxAge: 365 * 24 * 60 * 60 * 1000, // 1 year
    maxEntries: 20
  },
  {
    pattern: /\/api\//,
    strategy: CACHE_STRATEGIES.NETWORK_FIRST,
    maxAge: 5 * 60 * 1000, // 5 minutes
    maxEntries: 50
  }
];

// Critical resources to cache immediately
const CRITICAL_RESOURCES = [
  '/',
  '/manifest.json',
  '/favicon.ico',
  '/assets/AssetManifest.json',
  '/assets/FontManifest.json'
];

// Install event - cache critical resources
self.addEventListener('install', event => {
  console.log('SW: Installing service worker');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('SW: Caching critical resources');
        return cache.addAll(CRITICAL_RESOURCES);
      })
      .then(() => {
        console.log('SW: Critical resources cached');
        return self.skipWaiting();
      })
      .catch(error => {
        console.error('SW: Failed to cache critical resources:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  console.log('SW: Activating service worker');
  
  event.waitUntil(
    caches.keys()
      .then(cacheNames => {
        const oldCaches = cacheNames.filter(name => 
          name.startsWith('carenow-cache-') && name !== CACHE_NAME ||
          name.startsWith('carenow-runtime-') && name !== RUNTIME_CACHE
        );
        
        console.log('SW: Cleaning up old caches:', oldCaches);
        
        return Promise.all(
          oldCaches.map(name => caches.delete(name))
        );
      })
      .then(() => {
        console.log('SW: Old caches cleaned up');
        return self.clients.claim();
      })
      .catch(error => {
        console.error('SW: Failed to clean up old caches:', error);
      })
  );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }
  
  // Skip chrome-extension requests
  if (url.protocol === 'chrome-extension:') {
    return;
  }
  
  // Find matching cache pattern
  const pattern = CACHE_PATTERNS.find(p => p.pattern.test(request.url));
  
  if (pattern) {
    event.respondWith(handleRequest(request, pattern));
  } else {
    // Default strategy for unmatched requests
    event.respondWith(
      handleRequest(request, {
        strategy: CACHE_STRATEGIES.NETWORK_FIRST,
        maxAge: 24 * 60 * 60 * 1000, // 24 hours
        maxEntries: 50
      })
    );
  }
});

// Handle request based on caching strategy
async function handleRequest(request, pattern) {
  const { strategy, maxAge, maxEntries } = pattern;
  
  switch (strategy) {
    case CACHE_STRATEGIES.CACHE_FIRST:
      return cacheFirst(request, maxAge, maxEntries);
    
    case CACHE_STRATEGIES.NETWORK_FIRST:
      return networkFirst(request, maxAge, maxEntries);
    
    case CACHE_STRATEGIES.STALE_WHILE_REVALIDATE:
      return staleWhileRevalidate(request, maxAge, maxEntries);
    
    case CACHE_STRATEGIES.NETWORK_ONLY:
      return fetch(request);
    
    case CACHE_STRATEGIES.CACHE_ONLY:
      return cacheOnly(request);
    
    default:
      return networkFirst(request, maxAge, maxEntries);
  }
}

// Cache-first strategy
async function cacheFirst(request, maxAge, maxEntries) {
  const cache = await caches.open(RUNTIME_CACHE);
  const cachedResponse = await cache.match(request);
  
  if (cachedResponse && !isExpired(cachedResponse, maxAge)) {
    return cachedResponse;
  }
  
  try {
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      await cache.put(request, networkResponse.clone());
      await cleanupCache(cache, maxEntries);
    }
    
    return networkResponse;
  } catch (error) {
    console.warn('SW: Network failed, serving stale cache:', error);
    return cachedResponse || new Response('Offline', { status: 503 });
  }
}

// Network-first strategy
async function networkFirst(request, maxAge, maxEntries) {
  const cache = await caches.open(RUNTIME_CACHE);
  
  try {
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      await cache.put(request, networkResponse.clone());
      await cleanupCache(cache, maxEntries);
    }
    
    return networkResponse;
  } catch (error) {
    console.warn('SW: Network failed, trying cache:', error);
    const cachedResponse = await cache.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    return new Response('Offline', { status: 503 });
  }
}

// Stale-while-revalidate strategy
async function staleWhileRevalidate(request, maxAge, maxEntries) {
  const cache = await caches.open(RUNTIME_CACHE);
  const cachedResponse = await cache.match(request);
  
  // Always try to fetch from network in background
  const networkPromise = fetch(request)
    .then(response => {
      if (response.ok) {
        cache.put(request, response.clone());
        cleanupCache(cache, maxEntries);
      }
      return response;
    })
    .catch(error => {
      console.warn('SW: Background fetch failed:', error);
    });
  
  // Return cached response immediately if available
  if (cachedResponse) {
    return cachedResponse;
  }
  
  // If no cache, wait for network
  return networkPromise;
}

// Cache-only strategy
async function cacheOnly(request) {
  const cache = await caches.open(RUNTIME_CACHE);
  const cachedResponse = await cache.match(request);
  
  return cachedResponse || new Response('Not in cache', { status: 404 });
}

// Check if cached response is expired
function isExpired(response, maxAge) {
  if (!maxAge) return false;
  
  const dateHeader = response.headers.get('date');
  if (!dateHeader) return false;
  
  const date = new Date(dateHeader);
  const now = new Date();
  
  return (now.getTime() - date.getTime()) > maxAge;
}

// Clean up cache to maintain size limits
async function cleanupCache(cache, maxEntries) {
  if (!maxEntries) return;
  
  const keys = await cache.keys();
  
  if (keys.length > maxEntries) {
    const keysToDelete = keys.slice(0, keys.length - maxEntries);
    
    await Promise.all(
      keysToDelete.map(key => cache.delete(key))
    );
    
    console.log(`SW: Cleaned up ${keysToDelete.length} cache entries`);
  }
}

// Background sync for offline actions
self.addEventListener('sync', event => {
  console.log('SW: Background sync triggered:', event.tag);
  
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

// Handle background sync
async function doBackgroundSync() {
  try {
    // Implement background sync logic here
    // e.g., sync offline data, send queued requests
    console.log('SW: Background sync completed');
  } catch (error) {
    console.error('SW: Background sync failed:', error);
  }
}

// Push notification handling
self.addEventListener('push', event => {
  console.log('SW: Push notification received');
  
  const options = {
    body: event.data ? event.data.text() : 'New notification',
    icon: '/assets/icons/icon-192.png',
    badge: '/assets/icons/badge-72.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'View',
        icon: '/assets/icons/checkmark.png'
      },
      {
        action: 'close',
        title: 'Close',
        icon: '/assets/icons/xmark.png'
      }
    ]
  };
  
  event.waitUntil(
    self.registration.showNotification('CareNow', options)
  );
});

// Notification click handling
self.addEventListener('notificationclick', event => {
  console.log('SW: Notification clicked:', event.action);
  
  event.notification.close();
  
  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

// Message handling from main thread
self.addEventListener('message', event => {
  console.log('SW: Message received:', event.data);
  
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_VERSION });
  }
});

console.log('SW: Service worker loaded successfully');
