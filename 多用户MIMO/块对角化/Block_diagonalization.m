% Block_diagonalization.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all; clf
N_frame=10; N_packet=200; % Number of frames/packet and Number of packets
b=2; % Number of bits per QPSK symbol
NT=4;  NR=2;  N_user=2;  
N_pbits = N_frame*NT*b; % Number of bits in a packet
N_tbits = N_pbits*N_packet; % Number of total bits
SNRdBs = [0:2:30]; sq2=sqrt(2);
for i_SNR=1:length(SNRdBs)
   SNRdB=SNRdBs(i_SNR); N_ebits=0; rand('seed',1); randn('seed',1);
   sigma2 = NT*0.5*10^(-SNRdB/10); sigma = sqrt(sigma2);
   for i_packet=1:N_packet
      msg_bit = randint(1,N_pbits); % bit generation
      symbol = QPSK_mapper(msg_bit).';
      x = reshape(symbol,NT,N_frame); 
      H1 = (randn(NR,NT)+j*randn(NR,NT))/sq2;
      H2 = (randn(NR,NT)+j*randn(NR,NT))/sq2;
      [U1,S1,V1] = svd(H1); W2 = V1(:,3:4);
      [U2,S2,V2] = svd(H2); W1 = V2(:,3:4);     
      Tx_Data = W1*x(1:2,:) + W2*x(3:4,:);
      Rx1 = H1*Tx_Data + sigma*(randn(2,N_frame)+j*randn(2,N_frame));
      Rx2 = H2*Tx_Data + sigma*(randn(2,N_frame)+j*randn(2,N_frame));            
      W1_H1=H1*W1;
      EQ1 = W1_H1'*inv(W1_H1*W1_H1'); % Equalizer for the 1st user
      W2_H2=H2*W2;
      EQ2 = W2_H2'*inv(W2_H2*W2_H2'); % Equalizer for the 2nd user
      y = [EQ1*Rx1; EQ2*Rx2];
      symbol_hat = reshape(y,NT*N_frame,1);
      symbol_sliced = QPSK_slicer(symbol_hat);
      demapped = QPSK_demapper(symbol_sliced);
      N_ebits = N_ebits + sum(msg_bit~=demapped); 
   end
   BER(i_SNR) = N_ebits/N_tbits;
end
semilogy(SNRdBs,BER,'-o'), grid on
