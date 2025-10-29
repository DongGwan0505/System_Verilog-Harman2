/*
`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit(
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic        aluSrcMuxSel,
    output logic [1:0]  strb,
    output logic [3:0]  aluControl
    );

    wire [6:0] opcode = instrCode [6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};

    logic [1:0] signals;

    assign {regFileWe, aluSrcMuxSel} = signals;

    always_comb begin
        signals = 2'b0;
        case (opcode)
            // {regFilewe, aluSrcMuxSel}
            `OP_TYPE_R: signals = 2'b1_0;
            `OP_TYPE_I: signals = 2'b1_1;
        endcase
    end

    always_comb begin
        aluControl = `ADD;
        case (opcode)
            `OP_TYPE_R: aluControl = operator; 
            `OP_TYPE_I: begin
                if (operator == 4'b1101) begin
                    aluControl = operator;
                end else begin
                    aluControl = {1'b0, operator[2:0]};
                end
            end
        endcase
    end

    always_comb begin
        strb = 2'bx;
        case (instrCode[14:12])
            3'b000: strb = 2'b00;
            3'b001: strb = 2'b01;
            3'b010: strb = 2'b10;
        endcase
    end
endmodule
*/
`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit(
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic        aluSrcMuxSel,
    output logic [1:0]  strb,
    output logic [3:0]  aluControl,
    output logic        d_we             
);
    wire [6:0] opcode   = instrCode [6:0];
    wire [2:0] funct3   = instrCode [14:12];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};

    // 기본값
    always_comb begin
        regFileWe    = 1'b0;
        aluSrcMuxSel = 1'b0;
        d_we         = 1'b0;            
        aluControl   = `ADD;

        unique case (funct3)
            3'b000: strb = 2'b00; // byte
            3'b001: strb = 2'b01; // half
            3'b010: strb = 2'b10; // word
            default: strb = 2'b10;
        endcase

        unique case (opcode)
            `OP_TYPE_R: begin
                regFileWe    = 1'b1;
                aluSrcMuxSel = 1'b0;
                aluControl   = operator; 
            end
            `OP_TYPE_I: begin
                regFileWe    = 1'b1;
                aluSrcMuxSel = 1'b1;     
                if (operator == 4'b1101) aluControl = operator; 
                else                      aluControl = {1'b0, operator[2:0]};
            end
            `OP_TYPE_S: begin                  
                regFileWe    = 1'b0;
                aluSrcMuxSel = 1'b1;          
                d_we         = 1'b1;          
                aluControl   = `ADD;          
            end
            default: ;
        endcase
    end
endmodule
