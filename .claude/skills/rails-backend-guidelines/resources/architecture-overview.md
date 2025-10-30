# Architecture Overview

## Rails MVC + Service Objects

```
HTTP Request
    ↓
Routes (config/routes.rb)
    ↓
Controllers (request handling)
    ↓
Service Objects (business logic)
    ↓
Models (data validation & persistence)
    ↓
Database (ActiveRecord → SQL)
```

## Layer Responsibilities

### Routes
- Define HTTP endpoints
- Map URLs to controller actions
- Follow RESTful conventions

### Controllers
- Handle HTTP requests/responses
- Delegate to services or models
- Return appropriate status codes
- Thin - no business logic

### Service Objects
- Complex business logic
- Multi-step operations
- External API integration
- Reusable operations

### Models
- Data persistence (ActiveRecord)
- Validations and associations
- Scopes for queries
- Simple business rules

### Database
- Data storage
- Constraints and indexes
- Referential integrity

## Design Principles

✅ **Thin controllers** - Delegate to services
✅ **Smart models** - But not fat
✅ **Service objects** - For complex logic
✅ **RESTful routes** - Follow conventions
✅ **Single responsibility** - Each class one purpose

## See Also
- [controllers.md](controllers.md)
- [models.md](models.md)
- [services.md](services.md)
