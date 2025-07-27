`timescale 1ns / 1ps

// Register File Monitor
// Monitors interface activity and sends transactions to scoreboard
class register_file_monitor extends uvm_monitor;
    
    `uvm_component_utils(register_file_monitor)
    
    // Virtual interface handle
    virtual register_file_if vif;
    
    // Analysis port for sending transactions to scoreboard
    uvm_analysis_port #(register_file_transaction) ap;
    
    // Constructor
    function new(string name = "register_file_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config DB
        if (!uvm_config_db#(virtual register_file_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
        end
        
        // Create analysis port
        ap = new("ap", this);
    endfunction
    
    // Run phase - main monitoring functionality
    virtual task run_phase(uvm_phase phase);
        register_file_transaction trans;
        
        `uvm_info(get_type_name(), "Monitor started", UVM_MEDIUM)
        
        // Wait for reset deassertion
        wait (vif.monitor_cb.reset == 1'b0);
        `uvm_info(get_type_name(), "Reset deasserted, starting monitoring", UVM_MEDIUM)
        
        // Main monitoring loop
        forever begin
            // Wait for activity on interface
            @(vif.monitor_cb);
            
            // Check for read or write operations
            if (vif.monitor_cb.ready) begin
                if (vif.monitor_cb.write_enable) begin
                    trans = monitor_write();
                    if (trans != null) begin
                        ap.write(trans);
                    end
                end else if (vif.monitor_cb.read_enable) begin
                    trans = monitor_read();
                    if (trans != null) begin
                        ap.write(trans);
                    end
                end
            end
        end
    endtask
    
    // Monitor write operation
    virtual function register_file_transaction monitor_write();
        register_file_transaction trans;
        
        trans = register_file_transaction::type_id::create("monitored_write_trans");
        trans.operation = register_file_transaction::WRITE;
        trans.address = vif.monitor_cb.address;
        trans.data = vif.monitor_cb.write_data;
        trans.ready = vif.monitor_cb.ready;
        
        `uvm_info(get_type_name(), $sformatf("Monitored WRITE: %s", trans.convert2string()), UVM_HIGH)
        
        return trans;
    endfunction
    
    // Monitor read operation
    virtual function register_file_transaction monitor_read();
        register_file_transaction trans;
        
        trans = register_file_transaction::type_id::create("monitored_read_trans");
        trans.operation = register_file_transaction::READ;
        trans.address = vif.monitor_cb.address;
        trans.data = vif.monitor_cb.read_data;
        trans.ready = vif.monitor_cb.ready;
        
        `uvm_info(get_type_name(), $sformatf("Monitored READ: %s", trans.convert2string()), UVM_HIGH)
        
        return trans;
    endfunction

endclass
