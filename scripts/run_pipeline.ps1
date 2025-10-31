# PowerShell wrapper for the cluster analysis pipeline
# Sets up environment and calls pipeline_runner.py with parameters

param(
    [string[]]$Rules,
    [switch]$NoExport,
    [switch]$ListRules,
    [string]$ScriptsDir = "scripts",
    [string]$DataDir = "data/output",
    [string]$ICMExchange = "output/ICM_Release.x64/ICMExchange.exe",
    [switch]$Help
)

# Show help if requested
if ($Help) {
    Write-Host "Cluster Analysis Pipeline - PowerShell Wrapper" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\run_pipeline.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -Rules <rule1,rule2,...>  Process specific rules (default: all rules)" -ForegroundColor White
    Write-Host "  -NoExport                Skip raster export step" -ForegroundColor White
    Write-Host "  -ListRules               List available rules" -ForegroundColor White
    Write-Host "  -ScriptsDir <path>       Scripts directory (default: scripts)" -ForegroundColor White
    Write-Host "  -DataDir <path>          Data output directory (default: data/output)" -ForegroundColor White
    Write-Host "  -ICMExchange <path>      Path to ICMExchange executable" -ForegroundColor White
    Write-Host "  -Help                    Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\run_pipeline.ps1                                    # Process all rules" -ForegroundColor White
    Write-Host "  .\run_pipeline.ps1 -Rules depth_change_analysis      # Process specific rule" -ForegroundColor White
    Write-Host "  .\run_pipeline.ps1 -ListRules                        # List available rules" -ForegroundColor White
    Write-Host "  .\run_pipeline.ps1 -NoExport                         # Skip export, process existing data" -ForegroundColor White
    exit 0
}

# Function to check if Python is available
function Test-Python {
    try {
        $pythonVersion = python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Python found: $pythonVersion" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Python not found in PATH" -ForegroundColor Red
        return $false
    }
    return $false
}

# Function to check if required Python packages are available
function Test-PythonPackages {
    $requiredPackages = @(
        "numpy",
        "rasterio", 
        "matplotlib",
        "scikit-learn",
        "scipy",
        "pandas",
        "pillow",
        "imageio",
        "shapely"
    )
    
    $missingPackages = @()
    
    foreach ($package in $requiredPackages) {
        try {
            python -c "import $package" 2>$null
            if ($LASTEXITCODE -ne 0) {
                $missingPackages += $package
            }
        }
        catch {
            $missingPackages += $package
        }
    }
    
    if ($missingPackages.Count -gt 0) {
        Write-Host "Missing Python packages: $($missingPackages -join ', ')" -ForegroundColor Red
        Write-Host "Please install missing packages using: pip install $($missingPackages -join ' ')" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "All required Python packages are available" -ForegroundColor Green
    return $true
}

# Function to check if ICMExchange exists
function Test-ICMExchange {
    if (Test-Path $ICMExchange) {
        Write-Host "ICMExchange found: $ICMExchange" -ForegroundColor Green
        return $true
    } else {
        Write-Host "ICMExchange not found: $ICMExchange" -ForegroundColor Red
        Write-Host "Please check the path to ICMExchange executable" -ForegroundColor Yellow
        return $false
    }
}

# Function to create virtual environment if needed
function Setup-VirtualEnvironment {
    $venvPath = "venv"
    
    if (-not (Test-Path $venvPath)) {
        Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
        python -m venv $venvPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to create virtual environment" -ForegroundColor Red
            return $false
        }
    }
    
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    & "$venvPath\Scripts\Activate.ps1"
    
    # Install required packages
    Write-Host "Installing/updating required packages..." -ForegroundColor Yellow
    $packages = @(
        "numpy",
        "rasterio",
        "matplotlib", 
        "scikit-learn",
        "scipy",
        "pandas",
        "pillow",
        "imageio",
        "shapely"
    )
    
    foreach ($package in $packages) {
        pip install $package --quiet
    }
    
    return $true
}

# Function to update paths.txt
function Update-Paths {
    Write-Host "Updating paths.txt..." -ForegroundColor Yellow
    try {
        & ".\scripts\dir.bat"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "paths.txt updated successfully" -ForegroundColor Green
        } else {
            Write-Host "Warning: Could not update paths.txt" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Warning: Could not run dir.bat to update paths.txt" -ForegroundColor Yellow
    }
}

# Main execution
try {
    Write-Host "=== Cluster Analysis Pipeline ===" -ForegroundColor Green
    Write-Host "Starting pipeline execution..." -ForegroundColor Yellow
    
    # Check prerequisites
    Write-Host "`nChecking prerequisites..." -ForegroundColor Cyan
    
    if (-not (Test-Python)) {
        Write-Host "Python is required but not found. Please install Python 3.8+ and add it to PATH." -ForegroundColor Red
        exit 1
    }
    
    if (-not (Test-PythonPackages)) {
        Write-Host "Some required Python packages are missing." -ForegroundColor Red
        $response = Read-Host "Would you like to set up a virtual environment and install packages? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            if (-not (Setup-VirtualEnvironment)) {
                Write-Host "Failed to set up virtual environment" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "Please install the missing packages manually and try again." -ForegroundColor Red
            exit 1
        }
    }
    
    if (-not $NoExport -and -not (Test-ICMExchange)) {
        Write-Host "ICMExchange not found. Please check the path or use -NoExport to skip raster export." -ForegroundColor Red
        exit 1
    }
    
    # Build command arguments
    $pythonArgs = @()
    
    if ($Rules) {
        $pythonArgs += "--rules"
        $pythonArgs += $Rules
    }
    
    if ($NoExport) {
        $pythonArgs += "--no-export"
    }
    
    if ($ListRules) {
        $pythonArgs += "--list-rules"
    }
    
    $pythonArgs += "--scripts-dir"
    $pythonArgs += $ScriptsDir
    
    $pythonArgs += "--data-dir" 
    $pythonArgs += $DataDir
    
    $pythonArgs += "--icm-exchange"
    $pythonArgs += $ICMExchange
    
    # Run the Python pipeline
    Write-Host "`nRunning Python pipeline..." -ForegroundColor Cyan
    Write-Host "Command: python .\scripts\pipeline_runner.py $($pythonArgs -join ' ')" -ForegroundColor Gray
    
    python ".\scripts\pipeline_runner.py" @pythonArgs
    
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "`nPipeline completed successfully!" -ForegroundColor Green
        
        # Update paths.txt
        Update-Paths
        
        Write-Host "`nResults are available in the following directories:" -ForegroundColor Cyan
        Write-Host "  - Rasters: $DataDir\rasters\" -ForegroundColor White
        Write-Host "  - Visualizations: $DataDir\viz\" -ForegroundColor White
        Write-Host "  - Results: $DataDir\results\" -ForegroundColor White
        Write-Host "  - Logs: $DataDir\logs\" -ForegroundColor White
        
    } else {
        Write-Host "`nPipeline failed with exit code $exitCode" -ForegroundColor Red
    }
    
    exit $exitCode
    
}
catch {
    Write-Host "`nPipeline execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Deactivate virtual environment if it was activated
    if ($env:VIRTUAL_ENV) {
        deactivate
    }
}
