
`timescale 1ns / 1ps

module AXI4_Lite_Master (
    //global Signal
    input  logic        ACLK,
    input  logic        ARESETn,
    //Host - Master
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic        write,
    input  logic        transfer,
    output logic [31:0] rdata,
    output logic        ready,
    //Write Transaction
    //AW Channel
    output logic [ 3:0] AWADDR,
    output logic        AWVALID,
    input  logic        AWREADY,
    //W Channel
    output logic [31:0] WDATA,
    output logic        WVALID,
    input  logic        WREADY,
    //B Channel
    input  logic [ 1:0] BRESP,
    input  logic        BVALID,
    output logic        BREADY,
    //Read Transaction
    //AR Channel
    output logic [ 3:0] ARADDR,
    output logic        ARVALID,
    input  logic        ARREADY,
    //R Channel
    input  logic [31:0] RDATA,
    input  logic        RVALID,
    output logic        RREADY,
    input  logic [ 1:0] RRESP
);

    logic w_ready, r_ready;
    logic [31:0] rdata_slv;

    assign ready = w_ready | r_ready;
    assign rdata = rdata_slv;

    //WRITE Transaction, AW Channel
    typedef enum { 
        AW_IDLE_S,
        AW_VALID_S
    } aw_state_e;

    aw_state_e aw_state, aw_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            aw_state <= AW_IDLE_S;
        end else begin
            aw_state <= aw_state_next;
        end
    end

    always_comb begin
        aw_state_next = aw_state;
        AWVALID       = 1'b0;
        AWADDR        = addr[3:0];
        case (aw_state)
            AW_IDLE_S: begin
                AWVALID = 1'b0;
                if(transfer & write) begin
                    aw_state_next = AW_VALID_S;
                end
            end

            AW_VALID_S: begin
                AWADDR  = addr;
                AWVALID = 1'b1;
                if (AWVALID & AWREADY) begin
                    aw_state_next = AW_IDLE_S;
                end
            end  
        endcase
    end

    //WRITE Transaction, W Channel
    typedef enum { 
        W_IDLE_S,
        W_VALID_S
    } w_state_e;

    w_state_e w_state, w_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            w_state <= W_IDLE_S;
        end else begin
            w_state <= w_state_next;
        end
    end

    always_comb begin
        w_state_next = w_state;
        WVALID       = 1'b0;
        WDATA        = wdata;
        case (w_state)
            W_IDLE_S: begin
                WVALID = 1'b0;
                if(transfer & write) begin
                    w_state_next = W_VALID_S;
                end
            end

            W_VALID_S: begin
                WDATA = wdata;
                WVALID = 1'b1;
                if (WVALID & WREADY) begin
                    w_state_next = W_IDLE_S;
                end
            end  
        endcase
    end

    //WRITE Transaction, B Channel
    typedef enum { 
        B_IDLE_S,
        B_READY_S
    } b_state_e;

    b_state_e b_state, b_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            b_state <= B_IDLE_S;
        end else begin
            b_state <= b_state_next;
        end
    end

    always_comb begin
        b_state_next = b_state;
        BREADY       = 1'b0;
        w_ready        = 1'b0;
        case (b_state)
            B_IDLE_S: begin
                BREADY = 1'b0;
                if(BVALID) begin
                    b_state_next = B_READY_S;
                end
            end

            B_READY_S: begin
                BREADY = 1'b1;
                if (BVALID & BREADY) begin
                    b_state_next = B_IDLE_S;
                    w_ready        = 1'b1;
                end
            end  
        endcase
    end

    //READ Transaction, AR Channel
    typedef enum { 
        AR_IDLE_S,
        AR_VALID_S
    } ar_state_e;

    ar_state_e ar_state, ar_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            ar_state <= AR_IDLE_S;
        end else begin
            ar_state <= ar_state_next;
        end
    end

    always_comb begin
        ar_state_next = ar_state;
        ARVALID       = 1'b0;
        ARADDR        = addr[3:0];
        case (ar_state)
            AR_IDLE_S: begin
                ARVALID = 1'b0;
                if(transfer & !(write)) begin
                    ar_state_next = AR_VALID_S;
                end
            end

            AR_VALID_S: begin
                ARADDR  = addr;
                ARVALID = 1'b1;
                if (ARVALID & ARREADY) begin
                    ar_state_next = AR_IDLE_S;
                end
            end  
        endcase
    end

    //READ Transaction, R Channel
    logic rd_inflight;

    always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) rd_inflight <= 1'b0;
    else begin
        // ARVALID&ARREADY 성립 시 읽기 outstanding
        if (ARVALID && ARREADY) rd_inflight <= 1'b1;
        // RVALID&RREADY 성립 시 클리어
        if (RVALID && RREADY)   rd_inflight <= 1'b0;
    end
    end

    // 2-state FSM
    typedef enum logic { R_IDLE_S, R_READY_S } r_state_e;
    r_state_e r_state, r_state_next;

    always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) r_state <= R_IDLE_S;
    else          r_state <= r_state_next;
    end

    // 데이터 래치 + 완료 펄스
    always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        rdata_slv <= '0;
        r_ready   <= 1'b0;
    end else begin
        r_ready <= 1'b0;
        if (r_state == R_READY_S && RVALID) begin
        rdata_slv <= RDATA;
        r_ready   <= 1'b1;
        end
    end
    end

    always_comb begin
    r_state_next = r_state;
    RREADY       = 1'b0;
    unique case (r_state)
        R_IDLE_S : if (rd_inflight) r_state_next = R_READY_S;
        R_READY_S: begin
        RREADY = 1'b1;                 
        if (RVALID) r_state_next = R_IDLE_S;
        end
    endcase
    end


endmodule

/*
module AXI4_Lite_Slave (
    //global Signal
    input  logic        ACLK,
    input  logic        ARESETn,
    //Write Transaction
    //AW Channel
    input  logic [3:0] AWADDR,
    input  logic AWVALID,
    output logic AWREADY,
    //W Channel
    input  logic [31:0] WDATA,
    input  logic WVALID,
    output logic WREADY,
    //B Channel
    output logic [1:0] BRESP,
    output logic BVALID,
    input  logic BREADY,
    //Write Transaction
    //AR Channel
    input  logic [3:0] ARADDR,
    input  logic ARVALID,
    output logic ARREADY,
    //R Channel
    output logic [31:0] RDATA,
    output logic RVALID,
    input  logic RREADY,
    output logic [1:0] RRESP
);
    logic [31:0] slv_reg [0:3];

    logic [3:0] aw_addr, ar_addr;
    logic [31:0] slv_register_addr;

    wire aw_hs = AWVALID & AWREADY;
    wire w_hs  = WVALID  & WREADY;
    wire ar_hs = ARVALID & ARREADY;

    //WRITE Transaction, AW Channel
    typedef enum { 
        AW_IDLE_S,
        AW_READY_S
    } aw_state_e;

    aw_state_e aw_state, aw_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            aw_state <= AW_IDLE_S;
        end else begin
            aw_state <= aw_state_next;
        end
    end

    always_comb begin
        aw_state_next = aw_state;
        AWREADY = 1'b0;
        case (aw_state)
            AW_IDLE_S: begin
                AWREADY = 1'b0;
                if(AWVALID) begin
                    aw_state_next = AW_READY_S;
                end
            end

            AW_READY_S: begin
                aw_addr = AWADDR;
                AWREADY = 1'b1;
                aw_state_next = AW_IDLE_S;
            end  
        endcase
    end

    //WRITE Transaction, W Channel
    typedef enum { 
        W_IDLE_S,
        W_READY_S
    } w_state_e;

    w_state_e w_state, w_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            w_state <= W_IDLE_S;
        end else begin
            w_state <= w_state_next;
        end
    end

    always_comb begin
        w_state_next = w_state;
        WREADY = 1'b0;
        case (w_state)
            W_IDLE_S: begin
                WREADY = 1'b0;
                if(WVALID) begin
                    w_state_next = W_READY_S;
                end
            end

            W_READY_S: begin
                slv_register_addr = WDATA;
                WREADY = 1'b1;
                w_state_next = W_IDLE_S;
            end  
        endcase
    end

    //WRITE Transaction, B Channel
    typedef enum { 
        B_IDLE_S,
        B_VALID_S
    } b_state_e;

    b_state_e b_state, b_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            b_state <= B_IDLE_S;
        end else begin
            b_state <= b_state_next;
        end
    end

    always_comb begin
        b_state_next = b_state;
        BVALID = 1'b0;
        case (b_state)
            B_IDLE_S: begin
                BVALID = 1'b0;
                if(WVALID & WREADY) begin
                    b_state_next = B_VALID_S;
                end
            end

            B_VALID_S: begin
                BRESP  = 1'b0;
                BVALID = 1'b1;
                b_state_next = B_IDLE_S;
            end  
        endcase
    end

    //Read Transaction, AR Channel
    typedef enum { 
        AR_IDLE_S,
        AR_READY_S
    } ar_state_e;

    ar_state_e ar_state, ar_state_next;

    always_ff @( posedge ACLK) begin
        if (!ARESETn) begin //동기화 리셋
            ar_state <= AR_IDLE_S;
        end else begin
            ar_state <= ar_state_next;
        end
    end

    always_comb begin
        ar_state_next = ar_state;
        ARREADY = 1'b0;
        case (ar_state)
            AR_IDLE_S: begin
                ARREADY = 1'b0;
                if(ARVALID) begin
                    ar_state_next = AR_READY_S;
                end
            end

            AR_READY_S: begin
                ar_addr = ARADDR;
                ARREADY = 1'b1;
                ar_state_next = AR_IDLE_S;
            end  
        endcase
    end

    //Read Transaction, R Channel
    typedef enum { 
        R_IDLE_S,
        R_VALID_S
    } r_state_e;

    r_state_e r_state, r_state_next;

    always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        r_state <= R_IDLE_S;
        RVALID  <= 1'b0;
        RDATA   <= '0;
        RRESP   <= 2'b00; // OKAY
    end else begin
        r_state <= r_state_next;

        // RVALID 유지/내림
        if (r_state == R_VALID_S && RVALID && RREADY)
        RVALID <= 1'b0;

        // AR 수락 시점에 데이터 준비 + RVALID 올림
        if (r_state == R_IDLE_S && ar_hs) begin
        RDATA  <= slv_reg[ARADDR[3:2]];  // 또는 araddr_q[3:2]
        RRESP  <= 2'b00;                 // OKAY
        RVALID <= 1'b1;
        end
    end
    end

    always_comb begin
    r_state_next = r_state;
    unique case (r_state)
        R_IDLE_S : begin
        // AR 수락되면 다음 사이클부터 RVALID 상태
        if (ar_hs) r_state_next = R_VALID_S;
        end
        R_VALID_S: begin
        // 마스터가 RREADY 주면 한 번에 종료
        if (RVALID && RREADY) r_state_next = R_IDLE_S;
        end
    endcase
    end

endmodule
*/


// ==============================
// AXI4-Lite Slave (4 regs @ 0x00/04/08/0C)
// ==============================
module AXI4_Lite_Slave (
    //global Signal
    input  logic        ACLK,
    input  logic        ARESETn,
    //Write Transaction
    //AW Channel
    input  logic [3:0]  AWADDR,
    input  logic        AWVALID,
    output logic        AWREADY,
    //W Channel
    input  logic [31:0] WDATA,
    input  logic        WVALID,
    output logic        WREADY,
    //B Channel
    output logic [1:0]  BRESP,
    output logic        BVALID,
    input  logic        BREADY,
    //Read Transaction
    //AR Channel
    input  logic [3:0]  ARADDR,
    input  logic        ARVALID,
    output logic        ARREADY,
    //R Channel
    output logic [31:0] RDATA,
    output logic        RVALID,
    input  logic        RREADY,
    output logic [1:0]  RRESP
);
    // 4 x 32-bit registers
    logic [31:0] slv_reg [0:3];

    // handshakes
    wire aw_hs = AWVALID & AWREADY;
    wire w_hs  = WVALID  & WREADY;
    wire ar_hs = ARVALID & ARREADY;

    // -------------------------
    // WRITE: AW Channel (FSM)
    // -------------------------
    typedef enum { AW_IDLE_S, AW_READY_S } aw_state_e;
    aw_state_e aw_state, aw_state_next;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) aw_state <= AW_IDLE_S;
        else          aw_state <= aw_state_next;
    end

    always_comb begin
        aw_state_next = aw_state;
        AWREADY = 1'b0;
        unique case (aw_state)
            AW_IDLE_S: begin
                if (AWVALID) aw_state_next = AW_READY_S;
            end
            AW_READY_S: begin
                AWREADY = 1'b1;              // accept this cycle
                aw_state_next = AW_IDLE_S;
            end
        endcase
    end

    // -------------------------
    // WRITE: W Channel (FSM)
    // -------------------------
    typedef enum { W_IDLE_S, W_READY_S } w_state_e;
    w_state_e w_state, w_state_next;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) w_state <= W_IDLE_S;
        else          w_state <= w_state_next;
    end

    always_comb begin
        w_state_next = w_state;
        WREADY = 1'b0;
        unique case (w_state)
            W_IDLE_S: begin
                if (WVALID) w_state_next = W_READY_S;
            end
            W_READY_S: begin
                WREADY = 1'b1;               // accept this cycle
                w_state_next = W_IDLE_S;
            end
        endcase
    end

    // -------------------------
    // WRITE: latch + commit (robust to AW/W reorder)
// -------------------------
    logic [3:0]  awaddr_q;
    logic [31:0] wdata_q;
    logic        aw_seen, w_seen;
    logic        wr_commit;  // 1-cycle pulse when both accepted and write done

    always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) begin
        awaddr_q  <= '0;
        wdata_q   <= '0;
        aw_seen   <= 1'b0;
        w_seen    <= 1'b0;
        wr_commit <= 1'b0;
      end else begin
        wr_commit <= 1'b0;   // default

        if (aw_hs) begin
          awaddr_q <= AWADDR;   // capture address
          aw_seen  <= 1'b1;
        end
        if (w_hs) begin
          wdata_q <= WDATA;     // capture data
          w_seen  <= 1'b1;
        end

        if (aw_seen && w_seen) begin
          slv_reg[awaddr_q[3:2]] <= wdata_q;  // 0x00/04/08/0C -> [3:2]
          aw_seen   <= 1'b0;
          w_seen    <= 1'b0;
          wr_commit <= 1'b1;                  // commit pulse
        end
      end
    end

    // -------------------------
    // WRITE: B Channel (driven by wr_commit)
    // -------------------------
    typedef enum { B_IDLE_S, B_VALID_S } b_state_e;
    b_state_e b_state, b_state_next;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) b_state <= B_IDLE_S;
        else          b_state <= b_state_next;
    end

    always_comb begin
        b_state_next = b_state;
        BVALID = 1'b0;
        BRESP  = 2'b00;                 // OKAY
        unique case (b_state)
            B_IDLE_S: begin
                if (wr_commit)          // commit moment → respond
                    b_state_next = B_VALID_S;
            end
            B_VALID_S: begin
                BVALID = 1'b1;          // hold until master ready
                if (BREADY)
                    b_state_next = B_IDLE_S;
            end
        endcase
    end

    // -------------------------
    // READ: AR Channel (FSM)
    // -------------------------
    typedef enum { AR_IDLE_S, AR_READY_S } ar_state_e;
    ar_state_e ar_state, ar_state_next;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) ar_state <= AR_IDLE_S;
        else          ar_state <= ar_state_next;
    end

    always_comb begin
        ar_state_next = ar_state;
        ARREADY = 1'b0;
        unique case (ar_state)
            AR_IDLE_S: begin
                if (ARVALID) ar_state_next = AR_READY_S;
            end
            AR_READY_S: begin
                ARREADY = 1'b1;         // accept this cycle
                ar_state_next = AR_IDLE_S;
            end
        endcase
    end

    // -------------------------
    // READ: R Channel (2-state)
    // -------------------------
    typedef enum { R_IDLE_S, R_VALID_S } r_state_e;
    r_state_e r_state, r_state_next;

    always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) begin
        r_state <= R_IDLE_S;
        RVALID  <= 1'b0;
        RDATA   <= '0;
        RRESP   <= 2'b00; // OKAY
      end else begin
        r_state <= r_state_next;

        // drop when accepted
        if (r_state == R_VALID_S && RVALID && RREADY)
          RVALID <= 1'b0;

        // prepare data at AR accept
        if (r_state == R_IDLE_S && ar_hs) begin
          RDATA  <= slv_reg[ARADDR[3:2]];
          RRESP  <= 2'b00; // OKAY
          RVALID <= 1'b1;
        end
      end
    end

    always_comb begin
      r_state_next = r_state;
      unique case (r_state)
        R_IDLE_S : if (ar_hs)                    r_state_next = R_VALID_S;
        R_VALID_S: if (RVALID && RREADY)         r_state_next = R_IDLE_S;
      endcase
    end

endmodule
