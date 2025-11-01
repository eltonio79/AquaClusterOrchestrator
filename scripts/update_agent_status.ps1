# Script to update and query agent status
# Usage:
#   Update: .\scripts\update_agent_status.ps1 -AgentName "raster_monitor" -Status "running" -ProcessId 12345
#   Query:  .\scripts\update_agent_status.ps1 -AgentName "raster_monitor"
#   List:   .\scripts\update_agent_status.ps1 -ListAvailable

param(
    [string]$AgentName,
    [ValidateSet("idle", "running", "error")]
    [string]$Status,
    [int]$ProcessId,
    [string]$CurrentTask,
    [string]$LogFile,
    [switch]$ListAvailable,
    [switch]$GetStatus
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
    
    return Get-Location
}

$projectRoot = Get-ProjectRoot
Set-Location $projectRoot

$statusFile = Join-Path $projectRoot "data\output\config\agent_status.json"
$configDir = Split-Path $statusFile -Parent

# Ensure config directory exists
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
}

# Initialize status structure if file doesn't exist
if (-not (Test-Path $statusFile)) {
    $statusData = @{
        agents = @{}
        tasks = @{}
        available_agents = @()
        timestamp = (Get-Date).ToString("o")
    }
    $statusData | ConvertTo-Json -Depth 10 | Set-Content -Path $statusFile -Encoding UTF8
}

# Load current status (using different variable name to avoid conflict with $Status parameter)
$statusData = Get-Content -Raw -Path $statusFile | ConvertFrom-Json

# List available agents
if ($ListAvailable) {
    $available = @()
    $statusData.PSObject.Properties.Name | ForEach-Object {
        if ($_ -eq "agents") {
            $statusData.agents.PSObject.Properties | ForEach-Object {
                $agentName = $_.Name
                $agentStatus = $_.Value
                if ($agentStatus.status -eq "idle") {
                    $available += $agentName
                }
            }
        }
    }
    Write-Host "Available (idle) agents: $($available.Count)" -ForegroundColor Green
    if ($available.Count -gt 0) {
        $available | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    }
    return
}

# Get status for specific agent
if ($GetStatus -and $AgentName) {
    if ($statusData.agents.PSObject.Properties.Name -contains $AgentName) {
        $agent = $statusData.agents.$AgentName
        Write-Host "Agent: $AgentName" -ForegroundColor Cyan
        Write-Host "  Status: $($agent.status)" -ForegroundColor $(switch($agent.status) { "idle" {"Green"} "running" {"Yellow"} "error" {"Red"} default {"Gray"}})
        if ($agent.last_activity) { Write-Host "  Last Activity: $($agent.last_activity)" -ForegroundColor Gray }
        if ($agent.current_task) { Write-Host "  Current Task: $($agent.current_task)" -ForegroundColor Gray }
        if ($agent.pid) { Write-Host "  PID: $($agent.pid)" -ForegroundColor Gray }
        if ($agent.log_file) { Write-Host "  Log File: $($agent.log_file)" -ForegroundColor Gray }
    } else {
        Write-Host "Agent '$AgentName' not found in status" -ForegroundColor Yellow
    }
    return
}

# Update agent status
if ($AgentName -and $Status) {
    if (-not $statusData.agents.PSObject.Properties.Name -contains $AgentName) {
        $statusData.agents | Add-Member -MemberType NoteProperty -Name $AgentName -Value @{
            status = "idle"
            last_activity = $null
            current_task = $null
            pid = $null
            log_file = $null
        }
    }
    
    $agent = $statusData.agents.$AgentName
    $agent.status = $Status
    $agent.last_activity = (Get-Date).ToString("o")
    
    if ($PSBoundParameters.ContainsKey('ProcessId')) {
        $agent.pid = $ProcessId
    }
    
    if ($PSBoundParameters.ContainsKey('CurrentTask')) {
        $agent.current_task = $CurrentTask
    }
    
    if ($PSBoundParameters.ContainsKey('LogFile')) {
        $agent.log_file = $LogFile
    }
    
    # Update available agents list
    $available = @()
    $statusData.agents.PSObject.Properties | ForEach-Object {
        if ($_.Value.status -eq "idle") {
            $available += $_.Name
        }
    }
    $statusData.available_agents = $available
    
    $statusData.timestamp = (Get-Date).ToString("o")
    
    # Save status
    $statusData | ConvertTo-Json -Depth 10 | Set-Content -Path $statusFile -Encoding UTF8
    
    Write-Host "Agent status updated: $AgentName = $Status" -ForegroundColor Green
}

# Update task status
if ($PSBoundParameters.ContainsKey('TaskId') -and $PSBoundParameters.ContainsKey('TaskStatus')) {
    if (-not $statusData.tasks.PSObject.Properties.Name -contains $TaskId) {
        $statusData.tasks | Add-Member -MemberType NoteProperty -Name $TaskId -Value @{
            status = "pending"
            assigned_to = $null
            started = $null
            completed = $null
        }
    }
    
    $task = $statusData.tasks.$TaskId
    $task.status = $TaskStatus
    
    if ($TaskStatus -eq "in_progress" -and -not $task.started) {
        $task.started = (Get-Date).ToString("o")
        if ($AgentName) {
            $task.assigned_to = $AgentName
        }
    }
    
    if ($TaskStatus -eq "completed" -or $TaskStatus -eq "failed") {
        $task.completed = (Get-Date).ToString("o")
    }
    
    $statusData.timestamp = (Get-Date).ToString("o")
    $statusData | ConvertTo-Json -Depth 10 | Set-Content -Path $statusFile -Encoding UTF8
    
    Write-Host "Task status updated: $TaskId = $TaskStatus" -ForegroundColor Green
}

