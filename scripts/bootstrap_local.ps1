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

function Get-ResolvedPathSafe {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  return [System.IO.Path]::GetFullPath($Path)
}

function Get-CompatiblePython {
  $candidates = New-Object System.Collections.Generic.List[string]

  $currentPython = Get-Command python -ErrorAction SilentlyContinue
  if ($currentPython) {
    $candidates.Add($currentPython.Source)
  }

  $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
  if ($pyLauncher) {
    $pyOutput = & $pyLauncher.Source -0p 2>$null
    foreach ($line in ($pyOutput -split "`r?`n")) {
      if ($line -match '3\.(12|13|14).+?([A-Z]:\\.+python\.exe)$') {
        $candidates.Add($Matches[2].Trim())
      }
    }
  }

  $uvPythonRoot = Join-Path $env:APPDATA "uv\\python"
  if (Test-Path $uvPythonRoot) {
    Get-ChildItem -Path $uvPythonRoot -Filter python.exe -Recurse -File -ErrorAction SilentlyContinue |
      ForEach-Object { $candidates.Add($_.FullName) }
  }

  foreach ($candidate in ($candidates | Select-Object -Unique)) {
    try {
      $version = & $candidate --version 2>&1
      if ($version -match 'Python 3\.(12|13|14)\.') {
        return @{
          Path = $candidate
          Version = $version
        }
      }
    } catch {
      continue
    }
  }

  throw "Nenhum Python 3.12.x, 3.13.x ou 3.14.x foi encontrado. Instale um runtime compatível para o backend."
}

Write-Host "== GeoAdmin Core: bootstrap local =="

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
  throw "npm nao encontrado no PATH."
}

$pythonInfo = Get-CompatiblePython
$pythonCommand = $pythonInfo.Path
$pythonVersion = $pythonInfo.Version
Write-Host "Usando interpretador compatível: $pythonVersion ($pythonCommand)"

if (Test-Path $pythonExe) {
  $venvVersion = & $pythonExe --version 2>&1
  if ($venvVersion -notmatch 'Python 3\.(12|13|14)\.') {
    $resolvedRepoRoot = Get-ResolvedPathSafe -Path $repoRoot
    $resolvedVenvPath = Get-ResolvedPathSafe -Path $venvPath
    if (-not $resolvedVenvPath.StartsWith($resolvedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
      throw "A .venv atual nao esta dentro do workspace esperado. Abortando a limpeza por seguranca."
    }

    Write-Warning "A .venv atual foi criada com um Python fora da baseline suportada e sera recriada."
    Remove-Item -LiteralPath $venvPath -Recurse -Force
  }
}

if (-not (Test-Path $venvPath)) {
  Write-Host "Criando ambiente virtual em $venvPath"
  Invoke-CheckedCommand -FilePath $pythonCommand -Arguments @("-m", "venv", $venvPath)
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
