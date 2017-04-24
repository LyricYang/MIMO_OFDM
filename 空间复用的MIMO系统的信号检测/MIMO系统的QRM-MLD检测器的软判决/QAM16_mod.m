function qam16=QAM16_mod(bitseq,N)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

bitseq = bitseq(:).';  
%sq10=sqrt(10);
%QAM_table = [-3-3*j, -3-j, -3+3*j, -3+j, -1-3*j, -1-j, -1+3*j, -1+j, 3-3*j, 3-j, 3+3*j, 3+j, 1-3*j, 1-j, 1+3*j, 1+j]/sqrt(10.);
QAM_table =[-3+3i, -1+3i, 3+3i, 1+3i, -3+i, -1+i, 3+i, 1+i,-3-3i, -1-3i, 3-3i, 1-3i, -3-i, -1-i, 3-i, 1-i]/sqrt(10);
if nargin<2,  N=floor(length(bitseq)/4); end
for n=1:N
   qam16(n) = QAM_table(bitseq(4*n-[3 2 1])*[8;4;2]+bitseq(4*n)+1);
end