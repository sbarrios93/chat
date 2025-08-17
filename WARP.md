# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a LiteLLM proxy deployment setup using Docker Compose. The project provides a containerized proxy service for accessing various LLM APIs through a unified interface, with PostgreSQL for persistence and custom handlers for request processing.

## Architecture

**Core Services:**
- **LiteLLM Proxy**: Main service on port 4000, handles API requests and model routing
- **PostgreSQL Database**: Stores model configurations and proxy data on port 5433

**Key Components:**
- `docker-compose.yml`: Service orchestration with health checks and volume persistence
- `litellm_config.yaml`: Proxy configuration defining model routing (currently configured for gpt-5-smart)
- `proxy_handler_instance.py`: Custom handlers for request preprocessing, content moderation, and callbacks
- `.env`: Environment variables for database credentials and API keys (gitignored)

The proxy uses a named volume `litellm_postgres_data` for data persistence and loads configuration from environment variables.

## Common Development Commands

### Service Management
```bash
# Start all services (proxy + database)
docker-compose up -d

# View service logs
docker-compose logs -f litellm
docker-compose logs -f db

# Restart after config changes
docker-compose restart litellm

# Stop all services
docker-compose down

# Check service status
docker-compose ps
```

### Configuration and Testing
```bash
# Test proxy health
curl http://localhost:4000/health/liveliness
curl http://localhost:4000/health/readiness

# Test gpt-5-smart model (using included script)
./curl_gpt5_smart.sh "Your test prompt here"

# View current proxy configuration
docker-compose exec litellm cat /app/config.yaml
```

### Database Operations
```bash
# Connect to PostgreSQL
docker-compose exec db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -p 5433

# Backup database
docker-compose exec db pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > backup.sql

# View database logs
docker-compose logs db
```

### Python Development
```bash
# Install dependencies (using uv)
uv sync

# Run Python scripts locally
uv run python proxy_handler_instance.py
```

## Model Configuration

The current setup is configured for GPT-5 with high reasoning effort:
- **Model**: `gpt-5-smart` → `gpt-5` 
- **Reasoning**: High effort with detailed summary
- **Text**: High verbosity
- **API Key**: Loaded from `OPENAI_API_KEY` environment variable

Model configurations are stored in the database when `store_model_in_db: true`.

## Custom Handlers

The `proxy_handler_instance.py` defines:
- **Pre-call hooks**: Request modification before API calls
- **Moderation hooks**: Content safety policy enforcement  
- **Logging callbacks**: Success/failure event handling

These handlers integrate with the LiteLLM proxy through the custom callback system.

## Environment Variables

Required in `.env` file:
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`: Database configuration
- `OPENAI_API_KEY`: OpenAI API access
- Additional variables loaded by both litellm and db services

## Important Notes

- All sensitive data is stored in `.env` (gitignored) and referenced via environment variables
- PostgreSQL runs on custom port 5433 instead of default 5432
- The proxy configuration is mounted from `litellm_config.yaml` to `/app/config.yaml` in container
- Health checks ensure services are ready before accepting traffic
- Database data persists across container restarts via named volumes
