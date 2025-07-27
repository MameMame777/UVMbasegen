`timescale 1ns / 1ps

// Register File Driver
// Drives stimulus to the DUT through the virtual interface
class register_file_driver extends uvm_driver #(register_file_transaction);
    
    `uvm_component_utils(register_file_driver)
    
    // Virtual interface handle
    virtual register_file_if vif;
    
    // Constructor
    function new(string name = "register_file_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - get virtual interface from config DB
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(virtual register_file_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
        end
    endfunction
    
    // Run phase - main driver functionality
    virtual task run_phase(uvm_phase phase);
        register_file_transaction req;
        
        // Initialize interface signals
        init_signals();
        
        // Wait for reset deassertion
        wait_for_reset();
        
        // Main driver loop
        forever begin
            // Get next transaction from sequencer
            seq_item_port.get_next_item(req);
            
            `uvm_info(get_type_name(), $sformatf("Driving transaction: %s", req.convert2string()), UVM_HIGH)
            
            // Drive the transaction
            drive_transaction(req);
            
            // Signal completion to sequencer
            seq_item_port.item_done();
        end
    endtask
    
    // Initialize interface signals
    virtual task init_signals();
        vif.driver_cb.reset <= 1'b1;
        vif.driver_cb.write_enable <= 1'b0;
        vif.driver_cb.address <= 2'b00;
        vif.driver_cb.write_data <= 32'h0;
        vif.driver_cb.read_enable <= 1'b0;
        
        `uvm_info(get_type_name(), "Interface signals initialized", UVM_HIGH)
    endtask
    
    // Wait for reset deassertion
    virtual task wait_for_reset();
        `uvm_info(get_type_name(), "Waiting for reset deassertion...", UVM_MEDIUM)
        
        // Apply reset for a few cycles
        repeat (5) @(vif.driver_cb);
        vif.driver_cb.reset <= 1'b0;
        
        // Wait for ready signal
        wait (vif.driver_cb.ready == 1'b1);
        `uvm_info(get_type_name(), "Reset deasserted and DUT ready", UVM_MEDIUM)
    endtask
    
    // Drive a single transaction
    virtual task drive_transaction(register_file_transaction req);
        case (req.operation)
            READ: begin
                drive_read(req.address);
                req.data = vif.driver_cb.read_data;
            end
            WRITE: begin
                drive_write(req.address, req.data);
            end
            default: begin
                `uvm_error(get_type_name(), $sformatf("Unknown operation: %s", req.operation.name()))
            end
        endcase
        
        req.ready = vif.driver_cb.ready;
    endtask
    
    // Drive read operation
    virtual task drive_read(bit [1:0] addr);
        `uvm_info(get_type_name(), $sformatf("Driving READ from address 0x%0h", addr), UVM_HIGH)
        
        @(vif.driver_cb);
        vif.driver_cb.address <= addr;
        vif.driver_cb.read_enable <= 1'b1;
        vif.driver_cb.write_enable <= 1'b0;
        
        @(vif.driver_cb);
        vif.driver_cb.read_enable <= 1'b0;
        
        `uvm_info(get_type_name(), $sformatf("READ completed, data=0x%0h", vif.driver_cb.read_data), UVM_HIGH)
    endtask
    
    // Drive write operation
    virtual task drive_write(bit [1:0] addr, bit [31:0] data);
        `uvm_info(get_type_name(), $sformatf("Driving WRITE to address 0x%0h, data=0x%0h", addr, data), UVM_HIGH)
        
        @(vif.driver_cb);
        vif.driver_cb.address <= addr;
        vif.driver_cb.write_data <= data;
        vif.driver_cb.write_enable <= 1'b1;
        vif.driver_cb.read_enable <= 1'b0;
        
        @(vif.driver_cb);
        vif.driver_cb.write_enable <= 1'b0;
        
        `uvm_info(get_type_name(), "WRITE completed", UVM_HIGH)
    endtask

endclass
