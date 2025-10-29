`timescale 1ns / 1ps

module APB_Slave (
    //global signal
    input  logic        PCLK,
    input  logic        PRESET,
    //APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic        PWRITE,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3; //32bits register 생성

    //저장
    always_ff @( posedge PCLK, posedge PRESET ) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            PREADY <= 1'b0;
            if (PSEL & PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    //레지스터에 저장
                    case (PADDR[3:2])
                        2'd0 : slv_reg0 <= PWDATA;
                        2'd1 : slv_reg1 <= PWDATA;
                        2'd2 : slv_reg2 <= PWDATA;
                        2'd3 : slv_reg3 <= PWDATA;
                    endcase    
                end else begin
                    //레지스터를 읽기
                    case (PADDR[3:2])
                        2'd0 : PRDATA <= slv_reg0;
                        2'd1 : PRDATA <= slv_reg1;
                        2'd2 : PRDATA <= slv_reg2;
                        2'd3 : PRDATA <= slv_reg3;
                    endcase  
                end
            end
        end
    end

endmodule
