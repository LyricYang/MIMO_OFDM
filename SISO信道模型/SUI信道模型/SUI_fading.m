function [FadMtx,tf]=SUI_fading(P_dB,K_factor,Dopplershift_Hz,Fnorm_dB,N,M,Nfosf)
% SUI fading generation using FWGN with fitering in the frequency domain
%  Inputs:
%    P_dB            : power in each tap in dB
%    K_factor        : Rician K-factor in linear scale
%    Dopplershift_Hz : a vector containing the maximum Doppler frequency of each path in Hz
%    Fnorm_dB        : gain normalization factor in dB
%    N               : # of independent random realization
%    M               : length of Doppler filter, i.e, size of IFFT
%    Nfosf           : fading oversampling factor 
%  Outputs:
%    FadMtx          : length(P_dB) x N fading matrix
%    tf              : fading sample time=1/(Max. Doppler BW * Nfosf) 
 
%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd
 
Power = 10.^(P_dB/10);                    % calculate linear power
s2 = Power./(K_factor+1);                 % calculate variance
s=sqrt(s2);
m2 = Power.*(K_factor./(K_factor+1));     % calculate constant power
m = sqrt(m2);                             % calculate constant part
L=length(Power);                          % # of tabs
fmax= max(Dopplershift_Hz);
tf=1/(2*fmax*Nfosf);
if isscalar(Dopplershift_Hz), Dopplershift_Hz= Dopplershift_Hz*ones(1,L);  end
path_wgn= sqrt(1/2)*complex(randn(L,N),randn(L,N));
for p=1:L
   filt=gen_filter(Dopplershift_Hz(p),fmax,M,Nfosf,'sui');
   path(p,:)=fftfilt(filt,[path_wgn(p,:) zeros(1,M)]); %filtering WGN
end
FadMtx= path(:,M/2+1:end-M/2);
for i=1:L , FadMtx(i,:)=FadMtx(i,:)*s(i) + m(i)*ones(1,N); end
FadMtx = FadMtx*10^(Fnorm_dB/20); 