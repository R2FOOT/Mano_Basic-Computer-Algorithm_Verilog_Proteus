`timescale 1ns / 1ps

module sequence_counter(
    input wire CLK,
    input wire CLR,
    output reg [7:0] T
    );
    
    reg [2:0] count; 
    
    initial begin
        count = 3'b000;
    end
    
    always @(posedge CLK or posedge CLR) begin
        if(CLR) begin
            count <= 3'b000;
        end else begin
            count <= count + 1;
        end
    end
    
    always @(posedge CLK) begin
        case(count)
            3'b000: T = 8'b00000001; 
            3'b001: T = 8'b00000010; 
            3'b010: T = 8'b00000100; 
            3'b011: T = 8'b00001000; 
            3'b100: T = 8'b00010000; 
            3'b101: T = 8'b00100000; 
            3'b110: T = 8'b01000000; 
            3'b111: T = 8'b10000000; 
            default: T = 8'b00000000; 
        endcase
    end
endmodule