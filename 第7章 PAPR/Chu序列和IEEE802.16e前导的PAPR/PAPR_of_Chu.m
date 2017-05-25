% PAPR_of_Chu.m
% Plot Fig. 7.10(a)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear, clf
N=16; L=4; i=[0:N-1]; 
k = 3; X = exp(j*k*pi/N*(i.*i));
[x,time] = IFFT_oversampling(X,N);
PAPRdB = PAPR(x);
[x_os,time_os] = IFFT_oversampling(X,N,L); %x_os=x_os*L;
PAPRdB_os = PAPR(x_os);
subplot(221), plot(x,'o'), hold on, plot(x_os,'k*')
axis([-0.4 0.4 -0.4 0.4]), axis('equal')
plot(0.25*exp(j*pi/180*[0:359])) % circle with radius 0.25 ??????
subplot(222), plot(time,abs(x),'o', time_os,abs(x_os),'k:*')
PAPRdB_without_and_with_oversampling=[PAPRdB  PAPRdB_os]