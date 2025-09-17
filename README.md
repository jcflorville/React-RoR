# React + Rails Full-Stack Application

Este projeto é uma aplicação full-stack com React (frontend) e Ruby on Rails API (backend), totalmente dockerizada para desenvolvimento.

## � Pré-requisitos

- **Docker** e **Docker Compose**
- **Node.js 22.16.0** (para desenvolvimento local)
- **pnpm** (gerenciador de pacotes)

### Configuração do Node.js

Este projeto usa Node.js 22.16.0. Para garantir consistência:

**Com nvm:**

```bash
# Use a versão especificada no .nvmrc
nvm use

# Ou instale a versão específica
nvm install 22.16.0
nvm use 22.16.0
```

**Com asdf:**

```bash
# Use a versão especificada no .tool-versions
asdf install
```

**Com fnm:**

```bash
# Use a versão especificada no .nvmrc
fnm use
```

**Instalar pnpm:**

```bash
npm install -g pnpm
```

## �🚀 Quick Start

### Levantar todo o stack (Recomendado)

```bash
# No diretório raiz do projeto
pnpm run dev
```

Isso irá iniciar:

- **Frontend React**: `http://localhost:5173`
- **Backend Rails API**: `http://localhost:3000`
- **PostgreSQL Database**: `localhost:5432`

### Comandos Úteis

```bash
# Iniciar em modo detached (background)
pnpm run dev:detached

# Parar todos os serviços
pnpm run down

# Ver logs de todos os serviços
pnpm run logs

# Ver logs específicos
pnpm run logs:frontend
pnpm run logs:backend
pnpm run logs:db

# Reiniciar serviços
pnpm run restart
pnpm run restart:frontend
pnpm run restart:backend

# Limpar tudo (volumes, networks, etc.)
pnpm run clean

# Rebuild completo
pnpm run rebuild
```

### Comandos Individuais (se precisar)

```bash
# Apenas frontend
pnpm run frontend:dev

# Apenas backend
pnpm run backend:dev
```

## 🏗️ Arquitetura

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
├── docker-compose.yml  # Orquestração completa
└── package.json        # Scripts de gerenciamento
```

## 🔧 Configuração

### Variáveis de Ambiente

As variáveis estão configuradas no `docker-compose.yml`:

**Frontend:**

- `VITE_API_URL=http://localhost:3000`

**Backend:**

- `DATABASE_URL=postgresql://postgres:password@db:5432/myapp_development`
- `RAILS_ENV=development`

### Networking

Todos os serviços rodam na mesma rede Docker (`fullstack-network`), permitindo comunicação entre eles usando os nomes dos serviços.

## 🔍 Troubleshooting

### Se o backend não conectar ao banco:

```bash
npm run logs:db
npm run logs:backend
```

### Se o frontend não conseguir acessar a API:

- Verifique se `VITE_API_URL` está correto
- Confirme se o backend está rodando na porta 3000

### Para rebuild completo:

```bash
pnpm run clean
pnpm run rebuild
```

## 🚀 Desenvolvimento

1. **Hot Reload**: Ambos frontend e backend têm hot reload ativo
2. **Volume Mounting**: Suas alterações de código são refletidas instantaneamente
3. **Logs em Tempo Real**: Use `pnpm run logs` para monitorar

## 📝 Próximos Passos

- [ ] Configurar CORS no Rails para permitir requests do frontend
- [ ] Adicionar seeds para o banco de dados
- [ ] Configurar testes automatizados
- [ ] Setup de produção com Docker

Agora você pode desenvolver tanto frontend quanto backend simultaneamente! 🎉
