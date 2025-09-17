# React + Rails Full-Stack Application

This project is a full-stack application with React (frontend) and Ruby on Rails API (backend), fully dockerized for development.

## 📋 Prerequisites

- **Docker** and **Docker Compose**
- **Node.js 22.16.0** (for local development)
- **pnpm** (package manager)

### Node.js Setup

This project uses Node.js 22.16.0. To ensure consistency:

**With nvm:**

```bash
# Use the version specified in .nvmrc
nvm use

# Or install the specific version
nvm install 22.16.0
nvm use 22.16.0
```

**With asdf:**

```bash
# Use the version specified in .tool-versions
asdf install
```

**With fnm:**

```bash
# Use the version specified in .nvmrc
fnm use
```

**Install pnpm:**

```bash
npm install -g pnpm
```

## 🚀 Quick Start

### Start the entire stack (Recommended)

```bash
# In the project root directory
pnpm run dev
```

This will start:

- **React Frontend**: `http://localhost:5173`
- **Rails API Backend**: `http://localhost:3000`
- **PostgreSQL Database**: `localhost:5432`

### Useful Commands

```bash
# Start in detached mode (background)
pnpm run dev:detached

# Stop all services
pnpm run down

# View logs from all services
pnpm run logs

# View specific logs
pnpm run logs:frontend
pnpm run logs:backend
pnpm run logs:db

# Restart services
pnpm run restart
pnpm run restart:frontend
pnpm run restart:backend

# Clean everything (volumes, networks, etc.)
pnpm run clean

# Complete rebuild
pnpm run rebuild
```

### Individual Commands (if needed)

```bash
# Frontend only
pnpm run frontend:dev

# Backend only
pnpm run backend:dev
```

## 🏗️ Architecture

```
React-RoR/
├── frontend/           # React + Vite + TypeScript
│   ├── Dockerfile.dev
│   ├── docker-compose.dev.yml
│   └── src/
├── backend/            # Rails API
│   ├── Dockerfile.dev
│   ├── docker-compose.dev.yml
│   └── app/
├── docker-compose.yml  # Complete orchestration
└── package.json        # Management scripts
```

## 🔧 Configuration

### Environment Variables

Variables are configured in `docker-compose.yml`:

**Frontend:**

- `VITE_API_URL=http://localhost:3000`

**Backend:**

- `DATABASE_URL=postgresql://postgres:password@db:5432/myapp_development`
- `RAILS_ENV=development`

### Networking

All services run on the same Docker network (`fullstack-network`), allowing communication between them using service names.

## 🔍 Troubleshooting

### If backend can't connect to database:

```bash
pnpm run logs:db
pnpm run logs:backend
```

### If frontend can't access the API:

- Check if `VITE_API_URL` is correct
- Confirm backend is running on port 3000

### For complete rebuild:

```bash
pnpm run clean
pnpm run rebuild
```

## 🚀 Development

1. **Hot Reload**: Both frontend and backend have active hot reload
2. **Volume Mounting**: Your code changes are reflected instantly
3. **Real-time Logs**: Use `pnpm run logs` to monitor

## 📝 Next Steps

- [ ] Configure CORS in Rails to allow frontend requests
- [ ] Add database seeds
- [ ] Configure automated tests
- [ ] Production setup with Docker

Now you can develop both frontend and backend simultaneously! 🎉
