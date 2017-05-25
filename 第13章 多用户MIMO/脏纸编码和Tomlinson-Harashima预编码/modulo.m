function [y]=modulo(x,A)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

temp_real=floor((real(x)+A)/(2*A));
temp_imag=floor((imag(x)+A)/(2*A));
y=x-temp_real*(2*A)-j*temp_imag*(2*A);