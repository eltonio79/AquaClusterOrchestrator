# Script to clean up agent logs - moves completed logs to processed/ and cleans monitor locks
# Can be run standalone or called from other scripts

param(
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
$activePath = Join-Path (Join-Path $projectRoot "data\output") "logs\active"
$processedPath = Join-Path (Join-Path $projectRoot "data\output") "logs\processed"
$lockFile = Join-Path $activePath ".monitor_lock.txt"

# Funkcja do czyszczenia starych locków (usuwa wpisy dla nieistniejących procesów)
function Clean-MonitorLocks {
    if (-not (Test-Path $lockFile)) {
        return 0
    }
    
    $cleanedCount = 0
    
    try {
        $content = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue
        if (-not $content) { return 0 }
        
        $lines = $content -split "`r?`n" | Where-Object { $_.Trim() }
        $validLocks = @()
        
        foreach ($line in $lines) {
            try {
                $lockData = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
                if ($lockData -and $lockData.PID) {
                    # Sprawdź czy proces nadal działa
                    $proc = Get-Process -Id $lockData.PID -ErrorAction SilentlyContinue
                    if ($proc -and $proc.ProcessName -like "*powershell*") {
                        # Proces działa - zachowaj lock
                        $validLocks += $line
                    } else {
                        # Proces nie istnieje - usuń lock
                        $cleanedCount++
                    }
                } else {
                    # Niepoprawny format - zachowaj dla bezpieczeństwa
                    $validLocks += $line
                }
            } catch {
                # Jeśli nie można sparsować linii, zachowaj ją (może być ważna)
                $validLocks += $line
            }
        }
        
        # Zapisz tylko ważne locki
        if ($validLocks.Count -gt 0) {
            $validLocks | Set-Content -Path $lockFile -Encoding UTF8 -NoNewline
        } else {
            # Jeśli nie ma ważnych locków, usuń plik
            Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
        }
    } catch {
        # W razie błędu, zostaw plik bez zmian
    }
    
    return $cleanedCount
}

# Funkcja do przenoszenia zakończonych logów do processed/
function Move-CompletedLogs {
    if (-not (Test-Path $activePath)) { return 0 }
    if (-not (Test-Path $processedPath)) {
        New-Item -ItemType Directory -Force -Path $processedPath | Out-Null
    }
    
    $movedCount = 0
    
    try {
        # Pobierz wszystkie logi z active
        $logs = Get-ChildItem -Path $activePath -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue
        
        foreach ($log in $logs) {
            try {
                $content = Get-Content $log.FullName -Raw -ErrorAction SilentlyContinue
                if (-not $content) { continue }
                
                # Sprawdź czy log ma oznaczenie "Finished" lub "Exit:"
                $isFinished = $content -match '- Finished:' -or $content -match '- Exit:'
                
                if ($isFinished) {
                    # Sprawdź czy nie ma już procesu pipeline który używa tego loga
                    $logTimestamp = $log.Name -replace 'agent_run_(\d{8})_(\d{6})\.md', '$1_$2'
                    
                    # Sprawdź czy istnieje proces Python/PowerShell który mógłby używać tego loga
                    $hasActiveProcess = $false
                    $allProcs = Get-CimInstance Win32_Process -Filter "Name LIKE 'python%' OR Name LIKE 'powershell%' OR Name LIKE 'pwsh%'" -ErrorAction SilentlyContinue
                    foreach ($proc in $allProcs) {
                        if ($proc.CommandLine -like "*pipeline*" -or $proc.CommandLine -like "*$logTimestamp*") {
                            $hasActiveProcess = $true
                            break
                        }
                    }
                    
                    # Jeśli log jest zakończony I nie ma aktywnych procesów - przenieś do processed
                    if (-not $hasActiveProcess) {
                        # Sprawdź czy nikt nie monitoruje tego loga
                        $isMonitored = $false
                        if (Test-Path $lockFile) {
                            $lockContent = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue
                            if ($lockContent -and $lockContent -like "*$($log.Name)*") {
                                $isMonitored = $true
                            }
                        }
                        
                        if (-not $isMonitored) {
                            # Przenieś log i powiązane pliki
                            Move-Item -Path $log.FullName -Destination $processedPath -Force -ErrorAction SilentlyContinue
                            $movedCount++
                            
                            # Przenieś powiązane pipeline logi jeśli istnieją
                            $logBaseName = $log.BaseName -replace 'agent_run_', 'pipeline_run_'
                            Get-ChildItem -Path $activePath -Filter "*$logBaseName*" -File -ErrorAction SilentlyContinue | ForEach-Object {
                                Move-Item -Path $_.FullName -Destination $processedPath -Force -ErrorAction SilentlyContinue
                            }
                            
                            # Przenieś powiązane pipeline logi (pipeline_*.log) z tym samym timestamp
                            $pipelineLogPattern = $log.Name -replace 'agent_run_', 'pipeline_'
                            Get-ChildItem -Path $activePath -Filter $pipelineLogPattern -File -ErrorAction SilentlyContinue | ForEach-Object {
                                Move-Item -Path $_.FullName -Destination $processedPath -Force -ErrorAction SilentlyContinue
                            }
                        }
                    }
                }
            } catch {
                # Ignoruj błędy przy przetwarzaniu pojedynczego loga
            }
        }
    } catch {
        # Ignoruj ogólne błędy
    }
    
    return $movedCount
}

# Main cleanup logic
try {
    $cleanedLocks = Clean-MonitorLocks
    $movedLogs = Move-CompletedLogs
    
    if (-not $Quiet) {
        if ($cleanedLocks -gt 0 -or $movedLogs -gt 0) {
            Write-Host "Cleanup completed:" -ForegroundColor Cyan
            if ($cleanedLocks -gt 0) {
                Write-Host "  - Removed $cleanedLocks stale monitor lock(s)" -ForegroundColor Gray
            }
            if ($movedLogs -gt 0) {
                Write-Host "  - Moved $movedLogs completed log(s) to processed/" -ForegroundColor Gray
            }
        }
    }
    
    # Return counts for use by calling scripts
    return @{
        CleanedLocks = $cleanedLocks
        MovedLogs = $movedLogs
    }
} catch {
    if (-not $Quiet) {
        Write-Host "Cleanup error: $($_.Exception.Message)" -ForegroundColor Red
    }
    return @{
        CleanedLocks = 0
        MovedLogs = 0
    }
}

