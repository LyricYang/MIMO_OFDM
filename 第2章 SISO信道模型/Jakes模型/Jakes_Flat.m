function [h,tf]=Jakes_Flat(fd,Ts,Ns,t0,E0,phi_N)
% Inputs:
%   fd      : Doppler frequency
%   Ts      : sampling period
%   Ns      : number of samples
%   t0      : initial time
%   E0      : channel power
%   phi_N  : inital phase of the maximum doppler frequency sinusoid
% Outputs:
%   h       : complex fading vector
%   t_state: current time
if nargin<6
    phi_N=0;    
end
if nargin<5
    E0=1;      
end
if nargin<4
    t0=0;  
end
if nargin<3
    error('More arguments are needed for Jakes_Flat()');  
end
N0=8;                 % As suggested by Jakes 
N=4*N0+2;             % an accurate approximation              
wd=2*pi*fd;           % Maximum doppler frequency[rad]
%t_state = t0;
%for i=1:Ns
%   ich=sqrt(2)*cos(phi_N)*cos(wd*t_state);
%   qch=sqrt(2)*sin(phi_N)*cos(wd*t_state);
%   for k=1:N0
%      phi_n=pi*k/(N0+1);
%      wn=wd*cos(2*pi*k/N);
%      ich=ich+2*cos(phi_n)*cos(wn*t_state);
%      qch=qch+2*sin(phi_n)*cos(wn*t_state);
%   end
%   h1(i) = E0/sqrt(2*N0+1)*complex(ich,qch);
%   t_state=t_state+Ts;             % save last time
%end
t = t0+[0:Ns-1]*Ts;  
tf = t(end)+Ts; 
coswt = [sqrt(2)*cos(wd*t); 2*cos(wd*cos(2*pi/N*[1:N0]')*t)]; % (2.32)
h = E0/sqrt(2*N0+1)*exp(j*[phi_N pi/(N0+1)*[1:N0]])*coswt; 
% discrepancy = norm(h-h1)