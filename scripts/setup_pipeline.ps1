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
Write-Host "Next: you can run .\\scripts\\run_pipeline_interactive.ps1 or .\\scripts\\run_pipeline_background.ps1" -ForegroundColor Gray

# Interactive setup for Cluster Analysis Pipeline
# Prompts for essential configuration and saves to scripts/pipeline_config.json

param(
    [string]$DefaultModel = "models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm",
    [string]$DefaultOutput = "data/output",
    [string]$DefaultICMExchange = "output/ICM_Release.x64/ICMExchange.exe"
)

function Ensure-Directory {
    param([string]$Path)
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path | Out-Null
        }
    }
}

function Prompt-Path {
    param(
        [string]$Message,
        [string]$DefaultValue,
        [switch]$MustExist
    )
    while ($true) {
        $val = Read-Host "$Message [`$Default: $DefaultValue`]"
        if ([string]::IsNullOrWhiteSpace($val)) { $val = $DefaultValue }
        if ($MustExist) {
            if (Test-Path $val) { return $val } else { Write-Host "Path not found: $val" -ForegroundColor Yellow }
        } else {
            return $val
        }
    }
}

function Show-Header($title) {
    Write-Host "`n=== $title ===" -ForegroundColor Cyan
}

function Try-ListSimulations {
    param(
        [string]$ICMExchange,
        [string]$ScriptsDir
    )
    try {
        if (-not (Test-Path $ICMExchange)) { Write-Host "ICMExchange not found: $ICMExchange" -ForegroundColor Yellow; return }
        $scriptPath = Join-Path $ScriptsDir "list_simulations.rb"
        if (-not (Test-Path $scriptPath)) { Write-Host "Script not found: $scriptPath" -ForegroundColor Yellow; return }
        Write-Host "`nListing available simulations (this may take a moment)..." -ForegroundColor Yellow
        & $ICMExchange $scriptPath 2>&1 | Write-Host
    } catch {
        Write-Host "Unable to list simulations: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

try {
    Show-Header "Cluster Analysis Pipeline - Interactive Setup"

    $scriptsDir = "scripts"
    $configPath = Join-Path $scriptsDir "pipeline_config.json"

    # Load existing config if present
    $existing = $null
    if (Test-Path $configPath) {
        try { $existing = Get-Content $configPath -Raw | ConvertFrom-Json } catch {}
    }

    $modelPath = Prompt-Path -Message "Path to ICM model (.icmm)" -DefaultValue ($existing.model_path ?? $DefaultModel) -MustExist
    $outputDir = Prompt-Path -Message "Output data directory" -DefaultValue ($existing.data_dir ?? $DefaultOutput)
    $icmExchange = Prompt-Path -Message "Path to ICMExchange.exe" -DefaultValue ($existing.icm_exchange ?? $DefaultICMExchange) -MustExist

    Ensure-Directory $outputDir
    Ensure-Directory (Join-Path $outputDir "logs")

    # Optionally list simulations
    $resp = Read-Host "List available simulations now? (y/n)"
    if ($resp -match '^(y|Y)$') { Try-ListSimulations -ICMExchange $icmExchange -ScriptsDir $scriptsDir }

    # Optional baseline/candidate IDs
    $baseline = Read-Host "Baseline simulation ID (press Enter to skip)"
    $candidate = Read-Host "Candidate simulation ID (press Enter to skip)"

    $cfg = [ordered]@{
        model_path   = $modelPath
        data_dir     = $outputDir
        icm_exchange = $icmExchange
        baseline_id  = [string]::IsNullOrWhiteSpace($baseline) ? $null : [int]$baseline
        candidate_id = [string]::IsNullOrWhiteSpace($candidate) ? $null : [int]$candidate
        updated_at   = (Get-Date).ToString("s")
    }

    $json = ($cfg | ConvertTo-Json -Depth 5)
    Set-Content -Path $configPath -Value $json -Encoding UTF8

    Write-Host "`nConfiguration saved to $configPath" -ForegroundColor Green
    Write-Host "Model: $modelPath" -ForegroundColor Gray
    Write-Host "Output: $outputDir" -ForegroundColor Gray
    Write-Host "ICMExchange: $icmExchange" -ForegroundColor Gray

    exit 0
}
catch {
    Write-Host "Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


