`timescale 1ns / 1ps

module register_reference_instructions(
    input wire CLK,
    input wire r,
    input wire T3,
    input [3:0] B,
    output reg clear_AC,
    output reg COM_AC,
    output reg CIR_AC,
    output reg CIL_AC
    );
initial begin
    clear_AC = 0;
    COM_AC = 0;
    CIR_AC = 0;
    CIL_AC = 0;
end

    always @(posedge T3) begin
    if(r == 1) begin
        if (B[0]) begin
            clear_AC = 1;
            #1 clear_AC = 0;
        end else if (B[1]) begin
            COM_AC = 1;
            #1 COM_AC = 0;
        end else if (B[2]) begin
            CIR_AC = 1;
            #1 CIR_AC = 0;
        end else if (B[3]) begin
            CIL_AC = 1;
            #1 CIL_AC = 0;
        end       
    end
    
end
endmodule
