`timescale 1ns / 1ps

module PC_program_counter(
    input wire clk_clock,
    input wire INR_increment,
    input wire CLR_clear,
    input wire LD_load,
    input wire [3:0] PC_input,
    output reg [3:0] PC_output    
    );
    reg [3:0] PC;    
    initial begin
        PC = 4'b0000;
        PC_output = 4'b0000;
    end
    
always @(posedge CLR_clear)
begin
    PC <= 4'b0;
    PC_output = PC;
end

always @(posedge INR_increment)
begin
    PC = PC + 1;
    PC_output = PC;
end

always @(posedge LD_load)
begin
    PC = PC_input;
    PC_output = PC;
end

endmodule
