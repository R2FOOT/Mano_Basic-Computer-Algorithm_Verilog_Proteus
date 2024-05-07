`timescale 1ns / 1ps

module test_bench;

reg CLK;
wire [7:0] timing_signals;
reg [7:0] timing;

reg PC_INC; 
reg PC_CLR; 
reg PC_LD; 
reg [3:0] PC_IN;
wire [3:0] PC_OUT;

reg AR_INC; 
reg AR_CLR; 
reg AR_LD; 
reg [3:0] AR_IN;
wire [3:0] AR_OUT;

reg RW_memory;
reg [7:0] DataIN_tb;
wire [7:0] DataBus_tb;

//reg IR_INC; 
//reg IR_CLR; 
//reg IR_LD; 
//reg [7:0] IR_IN;
//reg [3:0] IR_address_nibble;
reg [7:0] Decoded_OPcode;
reg I_bit;

reg r;
reg indirect_memory;
reg direct_memory;

wire AC_CLR;
wire AC_COM;
wire AC_CIR;
wire AC_CIL;
reg [7:0] AC_IN;
reg AC_LD;
wire [7:0] AC_OUT;

reg DR_INC; 
reg DR_CLR; 
reg DR_LD; 
reg [7:0] DR_IN;
wire [7:0] DR_OUT;


initial begin
    //timing = 8'b0;
    
    CLK = 1'b1;
    
    PC_INC = 1'b0;
    PC_CLR = 1'b0;
    PC_LD  = 1'b0;
    PC_IN  = 4'b0;
    
    AR_INC = 1'b0;
    AR_CLR = 1'b0;
    AR_LD  = 1'b0;
    
    AC_LD = 1'b0;
end

always #5 CLK = ~CLK;

sequence_counter SC (
    .CLK(CLK),
    .CLR(r),
    .T(timing_signals)
);

PC_program_counter PC (
    .clk_clock(CLK),
    .INR_increment(PC_INC),
    .CLR_clear(PC_CLR),
    .LD_load(PC_LD),
    .PC_input(PC_IN),
    .PC_output(PC_OUT)   
);

AR_address_register AR (
    .clk_clock(CLK),
    .INR_increment(AR_INC),
    .CLR_clear(AR_CLR),
    .LD_load(AR_LD),
    .AR_input(AR_IN),
    .AR_output(AR_OUT)   
);
/*
IR_instruction_register IR(
    .input_data(DataBus_tb),   
    .T1(timing[1]),                 
    .T2(timing[2]),                  
    .address_register(IR_address_nibble),   
    .D(Decoded_OPcode),            
    .I(I_bit)                 
);
*/
RAM ram_t(
    .address(AR_OUT),
    .CLK(CLK),
    .R_W(RW_memory),
    .Data_Bus(DataBus_tb)
);

register_reference_instructions AC_instructions(
    .CLK(CLK),
    .r(r),
    .B(AR_OUT),
    .clear_AC(AC_CLR),
    .COM_AC(AC_COM),
    .CIR_AC(AC_CIR),
    .CIL_AC(AC_CIL)
    );
    
AC_accumulator AC(
    .CLK(CLK),
    .input_data(AC_IN),
    .LD_load(AC_LD),   
    .CLR_clear(AC_CLR),
    .COM_complement(AC_COM),
    .CIR_circulateR(AC_CIR),
    .CIL_circulateL(AC_CIL),
    .AC_output(AC_OUT)
);

    
DR_data_register DR(
    .clk_clock(CLK),
    //.INR_increment(DR_INC),
    //.CLR_clear(DR_CLR),
    //.LD_load(DR_LD),
    .DR_input(DR_IN),
    .DR_output(DR_OUT) 
);

assign DataBus_tb = RW_memory ? 'hzz : DataIN_tb;

always @(posedge CLK) begin
    timing = timing_signals;
    r = Decoded_OPcode[7] && timing[3] && (~I_bit);
    indirect_memory = (~Decoded_OPcode[7]) && timing[3] && I_bit;
    direct_memory = (~Decoded_OPcode[7]) && timing[3] && (~I_bit);
end 

always @(posedge timing[0])
begin
    AR_IN <= PC_OUT;
    AR_LD <= 1'b1;
    #1 AR_LD <= 1'b0;  
end
always @(posedge timing[1])
begin
    RW_memory = 1'b1;
    PC_INC <= 1'b1;
    #1 PC_INC <= 1'b0; 
end

always @(posedge timing[2])
begin
    AR_IN <= DataBus_tb[3:0];
    I_bit <= DataBus_tb[7];
    case (DataBus_tb[6:4])
        3'b000: Decoded_OPcode <= 8'h01; 
        3'b001: Decoded_OPcode <= 8'h02;  
        3'b010: Decoded_OPcode <= 8'h04; 
        3'b011: Decoded_OPcode <= 8'h08; 
        3'b100: Decoded_OPcode <= 8'h10; 
        3'b101: Decoded_OPcode <= 8'h20; 
        3'b110: Decoded_OPcode <= 8'h40;
        3'b111: Decoded_OPcode <= 8'h80; 
        default: Decoded_OPcode <= 8'h00; 
    endcase 
    AR_LD <= 1'b1;
    #1 AR_LD <= 1'b0;       
end

always @(posedge indirect_memory) 
begin   
    AR_IN <= DataBus_tb[3:0];
    AR_LD <= 1'b1;
    #1 AR_LD <= 1'b0; 
end

always @(posedge direct_memory)
begin
    #10;
end

always @(posedge timing[4])
    begin
        if(Decoded_OPcode[0] || Decoded_OPcode[1] || Decoded_OPcode[2]) begin
            AR_IN <= DataBus_tb[3:0];
            AR_LD <= 1'b1;
            #1 
            DR_IN <= DataBus_tb[3:0];
            AR_LD <= 1'b0;
        end else if (Decoded_OPcode[3]) begin   // STA (Store Accumulator)
           RW_memory <= 1'b0;
           DataIN_tb <= AC_OUT;
           r <= 1'b1;
           #1 r <= 1'b0;
           #9 RW_memory <= 1'b1;
        end else if (Decoded_OPcode[4]) begin   // BUN (Branch)
           PC_IN <= AR_OUT;
           PC_LD <= 1'b1;
           r <= 1'b1;
           #1 PC_LD <= 1'b0;
           r <= 1'b0;
        end 
end 
always @(posedge timing[5]) begin
    if(Decoded_OPcode[0]) begin      //AND (and logical operation)
        AC_LD <= 1'b1;
        AC_IN <= AC_OUT & DR_OUT;
        r <= 1'b1;
        #1 AC_LD <= 1'b0;
        r <= 1'b0;
    end else if(Decoded_OPcode[1]) begin  // ADD (sum operation)
        AC_LD <= 1'b1;
        AC_IN <= AC_OUT + DR_OUT;
        r <= 1'b1;
        #1 AC_LD <= 1'b0;
        r <= 1'b0;   
    end else if(Decoded_OPcode[2]) begin  // LDA (load accumulator)
        AC_LD <= 1'b1;  
        AC_IN <= DR_OUT;
        r <= 1'b1;
        #1 AC_LD <= 1'b0;
        r <= 1'b0; 
    end
end

  
endmodule

