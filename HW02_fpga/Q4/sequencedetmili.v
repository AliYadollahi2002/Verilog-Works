module sequencedetmili (Clock , w , Resetn , z);
    input Clock , w , Resetn ;
    output reg z;
    parameter A = 3'b000 , B = 3'b001 , C = 3'b010 , D = 3'b011 , E = 3'b100 , F = 3'b101 , G = 3'b110 , H = 3'b111;
    reg[3:0] Cs = A ;
    reg[3:0] Ns ;


    always @(Cs , w) begin
        case (Cs)
            A:if (w==0) begin
                Ns = A; z = 0;
            end
            else begin
                Ns = B; z = 0;
            end
            B:if (w==0) begin
                Ns = C; z = 0;
            end
            else begin
                Ns = B; z = 0;
            end
            C:if (w==0) begin
                Ns = A; z = 0;
            end
            else begin
                Ns = D; z = 0;
            end
            D:if (w==0) begin
                Ns = C; z = 0;
            end
            else begin
                Ns = E; z = 0;
            end
            E:if (w==0) begin
                Ns = F; z = 0;
            end
            else begin
                Ns = B; z = 0;
            end
            F:if (w==0) begin
                Ns = A; z = 0;
            end
            else begin
                Ns = G; z = 0;
            end
            G:if (w==0) begin
                Ns = C; z = 0;
            end
            else begin
                Ns = H; z = 0;
            end
            H:if (w==0) begin
                Ns = F; z = 1;
            end
            else begin
                Ns = B; z = 0;
            end
        endcase
        
    end 
    always @(posedge Clock , negedge Resetn) begin
        if(Resetn == 0) Cs <= A;
        else Cs <= Ns;
    end


endmodule