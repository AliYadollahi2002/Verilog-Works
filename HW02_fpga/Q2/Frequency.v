module Frequency (Clock , sinx , cosx , op , i , sinx_out , cosx_out , valid);
input Clock;
input signed [15:0] sinx ;
input signed [15:0] cosx ;
input [1:0] op;
input [10:0]i;
output reg signed [15:0] sinx_out ;
output reg signed [15:0] cosx_out ;
output reg valid;
always @(posedge Clock) begin
    case (op)
        2'b00:begin
            cosx_out <= cosx;
            sinx_out <= sinx;
            valid <= 1'b1;
        end 
        2'b01:begin
            if(i%2 == 0)begin
                valid <= 1'b1;
                sinx_out <= sinx;
                cosx_out <= cosx;
            end
            else begin
                valid <= 1'b0;
            end
        end
        2'b10:begin
             if(i%4 == 0)begin
                valid <= 1'b1;
                sinx_out <= sinx;
                cosx_out <= cosx;
            end
            else begin
                valid <= 1'b0;
            end
        end
        2'b11:begin
             if(i%8 == 0)begin
                valid <= 1'b1;
                sinx_out <= sinx;
                cosx_out <= cosx;
            end
            else begin
                valid <= 1'b0;
            end
        end
        
    endcase
end
    
endmodule