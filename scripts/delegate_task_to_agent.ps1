# Script to delegate tasks to another Cursor agent via task file
# Usage: .\scripts\delegate_task_to_agent.ps1 -TaskName "cleanup_logs" -Instructions "Run cleanup script and report results"

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskName,
    
    [Parameter(Mandatory=$true)]
    [string]$Instructions,
    
    [string]$ScriptPath = "",
    [string[]]$ScriptArguments = @(),
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
$tasksDir = Join-Path $projectRoot "tasks"
if (-not (Test-Path $tasksDir)) {
    New-Item -ItemType Directory -Force -Path $tasksDir | Out-Null
}

# Utwórz plik zadania dla drugiego agenta
$taskId = [guid]::NewGuid().ToString()
$taskFile = Join-Path $tasksDir "task_$TaskName`_$taskId.json"

$task = @{
    TaskId = $taskId
    TaskName = $TaskName
    Created = (Get-Date).ToString("o")
    Priority = $Priority
    Status = "pending"
    Instructions = $Instructions
    ScriptPath = $ScriptPath
    ScriptArguments = $ScriptArguments
    Result = $null
    Completed = $null
} | ConvertTo-Json -Depth 10

$task | Set-Content -Path $taskFile -Encoding UTF8

Write-Host "Task delegated to another agent!" -ForegroundColor Green
Write-Host "Task file: $taskFile" -ForegroundColor Gray
Write-Host "Task ID: $taskId" -ForegroundColor Gray
Write-Host ""
Write-Host "Instructions for the other agent:" -ForegroundColor Cyan
Write-Host "1. Read the task file: $taskFile" -ForegroundColor Yellow
Write-Host "2. Follow the instructions: $Instructions" -ForegroundColor Yellow
if ($ScriptPath) {
    Write-Host "3. Execute: $ScriptPath $($ScriptArguments -join ' ')" -ForegroundColor Yellow
    Write-Host "4. Update task file with results" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "You can check task status by reading: $taskFile" -ForegroundColor Gray

if ($WaitForCompletion) {
    Write-Host "Waiting for task completion..." -ForegroundColor Yellow
    while ($true) {
        Start-Sleep -Seconds 2
        if (Test-Path $taskFile) {
            try {
                $currentTask = Get-Content $taskFile -Raw | ConvertFrom-Json
                if ($currentTask.Status -eq "completed" -or $currentTask.Status -eq "failed") {
                    Write-Host "Task completed with status: $($currentTask.Status)" -ForegroundColor $(if ($currentTask.Status -eq "completed") { "Green" } else { "Red" })
                    if ($currentTask.Result) {
                        Write-Host "Result: $($currentTask.Result)" -ForegroundColor Gray
                    }
                    break
                }
            } catch {
                # Ignoruj błędy parsowania
            }
        }
    }
}

return @{
    TaskId = $taskId
    TaskFile = $taskFile
}

