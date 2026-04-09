$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$venvPath = Join-Path $repoRoot ".venv"
$pythonExe = Join-Path $venvPath "Scripts\\python.exe"
$pipExe = Join-Path $venvPath "Scripts\\pip.exe"
$backendEnv = Join-Path $repoRoot "backend\\.env"
$backendEnvExample = Join-Path $repoRoot "backend\\.env.example"
$mobileDir = Join-Path $repoRoot "mobile"

function Invoke-CheckedCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $false)]
    [string[]]$Arguments = @()
  )

  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Falha ao executar: $FilePath $($Arguments -join ' ')"
  }
}

Write-Host "== GeoAdmin Core: bootstrap local =="

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  throw "Python nao encontrado no PATH."
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
  throw "npm nao encontrado no PATH."
}

$pythonVersion = python --version 2>&1
if ($pythonVersion -match 'Python 3\\.14') {
  throw "Python 3.14 nao e suportado pela stack atual do backend por causa do pyproj. Use Python 3.12.x ou 3.13.x para o GeoAdmin Core."
}

if (Test-Path $pythonExe) {
  $venvVersion = & $pythonExe --version 2>&1
  if ($venvVersion -match 'Python 3\\.14') {
    throw "A .venv atual foi criada com Python 3.14 e nao serve para o backend. Remova .venv e rode novamente com Python 3.12.x ou 3.13.x."
  }
}

if (-not (Test-Path $venvPath)) {
  Write-Host "Criando ambiente virtual em $venvPath"
  Invoke-CheckedCommand -FilePath "python" -Arguments @("-m", "venv", $venvPath)
}

Write-Host "Atualizando pip"
Invoke-CheckedCommand -FilePath $pythonExe -Arguments @("-m", "pip", "install", "--upgrade", "pip")

Write-Host "Instalando dependencias do backend"
Invoke-CheckedCommand -FilePath $pipExe -Arguments @("install", "-r", (Join-Path $repoRoot "backend\\requirements.txt"))

if (-not (Test-Path $backendEnv) -and (Test-Path $backendEnvExample)) {
  Copy-Item -LiteralPath $backendEnvExample -Destination $backendEnv
  Write-Warning "backend/.env nao existia. Foi criado a partir do exemplo; revise as credenciais antes de usar o backend."
}

Write-Host "Instalando dependencias do mobile com npm ci"
Push-Location $mobileDir
try {
  Invoke-CheckedCommand -FilePath "npm.cmd" -Arguments @("ci")
}
finally {
  Pop-Location
}

Write-Host "Bootstrap concluido."
