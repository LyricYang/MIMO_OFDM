% STBC_3x4_simulation.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear; clf;
L_frame=130; N_packets=4000;  
NT=3; NR=4; b=2; M=2^b;
SNRdBs=[0:2:30];  sq_NT=sqrt(NT);  sq2=sqrt(2);
for i_SNR=1:length(SNRdBs)
   SNRdB=SNRdBs(i_SNR);  sigma=sqrt(0.5/(10^(SNRdB/10)));
   for i_packet=1:N_packets
      msg_symbol=randint(L_frame*b,M);
      tx_bits=msg_symbol.'; temp=[]; temp1=[];
      for i=1:4
         [temp1,sym_table,P]=modulator(tx_bits(i,:),b); temp=[temp; temp1];
      end            
      X=temp.'; 
      % Block signals in the l-th time slot % Block coding for G3 STBC 
      X1=X(:,1:3);  X5=conj(X1); 
      X2 = [-X(:,2)  X(:,1) -X(:,4)];  X6=conj(X2); 
      X3 = [-X(:,3)  X(:,4)  X(:,1)];  X7=conj(X3);
      X4 = [-X(:,4) -X(:,3)  X(:,2)];  X8=conj(X4);
      for n=1:NT     
         Hr(n,:,:)=(randn(L_frame,NT)+j*randn(L_frame,NT))/sq2;
      end
      for n=1:NT
         H = reshape(Hr(n,:,:),L_frame,NT);  Hc=conj(H);
         Habs(:,n) = sum(abs(H).^2,2);
         R1n = sum(H.*X1,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         R2n = sum(H.*X2,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         R3n = sum(H.*X3,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         R4n = sum(H.*X4,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         R5n = sum(H.*X5,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         R6n = sum(H.*X6,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         R7n = sum(H.*X7,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         R8n = sum(H.*X8,2)/sq_NT+sigma*(randn(L_frame,1)+j*randn(L_frame,1));
         Z1_1 = R1n.*Hc(:,1) + R2n.*Hc(:,2) + R3n.*Hc(:,3);
         Z1_2 = conj(R5n).*H(:,1) + conj(R6n).*H(:,2) + conj(R7n).*H(:,3);
         Z(:,n,1) = Z1_1 + Z1_2;
         Z2_1 = R1n.*Hc(:,2) - R2n.*Hc(:,1) + R4n.*Hc(:,3);
         Z2_2 = conj(R5n).*H(:,2) - conj(R6n).*H(:,1) + conj(R8n).*H(:,3);
         Z(:,n,2) = Z2_1 + Z2_2;
         Z3_1 = R1n.*Hc(:,3)- R3n.*Hc(:,1)-R4n.*Hc(:,2);
         Z3_2 = conj(R5n).*H(:,3)-conj(R7n).*H(:,1)-conj(R8n).*H(:,2);
         Z(:,n,3) = Z3_1 + Z3_2;
         Z4_1 = -R2n.*Hc(:,3) + R3n.*Hc(:,2) - R4n.*Hc(:,1);
         Z4_2 = -conj(R6n).*H(:,3) + conj(R7n).*H(:,2)- conj(R8n).*H(:,1);
         Z(:,n,4) = Z4_1 + Z4_2;
      end
      for m=1:P
         tmp = (-1+sum(Habs,2))*abs(sym_table(m))^2;
         for i=1:4
            d(:,m,i) = abs(sum(Z(:,:,i),2)-sym_table(m)).^2 + tmp;
         end
      end
      Xd = [];
      for n=1:4, [yn,in]=min(d(:,:,n),[],2); Xd = [Xd sym_table(in).']; end
      temp1=X>0;   temp2=Xd>0;
      noeb_p(i_packet) = sum(sum(temp1~=temp2));
   end% end of FOR loop for "i_packet"
   BER(i_SNR) = sum(noeb_p)/(N_packets*L_frame*b);
end% end of FOR loop for SNR
semilogy(SNRdBs,BER,'b'), axis([SNRdBs([1 end]) 1e-6 1e0]); 
grid on;  xlabel('SNR [dB]'); ylabel('BER');
