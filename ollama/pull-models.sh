#!/usr/bin/env bash
#
# pull-models.sh — pull required Ollama models after container starts
# Usage: ./pull-models.sh
#

set -euo pipefail

OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11435}"
CONTAINER="ollama"

# Models required by n8n workflows
MODELS=(
  "digitsflow/bonsai-8b:latest"
)

echo ">> Waiting for Ollama to be ready..."
until curl -sf "${OLLAMA_URL}/api/tags" > /dev/null 2>&1; do
  echo "   ...not ready yet, retrying in 5s"
  sleep 5
done
echo ">> Ollama is up."

for model in "${MODELS[@]}"; do
  echo ""
  echo ">> Pulling model: ${model}"
  docker exec ollama ollama pull "${model}"
  echo ">> Done: ${model}"
done

echo ""
echo ">> All models pulled. Verify with:"
echo "   curl http://localhost:11434/api/tags | python3 -m json.tool"
