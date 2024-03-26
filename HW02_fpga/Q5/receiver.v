module receiver (Clock , inputseq , outputseq ,error , valid);
input Clock ;
input [1:15] inputseq;
output reg [10:0] outputseq;
output reg [7:0] error = 8'b00000000;
output reg valid;
wire p1 , p2 , p3 , p4;
assign p1 = inputseq[1] ^ inputseq[3] ^ inputseq[5] ^ inputseq[7] ^ inputseq[9] ^ inputseq[11] ^ inputseq[13] ^ inputseq[15];
assign p2 = inputseq[2] ^ inputseq[3] ^ inputseq[6] ^ inputseq[7] ^ inputseq[10] ^ inputseq[11] ^ inputseq[14] ^ inputseq[15];
assign p3 = inputseq[4] ^ inputseq[5] ^ inputseq[6] ^ inputseq[7] ^ inputseq[12] ^ inputseq[13] ^ inputseq[14] ^ inputseq[15];
assign p4 = inputseq[8] ^ inputseq[9] ^ inputseq[10] ^ inputseq[11] ^ inputseq[12] ^ inputseq[13] ^ inputseq[14] ^ inputseq[15];
//wire[3:0] parity;
//wire[3:0] ones_count;
//assign parity = inputseq[3:0];
//assign ones_count = inputseq[14] + inputseq[13] + inputseq[12] + inputseq[11] + inputseq[10] + inputseq[9] + inputseq[8] + inputseq[7] + inputseq[6] + inputseq[5] + inputseq[4];
always @(posedge Clock) begin
    if ({p1 , p2 , p3 , p4}== 4'b0000) begin
        valid <= 1'b1;
        outputseq <= {inputseq[3] , inputseq[5:7] , inputseq[9:15]};
    end
    else begin
        valid <= 1'b0;
        outputseq <= 11'b0;
        error <= error + 1;
    end
end


endmodule