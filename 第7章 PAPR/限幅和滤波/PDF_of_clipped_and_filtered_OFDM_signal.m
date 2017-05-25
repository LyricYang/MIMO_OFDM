% PDF_of_clipped_and_filtered_OFDM_signal.m
% Plot Figs. 7.14 and 7.15

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear
CR = 1.2; % Clipping Ratio
b=2; N=128; Ncp=32; fs=1e6; L=8; Tsym=1/(fs/N); Ts=1/(fs*L); 
fc=2e6; wc=2*pi*fc; % Carrier frequency
t=[0:Ts:2*Tsym-Ts]/Tsym;  t0=t((N/2-Ncp)*L);
f=[0:fs/(N*2):L*fs-fs/(N*2)]-L*fs/2;
Fs=8; Norder=104; dens=20; % Sampling frequency, Order, and Density factor of filter
FF=[0 1.4 1.5 2.5 2.6 Fs/2]; % Stopband/Passband/Stopband frequency edge vector
WW=[10 1 10]; % Stopband/Passband/Stopband weight vector
h = firpm(Norder,FF/(Fs/2),[0 0 1 1 0 0],WW,{dens}); % BPF coefficients
%Hd = dfilt.dffir(h);
X = mapper(b,N);  X(1) = 0; % QPSK modulation
x=IFFT_oversampling(X,N,L); % IFFT and oversampling
x_b=add_CP(x,Ncp*L); % Add CP
x_b_os=[zeros(1,(N/2-Ncp)*L), x_b, zeros(1,N*L/2)]; % Oversampling
%x_p = upconv_fin(2*fc,x_b_os,t); % From baseband to passband
x_p = sqrt(2)*real(x_b_os.*exp(j*2*wc*t)); % From baseband to passband
%norm(x_p-x_p1)
x_p_c = clipping(x_p,CR); % Eq.(7.18)
%X_p_c_f = filtering(h,x_p_c);
X_p_c_f= fft(filter(h,1,x_p_c)); %norm(X_p_c_f-X_p_c_f1)
%X_p_c_f = BPF_using_FFT(x_p_c,[1.5 2.5],8);
x_p_c_f = ifft(X_p_c_f);
%x_b_c_f = dwconv_fin(2*fc,x_p_c_f,t); % From passband to baseband
x_b_c_f = sqrt(2)*x_p_c_f.*exp(-j*2*wc*t); % From passband to baseband

figure(1); clf % Fig. 7.15(a), (b)
nn=(N/2-Ncp)*L+[1:N*L]; nn1=N/2*L+[-Ncp*L+1:0]; nn2=N/2*L+[0:N*L];
subplot(221)
plot(t(nn1)-t0, abs(x_b_os(nn1)),'k:'); hold on;
plot(t(nn2)-t0, abs(x_b_os(nn2)),'k-');
axis([t([nn1(1) nn2(end)])-t0  0  max(abs(x_b_os))]);
title(['Baseband signal, with CP']);
xlabel('t (normalized by symbol duration)'); ylabel('abs(x''[m])');
subplot(223)
XdB_p_os = 20*log10(abs(fft(x_b_os)));
plot(f,fftshift(XdB_p_os)-max(XdB_p_os),'k');
xlabel('frequency[Hz]'); ylabel('PSD[dB]'); axis([f([1 end]) -100 0]);
subplot(222)
[pdf_x_p,bin]=hist(x_p(nn),50); bar(bin,pdf_x_p/sum(pdf_x_p),'k');
xlabel('x'); ylabel('pdf'); title(['Unclipped passband signal']);
subplot(224)
XdB_p = 20*log10(abs(fft(x_p)));
plot(f,fftshift(XdB_p)-max(XdB_p),'k');
xlabel('frequency[Hz]'); ylabel('PSD[dB]'); axis([f([1 end]) -100 0]);

figure(2); clf % Fig. 7.15(c), (d)
subplot(221)
[pdf_x_p_c,bin] = hist(x_p_c(nn),50);
bar(bin,pdf_x_p_c/sum(pdf_x_p_c),'k');
title(['Clipped passband signal, CR=' num2str(CR)]);
xlabel('x'); ylabel('pdf');
subplot(223)
XdB_p_c = 20*log10(abs(fft(x_p_c)));
plot(f,fftshift(XdB_p_c)-max(XdB_p_c),'k');
xlabel('frequency[Hz]'); ylabel('PSD[dB]'); axis([f([1 end]) -100 0]);
subplot(222)
[pdf_x_p_c_f,bin] = hist(x_p_c_f(nn),50); 
bar(bin,pdf_x_p_c_f/sum(pdf_x_p_c_f),'k');
title(['Passband signal after clipping and filtering, CR=' num2str(CR)]);
xlabel('x'); ylabel('pdf');
subplot(224)
XdB_p_c_f = 20*log10(abs(X_p_c_f));
plot(f,fftshift(XdB_p_c_f)-max(XdB_p_c_f),'k');
xlabel('frequency[Hz]'); ylabel('PSD[dB]');
axis([f([1 end]) -100 0]);

figure(3); clf % Fig. 7.14
subplot(221)
stem(h,'k'); xlabel('tap'); ylabel('Filter coefficient h[n]');
axis([1, length(h), min(h), max(h)]);
subplot(222)
HdB = 20*log10(abs(fft(h,length(X_p_c_f))));
plot(f,fftshift(HdB),'k');
xlabel('frequency[Hz]'); ylabel('Filter freq response H[dB]');
axis([f([1 end]) -100 0]);
subplot(223)
[pdf_x_p_c_f,bin] = hist(abs(x_b_c_f(nn)),50);
bar(bin,pdf_x_p_c_f/sum(pdf_x_p_c_f),'k');
title(['Baseband signal after clipping and filtering, CR=' num2str(CR)]);
xlabel('|x|'); ylabel('pdf');
subplot(224)
XdB_b_c_f = 20*log10(abs(fft(x_b_c_f)));
plot(f,fftshift(XdB_b_c_f)-max(XdB_b_c_f),'k');
xlabel('frequency[Hz]'); ylabel('PSD[dB]'); axis([f([1 end]) -100 0]);