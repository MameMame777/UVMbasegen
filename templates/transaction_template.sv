`timescale 1ns / 1ps

// Register File Transaction Class
// Defines the transaction item for register file operations
class register_file_transaction extends uvm_sequence_item;
    
    // Transaction fields
    typedef enum {READ, WRITE} operation_t;
    
    rand operation_t operation;     // READ or WRITE operation
    rand bit [1:0]   address;       // Register address (0-3)
    rand bit [31:0]  data;          // Data for read/write
    bit              ready;         // Ready signal status
    
    // UVM automation macros
    `uvm_object_utils_begin(register_file_transaction)
        `uvm_field_enum(operation_t, operation, UVM_DEFAULT)
        `uvm_field_int(address, UVM_DEFAULT)
        `uvm_field_int(data, UVM_DEFAULT)
        `uvm_field_int(ready, UVM_DEFAULT)
    `uvm_object_utils_end
    
    // Constructor
    function new(string name = "register_file_transaction");
        super.new(name);
    endfunction
    
    // Constraints
    constraint valid_address {
        address inside {[0:3]};
    }
    
    constraint data_constraint {
        data inside {[0:32'hFFFFFFFF]};
    }
    
    // Convert to string for debugging
    virtual function string convert2string();
        string s;
        s = $sformatf("operation=%s, address=0x%0h, data=0x%0h, ready=%0b",
                     operation.name(), address, data, ready);
        return s;
    endfunction
    
    // Deep copy
    virtual function void do_copy(uvm_object rhs);
        register_file_transaction rhs_;
        if (!$cast(rhs_, rhs)) begin
            `uvm_fatal("do_copy", "Cast failed")
        end
        super.do_copy(rhs);
        operation = rhs_.operation;
        address = rhs_.address;
        data = rhs_.data;
        ready = rhs_.ready;
    endfunction
    
    // Compare function
    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        register_file_transaction rhs_;
        if (!$cast(rhs_, rhs)) begin
            `uvm_error("do_compare", "Cast failed")
            return 0;
        end
        return (super.do_compare(rhs, comparer) &&
                (operation == rhs_.operation) &&
                (address == rhs_.address) &&
                (data == rhs_.data) &&
                (ready == rhs_.ready));
    endfunction

endclass
