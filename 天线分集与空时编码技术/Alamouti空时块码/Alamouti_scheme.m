% Alamouti_scheme.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear; clf;
L_frame=130; N_Packets=4000; % Number of frames/packet and Number of packets 
NT=2; NR=1; b=2; 
SNRdBs=[0:2:30];  sq_NT=sqrt(NT); sq2=sqrt(2);
for i_SNR=1:length(SNRdBs)
   SNRdB=SNRdBs(i_SNR);  sigma=sqrt(0.5/(10^(SNRdB/10)));
   for i_packet=1:N_Packets
      msg_symbol=randint(L_frame*b,NT);
      tx_bits=msg_symbol.';  tmp=[];   tmp1=[];
      for i=1:NT
         [tmp1,sym_tab,P] = modulator(tx_bits(i,:),b); tmp=[tmp; tmp1];
      end
      X=tmp.'; X1=X; X2=[-conj(X(:,2)) conj(X(:,1))];
      for n=1:NT
         Hr(n,:,:)=(randn(L_frame,NT)+j*randn(L_frame,NT))/sq2;
      end
      H=reshape(Hr(n,:,:),L_frame,NT);  Habs(:,n)=sum(abs(H).^2,2);
      R1 = sum(H.*X1,2)/sq_NT + sigma*(randn(L_frame,1)+j*randn(L_frame,1));
      R2 = sum(H.*X2,2)/sq_NT + sigma*(randn(L_frame,1)+j*randn(L_frame,1));
      Z1 = R1.*conj(H(:,1)) + conj(R2).*H(:,2);
      Z2 = R1.*conj(H(:,2)) - conj(R2).*H(:,1);
      for m=1:P
         tmp = (-1+sum(Habs,2))*abs(sym_tab(m))^2;
         d1(:,m) = abs(sum(Z1,2)-sym_tab(m)).^2 + tmp;
         d2(:,m) = abs(sum(Z2,2)-sym_tab(m)).^2 + tmp;
      end
      [y1,i1]=min(d1,[],2);   S1d=sym_tab(i1).';    clear d1
      [y2,i2]=min(d2,[],2);   S2d=sym_tab(i2).';    clear d2
      Xd = [S1d S2d];   tmp1=X>0;  tmp2=Xd>0;
      noeb_p(i_packet) = sum(sum(tmp1~=tmp2));% for coded
   end % End of FOR loop for i_packet
   BER(i_SNR) = sum(noeb_p)/(N_Packets*L_frame*b);
end    % End of FOR loop for i_SNR
semilogy(SNRdBs,BER), axis([SNRdBs([1 end]) 1e-6 1e0]); 
grid on;  xlabel('SNR[dB]'); ylabel('BER');
