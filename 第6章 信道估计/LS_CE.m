function H_LS = LS_CE(Y,Xp,pilot_loc,Nfft,Nps,int_opt)
% LS channel estimation function
% Inputs:
%       Y         = Frequency-domain received signal
%       Xp        = Pilot signal
%       pilot_loc = Pilot location
%       N         = FFT size
%       Nps       = Pilot spacing
%       int_opt   = 'linear' or 'spline'
% output:
%       H_LS      = LS channel etimate
Np=Nfft/Nps;
k=1:Np;
LS_est(k) = Y(pilot_loc(k))./Xp(k);  % LS channel estimation
if  lower(int_opt(1))=='l'
    method='linear'; 
else
    method='spline'; 
end
H_LS = interpolate(LS_est,pilot_loc,Nfft,method); % Linear/Spline interpolation