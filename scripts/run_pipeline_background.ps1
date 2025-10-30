param(
    [string[]]$Rules,
    [switch]$NoExport,
    [string]$ConfigPath = "scripts/pipeline_config.json"
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

    $logsPath = Join-Path $dataDir "logs"
    if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Force -Path $logsPath | Out-Null }

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $mdLog = Join-Path $logsPath ("agent_run_" + $stamp + ".md")

    "# Background Agent Run" | Set-Content -Encoding UTF8 -Path $mdLog
    ("- Started: " + (Get-Date -Format s)) | Add-Content -Path $mdLog
    ("- Data dir: " + $dataDir) | Add-Content -Path $mdLog

    $argsList = @()
    if ($Rules) { $argsList += @('--rules'); $argsList += $Rules }
    if ($NoExport) { $argsList += '--no-export' }
    $argsList += @('--scripts-dir', $scriptsDir, '--data-dir', $dataDir, '--icm-exchange', $iexPath)

    "" | Add-Content -Path $mdLog
    "## Command" | Add-Content -Path $mdLog
    "````" | Add-Content -Path $mdLog
    ("python .\scripts\pipeline_runner.py " + ($argsList -join ' ')) | Add-Content -Path $mdLog
    "````" | Add-Content -Path $mdLog

    $job = Start-Job -Name "cluster-pipeline" -ScriptBlock {
        param($alist, $md)
        try {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = "python"
            $psi.Arguments = ".\scripts\pipeline_runner.py " + ($alist -join ' ')
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.UseShellExecute = $false
            $psi.CreateNoWindow = $true
            $proc = New-Object System.Diagnostics.Process
            $proc.StartInfo = $psi
            $null = $proc.Start()
            $out = $proc.StandardOutput.ReadToEnd()
            $err = $proc.StandardError.ReadToEnd()
            $proc.WaitForExit()
            "" | Add-Content -Path $md
            "## Console Output" | Add-Content -Path $md
            "````" | Add-Content -Path $md
            $out | Add-Content -Path $md
            "`````n## Console Errors" | Add-Content -Path $md
            "````" | Add-Content -Path $md
            $err | Add-Content -Path $md
            "`````n- Exit: " + $proc.ExitCode | Add-Content -Path $md
        } catch {
            ("## Agent Error`n" + $_.Exception.Message) | Add-Content -Path $md
        }
    } -ArgumentList ($argsList, $mdLog)

    ("- JobId: " + $job.Id) | Add-Content -Path $mdLog
    ("- Supervision log: " + $mdLog) | Add-Content -Path $mdLog

    Write-Host ("Started background job Id=" + $job.Id + ". MD log: " + $mdLog) -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ("Background start failed: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}


