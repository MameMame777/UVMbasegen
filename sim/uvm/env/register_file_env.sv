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
