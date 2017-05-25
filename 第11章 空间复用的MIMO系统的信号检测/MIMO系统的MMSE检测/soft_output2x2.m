function [x4_soft] = soft_output2x2(x)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

sq10=sqrt(10); sq10_2=2/sq10;  x=x(:).'; xr=real(x); xi=imag(x); 
X=sq10*[-xi; sq10_2-abs(xi); xr; sq10_2-abs(xr)]; 
x4_soft = X(:).'; 
