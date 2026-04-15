#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV_PYTHON="$REPO_ROOT/.venv/bin/python"
BACKEND_DIR="$REPO_ROOT/backend"

if [ ! -f "$VENV_PYTHON" ]; then
  echo "Ambiente virtual ausente. Rode scripts/bootstrap_local.sh primeiro." >&2; exit 1
fi

if [ ! -f "$BACKEND_DIR/.env" ]; then
  echo "backend/.env ausente. Configure o ambiente antes de subir o backend." >&2; exit 1
fi

cd "$BACKEND_DIR"
exec "$VENV_PYTHON" -m uvicorn main:app --host 127.0.0.1 --port 8001
