// tests/unit/toast.test.js
// Purpose: Unit tests for Toast notification system
// Coverage: show, success, error, clear, apiError

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import fs from 'fs';
import path from 'path';

describe('Toast Notification System', () => {
  beforeEach(() => {
    // Clean DOM
    document.body.innerHTML = '';

    // Load and execute toast.js
    const toastCode = fs.readFileSync(
      path.join(process.cwd(), 'web', 'toast.js'),
      'utf-8'
    );
    eval(toastCode);
  });

  afterEach(() => {
    // Clean up toasts
    if (window.Toast) {
      window.Toast.clear();
    }
    document.body.innerHTML = '';
  });

  describe('Toast.success', () => {
    it('should create a success toast', () => {
      window.Toast.success('Test message');

      const toast = document.querySelector('.toast-success');
      expect(toast).not.toBeNull();
      expect(toast.textContent).toContain('Test message');
      expect(toast.textContent).toContain('✓');
    });

    it('should include the success title', () => {
      window.Toast.success('Test message');

      const title = document.querySelector('.toast-title');
      expect(title.textContent).toBe('Succès');
    });
  });

  describe('Toast.error', () => {
    it('should create an error toast', () => {
      window.Toast.error('Error message');

      const toast = document.querySelector('.toast-error');
      expect(toast).not.toBeNull();
      expect(toast.textContent).toContain('Error message');
      expect(toast.textContent).toContain('✕');
    });
  });

  describe('Toast.warning', () => {
    it('should create a warning toast', () => {
      window.Toast.warning('Warning message');

      const toast = document.querySelector('.toast-warning');
      expect(toast).not.toBeNull();
      expect(toast.textContent).toContain('⚠');
    });
  });

  describe('Toast.info', () => {
    it('should create an info toast', () => {
      window.Toast.info('Info message');

      const toast = document.querySelector('.toast-info');
      expect(toast).not.toBeNull();
      expect(toast.textContent).toContain('ℹ');
    });
  });

  describe('Toast.show', () => {
    it('should create a toast with custom type', () => {
      window.Toast.show('success', 'Custom message');

      const toast = document.querySelector('.toast-success');
      expect(toast).not.toBeNull();
    });
  });

  describe('Toast.clear', () => {
    it('should mark all toasts as removing', () => {
      // Create multiple toasts
      window.Toast.success('Message 1');
      window.Toast.error('Message 2');
      window.Toast.info('Message 3');

      expect(document.querySelectorAll('.toast').length).toBe(3);

      // Clear all
      window.Toast.clear();

      // After clear, toasts should be marked as removing
      const removingToasts = document.querySelectorAll('.toast.removing');
      expect(removingToasts.length).toBe(3);
    });
  });

  describe('Toast container', () => {
    it('should create container on first toast', () => {
      expect(document.querySelector('.toast-container')).toBeNull();

      window.Toast.success('Test');

      expect(document.querySelector('.toast-container')).not.toBeNull();
    });

    it('should reuse existing container', () => {
      window.Toast.success('Test 1');
      window.Toast.success('Test 2');

      const containers = document.querySelectorAll('.toast-container');
      expect(containers.length).toBe(1);
    });
  });

  describe('Toast options', () => {
    it('should accept custom title', () => {
      window.Toast.success('Message', { title: 'Custom Title' });

      const title = document.querySelector('.toast-title');
      expect(title.textContent).toBe('Custom Title');
    });

    it('should accept custom duration', () => {
      const toast = window.Toast.success('Message', { duration: 1000 });

      const progress = toast.querySelector('.toast-progress');
      expect(progress.style.animationDuration).toBe('1000ms');
    });

    it('should not show progress bar when duration is 0', () => {
      const toast = window.Toast.success('Message', { duration: 0 });

      const progress = toast.querySelector('.toast-progress');
      expect(progress).toBeNull();
    });
  });

  describe('Toast.apiError', () => {
    it('should translate common Supabase errors', () => {
      window.Toast.apiError({ message: 'Invalid login credentials' });

      const toast = document.querySelector('.toast-error');
      expect(toast.textContent).toContain('Identifiants incorrects');
    });

    it('should use fallback message for unknown errors', () => {
      window.Toast.apiError(null, 'Fallback message');

      const toast = document.querySelector('.toast-error');
      expect(toast.textContent).toContain('Fallback message');
    });

    it('should handle string errors', () => {
      window.Toast.apiError('Direct error message');

      const toast = document.querySelector('.toast-error');
      expect(toast.textContent).toContain('Direct error message');
    });
  });

  describe('Toast.validation', () => {
    it('should create a validation warning toast', () => {
      window.Toast.validation('Field is required');

      const toast = document.querySelector('.toast-warning');
      expect(toast).not.toBeNull();
      expect(toast.textContent).toContain('Validation');
      expect(toast.textContent).toContain('Field is required');
    });
  });

  describe('Max toasts limit', () => {
    it('should enforce max toasts limit (5)', () => {
      // Create 6 toasts
      for (let i = 0; i < 6; i++) {
        window.Toast.success(`Message ${i}`);
      }

      const toasts = document.querySelectorAll('.toast:not(.removing)');
      expect(toasts.length).toBeLessThanOrEqual(5);
    });
  });

  describe('Close button', () => {
    it('should have a close button', () => {
      window.Toast.success('Test');

      const closeBtn = document.querySelector('.toast-close');
      expect(closeBtn).not.toBeNull();
      expect(closeBtn.getAttribute('aria-label')).toBe('Fermer');
    });
  });
});
