%Ergodic_Capacity_Correlation.m
% Capacity reduction due to correlation of the MIMO channels

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all, close all;
SNR_dB=[0:5:20];  SNR_linear=10.^(SNR_dB/10);
N_iter=1000;  N_SNR=length(SNR_dB);
%%----------------- 4x4 -----------------------------
nT=4;  nR=4;  n=min(nT,nR);  I = eye(n);  sq2=sqrt(0.5);
R=[1                      0.76*exp(0.17j*pi)   0.43*exp(0.35j*pi)    0.25*exp(0.53j*pi);
   0.76*exp(-0.17j*pi)   1                     0.76*exp(0.17j*pi)    0.43*exp(0.35j*pi);
   0.43*exp(-0.35j*pi)   0.76*exp(-0.17j*pi)   1                     0.76*exp(0.17j*pi);
   0.25*exp(-0.53j*pi)   0.43*exp(-0.35j*pi)   0.76*exp(-0.17j*pi)   1                  ];
C_44_iid=zeros(1,N_SNR);  C_44_corr=zeros(1,N_SNR);
for iter=1:N_iter
   H_iid = sq2*(randn(nR,nT)+j*randn(nR,nT));
   H_corr = H_iid*R^(1/2);
   tmp1 = H_iid'*H_iid/nT;  tmp2 = H_corr'*H_corr/nT;
   for i=1:N_SNR
      C_44_iid(i) = C_44_iid(i) + log2(det(I+SNR_linear(i)*tmp1));
      C_44_corr(i) = C_44_corr(i) + log2(det(I+SNR_linear(i)*tmp2));
   end
end
C_44_iid = real(C_44_iid)/N_iter;  C_44_corr = real(C_44_corr)/N_iter;
plot(SNR_dB,C_44_iid, SNR_dB,C_44_corr,':');
xlabel('SNR [dB]'); ylabel('bps/Hz'); set(gca,'fontsize',10)
legend('iid 4x4 channels','correlated 4x4 channels');