clear, clf
Nfading=1024;  % IFFT size for the Npath x Nfading fading matrix 
Nos=8;         % Fading oversampling factor
Npath=2;       % Number of paths
N=10000;
FadingType= 'class';
fm= [100 10];  % Doppler frequency
subplot(211)
[FadingMatrix,tf]= FWGN_ff(Npath,fm,Nfading,Nos,FadingType);
plot([1:Nfading]*tf,10*log10(abs(FadingMatrix(1,:))),'k:')
hold on
plot([1:Nfading]*tf,10*log10(abs(FadingMatrix(2,:))),'k-') 
title('Modified FWGN in Frequency Domain') 
xlabel('time[s]')
ylabel('Magnitude[dB]')
set(gca,'fontsize',9)
legend('Path 1, f_m=100Hz','Path 2, f_m=10Hz')
axis([0 0.5 -20 5]) 
subplot(212)
[FadingMatrix,tf]= FWGN_tf(Npath,fm,N,Nfading,Nos,FadingType);
plot([1:N]*tf,10*log10(abs(FadingMatrix(1,:))),'k:')
hold on
plot([1:N]*tf,10*log10(abs(FadingMatrix(2,:))),'k-')
title('Modified FWGN in Time Domain');
title(['Modified FWGN in Time Domain, Nfading=', num2str(Nfading),',Nos=',num2str(Nos),',T_s=',num2str(tf),'s']);
xlabel('time[s]')
ylabel('Magnitude[dB]')
set(gca,'fontsize',9)
legend('Path 1, f_m=100Hz','Path 2, f_m=10Hz')
axis([0 0.5 -20 5])