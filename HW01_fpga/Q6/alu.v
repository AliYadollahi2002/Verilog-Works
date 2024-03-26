module alu(
    input [3:0] A, B,
    input [1:0] sel,
    input Clk,
    output reg [7:0] ALU_out
    );

    wire [3:0] Q;
    wire [3:0] q;
    wire [3:0] R;

    Divide d(.A(A), .B(B), .Clk(Clk), .Q(Q));
    Fraction f(.A((A - (Q*B))),.B(B),.Clk(Clk),.Q(q));


    always @(posedge Clk) begin
        case (sel)
           2'b00 : ALU_out = A+B;
           2'b01 : ALU_out = A-B;
           2'b10 : ALU_out = A*B;
           2'b11 : ALU_out = {Q,q};
            default: ALU_out = 8'b00000000;
        endcase
    end

endmodule

module Divide (
    input [3:0] A, B,
    input Clk,
    output reg [3:0] Q
    );
    reg [3:0] r;

    always @(posedge Clk ) begin
       r <= A; 
       Q = 4'b0000;
        while (r >= B) begin
            Q = Q + 1;
            r = r - B;
        end
        
    end

endmodule
module Fraction(
input [3:0] A,B,
input Clk,
output reg [3:0] Q

);
reg [7:0] r;
integer i;
integer s;

always @(posedge Clk) begin
    r <= {4'b0000,A};
    for (i = 0 ;i<4 ;i = i+1 ) begin
        if ((2 * r) < B ) begin
            Q[3-i] = 0;
            if(s==1) begin
                r = A;
                s = 0;
            end
            else  begin
                r = 2*r;
                s = 0;
            end
            
        end
        else begin
            Q[3-i] = 1;
            r = (2 * r) - B ;
            s = 1;
        end
    end

end
endmodule
           