/**
 * CareNow MVP - Web Performance Optimizer
 * This script optimizes web performance for production deployment
 */

(function() {
    'use strict';

    // Configuration
    const CONFIG = {
        CACHE_VERSION: 'v1.0.0',
        CACHE_NAME: 'carenow-cache-v1',
        PERFORMANCE_BUDGET: {
            FCP: 2000,  // First Contentful Paint (ms)
            LCP: 2500,  // Largest Contentful Paint (ms)
            FID: 100,   // First Input Delay (ms)
            CLS: 0.1    // Cumulative Layout Shift
        },
        LAZY_LOAD_THRESHOLD: 50, // pixels
        IMAGE_QUALITY: 0.8,
        COMPRESSION_ENABLED: true
    };

    // Performance monitoring
    class PerformanceMonitor {
        constructor() {
            this.metrics = {};
            this.observers = [];
            this.init();
        }

        init() {
            if (typeof window !== 'undefined') {
                this.setupPerformanceObserver();
                this.setupIntersectionObserver();
                this.monitorNetworkConditions();
                this.trackUserInteractions();
            }
        }

        setupPerformanceObserver() {
            if ('PerformanceObserver' in window) {
                // Monitor Core Web Vitals
                const observer = new PerformanceObserver((list) => {
                    for (const entry of list.getEntries()) {
                        this.recordMetric(entry.name, entry.value);
                    }
                });

                observer.observe({ entryTypes: ['measure', 'navigation', 'paint'] });
                this.observers.push(observer);
            }
        }

        setupIntersectionObserver() {
            if ('IntersectionObserver' in window) {
                const observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            this.lazyLoadElement(entry.target);
                        }
                    });
                }, {
                    rootMargin: `${CONFIG.LAZY_LOAD_THRESHOLD}px`
                });

                this.observers.push(observer);
            }
        }

        monitorNetworkConditions() {
            if ('connection' in navigator) {
                const connection = navigator.connection;
                this.recordMetric('network-type', connection.effectiveType);
                this.recordMetric('network-downlink', connection.downlink);
                this.recordMetric('network-rtt', connection.rtt);
            }
        }

        trackUserInteractions() {
            ['click', 'scroll', 'keydown'].forEach(eventType => {
                document.addEventListener(eventType, (event) => {
                    this.recordInteraction(eventType, event.timeStamp);
                }, { passive: true });
            });
        }

        recordMetric(name, value) {
            this.metrics[name] = {
                value: value,
                timestamp: Date.now()
            };

            // Send to analytics if available
            if (window.gtag) {
                window.gtag('event', 'performance_metric', {
                    metric_name: name,
                    metric_value: value
                });
            }
        }

        recordInteraction(type, timestamp) {
            this.recordMetric(`interaction_${type}`, timestamp);
        }

        lazyLoadElement(element) {
            if (element.dataset.src) {
                element.src = element.dataset.src;
                element.removeAttribute('data-src');
            }
        }

        getMetrics() {
            return this.metrics;
        }
    }

    // Resource optimization
    class ResourceOptimizer {
        constructor() {
            this.init();
        }

        init() {
            this.optimizeImages();
            this.preloadCriticalResources();
            this.setupServiceWorker();
            this.optimizeCSS();
            this.optimizeJavaScript();
        }

        optimizeImages() {
            const images = document.querySelectorAll('img[data-src]');
            images.forEach(img => {
                // Add lazy loading
                img.loading = 'lazy';
                
                // Optimize image format
                if (this.supportsWebP()) {
                    const src = img.dataset.src;
                    if (src && !src.includes('.webp')) {
                        img.dataset.src = src.replace(/\.(jpg|jpeg|png)$/, '.webp');
                    }
                }
            });
        }

        supportsWebP() {
            const canvas = document.createElement('canvas');
            canvas.width = 1;
            canvas.height = 1;
            return canvas.toDataURL('image/webp').indexOf('data:image/webp') === 0;
        }

        preloadCriticalResources() {
            const criticalResources = [
                '/assets/fonts/main.woff2',
                '/assets/css/critical.css',
                '/assets/js/main.js'
            ];

            criticalResources.forEach(resource => {
                const link = document.createElement('link');
                link.rel = 'preload';
                link.href = resource;
                
                if (resource.endsWith('.woff2')) {
                    link.as = 'font';
                    link.type = 'font/woff2';
                    link.crossOrigin = 'anonymous';
                } else if (resource.endsWith('.css')) {
                    link.as = 'style';
                } else if (resource.endsWith('.js')) {
                    link.as = 'script';
                }
                
                document.head.appendChild(link);
            });
        }

        setupServiceWorker() {
            if ('serviceWorker' in navigator) {
                navigator.serviceWorker.register('/sw.js')
                    .then(registration => {
                        console.log('SW registered:', registration);
                    })
                    .catch(error => {
                        console.log('SW registration failed:', error);
                    });
            }
        }

        optimizeCSS() {
            // Remove unused CSS (simplified)
            const stylesheets = document.querySelectorAll('link[rel="stylesheet"]');
            stylesheets.forEach(sheet => {
                if (sheet.media && sheet.media !== 'all' && sheet.media !== 'screen') {
                    sheet.media = 'print';
                    sheet.onload = function() {
                        this.media = 'all';
                    };
                }
            });
        }

        optimizeJavaScript() {
            // Defer non-critical JavaScript
            const scripts = document.querySelectorAll('script[data-defer]');
            scripts.forEach(script => {
                script.defer = true;
            });
        }
    }

    // Cache management
    class CacheManager {
        constructor() {
            this.cacheName = CONFIG.CACHE_NAME;
            this.init();
        }

        async init() {
            if ('caches' in window) {
                await this.setupCache();
                this.setupCacheStrategies();
            }
        }

        async setupCache() {
            const cache = await caches.open(this.cacheName);
            const criticalResources = [
                '/',
                '/manifest.json',
                '/assets/css/main.css',
                '/assets/js/main.js',
                '/assets/fonts/main.woff2'
            ];

            await cache.addAll(criticalResources);
        }

        setupCacheStrategies() {
            // Cache-first for static assets
            // Network-first for API calls
            // Stale-while-revalidate for images
        }

        async clearOldCaches() {
            const cacheNames = await caches.keys();
            const oldCaches = cacheNames.filter(name => 
                name.startsWith('carenow-cache-') && name !== this.cacheName
            );

            await Promise.all(
                oldCaches.map(name => caches.delete(name))
            );
        }
    }

    // Main optimizer
    class WebOptimizer {
        constructor() {
            this.performanceMonitor = new PerformanceMonitor();
            this.resourceOptimizer = new ResourceOptimizer();
            this.cacheManager = new CacheManager();
            this.init();
        }

        init() {
            // Wait for DOM to be ready
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', () => {
                    this.optimize();
                });
            } else {
                this.optimize();
            }
        }

        optimize() {
            this.optimizeRendering();
            this.optimizeInteractions();
            this.setupErrorHandling();
            this.reportPerformance();
        }

        optimizeRendering() {
            // Reduce layout thrashing
            document.body.style.willChange = 'transform';
            
            // Optimize animations
            const animatedElements = document.querySelectorAll('[data-animate]');
            animatedElements.forEach(element => {
                element.style.willChange = 'transform, opacity';
            });
        }

        optimizeInteractions() {
            // Debounce scroll events
            let scrollTimeout;
            window.addEventListener('scroll', () => {
                clearTimeout(scrollTimeout);
                scrollTimeout = setTimeout(() => {
                    this.performanceMonitor.recordMetric('scroll_end', Date.now());
                }, 100);
            }, { passive: true });
        }

        setupErrorHandling() {
            window.addEventListener('error', (event) => {
                this.performanceMonitor.recordMetric('js_error', {
                    message: event.message,
                    filename: event.filename,
                    lineno: event.lineno,
                    timestamp: Date.now()
                });
            });

            window.addEventListener('unhandledrejection', (event) => {
                this.performanceMonitor.recordMetric('promise_rejection', {
                    reason: event.reason,
                    timestamp: Date.now()
                });
            });
        }

        reportPerformance() {
            // Report performance metrics after page load
            window.addEventListener('load', () => {
                setTimeout(() => {
                    const metrics = this.performanceMonitor.getMetrics();
                    console.log('Performance Metrics:', metrics);
                    
                    // Send to analytics
                    if (window.gtag) {
                        window.gtag('event', 'performance_report', {
                            custom_map: { metrics: JSON.stringify(metrics) }
                        });
                    }
                }, 1000);
            });
        }
    }

    // Initialize optimizer
    const optimizer = new WebOptimizer();

    // Export for debugging
    window.CareNowOptimizer = optimizer;

})();
