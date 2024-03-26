`timescale 1ns/1ns
module shift_register_T();
reg clk = 1'b1;
   always @(clk)
      clk <= #10 ~clk;
reg [3:0] I_par;
reg s1,s0,MSB_in,LSB_in,clear;
initial begin
    clear = 0;
    s1 = 1;
    s0 = 1;
    I_par = 4'b1010;
    MSB_in = 'bx;
    LSB_in = 'bx;
    @(posedge clk);
    @(posedge clk);
    #1
    $display("Value in binary: %b",ut.A_par);

    clear = 0;
    s1 = 0;
    s0 = 0;
    I_par = 4'b1010;
    MSB_in = 1'b0;
    LSB_in = 1'b0;
    @(posedge clk);
    @(posedge clk);
    $display("Value in binary: %b",ut.A_par);
      $stop;



end




shift_register ut (        
        .I_par(I_par),
        .s1(s1),
        .s0(s0),
        .MSB_in(MSB_in),
        .LSB_in(LSB_in),
        .clk(clk),
        .clear(clear),
        .A_par()
    );



endmodule