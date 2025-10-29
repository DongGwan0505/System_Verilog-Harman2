`timescale 1ns / 1ps

module ROM (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:2**8-1];

    initial begin
        //$readmemh("code.mem",rom);
         //rom[x]=32'b imm(7)_  rs2 _ rs1 _f3  imm(5)  opcode; // B-Type
        //rom[0] = 32'b0000000_00010_00010_000_01100_1100011;  // beq x2, x2, 12;
        

        
        //rom[x]=32'b        imm(20)_       rd _ opcode; // LU-Type
        rom[0] = 32'b00010000000000000000_10001_0110111;  // Lui x17 
        rom[1] = 32'b00010000000000000000_10001_0010111;  // Aui x17 
    
    end

    assign data = rom[addr[31:2]];
endmodule
