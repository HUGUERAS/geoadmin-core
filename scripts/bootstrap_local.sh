#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV_PATH="$REPO_ROOT/.venv"
PYTHON_EXE="$VENV_PATH/bin/python"
PIP_EXE="$VENV_PATH/bin/pip"
BACKEND_ENV="$REPO_ROOT/backend/.env"
BACKEND_ENV_EXAMPLE="$REPO_ROOT/backend/.env.example"
MOBILE_DIR="$REPO_ROOT/mobile"

echo "== GeoAdmin Core: bootstrap local =="

if ! command -v python3 &>/dev/null; then
  echo "Python3 nao encontrado no PATH." >&2; exit 1
fi

if ! command -v npm &>/dev/null; then
  echo "npm nao encontrado no PATH." >&2; exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1)
if [[ "$PYTHON_VERSION" == *"3.14"* ]]; then
  echo "Python 3.14 nao e suportado. Use Python 3.12.x ou 3.13.x." >&2; exit 1
fi

if [ ! -d "$VENV_PATH" ]; then
  echo "Criando ambiente virtual em $VENV_PATH"
  python3 -m venv "$VENV_PATH"
fi

echo "Atualizando pip"
"$PYTHON_EXE" -m pip install --upgrade pip

echo "Instalando dependencias do backend"
"$PIP_EXE" install -r "$REPO_ROOT/backend/requirements.txt"

if [ ! -f "$BACKEND_ENV" ] && [ -f "$BACKEND_ENV_EXAMPLE" ]; then
  cp "$BACKEND_ENV_EXAMPLE" "$BACKEND_ENV"
  echo "AVISO: backend/.env criado a partir do exemplo. Revise as credenciais."
fi

echo "Instalando dependencias do mobile com npm ci"
cd "$MOBILE_DIR"
npm ci

echo "Bootstrap concluido."
