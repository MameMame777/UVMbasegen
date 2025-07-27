`timescale 1ns / 1ps

// Register File Scoreboard
// Compares expected vs actual results
class register_file_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(register_file_scoreboard)
    
    // Analysis imports from monitor
    uvm_analysis_imp #(register_file_transaction, register_file_scoreboard) analysis_export;
    
    // Reference model storage
    logic [31:0] register_model [0:255];
    
    // Constructor
    function new(string name = "register_file_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction
    
    // Initialize reference model
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Initialize register model
        for (int i = 0; i < 256; i++) begin
            register_model[i] = 32'h0;
        end
    endfunction
    
    // Analysis function - called by monitor
    virtual function void write(register_file_transaction t);
        if (t.operation == register_file_transaction::WRITE) begin
            // Update reference model
            register_model[t.address] = t.data;
            `uvm_info(get_type_name(), $sformatf("WRITE: addr=0x%02x, data=0x%08x", t.address, t.data), UVM_LOW)
        end else if (t.operation == register_file_transaction::READ) begin
            // Check against reference model
            if (register_model[t.address] == t.data) begin
                `uvm_info(get_type_name(), $sformatf("READ PASS: addr=0x%02x, exp=0x%08x, act=0x%08x", 
                    t.address, register_model[t.address], t.data), UVM_LOW)
            end else begin
                `uvm_error(get_type_name(), $sformatf("READ FAIL: addr=0x%02x, exp=0x%08x, act=0x%08x", 
                    t.address, register_model[t.address], t.data))
            end
        end
    endfunction
    
endclass

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
        agent.ap.connect(scoreboard.analysis_export);
        
        `uvm_info(get_type_name(), "Environment connections completed", UVM_MEDIUM)
    endfunction

endclass
