param(
    [Parameter(Position=0)]
    [ValidateSet("list", "start", "stop", "restart")]
    [string]$Action = "list",
    
    [string]$AgentName = "",
    [string[]]$Rules,
    [switch]$NoExport,
    [string]$ConfigPath = "scripts/pipeline_config.json"
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
Set-Location $projectRoot | Out-Null

function Read-Config {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "Config not found: $Path" }
    try { return (Get-Content -Raw -Path $Path | ConvertFrom-Json) }
    catch { throw ("Invalid JSON in " + $Path + ": " + $_.Exception.Message) }
}

function Get-AgentLogs {
    # Check both active and processed folders for complete list
    $logsPathActive = Join-Path (Join-Path $projectRoot "data\output") "logs\active"
    $logsPathProcessed = Join-Path (Join-Path $projectRoot "data\output") "logs\processed"
    
    $logs = @()
    if (Test-Path $logsPathActive) {
        $logs += Get-ChildItem -Path $logsPathActive -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue
    }
    if (Test-Path $logsPathProcessed) {
        $logs += Get-ChildItem -Path $logsPathProcessed -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue
    }
    
    return $logs | Sort-Object LastWriteTime -Descending
}

function Get-AgentInfo {
    param([System.IO.FileInfo]$LogFile)
    
    $info = @{
        Name = $LogFile.Name
        FullPath = $LogFile.FullName
        LastWriteTime = $LogFile.LastWriteTime
        Age = (Get-Date) - $LogFile.LastWriteTime
    }
    
    # Próba odczytania konfiguracji z loga
    try {
        $content = Get-Content $LogFile.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Szukaj sekcji Command - różne formaty
            $cmdLine = $null
            
            # Format 1: ```log python ... ```
            if ($content -match '(?s)```[\s\S]*?python.*?pipeline_runner\.py\s+([^\`]+)```') {
                $cmdLine = $matches[1].Trim()
            }
            # Format 2: ``` python ... ```
            elseif ($content -match '(?s)````[\s\S]*?python.*?pipeline_runner\.py\s+([^\`]+)```') {
                $cmdLine = $matches[1].Trim()
            }
            # Format 3: Linia zaczynająca się od "python pipeline_runner.py"
            elseif ($content -match '(?m)^python\s+pipeline_runner\.py\s+(.+)$') {
                $cmdLine = $matches[1].Trim()
            }
            
            if ($cmdLine) {
                $info.CommandLine = $cmdLine
                
                # Wyciągnij Rules jeśli są (może być kilka)
                if ($cmdLine -match '--rules\s+([^\s]+(?:\s+[^\s-]+)*)') {
                    $rulesStr = $matches[1]
                    # Usuń następne parametry jeśli są
                    $rulesStr = $rulesStr -replace '\s+--.+$', ''
                    $info.Rules = ($rulesStr -split '\s+') | Where-Object { $_ -notmatch '^--' }
                }
                
                # Sprawdź --no-export
                if ($cmdLine -match '--no-export') {
                    $info.NoExport = $true
                }
            }
            
            # Sprawdź status (czy zakończony)
            if ($content -match '- Finished:') {
                $info.Status = "Finished"
            } elseif ($content -match '- Exit:') {
                $info.Status = "Stopped"
            } else {
                $info.Status = "Running"
            }
        }
    } catch {
        $info.Status = "Unknown"
    }
    
    # Sprawdź czy proces Python faktycznie działa
    try {
        $proc = Get-CimInstance Win32_Process -Filter "Name LIKE 'python%'" -ErrorAction SilentlyContinue | 
            Where-Object { $_.CommandLine -like "*pipeline_runner*" -and $_.CommandLine -like "*$($LogFile.Name)*" }
        if ($proc) {
            $info.ProcessId = $proc.ProcessId
            $info.IsRunning = $true
        } else {
            $info.IsRunning = $false
        }
    } catch {
        $info.IsRunning = $false
    }
    
    return $info
}


function List-Agents {
    Write-Host "=== Available Agents ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Wywołaj skrypt czyszczący przed listowaniem
    $cleanupScript = Join-Path $projectRoot "scripts\cleanup_agent_logs.ps1"
    if (Test-Path $cleanupScript) {
        $cleanupResult = & $cleanupScript -Quiet
        if ($cleanupResult.MovedLogs -gt 0 -or $cleanupResult.CleanedLocks -gt 0) {
            Write-Host "Cleaned up:" -ForegroundColor DarkGray
            if ($cleanupResult.CleanedLocks -gt 0) {
                Write-Host "  - Removed $($cleanupResult.CleanedLocks) stale monitor lock(s)" -ForegroundColor DarkGray
            }
            if ($cleanupResult.MovedLogs -gt 0) {
                Write-Host "  - Moved $($cleanupResult.MovedLogs) completed log(s) to processed/" -ForegroundColor DarkGray
            }
            Write-Host ""
        }
    }
    
    $logs = Get-AgentLogs
    
    if ($logs.Count -eq 0) {
        Write-Host "No agent logs found." -ForegroundColor Yellow
        return
    }
    
    $agents = @()
    foreach ($log in $logs) {
        $info = Get-AgentInfo -LogFile $log
        $agents += $info
    }
    
    # Grupuj po statusie
    $running = $agents | Where-Object { $_.IsRunning -eq $true }
    $stopped = $agents | Where-Object { $_.IsRunning -eq $false -and $_.Status -eq "Finished" }
    $active = $agents | Where-Object { $_.IsRunning -eq $false -and $_.Status -eq "Running" }
    
    if ($running.Count -gt 0) {
        Write-Host "RUNNING ($($running.Count)):" -ForegroundColor Green
        foreach ($agent in $running) {
            Write-Host ("  [{0}] {1}" -f $agent.ProcessId, $agent.Name) -ForegroundColor Green
            Write-Host ("      Started: {0} ({1} ago)" -f $agent.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"), 
                "{0:D2}:{1:D2}:{2:D2}" -f $agent.Age.Hours, $agent.Age.Minutes, $agent.Age.Seconds) -ForegroundColor Gray
            if ($agent.Rules) { Write-Host ("      Rules: {0}" -f $agent.Rules) -ForegroundColor DarkGray }
        }
        Write-Host ""
    }
    
    if ($active.Count -gt 0) {
        Write-Host "ACTIVE BUT NO PROCESS ($($active.Count)):" -ForegroundColor Yellow
        foreach ($agent in $active) {
            Write-Host ("  [DEAD] {0}" -f $agent.Name) -ForegroundColor Yellow
            Write-Host ("      Started: {0} ({1} ago)" -f $agent.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"),
                "{0:D2}:{1:D2}:{2:D2}" -f $agent.Age.Hours, $agent.Age.Minutes, $agent.Age.Seconds) -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    if ($stopped.Count -gt 0) {
        Write-Host "FINISHED ($($stopped.Count)):" -ForegroundColor DarkGray
        foreach ($agent in ($stopped | Select-Object -First 5)) {
            Write-Host ("  [DONE] {0}" -f $agent.Name) -ForegroundColor DarkGray
            Write-Host ("      Finished: {0} ({1} ago)" -f $agent.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"),
                "{0:D2}:{1:D2}:{2:D2}" -f $agent.Age.Hours, $agent.Age.Minutes, $agent.Age.Seconds) -ForegroundColor Gray
        }
        Write-Host ""
    }
}

function Start-NewAgent {
    param(
        [string[]]$Rules = @(),
        [bool]$NoExport = $false,
        [string]$ConfigPath = "scripts/pipeline_config.json"
    )
    
    Write-Host "=== Starting New Agent ===" -ForegroundColor Cyan
    Write-Host ""
    
    $scriptPath = Join-Path $projectRoot "scripts\run_pipeline_background.ps1"
    if (-not (Test-Path $scriptPath)) {
        Write-Host "Error: run_pipeline_background.ps1 not found" -ForegroundColor Red
        return $false
    }
    
    $args = @()
    if ($Rules.Count -gt 0) {
        $args += "-Rules"
        $args += $Rules
    }
    if ($NoExport) {
        $args += "-NoExport"
    }
    $args += "-ConfigPath"
    $args += $ConfigPath
    
    Write-Host "Command: .\scripts\run_pipeline_background.ps1 $($args -join ' ')" -ForegroundColor Gray
    Write-Host ""
    
    # Uruchom w osobnym procesie PowerShell (w tle)
    # Buduj argumenty w bezpieczny sposób
    $psArgsList = @("-ExecutionPolicy", "Bypass", "-NoProfile", "-File", $scriptPath)
    
    # Dodaj argumenty z odpowiednim escapowaniem
    foreach ($arg in $args) {
        $psArgsList += $arg
    }
    
    try {
        # Użyj Start-Process z tablicą argumentów
        $proc = Start-Process -FilePath "powershell.exe" `
            -ArgumentList $psArgsList `
            -WindowStyle Hidden `
            -PassThru `
            -ErrorAction Stop
        
        Write-Host "Launched PowerShell process (PID: $($proc.Id))" -ForegroundColor DarkGray
        Write-Host ""
        
        # Krótkie oczekiwanie na utworzenie loga
        Start-Sleep -Seconds 2
        
        # Znajdź najnowszy log TYLKO w active folderze
        $activeLogsPath = Join-Path (Join-Path $projectRoot "data\output") "logs\active"
        if (-not (Test-Path $activeLogsPath)) {
            New-Item -ItemType Directory -Force -Path $activeLogsPath | Out-Null
        }
        
        # Pobierz wszystkie logi w active przed startem jako referencję
        $beforeTime = Get-Date
        $existingLogs = @{}
        if (Test-Path $activeLogsPath) {
            Get-ChildItem -Path $activeLogsPath -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue | 
                ForEach-Object { $existingLogs[$_.FullName] = $_.LastWriteTime }
        }
        
        $latestLog = $null
        $maxWait = 10
        $waited = 0
        
        while ($waited -lt $maxWait) {
            $allLogs = Get-ChildItem -Path $activeLogsPath -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue
            # Znajdź logi, które są nowsze niż przed startem lub mają nowy timestamp
            $newLogs = $allLogs | Where-Object { 
                -not $existingLogs.ContainsKey($_.FullName) -or 
                $_.LastWriteTime -gt $beforeTime
            } | Sort-Object LastWriteTime -Descending
            
            if ($newLogs -and $newLogs.Count -gt 0) {
                $latestLog = $newLogs[0]
                break
            }
            
            Start-Sleep -Milliseconds 500
            $waited += 0.5
        }
        
        # Jeśli nie znaleziono nowego, użyj najnowszego z active
        if (-not $latestLog) {
            $latestLog = Get-ChildItem -Path $activeLogsPath -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue | 
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
        }
        
        if ($latestLog) {
            Write-Host "Agent started successfully!" -ForegroundColor Green
            Write-Host "Log: $($latestLog.FullName)" -ForegroundColor Gray
            Write-Host "Monitor with: .\scripts\monitor_most_recent_agents_markdown_log.ps1" -ForegroundColor Gray
            return $true
        } else {
            Write-Host "Warning: Agent process started (PID: $($proc.Id)) but log not found yet." -ForegroundColor Yellow
            Write-Host "Logs are created in: $((Join-Path (Join-Path $projectRoot "data\output") "logs"))" -ForegroundColor Gray
            Write-Host "Check logs manually or wait a few seconds." -ForegroundColor Gray
            return $true  # Zwróć true, bo proces się uruchomił
        }
    } catch {
        Write-Host "Error starting agent: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-ExistingAgent {
    param([string]$AgentName)
    
    Write-Host "=== Starting Existing Agent ===" -ForegroundColor Cyan
    Write-Host ""
    
    $logs = Get-AgentLogs
    
    if ($logs.Count -eq 0) {
        Write-Host "No agent logs found." -ForegroundColor Red
        return $false
    }
    
    # Znajdź agenta po nazwie (częściowa nazwa lub timestamp)
    $matchingLogs = @()
    foreach ($log in $logs) {
        if ($log.Name -like "*$AgentName*" -or $AgentName -eq "") {
            $matchingLogs += $log
        }
    }
    
    if ($matchingLogs.Count -eq 0) {
        Write-Host "No agent found matching: $AgentName" -ForegroundColor Red
        Write-Host "Available agents:" -ForegroundColor Yellow
        foreach ($log in ($logs | Select-Object -First 10)) {
            Write-Host ("  - {0}" -f $log.Name) -ForegroundColor Gray
        }
        return $false
    }
    
    if ($matchingLogs.Count -gt 1) {
        Write-Host "Multiple agents found matching '$AgentName':" -ForegroundColor Yellow
        for ($i = 0; $i -lt $matchingLogs.Count; $i++) {
            Write-Host ("  [{0}] {1}" -f $i, $matchingLogs[$i].Name) -ForegroundColor Gray
        }
        $choice = Read-Host "Select agent number (0-$($matchingLogs.Count-1))"
        try {
            $idx = [int]$choice
            if ($idx -ge 0 -and $idx -lt $matchingLogs.Count) {
                $selectedLog = $matchingLogs[$idx]
            } else {
                Write-Host "Invalid selection." -ForegroundColor Red
                return $false
            }
        } catch {
            Write-Host "Invalid selection." -ForegroundColor Red
            return $false
        }
    } else {
        $selectedLog = $matchingLogs[0]
    }
    
    Write-Host ("Selected agent: {0}" -f $selectedLog.Name) -ForegroundColor Green
    Write-Host ""
    
    # Odczytaj konfigurację z loga
    $info = Get-AgentInfo -LogFile $selectedLog
    
    if (-not $info.CommandLine) {
        Write-Host "Warning: Could not extract command line from log. Starting with default config." -ForegroundColor Yellow
        return Start-NewAgent
    }
    
    # Wyciągnij parametry z command line
    $rules = @()
    $noExport = $false
    $configPath = "scripts/pipeline_config.json"
    
    if ($info.Rules) {
        $rules = $info.Rules -split '\s+'
    }
    
    if ($info.NoExport) {
        $noExport = $true
    }
    
    Write-Host "Restarting agent with same configuration..." -ForegroundColor Cyan
    Write-Host ("Rules: {0}" -f ($rules -join ', ')) -ForegroundColor Gray
    Write-Host ("NoExport: {0}" -f $noExport) -ForegroundColor Gray
    Write-Host ""
    
    return Start-NewAgent -Rules $rules -NoExport $noExport -ConfigPath $configPath
}

function Stop-Agent {
    param([string]$AgentName)
    
    Write-Host "=== Stopping Agent ===" -ForegroundColor Cyan
    Write-Host ""
    
    $logs = Get-AgentLogs
    
    if ($logs.Count -eq 0) {
        Write-Host "No agent logs found." -ForegroundColor Red
        return $false
    }
    
    # Znajdź uruchomione agenty
    $runningProcs = Get-CimInstance Win32_Process -Filter "Name LIKE 'python%'" -ErrorAction SilentlyContinue | 
        Where-Object { $_.CommandLine -like "*pipeline_runner*" }
    
    if (-not $runningProcs -or $runningProcs.Count -eq 0) {
        Write-Host "No running pipeline processes found." -ForegroundColor Yellow
        return $false
    }
    
    if ($AgentName -eq "") {
        # Pokaż wszystkie i zapytaj
        Write-Host "Running agents:" -ForegroundColor Yellow
        foreach ($proc in $runningProcs) {
            Write-Host ("  PID {0}: {1}" -f $proc.ProcessId, ($proc.CommandLine.Substring(0, [Math]::Min(80, $proc.CommandLine.Length)))) -ForegroundColor Gray
        }
        Write-Host ""
        $pidStr = Read-Host "Enter Process ID to stop (or 'all' to stop all)"
        
        if ($pidStr -eq "all") {
            $procsToStop = $runningProcs
        } else {
            try {
                $pid = [int]$pidStr
                $procsToStop = $runningProcs | Where-Object { $_.ProcessId -eq $pid }
            } catch {
                Write-Host "Invalid PID." -ForegroundColor Red
                return $false
            }
        }
    } else {
        # Znajdź po nazwie (po timestamp w command line)
        $procsToStop = $runningProcs | Where-Object { $_.CommandLine -like "*$AgentName*" }
    }
    
    if (-not $procsToStop -or $procsToStop.Count -eq 0) {
        Write-Host "No matching processes found." -ForegroundColor Red
        return $false
    }
    
    foreach ($proc in $procsToStop) {
        Write-Host ("Stopping PID {0}..." -f $proc.ProcessId) -ForegroundColor Yellow
        try {
            Stop-Process -Id $proc.ProcessId -Force -ErrorAction Stop
            Write-Host ("  Stopped PID {0}" -f $proc.ProcessId) -ForegroundColor Green
        } catch {
            Write-Host ("  Failed to stop PID {0}: {1}" -f $proc.ProcessId, $_.Exception.Message) -ForegroundColor Red
        }
    }
    
    return $true
}

# Main
switch ($Action.ToLower()) {
    "list" {
        List-Agents
    }
    "start" {
        if ($AgentName -eq "") {
            Start-NewAgent -Rules $Rules -NoExport $NoExport -ConfigPath $ConfigPath
        } else {
            Start-ExistingAgent -AgentName $AgentName
        }
    }
    "stop" {
        Stop-Agent -AgentName $AgentName
    }
    "restart" {
        if ($AgentName -eq "") {
            Write-Host "Restart requires agent name." -ForegroundColor Red
            exit 1
        }
        Stop-Agent -AgentName $AgentName | Out-Null
        Start-Sleep -Seconds 2
        Start-ExistingAgent -AgentName $AgentName
    }
    default {
        Write-Host "Usage: .\scripts\manage_agents.ps1 <action> [options]" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Actions:" -ForegroundColor Cyan
        Write-Host "  list              - List all agents (default)"
        Write-Host "  start [name]      - Start new agent or restart existing by name/timestamp"
        Write-Host "  stop [name]       - Stop running agent by name/timestamp or PID"
        Write-Host "  restart [name]   - Restart existing agent"
        Write-Host ""
        Write-Host "Options:" -ForegroundColor Cyan
        Write-Host "  -AgentName        - Agent name/timestamp to find (for start/stop/restart)"
        Write-Host "  -Rules            - Rules to process (for new agent)"
        Write-Host "  -NoExport         - Skip raster export (for new agent)"
        Write-Host "  -ConfigPath       - Path to pipeline config (default: scripts/pipeline_config.json)"
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Cyan
        Write-Host "  .\scripts\manage_agents.ps1 list"
        Write-Host "  .\scripts\manage_agents.ps1 start"
        Write-Host "  .\scripts\manage_agents.ps1 start -AgentName 20251031_162427"
        Write-Host "  .\scripts\manage_agents.ps1 start -AgentName 20251031_162427 -Rules rule1,rule2"
        Write-Host "  .\scripts\manage_agents.ps1 stop"
        Write-Host "  .\scripts\manage_agents.ps1 restart -AgentName 20251031_162427"
    }
}

