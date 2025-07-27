`timescale 1ns / 1ps

// Register File Agent
// Contains driver, monitor, and sequencer for complete interface management
class register_file_agent extends uvm_agent;
    
    `uvm_component_utils(register_file_agent)
    
    // Agent components
    register_file_driver    driver;
    register_file_monitor   monitor;
    uvm_sequencer #(register_file_transaction) sequencer;
    
    // Analysis port (from monitor)
    uvm_analysis_port #(register_file_transaction) ap;
    
    // Configuration
    bit is_active = 1;  // 1 for active agent (has driver), 0 for passive
    
    // Constructor
    function new(string name = "register_file_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration if available
        void'(uvm_config_db#(int)::get(this, "", "is_active", is_active));
        
        // Always create monitor
        monitor = register_file_monitor::type_id::create("monitor", this);
        
        // Create driver and sequencer only for active agents
        if (is_active) begin
            driver = register_file_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer#(register_file_transaction)::type_id::create("sequencer", this);
        end
        
        `uvm_info(get_type_name(), $sformatf("Agent created as %s", is_active ? "ACTIVE" : "PASSIVE"), UVM_MEDIUM)
    endfunction
    
    // Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor analysis port to agent analysis port
        ap = monitor.ap;
        
        // Connect driver to sequencer (only for active agents)
        if (is_active) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
    
    // Set virtual interface for all components
    virtual function void set_interface(virtual register_file_if vif);
        uvm_config_db#(virtual register_file_if)::set(this, "monitor", "vif", vif);
        
        if (is_active) begin
            uvm_config_db#(virtual register_file_if)::set(this, "driver", "vif", vif);
        end
    endfunction

endclass
