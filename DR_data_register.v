`timescale 1ns / 1ps

module DR_data_register(
    input wire clk_clock,

    input wire [7:0] DR_input,
    output reg [7:0] DR_output  
    );
reg [7:0] DR;
initial begin
    DR <= 8'h00;
end

always @(*) begin
    DR_output <= DR_input;
end

endmodule
