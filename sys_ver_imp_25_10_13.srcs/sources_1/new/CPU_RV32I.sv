`timescale 1ns / 1ps

/*
module CPU_RV32I(
    input  logic clk,
    input  logic rst,
    input  logic [31:0] instrCode, 
    output logic [31:0] instrMemAddr,
    output logic [1:0]  strb
    );

    logic       regFileWe;
    logic [3:0] aluControl;
    logic       aluSrcMuxSel;

    ControlUnit U_ControlUnit(.*);
 
    DataPath U_DataPath(.*);

endmodule
*/

module CPU_RV32I(
    input  logic clk,
    input  logic rst,
    input  logic [31:0] instrCode, 
    output logic [31:0] instrMemAddr,
    output logic [31:0] dAddr,   
    output logic [31:0] dWData,  
    output logic [1:0]  strb,    
    output logic        d_we     
);
    logic       regFileWe;
    logic [3:0] aluControl;
    logic       aluSrcMuxSel;

    ControlUnit U_ControlUnit(
        .instrCode    (instrCode),
        .regFileWe    (regFileWe),
        .aluSrcMuxSel (aluSrcMuxSel),
        .strb         (strb),
        .aluControl   (aluControl),
        .d_we         (d_we)          
    );
 
    DataPath U_DataPath(
        .clk          (clk),
        .rst          (rst),
        .instrCode    (instrCode),
        .regFileWe    (regFileWe),
        .aluSrcMuxSel (aluSrcMuxSel),
        .aluControl   (aluControl),
        .instrMemAddr (instrMemAddr),
        .dAddr        (dAddr),        
        .dWData       (dWData)       
    );
endmodule
