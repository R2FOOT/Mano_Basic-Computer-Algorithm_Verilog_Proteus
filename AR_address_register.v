`timescale 1ns / 1ps


module AR_address_register(
    input wire clk_clock,
    input wire INR_increment,
    input wire CLR_clear,
    input LD_load,
    input wire [3:0] AR_input,
    output reg [3:0] AR_output    
);
reg [3:0] AR;    
/*
initial begin
    AR = 4'b0000;
end
*/
always @(posedge clk_clock or CLR_clear or INR_increment or LD_load) begin
    if(CLR_clear) begin
        AR <= 4'b0;
    end else if(INR_increment) begin
        AR = AR + 1;
    end else if (LD_load) begin
        AR = AR_input;
    end
    AR_output = AR;
end
endmodule
