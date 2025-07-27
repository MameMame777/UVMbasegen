#!/usr/bin/env python3
"""
UVM Base Generator Script - Updated for Organized Directory Structure
Generates SystemVerilog UVM verification environment from YAML configuration and templates.

Author: UVM Base Generator
Date: 2025-07-27
"""

import os
import sys
import yaml
import shutil
from pathlib import Path
from typing import Dict, Any, List
import argparse
from datetime import datetime

class UVMGenerator:
    """Main UVM environment generator class with organized directory structure."""
    
    def __init__(self, config_file: str = "config.yaml"):
        """Initialize the generator with configuration file."""
        self.config_file = config_file
        self.config = {}
        self.base_dir = Path.cwd()
        self.templates_dir = self.base_dir / "templates"
        
    def load_config(self) -> bool:
        """Load YAML configuration file."""
        try:
            config_path = self.base_dir / self.config_file
            if not config_path.exists():
                print(f"ERROR: Configuration file '{self.config_file}' not found!")
                return False
                
            with open(config_path, 'r', encoding='utf-8') as f:
                self.config = yaml.safe_load(f)
                
            print(f"Configuration loaded from '{self.config_file}'")
            return True
            
        except Exception as e:
            print(f"ERROR loading configuration: {e}")
            return False
    
    def validate_config(self) -> bool:
        """Validate configuration file contents."""
        required_sections = ['project', 'dut', 'interface', 'simulation', 'directories']
        
        for section in required_sections:
            if section not in self.config:
                print(f"ERROR: Missing required section '{section}' in config")
                return False
        
        # Validate DUT section
        dut_required = ['module_name', 'interface_name']
        for field in dut_required:
            if field not in self.config['dut']:
                print(f"ERROR: Missing required field '{field}' in dut section")
                return False
        
        print("Configuration validation passed")
        return True
    
    def create_directories(self) -> bool:
        """Create output directories based on configuration."""
        try:
            directories = self.config['directories']
            
            # Create main directories
            for dir_key, dir_path in directories.items():
                full_path = self.base_dir / dir_path
                full_path.mkdir(parents=True, exist_ok=True)
                print(f"Created directory: {full_path}")
            
            # Create UVM component subdirectories
            uvm_base_path = self.base_dir / self.config['directories']['sim_uvm']
            uvm_subdirs = [
                'base',           # Package files
                'transactions',   # Transaction classes
                'sequences',      # Sequence classes
                'agents',         # Agent, driver, monitor
                'env',           # Environment and scoreboard
                'tests'          # Test classes
            ]
            
            for subdir in uvm_subdirs:
                subdir_path = uvm_base_path / subdir
                subdir_path.mkdir(parents=True, exist_ok=True)
                print(f"Created UVM subdirectory: {subdir_path}")
            
            return True
            
        except Exception as e:
            print(f"ERROR creating directories: {e}")
            return False
    
    def substitute_template(self, template_content: str, substitutions: Dict[str, str]) -> str:
        """Perform string substitutions in template content."""
        result = template_content
        
        for old_str, new_str in substitutions.items():
            result = result.replace(old_str, new_str)
        
        return result
    
    def get_substitutions(self) -> Dict[str, str]:
        """Generate substitution dictionary from configuration."""
        module_name = self.config['dut']['module_name']
        interface_name = self.config['dut']['interface_name']
        timescale = self.config['simulation']['timescale']
        
        substitutions = {
            'register_file': module_name,
            'register_file_if': interface_name,
            '`timescale 1ns / 1ps': f'`timescale {timescale}',
            'register_file_tb': f'{module_name}_tb',
            'register_file_transaction': f'{module_name}_transaction',
            'register_file_driver': f'{module_name}_driver',
            'register_file_monitor': f'{module_name}_monitor',
            'register_file_agent': f'{module_name}_agent',
            'register_file_env': f'{module_name}_env',
            'register_file_scoreboard': f'{module_name}_scoreboard',
            'register_file_sequence': f'{module_name}_sequence',
            'register_file_write_sequence': f'{module_name}_write_sequence',
            'register_file_read_sequence': f'{module_name}_read_sequence',
            'register_file_random_sequence': f'{module_name}_random_sequence',
            'register_file_base_test': f'{module_name}_base_test',
            'register_file_basic_test': f'{module_name}_basic_test',
            'register_file_random_test': f'{module_name}_random_test'
        }
        
        return substitutions
    
    def generate_file_from_template(self, template_file: str, output_file: str, 
                                  additional_subs: Dict[str, str] = None) -> bool:
        """Generate output file from template with substitutions."""
        try:
            template_path = self.templates_dir / template_file
            if not template_path.exists():
                print(f"ERROR: Template file '{template_file}' not found!")
                return False
            
            # Read template
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()
            
            # Get substitutions
            substitutions = self.get_substitutions()
            if additional_subs:
                substitutions.update(additional_subs)
            
            # Apply substitutions
            output_content = self.substitute_template(template_content, substitutions)
            
            # Write output file
            output_path = self.base_dir / output_file
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(output_content)
            
            print(f"Generated: {output_path}")
            return True
            
        except Exception as e:
            print(f"ERROR generating {output_file}: {e}")
            return False
    
    def generate_package_file(self) -> bool:
        """Generate UVM package file including all components with organized directory structure."""
        try:
            module_name = self.config['dut']['module_name']
            package_content = f'''`timescale {self.config['simulation']['timescale']}

// {module_name.upper()} UVM Package
// Generated by UVM Base Generator on {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
package {module_name}_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Include all UVM components with organized directory structure
    `include "../transactions/{module_name}_transaction.sv"
    `include "../sequences/{module_name}_sequence.sv"
    `include "../agents/{module_name}_driver.sv"
    `include "../agents/{module_name}_monitor.sv"
    `include "../agents/{module_name}_agent.sv"
    `include "../env/{module_name}_env.sv"
    `include "../tests/{module_name}_test.sv"
    
endpackage
'''
            
            package_file = self.base_dir / self.config['directories']['sim_uvm'] / "base" / f"{module_name}_pkg.sv"
            with open(package_file, 'w', encoding='utf-8') as f:
                f.write(package_content)
            
            print(f"Generated: {package_file}")
            return True
            
        except Exception as e:
            print(f"ERROR generating package file: {e}")
            return False
    
    def generate_testbench_file(self) -> bool:
        """Generate testbench file with proper UVM package imports."""
        try:
            module_name = self.config['dut']['module_name']
            interface_name = self.config['dut']['interface_name']
            
            tb_content = f'''`timescale {self.config['simulation']['timescale']}

// Import UVM macros (available with -uvm flag in DSIM)
`include "uvm_macros.svh"
// Include the UVM package file directly
`include "{module_name}_pkg.sv"

// Import the UVM package
import uvm_pkg::*;
import {module_name}_pkg::*;

// {module_name} Testbench Top
// Top-level testbench module connecting DUT, interface, and UVM test
module {module_name}_tb;
    
    // Clock and reset generation
    logic clk;
    logic reset;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end
    
    // Reset generation
    initial begin
        reset = 1;
        #50ns;
        reset = 0;
    end
    
    // Interface instantiation
    {interface_name} vif(clk);
    
    // DUT instantiation
    {module_name} dut (
        .clk(clk),
        .reset(vif.reset),
        .write_enable(vif.write_enable),
        .address(vif.address),
        .write_data(vif.write_data),
        .read_enable(vif.read_enable),
        .read_data(vif.read_data),
        .ready(vif.ready)
    );
    
    // UVM testbench initialization
    initial begin
        // Set interface in config DB for UVM components
        uvm_config_db#(virtual {interface_name})::set(null, "*", "vif", vif);
        
        // Enable wave dumping (MXD format for DSIM)
        $dumpfile("{module_name}_tb.mxd");
        $dumpvars(0, {module_name}_tb);
        
        // Run the test
        run_test();
    end
    
    // Timeout mechanism
    initial begin
        #10ms;
        `uvm_fatal("TIMEOUT", "Test timeout after 10ms")
    end

endmodule
'''
            
            tb_file = self.base_dir / self.config['directories']['sim_tb'] / f"{module_name}_tb.sv"
            with open(tb_file, 'w', encoding='utf-8') as f:
                f.write(tb_content)
            
            print(f"Generated: {tb_file}")
            return True
            
        except Exception as e:
            print(f"ERROR generating testbench file: {e}")
            return False
    
    def generate_dsim_script(self) -> bool:
        """Generate DSIM simulation script following DSIMtuto best practices with organized structure."""
        try:
            module_name = self.config['dut']['module_name']
            
            # Generate unified test runner (run.bat)
            bat_content = f'''@echo off
REM Unified Test Execution Script for {module_name}
REM Generated by UVM Base Generator - Based on DSIMtuto best practices
REM Usage: run.bat [test_name]

setlocal enabledelayedexpansion

REM Configuration file
set CONFIG_FILE=test_config.cfg

REM Check if test name is provided
if "%1"=="" (
    echo.
    echo ================================
    echo   {module_name.upper()} Test Runner
    echo ================================
    echo.
    echo Usage: run.bat [test_name]
    echo.
    echo Available tests:
    echo ----------------
    for /f "eol=# tokens=1,2 delims=|" %%a in (%CONFIG_FILE%) do (
        echo   %%a - %%b
    )
    echo.
    goto :eof
)

set TEST_NAME=%1

REM Parse configuration file to find test
set FOUND=0
for /f "eol=# tokens=1,2,3,4,5,6 delims=|" %%a in (%CONFIG_FILE%) do (
    if "%%a"=="%TEST_NAME%" (
        set FOUND=1
        set TEST_DESC=%%b
        set FILELIST=%%c
        set TEST_CLASS=%%d
        set WAVE_FILE=%%e
        set VERBOSITY=%%f
    )
)

if %FOUND%==0 (
    echo ERROR: Test '%TEST_NAME%' not found in configuration
    echo Run 'run.bat' to see available tests
    exit /b 1
)

REM Check DSIM environment
if not defined DSIM_HOME (
    echo ERROR: DSIM_HOME environment variable not set
    exit /b 1
)

REM DSIM Environment Setup
set "DSIM_LICENSE=%USERPROFILE%\\AppData\\Local\\metrics-ca\\dsim-license.json"
call "%USERPROFILE%\\AppData\\Local\\metrics-ca\\dsim\\20240422.0.0\\shell_activate.bat"

REM Display test information
echo.
echo ================================================================================
echo Test: %TEST_NAME%
echo Description: %TEST_DESC%
echo Filelist: %FILELIST%
echo Test Class: %TEST_CLASS%
echo Wave File: %WAVE_FILE%
echo Verbosity: %VERBOSITY%
echo DSIM_HOME: %DSIM_HOME%
echo ================================================================================
echo.

REM Create waves directory if it doesn''t exist
if not exist waves mkdir waves

REM Execute DSIM simulation with organized include paths
echo Starting DSIM simulation...
dsim ^
    +incdir+../uvm/base +incdir+../uvm/transactions +incdir+../uvm/sequences +incdir+../uvm/agents +incdir+../uvm/env +incdir+../uvm/tests ^
    +define+UVM_NO_DEPRECATED ^
    -f %FILELIST% ^
    +UVM_TESTNAME=%TEST_CLASS% ^
    +UVM_VERBOSITY=%VERBOSITY% ^
    -waves waves\\%WAVE_FILE% ^
    -top {module_name}_tb

set DSIM_EXIT_CODE=%ERRORLEVEL%

echo.
if %DSIM_EXIT_CODE%==0 (
    echo ================================================================================
    echo Test '%TEST_NAME%' completed successfully!
    echo Waveform saved to: waves\\%WAVE_FILE%
    echo ================================================================================
) else (
    echo ================================================================================
    echo Test '%TEST_NAME%' failed with exit code: %DSIM_EXIT_CODE%
    echo Check the simulation log for details
    echo ================================================================================
)

exit /b %DSIM_EXIT_CODE%
'''
            
            bat_file = self.base_dir / self.config['directories']['sim_exec'] / "run.bat"
            with open(bat_file, 'w', encoding='utf-8') as f:
                f.write(bat_content)
            
            print(f"Generated: {bat_file}")
            return True
            
        except Exception as e:
            print(f"ERROR generating DSIM script: {e}")
            return False
    
    def generate_test_config(self) -> bool:
        """Generate test configuration file."""
        try:
            module_name = self.config['dut']['module_name']
            config_content = f'''# Test Configuration File for {module_name} UVM Verification
# Generated by UVM Base Generator
# Format: test_name|description|filelist|test_class|wave_file|verbosity

{module_name}_basic|{module_name.title()} Basic Test - Write/Read operations|{module_name}.f|{module_name}_basic_test|{module_name}_basic.{self.config['simulation']['wave_format']}|UVM_MEDIUM
{module_name}_random|{module_name.title()} Random Test - Random operations|{module_name}.f|{module_name}_random_test|{module_name}_random.{self.config['simulation']['wave_format']}|UVM_HIGH
'''
            
            config_file = self.base_dir / self.config['directories']['sim_exec'] / "test_config.cfg"
            with open(config_file, 'w', encoding='utf-8') as f:
                f.write(config_content)
            
            print(f"Generated: {config_file}")
            return True
            
        except Exception as e:
            print(f"ERROR generating test config: {e}")
            return False
    
    def generate_filelist(self) -> bool:
        """Generate file list for compilation with organized directory structure."""
        try:
            module_name = self.config['dut']['module_name']
            interface_name = self.config['dut']['interface_name']
            
            filelist_content = f'''// File list for {module_name} UVM testbench
// Generated by UVM Base Generator with organized directory structure

// RTL files first (interfaces must be compiled before packages that use them)
..\\..\\rtl\\interfaces\\{interface_name}.sv
..\\..\\rtl\\hdl\\{module_name}.sv

// UVM library (use DSIM built-in UVM)
-uvm

// Testbench top (includes UVM package directly)
..\\tb\\{module_name}_tb.sv
'''
            
            filelist_file = self.base_dir / self.config['directories']['sim_exec'] / f"{module_name}.f"
            with open(filelist_file, 'w', encoding='utf-8') as f:
                f.write(filelist_content)
            
            print(f"Generated: {filelist_file}")
            return True
            
        except Exception as e:
            print(f"ERROR generating filelist: {e}")
            return False
    
    def generate_all(self) -> bool:
        """Generate complete UVM environment with organized directory structure."""
        print("=== UVM Base Generator ===")
        print(f"Project: {self.config['project']['name']}")
        print(f"Module: {self.config['dut']['module_name']}")
        print("Using organized directory structure for UVM components")
        print()
        
        # Template to output file mapping with new directory structure
        file_mappings = [
            ("transaction_template.sv", f"{self.config['directories']['sim_uvm']}/transactions/{self.config['dut']['module_name']}_transaction.sv"),
            ("sequence_template.sv", f"{self.config['directories']['sim_uvm']}/sequences/{self.config['dut']['module_name']}_sequence.sv"),
            ("driver_template.sv", f"{self.config['directories']['sim_uvm']}/agents/{self.config['dut']['module_name']}_driver.sv"),
            ("monitor_template.sv", f"{self.config['directories']['sim_uvm']}/agents/{self.config['dut']['module_name']}_monitor.sv"),
            ("agent_template.sv", f"{self.config['directories']['sim_uvm']}/agents/{self.config['dut']['module_name']}_agent.sv"),
            ("env_template.sv", f"{self.config['directories']['sim_uvm']}/env/{self.config['dut']['module_name']}_env.sv"),
            ("test_template.sv", f"{self.config['directories']['sim_uvm']}/tests/{self.config['dut']['module_name']}_test.sv")
        ]
        
        # Generate all files from templates
        success = True
        for template_file, output_file in file_mappings:
            if not self.generate_file_from_template(template_file, output_file):
                success = False

        # Generate package file (must be done after all components are generated)
        if not self.generate_package_file():
            success = False

        # Generate testbench with proper imports
        if not self.generate_testbench_file():
            success = False

        # Generate simulation scripts
        if not self.generate_dsim_script():
            success = False
        
        if not self.generate_test_config():
            success = False
        
        if not self.generate_filelist():
            success = False
        
        return success
    
    def run(self) -> bool:
        """Main execution function."""
        if not self.load_config():
            return False
        
        if not self.validate_config():
            return False
        
        if not self.create_directories():
            return False
        
        if not self.generate_all():
            return False
        
        print()
        print("=== Generation Complete ===")
        print(f"UVM environment generated for '{self.config['dut']['module_name']}'")
        print("Organized directory structure:")
        print("  - sim/uvm/base/       : Package files")
        print("  - sim/uvm/transactions: Transaction classes")
        print("  - sim/uvm/sequences/  : Sequence classes")
        print("  - sim/uvm/agents/     : Driver, monitor, agent")
        print("  - sim/uvm/env/        : Environment and scoreboard")
        print("  - sim/uvm/tests/      : Test classes")
        print(f"To run simulation: cd {self.config['directories']['sim_exec']} && .\\run.bat")
        
        return True

def main():
    """Main function with command line argument parsing."""
    parser = argparse.ArgumentParser(description="UVM Base Generator with Organized Directory Structure")
    parser.add_argument("-c", "--config", default="config.yaml", 
                       help="Configuration file path (default: config.yaml)")
    parser.add_argument("-v", "--verbose", action="store_true",
                       help="Verbose output")
    
    args = parser.parse_args()
    
    generator = UVMGenerator(args.config)
    success = generator.run()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
