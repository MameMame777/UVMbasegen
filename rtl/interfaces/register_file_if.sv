`timescale 1ns / 1ps

// Register File Interface
// Interface for connecting UVM testbench to register file DUT
interface register_file_if (input logic clk);
    
    // Interface signals
    logic        reset;
    logic        write_enable;
    logic [1:0]  address;
    logic [31:0] write_data;
    logic        read_enable;
    logic [31:0] read_data;
    logic        ready;
    
    // Clocking block for driver
    // Driver outputs stimulus to DUT
    clocking driver_cb @(posedge clk);
        output reset, write_enable, address, write_data, read_enable;
        input  read_data, ready;
    endclocking
    
    // Clocking block for monitor
    // Monitor observes all signals for checking and coverage
    clocking monitor_cb @(posedge clk);
        input reset, write_enable, address, write_data, read_enable, read_data, ready;
    endclocking
    
    // Modports for different UVM components
    modport driver_mp (clocking driver_cb);
    modport monitor_mp (clocking monitor_cb);
    modport dut_mp (
        input  clk, reset, write_enable, address, write_data, read_enable,
        output read_data, ready
    );

endinterface
