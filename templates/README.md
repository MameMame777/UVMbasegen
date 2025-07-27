# UVM Base Generator - Template Files

This directory contains SystemVerilog template files for generating UVM verification environments.

## Template Files Structure

```
templates/
├── transaction_template.sv    # UVM transaction class template
├── sequence_template.sv       # UVM sequence classes template
├── driver_template.sv         # UVM driver class template
├── monitor_template.sv        # UVM monitor class template
├── agent_template.sv          # UVM agent class template
├── env_template.sv           # UVM environment and scoreboard template
├── test_template.sv          # UVM test classes template
├── tb_template.sv            # Testbench top module template
└── README.md                 # This file
```

## Template Usage

These templates are used by the UVM base generator script to create a complete verification environment. The script performs the following substitutions:

- `register_file` → User-defined module name
- `register_file_if` → User-defined interface name
- Port definitions and widths based on YAML configuration
- Directory paths based on project structure

## Generated Files Structure

When processed by the generator script, these templates create:

```
sim/
├── tb/
│   └── {module_name}_tb.sv           # From tb_template.sv
└── uvm/
    ├── {module_name}_transaction.sv   # From transaction_template.sv
    ├── {module_name}_sequence.sv      # From sequence_template.sv
    ├── {module_name}_driver.sv        # From driver_template.sv
    ├── {module_name}_monitor.sv       # From monitor_template.sv
    ├── {module_name}_agent.sv         # From agent_template.sv
    ├── {module_name}_env.sv           # From env_template.sv
    ├── {module_name}_test.sv          # From test_template.sv
    └── {module_name}_pkg.sv           # Generated package file
```

## Template Features

- **UVM Best Practices**: All templates follow UVM methodology best practices
- **DSIM Compatibility**: Optimized for DSIM simulator with MXD wave format
- **Modular Design**: Each component is self-contained and reusable
- **Comprehensive Coverage**: Includes all essential UVM components
- **Documentation**: Well-commented code for educational purposes

## Customization

Templates can be customized by:
1. Modifying the template files directly
2. Updating the YAML configuration file
3. Extending the generator script for additional features
