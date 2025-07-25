// Enhanced Visitor Tracking Script for bigbraincoding.com
// Add this script to your website's <head> section

(function() {
    'use strict';

    // Configuration
    const TRACKING_ENDPOINT = '/api/track';
    const SESSION_TIMEOUT = 30 * 60 * 1000; // 30 minutes

    // Session management
    let sessionId = localStorage.getItem('session_id') || generateSessionId();
    let sessionStart = parseInt(localStorage.getItem('session_start')) || Date.now();
    let lastActivity = Date.now();

    // Generate unique session ID
    function generateSessionId() {
        const id = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        localStorage.setItem('session_id', id);
        localStorage.setItem('session_start', Date.now().toString());
        return id;
    }

    // Device detection
    function getDeviceInfo() {
        const ua = navigator.userAgent;
        let deviceType = 'desktop';

        if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ua)) {
            deviceType = 'mobile';
            if (/iPad|Android.*Tablet/i.test(ua)) {
                deviceType = 'tablet';
            }
        }

        return {
            type: deviceType,
            userAgent: ua,
            screen: {
                width: screen.width,
                height: screen.height,
                colorDepth: screen.colorDepth
            },
            viewport: {
                width: window.innerWidth,
                height: window.innerHeight
            },
            language: navigator.language,
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            cookiesEnabled: navigator.cookieEnabled,
            online: navigator.onLine
        };
    }

    // Page tracking
    function trackPageView() {
        const pageData = {
            type: 'pageview',
            url: window.location.href,
            title: document.title,
            referrer: document.referrer,
            timestamp: Date.now(),
            sessionId: sessionId,
            device: getDeviceInfo(),
            performance: {
                loadTime: performance.timing.loadEventEnd - performance.timing.navigationStart,
                domReady: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart,
                firstPaint: performance.getEntriesByType('paint')[0]?.startTime || 0
            }
        };

        sendTrackingData(pageData);
    }

    // Event tracking
    function trackEvent(eventName, eventData = {}) {
        const eventPayload = {
            type: 'event',
            event: eventName,
            data: eventData,
            timestamp: Date.now(),
            sessionId: sessionId,
            url: window.location.href
        };

        sendTrackingData(eventPayload);
    }

    // Send data to server
    function sendTrackingData(data) {
        // Use navigator.sendBeacon for better performance
        if (navigator.sendBeacon) {
            navigator.sendBeacon(TRACKING_ENDPOINT, JSON.stringify(data));
        } else {
            // Fallback to fetch
            fetch(TRACKING_ENDPOINT, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            }).catch(console.error);
        }
    }

    // Activity tracking
    function updateActivity() {
        lastActivity = Date.now();
        localStorage.setItem('last_activity', lastActivity.toString());
    }

    // Session management
    function checkSession() {
        const now = Date.now();
        const timeSinceLastActivity = now - lastActivity;

        if (timeSinceLastActivity > SESSION_TIMEOUT) {
            // Session expired, create new session
            sessionId = generateSessionId();
            sessionStart = now;
            trackEvent('session_expired');
        }

        updateActivity();
    }

    // Scroll tracking
    let scrollDepth = 0;
    function trackScroll() {
        const scrollPercent = Math.round((window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100);

        if (scrollPercent > scrollDepth && scrollPercent % 25 === 0) {
            scrollDepth = scrollPercent;
            trackEvent('scroll_depth', { depth: scrollPercent });
        }
    }

    // Time on page tracking
    let pageStartTime = Date.now();
    function trackTimeOnPage() {
        const timeOnPage = Date.now() - pageStartTime;
        trackEvent('time_on_page', { duration: timeOnPage });
    }

    // Initialize tracking
    function initTracking() {
        // Track initial page view
        trackPageView();

        // Set up event listeners
        document.addEventListener('click', function(e) {
            const target = e.target;
            if (target.tagName === 'A' || target.tagName === 'BUTTON') {
                trackEvent('click', {
                    element: target.tagName.toLowerCase(),
                    text: target.textContent?.substring(0, 50),
                    href: target.href || null
                });
            }
        });

        // Track scroll events
        window.addEventListener('scroll', trackScroll);

        // Track form submissions
        document.addEventListener('submit', function(e) {
            trackEvent('form_submit', {
                formId: e.target.id || 'unknown',
                formAction: e.target.action || 'unknown'
            });
        });

        // Track page visibility changes
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                trackTimeOnPage();
            } else {
                pageStartTime = Date.now();
                trackEvent('page_visible');
            }
        });

        // Track before unload
        window.addEventListener('beforeunload', function() {
            trackTimeOnPage();
            trackEvent('page_exit');
        });

        // Periodic activity check
        setInterval(checkSession, 60000); // Check every minute

        // Track session start
        trackEvent('session_start', {
            sessionStart: sessionStart,
            referrer: document.referrer
        });
    }

    // Start tracking when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initTracking);
    } else {
        initTracking();
    }

    // Expose tracking functions globally for manual tracking
    window.trackEvent = trackEvent;
    window.trackPageView = trackPageView;

})();