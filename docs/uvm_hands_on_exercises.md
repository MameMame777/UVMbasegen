# UVM Hands-On Learning Exercises

**Author**: UVM Base Generator  
**Date**: July 27, 2025  
**Purpose**: Practical exercises for mastering UVM verification

## Exercise Overview

This document provides hands-on exercises to reinforce UVM concepts learned in the comprehensive guide. Each exercise builds upon previous knowledge and introduces new challenges.

---

## Exercise 1: Basic UVM Environment Exploration

### Objective
Understand the generated UVM environment structure and component interactions.

### Tasks

#### Task 1.1: Environment Analysis
1. **Examine the generated directory structure**:
   ```bash
   cd UVMbasegen
   tree sim/uvm/
   ```

2. **Identify component relationships**:
   - Open `sim/uvm/base/register_file_pkg.sv`
   - Trace the include order and understand dependencies
   - Map the includes to actual component files

#### Task 1.2: Component Hierarchy
1. **Draw the UVM component hierarchy**:
   - Start from the testbench top
   - Show parent-child relationships
   - Include TLM port connections

2. **Verify your understanding**:
   ```bash
   cd sim/exec
   ./run.bat register_file_basic
   ```
   - Look for the topology printout in the log
   - Compare with your drawn hierarchy

#### Task 1.3: Transaction Analysis
1. **Examine the transaction class**:
   - Open `sim/uvm/transactions/register_file_transaction.sv`
   - Identify all fields and their purposes
   - Understand the constraint structure

2. **Experiment with constraints**:
   - Modify the address constraint to limit to registers 0-1
   - Run simulation and observe the effect

### Expected Learning Outcomes
- Understanding of UVM directory organization
- Knowledge of component instantiation hierarchy
- Familiarity with transaction structure and constraints

---

## Exercise 2: Sequence Development

### Objective
Create custom sequences to generate specific test patterns.

### Tasks

#### Task 2.1: Create a Corner Case Sequence
Create a new sequence file: `sim/uvm/sequences/register_file_corner_sequence.sv`

```systemverilog
`timescale 1ns / 1ps

class register_file_corner_sequence extends register_file_sequence;
    `uvm_object_utils(register_file_corner_sequence)
    
    function new(string name = "register_file_corner_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        register_file_transaction req;
        
        // TODO: Implement corner case testing
        // 1. Test all-zeros data
        // 2. Test all-ones data (0xFFFFFFFF)
        // 3. Test alternating patterns (0xAAAAAAAA, 0x55555555)
        // 4. Test boundary values
        
        `uvm_info(get_type_name(), "Corner case sequence started", UVM_MEDIUM)
        
        // Your implementation here
        
        `uvm_info(get_type_name(), "Corner case sequence completed", UVM_MEDIUM)
    endtask
endclass
```

#### Task 2.2: Implement the Corner Sequence
Complete the sequence implementation:

1. **All-zeros test**:
   ```systemverilog
   req = register_file_transaction::type_id::create("req");
   start_item(req);
   assert(req.randomize() with {
       operation == WRITE;
       address == 0;
       data == 32'h00000000;
   });
   finish_item(req);
   ```

2. **Add similar patterns for other corner cases**

3. **Add read verification for each written value**

#### Task 2.3: Create a Stress Test Sequence
Create `register_file_stress_sequence.sv`:

```systemverilog
class register_file_stress_sequence extends register_file_sequence;
    
    rand int num_operations;
    constraint ops_constraint {
        num_operations inside {[100:1000]};
    }
    
    virtual task body();
        // TODO: Implement high-frequency random operations
        // Include back-to-back writes and reads
        // Test all addresses with random data
    endtask
endclass
```

#### Task 2.4: Integrate New Sequences
1. **Add to package file**: Include new sequences in `register_file_pkg.sv`
2. **Create new test**: Develop `register_file_corner_test` using your sequence
3. **Update test configuration**: Add new test to `test_config.cfg`

### Expected Learning Outcomes
- Ability to create custom UVM sequences
- Understanding of constraint-based stimulus generation
- Knowledge of sequence integration into testbench

---

## Exercise 3: Monitor and Scoreboard Enhancement

### Objective
Enhance monitoring capabilities and improve checking mechanisms.

### Tasks

#### Task 3.1: Enhanced Monitor
Modify `sim/uvm/agents/register_file_monitor.sv` to collect additional information:

1. **Add timing measurements**:
   ```systemverilog
   class register_file_monitor extends uvm_monitor;
       // Existing code...
       
       // Add timing fields
       time last_operation_start;
       time last_operation_end;
       
       virtual task collect_transaction(register_file_transaction trans);
           // Measure operation timing
           trans.start_time = last_operation_start;
           trans.end_time = $time;
           trans.latency = trans.end_time - trans.start_time;
           
           // Your enhanced collection logic here
       endtask
   endclass
   ```

2. **Add protocol checking**:
   - Check for illegal combinations (simultaneous read/write enables)
   - Verify ready signal behavior
   - Monitor for protocol violations

#### Task 3.2: Advanced Scoreboard
Create an enhanced scoreboard with additional features:

1. **Performance tracking**:
   ```systemverilog
   class register_file_enhanced_scoreboard extends register_file_scoreboard;
       
       // Performance metrics
       int total_reads;
       int total_writes;
       time total_latency;
       time min_latency;
       time max_latency;
       
       virtual function void write_trans(register_file_transaction trans);
           super.write_trans(trans);
           
           // Update performance metrics
           if (trans.operation == READ) begin
               total_reads++;
           end else begin
               total_writes++;
           end
           
           update_latency_stats(trans.latency);
       endfunction
       
       function void update_latency_stats(time latency);
           // TODO: Implement latency statistics
       endfunction
       
       virtual function void report_phase(uvm_phase phase);
           super.report_phase(phase);
           
           // TODO: Report performance statistics
       endfunction
   endclass
   ```

2. **Data integrity checking**:
   - Implement read-after-write verification
   - Add data corruption detection
   - Create register state tracking

#### Task 3.3: Coverage Enhancement
Add comprehensive coverage collection:

```systemverilog
class register_file_enhanced_coverage extends uvm_subscriber#(register_file_transaction);
    
    register_file_transaction trans;
    
    covergroup register_access_cg;
        operation_cp: coverpoint trans.operation {
            bins read_ops = {READ};
            bins write_ops = {WRITE};
        }
        
        address_cp: coverpoint trans.address {
            bins addr_0 = {0};
            bins addr_1 = {1};
            bins addr_2 = {2};
            bins addr_3 = {3};
        }
        
        // TODO: Add more sophisticated coverage
        // - Data pattern coverage
        // - Address sequence coverage
        // - Timing coverage
        // - Cross coverage between different aspects
    endgroup
    
    // TODO: Add protocol coverage group
    // TODO: Add performance coverage group
endclass
```

### Expected Learning Outcomes
- Advanced monitor implementation techniques
- Sophisticated scoreboard design
- Comprehensive coverage modeling

---

## Exercise 4: Advanced Test Scenarios

### Objective
Develop complex test scenarios that stress different aspects of the DUT.

### Tasks

#### Task 4.1: Protocol Violation Test
Create a test that intentionally generates protocol violations to verify error handling:

```systemverilog
class register_file_protocol_test extends register_file_base_test;
    `uvm_component_utils(register_file_protocol_test)
    
    virtual function void run_phase(uvm_phase phase);
        protocol_violation_sequence viol_seq;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "Starting protocol violation test", UVM_LOW)
        
        // TODO: Create sequence that tests:
        // 1. Simultaneous read/write enables
        // 2. Operations when ready is low
        // 3. Invalid address ranges
        // 4. Back-to-back operations without proper timing
        
        viol_seq = protocol_violation_sequence::type_id::create("viol_seq");
        viol_seq.start(env.agent.sequencer);
        
        phase.drop_objection(this);
    endfunction
endclass
```

#### Task 4.2: Power-On Reset Test
Develop a test that verifies proper reset behavior:

```systemverilog
class register_file_reset_test extends register_file_base_test;
    
    virtual function void run_phase(uvm_phase phase);
        // TODO: Implement reset testing
        // 1. Apply reset during operation
        // 2. Verify all registers clear to 0
        // 3. Test multiple reset cycles
        // 4. Verify functionality after reset
    endfunction
endclass
```

#### Task 4.3: Concurrent Access Test
Create a test with overlapping operations:

```systemverilog
class register_file_concurrent_test extends register_file_base_test;
    
    virtual function void run_phase(uvm_phase phase);
        register_file_write_sequence write_seq1, write_seq2;
        register_file_read_sequence read_seq;
        
        phase.raise_objection(this);
        
        // TODO: Implement concurrent testing
        fork
            // Parallel write sequences to different addresses
            // Interleaved read operations
            // Verify data integrity throughout
        join
        
        phase.drop_objection(this);
    endfunction
endclass
```

### Expected Learning Outcomes
- Complex test scenario development
- Error injection and handling verification
- Concurrent operation testing techniques

---

## Exercise 5: Configuration and Reusability

### Objective
Learn to create configurable and reusable verification components.

### Tasks

#### Task 5.1: Configurable Agent
Enhance the agent to support different operation modes:

```systemverilog
typedef enum {
    NORMAL_MODE,
    DEBUG_MODE,
    PERFORMANCE_MODE,
    STRESS_MODE
} agent_mode_e;

class register_file_config extends uvm_object;
    `uvm_object_utils(register_file_config)
    
    agent_mode_e mode = NORMAL_MODE;
    bit enable_protocol_checking = 1;
    bit enable_timing_checks = 1;
    int max_latency_cycles = 10;
    
    // TODO: Add more configuration parameters
endclass

class register_file_agent extends uvm_agent;
    
    register_file_config cfg;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(register_file_config)::get(this, "", "cfg", cfg)) begin
            cfg = register_file_config::type_id::create("cfg");
        end
        
        // Configure components based on cfg
        uvm_config_db#(register_file_config)::set(this, "*", "cfg", cfg);
        
        // TODO: Implement mode-specific component creation
    endfunction
endclass
```

#### Task 5.2: Parameterizable Environment
Create an environment that can be configured for different DUT variants:

```systemverilog
class register_file_env_config extends uvm_object;
    `uvm_object_utils(register_file_env_config)
    
    int num_registers = 4;
    int register_width = 32;
    int address_width = 2;
    bit has_ready_signal = 1;
    
    // TODO: Add configuration for different DUT variants
endclass
```

#### Task 5.3: Factory Override Example
Demonstrate component substitution using UVM factory:

```systemverilog
class debug_register_file_driver extends register_file_driver;
    `uvm_component_utils(debug_register_file_driver)
    
    virtual task drive_transaction(register_file_transaction req);
        `uvm_info(get_type_name(), $sformatf("DEBUG: Driving %s", req.convert2string()), UVM_LOW)
        super.drive_transaction(req);
        `uvm_info(get_type_name(), "DEBUG: Transaction completed", UVM_LOW)
    endtask
endclass

// In test:
class register_file_debug_test extends register_file_base_test;
    
    virtual function void build_phase(uvm_phase phase);
        // Override driver with debug version
        register_file_driver::type_id::set_type_override(debug_register_file_driver::get_type());
        super.build_phase(phase);
    endfunction
endclass
```

### Expected Learning Outcomes
- Configuration-driven verification
- Component reusability techniques
- UVM factory usage and overrides

---

## Exercise 6: Integration and System-Level Testing

### Objective
Integrate the verification environment with larger system contexts.

### Tasks

#### Task 6.1: Multi-Agent Environment
Create an environment with multiple register file agents:

```systemverilog
class multi_register_file_env extends uvm_env;
    
    register_file_agent agents[];
    register_file_scoreboard scoreboards[];
    system_level_scoreboard sys_scoreboard;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // TODO: Create multiple agents and scoreboards
        // Configure each for different register file instances
        agents = new[2];
        scoreboards = new[2];
        
        foreach (agents[i]) begin
            agents[i] = register_file_agent::type_id::create($sformatf("agent_%0d", i), this);
            scoreboards[i] = register_file_scoreboard::type_id::create($sformatf("scoreboard_%0d", i), this);
        end
        
        sys_scoreboard = system_level_scoreboard::type_id::create("sys_scoreboard", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // TODO: Connect agents to respective scoreboards
        // Connect all to system-level scoreboard for cross-checking
    endfunction
endclass
```

#### Task 6.2: System-Level Sequences
Develop sequences that coordinate multiple agents:

```systemverilog
class system_level_sequence extends uvm_sequence;
    
    register_file_env env;
    
    virtual task body();
        register_file_write_sequence write_seq0, write_seq1;
        register_file_read_sequence read_seq0, read_seq1;
        
        // TODO: Implement system-level coordination
        fork
            // Agent 0 operations
            begin
                write_seq0 = register_file_write_sequence::type_id::create("write_seq0");
                write_seq0.start(env.agents[0].sequencer);
            end
            
            // Agent 1 operations
            begin
                write_seq1 = register_file_write_sequence::type_id::create("write_seq1");
                write_seq1.start(env.agents[1].sequencer);
            end
        join
        
        // Cross-agent verification
        fork
            begin
                read_seq0 = register_file_read_sequence::type_id::create("read_seq0");
                read_seq0.start(env.agents[0].sequencer);
            end
            
            begin
                read_seq1 = register_file_read_sequence::type_id::create("read_seq1");
                read_seq1.start(env.agents[1].sequencer);
            end
        join
    endtask
endclass
```

### Expected Learning Outcomes
- Multi-agent environment construction
- System-level verification strategies
- Cross-component interaction testing

---

## Exercise 7: Performance and Debugging

### Objective
Learn advanced debugging techniques and performance optimization.

### Tasks

#### Task 7.1: Simulation Performance Analysis
1. **Measure simulation performance**:
   ```bash
   # Run with timing measurement
   time ./run.bat register_file_basic
   
   # Profile memory usage
   dsim -profile memory register_file.f
   ```

2. **Optimize for speed**:
   - Reduce unnecessary UVM verbosity
   - Optimize sequence randomization
   - Minimize waveform dumping scope

#### Task 7.2: Advanced Debugging Setup
1. **Create debug utilities**:
   ```systemverilog
   class register_file_debug_utilities;
       static function void dump_register_state(virtual register_file_if vif);
           $display("=== Register State Dump ===");
           $display("Time: %0t", $time);
           $display("Ready: %b", vif.ready);
           $display("Write Enable: %b", vif.write_enable);
           $display("Read Enable: %b", vif.read_enable);
           $display("Address: 0x%0h", vif.address);
           $display("Write Data: 0x%0h", vif.write_data);
           $display("Read Data: 0x%0h", vif.read_data);
           $display("========================");
       endfunction
   endclass
   ```

2. **Implement breakpoint functionality**:
   ```systemverilog
   class register_file_breakpoint_monitor extends uvm_monitor;
       
       bit [31:0] breakpoint_address;
       bit [31:0] breakpoint_data;
       bit enable_address_bp;
       bit enable_data_bp;
       
       virtual task run_phase(uvm_phase phase);
           forever begin
               @(posedge vif.clk);
               
               if (enable_address_bp && (vif.address == breakpoint_address)) begin
                   `uvm_info(get_type_name(), "Address breakpoint hit!", UVM_LOW)
                   $stop; // Simulation breakpoint
               end
               
               if (enable_data_bp && (vif.write_data == breakpoint_data)) begin
                   `uvm_info(get_type_name(), "Data breakpoint hit!", UVM_LOW)
                   $stop; // Simulation breakpoint
               end
           end
       endtask
   endclass
   ```

#### Task 7.3: Automated Debug Report Generation
Create a comprehensive debug report generator:

```systemverilog
class register_file_debug_report extends uvm_object;
    
    // Statistics collection
    int total_transactions;
    int read_count;
    int write_count;
    int error_count;
    
    // Timing analysis
    time min_latency;
    time max_latency;
    time avg_latency;
    
    virtual function void generate_report();
        $display("\n=== DEBUG REPORT ===");
        $display("Total Transactions: %0d", total_transactions);
        $display("Reads: %0d (%.1f%%)", read_count, (real'(read_count)/real'(total_transactions))*100.0);
        $display("Writes: %0d (%.1f%%)", write_count, (real'(write_count)/real'(total_transactions))*100.0);
        $display("Errors: %0d", error_count);
        $display("Min Latency: %0t", min_latency);
        $display("Max Latency: %0t", max_latency);
        $display("Avg Latency: %0t", avg_latency);
        $display("===================\n");
    endfunction
endclass
```

### Expected Learning Outcomes
- Simulation performance optimization
- Advanced debugging techniques
- Automated analysis and reporting

---

## Challenge Projects

### Challenge 1: Register File with Interrupt Support
Extend the register file to support interrupt generation:

1. **Add interrupt output to DUT**
2. **Create interrupt agent** for monitoring and control
3. **Develop interrupt-specific sequences**
4. **Implement interrupt scoreboard checking**

### Challenge 2: Register File with DMA Interface
Add DMA (Direct Memory Access) capability:

1. **Design DMA interface**
2. **Create DMA agent and sequences**
3. **Implement multi-interface coordination**
4. **Develop DMA-specific test scenarios**

### Challenge 3: Register File with Error Injection
Implement fault injection capabilities:

1. **Add error injection interface**
2. **Create fault models** (stuck-at, delay faults)
3. **Develop error recovery sequences**
4. **Implement fault coverage analysis**

---

## Learning Assessment

### Self-Assessment Questions

1. **Architecture Understanding**:
   - Can you draw the UVM component hierarchy from memory?
   - Do you understand the data flow from sequence to DUT and back?

2. **Implementation Skills**:
   - Can you create a new sequence without referring to examples?
   - Are you able to modify the scoreboard for new checking requirements?

3. **Debugging Proficiency**:
   - Can you effectively use UVM reporting for debugging?
   - Do you know how to trace transaction flow through the testbench?

4. **Advanced Concepts**:
   - Can you implement factory overrides for component substitution?
   - Do you understand configuration database usage?

### Practical Assessment
Complete these tasks without referring to documentation:

1. **Create a directed test** that writes specific patterns to all registers
2. **Implement a monitor enhancement** that tracks protocol violations
3. **Develop a custom sequence** with complex constraints
4. **Set up factory override** to substitute a component variant

---

## Additional Resources

### Recommended Reading
1. **UVM 1.2 User Guide** - Complete methodology reference
2. **SystemVerilog for Verification** by Chris Spear - Foundational concepts
3. **Writing Testbenches using SystemVerilog** by Janick Bergeron - Advanced techniques

### Online Resources
1. **Verification Academy** - Training courses and articles
2. **UVM Cookbook** - Practical UVM recipes
3. **SystemVerilog Central** - Community discussions and examples

### Tools and Simulators
1. **DSIM** - High-performance SystemVerilog simulator
2. **DVT Eclipse IDE** - Advanced SystemVerilog development environment
3. **Verdi** - Debug and analysis platform

---

## Conclusion

These hands-on exercises provide practical experience with UVM methodology, from basic environment understanding to advanced system-level verification. Each exercise builds upon previous knowledge and introduces new challenges that reflect real-world verification scenarios.

**Remember**: The key to mastering UVM is consistent practice and experimentation. Don't hesitate to modify existing code, break things intentionally to understand error conditions, and always ask "what if" questions to explore edge cases.

Good luck with your UVM learning journey!
