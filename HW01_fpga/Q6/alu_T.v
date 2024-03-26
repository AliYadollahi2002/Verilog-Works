module alu_T;

reg [3:0] A, B;
reg [1:0] sel;
reg Clk = 1'b1;
wire [7:0] ALU_out;

always @(Clk) 
    Clk <= #10 ~Clk; 

alu uut (
  .A(A),
  .B(B),
  .Clk(Clk),
  .sel(sel),
  .ALU_out(ALU_out)
);

initial begin
  sel = 2'b00;
  A = 4'b0101;
  B = 4'b0100;
  #100 $display("%b + %b = %b", A, B, ALU_out);
  sel = 2'b01;
  A = 4'b0101;
  B = 4'b0100;
  #100 $display("%b - %b = %b", A, B, ALU_out);
  sel = 2'b10;
  A = 4'b0101;
  B = 4'b0100;
  #100 $display("%b * %b = %b", A, B, ALU_out);
  sel = 2'b11;
  A = 4'b0101;
  B = 4'b0100;
  #100 $display("%b / %b = %b.%b", A, B, ALU_out[7:4],ALU_out[3:0]);
  $stop;
end

endmodule