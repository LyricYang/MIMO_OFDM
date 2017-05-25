% Dirty_or_TH_precoding.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all; clf
mode = 0; % Set to 0/1 for Dirty/TH precoding 
N_frame=10; % Number of frames in a packet, 1 frame=4 symbols 
N_packet=200; % Number of packets
b=2; % Number of bits per QPSK symbol
NT=4; N_user=10; N_act_user=4; I=eye(N_act_user,NT); 
N_pbits = N_frame*NT*b; % Number of bits in a packet
N_tbits = N_pbits*N_packet; % Number of total bits
SNRdBs=[0:2:20]; sq2=sqrt(2);
for i_SNR=1:length(SNRdBs)
   SNRdB = SNRdBs(i_SNR); N_ebits = 0; rand('seed',1); randn('seed',1);
   sigma2 = NT*0.5*10^(-SNRdB/10); sigma = sqrt(sigma2);
   %------------- Transmitter ----------------
   for i_packet=1:N_packet
      msg_bit = randint(1,N_pbits); % Bit generation
      symbol = QPSK_mapper(msg_bit).';
      x = reshape(symbol,NT,N_frame); 
      H = (randn(N_user,NT)+j*randn(N_user,NT))/sq2;
      %----- user selection ----------
      Combinations = nchoosek([1:N_user],N_act_user)';
      for i=1:size(Combinations,2)
         H_used = H(Combinations(:,i),:);
         [Q_temp, R_temp] = qr(H_used);
         %diagonal entries of R_temp are real
         minimum_l(i) = min(diag(R_temp));
      end
      [max_min_l,Index] = max(minimum_l);
      H_used = H(Combinations(:,Index),:);
      [Q_temp,R_temp] = qr(H_used');
      L=R_temp'; Q=Q_temp';
      xp = x;
      if mode==0  % Dirty precoding
         for m=2:4
            xp(m,:) = xp(m,:) - L(m,1:m-1)/L(m,m)*xp(1:m-1,:);
         end
       else  % TH precoding
        for m=2:4
           xp(m,:) = modulo(xp(m,:)-L(m,1:m-1)/L(m,m)*xp(1:m-1,:),sq2);
        end
      end
      Tx_signal = Q'*xp; % DPC/TH encoder
      %------------ Channel and Noise ----------------        
      Rx_signal = H_used*Tx_signal + ...
          sigma*(randn(N_act_user,N_frame)+j*randn(N_act_user,N_frame));
      %------------ Receiver ----------------
      y = inv(diag(diag(L)))*Rx_signal;
      symbol_hat = reshape(y,NT*N_frame,1);
      if mode==1 % in the case of TH precoding
        symbol_hat = modulo(symbol_hat,sq2);
      end
      symbol_sliced = QPSK_slicer(symbol_hat);
      demapped = QPSK_demapper(symbol_sliced);      
      N_ebits = N_ebits + sum(msg_bit~=demapped);
   end
   BER(i_SNR) = N_ebits/N_tbits; 
end
semilogy(SNRdBs,BER,'-x'), grid on