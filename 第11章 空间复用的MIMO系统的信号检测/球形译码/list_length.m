function [len]=list_length(list)
% Input parameter
%     list : vector type
% Output parameter
%     len : index number

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

len = 0;
for i=1:4
   if list(i)==0,  break;   else  len = len+1;   end
end
