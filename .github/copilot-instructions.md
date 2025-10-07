# AI Coding Agent Instructions - React + Rails Full-Stack

## Project Context

This is a learning project by a Senior Fullstack Developer focused on practicing and refining fundamental concepts while maintaining professional-grade standards. The goal is to explore different approaches and solidify best practices through hands-on implementation.

## Developer Profile

- **Experience Level**: Senior Fullstack Developer
- **Expectation**: Professional, production-ready code is the baseline, not the goal
- **Focus**: Deep understanding of concepts, trade-offs, and architectural decisions

## Code Standards

- **Language**: All code, variables, functions, comments, and documentation must be written in English, regardless of the conversation language
- **Architecture**: Apply SOLID principles pragmatically - focus on practical benefits rather than strict dogmatic adherence
- **Frameworks**: Follow Rails conventions and React best practices as the primary guidelines
- **Performance**: Always consider and discuss performance implications in solutions
- **Best Practices**: Prioritize code quality, readability, and maintainability as standard practice

## Development Philosophy

Treat this as a senior-level exploration of fundamentals. Provide explanations that assume strong technical background, discuss architectural trade-offs, and suggest optimizations. Skip basic explanations unless specifically requested. Focus on the "why" behind decisions, not just the "how".

## Architecture Overview

This is a **dockerized full-stack application** with:

- **Backend**: Rails 8 API-only (Ruby 3.4.5) with JWT authentication
- **Frontend**: React 19 + Vite + TypeScript + TanStack Router
- **Database**: PostgreSQL 16 with separate dev/test databases
- **State Management**: Zustand (auth) + TanStack Query (server state)

### Key Architectural Patterns

**Service Layer Pattern**: All business logic lives in service objects (`app/services/`) using the Command pattern:

```ruby
# Services return a Result struct with success?, data, errors, message
result = Projects::Creator.call(user: current_user, params: project_params)
if result.success?
  render_success(result.data, result.message)
else
  render_error(result.message, result.errors)
end
```

**Modular API Response**: The `ApiResponse` concern is split into 3 modules:

- `ApiResponse` - Core response methods (`render_success`, `render_error`, `render_auth_success`)
- `ApiSerialization` - Handles Blueprinter serialization with auto-inference and conditional includes (optimized)
- `ApiPagination` - Pagination metadata helpers

**Blueprinter Serialization**: Uses Blueprinter for clean, flat JSON responses with auto-inference:

```ruby
# app/blueprints/project_blueprint.rb
class ProjectBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :status, :priority

  field :overdue { |project| project.overdue? }

  # Conditional associations
  association :tasks, blueprint: TaskBlueprint,
    if: ->(_, _, options) { options[:include]&.include?(:tasks) }

  association :categories, blueprint: CategoryBlueprint,
    if: ->(_, _, options) { options[:include]&.include?(:categories) }
end

# In controllers - blueprint auto-inferred from model
serialize_data(project)  # → ProjectBlueprint
serialize_data(tasks)    # → TaskBlueprint
# Or explicit when needed
serialize_data(data, blueprint: CustomBlueprint)
```

**Conditional Includes Pattern**: Use query parameters to optionally include relationships:

```ruby
# API call: GET /api/v1/projects/1?include=tasks,categories
# Blueprinter renders only requested associations
```

**Response Format** (Flat JSON):

```json
{
	"success": true,
	"data": {
		"id": 1,
		"name": "Project",
		"tasks": [{ "id": 1, "title": "Task 1" }],
		"categories": [{ "id": 1, "name": "Dev" }]
	},
	"message": "Success"
}
```

## Development Workflow

### Essential Docker Commands

**ALL commands must run through Docker** - never run Rails/Node commands directly:

```bash
# Start entire stack (from project root)
pnpm run dev

# Backend Rails commands
docker compose exec backend bash -lc 'bin/rails console'
docker compose exec backend bash -lc 'bin/rails db:migrate'
docker compose exec backend bash -lc 'bin/rspec spec/path/to/spec.rb'
docker compose exec backend bash -lc 'bin/rails db:seed'

# Frontend commands
docker compose exec frontend pnpm add package-name
docker compose exec frontend pnpm run dev

# Database access
docker compose exec db psql -U postgres -d myapp_development
```

### Testing Strategy

**Backend (RSpec)**:

- Request specs for API endpoints (`spec/requests/`)
- Service specs for business logic (`spec/services/`)
- Model specs for validations (`spec/models/`)
- Use FactoryBot for test data: `create(:user)`, `build(:project)`
- Run specs: `docker compose exec backend bash -lc 'bin/rspec'`

**Test Helpers** in `spec/support/`:

- `auth_helpers.rb` - `auth_headers(user)` for authenticated requests
- `json_helpers.rb` - `json_response` for parsing responses

## Project-Specific Conventions

### Backend Patterns

**1. Controller Structure**:

- All authenticated endpoints inherit from `Api::V1::Authenticated::BaseController`
- Use service objects for ALL business logic - controllers only orchestrate
- Render responses using Blueprinter: `render_success(data, message, blueprint: ProjectBlueprint)`

**2. Routing Conventions**:

- Nested routes for parent-child operations: `/projects/:id/tasks`
- Flat routes for global operations: `/tasks/mine`, `/tasks/overdue`
- Auth routes at `/api/v1/auth/sign_in`, `/api/v1/auth/sign_up`

**3. Service Object Pattern**:

```ruby
# All services inherit from BaseService and use .call class method
class Projects::Creator < BaseService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    project = @user.projects.new(@params)
    if project.save
      success(data: project, message: "Project created")
    else
      failure(errors: format_errors(project), message: "Failed")
    end
  end
end
```

**4. Authentication**:

- JWT tokens managed by devise-jwt
- Current user available via `current_user` in authenticated controllers
- Token in `Authorization: Bearer <token>` header

### Frontend Patterns

**1. API Integration**:

- All API calls in `src/lib/api/services/`
- Use TanStack Query hooks in `src/hooks/queries/`
- Auth state in Zustand store: `src/stores/auth-store.ts`

**2. File-Based Routing**:

- TanStack Router uses file-based routing in `src/routes/`
- Protected routes check auth state via beforeLoad

**3. Type Safety**:

- API response types in `src/types/`
- Form validation with Zod + React Hook Form

## Critical Integration Points

### CORS Configuration

Backend allows frontend origin in `config/initializers/cors.rb` - update for production

### Environment Variables

- Backend: `DATABASE_URL`, `DEVISE_JWT_SECRET_KEY` in `docker-compose.yml`
- Frontend: `VITE_API_URL=http://localhost:3000` for API base URL

### Database Setup

Uses custom script to create multiple databases in PostgreSQL container:

- `myapp_development` - for development
- `myapp_test` - for testing (auto-cleaned between specs)

## Common Gotchas

1. **Never modify code without running in Docker** - environment differences will break things
2. **Blueprint associations use lambda conditions** - conditional includes need `if:` option with lambda
3. **Service objects must return Result struct** - don't return raw ActiveRecord objects
4. **Use `bash -lc` for Rails commands in Docker** - ensures proper shell initialization
5. **Frontend types must match backend blueprint output** - check flat JSON response format
6. **Test database resets on each spec** - no need to manually clean between tests
7. **Blueprints in `app/blueprints/`** - not `app/serializers/`, follows Blueprinter conventions

## Quick Reference

**Add new API endpoint**:

1. Create service in `app/services/namespace/`
2. Create blueprint in `app/blueprints/` if needed
3. Add controller action calling service
4. Define route in `config/routes.rb`
5. Write request spec in `spec/requests/`

**Add frontend feature**:

1. Define types in `src/types/`
2. Create API service in `src/lib/api/services/`
3. Create TanStack Query hook in `src/hooks/queries/`
4. Add route in `src/routes/`
5. Build component using hooks

**Debug issues**:

- Backend logs: `pnpm run logs:backend`
- Frontend logs: `pnpm run logs:frontend`
- Database: `pnpm run logs:db`
- Full rebuild: `pnpm run clean && pnpm run rebuild`
