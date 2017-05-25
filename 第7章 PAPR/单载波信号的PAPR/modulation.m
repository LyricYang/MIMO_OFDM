function [s,time] = modulation(x,Ts,Nos,Fc)
% Ts : Sampling period
% Nos: Oversampling factor
% Fc : Carrier frequency
Nx=length(x);  offset = 0; 
if nargin<5
    scale = 1; 
    T=Ts/Nos; % Scale and Oversampling period for Baseband
else
    scale = sqrt(2);
    T=1/Fc/2/Nos; % Scale and Oversampling period for Passband
end
t_Ts = [0:T:Ts-T]; 
time = [0:T:Nx*Ts-T]; % One sampling interval and whole interval
tmp = 2*pi*Fc*t_Ts+offset; 
len_Ts=length(t_Ts); 
cos_wct = cos(tmp)*scale;  
sin_wct = sin(tmp)*scale;
%s = zeros(N*len_Ts,1);
for n = 1:Nx
   s((n-1)*len_Ts+1:n*len_Ts) = real(x(n))*cos_wct-imag(x(n))*sin_wct;
end