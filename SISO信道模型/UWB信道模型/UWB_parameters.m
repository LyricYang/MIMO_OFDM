function [Lam,lam,Gam,gam,nlos,sdi,sdc,sdr]=UWB_parameters(cm)
% S-V model parameters for standard UWB channel models
% Input
%   cm=1 : based on TDC measurements for LOS 0-4m
%   cm=2 : based on TDC measurements for NLOS 0-4m
%   cm=3 : based on TDC measurements for NLOS 4-10m
%   cm=4 : 25 nsec RMS delay spread bad multipath channel
% Output
%   Lam  : Cluster arrival rate (clusters per nsec)
%   lam  : Ray arrival rate (rays per nsec)
%   Gam  : Cluster decay factor (time constant, nsec)
%   gam  : Ray decay factor (time constant, nsec)
%   nlos : Flag for non line of sight channel
%   sdi  : Standard deviation of log-normal shadowing of entire impulse response
%   sdc  : Standard deviation of log-normal variable for cluster fading
%   sdr  : Standard deviation of log-normal variable for ray fading
% Table 2.1:
tmp = 4.8/sqrt(2);
Tb2_1= [0.0233 2.5  7.1  4.3 0 3 tmp tmp; 0.4  0.5  5.5  6.7 1 3 tmp tmp;
        0.0667 2.1 14.0  7.9 1 3 tmp tmp; 0.0667 2.1 24  12  1 3 tmp tmp];
Lam = Tb2_1(cm,1); lam = Tb2_1(cm,2); Gam = Tb2_1(cm,3); gam = Tb2_1(cm,4);
nlos= Tb2_1(cm,5); sdi = Tb2_1(cm,6); 
sdc = Tb2_1(cm,7); sdr = Tb2_1(cm,8);