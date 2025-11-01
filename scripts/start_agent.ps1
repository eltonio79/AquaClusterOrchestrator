# Script to start an agent via delegation or direct execution
# Usage: 
#   Delegation: .\scripts\start_agent.ps1 -AgentName "raster_monitor" -Instructions "Implement and start the raster monitor agent"
#   Direct:     .\scripts\start_agent.ps1 -AgentName "raster_monitor" -Direct

param(
    [Parameter(Mandatory=$true)]
    [string]$AgentName,
    
    [string]$Instructions = "",
    [string]$ScriptPath = "",
    [string[]]$ScriptArguments = @(),
    [switch]$Direct,
    [switch]$WaitForCompletion,
    [string]$Priority = "normal"
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

# Agent name to script mapping
$agentScripts = @{
    "raster_monitor" = "scripts\monitor_rasters.ps1"
    "experiment_monitor" = "scripts\monitor_experiments.ps1"
    "cleanup" = "scripts\cleanup_agent.ps1"
    "validation" = "scripts\validation_agent.ps1"
    "git_tracking" = "scripts\git_tracking_agent.ps1"
    "health_check" = "scripts\health_check_agent.ps1"
    "results_analyzer" = "scripts\results_analyzer_agent.ps1"
}

# Agent display names
$agentDisplayNames = @{
    "raster_monitor" = "Raster Monitor Agent"
    "experiment_monitor" = "Experiment Monitor Agent"
    "cleanup" = "Cleanup Agent"
    "validation" = "Validation Agent"
    "git_tracking" = "Git Tracking Agent"
    "health_check" = "Health Check Agent"
    "results_analyzer" = "Results Analyzer Agent"
}

if (-not $agentScripts.ContainsKey($AgentName)) {
    Write-Host "Error: Unknown agent name '$AgentName'" -ForegroundColor Red
    Write-Host "Available agents:" -ForegroundColor Yellow
    $agentScripts.Keys | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    exit 1
}

$displayName = $agentDisplayNames[$AgentName]
$agentScriptPath = $agentScripts[$AgentName]

# Determine execution mode
$useDirectExecution = $false
if ($Direct) {
    $useDirectExecution = $true
} elseif (Test-Path $agentScriptPath) {
    # If script exists, use direct execution by default
    $useDirectExecution = $true
    Write-Host "Agent script found, using direct execution mode" -ForegroundColor Green
}

if ($useDirectExecution) {
    # Direct execution mode
    Write-Host "Starting $displayName in direct execution mode..." -ForegroundColor Cyan
    
    if (-not (Test-Path $agentScriptPath)) {
        Write-Host "Error: Agent script not found: $agentScriptPath" -ForegroundColor Red
        Write-Host "Falling back to delegation mode..." -ForegroundColor Yellow
        $useDirectExecution = $false
    } else {
        # Update agent status to running
        & ".\scripts\update_agent_status.ps1" -AgentName $AgentName -Status "running" -ErrorAction SilentlyContinue
        
        # Start the agent script
        if ($ScriptArguments.Count -gt 0) {
            $process = Start-Process powershell.exe -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-File", (Resolve-Path $agentScriptPath),
                @($ScriptArguments)
            ) -PassThru -WindowStyle Minimized
        } else {
            $process = Start-Process powershell.exe -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-File", (Resolve-Path $agentScriptPath)
            ) -PassThru -WindowStyle Minimized
        }
        
        # Update status with PID
        & ".\scripts\update_agent_status.ps1" -AgentName $AgentName -Status "running" -Pid $process.Id -ErrorAction SilentlyContinue
        
        Write-Host "Agent started with PID: $($process.Id)" -ForegroundColor Green
        Write-Host "Script: $agentScriptPath" -ForegroundColor Gray
        
        if ($WaitForCompletion) {
            Write-Host "Waiting for agent to complete..." -ForegroundColor Yellow
            $process.WaitForExit()
            $exitCode = $process.ExitCode
            & ".\scripts\update_agent_status.ps1" -AgentName $AgentName -Status "idle" -ErrorAction SilentlyContinue
            Write-Host "Agent completed with exit code: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })
        } else {
            Write-Host "Agent running in background. Use update_agent_status.ps1 to check status." -ForegroundColor Gray
        }
    }
}

if (-not $useDirectExecution) {
    # Delegation mode (default)
    Write-Host "Starting $displayName in delegation mode..." -ForegroundColor Cyan
    
    # Default instructions if not provided
    if ([string]::IsNullOrWhiteSpace($Instructions)) {
        $Instructions = "Implement and start the $displayName. Follow the instructions in tasks/agents/$($AgentName.Replace('_', '_')).md"
    }
    
    # Use existing delegation script
    & ".\scripts\delegate_task_to_agent.ps1" `
        -TaskName "start_$AgentName" `
        -Instructions $Instructions `
        -ScriptPath $agentScriptPath `
        -ScriptArguments $ScriptArguments `
        -Priority $Priority `
        -WaitForCompletion:$WaitForCompletion
}

