`timescale 1ns / 1ps

// {module_name} Scoreboard
// Simple scoreboard for checking DUT behavior with reference model
class {module_name}_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils({module_name}_scoreboard)
    
    // Analysis import for receiving transactions from monitor
    uvm_analysis_imp #({module_name}_transaction, {module_name}_scoreboard) ap;
    
    // Reference model - simple register array
    bit [31:0] ref_registers [0:3];
    
    // Statistics
    int write_count = 0;
    int read_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Constructor
    function new(string name = "{module_name}_scoreboard", uvm_component parent = null);
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
    virtual function void write({module_name}_transaction trans);
        `uvm_info(get_type_name(), $sformatf("Received transaction: %s", trans.convert2string()), UVM_HIGH)
        
        case (trans.operation)
            {module_name}_transaction::WRITE: begin
                check_write(trans);
            end
            {module_name}_transaction::READ: begin
                check_read(trans);
            end
            default: begin
                `uvm_error(get_type_name(), $sformatf("Unknown operation: %s", trans.operation.name()))
            end
        endcase
    endfunction
    
    // Check write operation
    virtual function void check_write({module_name}_transaction trans);
        write_count++;
        
        // Update reference model
        ref_registers[trans.address] = trans.data;
        
        `uvm_info(get_type_name(), 
                 $sformatf("WRITE: addr=0x%0h, data=0x%0h - PASS", 
                          trans.address, trans.data), UVM_MEDIUM)
        pass_count++;
    endfunction
    
    // Check read operation
    virtual function void check_read({module_name}_transaction trans);
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
