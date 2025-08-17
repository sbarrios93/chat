# LibreChat + LiteLLM Integration

This setup combines LibreChat's superior chat interface with LiteLLM's powerful model proxy capabilities.

## Architecture

```
User → LibreChat UI (3080) → LibreChat API → LiteLLM Proxy (4000) → OpenAI/Models
                                ↓
                            MongoDB (conversations)
                                ↓
                            Meilisearch (search)
```

## Services

- **LibreChat API** (port 3080): Main chat interface and API
- **LiteLLM Proxy** (port 4000): Model routing and analytics  
- **MongoDB** (port 27018): LibreChat data storage
- **PostgreSQL** (port 5433): LiteLLM analytics and logs
- **Meilisearch** (port 7700): Enhanced search functionality

## Quick Start

1. **Start all services:**
   ```bash
   ./manage.sh start
   ```

2. **Access LibreChat:**
   - Open http://localhost:3080 in your browser
   - Create an account (first user becomes admin)
   - Select "LiteLLM" from the model dropdown

3. **Monitor logs:**
   ```bash
   ./manage.sh logs
   ```

## Configuration Files

### `librechat.yaml`
- Configures LibreChat to use your LiteLLM proxy
- Exposes `gpt-5-smart` model from your LiteLLM config
- Sets up basic file upload capabilities

### `docker-compose.override.yml`
- Adds LibreChat services to your existing setup
- Configures MongoDB and Meilisearch
- Mounts configuration files

### `.env`
- Added LibreChat-specific environment variables
- MongoDB credentials and connection string
- Security keys for JWT and encryption

## Management Commands

- `./manage.sh start` - Start all services
- `./manage.sh stop` - Stop all services
- `./manage.sh restart` - Restart services
- `./manage.sh logs` - View logs
- `./manage.sh status` - Check service health
- `./manage.sh update` - Update to latest images

## Model Configuration

Your LiteLLM models are automatically available in LibreChat:

- **gpt-5-smart**: Your configured GPT-5 model with reasoning capabilities
- Additional models can be added to `litellm_config.yaml`

## Data Persistence

All data is persisted in Docker volumes:

- `librechat_mongodb_data`: User accounts and conversations
- `litellm_postgres_data`: LiteLLM analytics and logs  
- `librechat_meilisearch_data`: Search indexes

## Security Notes

1. **Change default passwords** in `.env` before production use
2. **Generate new JWT secrets** for production
3. **Use environment-specific credentials**
4. **Enable HTTPS** for production deployments

## Troubleshooting

### LibreChat can't connect to LiteLLM
- Check that LiteLLM service is running: `./manage.sh status`
- Verify `LITELLM_MASTER_KEY` is set correctly in `.env`
- Check LibreChat logs: `./manage.sh logs librechat-api`

### Models not appearing
- Ensure your LiteLLM proxy is accessible at `http://litellm:4000`
- Check that `fetch: true` is set in `librechat.yaml`
- Restart LibreChat: `./manage.sh restart`

### Database connection issues
- Verify MongoDB is running: `./manage.sh logs mongodb`
- Check MongoDB connection string in `.env`
- Ensure MongoDB volume has proper permissions

## Advanced Configuration

### Adding More Models
Edit `litellm_config.yaml` and add models to the `model_list`:

```yaml
model_list:
  - model_name: claude-3-sonnet
    litellm_params:
      model: anthropic/claude-3-sonnet-20240229
      api_key: os.environ/ANTHROPIC_API_KEY
```

### Custom LibreChat Features
Edit `librechat.yaml` to enable additional features:
- Web search capabilities
- Custom tools and plugins  
- AI agents and assistants
- Enhanced file upload support

### Production Deployment
- Use proper secrets management
- Configure reverse proxy (nginx/traefik)
- Set up SSL certificates
- Enable monitoring and logging
- Configure backups for data volumes

## Support

- LibreChat docs: https://docs.librechat.ai
- LiteLLM docs: https://docs.litellm.ai
- Issues with this integration: check logs with `./manage.sh logs`
