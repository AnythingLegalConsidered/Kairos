/**
 * Auth Menu - Shared authentication menu component
 * Displays user email and logout button when authenticated
 */

async function initAuthMenu() {
    const userMenu = document.getElementById('userMenu');
    if (!userMenu) return;

    try {
        const { data: { session } } = await supabase.auth.getSession();

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
    await supabase.auth.signOut();
    window.location.href = 'index.html';
};

// Initialize on page load
if (typeof supabase !== 'undefined') {
    document.addEventListener('DOMContentLoaded', initAuthMenu);
}
