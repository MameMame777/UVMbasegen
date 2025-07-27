`timescale 1ns / 1ps

// UVM testbench for {module_name}
// Uses DSIM built-in UVM library with -uvm flag

// Import UVM package and custom package
import uvm_pkg::*;
import {module_name}_pkg::*;

// {module_name} Testbench Top
// Top-level testbench module connecting DUT, interface, and UVM test
module {module_name}_tb;
    
    // Clock generation
    logic clk;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end
    
    // Interface instantiation
    {interface_name} vif(clk);
    
    // DUT instantiation - all signals come from interface
    {module_name} dut (
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
