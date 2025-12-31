/**
 * Auth Menu - Shared authentication menu component
 * Displays user email and logout button when authenticated
 * Uses window.supabaseClient (set by each page before loading this script)
 */

async function initAuthMenu() {
    const userMenu = document.getElementById('userMenu');
    if (!userMenu) return;

    const client = window.supabaseClient;
    if (!client) {
        console.error('Auth menu: supabaseClient not found');
        userMenu.innerHTML = '<a href="login.html" class="login-link">Connexion</a>';
        return;
    }

    try {
        const { data: { session } } = await client.auth.getSession();

        if (session) {
            userMenu.innerHTML = `
                <span class="user-email">${session.user.email}</span>
                <button class="logout-btn" onclick="handleLogout()">Déconnexion</button>
            `;
        } else {
            userMenu.innerHTML = '<a href="login.html" class="login-link">Connexion</a>';
        }
    } catch (error) {
        console.error('Auth menu error:', error);
        userMenu.innerHTML = '<a href="login.html" class="login-link">Connexion</a>';
    }
}

// Exposed globally for onclick handler
window.handleLogout = async function() {
    if (window.supabaseClient) {
        await window.supabaseClient.auth.signOut();
    }
    window.location.href = 'index.html';
};

// Initialize on page load - always try, check client inside function
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAuthMenu);
} else {
    initAuthMenu();
}
