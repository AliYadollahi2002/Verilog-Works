`timescale 1ns/1ns
module Frequency_T ();
reg clk = 1'b1;
   always @(clk)
      clk <= #10 ~clk;
    reg signed[15:0] input_seq_sin [0:1023];
    reg signed[15:0] input_seq_cos [0:1023];
    reg signed[15:0] sin_in;
    reg signed[15:0] cos_in;
    reg [10:0]index;
    wire signed[15:0] sin_out;
    wire signed[15:0] cos_out;
    wire valid ;
    reg[1:0] op;
    //reg[14:0] input_seq [0:99];
    integer i,f1 , f2;
   initial begin
  f1 = $fopen("sin_out.txt","w");
  f2 = $fopen("cos_out.txt","w");

    end
    initial begin
        $readmemb("sin.txt" , input_seq_sin);
        $readmemb("cos.txt" , input_seq_cos);
        //op = 2'b00
        //op = 2'b01
        //op = 2'b10
        op = 2'b11;
        for (i =0 ;i < 1024 ;i = i+1 ) begin
            sin_in <= input_seq_sin[i];
            cos_in <= input_seq_cos[i];
            index <= i;
            #1
            @(posedge clk);
            @(posedge clk);
            $display(index);
            //$display(index%4);
            if (valid) begin
                $fwrite(f1,"%b\n",sin_out);
                $fwrite(f2,"%b\n",cos_out);
            end
        end
        $fclose(f1);
        $fclose(f2);
        
        $stop();
        
    end
    

        Frequency frq(
            .sinx(sin_in),
            .cosx(cos_in),
            .Clock(clk),
            .op(op),
            .i(index),
            .valid(valid),
            .sinx_out(sin_out),
            .cosx_out(cos_out)
);

endmodule