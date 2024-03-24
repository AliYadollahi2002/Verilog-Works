
`timescale 1ns/1ns

//==============================================================================

module async_mem(
   input clk,
   input read,
   input write,
   input [31:0] address,
   input [31:0] write_data,
   output [31:0] read_data
);

   reg [31:0] mem_data [0:1023];

   assign #7 read_data = read ? mem_data[ address[11:2] ] : 32'bxxxxxxxx;

   always @( posedge clk )
      if ( write )
         mem_data[ address[11:2] ] <= write_data;

endmodule



//==============================================================================
//`define DEBUG	// comment this line to disable register content writing below
//==============================================================================

module reg_file(
	input  clk,
	input  write,
	input  [ 4:0] WR,
	input  [31:0] WD,
	input  [ 4:0] RR1,
	input  [ 4:0] RR2,
	output [31:0] RD1,
	output [31:0] RD2
	);

	reg [31:0] reg_data [0:31];

	assign #2 RD1 = reg_data[RR1];
	assign #2 RD2 = reg_data[RR2];

	always @(posedge clk) begin
		if(write) begin
			reg_data[WR] <= WD;

			`ifdef DEBUG
			if(WR)
				$display("$%0d = %x", WR, WD);
			`endif
		end
		reg_data[0] <= 32'h00000000;
	end

endmodule

module multiplier(
//-----------------------Port directions and deceleration
   input clk,  
   input start,
   input [31:0] A, 
   input [31:0] B, 
   output reg [63:0] Product,
   output ready
    );



//------------------------------------------------------

//----------------------------------- register deceleration
reg [31:0] Multiplicand ;
reg [31:0]  Multiplier;
reg [31:0] Multiplexer_output;
reg [5:0]  counter;
reg [31:0] first_Product ;
reg [31:0] second_product;
reg [63:0] temp;
//-------------------------------------------------------

//------------------------------------- wire deceleration
wire multiplexer_enable;
wire [31:0] adder_output;
wire c_out; 
//---------------------------------------------------------

//-------------------------------------- combinational logic
assign{c_out,adder_output} = Multiplexer_output + first_Product;
assign multiplexer_enable = Multiplier[0]; 
assign ready = counter[5];
//---------------------------------------------------------

//--------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      counter <= 6'h0 ;
      Multiplier <= B;
      first_Product <= 32'h00;
      second_product <= 32'h00;
      Multiplicand <= A ;
      //Product <= {first_Product, second_product};
     
      if(multiplexer_enable) 
         Multiplexer_output <= Multiplicand;
      else
        Multiplexer_output <= 32'h00;
      
   end

   else if(! ready) begin

         first_Product <= {c_out,adder_output[31:1]};
         //bug!!!!!!
         second_product[ counter] <=  adder_output[0];
         counter <= counter + 1;
        
        
         Multiplier <= Multiplier >> 1;

         


         if(multiplexer_enable) 
         Multiplexer_output <= Multiplicand;
         else
         Multiplexer_output <= 32'h00;
         

        



      
   end 
   else
   
   Product <= ((c_out<<63) + ({adder_output,second_product}>>1));


   

endmodule


