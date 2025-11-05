`timescale 1 ns / 1 ps

module for_uart_v1_0_S00_AXI #
(
    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
    // Global Clock Signal
    input  wire                          S_AXI_ACLK,
    // Global Reset Signal (Active LOW)
    input  wire                          S_AXI_ARESETN,
    // Write address (issued by master, accepted by Slave)
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  wire [2:0]                    S_AXI_AWPROT,
    input  wire                          S_AXI_AWVALID,
    output wire                          S_AXI_AWREADY,
    // Write data (issued by master, accepted by Slave)
    input  wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire                              S_AXI_WVALID,
    output wire                              S_AXI_WREADY,
    // Write response
    output wire [1:0] S_AXI_BRESP,
    output wire       S_AXI_BVALID,
    input  wire       S_AXI_BREADY,
    // Read address (issued by master, accepted by Slave)
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  wire [2:0]                    S_AXI_ARPROT,
    input  wire                          S_AXI_ARVALID,
    output wire                          S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output wire [1:0]                    S_AXI_RRESP,
    output wire                          S_AXI_RVALID,
    input  wire                          S_AXI_RREADY,

    // ===== [추가 없음: 상위에서 rx/tx는 래퍼에서 내려줌] =====
    input  wire                           rx,
    output wire                           tx
);

    // ---------------- AXI4LITE signals (원형 유지) ----------------
    reg  [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg                           axi_awready;
    reg                           axi_wready;
    reg  [1:0]                    axi_bresp;
    reg                           axi_bvalid;
    reg  [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg                           axi_arready;
    reg  [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
    reg  [1:0]                    axi_rresp;
    reg                           axi_rvalid;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

    // 32-bit data: ADDR[...:2] 사용
    localparam integer ADDR_LSB          = (C_S_AXI_DATA_WIDTH/32) + 1; // =2
    localparam integer OPT_MEM_ADDR_BITS = 1;                            // 4 regs → 2비트

    wire rst_sync = ~S_AXI_ARESETN; // 내부 active-high reset
    reg  aw_en;

    // ---------------- 레지스터 맵 ----------------
    // 0x00: CR [0]=enable, [1]=soft_reset(1클럭 펄스 생성용)
    reg  [31:0] CR;

    // 0x04: SR {28'b0, [3]=rx_done_edge(Read-to-Clear), [2]=0, [1]=0, [0]=rx_empty}
    wire [31:0] SR;

    // 0x08: TXD (W/O) → 현재 uart_top 외부 push 미제공 → no-op (주석 처리)
    // 0x0C: RXD (R/O) {24'h0, data} 읽으면 pop(empty=1)

    // --------------- uart_top 인스턴스 ----------------
    wire [7:0] u_rx_data;
    wire       u_rx_done;

    // enable/soft_reset 처리
    reg soft_reset_q;          // 1클럭 펄스
    wire rst_uart = rst_sync | soft_reset_q | ~CR[0];

    always @(posedge S_AXI_ACLK or posedge rst_sync) begin
        if (rst_sync) soft_reset_q <= 1'b0;
        else          soft_reset_q <= CR[1]; // CR[1]에 1 쓰면 1클럭 하이
    end

    uart_top u_uart (
        .clk     (S_AXI_ACLK),
        .rst     (rst_uart),
        .rx      (rx),
        .tx      (tx),
        .rx_data (u_rx_data),
        .rx_done (u_rx_done)
    );

    // --------------- RX 버퍼(1바이트) & 상태 ---------------
    reg [7:0] rx_buf;
    reg       rx_empty;

    // rx_done 에지 검출 → SR[3] (Read-to-Clear)
    reg  rx_done_d;
    wire rx_done_edge = u_rx_done & ~rx_done_d;

    // SR 읽기 시(Read) edge 클리어
    wire rd_sr = (axi_arready & S_AXI_ARVALID & ~axi_rvalid) &&
                 (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h1);

    always @(posedge S_AXI_ACLK or posedge rst_uart) begin
        if (rst_uart) begin
            rx_done_d <= 1'b0;
        end else if (rd_sr) begin
            rx_done_d <= u_rx_done; // read-to-clear
        end else begin
            rx_done_d <= rx_done_d | rx_done_edge;
        end
    end

    // RX 데이터 수신 시 래치, 비었으면 0→1
    always @(posedge S_AXI_ACLK or posedge rst_uart) begin
        if (rst_uart) begin
            rx_buf   <= 8'h00;
            rx_empty <= 1'b1;
        end else if (u_rx_done) begin
            rx_buf   <= u_rx_data;
            rx_empty <= 1'b0;
        end
    end

    assign SR = {28'b0, rx_done_edge, 1'b0 /*tx_busy*/, 1'b0 /*tx_full*/, rx_empty};

    // ---------------- AWREADY / 주소 래치 ----------------
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_awready <= 1'b0;
            aw_en       <= 1'b1;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                axi_awready <= 1'b1;
                aw_en       <= 1'b0;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                aw_en       <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                axi_awready <= 1'b0;
            end
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) axi_awaddr <= {C_S_AXI_ADDR_WIDTH{1'b0}};
        else if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            axi_awaddr <= S_AXI_AWADDR;
    end

    // ---------------- WREADY ----------------
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) axi_wready <= 1'b0;
        else                axi_wready <= (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en);
    end

    // ---------------- Write 처리 (CR/TXD 전용) ----------------
    wire slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    integer byte_index;
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            CR <= 32'h0;
            // (참고) slv_reg1/2/3는 사용 안 함 (SR/RXD는 동적 생성)
        end else if (slv_reg_wren) begin
            case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
                2'h0: begin // CR
                    // 하위 바이트만 사용: [0]=enable, [1]=soft_reset
                    if (S_AXI_WSTRB[0]) CR[7:0] <= S_AXI_WDATA[7:0];
                end
                2'h2: begin // TXD (현재 no-op: uart_top 외부 TX push 미제공)
                    // TODO: uart_top에 tx_push/tx_byte 포트 추가 시 여기서 연결
                end
                default: ; // SR/RXD에 대한 쓰기는 무시
            endcase
        end
    end

    // ---------------- BRESP/BVALID ----------------
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_bvalid <= 1'b0;
            axi_bresp  <= 2'b00;
        end else begin
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid &&
                axi_wready  && S_AXI_WVALID) begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b00;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end
        end
    end

    // ---------------- ARREADY/주소 래치 ----------------
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_arready <= 1'b0;
            axi_araddr  <= {C_S_AXI_ADDR_WIDTH{1'b0}};
        end else begin
            if (~axi_arready && S_AXI_ARVALID) begin
                axi_arready <= 1'b1;
                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

    // ---------------- RVALID/RRESP ----------------
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_rvalid <= 1'b0;
            axi_rresp  <= 2'b00;
        end else begin
            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b00;
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid <= 1'b0;
            end
        end
    end

    // ---------------- Read MUX + RXD pop ----------------
    wire slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

    reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
    always @(*) begin
        case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
            2'h0: reg_data_out = CR;                       // CR
            2'h1: reg_data_out = SR;                       // SR (동적 생성)
            2'h2: reg_data_out = 32'h0000_0000;            // TXD read: 0
            2'h3: reg_data_out = {24'h0, rx_buf};          // RXD
            default: reg_data_out = 32'h0;
        endcase
    end

    // read data drive
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) axi_rdata <= {C_S_AXI_DATA_WIDTH{1'b0}};
        else if (slv_reg_rden) axi_rdata <= reg_data_out;
    end

    // RXD 읽기 시 pop(empty=1)
    always @(posedge S_AXI_ACLK or posedge rst_uart) begin
        if (rst_uart) begin
            rx_empty <= 1'b1;
        end else if (slv_reg_rden &&
                     (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h3) &&
                     ~rx_empty) begin
            rx_empty <= 1'b1; // pop
        end
    end

endmodule
