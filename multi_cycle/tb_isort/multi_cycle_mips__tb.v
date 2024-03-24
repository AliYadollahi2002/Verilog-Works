
`timescale 1ns/100ps

   `define ADD  3'b000
   `define SUB  3'b001
   `define SLT  3'b010
   `define SLTU 3'b011
   `define AND  3'b100
   `define XOR  3'b101
   `define OR   3'b110
   `define NOR  3'b111

module multi_cycle_mips(

   input clk,
   input reset,

   // Memory Ports
   output  [31:0] mem_addr,
   input   [31:0] mem_read_data,
   output  [31:0] mem_write_data,
   output         mem_read,
   output         mem_write
);

   // Data Path Registers
   reg MRE, MWE;
   reg [31:0] A, B, PC, IR, MDR, MAR, lr, hr;

   // Data Path Control Lines, donot forget, regs are not always regs !!
   reg setMRE, clrMRE, setMWE, clrMWE;
   reg Awrt, Bwrt, RFwrt, PCwrt, IRwrt, MDRwrt, MARwrt;

   // Memory Ports Binding
   assign mem_addr = MAR;
   assign mem_read = MRE;
   assign mem_write = MWE;
   assign mem_write_data = B;

   // Mux & ALU Control Lines
   reg [2:0] aluOp;
   reg [2:0] aluSelB, MemtoReg;
   reg [1:0] RegDst,pcSrc;
   reg SgnExt, aluSelA, IorD , start, LHWrite;

   // Wiring
   wire aluZero , ready;
   wire [31:0] aluResult, rfRD1, rfRD2 ;
   wire [63:0] multiplier_result;

   // Clocked Registers
   always @( posedge clk ) begin
      if( reset )
         PC <= #0.1 32'h00000000;
      else if( PCwrt )begin
         case(pcSrc)
         2'b00 : PC <= #0.1 aluResult;
         2'b01 : PC <= #0.1 {IR[31:28],IR[25:0],2'b00};
         2'b10 : PC <= #0.1 A;
      endcase
         end

      if( Awrt ) A <= #0.1 rfRD1;
      if( Bwrt ) B <= #0.1 rfRD2;

      if( MARwrt ) MAR <= #0.1 IorD ? aluResult : PC;

      if( IRwrt ) IR <= #0.1 mem_read_data;
      if( MDRwrt ) MDR <= #0.1 mem_read_data;

      if( reset | clrMRE ) MRE <= #0.1 1'b0;
          else if( setMRE) MRE <= #0.1 1'b1;

      if( reset | clrMWE ) MWE <= #0.1 1'b0;
          else if( setMWE) MWE <= #0.1 1'b1;
      if (LHWrite)begin
          hr <= #0.1 multiplier_result[63:32];
          lr <= #0.1 multiplier_result[31:0];
      end

   end

   // Register File
   reg_file rf(
      .clk( clk ),
      .write( RFwrt ),

      .RR1( IR[25:21] ),
      .RR2( IR[20:16] ),
      .RD1( rfRD1 ),
      .RD2( rfRD2 ),

      .WR( RegDst == 2'b01 ? IR[15:11] : RegDst == 2'b00 ?  IR[20:16] : 5'b11111 ),
      .WD( MemtoReg == 2'b01 ? MDR : MemtoReg == 2'b00 ? aluResult : MemtoReg == 2'b10 ? lr :MemtoReg == 2'b11 ? hr : PC)
   );
   

   // Sign/Zero Extension
   wire [31:0] SZout = SgnExt ? {{16{IR[15]}}, IR[15:0]} : {16'h0000, IR[15:0]};

   // ALU-A Mux
   wire [31:0] aluA = aluSelA ? A : PC;

   // ALU-B Mux
   reg [31:0] aluB;
   always @(*)
   case (aluSelB)
      3'b000: aluB = B;
      3'b001: aluB = 32'h4;
      3'b010: aluB = SZout;
      3'b011: aluB = SZout << 2;
      3'b100: aluB = SZout << 16;
   endcase

   my_alu alu(
      .A( aluA ),
      .B( aluB ),
      .Op( aluOp ),

      .X( aluResult ),
      .Z( aluZero )
   );
   //multiplier
   multiplier my_multiplier(
      .clk(clk),
      .start(start),
      .A(aluA),
      .B(aluB),
      .Product(multiplier_result),
      .ready(ready)
   );


   // Controller Starts Here

   // Controller State Registers
   reg [4:0] state, nxt_state;

   // State Names & Numbers
   localparam
      RESET = 0, FETCH1 = 1, FETCH2 = 2, FETCH3 = 3, DECODE = 4,
      EX_ALU_R = 7, EX_ALU_I = 8,EX_JR = 10,
      EX_LW_1 = 11, EX_LW_2 = 12, EX_LW_3 = 13, EX_LW_4 = 14, EX_LW_5 = 15,EX_JAL = 16,EX_J = 17,EX_MUL_1 = 18 , EX_MUL_2 = 19,EX_MUL_3 = 20,
      EX_SW_1 = 21, EX_SW_2 = 22, EX_SW_3 = 23,
      EX_BRA_1 = 25, EX_BRA_2 = 26,
      EX_BRN_1 = 27, EX_BRN_2 = 28,
      EX_MFH = 29 , EX_MFL = 30, EX_J_2 = 31;

   // State Clocked Register 
   always @(posedge clk)
      if(reset)
         state <= #0.1 RESET;
      else
         state <= #0.1 nxt_state;

   task PrepareFetch;
      begin
         IorD = 0;
         setMRE = 1;
         MARwrt = 1;
         nxt_state = FETCH1;

           
      end
   endtask

   // State Machine Body Starts Here
   always @( * ) begin

      nxt_state = 'bx;

      SgnExt = 0; IorD = 0;
      MemtoReg = 3'b000; RegDst = 2'b00;
      aluSelA = 0; aluSelB = 3'b000; aluOp = 0 ; LHWrite = 0 ; start = 0;

      PCwrt = 0;
      Awrt = 0; Bwrt = 0;
      RFwrt = 0; IRwrt = 0;
      MDRwrt = 0; MARwrt = 0;
      setMRE = 0; clrMRE = 0;
      setMWE = 0; clrMWE = 0;
      pcSrc = 2'b00;

      case(state)

         RESET:
            PrepareFetch;

         FETCH1:
            nxt_state = FETCH2;

         FETCH2:
            nxt_state = FETCH3;

         FETCH3: begin
             pcSrc = 2'b00;
            IRwrt = 1;
            PCwrt = 1;
            clrMRE = 1;
            aluSelA = 0;
            aluSelB = 2'b01;
            aluOp = `ADD;
            nxt_state = DECODE;
         end

         DECODE: begin
            Awrt = 1;
            Bwrt = 1;
            case( IR[31:26] )
               6'b000_000:             // R-format
                  case( IR[5:3] )
                     //3'b000: ;
                     3'b001: begin
                        if(IR[2:0]==3'b000)
                        nxt_state = EX_JR;
                        else if(IR[2:0]==3'b001) 
                        nxt_state = EX_JAL;
                        end
                        3'b010: 
                        case(IR[2:0])
                        3'b010: nxt_state = EX_MFL;
                        3'b000: nxt_state = EX_MFH;
                     endcase
                     3'b011: nxt_state = EX_MUL_1;
                     3'b100: nxt_state = EX_ALU_R;
                     3'b101: nxt_state = EX_ALU_R;
                    // 3'b110: ;
                     //3'b111: ;
                  endcase

               6'b001_000,             // addi
               6'b001_001,             // addiu
               6'b001_010,             // slti
               6'b001_011,             // sltiu
               6'b001_100,             // andi
               6'b001_101,             // ori
               6'b001_111,              //lui
               6'b001_110:             // xori
                  nxt_state = EX_ALU_I;

               6'b100_011:
                  nxt_state = EX_LW_1;

               6'b101_011:
                  nxt_state = EX_SW_1;

               6'b000_100:
                  nxt_state = EX_BRA_1;
               6'b000_101:
                  nxt_state = EX_BRN_1;
               6'b000_010:
                  nxt_state = EX_J;
               6'b000_011 : 
                  nxt_state = EX_JAL;

                  
                  

               // rest of instructiones should be decoded here

            endcase
         end
         EX_MUL_1 : begin
            start = 1;
            aluSelA = 1;
            aluSelB = 2'b00;
            nxt_state = EX_MUL_2;
         end
         EX_MUL_2 : begin
            start = 0;
            if (ready) begin
               nxt_state = EX_MUL_3;
            end
            else nxt_state = EX_MUL_2;
         end
         EX_MUL_3 : begin
            LHWrite = 1;
            nxt_state = RESET;
         end
         EX_MFL : begin
            RFwrt = 1;
            RegDst = 2'b01;
            MemtoReg = 2'b10;
            nxt_state = RESET;

         end
         EX_MFH : begin
            RFwrt = 1;
            RegDst = 2'b01;
            MemtoReg = 2'b11;
            nxt_state = RESET;

         end


         EX_ALU_R: begin
            RFwrt = 1;
            RegDst = 2'b01;
            MemtoReg = 2'b00;
            aluSelA = 1;
            aluSelB = 2'b00;
            
            case( IR[5:0] )
            6'b100000:
            aluOp = `ADD;
            6'b100001:
            aluOp = `ADD;
            6'b100010:
            aluOp = `SUB;
            6'b100011:
            aluOp = `SUB;
            6'b100100:
            aluOp = `AND;
            6'b100101:
            aluOp = `OR;
            6'b100110:
            aluOp = `XOR;
            6'b100111:
            aluOp = `NOR;
            6'b101010:
            aluOp = `SLT;
            6'b101011:
            aluOp = `SLTU;
         endcase
         nxt_state = RESET;
            
         end

         EX_ALU_I: begin
            RegDst = 2'b00;
            MemtoReg = 2'b00;
            aluSelA = 1;
            RFwrt = 1;
            case(IR[31:26])
             6'b001_000:  begin          // addi
             aluSelB = 3'b010;
             SgnExt = 1;
             aluOp = `ADD;
             
             end

               6'b001_001:begin             // addiu
               aluSelB = 3'b010;
               SgnExt = 0;
               aluOp = `ADD;
               end
               6'b001_010:begin             // slti
               aluSelB = 3'b010;
               SgnExt = 1;
               aluOp = `SLT;
               end
               6'b001_011:begin             // sltiu
               aluSelB = 3'b010;
               SgnExt = 0;
               aluOp = `SLTU;
               end
               6'b001_100:begin             // andi
               aluSelB = 3'b010;
               SgnExt = 0;
               aluOp = `AND;
               end
               6'b001_101:begin             // ori
               aluSelB = 3'b010;
               SgnExt = 0;
               aluOp = `OR;
               end
               6'b001111:begin              //lui
               aluSelB = 3'b100;
               SgnExt = 0;
               aluOp = `OR;
               end
               6'b001_110:begin             // xori
               aluSelB = 3'b010;
               SgnExt = 0;
               aluOp = `XOR;
               end
         endcase
         nxt_state = RESET;

         end

         EX_LW_1: begin
         SgnExt = 1;
         aluSelA = 1;
         aluSelB = 2'b10;
         IorD = 1;
         setMRE = 1;
         MARwrt = 1;
         nxt_state = EX_LW_2;

            
         end

         EX_SW_1: begin
         SgnExt = 1;
         aluSelA = 1;
         aluSelB = 3'b010;
         IorD = 1;
         setMWE = 1;
         MARwrt = 1;
         nxt_state = EX_SW_2;
         end

         EX_BRA_1: begin
            RFwrt = 0;
            aluSelA = 1;
            aluSelB = 2'b00;
            aluOp = `SUB;
            if (aluZero == 1)
            nxt_state = EX_BRA_2;
            else
            nxt_state = RESET;
      
         end
         EX_BRN_1: begin
            RFwrt = 0;
            aluSelA = 1;
            aluSelB = 2'b00;
            aluOp = `SUB;
            if (aluZero == 0)
            nxt_state = EX_BRN_2;
            else
            nxt_state = RESET;
      
         end

         EX_LW_2: begin
            nxt_state = EX_LW_3;

         end

         EX_LW_3: begin
            nxt_state = EX_LW_4;
         end

         EX_LW_4: begin
            clrMRE = 1;
            MDRwrt = 1;
            nxt_state = EX_LW_5;
         end
         EX_LW_5: begin
            RFwrt = 1;
            RegDst = 2'b00;
            MemtoReg = 2'b01;
            nxt_state = RESET;
         end
         EX_SW_2: begin
            setMWE = 0;
            clrMWE = 1;
            nxt_state = EX_SW_3;
         end
         EX_SW_3: begin
            nxt_state = RESET;
            //PrepareFetch;
         end
         EX_BRA_2: begin
            pcSrc = 2'b00;
            PCwrt = 1;
            aluSelA = 0;
            aluSelB = 2'b11;
            aluOp = `ADD;
            IorD = 1;
            setMRE = 1;
             MARwrt = 1;
             nxt_state = FETCH1;

         end
         EX_BRN_2: begin
            pcSrc = 2'b00;
            PCwrt = 1;
            aluSelA = 0;
            aluSelB = 2'b11;
            aluOp = `ADD;
            IorD = 1;
            setMRE = 1;
             MARwrt = 1;
             nxt_state = FETCH1;

         end
         EX_J : begin
            pcSrc = 2'b01;
            PCwrt = 1;
            //nxt_state = FETCH1;
            nxt_state = EX_J_2;
         end
         EX_JAL : begin
            RFwrt = 1;
            RegDst = 2'b10;
            MemtoReg = 3'b100;
            //aluSelA = 0;
            //aluSelB = 3'b001;
            if(IR[31:26]==6'b000000)
            nxt_state = EX_JR;
            else
            nxt_state = EX_J;
            //nxt_state = RESET;
            end
            EX_JR : begin
            pcSrc = 2'b10;
            PCwrt = 1;
            
            //nxt_state = FETCH1;
            nxt_state = EX_J_2;

         end
         EX_J_2 : begin
            nxt_state = RESET;


         end




            

      endcase

   end

endmodule

//==============================================================================

module my_alu(
   input [2:0] Op,
   input [31:0] A,
   input [31:0] B,

   output [31:0] X,
   output        Z
);

   wire sub = Op != `ADD;

   wire [31:0] bb = sub ? ~B : B;

   wire [32:0] sum = A + bb + sub;

   wire sltu = ! sum[32];

   wire v = sub ? 
        ( A[31] != B[31] && A[31] != sum[31] )
      : ( A[31] == B[31] && A[31] != sum[31] );

   wire slt = v ^ sum[31];

   reg [31:0] x;

   always @( * )
      case( Op )
         `ADD : x = sum;
         `SUB : x = sum;
         `SLT : x = slt;
         `SLTU: x = sltu;
         `AND : x =   A & B;
         `OR  : x =   A | B;
         `NOR : x = ~(A | B);
         `XOR : x =   A ^ B;
         default : x = 32'hxxxxxxxx;
      endcase

   assign #2 X = x;
   assign #2 Z = x == 32'h00000000;

endmodule

//==============================================================================

module reg_file(
   input clk,
   input write,
   input [4:0] WR,
   input [31:0] WD,
   input [4:0] RR1,
   input [4:0] RR2,
   output [31:0] RD1,
   output [31:0] RD2
);

   reg [31:0] rf_data [0:31];

   assign #2 RD1 = rf_data[ RR1 ];
   assign #2 RD2 = rf_data[ RR2 ];   

   always @( posedge clk ) begin
      if ( write )
         rf_data[ WR ] <= WD;

      rf_data[0] <= 32'h00000000;
   end

endmodule

//==============================================================================
module multiplier(
//-----------------------Port directions and deceleration
   input clk,  
   input start,
   input [31:0] A, 
   input [31:0] B, 
   output reg [63:0] Product,
   output ready
    );



//------------------------------------------------------

//----------------------------------- register deceleration
reg [31:0] Multiplicand ;
reg [31:0]  Multiplier;
reg [31:0] Multiplexer_output;
reg [5:0]  counter;
reg [31:0] first_Product ;
reg [31:0] second_product;
reg [63:0] temp;
//-------------------------------------------------------

//------------------------------------- wire deceleration
wire multiplexer_enable;
wire [31:0] adder_output;
wire c_out; 
//---------------------------------------------------------

//-------------------------------------- combinational logic
assign{c_out,adder_output} = Multiplexer_output + first_Product;
assign multiplexer_enable = Multiplier[0]; 
assign ready = counter[5];
//---------------------------------------------------------

//--------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      counter <= 6'h0 ;
      Multiplier <= B;
      first_Product <= 32'h00;
      second_product <= 32'h00;
      Multiplicand <= A ;
      //Product <= {first_Product, second_product};
     
      if(multiplexer_enable) 
         Multiplexer_output <= Multiplicand;
      else
        Multiplexer_output <= 32'h00;
      
   end

   else if(! ready) begin

         first_Product <= {c_out,adder_output[31:1]};
         //bug!!!!!!
         second_product[ counter] <=  adder_output[0];
         counter <= counter + 1;
        
        
         Multiplier <= Multiplier >> 1;

         


         if(multiplexer_enable) 
         Multiplexer_output <= Multiplicand;
         else
         Multiplexer_output <= 32'h00;
         

        



      
   end 
   else
   
   Product <= ((c_out<<63) + ({adder_output,second_product}>>1));


   

endmodule