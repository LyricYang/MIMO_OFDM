% PAPR_of_preamble.m
% Plot Fig. 7.10(b) (the PAPR of IEEE802.16e preamble)

%MIMO-OFDM Wireless Communications with MATLAB㈢   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear, clf
N=1024; L=4; Npreamble=114; n=0:Npreamble-1; % Mod='BPSK'; 
%PAPR = zeros(N_preamble,1); PAPR_os = zeros(N_preamble,1);
for i = 1:Npreamble
   X=load(['C:\Users\Administrator\Desktop\MIMO OFDM Wireless Communication\PAPR\Chu序列和IEEE802.16e前导的PAPR\Wibro-Preamble\Preamble_sym' num2str(i-1) '.dat']);
   X = X(:,1); X = sign(X); X = fftshift(X);
   x = IFFT_oversampling(X,N); PAPRdB(i) = PAPR(x);
   x_os = IFFT_oversampling(X,N,L); PAPRdB_os(i) = PAPR(x_os);
end
plot(n,PAPRdB,'-o', n,PAPRdB_os,':*'), 
title('PAPRdB without and with oversampling')
