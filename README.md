# UVM Base Generator

Automatic SystemVerilog UVM verification environment generator with DSIM simulator support.

## Overview

This tool generates a complete UVM (Universal Verification Methodology) testbench environment from a simple YAML configuration file. It creates all necessary UVM components following best practices and industry standards.

## Features

- **Complete UVM Environment**: Generates all UVM components (transaction, sequence, driver, monitor, agent, environment, test)
- **DSIM Simulator Support**: Optimized for DSIM with MXD wave format
- **Template-Based**: Flexible template system for customization
- **Best Practices**: Follows UVM methodology and SystemVerilog coding standards
- **Cross-Platform**: Works on Windows (PowerShell) and Linux/Unix (Bash)
- **Ready-to-Run**: Generated environment is immediately executable

## Directory Structure

```
UVMbasegen/
├── config.yaml              # Project configuration file
├── scripts/                 # Generator scripts
│   ├── generate_uvm_organized.py  # Main Python generator script (organized structure)
│   ├── generate_uvm.py      # Legacy generator script
│   └── generate_uvm.ps1     # PowerShell wrapper (Windows)
├── templates/               # SystemVerilog templates
│   ├── transaction_template.sv
│   ├── sequence_template.sv
│   ├── driver_template.sv
│   ├── monitor_template.sv
│   ├── agent_template.sv
│   ├── env_template.sv
│   ├── test_template.sv
│   └── tb_template.sv
├── rtl/                     # RTL source code
│   ├── hdl/                 # Hardware description files
│   └── interfaces/          # Interface definitions
├── sim/                     # Simulation files
│   ├── tb/                  # Generated testbenches
│   ├── uvm/                 # Generated UVM components (organized)
│   │   ├── base/            # Package files
│   │   ├── transactions/    # Transaction classes
│   │   ├── sequences/       # Sequence classes
│   │   ├── agents/          # Driver, monitor, agent
│   │   ├── env/             # Environment and scoreboard
│   │   └── tests/           # Test classes
│   └── exec/                # Simulation execution scripts
└── docs/                    # Documentation
```

## Quick Start

### 1. Configure Your Project

Edit `config.yaml` to specify your module details:

```yaml
project:
  name: "my_verification_project"
  description: "My module UVM verification environment"

dut:
  module_name: "my_module"
  interface_name: "my_module_if"

interface:
  signals:
    - {name: "reset", direction: "output", width: 1}
    - {name: "data_in", direction: "output", width: 32}
    - {name: "data_out", direction: "input", width: 32}
    # Add your signals here

simulation:
  timescale: "1ns / 1ps"
  wave_format: "mxd"
```

### 2. Generate UVM Environment

**整理されたディレクトリ構造での生成（推奨）:**
```powershell
python scripts/generate_uvm_organized.py
```

**従来形式での生成:**
```powershell
python scripts/generate_uvm.py
```

**または PowerShell ラッパーを使用:**
```powershell
.\scripts\generate_uvm.ps1
```

### 3. Run Simulation

```bash
cd sim/exec
./run_sim.sh
```

## Generated Files

The generator creates the following files:

### UVM Components (`sim/uvm/`)

**整理されたディレクトリ構造では、以下のように分類されます：**

- **`base/`** - パッケージファイル
  - `{module_name}_pkg.sv` - メインパッケージファイル（全コンポーネントを含む）
  
- **`transactions/`** - トランザクションクラス
  - `{module_name}_transaction.sv` - ランダム化機能を持つトランザクションクラス
  
- **`sequences/`** - シーケンスクラス
  - `{module_name}_sequence.sv` - テストシーケンス定義（基本、書き込み、読み込み、ランダム）
  
- **`agents/`** - エージェント関連コンポーネント
  - `{module_name}_driver.sv` - ドライバークラス（刺激生成）
  - `{module_name}_monitor.sv` - モニタークラス（信号観測）
  - `{module_name}_agent.sv` - エージェントクラス（ドライバー、モニター、シーケンサーを統合）
  
- **`env/`** - 環境コンポーネント
  - `{module_name}_env.sv` - 環境クラスとスコアボードクラス
  
- **`tests/`** - テストクラス
  - `{module_name}_test.sv` - テストクラス（基本、ランダム）

### Testbench (`sim/tb/`)
- `{module_name}_tb.sv` - Top-level testbench module

### Simulation Scripts (`sim/exec/`)
- `run_sim.sh` - DSIM simulation script
- `filelist.f` - File compilation list

## Configuration File Format

The `config.yaml` file supports the following sections:

### Project Information
```yaml
project:
  name: "project_name"
  description: "Project description"
  author: "Your name"
```

### DUT Configuration
```yaml
dut:
  module_name: "module_name"     # SystemVerilog module name
  interface_name: "interface_name"  # Interface name
  file_name: "module_name.sv"   # RTL file name
```

### Interface Signals
```yaml
interface:
  name: "interface_name"
  signals:
    - {name: "signal_name", direction: "input|output", width: N, description: "Description"}
```

### Simulation Settings
```yaml
simulation:
  timescale: "1ns / 1ps"
  wave_format: "mxd"
  simulator: "dsim"
  compile_options: "+incdir+sim/uvm +define+UVM_NO_DEPRECATED"
```

## Example: Register File

The default configuration generates a simple 4×32-bit register file verification environment:

- **DUT**: `register_file.sv` - Simple register file with read/write operations
- **Interface**: `register_file_if.sv` - Clocked interface with modports
- **Tests**: Basic read/write test and random test sequences

## Customization

### Template Modification
Templates in the `templates/` directory can be modified to change the generated code structure.

### Adding New Components
1. Create new template files in `templates/`
2. Update the generator script to include new templates
3. Modify `config.yaml` to support new configuration options

### Signal Customization
Modify the interface signals in `config.yaml` to match your DUT requirements.

## Requirements

- **Python 3.6+** with PyYAML
- **DSIM Simulator** (Metrics Technologies)
- **SystemVerilog-compatible simulator** (for compilation)

## Best Practices

The generated code follows these SystemVerilog and UVM best practices:

- **Timescale Consistency**: All files use the same timescale
- **UVM Methodology**: Proper use of UVM phases, components, and utilities  
- **Clocking Blocks**: Proper setup for race-free simulation
- **Modular Design**: Clean separation of concerns
- **Documentation**: Comprehensive comments in English
- **Error Handling**: Proper error checking and reporting

## Troubleshooting

### Common Issues

1. **Python/PyYAML not found**: Install Python 3.6+ and PyYAML (`pip install PyYAML`)
2. **Permission denied on scripts**: Make scripts executable (`chmod +x run_sim.sh`)
3. **DSIM not found**: Ensure DSIM is in your PATH
4. **Compilation errors**: Check signal widths and interface consistency

### Debug Options

- Use `-v` flag for verbose output
- Check generated file contents before simulation
- Verify YAML configuration syntax

## Contributing

This tool follows the development guidelines specified in the project's coding instructions. When contributing:

1. Follow SystemVerilog naming conventions
2. Maintain English documentation
3. Update development diary in `diary/` directory
4. Ensure compatibility with DSIM simulator

## License

This tool is part of the FPGA development workspace and follows the project's licensing terms.

## Support

For issues and improvements, refer to the project's GitHub repository or development team.
