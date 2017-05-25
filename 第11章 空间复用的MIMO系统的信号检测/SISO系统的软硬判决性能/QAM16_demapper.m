function [s] =QAM16_demapper(qam16,N) % N 개의 complex number를 argument로 받았다.

%MIMO-OFDM Wireless Communications with MATLAB®   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

if nargin<2,  N = length(qam16);  end
QAM_table = [-3+3i, -1+3i, 3+3i, 1+3i, -3+i, -1+i, 3+i, 1+i,-3-3i, -1-3i, 3-3i, 1-3i, -3-i, -1-i, 3-i, 1-i]/sqrt(10);
temp = [];
for n=0:N-1
   temp=[temp dec2bin(find(QAM_table==qam16(n+1))-1,4)]; 
end
%s=zeros(1,length(temp));
for n=1:length(temp)
   s(n)=bin2dec(temp(n));
end
