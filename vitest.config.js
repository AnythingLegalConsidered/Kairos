// vitest.config.js - Configuration Vitest pour Kairos
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'happy-dom',
    globals: true,
    include: ['tests/**/*.test.js'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['web/**/*.js'],
      exclude: ['web/config.js']
    }
  }
});
