`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic        aluSrcMuxSel,
    output logic        aluRamMuxSel,
    output logic [ 3:0] aluControl,
    output logic [ 2:0] strb,
    output logic        busWe
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};
    logic [3:0] signals;

    assign {regFileWe, aluSrcMuxSel, busWe, aluRamMuxSel} = signals;
    assign strb = instrCode[14:12];

    always_comb begin
        signals = 4'b0;
        case (opcode)
               //{regFileWe, aluSrcMuxSel, busWe, aluRamMuxsel} 
            `OP_TYPE_R: signals = 4'b1_0_0_0;
            `OP_TYPE_I: signals = 4'b1_1_0_0;
            `OP_TYPE_S: signals = 4'b0_1_1_0;
            `OP_TYPE_L: signals = 4'b1_1_0_1;
        endcase
    end

    always_comb begin
        aluControl = `ADD;
        case (opcode)
            `OP_TYPE_R: aluControl = operator;
            `OP_TYPE_I: begin
                if (operator == 4'b1101) aluControl = operator;
                else aluControl = {1'b0, operator[2:0]};
            end
            `OP_TYPE_R: aluControl = `ADD;
            `OP_TYPE_L: aluControl = `ADD;
        endcase
    end
endmodule
