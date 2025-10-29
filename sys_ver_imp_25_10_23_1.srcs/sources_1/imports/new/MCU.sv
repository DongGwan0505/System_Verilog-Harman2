/*
`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset,
    output logic [3:0] gpo
);

    logic [31:0] instrCode, instrMemAddr;
    //Internal INterface SIgnals
    logic [ 2:0] strb;
    logic        busWe;
    logic [31:0] busAddr;
    logic [31:0] busWData;
    logic [31:0] busRData;
    logic        transfer;
    logic        ready;

    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;

    logic        PSEL_RAM;
    logic        PSEL_GPO;
    logic [31:0] PRDATA_RAM;
    logic [31:0] PRDATA_GPO;
    logic        PREADY_RAM;
    logic        PREADY_GPO;

    //global Signals
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [31:0] PADDR;
    logic        PWRITE;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;
        
    // Internal Interface Signals
    assign PCLK  = clk;
    assign PRESET = reset;
    assign write = busWe;
    assign addr  = busAddr;
    assign wdata = busWData;
    assign busRData = rdata;

    ROM U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    CPU_RV32I U_RV32I (
        .*
    );

    APB_Manager U_APB_Manager(
        .*,
        .PSEL0  (PSEL_RAM),
        .PSEL1  (PSEL_GPO),
        .PSEL2  (),
        .PSEL3  (),
        .PRDATA0(PRDATA_RAM),
        .PRDATA1(PRDATA_GPO),
        .PRDATA2(),
        .PRDATA3(),
        .PREADY0(PREADY_RAM),
        .PREADY1(PREADY_GPO),
        .PREADY2(),
        .PREADY3()
    );

    RAM U_RAM(
        .*,
        .PADDR(PADDR[11:0]),   // ★ 명시적 슬라이스
        .PSEL    (PSEL_RAM),
        .PRDATA  (PRDATA_RAM),
        .PREADY  (PREADY_RAM)
    );

    APB_GPO U_GPO(
        .*,
        .PADDR(PADDR[2:0]),      // ★ 명시적 슬라이스
        .PSEL   (PSEL_GPO),
        .PRDATA (PRDATA_GPO),
        .PREADY (PREADY_GPO)
    );

endmodule
*/

`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset,
    output logic [3:0] gpo
);


    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [31:0] PADDR;
    logic        PWRITE;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;

    logic [31:0] instrCode, instrMemAddr;
    // Internal Interface Signals
    logic [ 2:0] strb;
    logic        busWe;
    logic [31:0] busAddr;
    logic [31:0] busWData;
    logic [31:0] busRData;
    logic        transfer;
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write;

    logic        PSEL_RAM;
    logic [31:0] PRDATA_RAM;
    logic        PREADY_RAM;
    logic [31:0] PRDATA_GPO;
    logic        PREADY_GPO;
    logic        PSEL_GPO;

    assign PCLK   = clk;
    assign PRESET = reset;
    assign write  = busWe;
    assign addr   = busAddr;
    assign wdata  = busWData;
    assign busRData = rdata;

    ROM U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    CPU_RV32I U_RV32I (.*);

    RAM U_RAM (
        .*,
        .PSEL  (PSEL_RAM),
        .PRDATA(PRDATA_RAM),
        .PREADY(PREADY_RAM)
    );

    APB_Manager U_APB_Manager (
        .*,
        // global signals
        .PSEL0  (PSEL_RAM),
        .PSEL1  (PSEL_GPO),
        .PSEL2  (),
        .PSEL3  (),
        .PRDATA0(PRDATA_RAM),
        .PRDATA1(PRDATA_GPO),
        .PRDATA2(),
        .PRDATA3(),
        .PREADY0(PREADY_RAM),
        .PREADY1(PREADY_GPO),
        .PREADY2(),
        .PREADY3()
    );

    APB_GPO U_GPO (
        .*,
        .PSEL  (PSEL_GPO),
        .PRDATA(PRDATA_GPO),
        .PREADY(PREADY_GPO)
    );
endmodule