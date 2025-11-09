`timescale 1ns / 1ps

module tb_control_unit_master();

    logic       clk;
    logic       reset;
    logic       run_stop;
    logic       clear;

    logic [7:0] tx_data;
    logic       start;
    logic       ready;
    logic       done;
    logic       ss_bar;

control_unit_master DUT(.*);

task automatic for_done();
    #200_000_000;   // 200 ms (timescale 1ns 기준)
    done = 1;
    #10;            // 10 ns ≒ 한 클록(주기가 10 ns라면)
    done = 0;
    #100_000_000;   // 200 ms (timescale 1ns 기준)
    done = 1;
    #10;            // 10 ns ≒ 한 클록(주기가 10 ns라면)
    done = 0;
    #100_000_000;
    ready = 1;
endtask //automatic

always #5 clk = ~clk;

initial begin
    clk = 0;
    run_stop = 0;
    reset = 1;
    clear = 1;
    ready = 1;
    done  = 0;
    repeat(5)@(posedge clk);
    reset = 0;
    clear = 0;
    run_stop = 1;
    for_done();
    for_done();

end

endmodule
