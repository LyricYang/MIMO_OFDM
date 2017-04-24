% multi_user_MIMO.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all;
mode = 1; % Set mode=0/1 for channel inversion or regularized channel inversion 
%%%%%% Parameter Setting %%%%%%%%%
N_frame=10; N_packet=200; % Number of frames/packet and Number of packets
b=2; % Number of bits per QPSK symbol
NT=4;  N_user=20;  N_act_user=4; I=eye(N_act_user,NT);
N_pbits = N_frame*NT*b; % Number of bits in a packet
N_tbits = N_pbits*N_packet; % Number of total bits
SNRdBs = [0:2:20]; sq2=sqrt(2);
for i_SNR=1:length(SNRdBs)
   SNRdB=SNRdBs(i_SNR); N_ebits = 0;   
   sigma2 = NT*0.5*10^(-SNRdB/10); sigma = sqrt(sigma2);
   rand('seed',1); randn('seed',1);
   for i_packet=1:N_packet
      msg_bit = randint(1,N_pbits); % Bit generation
      %%%%%%%%%%%%% Transmitter %%%%%%%%%%%%%%%%%%
      symbol = QPSK_mapper(msg_bit).';
      x = reshape(symbol,NT,N_frame); 
      for i_user=1:N_user
         H(i_user,:) = (randn(1,NT)+j*randn(1,NT))/sq2;
         Channel_norm(i_user)=norm(H(i_user,:));
      end
      [Ch_norm,Index]=sort(Channel_norm,'descend');
      %H_used=[H(Index(1),:); H(Index(2),:); H(Index(3),:); H(Index(4),:)];
      H_used = H(Index(1:N_act_user),:);
      temp_W = H_used'*inv(H_used*H_used' + (mode==1)*sigma*I);
      %if mode == 0, temp_W = H_used'*inv(H_used*H_used'); 
      % else     temp_W=H_used'*inv(H_used*H_used'+sigma2*I);
      %end
      beta = sqrt(NT/trace(temp_W*temp_W'));   W = beta*temp_W;
      Tx_signal = W*x; % Pre-equalized signal at Tx
      %%%%%%%%%%%%% Channel and Noise %%%%%%%%%%%%%        
      Rx_signal = H_used*Tx_signal + ...
        sigma*(randn(N_act_user,N_frame)+j*randn(N_act_user,N_frame));
      %%%%%%%%%%%%%% Receiver %%%%%%%%%%%%%%%%%%%%%
      x_hat = Rx_signal/beta; % Eq.(12.18)
      symbol_hat = reshape(x_hat,NT*N_frame,1);
      symbol_sliced = QPSK_slicer(symbol_hat);
      demapped = QPSK_demapper(symbol_sliced);      
      N_ebits = N_ebits + sum(msg_bit~=demapped);
      if mod(i_packet,1000)==0, fprintf('packet : %d passed\n',i_packet); end    
   end
   BER(i_SNR) = N_ebits/N_tbits; 
end
semilogy(SNRdBs,BER,'-ro'), grid on