/**
 * Kairos Configuration
 * Supports both local (Docker) and cloud (Supabase Cloud) environments
 */

// Configuration object - edit these values for your deployment
const CONFIG = {
    // ============================================
    // SUPABASE CONFIGURATION
    // ============================================

    // For LOCAL development (Docker via Kong)
    LOCAL: {
        SUPABASE_URL: 'http://localhost:8000',
        SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1sb2NhbCIsInJvbGUiOiJhbm9uIiwiZXhwIjoxOTgzODEyOTk2fQ.03kRoHS7CyhlnnUN3ys_b4xqbK7gkdACm0R-gyCpoo8'
        // Auth is routed through Kong at /auth/v1/
    },

    // For CLOUD deployment (Supabase Cloud)
    // Get your anon key from: https://supabase.com/dashboard/project/xvtraaflofksunqxuhsf/settings/api
    CLOUD: {
        SUPABASE_URL: 'https://xvtraaflofksunqxuhsf.supabase.co',
        SUPABASE_ANON_KEY: 'REMPLACEZ_PAR_VOTRE_CLE_ANON_JWT'  // Must start with eyJ...
    },

    // ============================================
    // APP SETTINGS
    // ============================================
    APP: {
        NAME: 'Kairos',
        VERSION: '2.0.0',
        DEFAULT_LANGUAGE: 'fr'
    }
};

// ============================================
// ENVIRONMENT DETECTION
// ============================================
// LOCAL-FIRST: Use Docker Supabase by default on localhost
// Add ?mode=cloud to URL to force cloud mode

const urlParams = new URLSearchParams(window.location.search);
const modeParam = urlParams.get('mode');
const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

let useLocalMode = true; // Default to LOCAL

if (modeParam === 'cloud') {
    useLocalMode = false;
    console.log('[Kairos] Mode: CLOUD (forced via URL)');
} else if (modeParam === 'local') {
    useLocalMode = true;
    console.log('[Kairos] Mode: LOCAL (forced via URL)');
} else if (isLocalhost) {
    useLocalMode = true;
    console.log('[Kairos] Mode: LOCAL (default on localhost)');
} else {
    useLocalMode = false;
    console.log('[Kairos] Mode: CLOUD (deployed)');
}

const ACTIVE_CONFIG = useLocalMode ? CONFIG.LOCAL : CONFIG.CLOUD;

// Supabase client initialization helper
function getSupabaseConfig() {
    return {
        url: ACTIVE_CONFIG.SUPABASE_URL,
        anonKey: ACTIVE_CONFIG.SUPABASE_ANON_KEY,
        options: {
            auth: {
                autoRefreshToken: true,
                persistSession: true,
                detectSessionInUrl: true
            }
        }
    };
}

// Check if user is authenticated
async function checkAuth(supabaseClient) {
    const { data: { session } } = await supabaseClient.auth.getSession();
    return session;
}

// Redirect to login if not authenticated
async function requireAuth(supabaseClient, redirectUrl = 'login.html') {
    const session = await checkAuth(supabaseClient);
    if (!session) {
        window.location.href = redirectUrl;
        return null;
    }
    return session;
}

// Get current user
async function getCurrentUser(supabaseClient) {
    const { data: { user } } = await supabaseClient.auth.getUser();
    return user;
}

// Logout helper
async function logout(supabaseClient, redirectUrl = 'index.html') {
    await supabaseClient.auth.signOut();
    window.location.href = redirectUrl;
}

// Export for use in other scripts
window.KairosConfig = {
    CONFIG,
    ACTIVE_CONFIG,
    getSupabaseConfig,
    checkAuth,
    requireAuth,
    getCurrentUser,
    logout,
    isLocalhost
};
