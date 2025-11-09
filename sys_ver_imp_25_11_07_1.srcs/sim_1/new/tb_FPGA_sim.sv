`timescale 1ns / 1ps

module tb_FPGA_sim();

    logic clk;
    logic reset;
    logic clear;
    logic run_stop;
    logic [7:0] fnd_font;
    logic [3:0] fnd_comm;

    FPGA_sim DUT(
        .clk      (clk),
        .reset    (reset),
        .clear    (clear),
        .run_stop (run_stop),
        .fnd_font (fnd_font),
        .fnd_comm (fnd_comm)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        clear = 1;
        run_stop = 0;
        #10;
        reset = 0;
        clear = 0;
        run_stop = 1;
        #100000000;
    end

endmodule
