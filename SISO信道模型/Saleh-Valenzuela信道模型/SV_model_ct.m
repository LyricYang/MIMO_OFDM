function [h,t,t0,np]=SV_model_ct(Lam,lam,Gam,gam,num_ch,b002,sdi,nlos)
% S-V channel model
% Input 
%  Lam      : Cluster arrival rate in GHz (avg # of clusters per nsec)
%  lam      : Ray arrival rate in GHz (avg # of rays per nsec)
%  Gam      : Cluster decay factor (time constant, nsec)
%  gam      : Ray decay factor (time constant, nsec)
%  num_ch   : number of random realizations to generate
%  b002     : power of first ray of first cluster
%  sdi      : Standard deviation of log-normal shadowing 
%                of entire impulse  response [dB]
%  nlos     : Flag to specify generation of Non Line Of Sight channels
% Output 
%  h: a matrix with num_ch columns, each column 
%      having a random realization of channel model (impulse response)
%  t: organized as h, but holds the time instances (in nsec) of the 
%      paths whose signed amplitudes are stored in h
%  t0: the arrival time of the first cluster for each realization
%  np: the number of paths for each realization.
% Thus, the k'th realization of the channel impulse response is the 
% sequence of (time,value) pairs given by(t(1:np(k),k),h(1:np(k),k))
if nargin<8
    nlos=0;  
end     % LOS environment
if nargin<7
    sdi=0;
end % 0dB
if nargin<6
    b002=1;
end  %  power of first ray of first cluster
h_len=1000; %There must be a better estimate of # of paths than???
for k=1:num_ch             % loop over number of channels
   tmp_h = zeros(h_len,1); 
   tmp_t = zeros(h_len,1);
   if nlos
       Tc = exprnd(1/Lam); % First cluster random arrival
   else
       Tc = 0;         % First cluster arrival occurs at time 0
   end
   t0(k) = Tc;
   path_ix = 0;
   while (Tc<10*Gam)  % cluster loop    
     % Determine Ray arrivals for each cluster
     Tr=0;  %1st ray arrival defined to be time 0 relative to cluster
     while (Tr<10*gam) % ray loop
        brm2 = b002*exp(-Tc/Gam)*exp(-Tr/gam);  % ray power (2.20)
        r = sqrt(randn^2+randn^2)*sqrt(brm2/2); 
        % rayleigh distributed mean power pow_bkl
        h_val=exp(j*2*pi*rand)*r;  % uniform phase      
        path_ix = path_ix+1;      % row index of this ray
        tmp_h(path_ix) = h_val;  
        tmp_t(path_ix) = Tc+Tr;  % time of arrival of this ray
        Tr = Tr + exprnd(1/Lam); % (2.16) ???
     end
     Tc = Tc + exprnd(1/lam); % (2.17) ???
   end
   np(k)=path_ix;  % number of rays (or paths) for this realization
   [sort_tmp_t,sort_ix] = sort(tmp_t(1:np(k)));  %in ascending order
   t(1:np(k),k) = sort_tmp_t;
   h(1:np(k),k) = tmp_h(sort_ix(1:np(k)));   
   % now impose a log-normal shadowing on this realization
   fac = 10^(sdi*randn/20)/sqrt(h(1:np(k),k)'*h(1:np(k),k));
   h(1:np(k),k) = h(1:np(k),k)*fac; % (2.21)
end