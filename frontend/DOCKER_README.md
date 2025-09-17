# Docker Development Setup

This React application has been configured for development using Docker. This setup provides an isolated, consistent development environment with hot reload functionality.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

### Option 1: Using npm scripts (Recommended)

Start the development environment:

```bash
pnpm run docker:dev
```

Stop the development environment:

```bash
pnpm run docker:dev:down
```

View logs:

```bash
pnpm run docker:dev:logs
```

### Option 2: Using Docker Compose directly

Start the development environment:

```bash
docker-compose -f docker-compose.dev.yml up --build
```

Stop the development environment:

```bash
docker-compose -f docker-compose.dev.yml down
```

## Features

- **Hot Module Replacement (HMR)**: Changes to your code will automatically refresh in the browser
- **Volume Mounting**: Your local source code is mounted into the container, so changes are reflected immediately
- **Port Mapping**: The application is accessible at `http://localhost:5173`
- **Optimized for Development**: Uses polling for file watching to ensure compatibility with Docker

## Configuration

- **Dockerfile.dev**: Development-specific Dockerfile with Node.js and pnpm
- **docker-compose.dev.yml**: Docker Compose configuration for development
- **vite.config.ts**: Updated with Docker-compatible settings
- **.dockerignore**: Excludes unnecessary files from the Docker build context

## Troubleshooting

- If hot reload is not working, ensure the `CHOKIDAR_USEPOLLING=true` environment variable is set
- Make sure no other application is using port 5173
- Try rebuilding the container if you encounter issues: `pnpm run docker:dev:down && pnpm run docker:dev`

## Development Workflow

1. Start the Docker development environment
2. Open your browser to `http://localhost:5173`
3. Make changes to your code
4. Watch as the changes are automatically reflected in the browser
