`timescale 1ns/1ns
module sequencedet (Clock , w , Resetn , z);
    input Clock , w , Resetn ;
    output  z;

    parameter A = 4'b0000 , B = 4'b0001 , C = 4'b0010 , D = 4'b0011 , E = 4'b0100 , F = 4'b0101 , G = 4'b0110 , H = 4'b0111 , I = 4'b1000;
    reg[3:0] Cs = A ;
    reg[3:0] Ns ;

    always @(Cs , w) begin
        case (Cs)
            A: if(w==0) Ns = A;
            else Ns = B;
            B: if(w==0) Ns = C;
            else Ns = B;
            C: if(w==0) Ns = A;
            else Ns = D;
            D: if(w==0) Ns = C;
            else Ns = E;
            E: if(w==0) Ns = F;
            else Ns = B;
            F: if(w==0) Ns = A;
            else Ns = G;
            G: if(w==0) Ns = C;
            else Ns = H;
            H: if(w==0) Ns = I;
            else Ns = B;
            I: if(w==0) Ns = A;
            else Ns = G;
        endcase
        
    end 
    always @(posedge Clock , negedge Resetn) begin
        if(Resetn == 0) Cs <= A;
        else Cs <= Ns;
    end
    assign z = (Cs==I);
endmodule