function [QPSK_symbols] = QPSK_mapper(bitseq)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

QPSK_table = [1  j -j -1]/sqrt(2); 
for i=1:length(bitseq)/2
   temp = bitseq(2*(i-1)+1)*2 +bitseq(2*(i-1)+2);
   QPSK_symbols(i) = QPSK_table(temp+1);
end