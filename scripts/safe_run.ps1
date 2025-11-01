# Safe wrapper for running commands with timeout and error handling
# Usage: .\scripts\safe_run.ps1 -Command "python script.py" -TimeoutSeconds 300 -ErrorAction Continue

param(
    [Parameter(Mandatory=$true)]
    [string]$Command,
    
    [int]$TimeoutSeconds = 3600,
    
    [string]$OutputFile = "",
    
    [ValidateSet('Stop', 'Continue', 'SilentlyContinue')]
    [string]$ErrorAction = 'Continue'
)

function Safe-RunCommand {
    param(
        [string]$Cmd,
        [int]$Timeout,
        [string]$LogFile,
        [string]$ErrAction
    )
    
    $result = @{
        Success = $false
        ExitCode = -1
        Output = ""
        Error = ""
    }
    
    try {
        if ($LogFile) {
            # Run with output redirection to file
            $process = Start-Process -FilePath "powershell.exe" `
                -ArgumentList @("-NoProfile", "-NonInteractive", "-Command", $Cmd) `
                -NoNewWindow `
                -RedirectStandardOutput $LogFile `
                -RedirectStandardError ($LogFile -replace '\.log$', '.err.log') `
                -PassThru `
                -ErrorAction Stop
            
            # Wait with timeout
            $completed = $process.WaitForExit($Timeout * 1000)
            
            if (-not $completed) {
                # Timeout - kill process
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                $result.Error = "Command timed out after $Timeout seconds"
                return $result
            }
            
            $result.ExitCode = $process.ExitCode
            $result.Success = $process.ExitCode -eq 0
            
            # Read output from log file if it exists
            if (Test-Path $LogFile) {
                $result.Output = Get-Content $LogFile -Raw -ErrorAction SilentlyContinue
            }
        } else {
            # Run without file output
            $output = & powershell.exe -NoProfile -NonInteractive -Command $Cmd 2>&1
            $result.ExitCode = $LASTEXITCODE
            $result.Success = $LASTEXITCODE -eq 0
            $result.Output = $output | Out-String
        }
        
    } catch {
        $result.Error = $_.Exception.Message
        $result.Success = $false
    }
    
    return $result
}

# Run the command
$result = Safe-RunCommand -Cmd $Command -Timeout $TimeoutSeconds -LogFile $OutputFile -ErrAction $ErrorAction

if (-not $result.Success -and $ErrorAction -eq 'Stop') {
    Write-Host "Error: $($result.Error)" -ForegroundColor Red
    exit $result.ExitCode
} elseif ($result.Error) {
    Write-Host "Warning: $($result.Error)" -ForegroundColor Yellow
}

return $result

