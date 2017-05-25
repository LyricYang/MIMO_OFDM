function data=data_generator(L_frame,N_frames,md,zf)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

data = round((md-1)*rand(L_frame,1,N_frames));
% zero forcing appendix
[m,n,o] = size(data);
data(m+1:m+zf,:,1:o) = 0;
