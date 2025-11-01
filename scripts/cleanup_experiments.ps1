# Script to clean up and archive experiment results
# Moves old experiment results to archived folder

param(
    [switch]$Quiet,
    [int]$ArchiveDaysOld = 30
)

# Dynamiczne wyznaczanie root projektu
function Get-ProjectRoot {
    $currentPath = $PSScriptRoot
    if (-not $currentPath) {
        $currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    if (-not $currentPath) {
        $currentPath = Get-Location
    }
    
    while ($currentPath -and $currentPath.Length -gt 3) {
        $gitMarker = Join-Path $currentPath ".git"
        $pathsMarker = Join-Path $currentPath "paths.txt"
        $dataMarker = Join-Path $currentPath "data"
        
        if ((Test-Path $gitMarker) -or (Test-Path $pathsMarker) -or (Test-Path $dataMarker)) {
            return $currentPath
        }
        
        $currentPath = Split-Path -Parent $currentPath
    }
    
    if ((Get-Location).Path -match 'scripts$') {
        return (Split-Path -Parent (Get-Location).Path)
    }
    
    return Get-Location
}

$projectRoot = Get-ProjectRoot
$experimentsPath = Join-Path (Join-Path $projectRoot "data\output") "experiments"
$archivedPath = Join-Path $experimentsPath "archived"

# NOTE: .cursor/plans/ directory is NEVER touched by cleanup scripts - plans must be preserved in git

if (-not (Test-Path $experimentsPath)) {
    if (-not $Quiet) {
        Write-Host "Experiments directory does not exist: $experimentsPath" -ForegroundColor Yellow
    }
    exit 0
}

# Create archived directory if it doesn't exist
if (-not (Test-Path $archivedPath)) {
    New-Item -ItemType Directory -Force -Path $archivedPath | Out-Null
}

$cutoffDate = (Get-Date).AddDays(-$ArchiveDaysOld)
$archivedCount = 0

try {
    # Archive old optimization result files
    $resultFiles = Get-ChildItem -Path $experimentsPath -Filter "*_optimization_*.json" -File -ErrorAction SilentlyContinue
    
    foreach ($file in $resultFiles) {
        if ($file.LastWriteTime -lt $cutoffDate) {
            try {
                Move-Item -Path $file.FullName -Destination $archivedPath -Force -ErrorAction SilentlyContinue
                $archivedCount++
            } catch {
                # Ignore errors moving individual files
            }
        }
    }
    
    # Archive old best_params files (keep only latest for each rule)
    $bestParamsFiles = Get-ChildItem -Path $experimentsPath -Filter "*_best_params.json" -File -ErrorAction SilentlyContinue
    
    # Group by rule name
    $ruleGroups = $bestParamsFiles | Group-Object {
        ($_.Name -replace '_best_params\.json$', '')
    }
    
    foreach ($group in $ruleGroups) {
        # Keep the most recent file, archive older ones
        $sortedFiles = $group.Group | Sort-Object LastWriteTime -Descending
        
        if ($sortedFiles.Count -gt 1) {
            # Archive all but the most recent
            for ($i = 1; $i -lt $sortedFiles.Count; $i++) {
                try {
                    Move-Item -Path $sortedFiles[$i].FullName -Destination $archivedPath -Force -ErrorAction SilentlyContinue
                    $archivedCount++
                } catch {
                    # Ignore errors
                }
            }
        }
        
        # Also archive if the file is older than cutoff date
        if ($sortedFiles.Count -gt 0) {
            $latestFile = $sortedFiles[0]
            if ($latestFile.LastWriteTime -lt $cutoffDate) {
                try {
                    # Create a copy in archived before archiving the latest
                    $archivedName = $latestFile.Name -replace '\.json$', "_$(Get-Date -Format 'yyyyMMdd').json"
                    Copy-Item -Path $latestFile.FullName -Destination (Join-Path $archivedPath $archivedName) -Force -ErrorAction SilentlyContinue
                } catch {
                    # Ignore errors
                }
            }
        }
    }
    
    # Archive old summary reports (keep only latest)
    $summaryFiles = Get-ChildItem -Path $experimentsPath -Filter "*.md" -File -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -like "*_summary.md" -or $_.Name -like "*_report.md" }
    
    if ($summaryFiles.Count -gt 1) {
        $sortedSummaries = $summaryFiles | Sort-Object LastWriteTime -Descending
        
        for ($i = 1; $i -lt $sortedSummaries.Count; $i++) {
            try {
                Move-Item -Path $sortedSummaries[$i].FullName -Destination $archivedPath -Force -ErrorAction SilentlyContinue
                $archivedCount++
            } catch {
                # Ignore errors
            }
        }
    }
    
    if (-not $Quiet) {
        if ($archivedCount -gt 0) {
            Write-Host "Archived $archivedCount experiment file(s) older than $ArchiveDaysOld days" -ForegroundColor Cyan
        } else {
            Write-Host "No experiment files to archive" -ForegroundColor Gray
        }
    }
    
    return $archivedCount
    
} catch {
    if (-not $Quiet) {
        Write-Host "Archive error: $($_.Exception.Message)" -ForegroundColor Red
    }
    return 0
}

