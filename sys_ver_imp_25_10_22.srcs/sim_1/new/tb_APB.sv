`timescale 1ns / 1ps

interface apb_master_if (
    input logic clk,
    input logic reset
);
    logic        transfer;
    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        ready;
endinterface

class apbSignal;

    logic                        transfer;
    logic                        write;
    rand logic            [31:0] addr;
    rand logic            [31:0] wdata;
    // logic [31:0] rdata;
    // logic        ready;

    constraint c_addr {
        addr inside {
            [32'h1000_0000 : 32'h1000_000c],
            [32'h1000_1000 : 32'h1000_100c],
            [32'h1000_2000 : 32'h1000_200c],
            [32'h1000_3000 : 32'h1000_300c]
        };
        addr[1:0] == 2'b00; // 4바이트 정렬 (mod보다 비트가 명확)
    }

    virtual apb_master_if        m_if;

    function new(virtual apb_master_if m_if);
        this.m_if = m_if;
    endfunction  //new()

    task automatic send();
        m_if.transfer <= 1'b1;
        m_if.write    <= 1'b1;
        m_if.addr     <= this.addr;
        m_if.wdata    <= this.wdata;
        @(posedge m_if.clk);
        m_if.transfer <= 1'b0;
        @(posedge m_if.clk);
        wait (m_if.ready);
        @(posedge m_if.clk);
    endtask 

    task automatic receive();
        m_if.transfer <= 1'b1;
        m_if.write    <= 1'b0;
        m_if.addr     <= this.addr;
        @(posedge m_if.clk);
        m_if.transfer <= 1'b0;
        @(posedge m_if.clk);
        wait (m_if.ready);
        @(posedge m_if.clk);
    endtask 


endclass  //apbSignal

module tb_APB ();

    //global signal
    logic            PCLK;
    logic            PRESET;

    //APB Interface Signals
    logic     [ 3:0] PADDR;
    logic            PWRITE;
    //logic        PSEL;
    logic            PENABLE;
    logic     [31:0] PWDATA;
    logic     [31:0] PRDATA;
    logic            PREADY;

    logic            PSEL0;
    logic            PSEL1;
    logic            PSEL2;
    logic            PSEL3;
    logic     [31:0] PRDATA0;
    logic     [31:0] PRDATA1;
    logic     [31:0] PRDATA2;
    logic     [31:0] PRDATA3;
    logic            PREADY0;
    logic            PREADY1;
    logic            PREADY2;
    logic            PREADY3;

    //Internal Interface Signals
    //logic            transfer;
    //logic            write;
    //logic     [31:0] addr;
    //logic     [31:0] wdata;
    //logic     [31:0] rdata;
    //logic            ready;

    apb_master_if m_if(PCLK, PRESET); //실제 하드웨어 생성됨

    apbSignal        apbTest;  //handler

    APB_Manager dut_manager (
        .*,
        .transfer(m_if.transfer),
        .write   (m_if.write),
        .addr    (m_if.addr),
        .wdata   (m_if.wdata),
        .rdata   (m_if.rdata), 
        .ready   (m_if.ready)
    );

    APB_Slave dut_slave_0 (
        .*,
        .PSEL  (PSEL0),
        .PRDATA(PRDATA0),
        .PREADY(PREADY0)
    );

    APB_Slave dut_slave_1 (
        .*,
        .PSEL  (PSEL1),
        .PRDATA(PRDATA1),
        .PREADY(PREADY1)
    );

    APB_Slave dut_slave_2 (
        .*,
        .PSEL  (PSEL2),
        .PRDATA(PRDATA2),
        .PREADY(PREADY2)
    );

    APB_Slave dut_slave_3 (
        .*,
        .PSEL  (PSEL3),
        .PRDATA(PRDATA3),
        .PREADY(PREADY3)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        #00 PCLK = 0;
        PRESET = 1;
        #10 PRESET = 0;
    end

    //////////////////<Task로 만드는 방법>/////////////////////////////////////////
    /*
    task automatic apbWrite (logic [3:0] addr, logic [31:0] wdata);
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =1'b1; PADDR = addr; PWDATA = wdata;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =1'b1; PADDR = addr; PWDATA = wdata;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK); //PENABLE을 0으로 한 클럭 유지
    endtask //automatic
    */
    
    /*
    task automatic apbMasterWrite(logic [31:0] address, logic [31:0] data);
        transfer = 1'b1;
        write = 1'b1;
        addr = address;
        wdata = data;
        @(posedge PCLK);
        transfer = 1'b0;
        @(posedge PCLK);
        wait (ready);
        @(posedge PCLK);
    endtask  //automatic
    */

    /*
    task automatic apbRead (logic [3:0] addr);
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =1'b0; PADDR = addr;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =1'b0; PADDR = addr;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK); //PENABLE을 0으로 한 클럭 유지
    endtask //automatic
    */

    /*
    task automatic apbMasterRead(logic [31:0] address);
        transfer = 1'b1;
        write = 1'b0;
        addr = address;
        @(posedge PCLK);
        transfer = 1'b0;
        @(posedge PCLK);
        wait (ready);
        @(posedge PCLK);
    endtask  //automatic
    */

    //////////////////<Class로 만드는 방법>/////////////////////////////////////////


    initial begin
        automatic integer i = 0;
        apbTest  = new(m_if);

        repeat (3) @(posedge PCLK);

        for (i = 0; i<50; i = i + 1) begin
            apbTest.randomize();
            apbTest.send();
            apbTest.receive();
        end
        
        //apbUART.read(32'h1000_0000);

        /*
        apbWrite(4'h00, 32'h1111_1111);
        apbWrite(4'h04, 32'h2222_2222);
        apbWrite(4'h08, 32'h3333_3333);
        apbWrite(4'h0c, 32'h4444_4444);
        */

        /*
        apbMasterWrite(32'h1000_0000, 32'h1111_1111);
        apbMasterWrite(32'h1000_1000, 32'h2222_2222);
        apbMasterWrite(32'h1000_2000, 32'h3333_3333);
        apbMasterWrite(32'h1000_3000, 32'h4444_4444);
        */

        /*
        apbRead(4'h00);
        apbRead(4'h04);
        apbRead(4'h08);
        apbRead(4'h0c);
        */

        /*
        apbMasterRead(32'h1000_0000);
        apbMasterRead(32'h1000_1000);
        apbMasterRead(32'h1000_1000);
        apbMasterRead(32'h1000_3000);
        */

        @(posedge PCLK);
        #20;
        $finish;

    end
endmodule
