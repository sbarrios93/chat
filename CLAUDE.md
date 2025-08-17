# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a LibreChat + LiteLLM integrated deployment using Docker Compose. The project combines LibreChat's superior chat interface with LiteLLM's powerful model proxy capabilities, providing a complete chat solution with model routing, search functionality, and data persistence.

## Architecture

The setup consists of five main services:
- **LibreChat API**: Chat interface and API running on port 3080
- **LiteLLM Proxy**: Model routing and analytics on port 4000
- **MongoDB**: LibreChat data storage (conversations, users)
- **Meilisearch**: Enhanced search functionality for chat history
- **PostgreSQL**: LiteLLM analytics and configuration data (port 5433)

Configuration is managed through:
- `docker-compose.yml`: Service definitions and container orchestration
- `librechat.yaml`: LibreChat configuration pointing to LiteLLM proxy
- `litellm_config.yaml`: LiteLLM proxy configuration with gpt-5-smart model
- `.env`: Environment variables (not tracked in git)

## Common Commands

### Development and Deployment
```bash
# Start all services (LibreChat + LiteLLM + databases)
docker-compose up -d

# View service logs
docker-compose logs -f api          # LibreChat API logs
docker-compose logs -f litellm      # LiteLLM proxy logs
docker-compose logs -f mongodb      # MongoDB logs
docker-compose logs -f meilisearch  # Search functionality logs
docker-compose logs -f db           # PostgreSQL logs

# Stop all services
docker-compose down

# Restart specific services
docker-compose restart api      # Restart LibreChat
docker-compose restart litellm  # Restart LiteLLM proxy

# Check service status
docker-compose ps
```

### Configuration Management
```bash
# Edit LiteLLM proxy configuration
# Modify litellm_config.yaml then restart:
docker-compose restart litellm

# Edit LibreChat configuration
# Modify librechat.yaml then restart:
docker-compose restart api

# Test GPT-5 Smart model
./curl_gpt5_smart.sh "Your test prompt here"

# View current environment variables
docker-compose exec litellm env | grep -E "(DATABASE_URL|STORE_MODEL_IN_DB)"
```

### Database Operations
```bash
# Connect to PostgreSQL (LiteLLM data)
docker-compose exec db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -p 5433

# Connect to MongoDB (LibreChat data)
docker-compose exec mongodb mongosh

# Backup databases
docker-compose exec db pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > litellm_backup.sql
docker-compose exec mongodb mongodump --out /data/db/backup

# View database logs
docker-compose logs db       # PostgreSQL logs
docker-compose logs mongodb  # MongoDB logs
```

### Access and Health Checks
```bash
# Access LibreChat web interface
# Open http://localhost:3080 in browser

# Check LiteLLM proxy health
curl http://localhost:4000/health/liveliness
curl http://localhost:4000/health/readiness

# Check LibreChat API health
curl http://localhost:3080/api/health
```

## Important Notes

### Configuration
- LiteLLM proxy configuration: `litellm_config.yaml` → `/app/config.yaml` in container
- LibreChat configuration: `librechat.yaml` → `/app/librechat.yaml` in container
- LibreChat connects to LiteLLM via `http://litellm:4000/v1` (internal Docker network)

### Security
- **All sensitive data** (API keys, database credentials) stored in `.env` file
- `.env` file is gitignored - never commit it to version control
- Generated JWT secrets and encryption keys for LibreChat security

### Data Persistence
- PostgreSQL data: `litellm_postgres_data` named volume (LiteLLM analytics)
- MongoDB data: `./data-node/` directory (LibreChat conversations, users)
- Meilisearch data: `./meili_data/` directory (search indexes)
- Application logs: `./logs/` directory
- **Important**: All data directories (`data-node/`, `meili_data/`, `logs/`, `uploads/`, `images/`) are excluded from git

### Models and Features
- Configured with `gpt-5-smart` model with high reasoning effort
- LibreChat provides superior UI with conversation management, search, file uploads
- LiteLLM handles model routing, analytics, and API management
- Health checks configured for all services

### Network Architecture
```
User → LibreChat (3080) → LiteLLM (4000) → OpenAI API
         ↓
     MongoDB (conversations)
         ↓
     Meilisearch (search)
```