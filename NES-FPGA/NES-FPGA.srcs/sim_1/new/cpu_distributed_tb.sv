`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Illinois Urbana-Champaign
// Engineer: Bryce Mikos, Jeffery Lefkovitz
// 
// Create Date: 04/17/2025 10:41:02 PM
// Design Name: 
// Module Name: cpu_distributed_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_distributed_tb();

timeunit 10ns;
timeprecision 1ns;

logic Clk;
logic toggle;

logic cpu_reset_n, cpu_en, Clk, cpu_rdy, cpu_R_W_n, cpu_IRQ_n; // tb, tb, tb, tb, CPU
logic [23:0] cpu_A; // CPU
logic [7:0] cpu_DI, cpu_DO; // tb, CPU
logic [63:0] cpu_regs; // -- 6502 registers (MSB) PC, SP, P, Y, X, A (LSB) [CPU]

logic [15:0] a;
logic [7:0] d;
logic we;
logic [7:0] spo;

logic [15:0] a_i;
logic [7:0] d_i;
logic we_i;


initial begin: CLOCK_INIT
    Clk = 1;
end
    
always begin: CLOCK_GEN
    #5 Clk = ~Clk;
end

T65 cpu(
    .Mode(2'b00),
    .BCD_en(1'b0),
    
    .Res_n(cpu_reset_n),//tb
    .Enable(cpu_en),    //tb
    .Clk(Clk),          //tb
    .Rdy(cpu_rdy),      //tb 
    .IRQ_n(cpu_IRQ_n),  // tb
    .R_W_n(cpu_R_W_n),  //CPU
    .A(cpu_A),          //CPU
    .DI(cpu_DI),        //tb (internal)
    .DO(cpu_DO),        // CPU
    .Regs(cpu_regs)     //CPU
);

dist_mem_gen_0 ram(
    .a(a),
    .d(d),
    .clk(Clk),
    .we(we),
    .spo(spo)
);

always_comb begin: TOGGLE_BEHAV
    if(toggle == 1'b1) begin
        a = cpu_A[15:0];
        d = cpu_DO;
        we = ~cpu_R_W_n;
        cpu_DI = spo;
    end else begin
        a = a_i;
        d = d_i;
        we = we_i;
        //spo = spo;
    end
end

initial begin: TEST_VECTORS
    toggle = 0;
    cpu_en = 0;
    cpu_rdy = 0;
    cpu_IRQ_n = 0;
    
    cpu_reset_n = 0;
    
    TestTwo();
    
    for(int i=32'h00008000; i < 32'h00008008; i++) readFromAddr(i[15:0]);
    
    toggle = 1;
    
    cpu_en = 1;
    cpu_rdy = 1;
    repeat(10) @(posedge Clk);
    cpu_reset_n = 1;
    repeat(100) @(posedge Clk);
    
    toggle = 0;
    
    readFromAddr(16'h80de);
    readFromAddr(16'h9000);
    readFromAddr(16'h9001);
    $finish;
end

task TestOne();
    writeToAddr(16'h8000, 8'hA9); // LDA $#34
    writeToAddr(16'h8001, 8'h34); 
    writeToAddr(16'h8002, 8'h8D); // STA $80de
    writeToAddr(16'h8003, 8'hDE);
    writeToAddr(16'h8004, 8'h80);
    writeToAddr(16'h8005, 8'h4C); // JMP $8000
    writeToAddr(16'h8006, 8'h00);
    writeToAddr(16'h8007, 8'h80);
    writeToAddr(16'hfffc, 8'h00); // Set starting address to $8000
    writeToAddr(16'hfffd, 8'h80);
endtask

task TestTwo();
    writeToAddr(16'h8000, 8'hA9); // LDA $#01
    writeToAddr(16'h8001, 8'h01); 
    
    writeToAddr(16'h8002, 8'h8D); // STA $9000
    writeToAddr(16'h8003, 8'h00);
    writeToAddr(16'h8004, 8'h90);
    
    writeToAddr(16'h8005, 8'h69); // ADC #$10
    writeToAddr(16'h8006, 8'h10);
    
    writeToAddr(16'h8007, 8'h8D); // STA $9001
    writeToAddr(16'h8008, 8'h01);
    writeToAddr(16'h8009, 8'h90);
    
    writeToAddr(16'h800A, 8'h4C); // JMP $8005
    writeToAddr(16'h800B, 8'h05);
    writeToAddr(16'h800C, 8'h80);
    
    writeToAddr(16'hfffc, 8'h00); // Set starting address to $8000
    writeToAddr(16'hfffd, 8'h80);
    
endtask

task writeToAddr(input logic [15:0] addr, input logic [7:0] data);
    a_i = addr;
    d_i = data;
    we_i = 1;
    @(posedge Clk);
    we_i = 0;
endtask

task readFromAddr(input logic [15:0] addr);
    a_i = addr;
    we_i = 0;
    @(posedge Clk);
    $display("MEM[%h] = %h", addr, spo);
endtask

endmodule
