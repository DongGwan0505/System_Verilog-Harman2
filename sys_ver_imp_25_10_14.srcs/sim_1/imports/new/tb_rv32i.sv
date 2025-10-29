`timescale 1ns / 1ps

module tb_rv32i();

    logic clk;
    logic rst;
    
    MCU DUT(.*);

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;

        #10;
        rst = 0;

        #200;
        $finish;
    end

endmodule
