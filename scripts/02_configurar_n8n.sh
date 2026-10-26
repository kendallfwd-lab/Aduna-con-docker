#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/.."
docker compose exec -T n8n node /plantillas/provisionar.mjs
docker compose restart n8n
printf '%s\n' 'Hecho. Abre http://localhost:5678 y busca LAB3 | Agente aduanero DeepSeek | Chat.'

