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


