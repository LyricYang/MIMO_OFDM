function PDP=ieee802_11_model(sigma_tau,Ts)
% IEEE 802.11 channel model PDP generator
% Input:
%       sigma_tau  : RMS delay spread
%       Ts         : Sampling time
% Output:
%       PDP        : Power delay profile
 
lmax = ceil(10*sigma_tau/Ts);
sigma02=(1-exp(-Ts/sigma_tau))/(1-exp(-(lmax+1)*Ts/sigma_tau)); % (2.9)
l=0:lmax;
PDP = sigma02*exp(-l*Ts/sigma_tau); % (2.8)