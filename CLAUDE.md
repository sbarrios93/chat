# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a LiteLLM proxy deployment setup using Docker Compose. The project provides a containerized proxy service for accessing various LLM APIs through a unified interface, with PostgreSQL for persistence and Prometheus for monitoring.

## Architecture

The setup consists of three main services:
- **LiteLLM Proxy**: Main service running on port 4000, handles API requests and model routing
- **PostgreSQL Database**: Stores model configurations and proxy data (port 5432)
- **Prometheus**: Monitoring and metrics collection (port 9090)

Configuration is managed through:
- `docker-compose.yml`: Service definitions and container orchestration
- `litellm_config.yaml`: LiteLLM proxy configuration (currently empty, to be populated)
- `.env`: Environment variables (not tracked in git)

## Common Commands

### Development and Deployment
```bash
# Start all services
docker-compose up -d

# View service logs
docker-compose logs -f litellm
docker-compose logs -f db
docker-compose logs -f prometheus

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart litellm

# Check service status
docker-compose ps
```

### Configuration Management
```bash
# Edit proxy configuration
# Modify litellm_config.yaml then restart:
docker-compose restart litellm

# View current environment variables
docker-compose exec litellm env | grep -E "(DATABASE_URL|STORE_MODEL_IN_DB)"
```

### Database Operations
```bash
# Connect to PostgreSQL (using environment variables)
docker-compose exec db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Backup database
docker-compose exec db pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > backup.sql

# View database logs
docker-compose logs db
```

### Monitoring
```bash
# Access Prometheus metrics
# Open http://localhost:9090 in browser

# Check proxy health
curl http://localhost:4000/health/liveliness
curl http://localhost:4000/health/readiness
```

## Important Notes

- The proxy configuration is loaded from `litellm_config.yaml` which is mounted as `/app/config.yaml` in the container
- **Security**: All sensitive information (database credentials, API keys) is stored in `.env` file and referenced via environment variables in docker-compose.yml
- The `.env` file contains sensitive configuration and is gitignored - never commit it to version control
- PostgreSQL data persists in the `litellm_postgres_data` named volume
- Health checks are configured for both LiteLLM and PostgreSQL services
- Environment variables from `.env` are automatically loaded by both litellm and db services