# File Organization

Proper file and directory structure for maintainable, scalable frontend code in the PLP application.

---

## features/ vs components/ Distinction

### features/ Directory

**Purpose**: Domain-specific features with their own logic, API, and components

**When to use:**
- Feature has multiple related components
- Feature has its own API endpoints
- Feature has domain-specific logic
- Feature has custom hooks/utilities

**Examples:**
- `features/submissions/` - Project catalog/submission management
- `features/forms/` - Form builder and rendering
- `features/auth/` - Authentication flows

**Structure:**
```
features/
  my-feature/
    api/
      myFeatureApi.ts         # API service layer
    components/
      MyFeatureMain.tsx       # Main component
      SubComponents/          # Related components
    hooks/
      useMyFeature.ts         # Custom hooks
      useSuspenseMyFeature.ts # Suspense hooks
    helpers/
      myFeatureHelpers.ts     # Utility functions
    types/
      index.ts                # TypeScript types
    index.ts                  # Public exports
```

### components/ Directory

**Purpose**: Truly reusable components used across multiple features

**When to use:**
- Component is used in 3+ places
- Component is generic (no feature-specific logic)
- Component is a UI primitive or pattern

**Examples:**
- `components/SuspenseLoader/` - Loading wrapper
- `components/CustomAppBar/` - Application header
- `components/ErrorBoundary/` - Error handling
- `components/LoadingOverlay/` - Loading overlay

**Structure:**
```
components/
  SuspenseLoader/
    SuspenseLoader.tsx
    SuspenseLoader.test.tsx
  CustomAppBar/
    CustomAppBar.tsx
    CustomAppBar.test.tsx
```

---

## Feature Directory Structure (Detailed)

### Complete Feature Example

Based on `features/submissions/` structure:

```
features/
  submissions/
    api/
      submissionApi.ts              # API service layer (GET, POST, PUT, DELETE)

    components/
      SubmissionTable.tsx           # Main container component
      grids/
        SubmissionDataGrid/
          SubmissionDataGrid.tsx
      drawers/
        ProjectSubmissionDrawer/
          ProjectSubmissionDrawer.tsx
      cells/
        editors/
          TextEditCell.tsx
        renderers/
          DateCell.tsx
      toolbar/
        CustomToolbar.tsx

    hooks/
      useSubmissionQueries.ts       # Regular queries
      useSuspenseSubmission.ts      # Suspense queries
      useSubmissionMutations.ts     # Mutations
      useGridLayout.ts              # Feature-specific hooks

    helpers/
      submissionHelpers.ts          # Utility functions
      validation.ts                 # Validation logic

    types/
      index.ts                      # TypeScript types/interfaces

    queries/
      submissionQueries.ts          # Query key factories (optional)

    context/
      SubmissionContext.tsx         # React context (if needed)

    index.ts                        # Public API exports
```

### Subdirectory Guidelines

#### api/ Directory

**Purpose**: Centralized API calls for the feature

**Files:**
- `{feature}Api.ts` - Main API service

**Pattern:**
```typescript
// features/my-feature/api/myFeatureApi.ts
import apiClient from '@/lib/apiClient';

export const myFeatureApi = {
    getItem: async (id: number) => {
        const { data } = await apiClient.get(`/form/items/${id}`);
        return data;
    },
    createItem: async (payload) => {
        const { data } = await apiClient.post('/form/items', payload);
        return data;
    },
};
```

#### components/ Directory

**Purpose**: Feature-specific components

**Organization:**
- Flat structure if <5 components
- Subdirectories by responsibility if >5 components

**Examples:**
```
components/
  MyFeatureMain.tsx           # Main component
  MyFeatureHeader.tsx         # Supporting components
  MyFeatureFooter.tsx

  # OR with subdirectories:
  containers/
    MyFeatureContainer.tsx
  presentational/
    MyFeatureDisplay.tsx
  forms/
    MyFeatureForm.tsx
```

#### hooks/ Directory

**Purpose**: Custom hooks for the feature

**Naming:**
- `use` prefix (camelCase)
- Descriptive of what they do

**Examples:**
```
hooks/
  useMyFeature.ts               # Main hook
  useSuspenseMyFeature.ts       # Suspense version
  useMyFeatureMutations.ts      # Mutations
  useMyFeatureFilters.ts        # Filters/search
```

#### helpers/ Directory

**Purpose**: Utility functions specific to the feature

**Examples:**
```
helpers/
  myFeatureHelpers.ts           # General utilities
  validation.ts                 # Validation logic
  transformers.ts               # Data transformations
  constants.ts                  # Constants
```

#### types/ Directory

**Purpose**: TypeScript types and interfaces

**Files:**
```
types/
  index.ts                      # Main types, exported
  internal.ts                   # Internal types (not exported)
```

---

## Import Aliases (Vite Configuration)

### Available Aliases

From `vite.config.ts` lines 180-185:

| Alias | Resolves To | Use For |
|-------|-------------|---------|
| `@/` | `src/` | Absolute imports from src root |
| `~types` | `src/types` | Shared TypeScript types |
| `~components` | `src/components` | Reusable components |
| `~features` | `src/features` | Feature imports |

### Usage Examples

```typescript
// ✅ PREFERRED - Use aliases for absolute imports
import { apiClient } from '@/lib/apiClient';
import { SuspenseLoader } from '~components/SuspenseLoader';
import { submissionApi } from '~features/submissions/api/submissionApi';
import type { User } from '~types/user';

// ❌ AVOID - Relative paths from deep nesting
import { apiClient } from '../../../lib/apiClient';
import { SuspenseLoader } from '../../../components/SuspenseLoader';
```

### When to Use Which Alias

**@/ (General)**:
- Lib utilities: `@/lib/apiClient`
- Hooks: `@/hooks/useAuth`
- Config: `@/config/theme`
- Shared services: `@/services/authService`

**~types (Type Imports)**:
```typescript
import type { Submission } from '~types/submission';
import type { User, UserRole } from '~types/user';
```

**~components (Reusable Components)**:
```typescript
import { SuspenseLoader } from '~components/SuspenseLoader';
import { CustomAppBar } from '~components/CustomAppBar';
import { ErrorBoundary } from '~components/ErrorBoundary';
```

**~features (Feature Imports)**:
```typescript
import { submissionApi } from '~features/submissions/api/submissionApi';
import { useAuth } from '~features/auth/hooks/useAuth';
```

---

## File Naming Conventions

### Components

**Pattern**: PascalCase with `.tsx` extension

```
MyComponent.tsx
SubmissionDataGrid.tsx
CustomAppBar.tsx
```

**Avoid:**
- camelCase: `myComponent.tsx` ❌
- kebab-case: `my-component.tsx` ❌
- All caps: `MYCOMPONENT.tsx` ❌

### Hooks

**Pattern**: camelCase with `use` prefix, `.ts` extension

```
useMyFeature.ts
useSuspenseSubmission.ts
useAuth.ts
useGridLayout.ts
```

### API Services

**Pattern**: camelCase with `Api` suffix, `.ts` extension

```
myFeatureApi.ts
submissionApi.ts
userApi.ts
```

### Helpers/Utilities

**Pattern**: camelCase with descriptive name, `.ts` extension

```
myFeatureHelpers.ts
validation.ts
transformers.ts
constants.ts
```

### Types

**Pattern**: camelCase, `index.ts` or descriptive name

```
types/index.ts
types/submission.ts
types/user.ts
```

---

## When to Create a New Feature

### Create New Feature When:

- Multiple related components (>3)
- Has own API endpoints
- Domain-specific logic
- Will grow over time
- Reused across multiple routes

**Example:** `features/submissions/`
- 20+ components
- Own API service
- Complex state management
- Used in multiple routes

### Add to Existing Feature When:

- Related to existing feature
- Shares same API
- Logically grouped
- Extends existing functionality

**Example:** Adding export dialog to submissions feature

### Create Reusable Component When:

- Used across 3+ features
- Generic, no domain logic
- Pure presentation
- Shared pattern

**Example:** `components/SuspenseLoader/`

---

## Import Organization

### Import Order (Recommended)

```typescript
// 1. React and React-related
import React, { useState, useCallback, useMemo } from 'react';
import { lazy } from 'react';

// 2. Third-party libraries (alphabetical)
import { Box, Paper, Button, Grid } from '@mui/material';
import type { SxProps, Theme } from '@mui/material';
import { useSuspenseQuery, useQueryClient } from '@tanstack/react-query';
import { createFileRoute } from '@tanstack/react-router';

// 3. Alias imports (@ first, then ~)
import { apiClient } from '@/lib/apiClient';
import { useAuth } from '@/hooks/useAuth';
import { useMuiSnackbar } from '@/hooks/useMuiSnackbar';
import { SuspenseLoader } from '~components/SuspenseLoader';
import { submissionApi } from '~features/submissions/api/submissionApi';

// 4. Type imports (grouped)
import type { Submission } from '~types/submission';
import type { User } from '~types/user';

// 5. Relative imports (same feature)
import { MySubComponent } from './MySubComponent';
import { useMyFeature } from '../hooks/useMyFeature';
import { myFeatureHelpers } from '../helpers/myFeatureHelpers';
```

**Use single quotes** for all imports (project standard)

---

## Public API Pattern

### feature/index.ts

Export public API from feature for clean imports:

```typescript
// features/my-feature/index.ts

// Export main components
export { MyFeatureMain } from './components/MyFeatureMain';
export { MyFeatureHeader } from './components/MyFeatureHeader';

// Export hooks
export { useMyFeature } from './hooks/useMyFeature';
export { useSuspenseMyFeature } from './hooks/useSuspenseMyFeature';

// Export API
export { myFeatureApi } from './api/myFeatureApi';

// Export types
export type { MyFeatureData, MyFeatureConfig } from './types';
```

**Usage:**
```typescript
// ✅ Clean import from feature index
import { MyFeatureMain, useMyFeature } from '~features/my-feature';

// ❌ Avoid deep imports (but OK if needed)
import { MyFeatureMain } from '~features/my-feature/components/MyFeatureMain';
```

---

## Directory Structure Visualization

```
src/
├── features/                    # Domain-specific features
│   ├── submissions/
│   │   ├── api/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── helpers/
│   │   ├── types/
│   │   └── index.ts
│   ├── forms/
│   └── auth/
│
├── components/                  # Reusable components
│   ├── SuspenseLoader/
│   ├── CustomAppBar/
│   ├── ErrorBoundary/
│   └── LoadingOverlay/
│
├── routes/                      # TanStack Router routes
│   ├── __root.tsx
│   ├── index.tsx
│   ├── project-catalog/
│   │   ├── index.tsx
│   │   └── create/
│   └── forms/
│
├── hooks/                       # Shared hooks
│   ├── useAuth.ts
│   ├── useMuiSnackbar.ts
│   └── useDebounce.ts
│
├── lib/                         # Shared utilities
│   ├── apiClient.ts
│   └── utils.ts
│
├── types/                       # Shared TypeScript types
│   ├── user.ts
│   ├── submission.ts
│   └── common.ts
│
├── config/                      # Configuration
│   └── theme.ts
│
└── App.tsx                      # Root component
```

---

## Summary

**Key Principles:**
1. **features/** for domain-specific code
2. **components/** for truly reusable UI
3. Use subdirectories: api/, components/, hooks/, helpers/, types/
4. Import aliases for clean imports (@/, ~types, ~components, ~features)
5. Consistent naming: PascalCase components, camelCase utilities
6. Export public API from feature index.ts

**See Also:**
- [component-patterns.md](component-patterns.md) - Component structure
- [data-fetching.md](data-fetching.md) - API service patterns
- [complete-examples.md](complete-examples.md) - Full feature example