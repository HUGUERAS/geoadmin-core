$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$venvPython = Join-Path $repoRoot ".venv\\Scripts\\python.exe"
$backendDir = Join-Path $repoRoot "backend"
$backendEnv = Join-Path $backendDir ".env"

if (-not (Test-Path $venvPython)) {
  throw "Ambiente virtual ausente. Rode scripts/bootstrap_local.ps1 primeiro."
}

if (-not (Test-Path $backendEnv)) {
  throw "backend/.env ausente. Configure o ambiente antes de subir o backend."
}

Push-Location $backendDir
try {
  & $venvPython -m uvicorn main:app --host 127.0.0.1 --port 8001
}
finally {
  Pop-Location
}
