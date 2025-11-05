`timescale 1ns / 1ps

module tb_AXI_Lite_Master_Slave ();

    // Global Signals
    logic        ACLK;
    logic        ARESETn;
    // WRITE Transaction, AW Channel
    logic [ 3:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;
    // WRITE Transaction, W Channel
    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;
    // WRITE Transaction, B Channel
    logic [ 1:0] BRESP;
    logic        BVALID;
    logic        BREADY;
    // READ Transaction, AR Channel
    logic [ 3:0] ARADDR;
    logic        ARVALID;
    logic        ARREADY;
    // READ Transaction, R Channel
    logic [31:0] RDATA;
    logic        RVALID;
    logic        RREADY;
    logic [ 1:0] RRESP;

    host_if h_if (ACLK);

    AXI_Lite_Master dut_AXI_Lite_Master (
        .*,
        .transfer(h_if.transfer),
        .ready   (h_if.ready),
        .addr    (h_if.addr),
        .wdata   (h_if.wdata),
        .write   (h_if.write),
        .rdata   (h_if.rdata)
    );
    AXI_Lite_Slave dut_AXI_Lite_Slave (.*);


    interface host_if (
        input logic ACLK,
        input logic ARESETn
    );
        // Internal Signals
        logic        transfer;
        logic        ready;
        logic [ 3:0] addr;
        logic [31:0] wdata;
        logic        write;
        logic [31:0] rdata;
    endinterface  //host_if

    class transaction;
        logic                  transfer;
        logic                  ready;
        randc logic      [ 3:0] addr;
        randc logic      [31:0] wdata;
        //logic                  write;
        logic           [31:0] rdata;

        constraint c_addr {addr inside {4'h0, 4'h4, 4'h8, 4'hc};}

        function void print(string name);
            $display("[%s] addr = %h, wdata = %h, rdata = %h", name, addr, wdata, rdata);
        endfunction 
    endclass //transaction


    class tester;
        virtual host_if        h_if;

        transaction tr;

        function new(virtual host_if h_if);
            this.h_if = h_if;
            this.tr   = new();
        endfunction  //new()

        task automatic write();
            @(posedge h_if.ACLK);
            h_if.addr     <= tr.addr;
            h_if.wdata    <= tr.wdata;
            h_if.write    <= 1'b1;
            h_if.transfer <= 1'b1;
            @(posedge h_if.ACLK);
            h_if.transfer <= 1'b0;
            tr.print("WRITE");
            @(posedge h_if.ACLK);
            wait (h_if.ready);
            @(posedge h_if.ACLK);
        endtask  //automatic

        task automatic read();
            @(posedge h_if.ACLK);
            h_if.addr     <= tr.addr;
            h_if.write    <= 1'b0;
            h_if.transfer <= 1'b1;
            @(posedge h_if.ACLK);
            h_if.transfer <= 1'b0;
            @(posedge h_if.ACLK);
            wait (h_if.ready);
            tr.rdata      = h_if.rdata;
            @(posedge h_if.ACLK);
            tr.print("READ");
        endtask  //automatic

        task automatic run(int loop);
            repeat (loop) begin
                tr.randomize(); //여기서 this -> 자기 자신
                write();
                read();
                ;
            end
        endtask  //automatic
    endclass  //tester

    tester axi_tester;

    always #5 ACLK = ~ACLK;

    initial begin
        ACLK = 0;
        ARESETn = 0;
        #10 ARESETn = 1'b1;
    end

    initial begin
        repeat (5) @(posedge ACLK);
        axi_tester = new(h_if);

        axi_tester.run(20);

        @(posedge ACLK);
        @(posedge ACLK);
        $finish;
    end
endmodule
