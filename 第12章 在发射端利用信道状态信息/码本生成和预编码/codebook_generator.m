function [code_book]=codebook_generator

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

% N_Nt: number of Tx antennas
% N_M : codeword length
% N_L : codebook size
N_Nt=4; N_M=2; N_L=64;
cloumn_index=[1 2]; rotation_vector=[1 7 52 56];
kk=0:N_Nt-1; ll=0:N_Nt-1;
w = exp(j*2*pi/N_Nt*kk.'*ll)/sqrt(N_Nt);
w_1 = w(:,cloumn_index([1 2]));
theta = diag(exp(j*2*pi/N_L*rotation_vector));
code_book(:,:,1) = w_1 ;
for i=1:N_L-1
   code_book(:,:,i+1) = theta*code_book(:,:,i);
end
