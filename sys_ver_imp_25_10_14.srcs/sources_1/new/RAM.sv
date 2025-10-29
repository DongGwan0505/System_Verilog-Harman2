`timescale 1ns / 1ps

module RAM (
    input  logic        clk,
    input  logic [ 2:0] strb,
    input  logic        we,
    input  logic [ 7:0] Addr,
    input  logic [31:0] wData,
    output logic [31:0] rData 
);
    logic [7:0] mem[0:2**8-1];

    always_ff @(posedge clk) begin
        if (we) begin
            mem[Addr] <= mem[Addr];
            case (strb)
                3'b000: begin  // byte
                    mem[Addr+0] <= wData[7:0];  
                end
                3'b001: begin  // half
                    mem[Addr+0] <= wData[7:0];
                    mem[Addr+1] <= wData[15:8];
                end
                3'b010: begin  // word
                    mem[Addr+0] <= wData[7:0];
                    mem[Addr+1] <= wData[15:8];
                    mem[Addr+2] <= wData[23:16];
                    mem[Addr+3] <= wData[31:24];
                end
            endcase
        end
    end

    always_comb begin
        rData = 0;
        case (strb)
            3'b000: begin
                rData[7:0]   = mem[Addr+0];  // byte
                rData[15:8]  = {8{mem[Addr][7]}};
                rData[23:16] = {8{mem[Addr][7]}};
                rData[31:24] = {8{mem[Addr][7]}};
            end
            3'b001: begin  // half
                rData[7:0]   = mem[Addr+0];  // half
                rData[15:8]  = mem[Addr+1];
                rData[23:16] = {8{mem[Addr+1][7]}};
                rData[31:24] = {8{mem[Addr+1][7]}};
            end
            3'b010: begin  // word
                rData[7:0]   = mem[Addr+0];  // word
                rData[15:8]  = mem[Addr+1];
                rData[23:16] = mem[Addr+2];
                rData[31:24] = mem[Addr+3];
            end
            3'b100: begin
                rData[7:0]   = mem[Addr+0];  // LBU
                rData[15:8]  = 0;
                rData[23:16] = 0;
                rData[31:24] = 0;
            end

            3'b101: begin
                rData[7:0]   = mem[Addr+0];  // LBH
                rData[15:8]  = mem[Addr+1];
                rData[23:16] = 0;
                rData[31:24] = 0;
            end
        endcase
    end
endmodule
