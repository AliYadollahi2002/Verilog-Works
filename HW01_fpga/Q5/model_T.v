`timescale 1ms/1ms
module model_T();
reg clk = 1'b1;
   always @(clk)
      clk <= #10 ~clk;
reg [7:0] sec,min;
reg reset , start;
integer j;

initial begin
    start = 0;
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
     #1;
     sec = 8'b00000101; 
     min = 8'b00000010;
     start = 1;
     reset = 1;
     @(posedge clk);
     #1;
     start = 0;
     reset = 1;
     min = 'bx;
     sec = 'bx;
     for(j=0; j<=8; j=j+1)        
            @(posedge clk);
         @(posedge clk);
    $display(ut.seconds);
    $display(ut.minuts);
    
    if(ut.done)begin
        $display(ut.done);
        $stop;
    end

end


model ut (        
        .clk(clk),
        .sec(sec),
        .minute(min),
        .reset(reset),
        .start(start),
        .seconds(),
        .minuts(),
        .done()
    );
      endmodule
