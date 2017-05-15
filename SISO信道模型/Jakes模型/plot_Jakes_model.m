close all, clear all
% initial parameter
fd= 55.53;%多谱勒频率
Ts= 1e-6;%采样周期
M= 2^12;
t= [0:M-1]*Ts;
f= [-M/2:M/2-1]/(M*Ts*fd);
Ns= 50000;
t_state= 0;
% channel generation
[h,t_state]=Jakes_Flat(fd,Ts,Ns,t_state,1,0);
% plotting
subplot(311)
plot([1:Ns]*Ts,10*log10(abs(h)))
axis([0 Ns*Ts -20 10])
title(['Channel Modeled by Jakes, f_d=',num2str(fd),'Hz, T_s=',num2str(Ts),'s']);
xlabel('time[s]');
ylabel('Magnitude[dB]');
subplot(323)
hist(abs(h),50);
title(['Channel Modeled by Jakes, f_d=',num2str(fd),'Hz, T_s=',num2str(Ts),'s']);
xlabel('Magnitude');
ylabel('Occasions');
subplot(324)
hist(angle(h),50);
title(['Channel Modeled by Jakes, f_d=',num2str(fd),'Hz, T_s=',num2str(Ts),'s']);
xlabel('Phase[rad]');
ylabel('Occasions');
% Autocorrelation of channel
temp=zeros(2,Ns);
for i=1:Ns
   j=i:Ns; 
   temp1(1:2,j-i+1)= temp(1:2,j-i+1)+[h(i)'*h(j); ones(1,Ns-i+1)];
end
k=1:M; 
Simulated_corr(k)= real(temp(1,k))./temp(2,k);
Classical_corr= besselj(0,2*pi*fd*t);
% Fourier transform of autocorrelation
Classical_Y= fftshift(fft(Classical_corr));
Simulated_Y= fftshift(fft(Simulated_corr));
% plotting
subplot(325)
plot(t,abs(Classical_corr),'b:', t,abs(Simulated_corr),'r:');
title(['Autocorrelation of Channel, f_d=',num2str(fd),'Hz']);
grid on, xlabel('delay \tau [s]');
ylabel('Correlation');
legend('Classical','Simulated');
subplot(326)
plot(f,abs(Classical_Y),'b:', f,abs(Simulated_Y),'r:');
title(['Doppler Spectrum,f_d=',num2str(fd),'Hz']);
axis([-1 1 0 600]);
xlabel('f/f_d');
ylabel('Magnitude');
legend('Classical','Simulated');