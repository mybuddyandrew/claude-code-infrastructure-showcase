# Routing Guide

TanStack Router implementation with folder-based routing and lazy loading patterns.

---

## TanStack Router Overview

PLP uses **TanStack Router** with file-based routing:
- Folder structure defines routes
- Lazy loading for code splitting
- Type-safe routing
- Breadcrumb loaders

---

## Folder-Based Routing

### Directory Structure

```
routes/
  __root.tsx                    # Root layout
  index.tsx                     # Home route (/)
  project-catalog/
    index.tsx                   # /project-catalog
    create/
      index.tsx                 # /project-catalog/create
  forms/
    index.tsx                   # /forms
    $formId.tsx                 # /forms/:formId (dynamic)
```

**Pattern**:
- `index.tsx` = Route at that path
- `$param.tsx` = Dynamic parameter
- Nested folders = Nested routes

---

## Basic Route Pattern

### Example from project-catalog/index.tsx

```typescript
/**
 * Projects route component
 * Displays the main project catalog table
 */

import { createFileRoute } from '@tanstack/react-router';
import { lazy } from 'react';

// Lazy load the page component
const SubmissionTable = lazy(() =>
    import('@/features/submissions/components/SubmissionTable').then(
        (module) => ({ default: module.SubmissionTable }),
    ),
);

// Constants for this route
const PROJECT_CATALOG_FORM_ID = 744;
const PROJECT_CATALOG_PROJECT_ID = 225;

export const Route = createFileRoute('/project-catalog/')({
    component: ProjectCatalogPage,
    // Define breadcrumb data
    loader: () => ({
        crumb: 'Projects',
    }),
});

function ProjectCatalogPage() {
    return (
        <SubmissionTable
            formId={PROJECT_CATALOG_FORM_ID}
            projectId={PROJECT_CATALOG_PROJECT_ID}
            tableType='active_projects'
            title='Project Catalog'
        />
    );
}

export default ProjectCatalogPage;
```

**Key Points:**
- Lazy load heavy components
- `createFileRoute` with route path
- `loader` for breadcrumb data
- Page component renders content
- Export both Route and component

---

## Lazy Loading Routes

### Named Export Pattern

```typescript
import { lazy } from 'react';

// For named exports, use .then() to map to default
const MyPage = lazy(() =>
    import('@/features/my-feature/components/MyPage').then(
        (module) => ({ default: module.MyPage })
    )
);
```

### Default Export Pattern

```typescript
import { lazy } from 'react';

// For default exports, simpler syntax
const MyPage = lazy(() => import('@/features/my-feature/components/MyPage'));
```

### Why Lazy Load Routes?

- Code splitting - smaller initial bundle
- Faster initial page load
- Load route code only when navigated to
- Better performance

---

## createFileRoute

### Basic Configuration

```typescript
export const Route = createFileRoute('/my-route/')({
    component: MyRoutePage,
});

function MyRoutePage() {
    return <div>My Route Content</div>;
}
```

### With Breadcrumb Loader

```typescript
export const Route = createFileRoute('/my-route/')({
    component: MyRoutePage,
    loader: () => ({
        crumb: 'My Route Title',
    }),
});
```

Breadcrumb appears in navigation/app bar automatically.

### With Data Loader

```typescript
export const Route = createFileRoute('/my-route/')({
    component: MyRoutePage,
    loader: async () => {
        // Can prefetch data here
        const data = await api.getData();
        return { crumb: 'My Route', data };
    },
});
```

### With Search Params

```typescript
export const Route = createFileRoute('/search/')({
    component: SearchPage,
    validateSearch: (search: Record<string, unknown>) => {
        return {
            query: (search.query as string) || '',
            page: Number(search.page) || 1,
        };
    },
});

function SearchPage() {
    const { query, page } = Route.useSearch();
    // Use query and page
}
```

---

## Dynamic Routes

### Parameter Routes

```typescript
// routes/users/$userId.tsx

export const Route = createFileRoute('/users/$userId')({
    component: UserPage,
});

function UserPage() {
    const { userId } = Route.useParams();

    return <UserProfile userId={userId} />;
}
```

### Multiple Parameters

```typescript
// routes/forms/$formId/submissions/$submissionId.tsx

export const Route = createFileRoute('/forms/$formId/submissions/$submissionId')({
    component: SubmissionPage,
});

function SubmissionPage() {
    const { formId, submissionId } = Route.useParams();

    return <SubmissionEditor formId={formId} submissionId={submissionId} />;
}
```

---

## Navigation

### Programmatic Navigation

```typescript
import { useNavigate } from '@tanstack/react-router';

export const MyComponent: React.FC = () => {
    const navigate = useNavigate();

    const handleClick = () => {
        navigate({ to: '/project-catalog' });
    };

    return <Button onClick={handleClick}>Go to Projects</Button>;
};
```

### With Parameters

```typescript
const handleNavigate = () => {
    navigate({
        to: '/users/$userId',
        params: { userId: '123' },
    });
};
```

### With Search Params

```typescript
const handleSearch = () => {
    navigate({
        to: '/search',
        search: { query: 'test', page: 1 },
    });
};
```

---

## Route Layout Pattern

### Root Layout (__root.tsx)

```typescript
import { createRootRoute, Outlet } from '@tanstack/react-router';
import { Box } from '@mui/material';
import { CustomAppBar } from '~components/CustomAppBar';

export const Route = createRootRoute({
    component: RootLayout,
});

function RootLayout() {
    return (
        <Box>
            <CustomAppBar />
            <Box sx={{ p: 2 }}>
                <Outlet />  {/* Child routes render here */}
            </Box>
        </Box>
    );
}
```

### Nested Layouts

```typescript
// routes/dashboard/index.tsx
export const Route = createFileRoute('/dashboard/')({
    component: DashboardLayout,
});

function DashboardLayout() {
    return (
        <Box>
            <DashboardSidebar />
            <Box sx={{ flex: 1 }}>
                <Outlet />  {/* Nested routes */}
            </Box>
        </Box>
    );
}
```

---

## Complete Route Example

```typescript
/**
 * User profile route
 * Path: /users/:userId
 */

import { createFileRoute } from '@tanstack/react-router';
import { lazy } from 'react';
import { SuspenseLoader } from '~components/SuspenseLoader';

// Lazy load heavy component
const UserProfile = lazy(() =>
    import('@/features/users/components/UserProfile').then(
        (module) => ({ default: module.UserProfile })
    )
);

export const Route = createFileRoute('/users/$userId')({
    component: UserPage,
    loader: () => ({
        crumb: 'User Profile',
    }),
});

function UserPage() {
    const { userId } = Route.useParams();

    return (
        <SuspenseLoader>
            <UserProfile userId={userId} />
        </SuspenseLoader>
    );
}

export default UserPage;
```

---

## Summary

**Routing Checklist:**
- ✅ Folder-based: `routes/my-route/index.tsx`
- ✅ Lazy load components: `React.lazy(() => import())`
- ✅ Use `createFileRoute` with route path
- ✅ Add breadcrumb in `loader` function
- ✅ Wrap in `SuspenseLoader` for loading states
- ✅ Use `Route.useParams()` for dynamic params
- ✅ Use `useNavigate()` for programmatic navigation

**See Also:**
- [component-patterns.md](component-patterns.md) - Lazy loading patterns
- [loading-and-error-states.md](loading-and-error-states.md) - SuspenseLoader usage
- [complete-examples.md](complete-examples.md) - Full route examples