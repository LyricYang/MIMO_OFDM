function ftn=Doppler_PSD_function(type)
% Doppler spectrum funtion for type =  
%  'flat'      : S(f)=1,   |f0(=f/fm)|< 1
%  'class'     : S(f)=A/(sqrt(1-f0.^2)), |f0|<1 (A: a real number)
%  'laplacian':  
%      S(f)=1./sqrt(1-f0.^2).*(exp(-sqrt(2)/sigma*abs(acos(f0)-phi))
%             +exp(-sqrt(2)/sigma*abs(acos(f0)-phi)))
%       with sigma(angle spread of UE) and phi(=DoM-AoA) 
%            in the case of 'laplacian' Doppler type
%  'sui'       : S(f)=0.785*f0.^4-1.72*f0.^2+1, |f0|<1
%  '3gpprice' : S(f)=0.41./(2*pi*fm*sqrt(1+1e-9-(f./fm).^2))+0.91*delta_ftn(f,0.7*fm), |f|<fm
%  'dr', S(f)=inline('(1./sqrt(2*pi*Dsp/2))*exp(-(f-Dsh).^2/Dsp)','f','Dsp','Dsh');
% f0 is the normalized Doppler frequency defined as f0=f/fm 
%  where fm is the maximum Doppler frequency

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

switch lower(type(1:2))
  case 'fl', ftn=inline('ones(1,length(f0))');
  case 'cl', ftn=inline('1./sqrt(1+1e-9-f0.^2)');
  case 'la', ftn=inline('(exp(-sqrt(2)/sigma*abs(acos(f0)-phi))+exp(-sqrt(2)/sigma*abs(acos(f0)+phi)))./sqrt(1+1e-9-f0.^2)','f0','sigma','phi');
  case 'su', ftn=inline('0.785*f0.^4-1.72*f0.^2+1.');
  case '3g', ftn=inline('0.41./(2*pi*fm*sqrt(1+1e-9-(f./fm).^2))+0.91*delta_ftn(f,0.7*fm)','f','fm');
  case 'dr', ftn=inline('(1./sqrt(2*pi*Dsp/2))*exp(-(f-Dsh).^2/Dsp)','f','Dsp','Dsh');
  otherwise, error('Unknown Doppler type in Doppler_PSD_function()');
end
