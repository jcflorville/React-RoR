# AI Coding Agent Guidelines - React + Rails Full-Stack

## Essential Commands

### Docker Development (ALL commands must run through Docker)
```bash
# Start entire stack
pnpm run dev

# Backend Rails operations
docker compose exec backend bash -lc 'bin/rails console'
docker compose exec backend bash -lc 'bin/rails db:migrate'
docker compose exec backend bash -lc 'bin/rspec spec/path/to/spec.rb'

# Frontend operations
docker compose exec frontend pnpm run lint
docker compose exec frontend pnpm run test
docker compose exec frontend pnpm run build

# Database access
docker compose exec db psql -U postgres -d myapp_development

# Logs and debugging
pnpm run logs:backend
pnpm run logs:frontend
pnpm run logs:db
```

### Single Test Execution
```bash
# Backend single test
docker compose exec backend bash -lc 'bin/rspec spec/requests/projects_spec.rb:15'

# Frontend single test
docker compose exec frontend pnpm test path/to/test.test.tsx
```

### Code Quality Commands
```bash
# Backend linting (run in backend container)
docker compose exec backend bash -lc 'rubocop'

# Frontend linting (run in frontend container)
docker compose exec frontend pnpm run lint

# Type checking
docker compose exec frontend pnpm run build
```

## Code Style Guidelines

### Backend (Ruby/Rails)
- **Ruby Version**: 3.4.5, **Rails**: 8.0.2
- **Style Guide**: RuboCop with Rails Omakase configuration
- **String Literals**: Use single quotes
- **File Encoding**: UTF-8
- **Indentation**: 2 spaces
- **Method Naming**: snake_case for methods, PascalCase for classes
- **Service Objects**: Inherit from BaseService, use .call class method

### Frontend (TypeScript/React)
- **TypeScript**: Strict mode enabled, target ES2022
- **Imports**: Use absolute path aliases (@/, @components/, @hooks/, etc.)
- **Component Naming**: PascalCase for components, camelCase for functions
- **File Extensions**: .tsx for React components, .ts for utilities
- **ESLint**: React hooks and TypeScript rules enforced

### Import Organization
```typescript
// External libraries first
import React from 'react'
import { useQuery } from '@tanstack/react-query'

// Internal imports with aliases
import { Button } from '@/components/ui'
import { useAuthStore } from '@/stores'
import type { User } from '@/types'

// Local imports last
import './styles.css'
```

## Architecture Patterns

### Backend Service Layer Pattern
```ruby
# All services inherit from BaseService and return Result struct
class Projects::Creator < BaseService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    # Business logic here
    if project.save
      success(data: project, message: "Project created")
    else
      failure(errors: format_errors(project), message: "Failed")
    end
  end
end
```

### Blueprinter Serialization
```ruby
# Auto-inferred blueprints in app/blueprints/
class ProjectBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :description, :status, :priority
  
  # Conditional associations
  association :tasks, blueprint: TaskBlueprint,
    if: ->(_, _, options) { options[:include]&.include?(:tasks) }
end
```

### Frontend Component Structure
```typescript
// API services in src/lib/api/services/
// TanStack Query hooks in src/hooks/queries/
// Types in src/types/
// Components in src/components/
```

## Response Format Standards

### API Response Format (Flat JSON)
```json
{
  "success": true,
  "data": { "id": 1, "name": "Project" },
  "message": "Success"
}
```

### Controller Response Methods
```ruby
# Use ApiResponse concern methods
render_success(data, message)
render_error(message, errors)
render_auth_success(user, message)
```

## Testing Strategy

### Backend (RSpec)
- **Request Specs**: API endpoints in spec/requests/
- **Service Specs**: Business logic in spec/services/
- **Model Specs**: Validations in spec/models/
- **Factories**: Use FactoryBot with create(:user), build(:project)
- **Test Helpers**: 
  - auth_headers(user) for JWT authentication
  - json_response for response parsing

### Frontend (Vitest + React Testing Library)
- **Component Tests**: src/components/__tests__/
- **Hook Tests**: Test custom hooks separately
- **Setup File**: src/test/setup.ts with global mocks
- **Coverage**: Excludes types, configs, and generated files

## Critical Rules & Gotchas

### Docker Mandate
- **NEVER** run Rails/Node commands directly - always use Docker containers
- Use `bash -lc` for Rails commands to ensure proper shell initialization
- Frontend commands run in frontend container, backend in backend container

### Service Object Requirements
- All business logic MUST be in service objects
- Services MUST return Result struct (success?, data, errors, message)
- Controllers only orchestrate, never contain business logic

### Authentication Patterns
- JWT tokens via devise-jwt
- Authenticated endpoints inherit from Api::V1::Authenticated::BaseController
- Token in Authorization: Bearer <token> header

### Blueprinter Specifics
- Blueprints in app/blueprints/ (not app/serializers/)
- Conditional associations need lambda: if: ->(_, _, options) { condition }
- Use serialize_data() for automatic blueprint inference

### Frontend Integration
- API calls in src/lib/api/services/
- State management: Zustand (auth) + TanStack Query (server state)
- File-based routing with TanStack Router
- Form validation with Zod + React Hook Form

## File Organization Quick Reference

### Adding New API Endpoint
1. Create service in app/services/namespace/
2. Create/identify blueprint in app/blueprints/
3. Add controller action calling service
4. Define route in config/routes.rb
5. Write request spec in spec/requests/

### Adding Frontend Feature
1. Define types in src/types/
2. Create API service in src/lib/api/services/
3. Create TanStack Query hook in src/hooks/queries/
4. Add route in src/routes/
5. Build component using hooks

### Debug Commands
```bash
# Check all logs
pnpm run logs

# Full rebuild (if environment issues)
pnpm run clean && pnpm run rebuild
```