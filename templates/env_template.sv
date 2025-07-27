`timescale 1ns / 1ps

// Register File Environment
// Top-level environment containing all verification components
class register_file_env extends uvm_env;
    
    `uvm_component_utils(register_file_env)
    
    // Environment components
    register_file_agent agent;
    register_file_scoreboard scoreboard;
    
    // Constructor
    function new(string name = "register_file_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create agent
        agent = register_file_agent::type_id::create("agent", this);
        
        // Create scoreboard
        scoreboard = register_file_scoreboard::type_id::create("scoreboard", this);
        
        `uvm_info(get_type_name(), "Environment components created", UVM_MEDIUM)
    endfunction
    
    // Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect agent monitor to scoreboard
        agent.ap.connect(scoreboard.ap);
        
        `uvm_info(get_type_name(), "Environment connections completed", UVM_MEDIUM)
    endfunction

endclass

// Register File Scoreboard
// Simple scoreboard for checking DUT behavior
class register_file_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(register_file_scoreboard)
    
    // Analysis import for receiving transactions from monitor
    uvm_analysis_imp #(register_file_transaction, register_file_scoreboard) ap;
    
    // Reference model - simple register array
    bit [31:0] ref_registers [0:3];
    
    // Statistics
    int write_count = 0;
    int read_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Constructor
    function new(string name = "register_file_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        ap = new("ap", this);
        
        // Initialize reference model
        for (int i = 0; i < 4; i++) begin
            ref_registers[i] = 32'h0;
        end
        
        `uvm_info(get_type_name(), "Scoreboard initialized", UVM_MEDIUM)
    endfunction
    
    // Write function called by analysis port
    virtual function void write(register_file_transaction trans);
        `uvm_info(get_type_name(), $sformatf("Received transaction: %s", trans.convert2string()), UVM_HIGH)
        
        case (trans.operation)
            WRITE: begin
                check_write(trans);
            end
            READ: begin
                check_read(trans);
            end
            default: begin
                `uvm_error(get_type_name(), $sformatf("Unknown operation: %s", trans.operation.name()))
            end
        endcase
    endfunction
    
    // Check write operation
    virtual function void check_write(register_file_transaction trans);
        write_count++;
        
        // Update reference model
        ref_registers[trans.address] = trans.data;
        
        `uvm_info(get_type_name(), 
                 $sformatf("WRITE: addr=0x%0h, data=0x%0h - PASS", 
                          trans.address, trans.data), UVM_MEDIUM)
        pass_count++;
    endfunction
    
    // Check read operation
    virtual function void check_read(register_file_transaction trans);
        bit [31:0] expected_data;
        
        read_count++;
        expected_data = ref_registers[trans.address];
        
        if (trans.data == expected_data) begin
            `uvm_info(get_type_name(), 
                     $sformatf("READ: addr=0x%0h, data=0x%0h, expected=0x%0h - PASS", 
                              trans.address, trans.data, expected_data), UVM_MEDIUM)
            pass_count++;
        end else begin
            `uvm_error(get_type_name(), 
                      $sformatf("READ: addr=0x%0h, data=0x%0h, expected=0x%0h - FAIL", 
                               trans.address, trans.data, expected_data))
            fail_count++;
        end
    endfunction
    
    // Report phase
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "=== SCOREBOARD SUMMARY ===", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Writes: %0d", write_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Reads:  %0d", read_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("PASS Count:   %0d", pass_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("FAIL Count:   %0d", fail_count), UVM_LOW)
        
        if (fail_count == 0) begin
            `uvm_info(get_type_name(), "*** TEST PASSED ***", UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), "*** TEST FAILED ***")
        end
    endfunction

endclass
