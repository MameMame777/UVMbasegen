# Sample DSIM Execution Log

This document contains a sanitized sample of the DSIM simulation log for the register file UVM testbench.

## File Description

- **Purpose**: Sample execution log for UVM testbench simulation using DSIM
- **Module**: Register File
- **Test**: `register_file_basic_test`
- **Result**: PASS (8 operations, 0 failures)

## Security Processing

The following information has been sanitized for security purposes:

1. **User paths**: Replaced with environment variables:
   - Personal user directory → `${DSIM_HOME}`
   - Workspace path → `${WORKSPACE_PATH}`

2. **Preserved information**:
   - UVM test hierarchy and topology
   - Test execution flow and results
   - Simulation timing information
   - Warning and error messages
   - Performance metrics

## Test Summary

The sample log shows a successful execution of:

- 4 write operations to register addresses 0x0-0x3
- 4 read operations with data verification
- Complete UVM testbench initialization and teardown
- MXD waveform dump generation

## Usage

This sample log can be used as a reference for:

- Expected DSIM output format
- UVM testbench execution flow
- Test result interpretation
- Debugging simulation issues

## Key Sections

1. **Compilation Phase**: Lines showing analysis, elaboration, and optimization
2. **UVM Initialization**: UVM version info and testbench topology
3. **Test Execution**: Write/read sequences with scoreboard validation
4. **Final Report**: Test summary with pass/fail statistics

## Environment Variables Referenced

- `${DSIM_HOME}`: DSIM installation directory containing UVM libraries
- `${WORKSPACE_PATH}`: Project workspace root directory
