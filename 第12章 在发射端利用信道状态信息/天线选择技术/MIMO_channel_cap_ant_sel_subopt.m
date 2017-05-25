% MIMO_channel_cap_ant_sel_subopt.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all; clf
sel_ant=2; % Number of antennas to select 
sel_method=0; % 0/1 for increasingly/decreasingly ordered selection
NT=4; NR=4; % Number of transmit/receive antennas
I=eye(NR,NR); sq2=sqrt(2);
SNRdBs = [0:10];  MaxIter=1000;   
for i_SNR=1:length(SNRdBs)
   SNRdB = SNRdBs(i_SNR);  
   SNR_sel_ant = 10^(SNRdB/10)/sel_ant;   
   rand('seed',1); randn('seed',1);  cum = 0;
   for i=1:MaxIter
      if sel_method==0
        sel_ant_indices=[];  rem_ant_indices=[1:NT];
       else 
        sel_ant_indices=[1:NT];  del_ant_indices=[];
      end
      H = (randn(NR,NT)+j*randn(NR,NT))/sq2;
      if sel_method==0 %increasingly ordered selection method
        for current_sel_ant_number=1:sel_ant
          clear log_SH;
           for n=1:length(rem_ant_indices)
              Hn = H(:,[sel_ant_indices rem_ant_indices(n)]); 
              log_SH(n) = log2(real(det(I+SNR_sel_ant*Hn*Hn')));
           end
           maximum_capacity = max(log_SH);
           selected = find(log_SH==maximum_capacity);
           sel_ant_index = rem_ant_indices(selected);
           rem_ant_indices = [rem_ant_indices(1:selected-1) rem_ant_indices(selected+1:end)];    
           sel_ant_indices = [sel_ant_indices sel_ant_index];
        end
       else %decreasingly ordered selection method
        for current_del_ant_number=1:NT-sel_ant
           clear log_SH;
           for n=1:length(sel_ant_indices)
              Hn = H(:,[sel_ant_indices(1:n-1) sel_ant_indices(n+1:end)]); 
              log_SH(n) = log2(real(det(I+SNR_sel_ant*Hn*Hn'))); 
           end
           maximum_capacity = max(log_SH);
           selected = find(log_SH==maximum_capacity);
           sel_ant_indices = [sel_ant_indices(1:selected-1) sel_ant_indices(selected+1:end)];                    
        end
     end
      cum = cum + maximum_capacity;
   end
   sel_capacity(i_SNR) = cum/MaxIter;
end
plot(SNRdBs,sel_capacity,'-ko', 'LineWidth',2); hold on;
xlabel('SNR[dB]'), ylabel('bps/Hz'), grid on;
title('Capacity of suboptimally selected antennas')
