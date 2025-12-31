# tests/ - Tests unitaires

> Tests unitaires Vitest pour les modules JavaScript de Kairos.
>
> **Version:** 0.5.0 | **Derniere MAJ:** 31/12/2024

## En un coup d'oeil

- **Framework** : Vitest + Happy DOM
- **Modules testes** : toast.js, intelligence.js
- **Couverture** : Fonctions critiques UI

## Structure

```
tests/
├── README.md           # CE FICHIER
└── unit/               # Tests unitaires
    ├── toast.test.js       # Tests notifications toast
    └── intelligence.test.js # Tests fonctions IA
```

## Tests disponibles

### toast.test.js

| Test | Description |
|------|-------------|
| `showToast success` | Affiche notification success |
| `showToast error` | Affiche notification error |
| `translateSupabaseError` | Traduit erreurs Supabase en francais |
| `dismiss` | Ferme notification manuellement |

### intelligence.test.js

| Test | Description |
|------|-------------|
| `renderHighlights` | Genere HTML pour phrases cles |
| `getPersonalizedScore` | Calcule boost selon preferences |
| `empty highlights` | Gere liste vide |

## Commandes

```bash
# Lancer tous les tests
npm test

# Mode watch (relance auto)
npm run test:watch

# Avec rapport de couverture
npm run test:coverage

# Test specifique
npx vitest run tests/unit/toast.test.js
```

## Configuration

Fichier `vitest.config.js` a la racine :

```javascript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'happy-dom',
    globals: true
  }
})
```

## Ajouter un nouveau test

1. Creer `tests/unit/module.test.js`
2. Importer le module a tester
3. Ecrire les tests avec `describe` / `it`
4. Lancer `npm test`

### Exemple

```javascript
import { describe, it, expect } from 'vitest'

describe('monModule', () => {
  it('devrait faire X', () => {
    const result = maFonction()
    expect(result).toBe(valeurAttendue)
  })
})
```

## Bonnes pratiques

1. **Isolation** : Chaque test est independant
2. **Nommage** : Decrire le comportement attendu
3. **AAA** : Arrange, Act, Assert
4. **Mocking** : Utiliser `vi.mock()` pour les deps externes

## Dependances

```json
{
  "devDependencies": {
    "vitest": "^1.x",
    "happy-dom": "^12.x",
    "@testing-library/dom": "^9.x"
  }
}
```
