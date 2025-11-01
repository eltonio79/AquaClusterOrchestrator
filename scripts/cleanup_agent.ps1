# Cleanup Agent - Main script for automated cleanup and maintenance
# Integrates all cleanup functions: logs, experiments, temp files, orphaned locks
# 
# Usage:
#   .\scripts\cleanup_agent.ps1 -WhatIf                    # Dry-run (preview only)
#   .\scripts\cleanup_agent.ps1                             # Run cleanup
#   .\scripts\cleanup_agent.ps1 -ExperimentDays 30 -LogDays 7  # Custom thresholds

param(
    [switch]$WhatIf,
    [int]$ExperimentDays = 30,
    [int]$LogDays = 7,
    [int]$TempDays = 1,
    [switch]$Quiet
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
Set-Location $projectRoot

$dataDir = Join-Path $projectRoot "data\output"
$cleanupLogDir = Join-Path $dataDir "logs\cleanup"
$statusFile = Join-Path $dataDir "config\agent_status.json"

# Ensure directories exist
if (-not (Test-Path $cleanupLogDir)) {
    New-Item -ItemType Directory -Force -Path $cleanupLogDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $cleanupLogDir "cleanup_$timestamp.md"

# Initialize log file
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $logEntry = "- [{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    
    if (-not $Quiet) {
        switch ($Level) {
            "INFO" { Write-Host $Message -ForegroundColor White }
            "SUCCESS" { Write-Host $Message -ForegroundColor Green }
            "WARNING" { Write-Host $Message -ForegroundColor Yellow }
            "ERROR" { Write-Host $Message -ForegroundColor Red }
            default { Write-Host $Message }
        }
    }
}

# Initialize log file
$logHeader = @"
# Cleanup Agent Log

**Started:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Mode:** $(if ($WhatIf) { "DRY-RUN (Preview Only)" } else { "EXECUTE" })
**Thresholds:**
- Experiments: Archive after $ExperimentDays days
- Logs: Move after $LogDays days
- Temp files: Remove after $TempDays days

---
"@
$logHeader | Set-Content -Path $logFile -Encoding UTF8

# Update agent status
try {
    & ".\scripts\update_agent_status.ps1" -AgentName "cleanup" -Status "running" -CurrentTask "Cleanup operation" -LogFile $logFile -ErrorAction SilentlyContinue
} catch {
    Write-Log "Warning: Could not update agent status: $($_.Exception.Message)" "WARNING"
}

# Summary counters
$summary = @{
    LogsMoved = 0
    LocksCleaned = 0
    ExperimentsArchived = 0
    TempFilesRemoved = 0
    OrphanedLocksRemoved = 0
    Errors = @()
    SpaceFreed = 0
}

# 1. Clean agent logs and locks
Write-Log "=== Step 1: Cleaning agent logs and locks ===" "INFO"
try {
    if ($WhatIf) {
        Write-Log "DRY-RUN: Would clean agent logs and locks" "INFO"
    } else {
        $result = & ".\scripts\cleanup_agent_logs.ps1" -Quiet
        if ($result) {
            $summary.LogsMoved = $result.MovedLogs
            $summary.LocksCleaned = $result.CleanedLocks
            Write-Log "Moved $($summary.LogsMoved) log file(s) to processed/" "SUCCESS"
            Write-Log "Cleaned $($summary.LocksCleaned) stale monitor lock(s)" "SUCCESS"
        }
    }
} catch {
    $errorMsg = "Error cleaning logs: $($_.Exception.Message)"
    Write-Log $errorMsg "ERROR"
    $summary.Errors += $errorMsg
}

# 2. Archive old experiments
# NOTE: .cursor/plans/ directory is NEVER touched by cleanup scripts - plans must be preserved in git
Write-Log "`n=== Step 2: Archiving old experiments ===" "INFO"
try {
    if ($WhatIf) {
        Write-Log "DRY-RUN: Would archive experiments older than $ExperimentDays days" "INFO"
        # Count files that would be archived
        $experimentsPath = Join-Path $dataDir "experiments"
        if (Test-Path $experimentsPath) {
            $cutoffDate = (Get-Date).AddDays(-$ExperimentDays)
            $oldFiles = Get-ChildItem -Path $experimentsPath -Filter "*_optimization_*.json" -File -ErrorAction SilentlyContinue | 
                Where-Object { $_.LastWriteTime -lt $cutoffDate -and $_.Name -notlike "*_best_params.json" }
            Write-Log "Would archive approximately $($oldFiles.Count) experiment file(s)" "INFO"
        }
    } else {
        $archived = & ".\scripts\cleanup_experiments.ps1" -Quiet -ArchiveDaysOld $ExperimentDays
        $summary.ExperimentsArchived = $archived
        Write-Log "Archived $archived experiment file(s)" "SUCCESS"
    }
} catch {
    $errorMsg = "Error archiving experiments: $($_.Exception.Message)"
    Write-Log $errorMsg "ERROR"
    $summary.Errors += $errorMsg
}

# 3. Remove temporary files
Write-Log "`n=== Step 3: Removing temporary files ===" "INFO"
function Remove-TempFiles {
    $tempDir = Join-Path $projectRoot "temp"
    if (-not (Test-Path $tempDir)) {
        Write-Log "Temp directory does not exist: $tempDir" "INFO"
        return 0
    }
    
    $cutoffDate = (Get-Date).AddDays(-$TempDays)
    $removedCount = 0
    $removedSize = 0
    
    # Remove old wrapper scripts (temporary PowerShell wrappers)
    # NOTE: .cursor/plans/ directory is NEVER touched by cleanup scripts - plans must be preserved
    $tempFiles = Get-ChildItem -Path $tempDir -File -ErrorAction SilentlyContinue |
        Where-Object { 
            $_.LastWriteTime -lt $cutoffDate -and 
            ($_.Name -like "*wrapper*.ps1" -or $_.Name -like "*temp*.ps1" -or $_.Extension -eq ".tmp")
        }
    
    foreach ($file in $tempFiles) {
        try {
            if (-not $WhatIf) {
                $size = (Get-Item $file.FullName).Length
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                $removedCount++
                $removedSize += $size
            } else {
                $removedCount++
                $removedSize += (Get-Item $file.FullName).Length
            }
        } catch {
            Write-Log "Warning: Could not remove temp file $($file.Name): $($_.Exception.Message)" "WARNING"
        }
    }
    
    if ($WhatIf) {
        Write-Log "DRY-RUN: Would remove $removedCount temp file(s) (~$([math]::Round($removedSize/1KB, 2)) KB)" "INFO"
    } else {
        Write-Log "Removed $removedCount temp file(s) (~$([math]::Round($removedSize/1KB, 2)) KB)" "SUCCESS"
    }
    
    $summary.TempFilesRemoved = $removedCount
    $summary.SpaceFreed += $removedSize
    
    return $removedCount
}

try {
    Remove-TempFiles
} catch {
    $errorMsg = "Error removing temp files: $($_.Exception.Message)"
    Write-Log $errorMsg "ERROR"
    $summary.Errors += $errorMsg
}

# 4. Clean orphaned lock files (in addition to monitor locks)
Write-Log "`n=== Step 4: Cleaning orphaned lock files ===" "INFO"
function Remove-OrphanedLocks {
    $locksDir = Join-Path $dataDir "logs\active"
    if (-not (Test-Path $locksDir)) {
        return 0
    }
    
    $removedCount = 0
    
    # Find lock files
    $lockFiles = Get-ChildItem -Path $locksDir -Filter "*.lock" -File -ErrorAction SilentlyContinue
    
    foreach ($lockFile in $lockFiles) {
        try {
            # Try to read PID from lock file
            $lockContent = Get-Content $lockFile.FullName -Raw -ErrorAction SilentlyContinue
            if ($lockContent -match 'PID["\s:]+(\d+)') {
                $pid = [int]$matches[1]
                
                # Check if process exists
                $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
                if (-not $proc) {
                    # Process doesn't exist - orphaned lock
                    if (-not $WhatIf) {
                        Remove-Item -Path $lockFile.FullName -Force -ErrorAction Stop
                        $removedCount++
                    } else {
                        $removedCount++
                        Write-Log "DRY-RUN: Would remove orphaned lock $($lockFile.Name) (PID $pid not running)" "INFO"
                    }
                }
            } else {
                # Lock file format unknown - be conservative, skip it
                Write-Log "Warning: Unknown lock file format: $($lockFile.Name)" "WARNING"
            }
        } catch {
            Write-Log "Warning: Could not process lock file $($lockFile.Name): $($_.Exception.Message)" "WARNING"
        }
    }
    
    if (-not $WhatIf -and $removedCount -gt 0) {
        Write-Log "Removed $removedCount orphaned lock file(s)" "SUCCESS"
    }
    
    $summary.OrphanedLocksRemoved = $removedCount
    
    return $removedCount
}

try {
    Remove-OrphanedLocks
} catch {
    $errorMsg = "Error removing orphaned locks: $($_.Exception.Message)"
    Write-Log $errorMsg "ERROR"
    $summary.Errors += $errorMsg
}

# Generate summary report
Write-Log "`n=== Cleanup Summary ===" "INFO"

$summaryText = @"

## Summary

- **Logs moved to processed/:** $($summary.LogsMoved)
- **Stale monitor locks cleaned:** $($summary.LocksCleaned)
- **Experiments archived:** $($summary.ExperimentsArchived)
- **Temp files removed:** $($summary.TempFilesRemoved)
- **Orphaned locks removed:** $($summary.OrphanedLocksRemoved)
- **Disk space freed:** ~$([math]::Round($summary.SpaceFreed/1MB, 2)) MB

**Finished:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Duration:** $((New-TimeSpan -Start (Get-Date).AddSeconds(-30) -End (Get-Date)).TotalSeconds.ToString("F2")) seconds

"@

if ($summary.Errors.Count -gt 0) {
    $summaryText += "`n## Errors`n`n"
    foreach ($error in $summary.Errors) {
        $summaryText += "- $error`n"
    }
}

$summaryText | Add-Content -Path $logFile -Encoding UTF8

# Update agent status
try {
    $finalStatus = if ($summary.Errors.Count -gt 0) { "error" } else { "idle" }
    & ".\scripts\update_agent_status.ps1" -AgentName "cleanup" -Status $finalStatus -CurrentTask $null -ErrorAction SilentlyContinue
} catch {
    Write-Log "Warning: Could not update agent status: $($_.Exception.Message)" "WARNING"
}

# Output summary
if (-not $Quiet) {
    Write-Host "`n=== Cleanup Summary ===" -ForegroundColor Cyan
    Write-Host "Logs moved: $($summary.LogsMoved)" -ForegroundColor Gray
    Write-Host "Locks cleaned: $($summary.LocksCleaned)" -ForegroundColor Gray
    Write-Host "Experiments archived: $($summary.ExperimentsArchived)" -ForegroundColor Gray
    Write-Host "Temp files removed: $($summary.TempFilesRemoved)" -ForegroundColor Gray
    Write-Host "Orphaned locks removed: $($summary.OrphanedLocksRemoved)" -ForegroundColor Gray
    Write-Host "Space freed: ~$([math]::Round($summary.SpaceFreed/1MB, 2)) MB" -ForegroundColor Gray
    Write-Host "`nLog file: $logFile" -ForegroundColor Cyan
}

# Exit with error code if errors occurred
if ($summary.Errors.Count -gt 0) {
    exit 1
}

exit 0

