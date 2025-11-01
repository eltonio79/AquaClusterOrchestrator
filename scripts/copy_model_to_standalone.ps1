# Script to copy complete model project (not just .icmm file) to standalone folder
# Usage: .\scripts\copy_model_to_standalone.ps1 -ModelPath ".\models\Medium 2D\Ruby_Hackathon_Medium_2D_Model.icmm"

param(
    [Parameter(Mandatory=$true)]
    [string]$ModelPath,
    
    [switch]$CleanExisting
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

# Resolve model path
if (-not ([System.IO.Path]::IsPathRooted($ModelPath))) {
    $ModelPath = Join-Path $projectRoot $ModelPath
}

if (-not (Test-Path $ModelPath)) {
    Write-Host "Error: Model file not found: $ModelPath" -ForegroundColor Red
    exit 1
}

$modelFile = Get-Item $ModelPath
$modelDir = $modelFile.DirectoryName
$modelName = $modelFile.BaseName

Write-Host "=== Copying Model Project ===" -ForegroundColor Cyan
Write-Host "Source: $modelDir" -ForegroundColor Gray
Write-Host "Model file: $($modelFile.Name)" -ForegroundColor Gray
Write-Host ""

# Determine destination - use model name as folder name in standalone
$standaloneRoot = Join-Path $projectRoot "models\standalone"
$destFolder = Join-Path $standaloneRoot $modelName

# Check if destination exists
if (Test-Path $destFolder) {
    if ($CleanExisting) {
        Write-Host "Cleaning existing folder: $destFolder" -ForegroundColor Yellow
        Remove-Item -Path $destFolder -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Warning: Destination folder exists: $destFolder" -ForegroundColor Yellow
        Write-Host "Use -CleanExisting to overwrite" -ForegroundColor Yellow
        exit 1
    }
}

# Create standalone root if needed
if (-not (Test-Path $standaloneRoot)) {
    New-Item -ItemType Directory -Force -Path $standaloneRoot | Out-Null
}

Write-Host "Copying model project folder..." -ForegroundColor Yellow

# Copy entire model directory
try {
    # Get all items in model directory
    $sourceItems = Get-ChildItem -Path $modelDir -Recurse
    
    $copiedCount = 0
    foreach ($item in $sourceItems) {
        $relativePath = $item.FullName.Substring($modelDir.Length + 1)
        $destPath = Join-Path $destFolder $relativePath
        
        # Create directory structure if needed
        $destDir = Split-Path -Parent $destPath
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }
        
        # Copy file or directory
        if ($item.PSIsContainer) {
            if (-not (Test-Path $destPath)) {
                New-Item -ItemType Directory -Force -Path $destPath | Out-Null
            }
        } else {
            Copy-Item -Path $item.FullName -Destination $destPath -Force
            $copiedCount++
        }
    }
    
    Write-Host "Successfully copied $copiedCount files to: $destFolder" -ForegroundColor Green
    Write-Host ""
    Write-Host "Model .icmm file location:" -ForegroundColor Cyan
    $icmmFile = Join-Path $destFolder "$modelName.icmm"
    if (Test-Path $icmmFile) {
        Write-Host "  $icmmFile" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: .icmm file not found in copied folder!" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "You can now use this model path:" -ForegroundColor Cyan
    Write-Host "  $icmmFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or relative path:" -ForegroundColor Cyan
    $relativeIcmm = $icmmFile.Replace($projectRoot + '\', '')
    Write-Host "  $relativeIcmm" -ForegroundColor Gray
    
    return $icmmFile
    
} catch {
    Write-Host "Error copying model: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

