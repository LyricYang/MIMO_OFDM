% plot_SUI_channel.m
clear, clf
ch_no=6;
fc=2e9;
fs_Hz=1e7;                     
Nfading=1024;    % Size of Doppler filter
N=10000;
Nos=4;
[Delay_us, P_dB, K_factor, Dopplershift_Hz, Ant_corr, Fnorm_dB]=SUI_parameters(ch_no);
[FadTime,tf]=SUI_fading(P_dB, K_factor, Dopplershift_Hz, Fnorm_dB, N, Nfading, Nos);
K1= size(FadTime,2)-1;
c_table=['b';'r';'k';'m'];
subplot(311)
stem(Delay_us,10.^(P_dB/10));
grid on, xlabel('Delay time[ms]'), ylabel('Channel gain');
title(['PDP of Channel No.',num2str(ch_no)]), set(gca,'fontsize',9)
subplot(312)
for k=1:length(P_dB)
   plot([0:K1]*tf,20*log10(abs(FadTime(k,:))),c_table(k,:)); hold on
end
grid on, xlabel('Time[s]'), ylabel('Channel Power[dB]');
title(['Channel No.',num2str(ch_no)]), axis([0 60 -50 10])
legend('Path 1','Path 2','Path 3'), set(gca,'fontsize',9)
idx_nonz= find(Dopplershift_Hz);
FadFreq= ones(length(Dopplershift_Hz),Nfading);
for k=1:length(idx_nonz)
   max_dsp= 2*Nos*max(Dopplershift_Hz);
   dfmax= max_dsp/Nfading; % Doppler frequency spacing respect to maximal Doppler frequency
   Nd= floor(Dopplershift_Hz(k)/dfmax)-1;      
   f0 = [-Nd+1:Nd]/Nd; % frequency vector    
   f = f0.*Dopplershift_Hz(k);    
   tmp=0.785*f0.^4 - 1.72*f0.^2 + 1.0;
   hpsd=psd(spectrum.welch,FadTime(idx_nonz(k),:),'Fs',max_dsp,'SpectrumType','twosided');
   nrom_f=hpsd.Frequencies-mean(hpsd.Frequencies);
   PSD_d=fftshift(hpsd.Data);   
   subplot(3,3,6+k), plot(nrom_f,PSD_d,'b', f,tmp,'r')
   xlabel('Frequency[Hz]'), axis([-1 1 0 1.1*max([PSD_d.' tmp])])
   title(['h_',num2str(idx_nonz(k)),' path']); set(gca,'fontsize',9)
end