% pre_MMSE.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all; clf
%%%%%% Parameter Setting %%%%%%%%%
N_frame=100;  N_packet=1000;
b=2; M=2^b;  % Number of bits per symbol and Modulation order
mod_obj=modem.qammod('M',M,'SymbolOrder','Gray','InputType','bit');
demod_obj = modem.qamdemod(mod_obj);
NT=4;  NR=4;  sq2=sqrt(2);  I=eye(NR,NR);
N_pbits = N_frame*NT*b; 
N_tbits = N_pbits*N_packet;
fprintf('====================================================\n');
fprintf(' Pre-MMSE transmission');
fprintf('\n  %d x %d MIMO\n  %d QAM', NT,NR,M);
fprintf('\n  Simulation bits : %d',N_tbits);
fprintf('\n====================================================\n');
SNRdBs = [0:2:20];
for i_SNR=1:length(SNRdBs)
   SNRdB = SNRdBs(i_SNR); 
   noise_var = NT*0.5*10^(-SNRdB/10); 
   sigma = sqrt(noise_var);
   rand('seed',1); randn('seed',1);  N_ebits = 0; 
   %%%%%%%%%%%%% Transmitter %%%%%%%%%%%%%%%%%%
   for i_packet=1:N_packet
      msg_bit = randint(N_pbits,1); % bit generation
      symbol = modulate(mod_obj,msg_bit).';
      Scale = modnorm(symbol,'avpow',1); % normalization
      Symbol_nomalized = reshape(Scale*symbol,NT,N_frame); 
      H = (randn(NR,NT)+j*randn(NR,NT))/sq2;
      temp_W = H'*inv(H*H'+noise_var*I); 
      beta = sqrt(NT/trace(temp_W*temp_W')); % Eq.(12.17)
      W = beta*temp_W;  
      Tx_signal = W*Symbol_nomalized;  
      %%%%%%%%%%%%% Channel and Noise %%%%%%%%%%%%%        
      Rx_signal = H*Tx_signal+sigma*(randn(NR,N_frame)+j*randn(NR,N_frame));
      %%%%%%%%%%%%%% Receiver %%%%%%%%%%%%%%%%%%%%%
      y = Rx_signal/beta; % Eq.(12.18)
      Symbol_hat = reshape(y/Scale,NT*N_frame,1);
      msg_hat = demodulate(demod_obj,Symbol_hat);
      N_ebits = N_ebits + sum(msg_hat~=msg_bit);
   end
   BER(i_SNR) = N_ebits/N_tbits;
end
semilogy(SNRdBs,BER,'-k^','LineWidth',2); hold on; grid on;
xlabel('SNR[dB]'), ylabel('BER');
legend('Pre-MMSE transmission')
