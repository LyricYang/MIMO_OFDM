function H_interpolated = interpolate(H_est,pilot_loc,Nfft,method)
% Input:        H_est    = Channel estimate using pilot sequence
%           pilot_loc    = location of pilot sequence
%                Nfft    = FFT size
%              method    = 'linear'/'spline'
% Output: H_interpolated = interpolated channel
if pilot_loc(1)>1
  slope = (H_est(2)-H_est(1))/(pilot_loc(2)-pilot_loc(1));
  H_est = [H_est(1)-slope*(pilot_loc(1)-1)  H_est]; 
  pilot_loc = [1 pilot_loc];
end
if pilot_loc(end)<Nfft
    slope = (H_est(end)-H_est(end-1))/(pilot_loc(end)-pilot_loc(end-1));  
    H_est = [H_est  H_est(end)+slope*(Nfft-pilot_loc(end))]; 
    pilot_loc = [pilot_loc Nfft];
end
if lower(method(1))=='l'
    H_interpolated = interp1(pilot_loc,H_est,[1:Nfft]);   
else
    H_interpolated = interp1(pilot_loc,H_est,[1:Nfft],'spline');
end  