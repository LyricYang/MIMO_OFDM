% Ergodic_Capacity_CDF.m
% To plot Fig. 4.4 on p72 of the book
% "Introduction to Space-Time Wireless Communications", A. Paulraj, R. Nabar and D. Gore

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all, close all, figure
SNR_dB=10;  SNR_linear=10.^(SNR_dB/10.);
N_iter=50000; sq2=sqrt(0.5); grps = ['b:'; 'b-'];
for Icase=1:2 
   if Icase==1,  nT=2; nR=2;  % 2x2
    else   nT=4; nR=4;       % 4x4
   end
   n=min(nT,nR);  I = eye(n);
   for iter=1:N_iter
      H = sq2*(randn(nR,nT)+j*randn(nR,nT)); 
      C(iter) = log2(real(det(I+SNR_linear/nT*H'*H)));
   end
   [PDF,Rate] = hist(C,50);
   PDF = PDF/N_iter;
   for i=1:50, CDF(Icase,i) = sum(PDF([1:i]));  end
   plot(Rate,CDF(Icase,:),grps(Icase,:)); hold on
end
xlabel('Rate[bps/Hz]'); ylabel('CDF')
axis([1 18 0 1]); grid on; set(gca,'fontsize',10); 
legend('{\it N_T}={\it N_R}=2','{\it N_T}={\it N_R}=4');

