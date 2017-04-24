function h=ray_fading(M,PDP,BS_PHI_rad,MS_theta_deg,v_ms,theta_v_deg,lambda,t)
%h=ray_fading(M,PDP,BS_theta_deg,BS_PHI_rad,MS_theta_deg,v_ms,theta_v_deg,lambda,t)
%   Inputs:
%       M               : # of subrays
%       PDP             : 1 x Npath Power at delay
%       BS_theta_deg    : (Npath x M) DoA per path in degree at BS ?????
%       BS_PHI_rad      : (Npath x M) random phase in degree at BS
%       MS_theta_deg    : (Npath x M) DoA per path in degree at MS
%       v_ms            : velocity in m/s
%       theta_v_deg     : DoT of mobile in degree
%       lambda          : wavelength in meter
%       t               : current time
%   Outputs:
%       h               : 1xlength(PDP) channel coefficient
 
%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd
 
MS_theta_rad=deg2rad(MS_theta_deg);
theta_v_rad=deg2rad(theta_v_deg);
% generate channel coefficients
for n=1:length(PDP)
   tmph=exp(-j*BS_PHI_rad(n,:)')*ones(size(t)).*exp(-j*2*pi/lambda*v_ms...
           *cos(MS_theta_rad(n,:)'-theta_v_rad)*t);
   h(n,:)=sqrt(PDP(n)/M)*sum(tmph);
end