param(
    [switch]$All,
    [string[]]$LogFiles,
    [int[]]$ProcessIDs
)

<#
.SYNOPSIS
    Stops running monitor_most_recent_agents_markdown_log.ps1 processes.

.DESCRIPTION
    This script can stop all running monitor processes or specific ones by LogFile path or PID.
    
    -All: Stop all running monitor processes
    -LogFiles: Comma or space separated list of log file paths to stop monitoring for
    -ProcessIDs: Space separated list of process IDs to kill

.EXAMPLE
    .\stop_monitor_agents.ps1 -All
    
.EXAMPLE
    .\stop_monitor_agents.ps1 -LogFiles "data\output\logs\agent_run_20251031_162427.md"
    
.EXAMPLE
    .\stop_monitor_agents.ps1 -ProcessIDs 12345,67890
#>

# Dynamiczne wyznaczanie root projektu
function Get-ProjectRoot {
    $scriptDir = $null
    
    if ($PSScriptRoot) {
        $scriptDir = $PSScriptRoot
    } elseif ($PSCommandPath) {
        $scriptDir = Split-Path -Parent $PSCommandPath
    } else {
        try {
            $invocationPath = $MyInvocation.MyCommand.Path
            if ($invocationPath) {
                $scriptDir = Split-Path -Parent $invocationPath
            }
        } catch { }
    }
    
    $currentPath = if ($scriptDir) { $scriptDir } else { Get-Location }
    
    $checkPath = $currentPath
    while ($checkPath -and $checkPath.Length -gt 3) {
        $gitMarker = Join-Path $checkPath ".git"
        $pathsMarker = Join-Path $checkPath "paths.txt"
        $dataMarker = Join-Path $checkPath "data"
        
        if ((Test-Path $gitMarker) -or (Test-Path $pathsMarker) -or (Test-Path $dataMarker)) {
            return $checkPath
        }
        
        $checkPath = Split-Path -Parent $checkPath
    }
    
    if ($currentPath -match 'scripts$') {
        return Split-Path -Parent $currentPath
    }
    
    return $currentPath
}

$projectRoot = Get-ProjectRoot
$logsPath = Join-Path $projectRoot "data\output\logs"
$lockFile = Join-Path $logsPath ".monitor_lock.txt"
$scriptName = "monitor_most_recent_agents_markdown_log.ps1"

# Funkcja do parsowania lock file
function Get-MonitorEntries {
    $entries = @()
    
    if (-not (Test-Path $lockFile)) {
        return $entries
    }
    
    try {
        $content = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Parsuj zarówno compact JSON (jedna linia) jak i formatted (wiele linii)
            $jsonObjects = @()
            $currentJson = ""
            $braceCount = 0
            
            $lines = $content -split "`r?`n"
            foreach ($line in $lines) {
                $trimmed = $line.Trim()
                if (-not $trimmed) { continue }
                
                if ($trimmed -match '^\s*\{') {
                    if ($braceCount -eq 0 -and $currentJson) {
                        try {
                            $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                        } catch { }
                    }
                    $currentJson = $trimmed
                    $braceCount = ($currentJson.ToCharArray() | Where-Object { $_ -eq '{' }).Count - ($currentJson.ToCharArray() | Where-Object { $_ -eq '}' }).Count
                } else {
                    $currentJson += "`n" + $trimmed
                    $braceCount += ($trimmed.ToCharArray() | Where-Object { $_ -eq '{' }).Count - ($trimmed.ToCharArray() | Where-Object { $_ -eq '}' }).Count
                }
                
                if ($braceCount -eq 0 -and $currentJson) {
                    try {
                        $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                    } catch { }
                    $currentJson = ""
                }
            }
            
            if ($currentJson -and $braceCount -eq 0) {
                try {
                    $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                } catch { }
            }
            
            foreach ($lockData in $jsonObjects) {
                if ($lockData -and $lockData.PID) {
                    # Sprawdź czy proces nadal działa
                    $proc = Get-Process -Id $lockData.PID -ErrorAction SilentlyContinue
                    if ($proc) {
                        $entries += @{
                            PID = $lockData.PID
                            MonitoringFile = $lockData.MonitoringFile
                            Started = $lockData.Started
                            Process = $proc
                        }
                    }
                }
            }
        }
    } catch {
        Write-Warning "Error reading lock file: $_"
    }
    
    return $entries
}

# Funkcja do usunięcia wpisu z lock file
function Remove-LockEntry {
    param([int]$ProcessID)
    
    if (-not (Test-Path $lockFile)) {
        return
    }
    
    try {
        $content = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Parsuj wszystkie wpisy
            $jsonObjects = @()
            $currentJson = ""
            $braceCount = 0
            
            $lines = $content -split "`r?`n"
            foreach ($line in $lines) {
                $trimmed = $line.Trim()
                if (-not $trimmed) { continue }
                
                if ($trimmed -match '^\s*\{') {
                    if ($braceCount -eq 0 -and $currentJson) {
                        try {
                            $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                        } catch { }
                    }
                    $currentJson = $trimmed
                    $braceCount = ($currentJson.ToCharArray() | Where-Object { $_ -eq '{' }).Count - ($currentJson.ToCharArray() | Where-Object { $_ -eq '}' }).Count
                } else {
                    $currentJson += "`n" + $trimmed
                    $braceCount += ($trimmed.ToCharArray() | Where-Object { $_ -eq '{' }).Count - ($trimmed.ToCharArray() | Where-Object { $_ -eq '}' }).Count
                }
                
                if ($braceCount -eq 0 -and $currentJson) {
                    try {
                        $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                    } catch { }
                    $currentJson = ""
                }
            }
            
            if ($currentJson -and $braceCount -eq 0) {
                try {
                    $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                } catch { }
            }
            
            # Filtruj usuwany PID
            $remaining = $jsonObjects | Where-Object { $_.PID -ne $ProcessID }
            
            if ($remaining.Count -gt 0) {
                # Zapisz pozostałe wpisy jako compact JSON (jedna linia każdy)
                $remaining | ForEach-Object {
                    ($_ | ConvertTo-Json -Compress)
                } | Set-Content -Path $lockFile -Encoding UTF8
            } else {
                # Usuń plik jeśli nie ma więcej wpisów
                Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Warning "Error updating lock file: $_"
    }
}

# Funkcja do zatrzymania procesu
function Stop-MonitorProcess {
    param(
        [int]$ProcessID,
        [string]$LogFile
    )
    
    try {
        $proc = Get-Process -Id $ProcessID -ErrorAction Stop
        Write-Host "Stopping PID $ProcessID (monitoring: $(Split-Path -Leaf $LogFile))" -ForegroundColor Yellow
        Stop-Process -Id $ProcessID -Force -ErrorAction Stop
        Remove-LockEntry -ProcessID $ProcessID
        Write-Host "  [OK] Stopped PID $ProcessID" -ForegroundColor Green
        return $true
    } catch {
        $errMsg = $_.Exception.Message
        Write-Host "  [FAIL] Failed to stop PID $ProcessID : $errMsg" -ForegroundColor Red
        return $false
    }
}

# Główna logika
Write-Host "=== Stop Monitor Agents ===" -ForegroundColor Cyan
Write-Host ""

$entries = Get-MonitorEntries
$stopped = 0
$failed = 0

if ($entries.Count -eq 0) {
    Write-Host "No active monitor processes found." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($entries.Count) active monitor process(es):" -ForegroundColor Cyan
foreach ($entry in $entries) {
    $logName = Split-Path -Leaf $entry.MonitoringFile
    Write-Host "  PID $($entry.PID) - Monitoring: $logName" -ForegroundColor Gray
}
Write-Host ""

if ($All) {
    # Zatrzymaj wszystkie
    Write-Host "Stopping all monitor processes..." -ForegroundColor Yellow
    foreach ($entry in $entries) {
        if (Stop-MonitorProcess -ProcessID $entry.PID -LogFile $entry.MonitoringFile) {
            $stopped++
        } else {
            $failed++
        }
    }
} elseif ($LogFiles -and $LogFiles.Count -gt 0) {
    # Zatrzymaj tylko te dla podanych plików logów
    # Normalizuj ścieżki (obsługa zarówno względnych jak i bezwzględnych)
    $normalizedLogFiles = @()
    foreach ($logFile in $LogFiles) {
        # Rozdziel jeśli było kilka w jednym stringu (przecinek lub spacja)
        $split = $logFile -split '[,\s]+' | Where-Object { $_.Trim() }
        foreach ($item in $split) {
            $trimmed = $item.Trim('"''')
            if ($trimmed) {
                # Konwertuj na pełną ścieżkę jeśli względna
                if (-not [System.IO.Path]::IsPathRooted($trimmed)) {
                    $normalized = (Resolve-Path -Path (Join-Path $logsPath $trimmed) -ErrorAction SilentlyContinue).Path
                    if (-not $normalized) {
                        $normalized = Join-Path $logsPath $trimmed
                    }
                } else {
                    $normalized = $trimmed
                }
                $normalizedLogFiles += $normalized
            }
        }
    }
    
    Write-Host "Stopping monitors for specified log files..." -ForegroundColor Yellow
    foreach ($normalizedFile in $normalizedLogFiles) {
        $matchingEntries = $entries | Where-Object { 
            $entryFile = $_.MonitoringFile
            # Porównaj zarówno pełne ścieżki jak i tylko nazwy plików
            $entryFile -eq $normalizedFile -or 
            (Split-Path -Leaf $entryFile) -eq (Split-Path -Leaf $normalizedFile) -or
            $entryFile -like "*$normalizedFile*"
        }
        
        if ($matchingEntries.Count -gt 0) {
            foreach ($entry in $matchingEntries) {
                if (Stop-MonitorProcess -ProcessID $entry.PID -LogFile $entry.MonitoringFile) {
                    $stopped++
                } else {
                    $failed++
                }
            }
        } else {
            Write-Host "  No monitor found for: $(Split-Path -Leaf $normalizedFile)" -ForegroundColor Yellow
        }
    }
} elseif ($ProcessIDs -and $ProcessIDs.Count -gt 0) {
    # Zatrzymaj tylko podane PID-y
    Write-Host "Stopping monitors for specified PIDs..." -ForegroundColor Yellow
    foreach ($procId in $ProcessIDs) {
        $matchingEntry = $entries | Where-Object { $_.PID -eq $procId } | Select-Object -First 1
        
        if ($matchingEntry) {
            if (Stop-MonitorProcess -PID $matchingEntry.PID -LogFile $matchingEntry.MonitoringFile) {
                $stopped++
            } else {
                $failed++
            }
        } else {
            Write-Host "  PID $procId is not a valid monitor process" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "No action specified. Use -All, -LogFiles, or -ProcessIDs" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\stop_monitor_agents.ps1 -All" -ForegroundColor Gray
    Write-Host "  .\stop_monitor_agents.ps1 -LogFiles 'agent_run_20251031_162427.md'" -ForegroundColor Gray
    Write-Host "  .\stop_monitor_agents.ps1 -ProcessIDs 12345,67890" -ForegroundColor Gray
    exit 0
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "  Stopped: $stopped" -ForegroundColor $(if ($stopped -gt 0) { "Green" } else { "Gray" })
if ($failed -gt 0) {
    Write-Host "  Failed: $failed" -ForegroundColor Red
}
Write-Host ""

