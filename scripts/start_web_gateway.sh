#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE_DIR="$REPO_ROOT/mobile"
DIST_DIR="$MOBILE_DIR/dist"
VENV_PYTHON="$REPO_ROOT/.venv/bin/python"
GATEWAY_SCRIPT="$REPO_ROOT/scripts/dev_web_gateway.py"

if [ ! -f "$VENV_PYTHON" ]; then
  echo "Ambiente virtual ausente. Rode scripts/bootstrap_local.sh primeiro." >&2; exit 1
fi

if [ ! -d "$DIST_DIR" ]; then
  echo "Build web ausente. Gerando mobile/dist..."
  cd "$MOBILE_DIR"
  npm run build:web
fi

exec "$VENV_PYTHON" "$GATEWAY_SCRIPT" --host 127.0.0.1 --port 8000 --upstream http://127.0.0.1:8001
