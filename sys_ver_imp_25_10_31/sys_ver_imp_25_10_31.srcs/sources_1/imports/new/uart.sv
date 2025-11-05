`timescale 1ns / 1ps

module uart_top(
    input        clk,
    input        rst,
    input        rx,
    output       tx,
    output [7:0] rx_data,
    output       rx_done
);

    // -------------------------
    // UART 내부 신호
    wire w_b_tick;
    wire w_rx_done, w_rx_busy;
    wire [7:0] w_rx_data;
    wire w_tx_busy;
    wire [7:0] w_tx_data;

    // -------------------------
    // FIFO 내부 신호
    wire [7:0] w_rx_fifo_rdata, w_tx_fifo_rdata;
    wire w_rx_fifo_empty, w_tx_fifo_empty, w_rx_fifo_full, w_tx_fifo_full;

    assign rx_data = w_rx_data;
    assign rx_done = w_rx_done;

    // -------------------------
    // RX done 1클록 펄스 생성
    reg rx_done_d;
    wire rx_done_pulse;
    always @(posedge clk or posedge rst) begin
        if (rst) rx_done_d <= 0;
        else rx_done_d <= w_rx_done;
    end
    assign rx_done_pulse = w_rx_done & ~rx_done_d;

    // -------------------------
    // UART RX
    uart_rx U_UART_RX(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_busy(w_rx_busy),
        .rx_done(w_rx_done)
    );

    // -------------------------
    // RX FIFO: UART RX 데이터를 임시 저장
    fifo U_RX_FIFO(
        .clk(clk),
        .rst(rst),
        .wr(rx_done_pulse),                     // 1클록 펄스로 push
        .rd(~w_tx_fifo_full & ~w_rx_fifo_empty), // TX FIFO에 push 가능하면 읽기
        .wdata(w_rx_data),
        .rdata(w_rx_fifo_rdata),
        .full(w_rx_fifo_full),
        .empty(w_rx_fifo_empty)
    );

    // -------------------------
    // TX FIFO: RX FIFO 데이터를 전송용으로 저장
    wire rx_fifo_to_tx_fifo = ~w_rx_fifo_empty & ~w_tx_fifo_full;
    fifo U_TX_FIFO(
        .clk(clk),
        .rst(rst),
        .wr(rx_fifo_to_tx_fifo),
        .rd(~w_tx_fifo_empty & ~w_tx_busy),      // TX idle이면 읽어서 전송
        .wdata(w_rx_fifo_rdata),
        .rdata(w_tx_fifo_rdata),
        .full(w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );

    // -------------------------
    // UART TX
    wire w_tx_start = ~w_tx_fifo_empty & ~w_tx_busy;
    uart_tx U_UART_TX(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .tx_start(w_tx_start),
        .tx_data(w_tx_fifo_rdata),
        .busy(w_tx_busy),
        .done(),
        .tx(tx)
    );

    // -------------------------
    // Baud tick generator
    baud_tick_gen U_BAUD_TICK(
        .clk(clk),
        .rst(rst),
        .baud_tick(w_b_tick)
    );

endmodule

`timescale 1ns / 1ps

module uart_rx(
    input clk,
    input rst,
    input rx,
    input b_tick,
    output rx_busy,
    output rx_done,
    output [7:0] rx_data
    );

    parameter [1:0] IDLE = 0, START = 1, RECIEVE = 2, STOP = 3 ;

    reg [1:0] c_state, n_state;
    reg c_rx_busy, n_rx_busy, c_rx_done, n_rx_done;
    reg [7:0] c_rx_data, n_rx_data;
    reg [3:0] c_b_tick_cnt, n_b_tick_cnt;
    reg [2:0] c_bit_cnt, n_bit_cnt;

    assign rx_busy = c_rx_busy;
    assign rx_done = c_rx_done;
    assign rx_data = c_rx_data;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= IDLE;
            c_rx_busy    <= 0;
            c_rx_done    <= 0;
            c_rx_data    <= 0;
            c_b_tick_cnt <= 0;
            c_bit_cnt    <= 0;
        end else begin
            c_state      <= n_state;
            c_rx_busy    <= n_rx_busy;
            c_rx_done    <= n_rx_done;
            c_rx_data    <= n_rx_data;
            c_b_tick_cnt <= n_b_tick_cnt;
            c_bit_cnt    <= n_bit_cnt;   
        end
    end

    always @(*) begin
        n_state      = c_state;
        n_rx_busy    = c_rx_busy;
        n_rx_done    = c_rx_done;
        n_rx_data    = c_rx_data;
        n_b_tick_cnt = c_b_tick_cnt;
        n_bit_cnt    = c_bit_cnt;
        case (c_state)
            IDLE : begin
                n_rx_busy    = 0;
                n_rx_done    = 0;
                if (rx == 0) begin
                    n_state = START;
                end
            end
            START:begin
                n_rx_busy = 1;
                if (b_tick) begin
                    if (c_b_tick_cnt == 15) begin
                        n_b_tick_cnt = 0;
                        n_state = RECIEVE;
                    end else begin
                        n_b_tick_cnt = c_b_tick_cnt + 1;
                    end
                end
            end
            RECIEVE : begin
                if (b_tick) begin
                    if (c_b_tick_cnt == 7) begin
                        n_rx_data = {rx, c_rx_data[7:1]};
                    end
                    if (c_b_tick_cnt==15) begin
                        n_b_tick_cnt = 0;
                        if (c_bit_cnt == 7) begin
                            n_bit_cnt = 0;
                            n_state = STOP;
                        end else begin
                            n_bit_cnt = c_bit_cnt + 1;
                        end
                    end else begin
                        n_b_tick_cnt = c_b_tick_cnt + 1;
                    end
                end
            end
            STOP : begin
                n_rx_done = 1;
                n_rx_busy = 0;
                if (b_tick) begin
                    n_state = IDLE;
                end
            end  
        endcase
    end

endmodule


module uart_tx(
    input         clk,
    input         rst,
    input         b_tick,
    input         tx_start,
    input   [7:0] tx_data,
    output        busy,
    output        done,
    output        tx
    );

    parameter [1:0] IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] c_state, n_state;
    reg [$clog2(16)-1:0] c_b_tick_cnt, n_b_tick_cnt;
    reg c_busy, n_busy, c_done, n_done, c_tx, n_tx;
    reg [7:0] c_tx_data, n_tx_data;
    reg [2:0] c_bit_cnt, n_bit_cnt;

    assign busy = c_busy;
    assign done = c_done;
    assign tx   = c_tx;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_busy       <= 0;
            c_done       <= 0;
            c_state      <= IDLE;
            c_tx         <= 1;
            c_b_tick_cnt <= 0;
            c_bit_cnt    <= 0;
            c_tx_data    <= 0;
        end else begin
            c_busy       <= n_busy;
            c_done       <= n_done;
            c_state      <= n_state;
            c_tx         <= n_tx;
            c_b_tick_cnt <= n_b_tick_cnt;
            c_bit_cnt    <= n_bit_cnt;
            c_tx_data    <= n_tx_data;
        end
    end

    always @(*) begin
        n_state      = c_state;
        n_busy       = c_busy;
        n_done       = c_done;
        n_tx         = c_tx;
        n_b_tick_cnt = c_b_tick_cnt;
        n_bit_cnt    = c_bit_cnt;
        n_tx_data    = c_tx_data;
        case (c_state)
            IDLE: begin
                n_done = 0;
                n_busy = 0;
                n_tx   = 1;
                if (tx_start == 1) begin
                    n_tx_data = tx_data;
                    n_state = START;
                end
            end
            START: begin
                n_busy = 1;
                n_tx   = 0;
                if (b_tick) begin
                    if (n_b_tick_cnt == 15) begin
                        n_b_tick_cnt = 0;
                        n_bit_cnt    = 0;
                        n_state      = DATA;
                    end else begin
                        n_b_tick_cnt = c_b_tick_cnt + 1;
                    end
                end
            end
            DATA: begin
                n_tx = c_tx_data[0];
                if (b_tick) begin
                    if (c_b_tick_cnt == 15) begin
                        if (c_bit_cnt == 7) begin
                            n_b_tick_cnt = 0;
                            n_bit_cnt    = 0;
                            n_state = STOP;
                        end else begin
                            n_b_tick_cnt = 0;
                            n_bit_cnt = c_bit_cnt + 1;
                            n_tx_data    = c_tx_data >> 1;
                        end
                    end else begin
                        n_b_tick_cnt = c_b_tick_cnt + 1;
                    end
                end
            end
            STOP: begin
                n_tx = 1;
                if (b_tick) begin
                    if (c_b_tick_cnt == 15) begin
                        n_done = 1;
                        n_b_tick_cnt = 0;
                        n_state = IDLE;
                    end else begin
                        n_b_tick_cnt = c_b_tick_cnt + 1;
                    end
                end
            end
        endcase
    end

endmodule


module baud_tick_gen (
    input   clk,
    input   rst,
    output  baud_tick
);
    parameter BAUD = 9600;
    parameter BAUD_TICK_COUNT = (100_000_000 / BAUD) / 16;
    reg [$clog2(BAUD_TICK_COUNT)-1 : 0] b_tick_cnt;
    reg b_tick_reg;

    assign baud_tick = b_tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            b_tick_cnt <= 0; 
            b_tick_reg <= 0;
        end else begin
            if (b_tick_cnt == BAUD_TICK_COUNT) begin
                b_tick_reg <= 1;
                b_tick_cnt <= 0;
            end else begin
                b_tick_cnt <= b_tick_cnt + 1;
                b_tick_reg <= 0;
            end
        end
    end

endmodule

`timescale 1ns / 1ps

module fifo(
    input  logic       clk,
    input  logic       rst,
    input  logic       wr,
    input  logic       rd,
    input  logic [7:0] wdata,
    output logic [7:0] rdata,
    output logic       full,
    output logic       empty
);
    logic wr_en;
    logic [2:0] waddr;
    logic [2:0] raddr;

    assign wr_en = wr & ~full;

    //이런 식으로 모듈을 인스턴스 할 시 같은 이름을 가진 것들끼리 매칭시켜준다.
    register_file U_REG_FILE (
        .*,
        .wr(wr_en)
    );

    fifo_ctrl_unit U_fifo_CU (.*);

endmodule

module register_file 
#(parameter AWIDTH = 3)
(
    input  logic                      clk,
    input  logic                      wr,
    input  logic [7:0]                wdata,
    input  logic [AWIDTH-1:0] waddr,
    input  logic [AWIDTH-1:0] raddr,
    output logic [7:0]                rdata
);
    
    logic [7:0] ram [0:2**AWIDTH-1];

    assign rdata = ram[raddr];

    always_ff @(posedge clk) begin
        if (wr) begin
            ram[waddr] <= wdata;
        end
    end

endmodule

module fifo_ctrl_unit 
#(parameter AWIDTH = 3)
(
    input  logic                clk,
    input  logic                rst,
    input  logic                wr,
    input  logic                rd,
    output logic                full,
    output logic                empty,
    output logic [AWIDTH - 1:0] raddr,
    output logic [AWIDTH - 1:0] waddr
);
    logic [AWIDTH-1:0] c_waddr, n_waddr;
    logic [AWIDTH-1:0] c_raddr, n_raddr;

    logic c_full, n_full;
    logic c_empty, n_empty;

    assign empty = c_empty;
    assign full  = c_full;
    assign raddr = c_raddr;
    assign waddr = c_waddr;

    //state reg
    always_ff @( posedge clk, posedge rst) begin
        if (rst) begin
            c_waddr <= 0;
            c_raddr <= 0;
            c_full  <= 0;
            c_empty <= 1;
        end else begin
            c_waddr <= n_waddr;
            c_raddr <= n_raddr;
            c_full  <= n_full;
            c_empty <= n_empty;
        end
    end

    //next CL
    always_comb begin
        n_waddr = c_waddr;
        n_raddr = c_raddr;
        n_full  = c_full;
        n_empty = c_empty;
        case ({wr, rd})
            2'b01: begin
                if (!c_empty) begin
                    n_raddr = c_raddr + 1;
                    n_full = 0;
                    if (c_waddr == n_raddr) begin 
                    //"이번에 읽기 동작을 해서 읽기 주소를 1 증가시켰더니(n_raddr), 그 값이 현재 쓰기 주소(c_waddr)와 같아졌는가?"
                    //만약 이 조건이 참(true)이라면, 그건 마지막 남은 데이터를 방금 읽었다는 뜻입니다. 따라서 FIFO는 이제 비게 됩니다.
                        n_empty = 1;
                    end
                end
            end //pop
            2'b10: begin
                if (!c_full) begin
                    n_waddr = c_waddr + 1;
                    n_empty = 0;
                    if (n_waddr == c_raddr) begin
                    //"쓰기 주소를 1 증가시켰더니(n_waddr), 그 값이 현재 읽기 주소(c_raddr)와 같아졌는가?"
                    //만약 이 조건이 참(true)이라면, 이는 마지막 남은 빈 공간에 데이터를 채웠다는 것을 의미합니다. 따라서 FIFO는 이제 꽉 차게 됩니다
                        n_full = 1;
                    end
                end
            end //push 
            2'b11: begin
                if (c_full) begin
                    //pop
                    n_raddr = c_raddr + 1;
                    n_full = 0;
                end else if (c_empty) begin
                    //push
                    n_waddr = c_waddr + 1;
                    n_empty = 0;
                end else begin
                    n_raddr = c_raddr + 1;
                    n_waddr = c_waddr + 1;
                end
            end //push, pop
        endcase
    end
endmodule

