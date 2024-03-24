`timescale 1ns/1ns
module fp_adder(
    input [31:0] a,
    input [31:0] b,
    output wire [31:0] s
    );
//  wires
//  sign  variables
wire sign_A;
wire sign_B;
wire sign_big;
wire final_sign;
wire sum_result_sign;
//  exponent variables
wire [7:0] exp_A;
wire [7:0] exp_B;
wire [7:0] final_exp_A;
wire [7:0] final_exp_B;
wire [7:0] exp_difference;
wire [7:0] exp_big;
wire [7:0] result_exp_1;
wire [7:0] result_exp_2;
wire [7:0] final_exp;
//  fraction & number variables
wire[22:0] frac_A;
wire[22:0] frac_B;
wire [25:0] final_A;
wire [25:0] final_B;
wire borrow;
wire [25:0] small_number;
wire [25:0] big_number;
wire sticky;
wire [28:0] final_small_number;
wire [28:0] final_big_number;
wire [28:0] sum_result;
wire [28:0] final_sum;
wire [4:0] leading_one;
wire [28:0] first_normalized_num;
wire[3:0] round_bits;
wire [24:0] rounded_number;
wire [24:0] final_output;
wire [22:0] final_frac;
wire my_temp;
wire my_temp_2;
wire [7:0] shift_amount;
wire[7:0] final_shift_amount;
wire[31:0] Output;

//  statement assigments

//  defining smaller and larger number
assign sign_A=a[31];
assign sign_B=b[31];
assign exp_A = a[30:23];
assign exp_B = b[30:23];
assign final_exp_A = (exp_A == 8'h00) ? (8'b00000001) : exp_A;
assign final_exp_B = (exp_B == 8'h00) ? (8'b00000001) : exp_B;
assign frac_A = a[22:0];
assign frac_B = b[22:0];
assign final_A=  exp_A!=0 ? {1'b1,frac_A,2'b00} : {1'b0,frac_A,2'b00};
assign final_B= exp_B!=0 ? {1'b1,frac_B,2'b00} : {1'b0,frac_B,2'b00};

//  borrow
assign borrow = (final_exp_A < final_exp_B) ? 1 : (final_exp_A > final_exp_B) ? 0 : (final_A>final_B) ? 0 : 1;

//  exponent difference
assign exp_difference = borrow ? final_exp_B - final_exp_A : final_exp_A - final_exp_B;
assign small_number= borrow?final_A:final_B;
assign big_number= borrow?final_B:final_A;
assign sign_big = borrow ? sign_B : sign_A;
assign exp_big = borrow ? final_exp_B : final_exp_A;


//  sticky
assign sticky=|(small_number<<(26 - exp_difference));
assign final_small_number = {{2'b00,small_number}>>exp_difference,sticky};
assign final_big_number={2'b00,big_number,1'b0};
//  calculating the sum
assign sum_result={sign_A,sign_B}==2'b00 || {sign_A,sign_B}==2'b11  ? final_small_number+final_big_number : final_big_number+(~final_small_number)+1; 
assign sum_result_sign = sum_result[28];
assign final_sum=sum_result_sign == 0 ? sum_result : (~sum_result) + 1;  

//  final_sign
assign final_sign = (final_exp_A != final_exp_B)||(sign_A==sign_B) ? sign_big : final_A > final_B ? sign_A : sign_B;

//  leading one
assign leading_one =   final_sum[28] ? 28 :
final_sum[27] ? 27 :
final_sum[26] ? 26 :
final_sum[25] ? 25 :
final_sum[24] ? 24 :
final_sum[23] ? 23 :
final_sum[22] ? 22 :
final_sum[21] ? 21 :
final_sum[20] ? 20 :
final_sum[19] ? 19 :
final_sum[18] ? 18 :
final_sum[17] ? 17 :
final_sum[16] ? 16 :
final_sum[15] ? 15 :
final_sum[14] ? 14 :
final_sum[13] ? 13 :
final_sum[12] ? 12 :
final_sum[11] ? 11 :
final_sum[10] ? 10 :
final_sum[9] ? 9 :
final_sum[8] ? 8 :
final_sum[7] ? 7 :
final_sum[6] ? 6 :
final_sum[5] ? 5 :
final_sum[4] ? 4 :
final_sum[3] ? 3 :
final_sum[2] ? 2 :
final_sum[1] ? 1 : 
final_sum[0] ? 0 : 30;

// normalizing
assign shift_amount = 27 - leading_one;
assign result_exp_1 = (exp_big + 1>=shift_amount) == 1 ? (exp_big + 1) - shift_amount:shift_amount - (exp_big + 1);
assign final_shift_amount = result_exp_1==0 ? shift_amount - 1 : (exp_big + 1<shift_amount) ? exp_big  : shift_amount;
assign first_normalized_num=final_sum<<final_shift_amount;
assign result_exp_2 = (exp_big + 1<shift_amount) ==0 ?result_exp_1 : 0  ;


// rounding
assign round_bits = first_normalized_num[3:0];
assign my_temp = first_normalized_num[4];
assign rounded_number = round_bits > 4'b1000 ? first_normalized_num[28:4] + 1 : round_bits < 4'b1000 ?  first_normalized_num[28:4] : my_temp == 1 ? first_normalized_num[28:4]+1:{first_normalized_num[28:5],1'b0};




// last normalizing if needed & defining the output
assign final_exp = rounded_number[24] == 1 ? result_exp_2 + 1 : result_exp_2 ; 
assign final_output = final_exp == 8'b11111111 ? 0 : rounded_number[24] == 1 ?  (rounded_number>>1)  : rounded_number ;
assign final_frac=final_output[22:0];
assign Output = {exp_A,frac_A}=={exp_B,frac_B}&& sign_A!=sign_B ? 32'h0000 : {final_sign,final_exp,final_frac};
assign s = Output;

    
endmodule