`timescale 1ns / 1ps

module IR_instruction_register(
    input [7:0] input_data,   
    input wire T1,                 
    input wire T2,                  
    output reg [3:0] address_register,   
    output reg [7:0] D,            
    output reg I                    
);

reg [7:0] instruction_register = 8'b0;
reg [2:0] OPcode;

always @(posedge T1) begin
    instruction_register <= input_data; 
end

always @(posedge T2) begin
    address_register <= instruction_register[3:0];
    I <= instruction_register[7]; 
    OPcode <= instruction_register[6:4];
    case (OPcode)
        3'b000: D <= 8'h01; 
        3'b001: D <= 8'h02;  
        3'b010: D <= 8'h04; 
        3'b011: D <= 8'h08; 
        3'b100: D <= 8'h10; 
        3'b101: D <= 8'h20; 
        3'b110: D <= 8'h40;
        3'b111: D <= 8'h80; 
        default: D <= 8'h00; 
    endcase
end

endmodule