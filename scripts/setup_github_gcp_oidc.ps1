param(
  [Parameter(Mandatory = $true)]
  [string]$ProjetoId,

  [string]$RepoOwner = "HUGUERAS",
  [string]$RepoName = "geoadmin-core",
  [string]$Regiao = "us-central1",
  [string]$Zona = "us-central1-a",
  [string]$Ambiente = "prod",
  [string]$PoolId = "github-actions",
  [string]$ProviderId = "github-oidc",
  [string]$DeployServiceAccountId = "geoadmin-deploy"
)

$ErrorActionPreference = "Stop"

$script:GcloudBin = $null

function Escrever-Secao {
  param([string]$Titulo)
  Write-Host ""
  Write-Host "=== $Titulo ===" -ForegroundColor Cyan
}

function Obter-GcloudBin {
  if ($script:GcloudBin) {
    return $script:GcloudBin
  }

  $cmd = Get-Command gcloud.cmd -ErrorAction SilentlyContinue
  if ($cmd) {
    $script:GcloudBin = $cmd.Source
    return $script:GcloudBin
  }

  $fallback = Get-Command gcloud -ErrorAction SilentlyContinue
  if ($fallback) {
    $script:GcloudBin = $fallback.Source
    return $script:GcloudBin
  }

  throw "gcloud nao encontrado no PATH."
}

function Executar-Gcloud {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Argumentos
  )

  $gcloudBin = Obter-GcloudBin
  & $gcloudBin @Argumentos
  if ($LASTEXITCODE -ne 0) {
    throw "Falha ao executar: gcloud $($Argumentos -join ' ')"
  }
}

function Testar-Gcloud {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Argumentos
  )

  $gcloudBin = Obter-GcloudBin
  $hadNativePreference = Test-Path variable:PSNativeCommandUseErrorActionPreference
  if ($hadNativePreference) {
    $nativePreferenceAnterior = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
  }

  try {
    & $gcloudBin @Argumentos 1>$null 2>$null
    return ($LASTEXITCODE -eq 0)
  }
  catch {
    return $false
  }
  finally {
    if ($hadNativePreference) {
      $PSNativeCommandUseErrorActionPreference = $nativePreferenceAnterior
    }
  }
}

$null = Obter-GcloudBin

$deployServiceAccountEmail = "$DeployServiceAccountId@$ProjetoId.iam.gserviceaccount.com"
$repositorioCompleto = "$RepoOwner/$RepoName"

Escrever-Secao "Projeto ativo"
Executar-Gcloud -Argumentos @("config", "set", "project", $ProjetoId)

Escrever-Secao "Habilitando APIs base"
Executar-Gcloud -Argumentos @(
  "services", "enable",
  "iam.googleapis.com",
  "iamcredentials.googleapis.com",
  "sts.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "serviceusage.googleapis.com",
  "cloudbuild.googleapis.com",
  "artifactregistry.googleapis.com",
  "run.googleapis.com",
  "secretmanager.googleapis.com",
  "firebase.googleapis.com",
  "firebasehosting.googleapis.com",
  "--project", $ProjetoId
)

Escrever-Secao "Consultando numero do projeto"
$numeroProjeto = (& gcloud projects describe $ProjetoId --format="value(projectNumber)").Trim()
if (-not $numeroProjeto) {
  throw "Nao foi possivel obter o numero do projeto $ProjetoId."
}

Escrever-Secao "Service account de deploy"
if (-not (Testar-Gcloud -Argumentos @("iam", "service-accounts", "describe", $deployServiceAccountEmail, "--project", $ProjetoId))) {
  Executar-Gcloud -Argumentos @(
    "iam", "service-accounts", "create", $DeployServiceAccountId,
    "--display-name", "GeoAdmin CI Deploy",
    "--description", "Service account para GitHub Actions do GeoAdmin",
    "--project", $ProjetoId
  )
}
else {
  Write-Host "Service account $deployServiceAccountEmail ja existe." -ForegroundColor Yellow
}

Escrever-Secao "Papéis da service account de deploy"
$papeisProjeto = @(
  "roles/serviceusage.serviceUsageAdmin",
  "roles/artifactregistry.admin",
  "roles/cloudbuild.builds.editor",
  "roles/run.admin",
  "roles/secretmanager.admin",
  "roles/iam.serviceAccountAdmin",
  "roles/resourcemanager.projectIamAdmin",
  "roles/firebasehosting.admin"
)

foreach ($papel in $papeisProjeto) {
  Executar-Gcloud -Argumentos @(
    "projects", "add-iam-policy-binding", $ProjetoId,
    "--member", "serviceAccount:$deployServiceAccountEmail",
    "--role", $papel,
    "--quiet"
  )
}

Escrever-Secao "Workload Identity Pool"
if (-not (Testar-Gcloud -Argumentos @(
      "iam", "workload-identity-pools", "describe", $PoolId,
      "--location", "global",
      "--project", $ProjetoId
    ))) {
  Executar-Gcloud -Argumentos @(
    "iam", "workload-identity-pools", "create", $PoolId,
    "--location", "global",
    "--display-name", "GitHub Actions Pool",
    "--project", $ProjetoId
  )
}
else {
  Write-Host "Pool $PoolId ja existe." -ForegroundColor Yellow
}

Escrever-Secao "Provider OIDC do GitHub"
$attributeMapping = "google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner,attribute.ref=assertion.ref"
$attributeCondition = "attribute.repository=='$repositorioCompleto'"

if (-not (Testar-Gcloud -Argumentos @(
      "iam", "workload-identity-pools", "providers", "describe", $ProviderId,
      "--location", "global",
      "--workload-identity-pool", $PoolId,
      "--project", $ProjetoId
    ))) {
  Executar-Gcloud -Argumentos @(
    "iam", "workload-identity-pools", "providers", "create-oidc", $ProviderId,
    "--location", "global",
    "--workload-identity-pool", $PoolId,
    "--display-name", "GitHub OIDC Provider",
    "--issuer-uri", "https://token.actions.githubusercontent.com",
    "--attribute-mapping", $attributeMapping,
    "--attribute-condition", $attributeCondition,
    "--project", $ProjetoId
  )
}
else {
  Write-Host "Provider $ProviderId ja existe." -ForegroundColor Yellow
}

Escrever-Secao "Permissao para o GitHub assumir a service account"
$principalSet = "principalSet://iam.googleapis.com/projects/$numeroProjeto/locations/global/workloadIdentityPools/$PoolId/attribute.repository/$repositorioCompleto"
Executar-Gcloud -Argumentos @(
  "iam", "service-accounts", "add-iam-policy-binding", $deployServiceAccountEmail,
  "--project", $ProjetoId,
  "--role", "roles/iam.workloadIdentityUser",
  "--member", $principalSet,
  "--quiet"
)

$providerResource = "projects/$numeroProjeto/locations/global/workloadIdentityPools/$PoolId/providers/$ProviderId"

Escrever-Secao "Valores para GitHub Actions"
Write-Host "GitHub Variables" -ForegroundColor Green
Write-Host "GCP_PROJECT_ID=$ProjetoId"
Write-Host "GCP_REGION=$Regiao"
Write-Host "GCP_ZONE=$Zona"
Write-Host "GCP_ENVIRONMENT=$Ambiente"
Write-Host "GCP_ARTIFACT_REGISTRY_REPOSITORY=geoadmin"
Write-Host "CLOUD_RUN_SERVICE=geoadmin-api"
Write-Host "CLOUD_RUN_RUNTIME_SERVICE_ACCOUNT=geoadmin-api@$ProjetoId.iam.gserviceaccount.com"
Write-Host "FIREBASE_PROJECT_ID=$ProjetoId"
Write-Host ""
Write-Host "GitHub Secrets" -ForegroundColor Green
Write-Host "GCP_WORKLOAD_IDENTITY_PROVIDER=$providerResource"
Write-Host "GCP_SERVICE_ACCOUNT=$deployServiceAccountEmail"
Write-Host ""
Write-Host "Repositorio autorizado: $repositorioCompleto"
Write-Host "Projeto: $ProjetoId"
