`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:47:30 PM
// Design Name: 
// Module Name: cpu_testbench
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


module cpu_testbench();

timeunit 10ns;
timeprecision 1ns;

logic cpu_reset_n, cpu_en, Clk, cpu_rdy, cpu_R_W_n, cpu_IRQ_n; // tb, tb, tb, tb, CPU
logic [23:0] cpu_A; // CPU
logic [7:0] cpu_DI, cpu_DO; // tb, CPU
logic [63:0] cpu_regs; // -- 6502 registers (MSB) PC, SP, P, Y, X, A (LSB) [CPU]
logic portA_en;
logic RAM_Clk;

//loading mem signals

logic [15:0] addrb; 
logic enb, web;
logic [7:0] dinb, doutb;

initial begin: CLOCK_INIT
    Clk = 1;
    end
    
always begin: CLOCK_GEN
    #10 Clk = ~Clk;
    end
    
initial begin: CLOCK_INIT2
    RAM_Clk = 1;
    end
    
always begin: CLOCK_GEN2
    #1 RAM_Clk = ~RAM_Clk;
    end
    
T65 cpu(
    .Mode(2'b00),
    .BCD_en(1'b0),
    
    .Res_n(cpu_reset_n), //tb
    .Enable(cpu_en), //tb
    .Clk(Clk), //tb
    .Rdy(cpu_rdy), //tb 
    .IRQ_n(cpu_IRQ_n), // tb
    .R_W_n(cpu_R_W_n), //CPU
    .A(cpu_A),//CPU
    .DI(cpu_DI), //tb (internal)
    .DO(cpu_DO), // CPU
    .Regs(cpu_regs) //CPU
);
logic [7:0] fuckassvariablename;
blk_mem_gen_0 RAM(
    .addra(cpu_A[15:0]),  // Address from the 6502 CPU (16-bit address space)
    .clka(RAM_Clk),            // Clock signal for memory
    .dina(cpu_DO),         // Data from the CPU to be written to memory
    .douta(fuckassvariablename),        // Data from memory to the CPU
    .ena(portA_en),          // Enable signal from the CPU
    .wea(~cpu_R_W_n),      // Write enable (active low when writing)
    
    .addrb(addrb),
    .clkb(RAM_Clk),
    .dinb(dinb),
    .doutb(doutb),
    .enb(enb),
    .web(web)
);

//logic wait_pending;
//always @(posedge Clk) begin
//    if (!cpu_R_W_n && !wait_pending) begin
//        // Start wait state
//        cpu_en <= 0;
//        wait_pending <= 1;
//    end else if (wait_pending) begin
//        // Resume CPU after 1 cycle
//        cpu_en <= 1;
//        wait_pending <= 0;
//    end else begin
//        cpu_en <= 1; // Normal operation
//        wait_pending <= 0;
//    end
//end
logic pluh;

always @(posedge Clk) begin
    if(pluh) cpu_DI = fuckassvariablename;
    else cpu_DI = 8'h00;
    
    if(~cpu_R_W_n) writeToAddr(cpu_A[15:0], cpu_DO);
end


initial begin: TEST_MEMORY
    pluh = 1'b0;
    //cpu_DI = 8'h00;
    writeTestOne();
    portA_en = 1'b1;
    cpu_en = 0;
    cpu_rdy = 0;
    cpu_reset_n = 0;
    @(posedge Clk);
    @(posedge Clk);
    @(posedge Clk);
    cpu_reset_n = 1;
    repeat(10) @(posedge Clk);
    enb = 1'b0;
    cpu_en = 1;
    cpu_rdy = 1;
    repeat (7) @(posedge Clk);
    pluh = 1'b1;
    //cpu_DI = fuckassvariablename;
    
    
    #10000

    readFromAddr(16'h0900);
    $finish();
    end
    
task writeTestOne();
    writeToAddr(16'h0000, 8'hA9);
    writeToAddr(16'h0001, 8'h42);
    
    writeToAddr(16'h0002, 8'h8D);
    writeToAddr(16'h0003, 8'h00);
    writeToAddr(16'h0004, 8'h09);
    
    writeToAddr(16'h0005, 8'h4C);
    writeToAddr(16'h0006, 8'h00);
    writeToAddr(16'h0007, 8'h00);
    
    $display("Initializing test #1, Memory addresse Read are as follows:");
    for(int i = 0; i < 8 ; i++) begin
        readFromAddr(i[15:0]);
    end
endtask
    
task writeToAddr(input logic [15:0] addr, input logic [7:0] data);
    addrb = addr;
    dinb = data;
    enb = 1'b1;
    web = 1'b1;
    @(posedge RAM_Clk);
    web = 1'b0;
    @(posedge RAM_Clk);
endtask

task readFromAddr(input logic [15:0] addr); 
    addrb = addr;
    @(posedge RAM_Clk);
    $display("MEM[%h] = %h", addr, doutb);
endtask

endmodule

//    cpu_en = 1'b0;
//    portA_en = 1'b0;
//    enb = 1'b0;
//    web = 1'b0;
    
//    repeat (10) @(posedge Clk);
    
//    addrb = 16'h0000;
//    dinb = 8'hFF;
//    //@(posedge Clk);
//    enb = 1'b1;
//    web = 1'b1;
//    @(posedge Clk);
//    //web = 1'b0;
//    @(posedge Clk);
//    //web = 1'b1;
    
//    addrb = 16'h0001;
//    dinb = 8'hFE;
//    @(posedge Clk);
////    web = 1'b0;
//    @(posedge Clk);
////    web = 1'b1;
    
    
//    addrb = 16'h0002;
//    dinb = 8'hAB;
//    @(posedge Clk);
//    web = 1'b0;
//    @(posedge Clk);