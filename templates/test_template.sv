`timescale 1ns / 1ps

// Register File Base Test
// Base test class containing common functionality
class register_file_base_test extends uvm_test;
    
    `uvm_component_utils(register_file_base_test)
    
    // Test environment
    register_file_env env;
    
    // Constructor
    function new(string name = "register_file_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create environment
        env = register_file_env::type_id::create("env", this);
        
        `uvm_info(get_type_name(), "Base test build completed", UVM_MEDIUM)
    endfunction
    
    // End of elaboration phase
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass

// Basic Register File Test
// Simple test with write and read operations
class register_file_basic_test extends register_file_base_test;
    
    `uvm_component_utils(register_file_basic_test)
    
    function new(string name = "register_file_basic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        register_file_write_sequence write_seq;
        register_file_read_sequence read_seq;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "Starting basic test", UVM_LOW)
        
        // Write to all registers
        for (int i = 0; i < 4; i++) begin
            write_seq = register_file_write_sequence::type_id::create("write_seq");
            write_seq.target_address = i;
            write_seq.write_value = 32'hDEADBEEF + i;
            write_seq.start(env.agent.sequencer);
        end
        
        // Small delay
        #100ns;
        
        // Read from all registers
        for (int i = 0; i < 4; i++) begin
            read_seq = register_file_read_sequence::type_id::create("read_seq");
            read_seq.target_address = i;
            read_seq.start(env.agent.sequencer);
        end
        
        #100ns;
        
        `uvm_info(get_type_name(), "Basic test completed", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass

// Random Register File Test
// Test with random operations
class register_file_random_test extends register_file_base_test;
    
    `uvm_component_utils(register_file_random_test)
    
    function new(string name = "register_file_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        register_file_random_sequence rand_seq;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "Starting random test", UVM_LOW)
        
        // Run random sequence
        rand_seq = register_file_random_sequence::type_id::create("rand_seq");
        if (!rand_seq.randomize() with { num_transactions == 20; }) begin
            `uvm_fatal(get_type_name(), "Random sequence randomization failed")
        end
        rand_seq.start(env.agent.sequencer);
        
        #1000ns;
        
        `uvm_info(get_type_name(), "Random test completed", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
