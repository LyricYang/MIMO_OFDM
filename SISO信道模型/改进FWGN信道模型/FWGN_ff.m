function [FadTime,tf] = FWGN_ff(Np,fm_Hz,Nfading,Nfosf,FadingType,varargin)
%Fadng generation based on FWGN method
% FadTime= FWGN_ff(Np,fm_Hz,Nfading,Nfosf,FadingType,sigma,phi)
% Inputs:
%  Np         : # of multipath
%  fm_Hz      : A vector of max. Doppler frequency of each path[Hz]
%  Nfading    : Doppler filter size (IFFT size)
%  Nfosf      : Oversampling factor of Doppler bandwith
%  FadingType : Doppler type, 'laplacian'/'class'/'flat'
%  sigma      : Angle spread of UE in case of 'laplacian' Doppler type
%  phi        : DoM-AoA in case of 'laplacian' Doppler type
% Outputs:
%  FadTime    : Np x Nfading, fading time matrix
fmax= max(fm_Hz);
% Doppler frequency spacing respect to maximal Doppler frequency
dfmax= 2*Nfosf*fmax/Nfading; 
if isscalar(fm_Hz), fm_Hz= fm_Hz*ones(1,Np);  end
% To get a funtion corresponding to Doppler spectrum of "FadingType"
FadingType= lower(FadingType); ftn_psd= Doppler_PSD_function(FadingType);
err_msg= 'The difference between max and min Doppler frequencies is too large.\n increase the IFFT size'; 
if strcmp(FadingType(1:2),'la') % Laplacian constrained PAS
  for i=1:Np
     Nd= floor(fm_Hz(i)/dfmax)-1;
     if Nd<1,  error(err_msg);   end
     tmp= ftn_psd([-Nd:Nd],varargin{1}(i),varargin{2}(i));
     tmpz= zeros(1,Nfading-2*Nd+1);
     FadFreq(i,:)= [tmp(Nd+1:end-1) tmpz tmp(2:Nd)];
  end
 else  % symmetric Doppler spectrum
  for i=1:Np
     Nd= floor(fm_Hz(i)/dfmax)-1;
     if Nd<1,  error(err_msg);  end
     tmp= ftn_psd([0:Nd]/Nd); tmpz= zeros(1,Nfading-2*Nd+3);
     FadFreq(i,:)= [tmp(1:Nd-1) tmpz fliplr(tmp(2:Nd-1))];
  end
end
% Add a random phase to the Doppler spectrum
FadFreq = sqrt(FadFreq).*exp(2*pi*j*rand(Np,Nfading));
FadTime = ifft(FadFreq,Nfading,2);
% Normalization to 1
FadTime= FadTime./sqrt(mean(abs(FadTime).^2,2)*ones(1,size(FadTime,2)));
tf=1/(2*fmax*Nfosf); %fading sample time=1/(Doppler BW*Nfosf)