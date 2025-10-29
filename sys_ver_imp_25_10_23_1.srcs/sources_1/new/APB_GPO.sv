//`timescale 1ns / 1ps
//
//module APB_GPO(
//    // global signals
//    input  logic        PCLK,
//    input  logic        PRESET,
//    // APB Interface Signals
//    input  logic [ 2:0] PADDR,
//    input  logic        PWRITE,
//    input  logic        PSEL,
//    input  logic        PENABLE,
//    input  logic [31:0] PWDATA,
//    output logic [31:0] PRDATA,
//    output logic        PREADY,
//    //external Signal Ports
//    output logic [ 3:0] gpo
//);
//
//    logic [3:0] mode;
//    logic [3:0] out_data;
//
//    APB_Slave_GPO_Interface U_APB_Slave_GPO_Interface(.*);
//    apb_gpo U_apb_gpo(.*);
//
//endmodule
//
//module APB_Slave_GPO_Interface (
//    // global signals
//    input  logic        PCLK,
//    input  logic        PRESET,
//    // APB Interface Signals
//    input  logic [ 2:0] PADDR,
//    input  logic        PWRITE,
//    input  logic        PSEL,
//    input  logic        PENABLE,
//    input  logic [31:0] PWDATA,
//    output logic [31:0] PRDATA,
//    output logic        PREADY,
//    //internal SIgnals
//    output logic [3:0] mode,
//    output logic [3:0] out_data
//);
//    logic [31:0] slv_reg0, slv_reg1; //, slv_reg2, slv_reg3;
//
//    assign mode = slv_reg0[3:0];
//    assign out_data = slv_reg1[3:0];
//
//    /*
//    always_ff @(posedge PCLK, posedge PRESET) begin
//        if (PRESET) begin
//            slv_reg0 <= 0;
//            slv_reg1 <= 0;
//        end else begin
//            PREADY <= 1'b0;
//            if (PSEL & PENABLE) begin
//                PREADY <= 1'b1;
//                if (PWRITE) begin
//                    case (PADDR[2])
//                        1'd0: slv_reg0 <= PWDATA;
//                        1'd1: slv_reg1 <= PWDATA;
//                    endcase
//                end else begin
//                    case (PADDR[2])
//                        1'd0: PRDATA <= slv_reg0;
//                        1'd1: PRDATA <= slv_reg1;
//                    endcase
//
//                end
//            end
//        end
//    end
//    */
//    always_comb begin
//        PREADY = 1'b0;
//        PRDATA = '0;
//        if (PSEL && PENABLE) begin
//            PREADY = 1'b1;                     // ★ 핵심: 즉시 응답
//            if (!PWRITE) begin
//            unique case (PADDR[2])
//                1'b0: PRDATA = slv_reg0;       // MODER read
//                1'b1: PRDATA = slv_reg1;       // ODR   read
//            endcase
//            end
//        end
//        end
//
//    // 레지스터 쓰기만 클록에 저장
//    always_ff @(posedge PCLK or posedge PRESET) begin
//        if (PRESET) begin
//            slv_reg0 <= '0; slv_reg1 <= '0;
//        end else if (PSEL && PENABLE && PWRITE) begin
//            unique case (PADDR[2])
//            1'b0: slv_reg0 <= PWDATA;        // MODER write
//            1'b1: slv_reg1 <= PWDATA;        // ODR   write
//            endcase
//        end
//    end
//endmodule
//
//module apb_gpo (
//    input  logic [3:0] mode,
//    input  logic [3:0] out_data,
//    output logic [3:0] gpo
//);
//
//    genvar i;
//
//    //generate 문은 조합회로에서 for문을 사용할 수 있게 해 준다.
//    generate
//        for ( i = 0; i<4 ; i++) begin
//            assign gpo[i] = mode[i] ? out_data[i] : 1'b0;
//        end
//    endgenerate
//
//endmodule

`timescale 1ns / 1ps

module APB_GPO(
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 2:0] PADDR,
    input  logic        PWRITE,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    //external Signal Ports
    output logic [ 3:0] gpo
);

    logic [3:0] mode;
    logic [3:0] out_data;

    APB_Slave_GPO_Interface U_APB_Slave_GPO_Interface(.*);
    apb_gpo U_apb_gpo(.*);

endmodule

module APB_Slave_GPO_Interface (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 2:0] PADDR,
    input  logic        PWRITE,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    //internal SIgnals
    output logic [3:0] mode,
    output logic [3:0] out_data
);
    logic [31:0] slv_reg0, slv_reg1; //, slv_reg2, slv_reg3;

    assign mode = slv_reg0[3:0];
    assign out_data = slv_reg1[3:0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
        end else begin
            PREADY <= 1'b0;
            if (PSEL & PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[2])
                        1'd0: slv_reg0 <= PWDATA;
                        1'd1: slv_reg1 <= PWDATA;
                    endcase
                end else begin
                    case (PADDR[2])
                        1'd0: PRDATA <= slv_reg0;
                        1'd1: PRDATA <= slv_reg1;
                    endcase

                end
            end
        end
    end
endmodule

module apb_gpo (
    input  logic [3:0] mode,
    input  logic [3:0] out_data,
    output logic [3:0] gpo
);

    genvar i;

    //generate 문은 조합회로에서 for문을 사용할 수 있게 해 준다.
    generate
        for ( i = 0; i<4 ; i++) begin
            assign gpo[i] = mode[i] ? out_data[i] : 1'hz;
        end
    endgenerate

endmodule