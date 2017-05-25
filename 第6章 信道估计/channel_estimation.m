%channel_estimation.m
% for LS/DFT Channel Estimation with linear/spline interpolation
clear all;  
close all; 
clf;
% figure(1), clf 
% figure(2), clf
Nfft=512; 
Ng=Nfft/8;  
Nofdm=Nfft+Ng;
Nsym=100;
Nps=32; 
Np=Nfft/Nps; 
Nd=Nfft-Np; % Pilot spacing, Numbers of pilots and data per OFDM symbol
Nbps=4; 
M=2^Nbps; % Number of bits per (modulated) symbol
mod_object = modem.qammod('M',M, 'SymbolOrder','gray');
demod_object = modem.qamdemod('M',M, 'SymbolOrder','gray');
Es=1;
A=sqrt(3/2/(M-1)*Es); % Signal energy and QAM normalization factor
%fs = 10e6;  ts = 1/fs;  % Sampling frequency and Sampling period
SNRs = [30];  
sq2=sqrt(2);
for i=1:length(SNRs)
   SNR = SNRs(i); 
   rand('seed',1); 
   randn('seed',1);
   MSE = zeros(1,6); 
   nose = 0;
   for nsym=1:Nsym
      Xp = 2*(randn(1,Np)>0)-1;    % Pilot sequence generation
      %Data = ((2*(randn(1,Nd)>0)-1) + j*(2*(randn(1,Nd)>0)-1))/sq2; % QPSK modulation
      msgint=randint(1,Nfft-Np,M);    % bit generation
      Data = modulate(mod_object,msgint)*A;
      %Data = modulate(mod_object, msgint); 
      %Data = modnorm(Data,'avpow',1)*Data;   % normalization
      ip = 0;    
      pilot_loc = [];
      for k=1:Nfft
         if mod(k,Nps)==1
            X(k) = Xp(floor(k/Nps)+1); 
            pilot_loc = [pilot_loc k]; 
            ip = ip+1;
         else
             X(k) = Data(k-ip);
         end
      end
      x = ifft(X,Nfft);                            % IFFT
      xt = [x(Nfft-Ng+1:Nfft) x];                  % Add CP
      h = [(randn+j*randn) (randn+j*randn)/2];     % generates a (2-tap) channel
      H = fft(h,Nfft); 
      channel_length = length(h); % True channel and its time-domain length
      H_power_dB = 10*log10(abs(H.*conj(H)));      % True channel power in dB
      y_channel = conv(xt, h);                     % Channel path (convolution)
      sig_pow = mean(y_channel.*conj(y_channel));
      %y_aw(1,1:Nofdm) = y(1,1:Nofdm) + ...
      %   sqrt((10.^(-SNR/10))*sig_pow/2)*(randn(1,Nofdm)+j*randn(1,Nofdm)); % Add noise(AWGN)
      yt = awgn(y_channel,SNR,'measured');  
      y = yt(Ng+1:Nofdm);                   % Remove CP
      Y = fft(y);                           % FFT
      for m=1:3
         if m==1
             H_est = LS_CE(Y,Xp,pilot_loc,Nfft,Nps,'linear'); 
             method='LS-linear'; % LS estimation with linear interpolation
         elseif m==2
             H_est = LS_CE(Y,Xp,pilot_loc,Nfft,Nps,'spline');
             method='LS-spline'; % LS estimation with spline interpolation
         else
             H_est = MMSE_CE(Y,Xp,pilot_loc,Nfft,Nps,h,SNR);
             method='MMSE'; % MMSE estimation
         end
         H_est_power_dB = 10*log10(abs(H_est.*conj(H_est)));
         h_est = ifft(H_est); 
         h_DFT = h_est(1:channel_length); 
         H_DFT = fft(h_DFT,Nfft); % DFT-based channel estimation
         H_DFT_power_dB = 10*log10(abs(H_DFT.*conj(H_DFT)));
         if nsym==1
           figure(1)
           subplot(319+2*m)
           plot(H_power_dB,'b','linewidth',1);
           grid on; 
           hold on;
           plot(H_est_power_dB,'r:+','Markersize',4,'linewidth',1);
           %axis([0 32 -6 10])
           title(method);
           xlabel('Subcarrier Index'); 
           ylabel('Power[dB]');
           legend('True Channel',method,4);  
           set(gca,'fontsize',9)
           subplot(320+2*m)
           plot(H_power_dB,'b','linewidth',1); 
           grid on; 
           hold on;
           plot(H_DFT_power_dB,'r:+','Markersize',4,'linewidth',1); 
           %axis([0 32 -6 10])
           title([method ' with DFT']);
           xlabel('Subcarrier Index');
           ylabel('Power[dB]');
           legend('True Channel',[method ' with DFT'],4); 
           set(gca,'fontsize',9)
         end
         MSE(m) = MSE(m) + (H-H_est)*(H-H_est)';
         MSE(m+3) = MSE(m+3) + (H-H_DFT)*(H-H_DFT)';
      end
      Y_eq = Y./H_est;
      if nsym>=Nsym-10
          figure(2)
          subplot(221)
          plot(Y,'.','Markersize',5)
          axis([-1.5 1.5 -1.5 1.5])
          axis('equal')
          set(gca,'fontsize',9)
          hold on,
          subplot(222)
          plot(Y_eq,'.','Markersize',5)
          axis([-1.5 1.5 -1.5 1.5])
          axis('equal')
          set(gca,'fontsize',9)
          hold on,       
      end
      ip = 0;
      for k=1:Nfft
         if mod(k,Nps)==1
             ip=ip+1;  
         else
             Data_extracted(k-ip)=Y_eq(k); 
         end
      end
      msg_detected = demodulate(demod_object,Data_extracted/A);
      nose = nose + sum(msg_detected~=msgint);
   end   
   MSEs(i,:) = MSE/(Nfft*Nsym);
end   
Number_of_symbol_errors=nose
figure(3)%, clf
semilogy(SNRs',MSEs(:,1),'-x', SNRs',MSEs(:,3),'-o')
legend('LS-linear','MMSE')
fprintf('MSE of LS-linear/LS-spline/MMSE Channel Estimation = %6.4e/%6.4e/%6.4e\n',MSEs(end,1:3));
fprintf('MSE of LS-linear/LS-spline/MMSE Channel Estimation with DFT = %6.4e/%6.4e/%6.4e\n',MSEs(end,4:6));