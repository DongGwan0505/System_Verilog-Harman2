`timescale 1ns/1ps

module tb_axi4lite_simple;

  // ------------------------
  // 클럭 / 리셋
  // ------------------------
  reg ACLK;
  reg ARESETn;

  // ------------------------
  // Host <-> Master
  // ------------------------
  reg  [31:0] addr;
  reg  [31:0] wdata;
  reg         write;
  reg         transfer;
  wire [31:0] rdata;
  wire        ready;

  // ------------------------
  // AXI-Lite 채널
  // ------------------------
  wire [3:0]  AWADDR;
  wire        AWVALID;
  wire        AWREADY;

  wire [31:0] WDATA;
  wire        WVALID;
  wire        WREADY;

  wire [1:0]  BRESP;
  wire        BVALID;
  wire        BREADY;

  wire [3:0]  ARADDR;
  wire        ARVALID;
  wire        ARREADY;

  wire [31:0] RDATA;
  wire        RVALID;
  wire        RREADY;
  wire [1:0]  RRESP;

  // ------------------------
  // DUT
  // ------------------------
  AXI4_Lite_Master u_master (.*);
  AXI4_Lite_Slave  u_slave  (.*);

  // ------------------------
  // 클럭 생성 (100 MHz)
  // ------------------------
  initial ACLK = 1'b0;
  always #5 ACLK = ~ACLK;

  // ------------------------
  // 테스트 시퀀스
  // ------------------------
  integer i;
  reg [31:0] rand_addr;
  reg [31:0] rand_data;
  reg [3:0]  offs4;   // Vivado 2020 호환용 임시 변수
  reg [31:0] exp_mem [0:3];

  initial begin
    // 초기화
    ARESETn  = 1'b0;
    addr     = 32'h0;
    wdata    = 32'h0;
    write    = 1'b0;
    transfer = 1'b0;
    exp_mem[0] = '0; exp_mem[1] = '0; exp_mem[2] = '0; exp_mem[3] = '0;

    // 리셋 해제
    repeat (5) @(posedge ACLK);
    ARESETn = 1'b1;
    repeat (2) @(posedge ACLK);

    $display("[%0t] ==== RANDOM TEST START ====", $time);

    // 랜덤 5회: 쓰고 → 읽고 → 비교
    for (i = 0; i < 5; i = i + 1) begin
      offs4     = i << 2;            // i * 4
      rand_addr = {28'h0, offs4};    // 0x00, 0x04, 0x08, 0x0C, ...
      rand_data = $urandom;

      // ---------------- WRITE ----------------
      @(posedge ACLK);
      addr  = rand_addr;
      wdata = rand_data;
      write = 1'b1;

      // transfer 2클록 유지 (엣지 놓침 방지)
      transfer = 1'b1;
      @(posedge ACLK);
      transfer = 1'b1;
      @(posedge ACLK);
      transfer = 1'b0;

      // 완료 대기
      wait (ready === 1'b1);
      @(posedge ACLK);
      write = 1'b0;

      exp_mem[rand_addr[3:2]] = rand_data;

      // ---------------- READ ----------------
      @(posedge ACLK);
      addr  = rand_addr;
      write = 1'b0;

      transfer = 1'b1;
      @(posedge ACLK);
      transfer = 1'b1;
      @(posedge ACLK);
      transfer = 1'b0;

      wait (ready === 1'b1);
      @(posedge ACLK);

      // 결과 체크
      if (rdata !== exp_mem[rand_addr[3:2]]) begin
        $display("[%0t] READ MISMATCH @%h exp=%h got=%h  **FAIL**",
                 $time, rand_addr, exp_mem[rand_addr[3:2]], rdata);
      end else begin
        $display("[%0t] READ OK       @%h data=%h", $time, rand_addr, rdata);
      end

      @(posedge ACLK);
    end

    $display("[%0t] ==== TEST END ====", $time);
    #50 $finish;
  end

endmodule
