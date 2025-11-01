param(
    [switch]$Yes
)

Write-Host "=== Cleanup Generated Data ===" -ForegroundColor Cyan
Write-Host "This will delete generated outputs under data/output (except logs) and data/input." -ForegroundColor Yellow

if (-not $Yes) {
    $resp = Read-Host "Are you sure you want to remove previous generated data (rasters, viz, results, experiments, clusters, csv)? (y/N)"
    if ($resp -notmatch '^[Yy]') { Write-Host "Cancelled."; exit 0 }
}

$targets = @()
# Legacy flat locations
$targets += @(
    "data/output/rasters",
    "data/output/viz",
    "data/output/results",
    "data/output/experiments",
    "data/output/clusters"
)
# Structured: remove everything under data/output except logs folder
if (Test-Path "data/output") {
    Get-ChildItem -Path "data/output" -Directory | ForEach-Object {
        if ($_.Name -ne 'logs') { $targets += $_.FullName }
    }
}
# Also clean data/input files
if (Test-Path "data/input") {
    $targets += (Get-ChildItem -Path "data/input" -Recurse -Force)
}

foreach ($p in $targets | Sort-Object -Descending) {
    try {
        if (Test-Path $p) {
            Write-Host ("Removing " + $p) -ForegroundColor Gray
            if ((Get-Item $p).PSIsContainer) {
                Remove-Item -Recurse -Force -ErrorAction Stop $p
            } else {
                Remove-Item -Force -ErrorAction Stop $p
            }
        }
    } catch {
        Write-Host ("Failed: " + $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host "Done. Logs preserved under data/output/logs." -ForegroundColor Green


