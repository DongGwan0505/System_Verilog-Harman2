`timescale 1ns / 1ps

module APB_manager_and_Master_Slave(
        input logic clk,
        input logic reset
    );
    logic [31:0] PRDATA0, PRDATA1, PRDATA2, PRDATA3;
    logic        PREADY0, PREADY1, PREADY2, PREADY3;
    logic        PSEL0, PSEL1, PSEL2, PSEL3, PENABLE, PWRITE, transfer, write, ready;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] addr, wdata, rdata;
    APB_Manager U_APB_MANAGER(
        // global signal
        .PCLK   (clk),
        .PRESET (reset),
        // APB Interface Signals
        .PRDATA0(PRDATA0),
        .PRDATA1(PRDATA1),
        .PRDATA2(PRDATA2),
        .PRDATA3(PRDATA3),
        .PREADY0(PREADY0),
        .PREADY1(PREADY1),
        .PREADY2(PREADY2),
        .PREADY3(PREADY3),
        .PADDR  (PADDR),
        .PENABLE(PENABLE),
        .PWRITE (PWRITE),
        .PWDATA (PWDATA),
        .PSEL0(PSEL0),
        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PSEL3(PSEL3),
        // Internal Interface Signals
        .transfer(transfer),
        .write   (write),
        .addr    (addr),
        .wdata   (wdata),
        .rdata   (rdata),
        .ready   (ready)
    );

    Test_Master U_test_master(
        .clk      (clk),
        .reset    (reset),
        .rdata    (rdata),
        .ready    (ready),
        //output
        .transfer (transfer),  // to APB_Manager
        .write    (write),     // to APB_Manager
        .addr     (addr),      // to APB_Manager
        .wdata    (wdata)      // to APB_Manager
    );

    Test_Slave_0 U_test_slave_0(
        .clk     (clk),
        .reset   (reset),      // active-high
        .PADDR   (PADDR),
        .PWRITE  (PWRITE),
        .PSEL0   (PSEL0),
        .PENABLE (PENABLE),
        .PWDATA  (PWDATA),
        //output
        .PRDATA0 (PRDATA0),
        .PREADY0 (PREADY0)
    );

    Test_Slave_0 U_test_slave_1(
        .clk     (clk),
        .reset   (reset),      // active-high
        .PADDR   (PADDR),
        .PWRITE  (PWRITE),
        .PSEL0   (PSEL1),
        .PENABLE (PENABLE),
        .PWDATA  (PWDATA),
        //output
        .PRDATA0 (PRDATA1),
        .PREADY0 (PREADY1)
    );

    Test_Slave_0 U_test_slave_2(
        .clk     (clk),
        .reset   (reset),      // active-high
        .PADDR   (PADDR),
        .PWRITE  (PWRITE),
        .PSEL0   (PSEL2),
        .PENABLE (PENABLE),
        .PWDATA  (PWDATA),
        //output
        .PRDATA0 (PRDATA2),
        .PREADY0 (PREADY2)
    );

    Test_Slave_0 U_test_slave_3(
        .clk     (clk),
        .reset   (reset),      // active-high
        .PADDR   (PADDR),
        .PWRITE  (PWRITE),
        .PSEL0   (PSEL3),
        .PENABLE (PENABLE),
        .PWDATA  (PWDATA),
        //output
        .PRDATA0 (PRDATA3),
        .PREADY0 (PREADY3)
    );
endmodule
