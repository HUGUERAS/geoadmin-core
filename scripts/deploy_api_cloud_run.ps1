[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ProjectId = $env:GCP_PROJECT_ID,
    [string]$Region = $env:GCP_REGION,
    [string]$ArtifactRegistryRepository = $env:GCP_ARTIFACT_REGISTRY_REPOSITORY,
    [string]$ServiceName = $env:CLOUD_RUN_SERVICE,
    [string]$RuntimeServiceAccount = $env:CLOUD_RUN_RUNTIME_SERVICE_ACCOUNT,
    [string]$PublicAppUrl = $env:PUBLIC_APP_URL,
    [string]$SupabaseUrl = $env:SUPABASE_URL,
    [string]$SupabaseKey = $env:SUPABASE_KEY,
    [string]$SupabaseBucket = $env:SUPABASE_BUCKET_ARQUIVOS_PROJETO,
    [string]$AllowedOrigins = $env:ALLOWED_ORIGINS,
    [string]$AllowedHosts = $env:ALLOWED_HOSTS,
    [string]$SupabaseKeySecretName = "SUPABASE_KEY",
    [int]$MinInstances = 0,
    [int]$MaxInstances = 10,
    [int]$HealthcheckRetries = 5,
    [int]$HealthcheckDelaySeconds = 5,
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

function Test-HealthEndpoint {
    param(
        [string]$BaseUrl,
        [int]$Retries,
        [int]$DelaySeconds
    )

    $healthUrl = ("{0}/health" -f $BaseUrl.TrimEnd("/"))
    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        Write-Host "> GET $healthUrl (tentativa $attempt/$Retries)"
        try {
            $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 30
            if ($response.StatusCode -eq 200) {
                Write-Host "Healthcheck OK."
                return
            }
        } catch {
            if ($attempt -eq $Retries) {
                throw "Healthcheck falhou em ${healthUrl}: $($_.Exception.Message)"
            }
        }

        Start-Sleep -Seconds $DelaySeconds
    }
}

function Test-CloudRunRuntimeContract {
    param(
        [string]$ServiceName,
        [string]$Region,
        [string]$ProjectId
    )

    $describeCommand = @(
        "run", "services", "describe", $ServiceName,
        "--region", $Region,
        "--project", $ProjectId,
        "--format=json"
    )
    $rendered = $describeCommand -join " "
    Write-Host "> gcloud $rendered"

    if (-not $PSCmdlet.ShouldProcess("gcloud", $rendered)) {
        return
    }

    $json = & gcloud @describeCommand
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao descrever servico Cloud Run para validar contrato."
    }

    $service = $json | ConvertFrom-Json
    $envMap = @{}
    foreach ($entry in $service.spec.template.spec.containers[0].env) {
        if ($entry.name) {
            $envMap[$entry.name] = $entry.value
        }
    }

    if ($envMap["AUTH_OBRIGATORIO"] -ne "true") {
        throw "Cloud Run deve estar com AUTH_OBRIGATORIO=true."
    }

    if ($envMap.ContainsKey("AUTH_PERMITIR_BYPASS_IMPLANTACAO")) {
        throw "Cloud Run nao pode expor AUTH_PERMITIR_BYPASS_IMPLANTACAO na trilha oficial."
    }

    if ($envMap["EXPOSE_API_DOCS"] -ne "false") {
        throw "Cloud Run deve estar com EXPOSE_API_DOCS=false."
    }

    if ($envMap["DEBUG_ERRORS"] -ne "false") {
        throw "Cloud Run deve estar com DEBUG_ERRORS=false."
    }
}

function Remove-LegacyBypassEnv {
    param(
        [string]$ServiceName,
        [string]$Region,
        [string]$ProjectId
    )

    $describeCommand = @(
        "run", "services", "describe", $ServiceName,
        "--region", $Region,
        "--project", $ProjectId,
        "--format=json"
    )

    $json = & gcloud @describeCommand
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao descrever servico Cloud Run para remover env legado."
    }

    $service = $json | ConvertFrom-Json
    $envNames = @(
        foreach ($entry in $service.spec.template.spec.containers[0].env) {
            if ($entry.name) { $entry.name }
        }
    )

    if ($envNames -notcontains "AUTH_PERMITIR_BYPASS_IMPLANTACAO") {
        Write-Host "AUTH_PERMITIR_BYPASS_IMPLANTACAO ja nao esta presente no runtime."
        return
    }

    Invoke-GCloud -Arguments @(
        "run", "services", "update", $ServiceName,
        "--region", $Region,
        "--project", $ProjectId,
        "--remove-env-vars", "AUTH_PERMITIR_BYPASS_IMPLANTACAO",
        "--quiet"
    )
}

Assert-RequiredValue -Name "ProjectId" -Value $ProjectId
Assert-RequiredValue -Name "Region" -Value $Region
Assert-RequiredValue -Name "ArtifactRegistryRepository" -Value $ArtifactRegistryRepository
Assert-RequiredValue -Name "ServiceName" -Value $ServiceName
Assert-RequiredValue -Name "RuntimeServiceAccount" -Value $RuntimeServiceAccount
Assert-RequiredValue -Name "PublicAppUrl" -Value $PublicAppUrl
Assert-RequiredValue -Name "SupabaseUrl" -Value $SupabaseUrl
Assert-RequiredValue -Name "SupabaseKey" -Value $SupabaseKey
Assert-RequiredValue -Name "SupabaseBucket" -Value $SupabaseBucket
Assert-RequiredValue -Name "AllowedOrigins" -Value $AllowedOrigins
Assert-RequiredValue -Name "AllowedHosts" -Value $AllowedHosts

$repoRoot = Split-Path -Parent $PSScriptRoot
$backendDir = Join-Path $repoRoot "backend"
$imageUri = "{0}-docker.pkg.dev/{1}/{2}/{3}:latest" -f $Region, $ProjectId, $ArtifactRegistryRepository, $ServiceName
$envVars = "^##^SUPABASE_URL=$SupabaseUrl##SUPABASE_BUCKET_ARQUIVOS_PROJETO=$SupabaseBucket##PUBLIC_APP_URL=$PublicAppUrl##BACKEND_PUBLIC_URL=$PublicAppUrl##ALLOWED_ORIGINS=$AllowedOrigins##ALLOWED_HOSTS=$AllowedHosts##EXPOSE_API_DOCS=false##DEBUG_ERRORS=false##AUTH_OBRIGATORIO=true"
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

    Invoke-GCloud -Arguments @(
        "secrets", "add-iam-policy-binding", $SupabaseKeySecretName,
        "--member=serviceAccount:$RuntimeServiceAccount",
        "--role=roles/secretmanager.secretAccessor",
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
        "--service-account", $RuntimeServiceAccount,
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
    Remove-LegacyBypassEnv -ServiceName $ServiceName -Region $Region -ProjectId $ProjectId

    $serviceUrlCommand = @(
        "run", "services", "describe", $ServiceName,
        "--region", $Region,
        "--project", $ProjectId,
        "--format=value(status.url)"
    )
    $serviceUrlRendered = $serviceUrlCommand -join " "
    Write-Host "> gcloud $serviceUrlRendered"

    if (-not $PSCmdlet.ShouldProcess("gcloud", $serviceUrlRendered)) {
        return
    }

    $serviceUrl = (& gcloud @serviceUrlCommand).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao consultar URL do servico Cloud Run"
    }

    Test-CloudRunRuntimeContract -ServiceName $ServiceName -Region $Region -ProjectId $ProjectId
    Write-Host "Service URL: $serviceUrl"
    Test-HealthEndpoint -BaseUrl $serviceUrl -Retries $HealthcheckRetries -DelaySeconds $HealthcheckDelaySeconds
} finally {
    Remove-Item -Path $secretFile -ErrorAction SilentlyContinue
}
