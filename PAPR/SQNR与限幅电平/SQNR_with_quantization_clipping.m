% SQNR_with_quantization_clipping.m
% Plot Fig. 7.12

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear, clf
N=64; b=6; L=8; MaxIter=1000;
TWLs = [6:9]; IWL = 1; % Total/Integral/Fractional WordLengths
mus=[2:0.2:8]; sq2=sqrt(2); % Clipping Ratio vector
%varx = 0;
%for k = 1:MaxIter
%   X = mapper(b,N);  x = ifft(X,N);  varx = varx + x*x'/N;
%end
%sigma = sqrt(varx/MaxIter); %SQNRe = zeros(length(FWL),length(mus)); varX = 0;
sigma=1/sqrt(N); gss=['ko-';'ks-';'k^-';'kd-']; % variance of x and graphic symbols
for i = 1:length(TWLs)
   TWL = TWLs(i); FWL = TWL-IWL; % Total/Fractional WordLength
   for m = 1:length(mus)
      mu = mus(m)/sq2; Tx = 0; Te = 0;
      for k = 1:MaxIter
         X = mapper(b,N); x = ifft(X,N); x = x/sigma/mu;
         xq=fi(x,1,TWL,FWL,'roundmode','round','overflowmode','saturate'); 
         xq=double(xq); Px = x*x'; e = x-xq; Pe = e*e';
         Tx = Tx + Px;  Te = Te + Pe;
      end
      SQNRdB(i,m) = 10*log10(Tx/Te);
   end
end
[SQNRdBmax,imax] = max(SQNRdB'); % To find the maximum elements in each row of SQNRdB
for i=1:size(gss,1), plot(mus,SQNRdB(i,:),gss(i,:)), hold on;  end
for i=1:size(gss,1)
   str(i,:)=[num2str(TWLs(i)) 'bit quantization'];
   plot(mus(imax(i)),SQNRdBmax(i),gss(i,1:2),'markerfacecolor','r')
end
title(['Effect of Clipping (N=' num2str(N) ', \sigma=' num2str(sigma) ')']);
xlabel('mus(clipping level normalized to \sigma)');  ylabel('SQNR[dB]');
legend(str(1,:),str(2,:),str(3,:),str(4,:));  grid on