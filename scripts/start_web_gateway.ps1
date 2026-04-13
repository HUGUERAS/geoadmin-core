$ErrorActionPreference = "Stop"

param(
  [switch]$Rebuild,
  [string]$ApiBaseUrl = "http://127.0.0.1:8001"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot "mobile"
$distDir = Join-Path $mobileDir "dist"
$venvPython = Join-Path $repoRoot ".venv\\Scripts\\python.exe"
$gatewayScript = Join-Path $repoRoot "scripts\\dev_web_gateway.py"

if (-not (Test-Path $venvPython)) {
  throw "Ambiente virtual ausente. Rode scripts/bootstrap_local.ps1 primeiro."
}

$distExists = Test-Path $distDir
$shouldBuild = $Rebuild -or (-not $distExists)

if ($shouldBuild) {
  Push-Location $mobileDir
  $previousApiBaseUrl = $env:EXPO_PUBLIC_API_BASE_URL
  try {
    $env:EXPO_PUBLIC_API_BASE_URL = $ApiBaseUrl
    Write-Host "Gerando mobile/dist com EXPO_PUBLIC_API_BASE_URL=$ApiBaseUrl"
    npm run build:web | Out-Host
    if ($LASTEXITCODE -ne 0) {
      throw "Falha ao gerar mobile/dist."
    }
  }
  finally {
    if ($null -eq $previousApiBaseUrl) {
      Remove-Item Env:EXPO_PUBLIC_API_BASE_URL -ErrorAction SilentlyContinue
    } else {
      $env:EXPO_PUBLIC_API_BASE_URL = $previousApiBaseUrl
    }
    Pop-Location
  }
}

& $venvPython $gatewayScript --host 127.0.0.1 --port 8000 --upstream http://127.0.0.1:8001
