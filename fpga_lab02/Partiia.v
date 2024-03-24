// Background image display

module background
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,
		SW,							//	Push Button[0:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B	  						//	VGA Blue[9:0]
	);

	input	CLOCK_50;				//	50 MHz
	input	[3:0] KEY;				//	Button[0:0]
	input	[3:0] SW;				//	Button[0:0]
	output	VGA_CLK;   				//	VGA Clock
	output	VGA_HS;					//	VGA H_SYNC
	output	VGA_VS;					//	VGA V_SYNC
	output	VGA_BLANK;				//	VGA BLANK
	output	VGA_SYNC;				//	VGA SYNC
	output	[9:0] VGA_R;   			//	VGA Red[9:0]
	output	[9:0] VGA_G;	 		//	VGA Green[9:0]
	output	[9:0] VGA_B;   			//	VGA Blue[9:0]
	
	wire resetn;
	reg flag1 = 1'b0 ;
	reg flag2 , plot;
	reg [2:0] color;
	reg [7:0] x , x_t;
	reg [6:0] y , y_t;
	wire [3:0] w ;
	reg [3:0] y_Q = 4'b0000;
	reg [3:0] Y_D;
	reg [7:0] counter_Y1,counter_Y2,counter_X1,counter_X2;
	reg [25:0] count = 26'b0;
   reg Q;
	parameter S1 = 4'b0000 , S2 = 4'b0001 , E1 = 4'b0010 , E2 = 4'b0011 , L1 = 4'b0100 , L2 = 4'b0101 , R1 = 4'b0110 , R2 = 4'b0111 , U1 = 4'b1000 , U2 = 4'b1001 , D1 = 4'b1010 , D2 = 4'b1011 , W1 = 4'b1100; 

    assign w = SW[3:0];

	assign resetn = KEY[0];
	always @(posedge CLOCK_50) begin
		count <= count + 1;
		if(count == 10000) begin
			Q <= ~Q;
			count <= 0;
		end
	end
	always @(w,y_Q) begin
		begin:state_table
		case (y_Q)
			S1:begin
				Y_D = S2;
			end 
			//......
			S2:begin
				if(flag1 == 0) Y_D = S2;
				else begin
					case (w)
					//RIGHT
						 4'b0001: Y_D = R1;
					//UP
						 4'b0010: Y_D = U1;
					//DOWN
					    4'b0100: Y_D = D1;
					//LEFT
					    4'b1000: Y_D = L1;
						default: Y_D = W1;
					endcase
				end
			end
			//.......
			E1:begin
				Y_D = E2;
			end
			//........
			E2:begin
				if(flag1 == 0) Y_D = E2;
				else Y_D = S1;
			end
			//........
			L1 : begin
				Y_D = L2;
			end
			//........
			L2:begin
				if(flag1 == 0) Y_D = L2;
				else begin
					case (w)
					//RIGHT
						 4'b0001: Y_D = R1;
					//UP
						 4'b0010: Y_D = U1;
					//DOWN
					    4'b0100: Y_D = D1;
					//LEFT
					    4'b1000: Y_D = L1;
						default: Y_D = W1;
					endcase
				end
			end
			//......
			R1 : begin
				Y_D = R2;
			end
			//........
			R2:begin
				if(flag1 == 0) Y_D = R2;
				else begin
					case (w)
					//RIGHT
						 4'b0001: Y_D = R1;
					//UP
						 4'b0010: Y_D = U1;
					//DOWN
					    4'b0100: Y_D = D1;
					//LEFT
					    4'b1000: Y_D = L1;
						default: Y_D = W1;
					endcase
				end
			end
			//......
			U1 : begin
				Y_D = U2;
			end
			//........
			U2:begin
				if(flag1 == 0) Y_D = U2;
				else begin
					case (w)
					//RIGHT
						 4'b0001: Y_D = R1;
					//UP
						 4'b0010: Y_D = U1;
					//DOWN
					    4'b0100: Y_D = D1;
					//LEFT
					    4'b1000: Y_D = L1;
						default: Y_D = W1;
					endcase
				end
			end
			D1 : begin
				Y_D = D2;
			end
			//........
			D2:begin
				if(flag1 == 0) Y_D = D2;
				else begin
					case (w)
					//RIGHT
						 4'b0001: Y_D = R1;
					//UP
						 4'b0010: Y_D = U1;
					//DOWN
					    4'b0100: Y_D = D1;
					//LEFT
					    4'b1000: Y_D = L1;
						default: Y_D = W1;
					endcase
				end
			end
			W1:begin
				case (w)
					//RIGHT
						 4'b0001: Y_D = R1;
					//UP
						 4'b0010: Y_D = U1;
					//DOWN
					    4'b0100: Y_D = D1;
					//LEFT
					    4'b1000: Y_D = L1;
						default: Y_D = W1;
					endcase
			end
		endcase
			
		end
		
	end

	always @(posedge Q) begin
		case (y_Q)
		//Left
			L1:begin
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b0;
				//flag2 <= 1'b0;
				if (x >= 1) begin
					x <= x - 1;
				end
				else x <= 8'b00000000;
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
			end
			L2: begin
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
				if (counter_X1 < 2) begin
					if (counter_Y1 < 10) begin
						y_t <= y + counter_Y1;
						x_t <= x + (counter_X1 * 30);
						plot <= 1'b1;
						counter_Y1 <= counter_Y1 + 1;
						if(counter_X1 == 0) color <= 3'b101;
						else color <= 3'b000;
					end
					else begin
						counter_Y1 <= 8'b00000000;
						counter_X1 <= counter_X1 + 1;
					end
				end
				else flag1 <= 1'b1;
			end
			R1: begin
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b0;
				//flag2 <= 1'b0;
				if (x < 131) begin
					x <= x + 1;
				end
				else x <= x;
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
			end
			R2:begin
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
				if (counter_X1 < 2) begin
					if (counter_Y1 < 10) begin
						y_t <= y + counter_Y1;
						plot <= 1'b1;
						//x_t <= x + (counter_X1 * 30);
						counter_Y1 <= counter_Y1 + 1;
						if(counter_X1 == 0) begin
							x_t <= x + 29;
							color <= 3'b101;
						end
						else begin
							x_t <= x - 1;
							color <= 3'b000;
						end
					end
					else begin
						counter_Y1 <= 8'b00000000;
						counter_X1 <= counter_X1 + 1;
					end
				end
				else flag1 <= 1'b1;
			end
			U1:begin
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b1;
				//flag2 <= 1'b0;
				if (y > 0) begin
					y <= y - 1;
				end
				else y <= y;
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
			end
			U2:begin
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
				if (counter_Y1 < 2) begin
					if (counter_X1 < 30) begin
						x_t <= x + counter_X1;
						plot <= 1'b1;
						//x_t <= x + (counter_X1 * 30);
						counter_X1 <= counter_X1 + 1;
						if(counter_Y1 == 0) begin
							y_t <= y;
							color <= 3'b101;
						end
						else begin
							y_t <= y + 10;
							color <= 3'b000;
						end
					end
					else begin
						counter_X1 <= 8'b00000000;
						counter_Y1 <= counter_Y1 + 1;
					end
				end
				else flag1 <= 1'b1;
			end
			D1:begin
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b1;
				//flag2 <= 1'b0;
				if (y <111) begin
					y <= y + 1;
				end
				else y <= y;
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
			end
		    D2:begin
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
				if (counter_Y1 < 2) begin
					if (counter_X1 < 30) begin
						x_t <= x + counter_X1;
						plot <= 1'b1;
						//x_t <= x + (counter_X1 * 30);
						counter_X1 <= counter_X1 + 1;
						if(counter_Y1 == 0) begin
							y_t <= y + 9;
							color <= 3'b101;
						end
						else begin
							y_t <= y -1;
							color <= 3'b000;
						end
					end
					else begin
						counter_X1 <= 8'b00000000;
						counter_Y1 <= counter_Y1 + 1;
					end
				end
				else flag1 <= 1'b1;
			end
			E1:begin
				y_Q <= Y_D;
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b0;
			end
			//earase the current rectangle
			E2:begin
				 y_Q <= Y_D;
				if (counter_Y1 < 10) begin
					if (counter_X1 < 30) begin
						x_t <= x + counter_X1;
						y_t <= y + counter_Y1;
						plot <= 1'b1;
						//x_t <= x + (counter_X1 * 30);
						counter_X1 <= counter_X1 + 1;
						color <= 3'b000;
					end
					else begin
						counter_X1 <= 8'b00000000;
						counter_Y1 <= counter_Y1 + 1;
					end
				end
				else flag1 <= 1'b1;
				
			end
			S1:begin
				y_Q <= Y_D;
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b0;
				x <= 8'b01000000;
				y <= 7'b0110110;
			end
			S2:begin
				y_Q <= Y_D;
				if (counter_Y1 < 10) begin
					if (counter_X1 < 30) begin
						x_t <= x + counter_X1;
						y_t <= y + counter_Y1;
						plot <= 1'b1;
						//x_t <= x + (counter_X1 * 30);
						counter_X1 <= counter_X1 + 1;
						color <= 3'b101;
					end
					else begin
						counter_X1 <= 8'b00000000;
						counter_Y1 <= counter_Y1 + 1;
					end
				end
				else flag1 <= 1'b1;
				
			end
			W1:begin
				x_t <= x;
				y_t <= y;
				plot <= 1'b0;
				if (resetn == 0) y_Q <= E1;
				else y_Q <= Y_D;
			end

		endcase
	end

	//assign plot = KEY[1];
	//assign x = SW[7:0];
	//assign y = SW[14:8];
	//assign color = SW[17:15];

	// Further assignments go here...

	

	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x_t),
			.y(y_t),
			.plot(plot),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "";
		
endmodule
