`timescale 1ns / 1ps

module tb_rv32i();

    logic clk;
    logic reset;
    
    MCU DUT(.*);

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        #300;
        $finish;
    end

endmodule
