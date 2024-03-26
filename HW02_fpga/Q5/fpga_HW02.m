% Generate a random binary sequence of length 11
%generated_sequences = zeros(100);
clear; clc;
display('F');
fileID = fopen('eleven.txt', 'w');
fileID2 = fopen('hammingcode.txt', 'w');
for i = 1:100
    random_sequence = randi([0, 1], 1, 11);
    fprintf(fileID, '%d', random_sequence);
    fprintf(fileID, '%d\n' , '');
    %disp(parity_adder(random_sequence));
    
    fprintf(fileID2, '%d', parity_adder(random_sequence));
    fprintf(fileID2, '%d\n' , '');
    %generated_sequences(i) = random_sequence;
    %disp(random_sequence);
end
fclose(fileID);
fclose(fileID2);

%%
function output =  parity_adder(random_sequence)
new_seq = [0 0 random_sequence(1) 0 random_sequence(2:4) 0 random_sequence(5:11)];
p1 = mod(sum(new_seq([3 5 7 9 11 13 15])), 2);
p2 = mod(sum(new_seq([3 6 7 10 11 14 15])), 2);
p3 = mod(sum(new_seq([5 6 7 12 13 14 15])), 2);
p4 = mod(sum(new_seq([9 10 11 12 13 14 15])), 2);

% Form the 15-bit sequence with Hamming code
output = [p1 p2 random_sequence(1) p3 random_sequence(2:4) p4 random_sequence(5:11)];
end
