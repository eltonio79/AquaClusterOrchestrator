# Test script dla monitor_most_recent_agents_markdown_log.ps1
Write-Host "=== Test monitor_most_recent_agents_markdown_log.ps1 ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Sprawdź czy skrypt znajduje projekt root
Write-Host "Test 1: Sprawdzanie wykrywania projektu..." -ForegroundColor Yellow
$scriptPath = ".\scripts\monitor_most_recent_agents_markdown_log.ps1"
if (-not (Test-Path $scriptPath)) {
    Write-Host "  ERROR: Skrypt nie istnieje: $scriptPath" -ForegroundColor Red
    exit 1
}
Write-Host "  OK: Skrypt istnieje" -ForegroundColor Green

# Test 2: Sprawdź strukturę folderów
Write-Host "`nTest 2: Sprawdzanie struktury folderów..." -ForegroundColor Yellow
$expectedLogsPath = ".\data\output\logs"
if (Test-Path $expectedLogsPath) {
    Write-Host "  OK: Folder logów istnieje: $expectedLogsPath" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Folder logów nie istnieje: $expectedLogsPath" -ForegroundColor Yellow
}

# Test 3: Sprawdź czy są logi agentów
Write-Host "`nTest 3: Sprawdzanie logów agentów..." -ForegroundColor Yellow
if (Test-Path $expectedLogsPath) {
    $agentLogs = Get-ChildItem -Path $expectedLogsPath -Filter "agent_run_*.md" -File -ErrorAction SilentlyContinue
    if ($agentLogs) {
        Write-Host "  OK: Znaleziono $($agentLogs.Count) logów agentów" -ForegroundColor Green
        Write-Host "  Najnowszy log: $($agentLogs | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | ForEach-Object { $_.Name + ' (' + $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss') + ')' })" -ForegroundColor Gray
    } else {
        Write-Host "  WARNING: Brak logów agentów" -ForegroundColor Yellow
    }
} else {
    Write-Host "  SKIP: Folder logów nie istnieje" -ForegroundColor Gray
}

# Test 4: Symulacja Get-ProjectRoot (z folderu scripts)
Write-Host "`nTest 4: Test Get-ProjectRoot z folderu scripts..." -ForegroundColor Yellow
$scriptsTestPath = Join-Path (Get-Location) "scripts"
if (Test-Path $scriptsTestPath) {
    Push-Location $scriptsTestPath
    try {
        # Wykonaj funkcję Get-ProjectRoot
        $testScript = Get-Content ".\monitor_most_recent_agents_markdown_log.ps1" -Raw
        $scriptBlock = [ScriptBlock]::Create($testScript)
        
        # Wykonaj tylko część z Get-ProjectRoot
        $projectRoot = $null
        $currentPath = $PSScriptRoot
        if (-not $currentPath) {
            $currentPath = Get-Location
        }
        
        $checkPath = $currentPath
        $found = $false
        while ($checkPath -and $checkPath.Length -gt 3) {
            $gitMarker = Join-Path $checkPath ".git"
            $pathsMarker = Join-Path $checkPath "paths.txt"
            $dataMarker = Join-Path $checkPath "data"
            
            if ((Test-Path $gitMarker) -or (Test-Path $pathsMarker) -or (Test-Path $dataMarker)) {
                $projectRoot = $checkPath
                $found = $true
                break
            }
            
            $checkPath = Split-Path -Parent $checkPath
        }
        
        if ($found) {
            Write-Host "  OK: Projekt root wykryty: $projectRoot" -ForegroundColor Green
            $testLogsPath = Join-Path $projectRoot "data\output\logs"
            if (Test-Path $testLogsPath) {
                Write-Host "  OK: Ścieżka do logów poprawna: $testLogsPath" -ForegroundColor Green
            } else {
                Write-Host "  WARNING: Ścieżka do logów nie istnieje: $testLogsPath" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  WARNING: Nie znaleziono projektu root" -ForegroundColor Yellow
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "  SKIP: Folder scripts nie istnieje" -ForegroundColor Gray
}

# Test 5: Sprawdź czy lock file działa
Write-Host "`nTest 5: Test lock file..." -ForegroundColor Yellow
$lockFile = Join-Path $expectedLogsPath ".monitor_lock.txt"
if (Test-Path $lockFile) {
    Write-Host "  INFO: Lock file istnieje (może być z poprzedniego uruchomienia)" -ForegroundColor Cyan
    try {
        $content = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $lines = $content -split "`n" | Where-Object { $_.Trim() }
            Write-Host "  Znaleziono $($lines.Count) wpis(ów) w lock file" -ForegroundColor Gray
            foreach ($line in $lines) {
                try {
                    $lockData = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
                    if ($lockData -and $lockData.PID) {
                        $proc = Get-Process -Id $lockData.PID -ErrorAction SilentlyContinue
                        if ($proc) {
                            Write-Host "    PID $($lockData.PID): ACTIVE (monitoring: $($lockData.MonitoringFile))" -ForegroundColor Green
                        } else {
                            Write-Host "    PID $($lockData.PID): DEAD (stary lock)" -ForegroundColor Yellow
                        }
                    }
                } catch {
                    Write-Host "    Nieprawidłowy format linii" -ForegroundColor Red
                }
            }
        }
    } catch {
        Write-Host "  ERROR: Nie można odczytać lock file: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  OK: Brak lock file (żaden monitor nie działa)" -ForegroundColor Green
}

Write-Host "`n=== Test zakończony ===" -ForegroundColor Cyan

