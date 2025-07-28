#!/bin/bash
# UVM Hands-On Tutorial Scripts
# Purpose: Provide easy-to-use scripts for UVM learning exercises

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if dsim is available
    if ! command -v dsim &> /dev/null; then
        print_error "DSIM simulator not found. Please install DSIM and add it to PATH."
        exit 1
    fi
    
    # Check DSIM version
    dsim_version=$(dsim --version 2>&1 | head -n1)
    print_success "Found DSIM: $dsim_version"
    
    # Check if we're in the correct directory
    if [ ! -d "sim" ] || [ ! -d "rtl" ]; then
        print_error "Please run this script from the UVMbasegen root directory"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to run basic test
run_basic_test() {
    print_info "Running basic UVM test..."
    
    cd sim/exec
    
    # Clean previous runs
    if [ -d "dsim_work" ]; then
        rm -rf dsim_work
    fi
    
    # Run the basic test
    if dsim -sv_lib uvm.so \
            +UVM_TESTNAME=register_file_basic_test \
            +UVM_VERBOSITY=UVM_MEDIUM \
            -compile ../../rtl/interfaces/register_file_if.sv \
            -compile ../uvm/base/register_file_pkg.sv \
            -compile ../tb/register_file_tb.sv \
            -run; then
        print_success "Basic test completed successfully!"
    else
        print_error "Basic test failed. Check the log for details."
        cd ../..
        exit 1
    fi
    
    cd ../..
}

# Function to run test with debug
run_debug_test() {
    print_info "Running test with debug information..."
    
    cd sim/exec
    
    # Clean previous runs
    if [ -d "dsim_work" ]; then
        rm -rf dsim_work
    fi
    
    # Run with high verbosity and waves
    if dsim -sv_lib uvm.so \
            +UVM_TESTNAME=register_file_basic_test \
            +UVM_VERBOSITY=UVM_HIGH \
            +WAVES \
            -compile ../../rtl/interfaces/register_file_if.sv \
            -compile ../uvm/base/register_file_pkg.sv \
            -compile ../tb/register_file_tb.sv \
            -run; then
        print_success "Debug test completed successfully!"
        print_info "Waveform saved to: waves/register_file_basic.mxd"
    else
        print_error "Debug test failed. Check the log for details."
        cd ../..
        exit 1
    fi
    
    cd ../..
}

# Function to run custom test
run_custom_test() {
    local test_name=$1
    if [ -z "$test_name" ]; then
        test_name="register_file_basic_test"
    fi
    
    print_info "Running custom test: $test_name"
    
    cd sim/exec
    
    # Clean previous runs
    if [ -d "dsim_work" ]; then
        rm -rf dsim_work
    fi
    
    # Run the specified test
    if dsim -sv_lib uvm.so \
            +UVM_TESTNAME=$test_name \
            +UVM_VERBOSITY=UVM_MEDIUM \
            -compile ../../rtl/interfaces/register_file_if.sv \
            -compile ../uvm/base/register_file_pkg.sv \
            -compile ../tb/register_file_tb.sv \
            -run; then
        print_success "Custom test '$test_name' completed successfully!"
    else
        print_error "Custom test '$test_name' failed. Check the log for details."
        cd ../..
        exit 1
    fi
    
    cd ../..
}

# Function to generate UVM code
generate_uvm_code() {
    print_info "Generating UVM code from templates..."
    
    if [ -f "scripts/generate_uvm_organized.py" ]; then
        python3 scripts/generate_uvm_organized.py
        print_success "UVM code generated successfully!"
    else
        print_warning "UVM generator script not found. Using existing code."
    fi
}

# Function to clean workspace
clean_workspace() {
    print_info "Cleaning workspace..."
    
    # Remove simulation artifacts
    if [ -d "sim/exec/dsim_work" ]; then
        rm -rf sim/exec/dsim_work
        print_info "Removed dsim_work directory"
    fi
    
    if [ -f "sim/exec/dsim.log" ]; then
        rm -f sim/exec/dsim.log
        print_info "Removed dsim.log"
    fi
    
    if [ -d "sim/exec/waves" ]; then
        rm -rf sim/exec/waves
        print_info "Removed waves directory"
    fi
    
    print_success "Workspace cleaned"
}

# Function to show test results
show_results() {
    print_info "Checking test results..."
    
    if [ -f "sim/exec/dsim.log" ]; then
        # Extract key information from log
        echo ""
        print_info "Test Summary:"
        grep -E "(UVM_INFO.*Running test|TEST PASSED|TEST FAILED|UVM_ERROR|UVM_FATAL)" sim/exec/dsim.log || true
        
        echo ""
        print_info "UVM Report Summary:"
        grep -A 10 "UVM Report Summary" sim/exec/dsim.log || true
    else
        print_warning "No test results found. Run a test first."
    fi
}

# Function to show help
show_help() {
    echo "UVM Hands-On Tutorial Script"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  check          - Check prerequisites"
    echo "  basic          - Run basic UVM test"
    echo "  debug          - Run test with debug info and waves"
    echo "  custom <test>  - Run custom test (specify test name)"
    echo "  generate       - Generate UVM code from templates"
    echo "  clean          - Clean workspace"
    echo "  results        - Show latest test results"
    echo "  help           - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 check                    # Check if environment is ready"
    echo "  $0 basic                    # Run basic test"
    echo "  $0 debug                    # Run with debug information"
    echo "  $0 custom my_custom_test    # Run specific test"
    echo "  $0 results                  # Show test results"
    echo ""
}

# Main script logic
case "$1" in
    "check")
        check_prerequisites
        ;;
    "basic")
        check_prerequisites
        run_basic_test
        show_results
        ;;
    "debug")
        check_prerequisites
        run_debug_test
        show_results
        ;;
    "custom")
        check_prerequisites
        run_custom_test "$2"
        show_results
        ;;
    "generate")
        generate_uvm_code
        ;;
    "clean")
        clean_workspace
        ;;
    "results")
        show_results
        ;;
    "help"|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
