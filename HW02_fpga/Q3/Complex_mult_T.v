`timescale 1ns/1ns
module Complex_mult_T ();
reg clk = 1'b1;
   always @(clk)
      clk <= #10 ~clk;
reg signed [17:0] a , b, c , d;
wire signed [37:0] Real , Imag;
initial begin
    a = 18'b000000000000000001;
    b = 18'b000000000000000001;
    c = 18'b000000000000000001;
    d = 18'b000000000000000001;
    #100
    $display("(%d+j%d)(%d+j%d)=",a,b,c,d);
    $display("%d+j%d",Real,Imag);
    a = 18'b000000000000000010;
    b = 18'b000000000000000011;
    c = 18'b000000000000000100;
    d = 18'b000000000000000001;
    #100
    $display("(%d+j%d)(%d+j%d)=",a,b,c,d);
    $display("%d+j%d",Real,Imag);
    a = 18'b000000000000010000;
    b = 18'b000000000000011111;
    c = 18'b000000000000000001;
    d = 18'b000000000000100000;
    #100
   $display("(%d+j%d)(%d+j%d)=",a,b,c,d);
    $display("%d+j%d",Real,Imag);
     
   a = 18'b000000000000000001;
    b = 18'b111111111111111110;
    c = 18'b000000000000000001;
    d = 18'b111111111111111111;
    #100
    $display("(%d+j%d)(%d+j%d)=",a,b,c,d);
    $display("%d+j%d",Real,Imag);
    /*#10
    $display(Real);
    $display(Imag);
    #10
    $display(Real);
    $display(Imag);
    #10
    $display(Real);
    $display(Imag);
    */
    $stop();
end
    Complex_mult c1(
        .clock(clk),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .Imag(Imag),
        .Real(Real)
    );

endmodule