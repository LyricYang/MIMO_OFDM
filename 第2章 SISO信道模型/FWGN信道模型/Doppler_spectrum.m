function y=Doppler_spectrum(fd,Nfft)
% fd=maximum Doppler frequency
% Nfft=number of frequency domain points
df = 2*fd/Nfft; % Frequency Spacing.
% The DC component first.
f(1) = 0;  
y(1) = 1.5/(pi*fd);   
% The other components for ONE side the spectrum.
for i = 2:Nfft/2,
   f(i) = (i-1)*df; % The frequency indices for polynomial fitting.
   y([i Nfft-i+2]) = 1.5/(pi*fd*sqrt(1- (f(i)/fd)^2));
end
% nyquist frequency applied polynomial fitting using the last 3 frequency samples.
nFitPoints=3 ; 
kk=[Nfft/2-nFitPoints:Nfft/2]; % good enough.
polyFreq = polyfit(f(kk),y(kk),nFitPoints);
y(Nfft/2+1) = polyval(polyFreq,f(Nfft/2)+df);
