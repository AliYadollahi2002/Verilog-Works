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
	reg [3:0] counter_Y1,counter_Y2,counter_X1,counter_X2;
    reg [25:0] count;
    reg Q;
    parameter Start = 5'b00000 , R1 = 5'b00001 , R2 = 5'b00010 , R3 = 5'b00011 , L1 = 5'b00100 , L2 = 5'b00101 , L3 = 5'b00110 , D1 = 5'b00111 , D2 = 5'b01000 , D3 = 5'b01001 , U1 = 5'b01010 , U2 = 5'b01011 , U3 = 5'b01100 , Draw = 5'b01101 , Erase1 = 5'b01110 , Erase2 = 5'b01111 , W1 = 5'b10000; 
	//parameter S1 = 4'b0000 , S2 = 4'b0001 , E1 = 4'b0010 , E2 = 4'b0011 , L1 = 4'b0100 , L2 = 4'b0101 , R1 = 4'b0110 , R2 = 4'b0111 , U1 = 4'b1000 , U2 = 4'b1001 , D1 = 4'b1010 , D2 = 4'b1011 , W1 = 4'b1100; 
    //parameter Start = 5'b00000 , L1 = 5'b00001 , R1 = 5'b00010 , D1 = 5'b00011 , U1 = 5'b00100 , Draw = 5'b00101 , Erase1 = 5'b00110 , Erase2 = 5'b00111 , W1;
    assign w = SW[3:0];

	assign resetn = KEY[0];
	always @(w,y_Q) begin
        case (y_Q)
            Start: Y_D = Draw;
            L1:begin
                Y_D = L2;
            end
            L2:begin
                if(flag1 == 0) Y_D = L2;
                else Y_D = L3;
            end
            L3: Y_D = Draw;
            R1:begin
                Y_D = R2;
            end
             R2:begin
                if(flag1 == 0) Y_D = R2;
                else Y_D = R3;
            end
            R3: Y_D = Draw;
            U1:begin
                Y_D = U2;
            end
             U2:begin
                if(flag1 == 0) Y_D = U2;
                else Y_D = U3;
            end
            U3: Y_D = Draw;
            D1:begin
                Y_D = D2;
            end
             D2:begin
                if(flag1 == 0) Y_D = D2;
                else Y_D = D3;
            end
            D3: Y_D = Draw;

            Draw:begin
                if(flag1 == 0) Y_D = Draw;
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
            Erase1:begin
                Y_D = Erase2;
            end
            Erase2:begin
                if (flag1 == 0) Y_D = Erase2;
                else begin
                    Y_D = Start;
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

	always @(posedge Q , negedge resetn) begin
        //**********
        if (resetn == 0) y_Q <= Erase1;
		else y_Q <= Y_D;
		case (y_Q)
        L1:begin
                counter_X1 <= 8'b00000000;
                counter_Y1 <= 8'b00000000;
                flag1 <= 1'b0;
                plot <= 1'b1;
            end
            L2:begin
                if (counter_Y1 < 13) begin
                    if (counter_X1 < 13) begin
                        x_t <= x + counter_X1;
                        y_t <= y + counter_Y1;
                        plot <= 1'b1;
                        color <= 3'b000;
                    end
                    else begin
                        counter_X1 <= 8'b00000000;
                        counter_Y1 <= counter_Y1 + 1;
                    end
                end
                else flag1 <= 1'b1;
            end
		L3: begin
            //y_Q <= Y_D;
         counter_X1 <= 8'b00000000;
         counter_Y1 <= 8'b00000000;
         flag1 <= 1'b0;
         plot <= 1'b1;
         if(x > 0) x <= x-1;
         else x <= x;
        end
        Start:begin
            //y_Q <= Y_D;
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b0;
				x <= 8'b01000000;
				y <= 7'b0110110;
            
        end
        R1:begin
                counter_X1 <= 8'b00000000;
                counter_Y1 <= 8'b00000000;
                flag1 <= 1'b0;
                plot <= 1'b1;
            end
            R2:begin
                if (counter_Y1 < 13) begin
                    if (counter_X1 < 13) begin
                        x_t <= x + counter_X1;
                        y_t <= y + counter_Y1;
                        plot <= 1'b1;
                        color <= 3'b000;
                    end
                    else begin
                        counter_X1 <= 8'b00000000;
                        counter_Y1 <= counter_Y1 + 1;
                    end
                end
                else flag1 <= 1'b1;
            end
        R3: begin
            //y_Q <= Y_D;
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b1;
				//flag2 <= 1'b0;
				if (x < 148) begin
					x <= x + 1;
				end
				else x <= x;
			end
            U1:begin
                counter_X1 <= 8'b00000000;
                counter_Y1 <= 8'b00000000;
                flag1 <= 1'b0;
                plot <= 1'b1;
            end
            U2:begin
                if (counter_Y1 < 13) begin
                    if (counter_X1 < 13) begin
                        x_t <= x + counter_X1;
                        y_t <= y + counter_Y1;
                        plot <= 1'b1;
                        color <= 3'b000;
                    end
                    else begin
                        counter_X1 <= 8'b00000000;
                        counter_Y1 <= counter_Y1 + 1;
                    end
                end
                else flag1 <= 1'b1;
            end
        U3:begin
            //y_Q <= Y_D;
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b1;
				plot <= 1'b0;
				//flag2 <= 1'b0;
				if (y > 0) begin
					y <= y - 1;
				end
				else y <= y;
			end 
            D1:begin
                counter_X1 <= 8'b00000000;
                counter_Y1 <= 8'b00000000;
                flag1 <= 1'b0;
                plot <= 1'b1;
            end
            D2:begin
                if (counter_Y1 < 13) begin
                    if (counter_X1 < 13) begin
                        x_t <= x + counter_X1;
                        y_t <= y + counter_Y1;
                        plot <= 1'b1;
                        color <= 3'b000;
                    end
                    else begin
                        counter_X1 <= 8'b00000000;
                        counter_Y1 <= counter_Y1 + 1;
                    end
                end
                else flag1 <= 1'b1;
            end
        D3:begin
				counter_Y1 <= 8'b00000000;
				counter_X1 <= 8'b00000000;
				flag1 <= 1'b0;
				plot <= 1'b0;
				//flag2 <= 1'b0;
				if (y <108) begin
					y <= y + 1;
				end
				else y <= y;
				//if (resetn == 0) y_Q <= E1;
				//else y_Q <= Y_D;
			end   
            //*****************************************
            Draw:begin
                if(counter_Y1<13)begin
                    if (counter_X1<13) begin
                        counter_X1 <= counter_X1 + 1;
                        x_t <= x + counter_X1;
                        y_t <= y + counter_Y1;
                        plot <= 1'b1;
                        if (counter_Y1 == 4'b0000 || counter_Y1 == 4'b1100) begin
                            case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b000;
                        4'b0011: color <= 3'b000;
                        4'b0100: color <= 3'b000;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b000; 
                        4'b1001: color <= 3'b000;
                        4'b1010: color <= 3'b000;
                        4'b1011: color <= 3'b000;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000; 
                    endcase
                            
                        end
                        else if ((counter_Y1 == 4'b0001) || (counter_Y1 == 4'b1011)) begin
                            case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b000;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b000;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000; 
                    endcase
                        end
                        else if (counter_Y1 == 4'b0010 || counter_Y1 == 4'b1010) begin
                         case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000;
                         endcase
                        end
                        else if (counter_Y1 == 4'b0011 || counter_Y1 == 4'b0100 || counter_Y1 == 4'b1000 || counter_Y1 == 4'b1001) begin
                             case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b000;
                    endcase
                        end
                        else begin
                            color <= 3'b101;
                        end
                        
                    end
                    counter_X1 <= 8'b00000000;
                    counter_Y1 <= counter_Y1 +1;
                end
                flag1 <= 1'b1;
            end
            //*****************************************
            //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
            Erase1:begin
                counter_X1 <= 8'b00000000;
                counter_Y1 <= 8'b00000000;
                flag1 <= 1'b0;
                plot <= 1'b1;
            end
            Erase2:begin
                if (counter_Y1 < 13) begin
                    if (counter_X1 < 13) begin
                        x_t <= x + counter_X1;
                        y_t <= y + counter_Y1;
                        plot <= 1'b1;
                        color <= 3'b000;
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
				//if (resetn == 0) y_Q <= E1;
				//else y_Q <= Y_D;
			end
            //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
            /*
			Draw0:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 0;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b000;
                        4'b0011: color <= 3'b000;
                        4'b0100: color <= 3'b000;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b000; 
                        4'b1001: color <= 3'b000;
                        4'b1010: color <= 3'b000;
                        4'b1011: color <= 3'b000;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000; 
                    endcase
                end
                else begin
                    flag1 <= 1'b1;
                    counter_X1 <= 8'b00000000;
                end
            end
            Draw1:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 1;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b000;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b000;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000; 
                    endcase
                end
                else flag1 <= 1'b1;
            end
             Draw2:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 2;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000;
                        
                    endcase
                end
                else flag1 <= 1'b1;
            end
             Draw3:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 3;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b000;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw4:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 4;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b000;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw5:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 5;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b101;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b101;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw6:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 6;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b101;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b101;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw7:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 7;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b101;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b101;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw8:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 8;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b000;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw9:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 9;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b101;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b101;
                        default: color <= 3'b000;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw10:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 10;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b101;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b101;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw11:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 11;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b000;
                        4'b0011: color <= 3'b101;
                        4'b0100: color <= 3'b101;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b101; 
                        4'b1001: color <= 3'b101;
                        4'b1010: color <= 3'b101;
                        4'b1011: color <= 3'b000;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000;
                        default: 
                    endcase
                end
                else flag1 <= 1'b1;
            end
            Draw12:begin
                if (counter_X1 < 13) begin
                    y_t <= y + 12;
                    x_t <= x + counter_X1;
                    case (counter_X1)
                        4'b0000: color <= 3'b000;
                        4'b0001: color <= 3'b000;
                        4'b0010: color <= 3'b000;
                        4'b0011: color <= 3'b000;
                        4'b0100: color <= 3'b000;
                        4'b0101: color <= 3'b101;
                        4'b0110: color <= 3'b101;
                        4'b0111: color <= 3'b101;
                        4'b1000: color <= 3'b000; 
                        4'b1001: color <= 3'b000;
                        4'b1010: color <= 3'b000;
                        4'b1011: color <= 3'b000;
                        4'b1100: color <= 3'b000;
                        default: color <= 3'b000; 
                    endcase
                end
                else begin
                    flag1 <= 1'b1;
                    counter_X1 <= 8'b00000000;
                end
            end
            */



		endcase
	end
    
    always @(posedge CLOCK_50) begin
		count <= count + 1;
		if(count == 26'd6_500_000) begin
			Q <= ~Q;
			count <= 0;
		end
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
