# UVM Base Generator PowerShell Script
# Wrapper script for Windows environments
# Author: UVM Base Generator
# Date: 2025-07-27

param(
    [string]$Config = "config.yaml",
    [switch]$Verbose,
    [switch]$Help
)

# Show help
if ($Help) {
    Write-Host "UVM Base Generator PowerShell Script"
    Write-Host ""
    Write-Host "Usage: .\generate_uvm.ps1 [-Config <config_file>] [-Verbose] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Config    Configuration YAML file (default: config.yaml)"
    Write-Host "  -Verbose   Enable verbose output"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\generate_uvm.ps1"
    Write-Host "  .\generate_uvm.ps1 -Config my_project.yaml -Verbose"
    exit 0
}

# Check if Python is available
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Found Python: $pythonVersion"
} catch {
    Write-Error "Python not found! Please install Python 3.6 or later."
    exit 1
}

# Check if PyYAML is installed
try {
    python -c "import yaml" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "PyYAML not found. Installing..."
        pip install PyYAML
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install PyYAML"
            exit 1
        }
    }
} catch {
    Write-Error "Failed to check/install PyYAML"
    exit 1
}

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$PythonScript = Join-Path $ScriptDir "generate_uvm.py"

# Check if Python script exists
if (-not (Test-Path $PythonScript)) {
    Write-Error "Python script not found: $PythonScript"
    exit 1
}

# Build Python command arguments
$pythonArgs = @()
$pythonArgs += $PythonScript
$pythonArgs += "-c"
$pythonArgs += $Config

if ($Verbose) {
    $pythonArgs += "-v"
}

# Change to root directory
Push-Location $RootDir

try {
    # Run Python script
    Write-Host "Running UVM Base Generator..."
    Write-Host "Working directory: $(Get-Location)"
    Write-Host "Config file: $Config"
    Write-Host ""
    
    & python @pythonArgs
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "UVM Base Generator completed successfully!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "UVM Base Generator failed with exit code: $exitCode" -ForegroundColor Red
    }
    
    exit $exitCode
    
} catch {
    Write-Error "Error running UVM Base Generator: $_"
    exit 1
} finally {
    Pop-Location
}
