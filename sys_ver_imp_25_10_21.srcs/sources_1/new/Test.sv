`timescale 1ns / 1ps

module Test_Master (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] rdata,
    input  logic        ready,     
    output logic        transfer, 
    output logic        write,    
    output logic [31:0] addr,      
    output logic [31:0] wdata      
);
    // regs
    logic        transfer_reg, transfer_next;
    logic        write_reg,    write_next;
    logic [31:0] addr_reg,     addr_next;
    logic [31:0] wdata_reg,    wdata_next;

    logic [31:0] mem [0:150];
    logic [31:0] dat [0:150];

    int unsigned i, j;
    int unsigned k_reg, k_next;

    // visible outputs
    assign transfer = transfer_reg;
    assign write    = write_reg;
    assign addr     = addr_reg;
    assign wdata    = wdata_reg;

    initial begin
        for (i = 0; i < 100; i++) mem[i] = 32'h1000_0000 + i*32'h100;
        for (j = 0; j < 100; j++) dat[j] = j;
    end

    typedef enum logic [1:0] { IDLE, PREP, SETUP, ACCESS } state_e;
    state_e state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            transfer_reg <= 1'b0;
            write_reg    <= 1'b0;
            addr_reg     <= '0;
            wdata_reg    <= '0;
            k_reg        <= 0;
        end else begin
            state        <= next_state;
            transfer_reg <= transfer_next;
            write_reg    <= write_next;
            addr_reg     <= addr_next;
            wdata_reg    <= wdata_next;
            k_reg        <= k_next;
        end
    end

    always_comb begin
        next_state    = state;
        transfer_next = transfer_reg;
        write_next    = write_reg;
        addr_next     = addr_reg;
        wdata_next    = wdata_reg;
        k_next        = k_reg;

        unique case (state)
            IDLE: begin
                transfer_next = 1'b0;
                write_next    = 1'b0;
                if (k_reg < 100) begin
                    addr_next  = mem[k_reg];
                    wdata_next = dat[k_reg];
                    next_state = PREP;         
                end
            end

            PREP: begin
                transfer_next = 1'b1;
                write_next    = 1'b1;         
                next_state    = SETUP;
            end

            SETUP: begin
                transfer_next = 1'b1;
                write_next    = 1'b1;
                next_state    = ACCESS;
            end

            ACCESS: begin
                if (ready) begin
                    if (k_reg + 1 < 100) begin
                        k_next        = k_reg + 1;
                        addr_next     = mem[k_next];
                        wdata_next    = dat[k_next];
                        dat[k_reg]    = rdata;
                        transfer_next = 1'b0;
                        write_next    = 1'b0;
                        next_state    = PREP; 
                    end else begin
                        transfer_next = 1'b0;
                        write_next    = 1'b0;
                        next_state    = IDLE;
                    end
                end else begin
                    next_state = ACCESS;
                end
            end
        endcase
    end
endmodule


module Test_Slave_0 (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] PADDR,
    input  logic        PWRITE,
    input  logic        PSEL0,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA0,
    output logic        PREADY0
);
    logic [31:0] mem [0:255];
    logic [31:0] addr_reg, wdata_reg;
    logic        write_reg;
    logic [31:0] rdata_reg;

    assign PRDATA0 = rdata_reg;
    assign PREADY0 = PSEL0 & PENABLE;

    wire [7:0] word_idx = PADDR[2 +: 8];
    
    integer i = 0;

    initial begin
        for ( i=0 ; i<255; i = i + 1) begin
            mem[i] <= 32'h1234_5678 + i;
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_reg  <= 32'b0;
            wdata_reg <= 32'b0;
            write_reg <= 1'b0;
            rdata_reg <= 32'b0;
        end
        else begin
            if (PSEL0 && !PENABLE) begin
                addr_reg  <= PADDR;
                wdata_reg <= PWDATA;
                write_reg <= PWRITE;
            end

            if (PSEL0 && PENABLE) begin
                if (write_reg) begin
                    mem[word_idx] <= wdata_reg;  
                    rdata_reg <= mem[word_idx];  
                end
                else begin
                    rdata_reg <= mem[word_idx]; 
                end
            end
        end
    end
endmodule
