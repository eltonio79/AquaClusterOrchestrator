param(
    [string]$ConfigPath = "scripts/pipeline_config.json"
)

# Interactive setup for Cluster Analysis Pipeline
# - Prompts for ICM model path, output dir, ICMExchange path
# - Optionally lists simulations to help pick baseline/candidate IDs
# - Saves to scripts/pipeline_config.json

function Read-ConfigIfExists {
    param([string]$Path)
    if (Test-Path $Path) {
        try { return (Get-Content -Raw -Path $Path | ConvertFrom-Json) } catch { return $null }
    }
    return $null
}

function Prompt-Default {
    param(
        [string]$Message,
        [string]$Default
    )
    if ([string]::IsNullOrWhiteSpace($Default)) { return Read-Host $Message }
    $resp = Read-Host "$Message [$Default]"
    if ([string]::IsNullOrWhiteSpace($resp)) { return $Default }
    return $resp
}

Write-Host "=== Interactive Setup: Cluster Analysis Pipeline ===" -ForegroundColor Cyan

$existing = Read-ConfigIfExists -Path $ConfigPath

$suggestedModel = "models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm"
$suggestedData  = "data/output"
$suggestedIex   = "output/ICM_Release.x64/ICMExchange.exe"

if ($existing) {
    Write-Host "Found existing configuration at $ConfigPath" -ForegroundColor Yellow
    if ($existing.model_path) { $suggestedModel = $existing.model_path }
    if ($existing.data_dir)   { $suggestedData  = $existing.data_dir }
    if ($existing.icm_exchange) { $suggestedIex = $existing.icm_exchange }
}

$modelPath = Prompt-Default -Message "Path to ICM model (.icmm)" -Default $suggestedModel
$dataDir   = Prompt-Default -Message "Output data directory" -Default $suggestedData
$iexPath   = Prompt-Default -Message "Path to ICMExchange.exe" -Default $suggestedIex

if (-not (Test-Path $modelPath)) { Write-Host "Warning: model path not found: $modelPath" -ForegroundColor Yellow }
if (-not (Test-Path $iexPath))   { Write-Host "Warning: ICMExchange not found: $iexPath" -ForegroundColor Yellow }

# Offer to list simulations using Exchange + list_simulations.rb (non-blocking if fails)
$listChoice = Read-Host "List available simulations now? (y/N)"
$baselineId = $null
$candidateId = $null
if ($listChoice -match '^[Yy]') {
    try {
        Write-Host "Listing simulations..." -ForegroundColor Cyan
        & $iexPath "scripts/list_simulations.rb" 2>&1 | Write-Host
        $baselineId = Read-Host "Optional: baseline simulation ID"
        $candidateId = Read-Host "Optional: candidate simulation ID"
    } catch {
        Write-Host "Could not list simulations via Exchange: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ConfigPath) | Out-Null

$config = [ordered]@{
    model_path   = $modelPath
    data_dir     = $dataDir
    icm_exchange = $iexPath
}
if ($baselineId) { $config.baseline_id = [int]$baselineId }
if ($candidateId){ $config.candidate_id = [int]$candidateId }

$config | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 -Path $ConfigPath

Write-Host "Saved configuration to $ConfigPath" -ForegroundColor Green
Write-Host "Next: you can run .\scripts\run_pipeline_interactive.ps1 or .\scripts\run_pipeline_background.ps1" -ForegroundColor Gray

## End of script


