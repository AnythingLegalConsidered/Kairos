import globals from "globals";

export default [
  {
    files: ["web/**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.browser,
        // Supabase global (chargé via CDN)
        supabase: "readonly",
      }
    },
    rules: {
      // Erreurs potentielles
      "no-undef": "error",
      "no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
      "no-console": "off", // Autorisé pour le debug

      // Bonnes pratiques
      "eqeqeq": ["error", "always"],
      "no-var": "error",
      "prefer-const": "warn",

      // Style (léger, pas trop strict)
      "semi": ["warn", "always"],
      "quotes": ["warn", "single", { "avoidEscape": true }],

      // Désactivé pour vanilla JS simple
      "no-alert": "off",
    }
  }
];
