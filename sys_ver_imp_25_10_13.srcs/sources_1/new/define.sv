`timescale 1ns / 1ps

//funct7[5] + funct3[2:0]
    //R-type)
`define    ADD  4'b0000
`define    SUB  4'b1000
`define    SLL  4'b0001
`define    SRL  4'b0101
`define    SRA  4'b1101
`define    SLT  4'b0010
`define    SLTU 4'b0011
`define    XOR  4'b0100
`define    OR   4'b0110
`define    AND  4'b0111

    //B-type
`define    BEQ   3'b000
`define    BNE   3'b001
`define    BLT   3'b100
`define    BGE   3'b101
`define    BLTU  3'b110
`define    BGEU  3'b111

// OPCODE
`define    OP_R_TYPE  7'b0110011 // RD = RS2 + RS1
`define    OP_S_TYPE  7'b0100011 // SW, SH, SB
`define    OP_IL_TYPE 7'b0000011 // LW, LH, LB, LBU, LHU
`define    OP_I_TYPE  7'b0010011 // RD = RS1 + IMM
`define    OP_B_TYPE  7'b1100011 // BEQ, 