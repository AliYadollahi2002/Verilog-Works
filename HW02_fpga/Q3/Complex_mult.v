module Complex_mult (clock , a , b , c , d , Imag , Real);
input clock;
input signed [17:0] a , b , c , d;
output reg signed[37 : 0] Imag , Real;
reg signed[18:0] reg1 , reg2;
reg signed[37:0] reg3 , reg4 , reg5 , reg6 , reg7;

always @(posedge clock) begin
    reg1 <= a + b;
    reg2 <= c + d;
    reg3 <= b * d;
    reg4 <= a * c;
    reg5 <= reg1 * reg2;
    reg6 <= reg3 + reg4;
    reg7 <= reg4 - reg3;
    Real <= reg7;
    Imag <= reg5 - reg6;
end
    
endmodule