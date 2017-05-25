function [xt, time] = IFFT_oversampling(X,N,L)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

if nargin<3,  L=1;  end
NL=N*L; T=1/NL; time = [0:T:1-T];  X = X(:).';
xt = L*ifft([X(1:N/2)  zeros(1,NL-N)  X(N/2+1:end)], NL);