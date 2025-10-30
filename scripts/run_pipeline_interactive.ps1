param(
    [string]$ConfigPath = "scripts/pipeline_config.json"
)

Write-Host "=== Interactive Runner ===" -ForegroundColor Cyan

if (-not (Test-Path $ConfigPath)) {
    Write-Host "Config not found. Launching setup..." -ForegroundColor Yellow
    & ".\scripts\setup_pipeline.ps1" -ConfigPath $ConfigPath
}

if (-not (Test-Path $ConfigPath)) { throw "Missing config after setup." }

$cfg = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json

Write-Host "Configuration:" -ForegroundColor Gray
Write-Host "  Model:        $($cfg.model_path)" -ForegroundColor Gray
Write-Host "  Data dir:     $($cfg.data_dir)" -ForegroundColor Gray
Write-Host "  ICMExchange:  $($cfg.icm_exchange)" -ForegroundColor Gray

$resp = Read-Host "Proceed with this configuration? (Y/n)"
if ($resp -and $resp -match '^[Nn]') { Write-Host "Cancelled."; exit 1 }

$listRules = Read-Host "List available rules now? (y/N)"
if ($listRules -match '^[Yy]') {
    python ".\scripts\pipeline_runner.py" --list-rules
}

$rules = Read-Host "Enter rule names separated by commas or leave blank for ALL"
$rulesArr = @()
if ($rules -and $rules.Trim().Length -gt 0) { $rulesArr = $rules.Split(',').ForEach({ $_.Trim() }) }

$skipExport = Read-Host "Skip raster export (use existing rasters)? (y/N)"
$noExportSwitch = $false
if ($skipExport -match '^[Yy]') { $noExportSwitch = $true }

Write-Host "Starting background agent..." -ForegroundColor Green

if ($rulesArr.Count -gt 0) {
    if ($noExportSwitch) {
        & ".\scripts\run_pipeline_background.ps1" -Rules $rulesArr -NoExport -ConfigPath $ConfigPath
    } else {
        & ".\scripts\run_pipeline_background.ps1" -Rules $rulesArr -ConfigPath $ConfigPath
    }
} else {
    if ($noExportSwitch) {
        & ".\scripts\run_pipeline_background.ps1" -NoExport -ConfigPath $ConfigPath
    } else {
        & ".\scripts\run_pipeline_background.ps1" -ConfigPath $ConfigPath
    }
}

Write-Host "Use Get-Job/Receive-Job to monitor. MD logs are in data/output/logs." -ForegroundColor Gray

# Interactive runner: setup + rule selection + background execution

param(
    [switch]$ForceSetup
)

function Load-Config($path) {
    if (-not (Test-Path $path)) { return $null }
    try { return Get-Content $path -Raw | ConvertFrom-Json } catch { return $null }
}

try {
    $configPath = "scripts/pipeline_config.json"
    if ($ForceSetup -or -not (Test-Path $configPath)) {
        Write-Host "Running initial setup..." -ForegroundColor Yellow
        & powershell -ExecutionPolicy Bypass -File "scripts/setup_pipeline.ps1"
        if ($LASTEXITCODE -ne 0) { throw "Setup failed." }
    }

    $cfg = Load-Config $configPath
    if (-not $cfg) { throw "Could not load config from $configPath" }

    Write-Host "`nCurrent configuration:" -ForegroundColor Cyan
    Write-Host "  Model: $($cfg.model_path)"
    Write-Host "  Output: $($cfg.data_dir)"
    Write-Host "  ICMExchange: $($cfg.icm_exchange)"
    $ok = Read-Host "Proceed with this configuration? (y/n)"
    if ($ok -notmatch '^(y|Y)$') { Write-Host "Aborted." -ForegroundColor Yellow; exit 1 }

    # List rules via pipeline_runner --list-rules
    Write-Host "`nFetching available rules..." -ForegroundColor Yellow
    $rulesOutput = & python ".\scripts\pipeline_runner.py" --list-rules --data-dir $cfg.data_dir --scripts-dir 'scripts' --icm-exchange $cfg.icm_exchange 2>&1
    $rules = @()
    foreach ($line in $rulesOutput) { if ($line.Trim().StartsWith("- ")) { $rules += ($line.Trim().Substring(2)) } }
    if ($rules.Count -eq 0) { Write-Host "No rules found. Proceeding without filter." -ForegroundColor Yellow }

    if ($rules.Count -gt 0) {
        Write-Host "Available rules:" -ForegroundColor Cyan
        $i = 0
        $rules | ForEach-Object { $i++; Write-Host ("  [$i] $_") }
        $sel = Read-Host "Enter comma-separated indexes to run (empty = all)"
        if (-not [string]::IsNullOrWhiteSpace($sel)) {
            $idxs = $sel.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
            $chosen = @()
            foreach ($j in $idxs) { if ($j -ge 1 -and $j -le $rules.Count) { $chosen += $rules[$j-1] } }
            $rulesToRun = $chosen
        }
    }

    $skipExport = Read-Host "Skip raster export and use existing rasters? (y/n)"
    $noExportSwitch = $false
    if ($skipExport -match '^(y|Y)$') { $noExportSwitch = $true }

    Write-Host "`nStarting background run..." -ForegroundColor Cyan
    if ($rulesToRun -and $rulesToRun.Count -gt 0) {
        & powershell -ExecutionPolicy Bypass -File "scripts/run_pipeline_background.ps1" -Rules $rulesToRun -NoExport:$noExportSwitch
    } else {
        & powershell -ExecutionPolicy Bypass -File "scripts/run_pipeline_background.ps1" -NoExport:$noExportSwitch
    }

    exit $LASTEXITCODE
}
catch {
    Write-Host "Interactive run failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


