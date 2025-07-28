# UVM Hands-On Tutorial PowerShell Script
# Purpose: Provide easy-to-use scripts for UVM learning exercises on Windows

param(
    [string]$Command = "help",
    [string]$TestName = "register_file_basic_test"
)

# Function to print colored output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check if dsim is available
    try {
        $dsimVersion = & dsim --version 2>&1 | Select-Object -First 1
        Write-Success "Found DSIM: $dsimVersion"
    }
    catch {
        Write-Error "DSIM simulator not found. Please install DSIM and add it to PATH."
        exit 1
    }
    
    # Check if we're in the correct directory
    if (-not (Test-Path "sim") -or -not (Test-Path "rtl")) {
        Write-Error "Please run this script from the UVMbasegen root directory"
        exit 1
    }
    
    Write-Success "Prerequisites check passed"
}

# Function to run basic test
function Start-BasicTest {
    Write-Info "Running basic UVM test..."
    
    Set-Location "sim\exec"
    
    # Clean previous runs
    if (Test-Path "dsim_work") {
        Remove-Item -Recurse -Force "dsim_work"
    }
    
    # Run the basic test
    $result = & dsim -sv_lib uvm.so `
        "+UVM_TESTNAME=register_file_basic_test" `
        "+UVM_VERBOSITY=UVM_MEDIUM" `
        "-compile" "..\..\rtl\interfaces\register_file_if.sv" `
        "-compile" "..\uvm\base\register_file_pkg.sv" `
        "-compile" "..\tb\register_file_tb.sv" `
        "-run" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Basic test completed successfully!"
    }
    else {
        Write-Error "Basic test failed. Check the log for details."
        Write-Host $result
        Set-Location "..\..\"
        exit 1
    }
    
    Set-Location "..\..\"
}

# Function to run test with debug
function Start-DebugTest {
    Write-Info "Running test with debug information..."
    
    Set-Location "sim\exec"
    
    # Clean previous runs
    if (Test-Path "dsim_work") {
        Remove-Item -Recurse -Force "dsim_work"
    }
    
    # Run with high verbosity and waves
    $result = & dsim -sv_lib uvm.so `
        "+UVM_TESTNAME=register_file_basic_test" `
        "+UVM_VERBOSITY=UVM_HIGH" `
        "+WAVES" `
        "-compile" "..\..\rtl\interfaces\register_file_if.sv" `
        "-compile" "..\uvm\base\register_file_pkg.sv" `
        "-compile" "..\tb\register_file_tb.sv" `
        "-run" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Debug test completed successfully!"
        Write-Info "Waveform saved to: waves\register_file_basic.mxd"
    }
    else {
        Write-Error "Debug test failed. Check the log for details."
        Write-Host $result
        Set-Location "..\..\"
        exit 1
    }
    
    Set-Location "..\..\"
}

# Function to run custom test
function Start-CustomTest {
    param([string]$TestName)
    
    if ([string]::IsNullOrEmpty($TestName)) {
        $TestName = "register_file_basic_test"
    }
    
    Write-Info "Running custom test: $TestName"
    
    Set-Location "sim\exec"
    
    # Clean previous runs
    if (Test-Path "dsim_work") {
        Remove-Item -Recurse -Force "dsim_work"
    }
    
    # Run the specified test
    $result = & dsim -sv_lib uvm.so `
        "+UVM_TESTNAME=$TestName" `
        "+UVM_VERBOSITY=UVM_MEDIUM" `
        "-compile" "..\..\rtl\interfaces\register_file_if.sv" `
        "-compile" "..\uvm\base\register_file_pkg.sv" `
        "-compile" "..\tb\register_file_tb.sv" `
        "-run" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Custom test '$TestName' completed successfully!"
    }
    else {
        Write-Error "Custom test '$TestName' failed. Check the log for details."
        Write-Host $result
        Set-Location "..\..\"
        exit 1
    }
    
    Set-Location "..\..\"
}

# Function to generate UVM code
function New-UVMCode {
    Write-Info "Generating UVM code from templates..."
    
    if (Test-Path "scripts\generate_uvm_organized.py") {
        python scripts\generate_uvm_organized.py
        Write-Success "UVM code generated successfully!"
    }
    else {
        Write-Warning "UVM generator script not found. Using existing code."
    }
}

# Function to clean workspace
function Clear-Workspace {
    Write-Info "Cleaning workspace..."
    
    # Remove simulation artifacts
    if (Test-Path "sim\exec\dsim_work") {
        Remove-Item -Recurse -Force "sim\exec\dsim_work"
        Write-Info "Removed dsim_work directory"
    }
    
    if (Test-Path "sim\exec\dsim.log") {
        Remove-Item -Force "sim\exec\dsim.log"
        Write-Info "Removed dsim.log"
    }
    
    if (Test-Path "sim\exec\waves") {
        Remove-Item -Recurse -Force "sim\exec\waves"
        Write-Info "Removed waves directory"
    }
    
    Write-Success "Workspace cleaned"
}

# Function to show test results
function Show-Results {
    Write-Info "Checking test results..."
    
    if (Test-Path "sim\exec\dsim.log") {
        # Extract key information from log
        Write-Host ""
        Write-Info "Test Summary:"
        Get-Content "sim\exec\dsim.log" | Select-String -Pattern "(UVM_INFO.*Running test|TEST PASSED|TEST FAILED|UVM_ERROR|UVM_FATAL)"
        
        Write-Host ""
        Write-Info "UVM Report Summary:"
        $content = Get-Content "sim\exec\dsim.log"
        $summaryIndex = $content | Select-String -Pattern "UVM Report Summary" | Select-Object -First 1
        if ($summaryIndex) {
            $startLine = $summaryIndex.LineNumber
            $content | Select-Object -Skip ($startLine - 1) -First 15
        }
    }
    else {
        Write-Warning "No test results found. Run a test first."
    }
}

# Function to show help
function Show-Help {
    Write-Host "UVM Hands-On Tutorial PowerShell Script"
    Write-Host ""
    Write-Host "Usage: .\uvm_tutorial.ps1 -Command <command> [-TestName <test_name>]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  check          - Check prerequisites"
    Write-Host "  basic          - Run basic UVM test"
    Write-Host "  debug          - Run test with debug info and waves"
    Write-Host "  custom         - Run custom test (specify with -TestName)"
    Write-Host "  generate       - Generate UVM code from templates"
    Write-Host "  clean          - Clean workspace"
    Write-Host "  results        - Show latest test results"
    Write-Host "  help           - Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\uvm_tutorial.ps1 -Command check"
    Write-Host "  .\uvm_tutorial.ps1 -Command basic"
    Write-Host "  .\uvm_tutorial.ps1 -Command debug"
    Write-Host "  .\uvm_tutorial.ps1 -Command custom -TestName my_custom_test"
    Write-Host "  .\uvm_tutorial.ps1 -Command results"
    Write-Host ""
}

# Main script logic
switch ($Command.ToLower()) {
    "check" {
        Test-Prerequisites
    }
    "basic" {
        Test-Prerequisites
        Start-BasicTest
        Show-Results
    }
    "debug" {
        Test-Prerequisites
        Start-DebugTest
        Show-Results
    }
    "custom" {
        Test-Prerequisites
        Start-CustomTest $TestName
        Show-Results
    }
    "generate" {
        New-UVMCode
    }
    "clean" {
        Clear-Workspace
    }
    "results" {
        Show-Results
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Help
        exit 1
    }
}
