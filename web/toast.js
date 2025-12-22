/**
 * Kairos Toast Notification System
 * A lightweight toast notification library
 */

(function() {
    'use strict';

    // Toast configuration
    const TOAST_CONFIG = {
        duration: 5000,        // Default duration in ms
        maxToasts: 5,          // Maximum number of toasts visible at once
        position: 'bottom-right' // Position (currently only bottom-right supported)
    };

    // Toast icons
    const TOAST_ICONS = {
        success: '✓',
        error: '✕',
        warning: '⚠',
        info: 'ℹ'
    };

    // Toast titles
    const TOAST_TITLES = {
        success: 'Succès',
        error: 'Erreur',
        warning: 'Attention',
        info: 'Information'
    };

    // Create container if it doesn't exist
    function getContainer() {
        let container = document.querySelector('.toast-container');
        if (!container) {
            container = document.createElement('div');
            container.className = 'toast-container';
            document.body.appendChild(container);
        }
        return container;
    }

    // Remove oldest toast if max reached
    function enforceMaxToasts(container) {
        const toasts = container.querySelectorAll('.toast:not(.removing)');
        if (toasts.length >= TOAST_CONFIG.maxToasts) {
            removeToast(toasts[0]);
        }
    }

    // Remove a toast with animation
    function removeToast(toastElement) {
        if (!toastElement || toastElement.classList.contains('removing')) return;

        toastElement.classList.add('removing');
        setTimeout(() => {
            if (toastElement.parentNode) {
                toastElement.parentNode.removeChild(toastElement);
            }
        }, 300); // Match animation duration
    }

    // Create and show a toast
    function showToast(type, message, options = {}) {
        const container = getContainer();
        enforceMaxToasts(container);

        const title = options.title || TOAST_TITLES[type] || '';
        const duration = options.duration !== undefined ? options.duration : TOAST_CONFIG.duration;
        const icon = options.icon || TOAST_ICONS[type] || '';

        // Create toast element
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.style.position = 'relative';
        toast.innerHTML = `
            <span class="toast-icon">${icon}</span>
            <div class="toast-content">
                ${title ? `<div class="toast-title">${title}</div>` : ''}
                <div class="toast-message">${message}</div>
            </div>
            <button class="toast-close" aria-label="Fermer">&times;</button>
            ${duration > 0 ? `<div class="toast-progress" style="animation-duration: ${duration}ms;"></div>` : ''}
        `;

        // Add close button handler
        const closeBtn = toast.querySelector('.toast-close');
        closeBtn.addEventListener('click', () => removeToast(toast));

        // Add to container
        container.appendChild(toast);

        // Auto-remove after duration (if duration > 0)
        if (duration > 0) {
            setTimeout(() => removeToast(toast), duration);
        }

        return toast;
    }

    // Public API
    window.Toast = {
        success: function(message, options = {}) {
            return showToast('success', message, options);
        },

        error: function(message, options = {}) {
            return showToast('error', message, options);
        },

        warning: function(message, options = {}) {
            return showToast('warning', message, options);
        },

        info: function(message, options = {}) {
            return showToast('info', message, options);
        },

        // Show toast with custom type
        show: function(type, message, options = {}) {
            return showToast(type, message, options);
        },

        // Remove all toasts
        clear: function() {
            const container = document.querySelector('.toast-container');
            if (container) {
                const toasts = container.querySelectorAll('.toast');
                toasts.forEach(toast => removeToast(toast));
            }
        },

        // Configure toast settings
        configure: function(options) {
            Object.assign(TOAST_CONFIG, options);
        }
    };

    // Helper function to show API errors in a user-friendly way
    window.Toast.apiError = function(error, fallbackMessage = 'Une erreur est survenue') {
        let message = fallbackMessage;

        if (error) {
            if (typeof error === 'string') {
                message = error;
            } else if (error.message) {
                // Handle Supabase errors
                message = error.message;

                // Translate common Supabase error messages
                const translations = {
                    'Invalid login credentials': 'Identifiants incorrects',
                    'Email not confirmed': 'Veuillez confirmer votre email',
                    'User already registered': 'Cet email est déjà utilisé',
                    'Password should be at least 6 characters': 'Le mot de passe doit contenir au moins 6 caractères',
                    'Network error': 'Erreur de connexion réseau',
                    'Failed to fetch': 'Impossible de contacter le serveur',
                    'JWT expired': 'Votre session a expiré, veuillez vous reconnecter'
                };

                for (const [en, fr] of Object.entries(translations)) {
                    if (message.includes(en)) {
                        message = fr;
                        break;
                    }
                }
            } else if (error.error_description) {
                message = error.error_description;
            }
        }

        return showToast('error', message, { title: 'Erreur' });
    };

    // Helper for validation errors
    window.Toast.validation = function(message) {
        return showToast('warning', message, { title: 'Validation', duration: 4000 });
    };

})();
