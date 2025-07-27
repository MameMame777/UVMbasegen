`timescale 1ns / 1ps

// Import UVM macros (available with -uvm flag in DSIM)
`include "uvm_macros.svh"
// Include the UVM package file directly
`include "{module_name}_pkg.sv"

// {module_name} Testbench Top
// Top-level testbench module connecting DUT, interface, and UVM test
module {module_name}_tb;
    
    // Clock and reset generation
    logic clk;
    logic reset;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end
    
    // Reset generation
    initial begin
        reset = 1;
        #50ns;
        reset = 0;
    end
    
    // Interface instantiation
    register_file_if vif(clk);
    
    // DUT instantiation
    register_file dut (
        .clk(clk),
        .reset(vif.reset),
        .write_enable(vif.write_enable),
        .address(vif.address),
        .write_data(vif.write_data),
        .read_enable(vif.read_enable),
        .read_data(vif.read_data),
        .ready(vif.ready)
    );
    
    // UVM testbench initialization
    initial begin
        // Set interface in config DB for UVM components
        uvm_config_db#(virtual register_file_if)::set(null, "*", "vif", vif);
        
        // Enable wave dumping (MXD format for DSIM)
        $dumpfile("register_file_tb.mxd");
        $dumpvars(0, register_file_tb);
        
        // Run the test
        run_test();
    end
    
    // Timeout mechanism
    initial begin
        #10ms;
        `uvm_fatal("TIMEOUT", "Test timeout after 10ms")
    end

endmodule
