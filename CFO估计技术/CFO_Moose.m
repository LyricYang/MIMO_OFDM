function CFO_est=CFO_Moose(y,Nfft)
% Frequency-domain CFO estimation using Moose method based on two consecutive identical OFDM symbols 

for i=0:1   
   Y(i+1,:)= fft(y(Nfft*i+1:Nfft*(i+1)),Nfft);
end
CFO_est = angle(Y(2,:)*Y(1,:)')/(2*pi);