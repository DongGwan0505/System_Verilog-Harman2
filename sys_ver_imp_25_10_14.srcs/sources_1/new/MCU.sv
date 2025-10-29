`timescale 1ns / 1ps

module MCU(
    input logic clk,
    input logic rst
);
    logic [31:0] instrCode, instrMemAddr;
    // NEW: D-MEM 배선
    logic [31:0] busAddr, busWData, busRData;
    logic [2:0]  strb;
    logic        busWe;

    ROM U_ROM(
        .addr (instrMemAddr),
        .data (instrCode)
    );

    RAM U_RAM(
        .clk   (clk),
        .strb  (strb),
        .we    (busWe),
        .Addr  (busAddr),
        .wData (busWData),
        .rData (busRData) 
    );

    CPU_RV32I U_RV32I(
        .clk          (clk),
        .reset        (rst),
        .instrCode    (instrCode),
        .instrMemAddr (instrMemAddr),
        .strb         (strb),
        .busWe        (busWe),
        .busAddr      (busAddr),
        .busWData     (busWData),
        .busRData     (busRData)
    );
endmodule