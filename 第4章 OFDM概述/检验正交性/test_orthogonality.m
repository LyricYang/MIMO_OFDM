%test_orthogonality.m
%to plot several sinusoidal signals with different frequencies/phases and their DFT sequences
% and to check their orthogonality
clear, clf
T=1.6; 
ND=1000; 
nn=0:ND; 
ts=0.002; 
tt=nn*ts; % time interval
Ts = 0.1; 
M = round(Ts/ts); % Sampling period in continuous/discrete-time 
nns = [1:M:ND+1]; 
tts = (nns-1)*ts; % Sampling indices and times 
ks = [1:4 3.9 4]; 
tds = [0 0 0.1 0.1 0 0.15]; % Frequency indices and delay times
K = length(ks);
for i=1:K
   k=ks(i); 
   td=tds(i); 
   x(i,:) = exp(j*2*pi*k*(tt-td)/T); 
   if i==K
       x(K,:) = [x(K,[302:end]) x(K-3,[1:301])]; end
   title_string = sprintf('cos(2pi*%1.1f*(t-%4.2f)/%2.1f)',k,td,T);
   subplot(K,2,2*i-1);
   plot(tt,real(x(i,:)),'LineWidth',1);
   title(title_string)
   hold on
   plot(tt([1 end]),[0 0],'k')
   set(gca,'fontsize',9);
   axis([tt([1 end]) -1.2 1.2])
   stem(tts,real(x(i,nns)),'.','markersize',5)
end
N = round(T/Ts); xn = x(:,nns(1:N));
xn*xn'/N % check orthogonality
Xk = fft(xn.').'; 
kk = 0:N-1;
for i=1:K
   k=ks(i); td=tds(i);   
   title_string = sprintf('DFT of cos(2pi*%1.1f*(t-%4.2f)/%2.1f), t=[0:%d]*%3.2f',k,td,T,N-1,Ts);
   subplot(K,2,2*i);
   stem(kk,abs(Xk(i,:)),'.','markersize',5);
   title(title_string)
   set(gca,'fontsize',8,'xtick',[k]), axis([0 N 0 20])
end