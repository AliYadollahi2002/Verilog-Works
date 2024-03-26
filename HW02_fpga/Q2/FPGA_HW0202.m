clear; clc;
% Define the parameters
Fs = 1024; % Sampling frequency
f = 50; % Frequency of the sine wave
t = 0:1/Fs:1-1/Fs; % Time vector

% Create the sine wave
x = sin(2*pi*f*t);
fixed_x = fi(x , 1 , 16 , 14);
x_bin = split(fixed_x.bin, '   ');
%fixed_x.bin
y = cos(2*pi*f*t);
fixed_y = fi(y , 1 , 16 , 14);
y_bin = split(fixed_y.bin, '   ');
fileID = fopen('sin.txt', 'w');
fileID2 = fopen('cos.txt', 'w');
for i = 1:1024
    fprintf(fileID, '%s\n', x_bin{i});
    %fprintf(fileID, '%d\n' , '');
    fprintf(fileID2, '%s\n', y_bin{i});
    %fprintf(fileID2, '%d\n' , '');
end
fclose(fileID);
fclose(fileID2);

%%
clear; clc;
Fs = 1024;          
T = 1/Fs;           
L = 128;           
t = (0:L-1)*T;      



fid1 = fopen('sin_out.txt', 'r');
fid2 = fopen('cos_out.txt','r');

data1 = [];
tline1 = fgetl(fid1);
data2 = [];
tline2 = fgetl(fid2);
while ischar(tline1)
    sign_bit1 = tline1(1); 
    int_part1 = bin2dec(tline1(2)); 
    frac_part1 = bin2dec(tline1(3:end)); 
    
    
    data_point1 = int_part1 + frac_part1/(2^14); 
    if sign_bit1 == '1'
        data_point1 = data_point1 - 2; 
    end
    
    data1 = [data1; data_point1];
    
    
    tline1 = fgetl(fid1);
end
while ischar(tline2)
    sign_bit2 = tline2(1);
    int_part2 = bin2dec(tline2(2)); 
    frac_part2 = bin2dec(tline2(3:end)); 
    
    
    data_point2 = int_part2 + frac_part2/(2^14); 
    if sign_bit2 == '1'
        data_point2 = data_point2 - 2; 
    end
    data2 = [data2; data_point2];
    
    
    tline2 = fgetl(fid2);
end


fclose(fid1);
fclose(fid2);


Y1 = fft(data1);
Y2 = fft(data2);

P2_1 = abs(Y1/L);
P2_2 = abs(Y2/L);

P1_1 = P2_1(1:L/2+1);
P1_2 = P2_2(1:L/2+1);

frequencies = Fs*(0:(L/2))/L;
figure;
plot(frequencies,P1_1);
title('Amplitude Spectrum of Sine Wave');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
figure;
plot(frequencies,P1_2);
title('Amplitude Spectrum of Cosine Wave');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
final_data = data1 + i*data2;
display(final_data);
