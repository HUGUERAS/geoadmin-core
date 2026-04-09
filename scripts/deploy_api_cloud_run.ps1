[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ProjectId = $env:GCP_PROJECT_ID,
    [string]$Region = $env:GCP_REGION,
    [string]$ArtifactRegistryRepository = $env:GCP_ARTIFACT_REGISTRY_REPOSITORY,
    [string]$ServiceName = $env:CLOUD_RUN_SERVICE,
    [string]$SupabaseUrl = $env:SUPABASE_URL,
    [string]$SupabaseKey = $env:SUPABASE_KEY,
    [string]$SupabaseBucket = $env:SUPABASE_BUCKET_ARQUIVOS_PROJETO,
    [string]$AllowedOrigins = $env:ALLOWED_ORIGINS,
    [string]$AllowedHosts = $env:ALLOWED_HOSTS,
    [string]$SupabaseKeySecretName = "SUPABASE_KEY",
    [int]$MinInstances = 0,
    [int]$MaxInstances = 10,
    [bool]$AllowUnauthenticated = $true
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

function Invoke-GCloud {
    param([string[]]$Arguments)

    $rendered = $Arguments -join " "
    Write-Host "> gcloud $rendered"

    if (-not $PSCmdlet.ShouldProcess("gcloud", $rendered)) {
        return
    }

    & gcloud @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar: gcloud $rendered"
    }
}

Assert-RequiredValue -Name "ProjectId" -Value $ProjectId
Assert-RequiredValue -Name "Region" -Value $Region
Assert-RequiredValue -Name "ArtifactRegistryRepository" -Value $ArtifactRegistryRepository
Assert-RequiredValue -Name "ServiceName" -Value $ServiceName
Assert-RequiredValue -Name "SupabaseUrl" -Value $SupabaseUrl
Assert-RequiredValue -Name "SupabaseKey" -Value $SupabaseKey
Assert-RequiredValue -Name "SupabaseBucket" -Value $SupabaseBucket
Assert-RequiredValue -Name "AllowedOrigins" -Value $AllowedOrigins
Assert-RequiredValue -Name "AllowedHosts" -Value $AllowedHosts

$repoRoot = Split-Path -Parent $PSScriptRoot
$backendDir = Join-Path $repoRoot "backend"
$imageUri = "{0}-docker.pkg.dev/{1}/{2}/{3}:latest" -f $Region, $ProjectId, $ArtifactRegistryRepository, $ServiceName
$envVars = "^##^SUPABASE_URL=$SupabaseUrl##SUPABASE_BUCKET_ARQUIVOS_PROJETO=$SupabaseBucket##ALLOWED_ORIGINS=$AllowedOrigins##ALLOWED_HOSTS=$AllowedHosts##EXPOSE_API_DOCS=false##DEBUG_ERRORS=false"
$secretFile = Join-Path ([System.IO.Path]::GetTempPath()) "geoadmin-supabase-key.txt"

try {
    try {
        Invoke-GCloud -Arguments @(
            "artifacts", "repositories", "describe", $ArtifactRegistryRepository,
            "--location", $Region,
            "--project", $ProjectId
        )
    } catch {
        Invoke-GCloud -Arguments @(
            "artifacts", "repositories", "create", $ArtifactRegistryRepository,
            "--repository-format=docker",
            "--location", $Region,
            "--project", $ProjectId
        )
    }

    Invoke-GCloud -Arguments @("auth", "configure-docker", "$Region-docker.pkg.dev", "--quiet")

    Set-Content -Path $secretFile -Value $SupabaseKey -NoNewline

    try {
        Invoke-GCloud -Arguments @(
            "secrets", "describe", $SupabaseKeySecretName,
            "--project", $ProjectId
        )
    } catch {
        Invoke-GCloud -Arguments @(
            "secrets", "create", $SupabaseKeySecretName,
            "--replication-policy=automatic",
            "--project", $ProjectId
        )
    }

    Invoke-GCloud -Arguments @(
        "secrets", "versions", "add", $SupabaseKeySecretName,
        "--data-file=$secretFile",
        "--project", $ProjectId
    )

    Push-Location $repoRoot
    try {
        Invoke-GCloud -Arguments @(
            "builds", "submit", "backend",
            "--tag", $imageUri,
            "--project", $ProjectId
        )
    } finally {
        Pop-Location
    }

    $deployArgs = @(
        "run", "deploy", $ServiceName,
        "--image", $imageUri,
        "--region", $Region,
        "--project", $ProjectId,
        "--platform", "managed",
        "--quiet",
        "--set-env-vars", $envVars,
        "--update-secrets", "SUPABASE_KEY=${SupabaseKeySecretName}:latest",
        "--min-instances", "$MinInstances",
        "--max-instances", "$MaxInstances"
    )

    if ($AllowUnauthenticated) {
        $deployArgs += "--allow-unauthenticated"
    } else {
        $deployArgs += "--no-allow-unauthenticated"
    }

    Invoke-GCloud -Arguments $deployArgs
    Invoke-GCloud -Arguments @(
        "run", "services", "describe", $ServiceName,
        "--region", $Region,
        "--project", $ProjectId,
        "--format=value(status.url)"
    )
} finally {
    Remove-Item -Path $secretFile -ErrorAction SilentlyContinue
}
