# ============================================================
# push_secrets.ps1
# Lê scripts\.secrets.local e empurra tudo pro GitHub de uma vez.
# Uso: .\scripts\push_secrets.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$REPO = "HUGUERAS/geoadmin-core"
$ARQUIVO = "$PSScriptRoot\.secrets.local"

if (-not (Test-Path $ARQUIVO)) {
    Write-Error "Arquivo nao encontrado: $ARQUIVO`nCopie scripts\.secrets.local.example e preencha."
    exit 1
}

# Nomes que vao como SECRET (sensíveis)
$SECRETS_KEYS = @(
    "SUPABASE_KEY",
    "GCP_WORKLOAD_IDENTITY_PROVIDER",
    "GCP_SERVICE_ACCOUNT",
    "VERCEL_TOKEN",
    "EXPO_PUBLIC_API_BASE_URL"
)

$secrets = @{}
$vars    = @{}

Get-Content $ARQUIVO | ForEach-Object {
    $linha = $_.Trim()
    if ($linha -match "^#" -or $linha -eq "") { return }
    $partes = $linha -split "=", 2
    if ($partes.Count -ne 2) { return }
    $chave = $partes[0].Trim()
    $valor = $partes[1].Trim()
    if (-not $valor) {
        Write-Warning "Pulando $chave (vazio)"
        return
    }
    if ($SECRETS_KEYS -contains $chave) {
        $secrets[$chave] = $valor
    } else {
        $vars[$chave] = $valor
    }
}

Write-Host "`n=== Configurando SECRETS ===" -ForegroundColor Cyan
foreach ($chave in $secrets.Keys) {
    Write-Host "  secret: $chave"
    $secrets[$chave] | gh secret set $chave --repo $REPO
}

Write-Host "`n=== Configurando VARS ===" -ForegroundColor Cyan
foreach ($chave in $vars.Keys) {
    Write-Host "  var: $chave = $($vars[$chave])"
    gh variable set $chave --body $vars[$chave] --repo $REPO
}

Write-Host "`nFeito! Verifique em: https://github.com/$REPO/settings/secrets/actions" -ForegroundColor Green
