function PDP=exp_PDP(tau_d,Ts,A_dB,norm_flag)
% Exponential PDP generator
%   Input:
%       tau_d     : rms delay spread in second
%       Ts        : Sampling time in second
%       A_dB      : the smallest noticeable power in dB
%       norm_flag : normalizes total power to unit
%   Output:
%       PDP       : PDP vector
 
if nargin<4
    norm_flag=1; 
end     % normalizes
if nargin<3
    A_dB=-20; 
end     % 20dB below
sigma_tau = tau_d;
A = 10^(A_dB/10); 
tau_max=ceil(-tau_d*log(A)/Ts); 
% Computes normalization factor for power normalization
if norm_flag
    p0=(1-exp(-Ts/sigma_tau))/(1-exp(-(tau_max+1)*Ts/sigma_tau));
else
    p0=1/sigma_tau;
end
% Exponential PDP
p=0:tau_max; 
PDP = p0*exp(-p*Ts/sigma_tau);