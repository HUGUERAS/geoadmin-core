$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$venvPython = Join-Path $repoRoot ".venv\\Scripts\\python.exe"
$backendDir = Join-Path $repoRoot "backend"
$backendEnv = Join-Path $backendDir ".env"

function Assert-BackendRuntime {
  param(
    [Parameter(Mandatory = $true)]
    [string]$PythonExe
  )

  $venvVersion = & $PythonExe --version 2>&1
  if ($venvVersion -match 'Python 3\.14') {
    throw "A .venv atual usa $venvVersion, que nao e suportado pelo backend. Rode scripts/bootstrap_local.ps1 para recriar o ambiente com Python 3.12.x ou 3.13.x."
  }

  & $PythonExe -c "import fastapi, uvicorn, filetype" *> $null
  if ($LASTEXITCODE -ne 0) {
    throw "Dependencias do backend ausentes ou desatualizadas na .venv. Rode scripts/bootstrap_local.ps1 para reinstalar o ambiente."
  }
}

if (-not (Test-Path $venvPython)) {
  throw "Ambiente virtual ausente. Rode scripts/bootstrap_local.ps1 primeiro."
}

if (-not (Test-Path $backendEnv)) {
  throw "backend/.env ausente. Configure o ambiente antes de subir o backend."
}

Assert-BackendRuntime -PythonExe $venvPython

Push-Location $backendDir
try {
  & $venvPython -m uvicorn main:app --host 127.0.0.1 --port 8001
}
finally {
  Pop-Location
}
