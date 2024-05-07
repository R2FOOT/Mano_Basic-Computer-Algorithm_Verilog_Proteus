`timescale 1ns / 1ps

module AC_accumulator(
    input wire CLK,
    input wire [7:0] input_data,
    input wire LD_load,   
    input CLR_clear,
    input COM_complement,
    input CIR_circulateR,
    input CIL_circulateL,
    output reg [7:0] AC_output
    );
reg [7:0] AC;

initial begin
    AC <= 8'h98;
end

always @(posedge CLK) begin
    AC_output = AC;
end

always @(posedge LD_load) begin
    AC <= input_data;
    AC_output = AC;
end

always @(posedge CLR_clear) begin
    AC = 8'h00;
    AC_output = AC;
end

always @(posedge COM_complement) begin
    AC = ~AC;
    AC_output = AC;
end

always @(posedge CIR_circulateR) begin
    AC = {AC[0], AC[7:1]};
    AC_output = AC;
end

always @(posedge CIL_circulateL) begin
    AC = {AC[6:0], AC[7]};
    AC_output = AC;
end

endmodule
