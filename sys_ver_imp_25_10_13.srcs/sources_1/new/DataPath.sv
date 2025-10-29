`timescale 1ns / 1ps

`include "defines.sv"

/*
module DataPath(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instrCode,
    input  logic        regFileWe,
    input  logic        aluSrcMuxSel,
    input  logic [3:0]  aluControl,
    output logic [31:0] instrMemAddr
);
    logic [31:0] RFData1, RFData2, aluResult;
    logic [31:0] PCOutData, PC_4_AdderResult; 
    logic [31:0] aluSrcMuxOut, immExt;

    assign instrMemAddr = PCOutData;

    RegisterFile U_RegFile (
        //input
        .clk (clk),
        .we  (regFileWe),
        .RA1 (instrCode[19:15]),
        .RA2 (instrCode[24:20]),
        .WA  (instrCode[11:7]),
        .WD  (aluResult),
        //output
        .RD1 (RFData1),
        .RD2 (RFData2)
    ); 

    mux_2x1 U_AluSrcMux(
        .sel (aluSrcMuxSel),
        .x0  (RFData2),
        .x1  (immExt),
        .y   (aluSrcMuxOut)
    );

    immExtend U_immExtend(
        .instrCode (instrCode),
        .immExt    (immExt)
    );

    ALU U_ALU(
        .aluControl (aluControl),
        .a          (RFData1),
        .b          (aluSrcMuxOut),
        .result     (aluResult)
    );

    register U_PC(
        .clk (clk),
        .rst (rst),
        .en  (1'b1),
        .d   (PC_4_AdderResult),
        .q   (PCOutData)
    );

    Adder U_Adder(
        .a (32'd4),
        .b (PCOutData),
        .y (PC_4_AdderResult)
    );
endmodule
*/
module DataPath(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instrCode,
    input  logic        regFileWe,
    input  logic        aluSrcMuxSel,
    input  logic [3:0]  aluControl,
    output logic [31:0] instrMemAddr,
    output logic [31:0] dAddr,   
    output logic [31:0] dWData   
);
    logic [31:0] RFData1, RFData2, aluResult;
    logic [31:0] PCOutData, PC_4_AdderResult; 
    logic [31:0] aluSrcMuxOut, immExt;

    assign instrMemAddr = PCOutData;
    assign dAddr  = aluResult; 
    assign dWData = RFData2;   

    RegisterFile U_RegFile (
        .clk (clk),
        .we  (regFileWe),
        .RA1 (instrCode[19:15]),
        .RA2 (instrCode[24:20]),
        .WA  (instrCode[11:7]),
        .WD  (aluResult),         
        .RD1 (RFData1),
        .RD2 (RFData2)
    ); 

    mux_2x1 U_AluSrcMux(
        .sel (aluSrcMuxSel),
        .x0  (RFData2),
        .x1  (immExt),
        .y   (aluSrcMuxOut)
    );

    immExtend U_immExtend(
        .instrCode (instrCode),
        .immExt    (immExt)
    );

    ALU U_ALU(
        .aluControl (aluControl),
        .a          (RFData1),
        .b          (aluSrcMuxOut),
        .result     (aluResult)
    );

    register U_PC(
        .clk (clk),
        .rst (rst),
        .en  (1'b1),
        .d   (PC_4_AdderResult),
        .q   (PCOutData)
    );

    Adder U_Adder(
        .a (32'd4),
        .b (PCOutData),
        .y (PC_4_AdderResult)
    );
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [4:0]  RA1,
    input  logic [4:0]  RA2,
    input  logic [4:0]  WA,
    input  logic [31:0] WD,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);
    logic [31:0] mem [0:2**5 - 1]; //address 수만큼 있다

    //임시값
    initial begin
        for (int i = 0; i < 31; i++) begin
            mem[i] = i;
        end
        mem[31] = 32'hFFFF_FFFF;
    end

    //write
    always_ff @( posedge clk ) begin
        if (we) begin
            mem [WA] <= WD;
        end
    end

    //read
    assign RD1 = (RA1 != 0) ? mem[RA1] : 32'b0;
    assign RD2 = (RA2 != 0) ? mem[RA2] : 32'b0;

endmodule

module ALU (
    input  logic [3:0]  aluControl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    //R-type
    always_comb begin
        result = 32'bx;
        case (aluControl)
            `ADD:  result = a + b; 
            `SUB:  result = a - b;
            `SLL:  result = a << b [4:0];
            `SRL:  result = a >> b [4:0];
            `SRA:  result = $signed(a) >>> b [4:0];
            `SLT:  result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU: result = (a < b) ? 1 : 0;
            `XOR:  result = a ^ b;
            `OR:   result = a | b;
            `AND:  result = a & b;
        endcase
    end

endmodule

module register (
    input  logic        clk,
    input  logic        rst,
    input  logic        en,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @( posedge clk, posedge rst ) begin : blockName
        if (rst) begin
            q <= 0;
        end else begin
            if (en) q <= d;
        end
    end
endmodule

module Adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    output logic [31:0] y
);
    always_comb begin
        y = 32'bx;
        case (sel)
            0: y = x0;
            1: y = x1;
        endcase
    end
endmodule

/*
module immExtend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode [6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};
    always_comb begin
        immExt = 32'bx;
        case (opcode) 
            `OP_TYPE_I : immExt = {{20{instrCode[31]}}, instrCode[31:20]};
        endcase
    end
endmodule
*/

module immExtend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode [6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};
    always_comb begin
        immExt = 32'bx;
        case (opcode) 
            `OP_TYPE_I : immExt = {{20{instrCode[31]}}, instrCode[31:20]};
            `OP_TYPE_S : immExt = {{20{instrCode[31]}}, instrCode[31:25], instrCode[11:7]}; // NEW
        endcase
    end
endmodule