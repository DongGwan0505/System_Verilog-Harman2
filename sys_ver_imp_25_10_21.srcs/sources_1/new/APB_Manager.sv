/*
`timescale 1ns / 1ps

module APB_Manager (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [31:0] PRDATA0,
    input  logic [31:0] PRDATA1,
    input  logic [31:0] PRDATA2,
    input  logic [31:0] PRDATA3,
    input  logic        PREADY0,
    input  logic        PREADY1,
    input  logic        PREADY2,
    input  logic        PREADY3,
    output logic [31:0] PADDR,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic [31:0] PWDATA,
    output logic        PSEL0,
    output logic        PSEL1,
    output logic        PSEL2,
    output logic        PSEL3,
    // Internal Interface Signals
    input  logic        transfer,
    input  logic        write,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    output logic        ready
);
    logic        decoder_en;
    logic        temp_write_reg, temp_write_next;
    logic [31:0] temp_wdata_reg, temp_wdata_next;         
    logic [31:0] temp_addr_reg, temp_addr_next;
    logic [ 3:0] pselx;
    logic [1:0]  mux_sel;

    assign PSEL0 = pselx[0];
    assign PSEL1 = pselx[1];
    assign PSEL2 = pselx[2];
    assign PSEL3 = pselx[3];

    typedef enum {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;

    apb_state_e state, next_state;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            state <= IDLE;
            temp_write_reg <= 0;
            temp_addr_reg  <= 0;
            temp_wdata_reg <= 0;
        end else begin
            state <= next_state;
            temp_write_reg <= temp_write_next;
            temp_addr_reg  <= temp_addr_next;
            temp_wdata_reg <= temp_wdata_next;
        end
    end
    
    always_comb begin
        next_state      = state;
        temp_write_next = temp_write_reg;
        temp_addr_next  = temp_addr_reg;
        temp_wdata_next = temp_wdata_reg;
        decoder_en      = 1'b0;
        PENABLE         = 1'b0;
        PADDR           = temp_addr_reg;
        PWRITE          = temp_write_reg;
        PWDATA          = temp_wdata_reg;
        case (state)
            IDLE: begin
                decoder_en = 1'b0;
                if (transfer) begin
                    temp_write_next = write;
                    temp_addr_next  = addr;
                    temp_wdata_next = wdata;
                    next_state = SETUP;
                end
            end
            SETUP: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b0;
                PADDR      = temp_addr_reg;
                PWRITE     = temp_write_reg;
                next_state = ACCESS;
                if (temp_write_reg) begin
                    PWDATA = temp_wdata_reg;
                end
            end
            ACCESS: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b1;
                if (!transfer & ready) begin
                    next_state = IDLE;
                end else if (transfer & ready) begin
                    next_state = SETUP;
                end else begin
                    next_state = ACCESS;
                end
            end
        endcase
    end

    APB_Decoder U_APB_DECODER (
        //input
        .en     (decoder_en),
        .sel    (temp_addr_reg), //HADDR
        //output
        .y      (pselx),
        .mux_sel(mux_sel)
    );

    APB_Mux U_APB_MUX (
        //input
        .sel   (mux_sel),
        .rdata0(PRDATA0),
        .rdata1(PRDATA1),
        .rdata2(PRDATA2),
        .rdata3(PRDATA3),
        .ready0(PREADY0),
        .ready1(PREADY1),
        .ready2(PREADY2),
        .ready3(PREADY3),
        //output
        .rdata (rdata),
        .ready (ready)
    );

endmodule

module APB_Decoder (
    //input
    input  logic        en,
    input  logic [31:0] sel,     //HADDR
    //output
    output logic [ 3:0] y,
    output logic [ 1:0] mux_sel
);
    //for HSEL (y)
    always_comb begin
        y = 4'b0000;
        if (en) begin
            casex (sel)  //when using x(unknown) in case, you must use 'casex' 
                32'h1000_0xxx: y = 4'b0001;  //RAM domain 
                32'h1000_1xxx: y = 4'b0010;  //P1 domain 
                32'h1000_2xxx: y = 4'b0100;  //P2 domain 
                32'h1000_3xxx: y = 4'b1000;  //P3 domain  
            endcase
        end
    end

    //for Mux select (mux_sel)
    always_comb begin
        mux_sel = 2'dx;
        if (en) begin
            casex (sel)  //when using x(unknown) in case, you must use 'casex' 
                32'h1000_0xxx: mux_sel = 2'd0;  //RAM domain 
                32'h1000_1xxx: mux_sel = 2'd1;  //P1 domain 
                32'h1000_2xxx: mux_sel = 2'd2;  //P2 domain 
                32'h1000_3xxx: mux_sel = 2'd3;  //P3 domain  
            endcase
        end
    end
endmodule

module APB_Mux (
    //input
    input  logic [ 1:0] sel,
    input  logic [31:0] rdata0,
    input  logic [31:0] rdata1,
    input  logic [31:0] rdata2,
    input  logic [31:0] rdata3,
    input  logic        ready0,
    input  logic        ready1,
    input  logic        ready2,
    input  logic        ready3,
    //output
    output logic [31:0] rdata,
    output logic        ready
);
    //rdata Mux
    always_comb begin
        rdata = 32'b0;
        case (sel)
            2'd0: rdata = rdata0;
            2'd1: rdata = rdata1;
            2'd2: rdata = rdata2;
            2'd3: rdata = rdata3;
        endcase
    end

    //ready Mux
    always_comb begin
        ready = 1'b0;
        case (sel)
            2'd0: ready = ready0;
            2'd1: ready = ready1;
            2'd2: ready = ready2;
            2'd3: ready = ready3;
        endcase
    end

endmodule
*/

`timescale 1ns / 1ps

module APB_Manager (
    input  logic        PCLK,
    input  logic        PRESET,
    // APB IF
    input  logic [31:0] PRDATA0, PRDATA1, PRDATA2, PRDATA3,
    input  logic        PREADY0, PREADY1, PREADY2, PREADY3,
    output logic [31:0] PADDR,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic [31:0] PWDATA,
    output logic        PSEL0, PSEL1, PSEL2, PSEL3,
    // Internal IF
    input  logic        transfer,
    input  logic        write,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    output logic        ready
);
    // decoder enable (모듈 상단에만 선언)
    logic        decoder_en;

    // 쉐도우 레지스터
    logic        temp_write_reg, temp_write_next;
    logic [31:0] temp_wdata_reg, temp_wdata_next;
    logic [31:0] temp_addr_reg,  temp_addr_next;

    // 디코더/멀티플렉서
    logic [3:0]  pselx;
    logic [1:0]  mux_sel;
    assign PSEL0 = pselx[0];
    assign PSEL1 = pselx[1];
    assign PSEL2 = pselx[2];
    assign PSEL3 = pselx[3];

    typedef enum logic [1:0] { IDLE, SETUP, ACCESS } apb_state_e;
    apb_state_e state, next_state;

    // 상태/레지스터
    always_ff @(posedge PCLK or posedge PRESET) begin
        if (PRESET) begin
            state           <= IDLE;
            temp_write_reg  <= 1'b0;
            temp_addr_reg   <= '0;
            temp_wdata_reg  <= '0;
        end else begin
            state           <= next_state;
            temp_write_reg  <= temp_write_next;
            temp_addr_reg   <= temp_addr_next;
            temp_wdata_reg  <= temp_wdata_next;
        end
    end

    // 콤비네이셔널
    always_comb begin
        // 기본값
        next_state       = state;
        temp_write_next  = temp_write_reg;
        temp_addr_next   = temp_addr_reg;
        temp_wdata_next  = temp_wdata_reg;

        // 버스 드라이브는 쉐도우 레지스터에서
        PADDR            = temp_addr_reg;
        PWRITE           = temp_write_reg;
        PWDATA           = temp_wdata_reg;
        PENABLE          = 1'b0;
        decoder_en       = 1'b0;

        unique case (state)
            // 첫 트랜잭션: IDLE에서 래치
            IDLE: begin
                if (transfer) begin
                    temp_write_next = write;
                    temp_addr_next  = addr;
                    temp_wdata_next = wdata;
                    next_state      = SETUP;
                end
            end

            // SETUP: PSEL=1, PENABLE=0 (샘플 X)
            SETUP: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b0;
                next_state = ACCESS;
            end

            // ACCESS: PSEL=1, PENABLE=1, ready 대기
            ACCESS: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b1;
                if (ready) begin
                    if (transfer) begin
                        // back-to-back: 다음 트랜잭션 지금 래치
                        temp_write_next = write;
                        temp_addr_next  = addr;
                        temp_wdata_next = wdata;
                        next_state      = SETUP;
                    end else begin
                        next_state      = IDLE;
                    end
                end
            end
        endcase
    end

    // 디코더
    APB_Decoder U_APB_DECODER (
        .en     (decoder_en),
        .sel    (temp_addr_reg),
        .y      (pselx),
        .mux_sel(mux_sel)
    );

    // 리드데이터/레디 MUX
    APB_Mux U_APB_MUX (
        .sel   (mux_sel),
        .rdata0(PRDATA0), .rdata1(PRDATA1),
        .rdata2(PRDATA2), .rdata3(PRDATA3),
        .ready0(PREADY0), .ready1(PREADY1),
        .ready2(PREADY2), .ready3(PREADY3),
        .rdata (rdata),
        .ready (ready)
    );
endmodule


// 안전한 디코더(상위 니블/4KB 윈도우)
module APB_Decoder (
    input  logic        en,
    input  logic [31:0] sel,
    output logic [3:0]  y,
    output logic [1:0]  mux_sel
);
    always_comb begin
        y       = 4'b0000;
        mux_sel = 2'd0;
        if (en) begin
            if (sel[31:28] == 4'h1) begin
                unique case (sel[15:12])
                    4'h0: begin y = 4'b0001; mux_sel = 2'd0; end // 0x1000_0xxx
                    4'h1: begin y = 4'b0010; mux_sel = 2'd1; end // 0x1000_1xxx
                    4'h2: begin y = 4'b0100; mux_sel = 2'd2; end // 0x1000_2xxx
                    4'h3: begin y = 4'b1000; mux_sel = 2'd3; end // 0x1000_3xxx
                    default: begin y = 4'b0000; mux_sel = 2'd0; end
                endcase
            end
        end
    end
endmodule

module APB_Mux (
    input  logic [1:0]  sel,
    input  logic [31:0] rdata0, rdata1, rdata2, rdata3,
    input  logic        ready0, ready1, ready2, ready3,
    output logic [31:0] rdata,
    output logic        ready
);
    always_comb begin
        unique case (sel)
            2'd0: begin rdata = rdata0; ready = ready0; end
            2'd1: begin rdata = rdata1; ready = ready1; end
            2'd2: begin rdata = rdata2; ready = ready2; end
            2'd3: begin rdata = rdata3; ready = ready3; end
            default: begin rdata = 32'b0; ready = 1'b0; end
        endcase
    end
endmodule
