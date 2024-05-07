`timescale 1ns / 1ps

module RAM(
    input wire [3:0] address,
    input wire CLK,
    input wire R_W,
    inout wire [7:0] Data_Bus
    );
    reg [7:0] temp_data;
    reg [7:0] stored_memory_bytes[15:0];
    
    initial begin
    $readmemh("D:/memory_content.txt", stored_memory_bytes);
    end
    
    always @(posedge CLK) begin
        if(!R_W) begin
            stored_memory_bytes[address] = Data_Bus;
        end else begin
            temp_data = stored_memory_bytes[address];
        end
    end

    assign Data_Bus = R_W ? temp_data : 8'hzz;

endmodule