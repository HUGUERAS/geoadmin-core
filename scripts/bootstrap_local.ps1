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

function Get-VersionString {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $false)]
    [string[]]$Arguments = @()
  )

  $nativePreferenceAnterior = $PSNativeCommandUseErrorActionPreference
  $PSNativeCommandUseErrorActionPreference = $false
  try {
    $saida = & $FilePath @Arguments --version 2>&1
    if ($LASTEXITCODE -ne 0) {
      return $null
    }
  }
  finally {
    $PSNativeCommandUseErrorActionPreference = $nativePreferenceAnterior
  }

  return ($saida | Out-String).Trim()
}

function Resolve-SupportedPython {
  $candidatos = @()

  if (Get-Command python -ErrorAction SilentlyContinue) {
    $versaoPython = Get-VersionString -FilePath "python"
    if ($versaoPython) {
      $candidatos += [PSCustomObject]@{
        FilePath = "python"
        Arguments = @()
        Version = $versaoPython
      }
    }
  }

  if (Get-Command py -ErrorAction SilentlyContinue) {
    $nativePreferenceAnterior = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    try {
      $pyLista = & py -0p 2>&1
    }
    finally {
      $PSNativeCommandUseErrorActionPreference = $nativePreferenceAnterior
    }

    if ($LASTEXITCODE -eq 0) {
      $linhasPy = ($pyLista | Out-String).Trim() -split "\r?\n"
      foreach ($versaoSuportada in @("3.13", "3.12")) {
        $linhaEncontrada = $linhasPy | Where-Object { $_ -match [regex]::Escape($versaoSuportada) } | Select-Object -First 1
        if ($linhaEncontrada -and $linhaEncontrada -match '([A-Za-z]:\\.*python\.exe)\s*$') {
          $candidatos += [PSCustomObject]@{
            FilePath = $matches[1]
            Arguments = @()
            Version = "Python $versaoSuportada"
          }
        }
      }
    }
  }

  if (-not $candidatos) {
    throw "Python nao encontrado. Instale Python 3.12.x ou 3.13.x antes de rodar o bootstrap."
  }

  foreach ($candidato in $candidatos) {
    if ($candidato.Version -match 'Python 3\.(12|13)') {
      return $candidato
    }
  }

  $versoesEncontradas = ($candidatos | ForEach-Object { $_.Version } | Sort-Object -Unique) -join ", "
  throw "Nenhum Python suportado encontrado. Versoes detectadas: $versoesEncontradas. Instale Python 3.12.x ou 3.13.x."
}

Write-Host "== GeoAdmin Core: bootstrap local =="

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
  throw "npm nao encontrado no PATH."
}

$pythonRuntime = Resolve-SupportedPython
Write-Host "Usando interpretador $($pythonRuntime.Version) via $($pythonRuntime.FilePath) $($pythonRuntime.Arguments -join ' ')"

if (Test-Path $pythonExe) {
  $venvVersion = & $pythonExe --version 2>&1
  if ($venvVersion -match 'Python 3\.14') {
    Write-Warning "A .venv atual foi criada com Python 3.14 e sera recriada com uma versao suportada."
    Remove-Item -LiteralPath $venvPath -Recurse -Force
  }
}

if (-not (Test-Path $venvPath)) {
  Write-Host "Criando ambiente virtual em $venvPath"
  Invoke-CheckedCommand -FilePath $pythonRuntime.FilePath -Arguments ($pythonRuntime.Arguments + @("-m", "venv", $venvPath))
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
