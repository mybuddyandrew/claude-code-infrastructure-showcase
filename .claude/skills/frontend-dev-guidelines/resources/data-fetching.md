# Data Fetching Patterns

Modern data fetching in PLP using TanStack Query with Suspense boundaries, cache-first strategies, and centralized API services.

---

## PRIMARY PATTERN: useSuspenseQuery

### Why useSuspenseQuery?

For **all new components**, use `useSuspenseQuery` instead of regular `useQuery`:

**Benefits:**
- No `isLoading` checks needed
- Integrates with Suspense boundaries
- Cleaner component code
- Consistent loading UX
- Better error handling with error boundaries

### Basic Pattern

```typescript
import { useSuspenseQuery } from '@tanstack/react-query';
import { myFeatureApi } from '../api/myFeatureApi';

export const MyComponent: React.FC<Props> = ({ id }) => {
    // No isLoading - Suspense handles it!
    const { data } = useSuspenseQuery({
        queryKey: ['myEntity', id],
        queryFn: () => myFeatureApi.getEntity(id),
    });

    // data is ALWAYS defined here (not undefined | Data)
    return <div>{data.name}</div>;
};

// Wrap in Suspense boundary
<SuspenseLoader>
    <MyComponent id={123} />
</SuspenseLoader>
```

### useSuspenseQuery vs useQuery

| Feature | useSuspenseQuery | useQuery |
|---------|------------------|----------|
| Loading state | Handled by Suspense | Manual `isLoading` check |
| Data type | Always defined | `Data \| undefined` |
| Use with | Suspense boundaries | Traditional components |
| Recommended for | **NEW components** | Legacy code only |
| Error handling | Error boundaries | Manual error state |

**When to use regular useQuery:**
- Maintaining legacy code
- Very simple cases without Suspense
- Polling with background updates

**For new components: Always prefer useSuspenseQuery**

---

## Cache-First Strategy

### Pattern from useSuspenseSubmission.ts

**Smart caching** reduces API calls by checking React Query cache first:

```typescript
import { useSuspenseQuery, useQueryClient } from '@tanstack/react-query';
import { myFeatureApi } from '../api/myFeatureApi';

export function useSuspenseMyEntity(formId: number, entityId: number) {
    const queryClient = useQueryClient();

    return useSuspenseQuery({
        queryKey: ['entity', formId, entityId],
        queryFn: async () => {
            // Strategy 1: Try to get from grid cache first
            const cachedGridData = queryClient.getQueryData<{ rows: MyEntity[] }>([
                'entities-v2',
                formId,
                'summary'
            ]);

            if (cachedGridData?.rows) {
                const cachedEntity = cachedGridData.rows.find(
                    (row) => row.id === entityId
                );

                if (cachedEntity) {
                    return cachedEntity;  // Return from cache!
                }
            }

            // Strategy 2: Not in cache, fetch from API
            return myFeatureApi.getEntity(formId, entityId);
        },
        staleTime: 5 * 60 * 1000,      // Consider fresh for 5 minutes
        gcTime: 10 * 60 * 1000,         // Keep in cache for 10 minutes
        refetchOnWindowFocus: false,    // Don't refetch on focus
    });
}
```

**Key Points:**
- Check grid/list cache before API call
- Avoids redundant requests
- `staleTime`: How long data is considered fresh
- `gcTime`: How long unused data stays in cache
- `refetchOnWindowFocus: false`: User preference

---

## Parallel Data Fetching

### useSuspenseQueries

When fetching multiple independent resources:

```typescript
import { useSuspenseQueries } from '@tanstack/react-query';

export const MyComponent: React.FC = () => {
    const [userQuery, settingsQuery, preferencesQuery] = useSuspenseQueries({
        queries: [
            {
                queryKey: ['user'],
                queryFn: () => userApi.getCurrentUser(),
            },
            {
                queryKey: ['settings'],
                queryFn: () => settingsApi.getSettings(),
            },
            {
                queryKey: ['preferences'],
                queryFn: () => preferencesApi.getPreferences(),
            },
        ],
    });

    // All data available, Suspense handles loading
    const user = userQuery.data;
    const settings = settingsQuery.data;
    const preferences = preferencesQuery.data;

    return <Display user={user} settings={settings} prefs={preferences} />;
};
```

**Benefits:**
- All queries in parallel
- Single Suspense boundary
- Type-safe results

---

## Query Keys Organization

### Naming Convention

```typescript
// Entity list
['entities', formId]
['entities', formId, 'summary']    // With view mode
['entities', formId, 'flat']

// Single entity
['entity', formId, entityId]

// Related data
['entity', entityId, 'history']
['entity', entityId, 'comments']

// User-specific
['user', userId, 'profile']
['user', userId, 'permissions']
```

**Rules:**
- Start with entity name (plural for lists, singular for one)
- Include IDs for specificity
- Add view mode / relationship at end
- Consistent across app

### Query Key Examples

```typescript
// From useSuspenseSubmission.ts
queryKey: ['submission', formId, submissionId]
queryKey: ['submissions-v2', formId, 'summary']

// Invalidation patterns
queryClient.invalidateQueries({ queryKey: ['submission', formId] });  // All submissions for form
queryClient.invalidateQueries({ queryKey: ['submission'] });          // All submissions
```

---

## API Service Layer Pattern

### File Structure

Create centralized API service per feature:

```
features/
  my-feature/
    api/
      myFeatureApi.ts    # Service layer
```

### Service Pattern (from submissionApi.ts)

```typescript
/**
 * Centralized API service for my-feature operations
 * Uses apiClient for consistent error handling
 */
import apiClient from '@/lib/apiClient';
import type { MyEntity, UpdatePayload } from '../types';

export const myFeatureApi = {
    /**
     * Fetch a single entity
     */
    getEntity: async (formId: number, entityId: number): Promise<MyEntity> => {
        const { data } = await apiClient.get(
            `/form/entities/${formId}/${entityId}`
        );
        return data;
    },

    /**
     * Fetch all entities for a form
     */
    getEntities: async (formId: number, view: 'summary' | 'flat'): Promise<MyEntity[]> => {
        const { data } = await apiClient.get(
            `/form/entities/${formId}`,
            { params: { view } }
        );
        return data.rows;
    },

    /**
     * Update entity
     */
    updateEntity: async (
        formId: number,
        entityId: number,
        payload: UpdatePayload
    ): Promise<MyEntity> => {
        const { data } = await apiClient.put(
            `/form/entities/${formId}/${entityId}`,
            payload
        );
        return data;
    },

    /**
     * Delete entity
     */
    deleteEntity: async (formId: number, entityId: number): Promise<void> => {
        await apiClient.delete(`/form/entities/${formId}/${entityId}`);
    },
};
```

**Key Points:**
- Export single object with methods
- Use `apiClient` (axios instance from `@/lib/apiClient`)
- Type-safe parameters and returns
- JSDoc comments for each method
- Centralized error handling (apiClient handles it)

---

## Route Format Rules (IMPORTANT)

### Correct Format

```typescript
// ✅ CORRECT - Direct service path
await apiClient.get('/form/submissions/123');
await apiClient.post('/projects/create', data);
await apiClient.put('/users/update/456', updates);
await apiClient.get('/email/templates');

// ❌ WRONG - Do NOT add /api/ prefix
await apiClient.get('/api/form/submissions/123');  // WRONG!
await apiClient.post('/api/projects/create', data); // WRONG!
```

**Microservice Routing:**
- Form service: `/form/*`
- Projects service: `/projects/*`
- Email service: `/email/*`
- Users service: `/users/*`

**Why:** API routing is handled by proxy configuration, no `/api/` prefix needed.

---

## Mutations

### Basic Mutation Pattern

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { myFeatureApi } from '../api/myFeatureApi';
import { useMuiSnackbar } from '@/hooks/useMuiSnackbar';

export const MyComponent: React.FC = () => {
    const queryClient = useQueryClient();
    const { showSuccess, showError } = useMuiSnackbar();

    const updateMutation = useMutation({
        mutationFn: (payload: UpdatePayload) =>
            myFeatureApi.updateEntity(formId, entityId, payload),

        onSuccess: () => {
            // Invalidate and refetch
            queryClient.invalidateQueries({
                queryKey: ['entity', formId, entityId]
            });
            showSuccess('Entity updated successfully');
        },

        onError: (error) => {
            showError('Failed to update entity');
            console.error('Update error:', error);
        },
    });

    const handleUpdate = () => {
        updateMutation.mutate({ name: 'New Name' });
    };

    return (
        <Button
            onClick={handleUpdate}
            disabled={updateMutation.isPending}
        >
            {updateMutation.isPending ? 'Updating...' : 'Update'}
        </Button>
    );
};
```

### Optimistic Updates

```typescript
const updateMutation = useMutation({
    mutationFn: (payload) => myFeatureApi.update(id, payload),

    // Optimistic update
    onMutate: async (newData) => {
        // Cancel outgoing refetches
        await queryClient.cancelQueries({ queryKey: ['entity', id] });

        // Snapshot current value
        const previousData = queryClient.getQueryData(['entity', id]);

        // Optimistically update
        queryClient.setQueryData(['entity', id], (old) => ({
            ...old,
            ...newData,
        }));

        // Return rollback function
        return { previousData };
    },

    // Rollback on error
    onError: (err, newData, context) => {
        queryClient.setQueryData(['entity', id], context.previousData);
        showError('Update failed');
    },

    // Refetch after success or error
    onSettled: () => {
        queryClient.invalidateQueries({ queryKey: ['entity', id] });
    },
});
```

---

## Advanced Query Patterns

### Prefetching

```typescript
export function usePrefetchEntity() {
    const queryClient = useQueryClient();

    return (formId: number, entityId: number) => {
        return queryClient.prefetchQuery({
            queryKey: ['entity', formId, entityId],
            queryFn: () => myFeatureApi.getEntity(formId, entityId),
            staleTime: 5 * 60 * 1000,
        });
    };
}

// Usage: Prefetch on hover
<div onMouseEnter={() => prefetch(formId, id)}>
    <Link to={`/entity/${id}`}>View</Link>
</div>
```

### Cache Access Without Fetching

```typescript
export function useEntityFromCache(formId: number, entityId: number) {
    const queryClient = useQueryClient();

    // Get from cache, don't fetch if missing
    const directCache = queryClient.getQueryData<MyEntity>(['entity', formId, entityId]);

    if (directCache) return directCache;

    // Try grid cache
    const gridCache = queryClient.getQueryData<{ rows: MyEntity[] }>(['entities-v2', formId]);

    return gridCache?.rows.find(row => row.id === entityId);
}
```

### Dependent Queries

```typescript
// Fetch user first, then user's settings
const { data: user } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: () => userApi.getUser(userId),
});

const { data: settings } = useSuspenseQuery({
    queryKey: ['user', userId, 'settings'],
    queryFn: () => settingsApi.getUserSettings(user.id),
    // Automatically waits for user to load due to Suspense
});
```

---

## API Client Configuration

### Using apiClient

```typescript
import apiClient from '@/lib/apiClient';

// apiClient is a configured axios instance
// Automatically includes:
// - Base URL configuration
// - Cookie-based authentication
// - Error interceptors
// - Response transformers
```

**Do NOT create new axios instances** - use apiClient for consistency.

---

## Error Handling in Queries

### onError Callback

```typescript
import { useMuiSnackbar } from '@/hooks/useMuiSnackbar';

const { showError } = useMuiSnackbar();

const { data } = useSuspenseQuery({
    queryKey: ['entity', id],
    queryFn: () => myFeatureApi.getEntity(id),

    // Handle errors
    onError: (error) => {
        showError('Failed to load entity');
        console.error('Load error:', error);
    },
});
```

### Error Boundaries

Combine with Error Boundaries for comprehensive error handling:

```typescript
import { ErrorBoundary } from 'react-error-boundary';

<ErrorBoundary
    fallback={<ErrorDisplay />}
    onError={(error) => console.error(error)}
>
    <SuspenseLoader>
        <ComponentWithSuspenseQuery />
    </SuspenseLoader>
</ErrorBoundary>
```

---

## Complete Examples

### Example 1: Simple Entity Fetch

```typescript
import React from 'react';
import { useSuspenseQuery } from '@tanstack/react-query';
import { Box, Typography } from '@mui/material';
import { userApi } from '../api/userApi';

interface UserProfileProps {
    userId: string;
}

export const UserProfile: React.FC<UserProfileProps> = ({ userId }) => {
    const { data: user } = useSuspenseQuery({
        queryKey: ['user', userId],
        queryFn: () => userApi.getUser(userId),
        staleTime: 5 * 60 * 1000,
    });

    return (
        <Box>
            <Typography variant='h5'>{user.name}</Typography>
            <Typography>{user.email}</Typography>
        </Box>
    );
};

// Usage with Suspense
<SuspenseLoader>
    <UserProfile userId='123' />
</SuspenseLoader>
```

### Example 2: Cache-First Strategy

```typescript
import { useSuspenseQuery, useQueryClient } from '@tanstack/react-query';
import { submissionApi } from '../api/submissionApi';
import type { Submission } from '../types';

/**
 * Hook with cache-first strategy
 * Checks grid cache before API call
 */
export function useSuspenseSubmission(formId: number, submissionId: number) {
    const queryClient = useQueryClient();

    return useSuspenseQuery<Submission, Error>({
        queryKey: ['submission', formId, submissionId],
        queryFn: async () => {
            // 1. Check grid cache first
            const gridCache = queryClient.getQueryData<{ rows: Submission[] }>([
                'submissions-v2',
                formId,
                'summary'
            ]) || queryClient.getQueryData<{ rows: Submission[] }>([
                'submissions-v2',
                formId,
                'flat'
            ]);

            if (gridCache?.rows) {
                const cached = gridCache.rows.find(row => row.S_ID === submissionId);
                if (cached) {
                    return cached;  // Reuse grid data
                }
            }

            // 2. Not in cache, fetch directly
            return submissionApi.getSubmission(formId, submissionId);
        },
        staleTime: 5 * 60 * 1000,
        gcTime: 10 * 60 * 1000,
        refetchOnWindowFocus: false,
    });
}
```

**Benefits:**
- Avoids duplicate API calls
- Instant data if already loaded
- Falls back to API if not cached

### Example 3: Parallel Fetching

```typescript
import { useSuspenseQueries } from '@tanstack/react-query';

export const Dashboard: React.FC = () => {
    const [statsQuery, projectsQuery, notificationsQuery] = useSuspenseQueries({
        queries: [
            {
                queryKey: ['stats'],
                queryFn: () => statsApi.getStats(),
            },
            {
                queryKey: ['projects', 'active'],
                queryFn: () => projectsApi.getActiveProjects(),
            },
            {
                queryKey: ['notifications', 'unread'],
                queryFn: () => notificationsApi.getUnread(),
            },
        ],
    });

    return (
        <Box>
            <StatsCard data={statsQuery.data} />
            <ProjectsList projects={projectsQuery.data} />
            <Notifications items={notificationsQuery.data} />
        </Box>
    );
};
```

---

## Mutations with Cache Invalidation

### Update Mutation

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { submissionApi } from '../api/submissionApi';
import { useMuiSnackbar } from '@/hooks/useMuiSnackbar';

export const useUpdateSubmission = () => {
    const queryClient = useQueryClient();
    const { showSuccess, showError } = useMuiSnackbar();

    return useMutation({
        mutationFn: ({ formId, submissionId, data }: UpdateParams) =>
            submissionApi.updateSubmission(formId, submissionId, data),

        onSuccess: (data, variables) => {
            // Invalidate specific submission
            queryClient.invalidateQueries({
                queryKey: ['submission', variables.formId, variables.submissionId]
            });

            // Invalidate list to refresh grid
            queryClient.invalidateQueries({
                queryKey: ['submissions-v2', variables.formId]
            });

            showSuccess('Submission updated');
        },

        onError: (error) => {
            showError('Failed to update submission');
            console.error('Update error:', error);
        },
    });
};

// Usage
const updateSubmission = useUpdateSubmission();

const handleSave = () => {
    updateSubmission.mutate({
        formId: 123,
        submissionId: 456,
        data: { responses: { '101': 'value' } }
    });
};
```

### Delete Mutation

```typescript
export const useDeleteSubmission = () => {
    const queryClient = useQueryClient();
    const { showSuccess, showError } = useMuiSnackbar();

    return useMutation({
        mutationFn: ({ formId, submissionId }: DeleteParams) =>
            submissionApi.deleteSubmission(formId, submissionId),

        onSuccess: (data, variables) => {
            // Remove from cache manually (optimistic)
            queryClient.setQueryData<{ rows: Submission[] }>(
                ['submissions-v2', variables.formId],
                (old) => ({
                    ...old,
                    rows: old?.rows.filter(row => row.S_ID !== variables.submissionId) || []
                })
            );

            showSuccess('Submission deleted');
        },

        onError: (error, variables) => {
            // Rollback - refetch to get accurate state
            queryClient.invalidateQueries({
                queryKey: ['submissions-v2', variables.formId]
            });
            showError('Failed to delete submission');
        },
    });
};
```

---

## Query Configuration Best Practices

### Default Configuration

```typescript
// In QueryClientProvider setup
const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            staleTime: 1000 * 60 * 5,        // 5 minutes
            gcTime: 1000 * 60 * 10,           // 10 minutes (was cacheTime)
            refetchOnWindowFocus: false,       // Don't refetch on focus
            refetchOnMount: false,             // Don't refetch on mount if fresh
            retry: 1,                          // Retry failed queries once
        },
    },
});
```

### Per-Query Overrides

```typescript
// Frequently changing data - shorter staleTime
useSuspenseQuery({
    queryKey: ['notifications', 'unread'],
    queryFn: () => notificationApi.getUnread(),
    staleTime: 30 * 1000,  // 30 seconds
});

// Rarely changing data - longer staleTime
useSuspenseQuery({
    queryKey: ['form', formId, 'structure'],
    queryFn: () => formApi.getStructure(formId),
    staleTime: 30 * 60 * 1000,  // 30 minutes
});
```

---

## Summary

**Modern Data Fetching Recipe:**

1. **Create API Service**: `features/X/api/XApi.ts` using apiClient
2. **Use useSuspenseQuery**: In components wrapped by SuspenseLoader
3. **Cache-First**: Check grid cache before API call
4. **Query Keys**: Consistent naming ['entity', id]
5. **Route Format**: `/form/route` NOT `/api/form/route`
6. **Mutations**: invalidateQueries after success
7. **Error Handling**: onError + useMuiSnackbar
8. **Type Safety**: Type all parameters and returns

**See Also:**
- [component-patterns.md](component-patterns.md) - Suspense integration
- [loading-and-error-states.md](loading-and-error-states.md) - SuspenseLoader usage
- [complete-examples.md](complete-examples.md) - Full working examples