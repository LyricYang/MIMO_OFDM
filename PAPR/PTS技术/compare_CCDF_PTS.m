% compare_CCDF_PTS.m
% Plot Fig. 7.20

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear, figure(2), clf
N=256; Nos=4; NNos=N*Nos;  
b=4; M=2^b; % Number of bits per QAM symbol and Alphabet size
Nsbs = [1,2,4,8,16]; gss='*^<sd>v.'; % Numbers of subblocks and graphic symbols
dBs = [4:0.1:11]; dBcs = dBs+(dBs(2)-dBs(1))/2;
Nblk = 3000; % Number of OFDM blocks for iteration
rand('twister',5489); randn('state',0);
CCDF_OFDMa = CCDF_OFDMA(N,Nos,b,dBs,Nblk);
semilogy(dBs,CCDF_OFDMa,'k'), hold on
for k = 1:length(Nsbs)
   Nsb=Nsbs(k); str(k,:)=sprintf('No of subblocks=%2d',Nsb);
   CCDF=CCDF_PTS(N,Nos,Nsb,b,dBs,Nblk);
   semilogy(dBs,CCDF,['-' gss(k)]) 
end
legend(str(1,:),str(2,:),str(3,:),str(4,:),str(5,:))
axis([dBs([1 end]) 1e-3 1]); grid on; 
title([num2str(M),'-QAM CCDF of OFDMA, ',num2str(N),'-point ',num2str(Nblk) '-blocks']);
xlabel('PAPR_0 [dB]'); ylabel('Pr(PAPR>PAPR_0)'); 