function PL=PL_logdist_or_norm(fc,d,d0,n,sigma)
% Log-distance or Log-normal Shadowing Path Loss model
% Input
%       fc    : carrier frequency[Hz]
%       d     : between base station and mobile station[m]
%       d0    : reference distance[m]
%       n     : path loss exponent, n
%       sigma : variance[dB]
% output
%       PL    : path loss[dB]
lamda = 3e8/fc;
PL = -20*log10(lamda/(4*pi*d0)) + 10*n*log10(d/d0);
if nargin>4
    PL = PL + sigma*randn(size(d));  
end %如果输入参数大于4