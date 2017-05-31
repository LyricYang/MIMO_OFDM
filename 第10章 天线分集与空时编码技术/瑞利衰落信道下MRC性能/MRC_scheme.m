% MRC_scheme.m
% Receiver diversity - MRC 
clear, clf
L_frame=130;
N_packet=4000; 
b=2;                % Set to 1/2/3/4 for BPSK/QPSK/16QAM/64QAM
SNRdBs=[0:2:20]; 
sq2=sqrt(2);
%SNRdBs=[0:10:20]; sq2=sqrt(2);
for iter=1:3
   if iter==1
       NT=1;
       NR=1; 
       gs='-kx'; % SISO
    elseif iter==2
        NT=1; 
        NR=2; 
        gs='-^'; 
   else
       NT=1;
       NR=4; 
       gs='-ro'; 
   end
   sq_NT=sqrt(NT);
   for i_SNR=1:length(SNRdBs)
      SNRdB=SNRdBs(i_SNR);  
      sigma=sqrt(0.5/(10^(SNRdB/10)));
      for i_packet=1:N_packet
         symbol_data=randi([0,1],L_frame*b,NT);
         [temp,sym_tab,P]=modulator(symbol_data.',b);
         X=temp.';
         Hr = (randn(L_frame,NR)+j*randn(L_frame,NR))/sq2;
         H = reshape(Hr,L_frame,NR);
         Habs = sum(abs(H).^2,2); 
         Z=0;
         for i=1:NR
            R(:,i) = sum(H(:,i).*X,2)/sq_NT + sigma*(randn(L_frame,1)+j*randn(L_frame,1));
            Z = Z + R(:,i).*conj(H(:,i));
         end
         for m=1:P
            d1(:,m)=abs(sum(Z,2)-sym_tab(m)).^2+(-1+sum(Habs,2))*abs(sym_tab(m))^2;
         end
         [y1,i1] = min(d1,[],2);  
         Xd=sym_tab(i1).';
         temp1 = X>0;  
         temp2 = Xd>0;
         noeb_p(i_packet)=sum(sum(temp1~=temp2));
      end
      BER(iter,i_SNR) = sum(noeb_p)/(N_packet*L_frame*b);
   end
   semilogy(SNRdBs,BER(iter,:),gs);
   hold on;
   axis([SNRdBs([1 end]) 1e-6 1e0])
end
title('BER perfoemancde of MRC Scheme');
xlabel('SNR[dB]');
ylabel('BER') 
grid on;
set(gca,'fontsize',9)
legend('SISO','MRC (Tx:1,Rx:2)','MRC (Tx:1,Rx:4)')
