`timescale 1ns / 1ps

// Register File Base Sequence
// Base sequence class for register file operations
class register_file_sequence extends uvm_sequence #(register_file_transaction);
    
    `uvm_object_utils(register_file_sequence)
    
    // Constructor
    function new(string name = "register_file_sequence");
        super.new(name);
    endfunction
    
    // Main body task - to be overridden by derived sequences
    virtual task body();
        `uvm_info(get_type_name(), "Starting register_file_sequence", UVM_MEDIUM)
    endtask

endclass

// Basic Write Sequence
class register_file_write_sequence extends register_file_sequence;
    
    `uvm_object_utils(register_file_write_sequence)
    
    rand bit [1:0]  target_address;
    rand bit [31:0] write_value;
    
    constraint addr_c { target_address inside {[0:3]}; }
    
    function new(string name = "register_file_write_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        register_file_transaction req;
        
        `uvm_info(get_type_name(), $sformatf("Writing 0x%0h to address 0x%0h", write_value, target_address), UVM_MEDIUM)
        
        req = register_file_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            operation == WRITE;
            address == target_address;
            data == write_value;
        }) begin
            `uvm_fatal(get_type_name(), "Randomization failed")
        end
        finish_item(req);
    endtask

endclass

// Basic Read Sequence
class register_file_read_sequence extends register_file_sequence;
    
    `uvm_object_utils(register_file_read_sequence)
    
    rand bit [1:0] target_address;
    
    constraint addr_c { target_address inside {[0:3]}; }
    
    function new(string name = "register_file_read_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        register_file_transaction req;
        
        `uvm_info(get_type_name(), $sformatf("Reading from address 0x%0h", target_address), UVM_MEDIUM)
        
        req = register_file_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            operation == READ;
            address == target_address;
        }) begin
            `uvm_fatal(get_type_name(), "Randomization failed")
        end
        finish_item(req);
    endtask

endclass

// Random Test Sequence
class register_file_random_sequence extends register_file_sequence;
    
    `uvm_object_utils(register_file_random_sequence)
    
    rand int num_transactions;
    
    constraint num_trans_c { num_transactions inside {[10:50]}; }
    
    function new(string name = "register_file_random_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        register_file_transaction req;
        
        `uvm_info(get_type_name(), $sformatf("Starting random sequence with %0d transactions", num_transactions), UVM_MEDIUM)
        
        for (int i = 0; i < num_transactions; i++) begin
            req = register_file_transaction::type_id::create($sformatf("req_%0d", i));
            start_item(req);
            if (!req.randomize()) begin
                `uvm_fatal(get_type_name(), "Randomization failed")
            end
            finish_item(req);
        end
    endtask

endclass
