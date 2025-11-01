param(
    [int]$PollIntervalSeconds = 5,
    [int]$ActiveThresholdSeconds = 60
)

# Dynamiczne wyznaczanie root projektu (szuka .git lub paths.txt lub ustawia na podstawie lokalizacji skryptu)
function Get-ProjectRoot {
    # Spróbuj różne sposoby wykrycia lokalizacji skryptu
    $scriptDir = $null
    
    # 1. PSScriptRoot (najpewniejsze, działa gdy skrypt uruchomiony bezpośrednio)
    if ($PSScriptRoot) {
        $scriptDir = $PSScriptRoot
    }
    
    # 2. $PSCommandPath (działa gdy skrypt uruchomiony przez -File)
    if (-not $scriptDir -and $PSCommandPath) {
        $scriptDir = Split-Path -Parent $PSCommandPath
    }
    
    # 3. MyInvocation (fallback)
    if (-not $scriptDir) {
        try {
            $invocationPath = $MyInvocation.MyCommand.Path
            if ($invocationPath) {
                $scriptDir = Split-Path -Parent $invocationPath
            }
        } catch {
            # Ignoruj błędy
        }
    }
    
    # 4. Jeśli wciąż brak, użyj Get-Location jako fallback
    $currentPath = if ($scriptDir) { $scriptDir } else { Get-Location }
    
    # Sprawdź, czy jesteśmy w root (szukaj .git, paths.txt, lub data/output)
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
    
    # Fallback: jeśli skrypt jest w scripts/, cofnij się o jeden poziom
    if ($currentPath -match 'scripts$') {
        return Split-Path -Parent $currentPath
    }
    
    return $currentPath
}

$projectRoot = Get-ProjectRoot
$logsPath = Join-Path $projectRoot "data\output\logs\active"

# Fallback do starej lokalizacji jeśli active nie istnieje
if (-not (Test-Path $logsPath)) {
    $logsPath = Join-Path $projectRoot "data\output\logs"
    if (-not (Test-Path $logsPath)) {
        Write-Host "Logs folder not found: $logsPath" -ForegroundColor Red
        Write-Host "Project root detected: $projectRoot" -ForegroundColor Yellow
        exit 1
    }
}

# Funkcja do znajdowania aktywnych logów agentów
function Get-ActiveAgentLogs {
    # Szukaj tylko w active folderze dla aktywnych logów
    $activePath = $logsPath
    if ($activePath -notlike "*\active") {
        $activePath = Join-Path $logsPath "active"
    }
    if (-not (Test-Path $activePath)) {
        return @()
    }
    $allLogs = Get-ChildItem -Path $activePath -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue
    $threshold = (Get-Date).AddSeconds(-$ActiveThresholdSeconds)
    
    $activeLogs = $allLogs | Where-Object {
        $_.LastWriteTime -gt $threshold
    } | Sort-Object LastWriteTime -Descending
    
    return $activeLogs
}

# Funkcja do pobierania wszystkich obecnie monitorowanych logów (z lock files)
function Get-AllMonitoredLogs {
    # Locki są czyszczone przez zewnętrzny skrypt cleanup_agent_logs.ps1
    
    $lockFile = Join-Path $logsPath ".monitor_lock.txt"
    $monitoredLogs = @()
    
    # Sprawdź lock file dla tej sesji
    if (Test-Path $lockFile) {
        try {
            $content = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue
            if ($content) {
                # Lock file może zawierać wiele wieloliniowych JSON obiektów
                # Parsuj jako kompleksowe obiekty JSON (obsługa zarówno compact jak i formatted)
                $jsonObjects = @()
                $currentJson = ""
                $braceCount = 0
                
                $lines = $content -split "`r?`n"
                foreach ($line in $lines) {
                    $trimmed = $line.Trim()
                    if (-not $trimmed) { continue }
                    
                    # Sprawdź czy linia zaczyna się od { (nowy obiekt)
                    if ($trimmed -match '^\s*\{') {
                        if ($braceCount -eq 0 -and $currentJson) {
                            # Zapisz poprzedni obiekt
                            try {
                                $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                            } catch { }
                        }
                        $currentJson = $trimmed
                        $braceCount = ($currentJson.ToCharArray() | Where-Object { $_ -eq '{' }).Count - ($currentJson.ToCharArray() | Where-Object { $_ -eq '}' }).Count
                    } else {
                        # Kontynuacja obiektu
                        $currentJson += "`n" + $trimmed
                        $braceCount += ($trimmed.ToCharArray() | Where-Object { $_ -eq '{' }).Count - ($trimmed.ToCharArray() | Where-Object { $_ -eq '}' }).Count
                    }
                    
                    # Jeśli braceCount == 0, mamy kompletny obiekt
                    if ($braceCount -eq 0 -and $currentJson) {
                        try {
                            $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                        } catch { }
                        $currentJson = ""
                    }
                }
                
                # Przetwórz ostatni obiekt jeśli został
                if ($currentJson -and $braceCount -eq 0) {
                    try {
                        $jsonObjects += ($currentJson | ConvertFrom-Json -ErrorAction Stop)
                    } catch { }
                }
                
                # Przetwórz wszystkie obiekty
                foreach ($lockData in $jsonObjects) {
                    if ($lockData -and $lockData.PID) {
                        $proc = Get-Process -Id $lockData.PID -ErrorAction SilentlyContinue
                        if ($proc -and $proc.ProcessName -like "*powershell*") {
                            if ($lockData.MonitoringFile) {
                                $monitoredLogs += $lockData.MonitoringFile
                            }
                        }
                    }
                }
            }
        } catch {
            # Ignoruj błędy odczytu
        }
    }
    
    # Sprawdź też bezpośrednio procesy PowerShell z tym skryptem
    $scriptName = "monitor_most_recent_agents_markdown_log.ps1"
    try {
        $scriptPath = $MyInvocation.MyCommand.Path
        if ($scriptPath) {
            $scriptName = Split-Path -Leaf $scriptPath
        }
    } catch {
        # Użyj domyślnej nazwy
    }
    
    $runningMonitors = Get-CimInstance Win32_Process -Filter "Name LIKE 'powershell%' OR Name LIKE 'pwsh%'" -ErrorAction SilentlyContinue | Where-Object {
        if ($_.CommandLine -like "*$scriptName*") {
            # Ten proces może monitorować log - sprawdź, czy ma otwarty plik z logsPath
            try {
                $procId = $_.ProcessId
                $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
                if ($proc) {
                    # Nie możemy bezpośrednio sprawdzić otwartych plików, więc poleganie na lock file
                    return $true
                }
            } catch {
                return $false
            }
        }
        return $false
    }
    
    return $monitoredLogs | Select-Object -Unique
}

# Funkcja do zapisania lock file (append do pliku, bo może być wiele monitorów)
function Set-MonitorLock {
    param([string]$LogFile)
    $lockFile = Join-Path $logsPath ".monitor_lock.txt"
    
    $scriptPath = ""
    try {
        $scriptPath = $MyInvocation.MyCommand.Path
        if (-not $scriptPath) { $scriptPath = "" }
    } catch {
        $scriptPath = ""
    }
    
    $lockData = @{
        PID = $PID
        MonitoringFile = $LogFile
        Started = (Get-Date).ToString("o")
        ScriptPath = $scriptPath
    } | ConvertTo-Json -Compress
    
    # Append do lock file (każda linia = jeden monitor jako compact JSON)
    Add-Content -Path $lockFile -Value $lockData -Encoding UTF8
}

# Funkcja do usunięcia naszego wpisu z lock file
function Remove-MonitorLock {
    # Lock file w folderze active
    $lockFile = Join-Path $logsPath ".monitor_lock.txt"
    if (-not (Test-Path $lockFile)) {
        return
    }
    
    try {
        $content = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $lines = $content -split "`n" | Where-Object { 
                $line = $_.Trim()
                if (-not $line) { return $false }
                try {
                    $lockData = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
                    return ($lockData.PID -ne $PID)
                } catch {
                    return $true
                }
            }
            
            if ($lines.Count -gt 0) {
                $lines | Set-Content -Path $lockFile -Encoding UTF8 -NoNewline
            } else {
                Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {
        # W razie błędu, usuń cały plik (najbezpieczniejsze)
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

# Cleanup przy wyjściu
$script:CleanupDone = $false
function Cleanup {
    if (-not $script:CleanupDone) {
        Remove-MonitorLock
        $script:CleanupDone = $true
    }
}
Register-ObjectEvent -InputObject ([System.Console]) -EventName CancelKeyPress -Action { Cleanup; exit } | Out-Null
trap { Cleanup; break }

# Wywołaj skrypt czyszczący na początku
$cleanupScript = Join-Path $projectRoot "scripts\cleanup_agent_logs.ps1"
if (Test-Path $cleanupScript) {
    $cleanupResult = & $cleanupScript -Quiet
}

# Pobierz wszystkie obecnie monitorowane logi
$allMonitoredLogs = Get-AllMonitoredLogs

# Znajdź wszystkie aktywne logi
$activeLogs = Get-ActiveAgentLogs

if (-not $activeLogs -or $activeLogs.Count -eq 0) {
    Write-Host "No active agent logs found (modified in last $ActiveThresholdSeconds seconds)" -ForegroundColor Yellow
    Write-Host "Available agent logs:" -ForegroundColor Cyan
    $allLogs = Get-ChildItem -Path $logsPath -Filter "agent_run_*.md" -File | Sort-Object LastWriteTime -Descending
    $allLogs | ForEach-Object {
        $age = (Get-Date) - $_.LastWriteTime
        $monitored = if ($allMonitoredLogs -contains $_.FullName) { " [MONITORED]" } else { "" }
        Write-Host ("  - {0} (last modified: {1} ago){2}" -f $_.Name, $age.ToString("hh\:mm\:ss"), $monitored) -ForegroundColor Gray
    }
    exit 0
}

# Wybierz log do monitorowania (pomiń już monitorowane)
$availableLogs = $activeLogs | Where-Object { $allMonitoredLogs -notcontains $_.FullName }
$logToMonitor = $null

if ($availableLogs -and $availableLogs.Count -gt 0) {
    $logToMonitor = $availableLogs | Select-Object -First 1
    if ($allMonitoredLogs.Count -gt 0) {
        Write-Host "Switching to next available active log" -ForegroundColor Cyan
        Write-Host "Currently monitored logs: $($allMonitoredLogs.Count)" -ForegroundColor Gray
        foreach ($monitored in $allMonitoredLogs) {
            Write-Host ("  - {0}" -f (Split-Path $monitored -Leaf)) -ForegroundColor DarkGray
        }
    }
} else {
    # Wszystkie aktywne logi są już monitorowane
    Write-Host "All active agent logs are already being monitored!" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Active logs currently monitored:" -ForegroundColor Cyan
    foreach ($log in $activeLogs) {
        Write-Host ("  - {0} (last modified: {1})" -f $log.Name, $log.LastWriteTime.ToString("HH:mm:ss")) -ForegroundColor Gray
    }
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  1. Wait for a new agent log to appear" -ForegroundColor Gray
    Write-Host "  2. Stop one of the existing monitors (Ctrl+C in its terminal)" -ForegroundColor Gray
    Write-Host "  3. Check for older logs that might be active" -ForegroundColor Gray
    Write-Host "" -ForegroundColor Yellow
    
    # Pokaż też nieaktywne logi (może użytkownik chce monitorować starszy)
    $allLogs = Get-ChildItem -Path $logsPath -Filter "agent_run_*.md" -File | Sort-Object LastWriteTime -Descending
    $unmonitoredAll = $allLogs | Where-Object { $allMonitoredLogs -notcontains $_.FullName } | Select-Object -First 5
    if ($unmonitoredAll) {
        Write-Host "Unmonitored logs (may not be active):" -ForegroundColor DarkCyan
        foreach ($log in $unmonitoredAll) {
            $age = (Get-Date) - $log.LastWriteTime
            Write-Host ("  - {0} (last modified: {1} ago)" -f $log.Name, $age.ToString("hh\:mm\:ss")) -ForegroundColor DarkGray
        }
    }
    
    exit 0
}

# Ustaw lock file
Set-MonitorLock -LogFile $logToMonitor.FullName

Write-Host "Monitoring: $($logToMonitor.Name)" -ForegroundColor Green
Write-Host "Full path: $($logToMonitor.FullName)" -ForegroundColor DarkGray
Write-Host "Last modified: $($logToMonitor.LastWriteTime)" -ForegroundColor Gray
Write-Host "Project root: $projectRoot" -ForegroundColor DarkGray
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Gray
Write-Host "---" -ForegroundColor Gray
Write-Host ""

# Tail log file
$lastSize = 0
$filePath = $logToMonitor.FullName

try {
    while ($true) {
        if (-not (Test-Path $filePath)) {
            Write-Host "`nLog file disappeared: $filePath" -ForegroundColor Red
            break
        }
        
        $currentSize = (Get-Item $filePath -ErrorAction SilentlyContinue).Length
        if ($currentSize -gt $lastSize) {
            # Nowa zawartość - wyświetl tylko nowe linie
            $reader = [System.IO.StreamReader]::new($filePath)
            $reader.BaseStream.Position = $lastSize
            
            while ($null -ne ($line = $reader.ReadLine())) {
                Write-Host $line
            }
            
            $reader.Close()
            $lastSize = $currentSize
        } elseif ($currentSize -lt $lastSize) {
            # Plik został przepisany - zacznij od początku
            $lastSize = 0
            Write-Host "`n--- Log file was rewritten, restarting from beginning ---" -ForegroundColor Yellow
            Write-Host ""
        }
        
        Start-Sleep -Seconds $PollIntervalSeconds
    }
} finally {
    Cleanup
    Write-Host "`nMonitor stopped." -ForegroundColor Yellow
}
