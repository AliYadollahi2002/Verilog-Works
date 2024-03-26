`timescale 1ns/1ns
module sequencedetmili_T ();
reg clk = 1'b1;
   always @(clk)
      clk <= #10 ~clk;
reg Resetn ;
reg [0:12] w = {1'b0 ,1'b1,1'b0,1'b1,1'b1,1'b0,1'b1,1'b1,1'b0,1'b1,1'b1,1'b0 , 1'b0};
reg [0:18] w2 = {1'b0 ,1'b1,1'b0,1'b1,1'b1,1'b0,1'b1,1'b1,1'b0,1'b1,1'b1,1'b0 , 1'b1 ,1'b1 , 1'b0 , 1'b1 , 1'b0 , 1'b0};
reg inp;
wire z;
integer i;
initial begin
    Resetn = 1'b1;
    for ( i=0 ;i < 17 ;i = i+1 ) begin
        #1
        inp = w2[i];
        //#5
        @(posedge clk);
        //#5
        $display(z);
    end
    $stop();
end

    sequencedetmili uut(
        .Clock(clk),
        .w(inp),
        .Resetn(Resetn),
        .z(z)
);
endmodule
