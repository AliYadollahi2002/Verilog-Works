// Animation

module animation
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
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
    wire [7:0] x;
    wire [6:0] y;

	reg [2:0] color;
	reg [7:0] x_t;
	reg [6:0] y_t;
	reg writeEn;
    reg [7:0] screen_X ,counter_X;
    reg [6:0] screen_Y,counter_Y;
    reg [11:0] counter_D;
    reg flag1 , flag2;
    reg [3:0] CS , NS;
    reg [1:0] motion;// 2'b00 : DR , 2'b01 : DL , 2'b10 : UR , 2'b11 : UL
    assign mem_address = counter_X + (5'b10000)*counter_Y;
    assign x = x_t + counter_X;
    assign y = y_t + counter_Y;
    parameter Draw1 = 4'b0000 ,Draw2 = 4'b0001, Erase = 4'b0010 ,Erase2 = 'b0011 , DR = 4'b0100 , DL = 4'b0101 , UR = 4'b0110 , UL = 4'b0111 , Delay1 = 4'b1000 , Delay2 = 4'b1001;
    initial begin
        screen_X = 7'b0101000;
        screen_Y = 6'b011110;
        x_t = 7'b0101000;
        y_t = 6'b011110;
        CS = 4'b0000;
    end
    always @(CS) begin
        case (CS)
            Draw1:  NS = Draw2; 
            Draw2: begin
                if(flag1 == 0) NS = Draw2;
                else NS = Delay1;
            end
            Delay1: NS = Delay2;
            Delay2: begin
                if(flag2 == 0) NS = Delay2;
                else NS = Erase1;
            end
            Erase1: NS = Erase2;
            Erase2: begin
                if(flag1 == 0) NS = Erase2;
                else begin
                    case (motion)
                        2'b00: NS = DR;
                        2'b01: NS = DL;
                        2'b10: NS = UR;
                        2'b11: NS = UL; 
                        //default: 
                    endcase
                end
            end
            DR: NS = Draw1;
            DL: NS = Draw1;
            UR: NS = Draw1;
            UL: NS = Draw1;
            default: 
        endcase
    end


    always @(posedge CLOCK_50 , negedge resetn) begin
        if (resetn == 0) begin
            x <= screen_X;
            y <= screen_Y;
            CS <= Draw;
        end
        else begin
            CS <= NS;
            case (CS)
            //DRAW
                Draw1:begin
                    counter_X <= 0;
                    counter_Y <= 0;
                    flag1 <= 0;
                    color <= mem_out;
                end 
                Draw2:begin
                     if(Counter_Y < 16) begin
			if(Counter_X < 16)
				Counter_X <= Counter_X + 1;
			else begin
				Counter_X <= 0;
				Counter_Y <= Counter_Y +1;
			end
		end
        else flag1 <= 1'b1;

                end
                //ERASE
                Erase1:begin
                    counter_X <= 0;
                    counter_Y <= 0;
                    flag1 <= 0;
                    color <= 3'b000;
                end
                Erase2:begin
                     if(Counter_Y < 16) begin
			if(Counter_X < 16)
				Counter_X <= Counter_X + 1;
			else begin
				Counter_X <= 0;
				Counter_Y <= Counter_Y +1;
			end
		end
        else flag1 <= 1'b1;

                end
                DR:begin
                    if (x_t < 145) begin
                        x_t <= x_t + 1;
                    end
                    else begin
                        motion <= 2'b01;
                    end
                    if(y_t < 105) begin
                        y_t = y_t + 1;
                    end
                    else begin
                        motion <= 2'b10;
                    end
                end
                DL:begin
                    if (x_t > 0) begin
                        x_t <= x_t - 1;
                    end
                    else begin
                        motion <= 2'b00;
                    end
                    if(y_t < 105) begin
                        y_t = y_t + 1;
                    end
                    else begin
                        motion <= 2'b11;
                    end
                end
                UR:begin
                    if (x_t < 145) begin
                        x_t <= x_t + 1;
                    end
                    else begin
                        motion <= 2'b11;
                    end
                    if(y_t > 0) begin
                        y_t = y_t - 1;
                    end
                    else begin
                        motion <= 2'b00;
                    end
                end
                UL:begin
                    if (x_t > 0) begin
                        x_t <= x_t - 1;
                    end
                    else begin
                        motion <= 2'b10;
                    end
                    if(y_t > 0) begin
                        y_t = y_t - 1;
                    end
                    else begin
                        motion <= 2'b01;
                    end
                end
                Delay1:begin
                    counter_D <= 12'b0;
                    flag2 <= 0;
                end
                Delay2:begin
                    if(counter_D < 12'b0011_1110_1000)begin
                        counter_D <= counter_D + 1
                    end
                    else begin
                        counter_D <= 12'b0;
                        flag2 <= 1'b1;
                    end

                end


                //default: 
            endcase

        end
    end

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
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