`timescale 1ns/1ns
module shift_register(                  
        input [3:0] I_par,
        input s1,
        input s0,
        input MSB_in,
        input LSB_in,
        input clk,
        input clear,
        output reg [3:0] A_par
);
always @(posedge clk)
if(clear == 1)begin
     A_par <= 4'b0000;
end
else
case({s1,s0})
2'b00: A_par <= A_par; //No change
2'b01: A_par <= {MSB_in , A_par[3:1]}; //Shift right
2'b10: A_par <= {A_par[2:0],LSB_in}; //Shift left
2'b11: A_par <= I_par; //Parallel Load of input
endcase

endmodule