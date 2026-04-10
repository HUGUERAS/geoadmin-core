[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ProjectId = $env:FIREBASE_PROJECT_ID,
    [string]$ApiBaseUrl = $env:EXPO_PUBLIC_API_BASE_URL
)

$ErrorActionPreference = "Stop"

function Assert-RequiredValue {
    param(
        [string]$Name,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "Parametro obrigatorio ausente: $Name"
    }
}

Assert-RequiredValue -Name "ProjectId" -Value $ProjectId
Assert-RequiredValue -Name "ApiBaseUrl" -Value $ApiBaseUrl

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot "mobile"

Push-Location $mobileDir
try {
    $env:EXPO_PUBLIC_API_BASE_URL = $ApiBaseUrl
    if ($PSCmdlet.ShouldProcess("npm", "npm run build:web")) {
        npm run build:web
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao gerar o build web do Expo."
        }
    }
} finally {
    Pop-Location
}

Push-Location $repoRoot
try {
    if ($PSCmdlet.ShouldProcess("firebase-tools", "npx firebase-tools deploy --only hosting --project $ProjectId")) {
        npx firebase-tools deploy --only hosting --project $ProjectId
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao publicar no Firebase Hosting."
        }
    }
} finally {
    Pop-Location
}
