function xp=add_pilot(x,Nfft,Nps)
% CAZAC (Constant Amplitude Zero AutoCorrelation) sequence --> pilot
% Nps : Pilot spacing

if nargin<3
    Nps=4; 
end
Np=Nfft/Nps;  
xp=x; % Number of pilots and an OFDM signal including pilot signal
for k=1:Np
   xp((k-1)*Nps+1)= exp(1i*pi*(k-1)^2/Np);  % Pilot boosting with an even Np
   %xp((k-1)*Nps+1)= exp(j*pi*(k-1)*k/Np);  % Pilot boosting with an odd Np
end
