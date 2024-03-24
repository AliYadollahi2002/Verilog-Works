// Animation

module animation
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
        SW,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[0:0]	KEY;					//	Button[3:0]
    input   [1:0]   SW;
 	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the color, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] color;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
    wire blank ;
    //reg [4:0] counter_X , counter_Y;
    reg [7:0] screen_X ,counter_X;
    reg [6:0] screen_Y,counter_Y;
    assign blank = SW[0];
    assign writeEn = 1'b1;
    assign color = (blank == 1) ? mem_out : 3'b000;
    assign x = screen_X + counter_X;
    assign y = screen_Y + counter_Y;
    assign mem_address = counter_X + (6'b010000)*counter_Y;
    initial begin
        counter_X = 0;
        counter_Y = 0;
        screen_X = 7'b0101000;
        screen_Y = 6'b011110;
    end 
    always @(posedge CLOCK_50 , negedge resetn) begin
        if (resetn == 0) begin
            counter_X <= 0;
            counter_Y <= 0;
        end
        else begin
            if(Counter_Y < 16) begin
			if(Counter_X < 16)
				Counter_X <= Counter_X + 1;
			else begin
				Counter_X <= 0;
				Counter_Y <= Counter_Y +1;
			end
		end
        end
    end
    parameter IMAGE_FILE = "image.mif";
	assign black_color = 3'b000;
	assign gnd = 1'b0;
	lpm_ram_dq my_ram(.inclock(CLOCK_50), .outclock(CLOCK_50), .data(black_color),
		.address(mem_address), .we(gnd), .q(mem_out) );
	defparam my_ram.LPM_FILE = IMAGE_FILE;
	defparam my_ram.LPM_WIDTH = 3;
	defparam my_ram.LPM_WIDTHAD = 12;
	defparam my_ram.LPM_INDATA = "REGISTERED";
	defparam my_ram.LPM_ADDRESS_CONTROL = "REGISTERED";
	defparam my_ram.LPM_OUTDATA = "REGISTERED";


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
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
			
	// Put your code here. Your code should produce signals x,y,color and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	
endmodule