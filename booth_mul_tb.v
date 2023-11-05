`timescale 1ns/1ps
`include"booth_mul.v"
module Booth_test ;
parameter N=16;
reg [N-1:0] data_in; 
reg clk,start;
wire done;
Booth B (lda,ldm,ldq,clra,clrq,clrff,sfta,sftq,addsub,decr,ldent,data_in,clk,qm1,eqz,q0);
Controller C (lda,clra,sfta,ldq,clrq,sftq,ldm,clrff,addsub,start,decr,ldent,done,clk,q0,qm1,eqz);
initial
begin
    clk=1'b0;
    #3 start=1'b1;
    #600 $finish;
end
always #5 clk=~clk;  
initial
begin
    #17 data_in=5;
    #10 data_in=2;
end
initial
begin
    
    $dumpfile("booth.vcd");$dumpvars(0,Booth_test);
end
    
endmodule