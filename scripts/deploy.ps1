param(
  [Parameter(Mandatory=$true)][string]$SubscriptionId,
  [string]$ResourceGroupName = "bbg-rg-dev",
  [string]$Location = "eastus2",
  [ValidateSet("dev","staging","prod")][string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"

function Assert-Command($cmd) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "Missing prerequisite: $cmd"
  }
}

try {
  Assert-Command "az"
  az account show | Out-Null
  az account set --subscription $SubscriptionId

  az group create --name $ResourceGroupName --location $Location | Out-Null

  $templateFile = "infrastructure/main.json"
  $paramFile    = "infrastructure/parameters/$Environment.parameters.json"

  $vmPass  = Read-Host "Enter VM admin password" -AsSecureString
  $sqlPass = Read-Host "Enter SQL admin password" -AsSecureString

  $vmPlain  = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($vmPass))
  $sqlPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sqlPass))

  Write-Host "Running What-If..."
  az deployment group what-if --resource-group $ResourceGroupName --template-file $templateFile --parameters @$paramFile vmAdminPassword=$vmPlain sqlAdminPassword=$sqlPlain | Out-Null

  Write-Host "Deploying..."
  $outputsJson = az deployment group create --resource-group $ResourceGroupName --template-file $templateFile --parameters @$paramFile vmAdminPassword=$vmPlain sqlAdminPassword=$sqlPlain --query "properties.outputs" -o json
  $outputs = $outputsJson | ConvertFrom-Json

  $appUrl = $outputs.appUrl.value
  Write-Host "App URL: $appUrl"

  Write-Host "Health check..."
  $health = "$appUrl/health"
  $resp = Invoke-WebRequest -Uri $health -UseBasicParsing -TimeoutSec 60
  if ($resp.StatusCode -ne 200) { throw "Health check failed: $health" }

  Write-Host "Deployment successful."
}
catch {
  Write-Host "ERROR: $($_.Exception.Message)"
  Write-Host "Rollback: deleting resource group $ResourceGroupName"
  az group delete --name $ResourceGroupName --yes --no-wait | Out-Null
  exit 1
}
