`timescale 1ns/1ns
module receiver_Tester ();
reg clk = 1'b1;
   always @(clk)
      clk <= #10 ~clk;
    reg[10:0]  output_seq [0:99];
    reg[10:0]  input_seq [0:99];
    reg[10:0] inputseq , outputseq;
    reg[6:0] error = 0;
    integer i ;

    initial begin
        $readmemb("eleven.txt",input_seq);
        $readmemb("final.txt",output_seq);

        for (i = 0;i<100 ;i = i+1 ) begin
            if (input_seq[i] != output_seq[i]) begin
                error = error + 1;
            end
        end
        $display("%d errors detected",error);
        $stop();

    end
//initial begin
  //$fclose(f);  
//end


endmodule
