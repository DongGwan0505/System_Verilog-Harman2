`timescale 1ns/1ps

module tb_for_uart_axi;

  // -------------------------
  // AXI4-Lite bus
  // -------------------------
  logic         ACLK;
  logic         ARESETn;

  // AW
  logic [3:0]   S_AWADDR;
  logic [2:0]   S_AWPROT;
  logic         S_AWVALID;
  logic         S_AWREADY;
  // W
  logic [31:0]  S_WDATA;
  logic [3:0]   S_WSTRB;
  logic         S_WVALID;
  logic         S_WREADY;
  // B
  logic [1:0]   S_BRESP;
  logic         S_BVALID;
  logic         S_BREADY;
  // AR
  logic [3:0]   S_ARADDR;
  logic [2:0]   S_ARPROT;
  logic         S_ARVALID;
  logic         S_ARREADY;
  // R
  logic [31:0]  S_RDATA;
  logic [1:0]   S_RRESP;
  logic         S_RVALID;
  logic         S_RREADY;

  // -------------------------
  // UART external pins
  // -------------------------
  logic rx;   // driven by TB (PC 역할)
  wire  tx;   // DUT 출력 (모니터용)

  // -------------------------
  // DUT (top wrapper)
  // -------------------------
  localparam int C_DW = 32;
  localparam int C_AW = 4;

  for_uart_v1_0 #(
    .C_S00_AXI_DATA_WIDTH(C_DW),
    .C_S00_AXI_ADDR_WIDTH(C_AW)
  ) dut (
    .rx(rx),
    .tx(tx),

    .s00_axi_aclk   (ACLK),
    .s00_axi_aresetn(ARESETn),

    .s00_axi_awaddr (S_AWADDR),
    .s00_axi_awprot (S_AWPROT),
    .s00_axi_awvalid(S_AWVALID),
    .s00_axi_awready(S_AWREADY),

    .s00_axi_wdata  (S_WDATA),
    .s00_axi_wstrb  (S_WSTRB),
    .s00_axi_wvalid (S_WVALID),
    .s00_axi_wready (S_WREADY),

    .s00_axi_bresp  (S_BRESP),
    .s00_axi_bvalid (S_BVALID),
    .s00_axi_bready (S_BREADY),

    .s00_axi_araddr (S_ARADDR),
    .s00_axi_arprot (S_ARPROT),
    .s00_axi_arvalid(S_ARVALID),
    .s00_axi_arready(S_ARREADY),

    .s00_axi_rdata  (S_RDATA),
    .s00_axi_rresp  (S_RRESP),
    .s00_axi_rvalid (S_RVALID),
    .s00_axi_rready (S_RREADY)
  );

  // -------------------------
  // Clock / Reset
  // -------------------------
  always #5 ACLK = ~ACLK;  // 100 MHz

  initial begin
    ACLK    = 0;
    ARESETn = 0;
    rx      = 1'b1; // UART idle high
    // init AXI
    S_AWADDR  = '0; S_AWPROT  = 3'b000; S_AWVALID = 0;
    S_WDATA   = '0; S_WSTRB   = 4'hF;   S_WVALID  = 0;
    S_BREADY  = 0;
    S_ARADDR  = '0; S_ARPROT  = 3'b000; S_ARVALID = 0;
    S_RREADY  = 0;

    repeat (10) @(posedge ACLK);
    ARESETn = 1'b1;
  end

  // -------------------------
  // AXI-Lite Master tasks (보수적 코딩)
  // -------------------------
  task axi_write(input [3:0] addr, input [31:0] data);
    begin
      @(posedge ACLK);
      S_AWADDR  <= addr;
      S_AWVALID <= 1'b1;
      S_WDATA   <= data;
      S_WSTRB   <= 4'hF;
      S_WVALID  <= 1'b1;
      S_BREADY  <= 1'b1;

      // Address/Data handshake
      wait (S_AWREADY && S_WREADY);
      @(posedge ACLK);
      S_AWVALID <= 1'b0;
      S_WVALID  <= 1'b0;

      // Write response
      wait (S_BVALID);
      @(posedge ACLK);
      S_BREADY  <= 1'b0;
    end
  endtask

  task axi_read(input [3:0] addr, output [31:0] data);
    begin
      @(posedge ACLK);
      S_ARADDR  <= addr;
      S_ARVALID <= 1'b1;
      S_RREADY  <= 1'b1;

      // Address handshake
      wait (S_ARREADY);
      @(posedge ACLK);
      S_ARVALID <= 1'b0;

      // Data phase
      wait (S_RVALID);
      data = S_RDATA;
      @(posedge ACLK);
      S_RREADY <= 1'b0;
    end
  endtask

  // -------------------------
  // UART line driver (PC 역할)
  // -------------------------
  time BIT_NS;
  initial BIT_NS = 104_166; // 1/9600 * 1e9

  task uart_send_byte(input logic [7:0] b);
    integer i;
    begin
      // Start bit
      rx <= 1'b0;
      #(BIT_NS);

      // 8 data bits, LSB first
      for (i = 0; i < 8; i = i + 1) begin
        rx <= b[i];
        #(BIT_NS);
      end

      // Stop bit (1)
      rx <= 1'b1;
      #(BIT_NS);

      // Gap
      #(BIT_NS);
    end
  endtask

  // -------------------------
  // Helpers / Constants
  // -------------------------
  localparam [3:0] REG_CR  = 4'h0; // 0x00
  localparam [3:0] REG_SR  = 4'h4; // 0x04
  localparam [3:0] REG_TXD = 4'h8; // 0x08 (현재 no-op)
  localparam [3:0] REG_RXD = 4'hC; // 0x0C

  function automatic bit sr_rx_empty(input [31:0] sr);
    sr_rx_empty = sr[0];
  endfunction

  // -------------------------
  // 테스트 데이터/변수 (모듈 범위에 선언)
  // -------------------------
  logic [7:0] vec [0:5];
  integer pass_cnt, fail_cnt, i;

  // 읽기 데이터 보관용(모듈 범위)
  reg [31:0] rx_word;
  reg [31:0] sr1, sr2;
  logic [7:0] got;
  logic [7:0] exp;

  initial begin
    // 테스트 패턴 초기화
    vec[0] = 8'h41; // 'A'
    vec[1] = 8'h42; // 'B'
    vec[2] = 8'h43; // 'C'
    vec[3] = 8'h55; // 'U'
    vec[4] = 8'h30; // '0'
    vec[5] = 8'h31; // '1'

    pass_cnt = 0;
    fail_cnt = 0;

    // 리셋 해제 대기
    wait (ARESETn==1'b1);
    repeat (5) @(posedge ACLK);

    // 1) CR = enable(1)
    axi_write(REG_CR, 32'h0000_0001);

    // 2) ASCII 전송 → 수신 확인
    for (i = 0; i < 6; i = i + 1) begin
      exp = vec[i];
      $display("[%0t] TB: Send 0x%02h on RX line", $time, exp);
      uart_send_byte(exp);

      // rx_empty==0 될 때까지 폴링
      do begin
        axi_read(REG_SR, sr1);
      end while (sr_rx_empty(sr1));

      // RXD 읽기(pop)
      axi_read(REG_RXD, rx_word);
      got = rx_word[7:0];

      if (got === exp) begin
        pass_cnt = pass_cnt + 1;
        $display("[%0t] PASS: Got 0x%02h", $time, got);
      end else begin
        fail_cnt = fail_cnt + 1;
        $display("[%0t] FAIL: Expect 0x%02h, Got 0x%02h", $time, exp, got);
      end

      // SR를 두 번 읽어서 flag clear 동작 확인(선택)
      axi_read(REG_SR, sr1);
      axi_read(REG_SR, sr2);
    end

    $display("==== SUMMARY: pass=%0d, fail=%0d ====", pass_cnt, fail_cnt);
    repeat (20) @(posedge ACLK);
    $finish;
  end

endmodule
