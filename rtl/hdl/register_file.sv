`timescale 1ns / 1ps

// Register File Module - 4 x 32-bit registers
// Simple register file with synchronous reset and separate read/write enables
module register_file (
    input  logic        clk,
    input  logic        reset,          // Active high synchronous reset
    input  logic        write_enable,   // Write enable
    input  logic [1:0]  address,        // Register address (0-3)
    input  logic [31:0] write_data,     // Data to write
    input  logic        read_enable,    // Read enable
    output logic [31:0] read_data,      // Read data output
    output logic        ready           // Ready signal
);

    // Internal register array
    logic [31:0] registers [0:3];
    
    // Ready signal generation (simple: always ready after reset)
    always_ff @(posedge clk) begin
        if (reset) begin
            ready <= 1'b0;
        end else begin
            ready <= 1'b1;
        end
    end
    
    // Write operation
    always_ff @(posedge clk) begin
        if (reset) begin
            registers[0] <= 32'h0;
            registers[1] <= 32'h0;
            registers[2] <= 32'h0;
            registers[3] <= 32'h0;
        end else if (write_enable && ready) begin
            registers[address] <= write_data;
        end
    end
    
    // Read operation (combinational)
    always_comb begin
        if (read_enable && ready && !reset) begin
            read_data = registers[address];
        end else begin
            read_data = 32'h0;
        end
    end

endmodule
