$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot "mobile"
$distDir = Join-Path $mobileDir "dist"
$venvPython = Join-Path $repoRoot ".venv\\Scripts\\python.exe"
$gatewayScript = Join-Path $repoRoot "scripts\\dev_web_gateway.py"

function Assert-SupportedVenv {
  param(
    [Parameter(Mandatory = $true)]
    [string]$PythonExe
  )

  $venvVersion = & $PythonExe --version 2>&1
  if ($venvVersion -match 'Python 3\.14') {
    throw "A .venv atual usa $venvVersion, que nao e suportado pela stack local. Rode scripts/bootstrap_local.ps1 para recriar o ambiente com Python 3.12.x ou 3.13.x."
  }
}

if (-not (Test-Path $venvPython)) {
  throw "Ambiente virtual ausente. Rode scripts/bootstrap_local.ps1 primeiro."
}

Assert-SupportedVenv -PythonExe $venvPython

Push-Location $mobileDir
try {
  if (-not (Test-Path $distDir)) {
    Write-Host "Build web ausente. Gerando mobile/dist..."
    npm run build:web | Out-Host
  }
}
finally {
  Pop-Location
}

& $venvPython $gatewayScript --host 127.0.0.1 --port 8000 --upstream http://127.0.0.1:8001
