`timescale 1ns / 1ps

module tb_10000_counter();

    logic        clk;
    logic        reset;
    logic        run_stop;
    logic        clear;
    logic [13:0] o_counter;

    logic tick;

counter_10000 U_cnt(
    .clk  (clk),
    .reset(reset),
    .clear(clear),
    .tick (tick),
    .o_counter(o_counter)
);

clk_tick_gen_10hz U_tick_gen(
    .clk_in   (clk),
    .reset    (reset),
    .run_stop (run_stop),
    .clear    (clear),
    .tick_10hz(tick)
);

always #5 clk = ~clk;

initial begin
   clk = 0;
   run_stop = 0;
   clear = 1;
   reset = 1; 

   #10;
   reset = 0;
   clear = 0;
   run_stop = 1;
   #100000;
   $finish;
end

endmodule
