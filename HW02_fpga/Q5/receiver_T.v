`timescale 1ns/1ns
module receiver_T ();
reg clk = 1'b1;
   always @(clk)
      clk <= #10 ~clk;
    reg[14:0] input_seq [0:99];
    reg[14:0] inputseq;
    integer i , f;
    wire[10:0] outputseq;
    wire[7:0] error;
    wire valid;
initial begin
  f = $fopen("final.txt","w");
end

    initial begin
        $readmemb("hammingcode.txt" , input_seq);

        for (i = 0;i<100 ;i = i+1 ) begin
            inputseq = input_seq[i];
            #10
            $display("input[%d] = %b",i , input_seq[i]);
            #10
            $fwrite(f,"%b\n",outputseq);
        end
        $fclose(f);
        $stop();

    end
//initial begin
  //$fclose(f);  
//end
    receiver uut(
        .Clock(clk),
        .inputseq(inputseq),
        .outputseq(outputseq),
        .error(error),
        .valid(valid)

    );

endmodule
