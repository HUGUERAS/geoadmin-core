$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot "mobile"
$distDir = Join-Path $mobileDir "dist"
$venvPython = Join-Path $repoRoot ".venv\\Scripts\\python.exe"
$gatewayScript = Join-Path $repoRoot "scripts\\dev_web_gateway.py"

if (-not (Test-Path $venvPython)) {
  throw "Ambiente virtual ausente. Rode scripts/bootstrap_local.ps1 primeiro."
}

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
