$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot "mobile"

Push-Location $mobileDir
try {
  npm start
}
finally {
  Pop-Location
}
