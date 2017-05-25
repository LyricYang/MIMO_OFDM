% MIMO_channel_cap_ant_sel_optimal.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all; clf
NT=4; NR=4; MaxIter=1000;
I=eye(NR,NR); sq2=sqrt(2); gss=['-ko';'-k^';'-kd';'-ks'];
SNRdBs=[0:2:20];
for sel_ant=1:4
   for i_SNR=1:length(SNRdBs)
      SNRdB = SNRdBs(i_SNR);  SNR_sel_ant = 10^(SNRdB/10)/sel_ant;   
      rand('seed',1); randn('seed',1);  cum = 0;
      for i=1:MaxIter
         H = (randn(NR,NT)+j*randn(NR,NT))/sq2;
         if sel_ant>NT|sel_ant<1
           error('sel_ant must be between 1 and NT!');
          else   indices = nchoosek([1:NT],sel_ant); 
         end
         for n=1:size(indices,1)
            Hn = H(:,indices(n,:)); 
            log_SH(n)=log2(real(det(I+SNR_sel_ant*Hn*Hn'))); % Eq.(12.22)
         end
         cum = cum + max(log_SH);
      end
      sel_capacity(i_SNR) = cum/MaxIter;
   end
   plot(SNRdBs,sel_capacity,gss(sel_ant,:), 'LineWidth',2); hold on;
end
xlabel('SNR[dB]'), ylabel('bps/Hz'), grid on;
legend('sel-ant=1','sel-ant=2','sel-ant=3','sel-ant=4')