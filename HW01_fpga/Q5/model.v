`timescale 1ms/1ms
module model
  (
   input clk,
   input [7:0] sec,
   input [7:0] minute,
   input reset,
   input start,
   output reg [7:0] seconds,
   output reg [7:0] minuts,
   output  done
   );

reg [7:0] sec_reg; 
reg [7:0] min_reg; 
reg done_reg;  

  integer counter = 0;
  integer j;


  assign done = done_reg;
  always @(posedge clk)
  
    if(start) begin
      min_reg <= minute;
      sec_reg <= sec;
      done_reg <= 1'b0;
   end
   else if(!reset)begin
       min_reg <= minute;
       sec_reg <= sec;
   end
   else if(!done)begin
       seconds <= sec_reg;
       minuts <= min_reg;
       if(counter == 50)begin
           counter <= 0;
           if(sec_reg == 8'b00000000)begin
               sec_reg <= 8'b00111011;
               if (min_reg == 8'b00000000)begin
                   done_reg <= 1;
               end
               else
               min_reg <= min_reg - 1;
           end
           else
           sec_reg = sec_reg - 1;

       end
       else
       counter <= counter + 1;
   end
   else if(done)begin
     for(j=0; j<=8000; j=j+1) 
     $stop;
   end
   




endmodule