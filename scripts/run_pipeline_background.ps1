param(
    [string[]]$Rules,
    [switch]$NoExport,
    [string]$ConfigPath = "scripts/pipeline_config.json"
)

# Runs the pipeline in the background and logs output. The Python pipeline also writes a MD log.

function Read-Config {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "Config not found: $Path" }
    return (Get-Content -Raw -Path $Path | ConvertFrom-Json)
}

$cfg = Read-Config -Path $ConfigPath

$scriptsDir = "scripts"
$dataDir    = if ($cfg.data_dir) { $cfg.data_dir } else { "data/output" }
$iexPath    = if ($cfg.icm_exchange) { $cfg.icm_exchange } else { "output/ICM_Release.x64/ICMExchange.exe" }

New-Item -ItemType Directory -Force -Path "$dataDir/logs" | Out-Null
$mdLog = Join-Path "$dataDir/logs" ("agent_run_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".md")

"# Background Agent Run`n- Started: $(Get-Date -Format s)" | Set-Content -Encoding UTF8 -Path $mdLog

$argsList = @()
if ($Rules) { $argsList += @('--rules'); $argsList += $Rules }
if ($NoExport) { $argsList += '--no-export' }
$argsList += @('--scripts-dir', $scriptsDir, '--data-dir', $dataDir, '--icm-exchange', $iexPath)

"`n## Command`n````
python .\scripts\pipeline_runner.py $($argsList -join ' ')
````" | Add-Content -Path $mdLog

Start-Job -Name "cluster-pipeline" -ScriptBlock {
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
        "`n## Console Output`n````
$out
`````n## Console Errors`n````
$err
`````n- Exit: $($proc.ExitCode)" | Add-Content -Path $md
    } catch {
        "`n## Agent Error`n$($_.Exception.Message)" | Add-Content -Path $md
    }
} -ArgumentList ($argsList, $mdLog) | Out-Null

Write-Host "Started background job 'cluster-pipeline'." -ForegroundColor Green
Write-Host "MD log: $mdLog" -ForegroundColor Gray

# Run pipeline in background and log progress

param(
    [string[]]$Rules,
    [switch]$NoExport,
    [string]$ConfigPath = "scripts/pipeline_config.json"
)

function Load-Config($path) {
    if (-not (Test-Path $path)) { throw "Config not found: $path" }
    try { return Get-Content $path -Raw | ConvertFrom-Json } catch { throw "Invalid JSON in $path: $($_.Exception.Message)" }
}

try {
    $cfg = Load-Config $ConfigPath
    $dataDir = $cfg.data_dir
    if (-not $dataDir) { $dataDir = "data/output" }
    $logsDir = Join-Path $dataDir "logs"
    if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }

    $stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $mdLog = Join-Path $logsDir "background_run_${stamp}.md"

    "# Background Pipeline Run`n- Started: $(Get-Date -Format s)`n- Data dir: `$dataDir`" | Set-Content -Path $mdLog -Encoding UTF8

    $args = @()
    if ($Rules) { $args += @('--rules') + $Rules }
    if ($NoExport) { $args += '--no-export' }
    $args += @('--scripts-dir', 'scripts', '--data-dir', $dataDir, '--icm-exchange', $cfg.icm_exchange)

    Add-Content -Path $mdLog -Value ("- Command: python .\\scripts\\pipeline_runner.py " + ($args -join ' '))

    $job = Start-Job -ScriptBlock {
        param($pyArgs)
        python ".\scripts\pipeline_runner.py" @pyArgs 2>&1
    } -ArgumentList (, $args)

    Add-Content -Path $mdLog -Value ("- JobId: $($job.Id)")
    Add-Content -Path $mdLog -Value ("- You can check detailed pipeline MD logs in `$dataDir\\logs`")

    Write-Host "Started background job Id=$($job.Id). Supervision log: $mdLog" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "Background start failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


