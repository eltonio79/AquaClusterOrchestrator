param(
    [string[]]$Rules,
    [switch]$NoExport,
    [string]$ConfigPath = "scripts/pipeline_config.json",
    [string]$ModelPath = "",
    [switch]$SkipModelWait
)

# Background pipeline runner with MD logging (PowerShell 5.1 compatible)

function Read-Config {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "Config not found: $Path" }
    try { return (Get-Content -Raw -Path $Path | ConvertFrom-Json) }
    catch { throw ("Invalid JSON in " + $Path + ": " + $_.Exception.Message) }
}

try {
    $cfg = Read-Config -Path $ConfigPath

    $scriptsDir = "scripts"
    $dataDir = if ($cfg.data_dir) { $cfg.data_dir } else { "data/output" }
    $iexPath = if ($cfg.icm_exchange) { $cfg.icm_exchange } else { "output/ICM_Release.x64/ICMExchange.exe" }

    # Użyj pełnej ścieżki bezwzględnej do folderu active
    $logsDir = Join-Path $dataDir "logs"
    $logsPath = Join-Path $logsDir "active"
    
    # Upewnij się że ścieżka jest bezwzględna
    if (-not ([System.IO.Path]::IsPathRooted($logsPath))) {
        $logsPath = Join-Path (Get-Location) $logsPath
    }
    
    if (-not (Test-Path $logsPath)) { 
        New-Item -ItemType Directory -Force -Path $logsPath | Out-Null 
    }
    
    # Debug: zapisz używaną ścieżkę
    Write-Host "Using logs path: $logsPath" -ForegroundColor DarkGray | Out-Null

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    # Użyj bezwzględnej ścieżki dla loga
    $mdLog = Join-Path $logsPath ("agent_run_" + $stamp + ".md")
    # Upewnij się że ścieżka jest bezwzględna
    if (-not ([System.IO.Path]::IsPathRooted($mdLog))) {
        $mdLog = Join-Path (Get-Location) $mdLog
    }
    $mdLog = [System.IO.Path]::GetFullPath($mdLog)

    "# Background Agent Run" | Set-Content -Encoding UTF8 -Path $mdLog
    ("- Started: " + (Get-Date -Format s)) | Add-Content -Path $mdLog
    ("- Data dir: " + $dataDir) | Add-Content -Path $mdLog
    ("- Scripts dir: " + $scriptsDir) | Add-Content -Path $mdLog
    ("- ICMExchange: " + $iexPath) | Add-Content -Path $mdLog

    # Model handling - either use provided path or wait for .icmm in standalone folder
    "" | Add-Content -Path $mdLog
    "## Model Watch" | Add-Content -Path $mdLog
    
    $finalModelPath = $null
    
    if ($ModelPath -and (Test-Path $ModelPath)) {
        # Use provided model path directly
        $finalModelPath = (Resolve-Path $ModelPath).Path
        ("- Using provided model: " + $finalModelPath) | Add-Content -Path $mdLog
        ("- Model path specified, skipping wait loop") | Add-Content -Path $mdLog
        
        # Update config with model path if needed
        try {
            $configContent = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
            $configContent.model_path = $finalModelPath
            $configContent | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
            ("- Updated config with model path") | Add-Content -Path $mdLog
        } catch {
            ("- Warning: Could not update config: " + $_.Exception.Message) | Add-Content -Path $mdLog
        }
    } elseif ($SkipModelWait) {
        # Skip waiting entirely
        ("- SkipModelWait specified, not waiting for model") | Add-Content -Path $mdLog
    } else {
        # Optional: wait for any .icmm model under .\models\standalone (recursive)
    ("Looking for .icmm under .\\models\\standalone (recursive). Checked every 30s.") | Add-Content -Path $mdLog
    $modelsRoot = Join-Path (Get-Location) "models/standalone"
    $foundModels = @()
    if (Test-Path $modelsRoot) {
        $tries = 0
            $maxTries = 120  # Max 1 hour (120 * 30s)
            while ($tries -lt $maxTries) {
            $foundModels = Get-ChildItem -Path $modelsRoot -Filter "*.icmm" -Recurse -File -ErrorAction SilentlyContinue
            if ($foundModels -and $foundModels.Count -gt 0) { break }
            $tries += 1
                ("- No model found yet (attempt {0}/{1}) at {2}" -f $tries, $maxTries, (Get-Date -Format s)) | Add-Content -Path $mdLog
            Start-Sleep -Seconds 30
        }
            if ($foundModels -and $foundModels.Count -gt 0) {
                $finalModelPath = $foundModels[0].FullName
        ("- Models detected at {0}:" -f (Get-Date -Format s)) | Add-Content -Path $mdLog
        '```log' | Add-Content -Path $mdLog
        $foundModels | ForEach-Object { $_.FullName } | Add-Content -Path $mdLog
        '```' | Add-Content -Path $mdLog
            } else {
                ("- Timeout: No model found after {0} attempts" -f $maxTries) | Add-Content -Path $mdLog
            }
    } else {
        ("- Models root not found: " + $modelsRoot) | Add-Content -Path $mdLog
        }
    }

    $argsList = @()
    if ($Rules) { $argsList += @('--rules'); $argsList += $Rules }
    if ($NoExport) { $argsList += '--no-export' }
    if ($ModelPath -and (Test-Path $ModelPath)) {
        # Ensure absolute path for model path to avoid issues
        if (-not ([System.IO.Path]::IsPathRooted($finalModelPath))) {
            $finalModelPath = (Resolve-Path $finalModelPath).Path
        }
        $argsList += @('--model-path', $finalModelPath)
    }
    if ($SkipModelWait) {
        $argsList += '--skip-model-wait'
    }
    # Ensure absolute paths for directories
    if (-not ([System.IO.Path]::IsPathRooted($scriptsDir))) {
        $scriptsDir = (Resolve-Path $scriptsDir).Path
    }
    if (-not ([System.IO.Path]::IsPathRooted($dataDir))) {
        $dataDir = (Resolve-Path $dataDir).Path
    }
    if (-not ([System.IO.Path]::IsPathRooted($iexPath))) {
        $iexPath = (Resolve-Path $iexPath).Path
    }
    $argsList += @('--scripts-dir', $scriptsDir, '--data-dir', $dataDir, '--icm-exchange', $iexPath)

    "" | Add-Content -Path $mdLog
    "## Command" | Add-Content -Path $mdLog
    "````" | Add-Content -Path $mdLog
    ("python .\scripts\pipeline_runner.py " + ($argsList -join ' ')) | Add-Content -Path $mdLog
    "````" | Add-Content -Path $mdLog

    # Przekaż bezwzględną ścieżkę do ScriptBlock - użyj $mdLog który już jest bezwzględny
    $absMdLog = $mdLog  # Już jest bezwzględna ścieżka
    
    # Create wrapper script content
    $projectRoot = (Get-Location).Path
    $stdoutFile = $absMdLog + ".stdout.tmp"
    $stderrFile = $absMdLog + ".stderr.tmp"
    
    # Build command line string for cmd.exe to handle spaces properly
    $allArgs = @('scripts\pipeline_runner.py') + $argsList
    # Escape each argument for cmd.exe - arguments with spaces need double quotes
    $cmdArgs = $allArgs | ForEach-Object {
        $arg = $_
        # If argument contains spaces, wrap in double quotes and escape internal quotes
        if ($arg -match ' ') {
            $escaped = $arg -replace '"', '""'
            "`"$escaped`""
        } else {
            $arg
        }
    }
    $cmdLine = ($cmdArgs -join ' ')
    $cmdLineEscaped = $cmdLine -replace "'", "''"
    
    $wrapperContent = @"
Set-Location '$projectRoot'
`$ErrorActionPreference = 'Continue'
try {
    "" | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    "## Python stdout" | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    '```log' | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    
    # Use cmd.exe to properly handle arguments with spaces
    `$cmdLine = '$cmdLineEscaped'
    `$proc = Start-Process -FilePath 'cmd.exe' -ArgumentList "/c", "python `$cmdLine" -WorkingDirectory '$projectRoot' -NoNewWindow -PassThru -RedirectStandardOutput '$stdoutFile' -RedirectStandardError '$stderrFile' -Wait
    
    Get-Content '$stdoutFile' -ErrorAction SilentlyContinue | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    '```' | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    "" | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    "## Python stderr" | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    '```log' | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    Get-Content '$stderrFile' -ErrorAction SilentlyContinue | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    '```' | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    "" | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    ("- Exit: " + `$proc.ExitCode) | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    ("- Finished: " + (Get-Date -Format s)) | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
    
    Remove-Item '$stdoutFile' -ErrorAction SilentlyContinue
    Remove-Item '$stderrFile' -ErrorAction SilentlyContinue
} catch {
    ("## Agent Error`n" + `$_.Exception.Message) | Out-File -FilePath '$absMdLog' -Append -Encoding UTF8
}
"@
    
    # Save wrapper script
    $psScript = Join-Path ([System.IO.Path]::GetTempPath()) "pipeline_runner_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
    $wrapperContent | Set-Content -Path $psScript -Encoding UTF8
    
    # Start background PowerShell process - non-blocking
    $proc = Start-Process -FilePath "powershell.exe" `
        -ArgumentList @("-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", $psScript) `
        -PassThru `
        -ErrorAction Stop
    
    ("- ProcessId: " + $proc.Id) | Add-Content -Path $mdLog
    ("- Wrapper script: " + $psScript) | Add-Content -Path $mdLog
    ("- Supervision log: " + $mdLog) | Add-Content -Path $mdLog

    Write-Host ("Started background process PID=" + $proc.Id + ". MD log: " + $mdLog) -ForegroundColor Green
    Write-Host "Process runs independently - check log for progress" -ForegroundColor DarkGray
    
    # Exit immediately to prevent connection issues
    # Job runs independently in background
    exit 0
}
catch {
    $errorMsg = "Background start failed: " + $_.Exception.Message
    Write-Host $errorMsg -ForegroundColor Red
    # Try to log error if possible
    try {
        if (Test-Path variable:mdLog) {
            ("## Fatal Error`n" + $errorMsg) | Add-Content -Path $mdLog -ErrorAction SilentlyContinue
        }
    } catch {
        # Ignore - can't even write error log
    }
    exit 1
}


