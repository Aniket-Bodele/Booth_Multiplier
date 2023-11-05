
`timescale 1ns/1ps
module Booth (lda,ldm,ldq,clra,clrq,clrff,sfta,sftq,addsub,decr,ldent,data_in,clk,qm1,eqz,q0);
input lda,ldm,ldq,clra,clrq,clrff,sfta,sftq,addsub,decr,clk,ldent;
parameter N=16;
parameter bit_c=4;
input [N-1:0] data_in;
output eqz,qm1,q0;
wire [N-1:0] A,M,Q,Z;
wire [bit_c:0] count;
assign eqz= ~|count;
assign q0=Q[0];
shiftreg AR (A,Z,A[N-1],clk,lda,clra,sfta);
shiftreg QR (Q,data_in,A[0],clk,ldq,clrq,sftq);
Qff Qf (Q[0],qm1,clk,clrff,sftq);
PIPO Mul (M,data_in,ldm,clk);
ALU ADDSUB (Z,A,M,addsub);
Counter c (count,decr,ldent,clk);
endmodule
module shiftreg (out,in,s_in,clk,ld,clr,sft);
input s_in,clk,ld,clr,sft;
parameter N=16;
input [N-1:0] in;
output reg [N-1:0] out;
always @(posedge clk)
begin
    if(clr) out<=0;
    else if(ld) out<=in;
    else if(sft) out<={s_in,out[N-1:1]};
end
    
endmodule
module Qff (q_in,qm1,clk,clr,sft);
input q_in,clk,clr,sft;
output reg qm1;
always @(posedge clk)
begin
if(clr) qm1<=0;
else if(sft) qm1<=q_in;
end
endmodule
module PIPO (out,in,ld,clk);
parameter N=16;
input ld,clk;
input [N-1:0] in;
output reg [N-1:0] out;
always @(posedge clk)
if(ld) out<=in;

    
endmodule
module ALU (out,in1,in2,addsub);
input addsub;
parameter N=16;
input [N-1:0] in1,in2;
output reg [N-1:0]out;
always @(*)
begin
if(addsub==0)
    out=in1-in2;
else out=in1+in2;
end  
endmodule
module Counter (data_out,decr,ldent,clk);
    parameter bit_c=4;
    parameter N=16;
    input decr,clk,ldent;
    output reg [bit_c:0] data_out;
    always @(posedge clk)
    begin
        if(ldent) data_out<=5'b10000;
        else if(decr) data_out<=data_out-1;
    end
endmodule
module Controller (lda,clra,sfta,ldq,clrq,sftq,ldm,clrff,addsub,start,decr,ldent,done,clk,q0,qm1,eqz);
input clk, q0, qm1, start,eqz;
output reg lda,clra,sfta,ldq,clrq,sftq,ldm,clrff,addsub,decr,ldent,done;
reg [2:0] state;
parameter s0=3'b000, s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5= 3'b101,s6=3'b110;
always @(posedge clk)
begin
    case (state)
        s0: if(start) state<=s1;
        s1:state<=s2;
        s2:#2 if({q0,qm1}==2'b01) state<=s3;
              else if({q0,qm1}==2'b10) state<=s4;
              else state<=s5;
        s3:state<=s5;
        s4:state<=s5;
        s5:#2 if(({q0,qm1}==2'b01)&& !eqz) state<=s3;
              else if(({q0,qm1}==2'b10)&& !eqz) state<=s4;
              else if(eqz) state<=s6;
        s6:state<=s6;

        default: state<=s0;
    endcase
end
always @(state)
begin
    case (state)
        s0: begin
            clra=0;lda=0;sfta=0;clrq=0;ldq=0;sftq=0;ldm=0;clrff=1;done=0;
        end
        s1:begin
            clra=1;clrff=1;ldent=1;ldm=1;
        end
        s2:begin
            clra=0;clrff=0;ldent=0;ldm=0;ldq=1;
        end
        s3:begin
            lda=1;addsub=1;ldq=0;sfta=0;sftq=0;decr=0;
        end
        s4:begin
            lda=1;addsub=0;ldq=0;sfta=0;sftq=0;decr=0;
        end
        s5:begin
            sfta=1;sftq=1;lda=0;ldq=0;decr=1;
        end
        s6:done=1;
        default:begin
            clra=0;sfta=0;ldq=0;sftq=0;
        end  
    endcase

end
    
endmodule