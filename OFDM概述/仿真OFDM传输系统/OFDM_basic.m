% OFDM_basic.m
clear all
NgType=1; % NgType=1/2 for cyclic prefix/zero padding
if NgType==1
    nt='CP';  
elseif NgType==2
    nt='ZP';   
end
Ch=0;  % Ch=0/1 for AWGN/multipath channel
if Ch==0
    chType='AWGN'; 
    Target_neb=100; 
else
    chType='CH'; 
    Target_neb=500; 
end
figure(Ch+1), clf
PowerdB=[0 -8 -17 -21 -25]; % Channel tap power profile 'dB'
Delay=[0 3 5 6 8];          % Channel delay 'sample'
Power=10.^(PowerdB/10);     % Channel tap power profile 'linear scale'
Ntap=length(PowerdB);       % Chanel tap number
Lch=Delay(end)+1;           % Channel length
Nbps=4; 
M=2^Nbps;                   % Modulation order=2/4/6 for QPSK/16QAM/64QAM
Nfft=64;                    % FFT size                    
Ng=Nfft/4;                  % Guard interval length
Nsym=Nfft+Ng;               % Symbol duration
Nvc=Nfft/4;                 % Nvc=0: no virtual carrier
Nused=Nfft-Nvc;
EbN0=[0:5:20];    % EbN0
N_iter=1e5;       % Number of iterations for each EbN0
Nframe=3;         % Number of symbols per frame
sigPow=0;         % Signal power initialization
file_name=['OFDM_BER_' chType '_' nt '_' 'GL' num2str(Ng) '.dat'];
fid=fopen(file_name, 'w+');
norms=[1 sqrt(2) 0 sqrt(10) 0 sqrt(42)];     % BPSK 4-QAM 16-QAM
for i=0:length(EbN0)
   randn('state',0);
   rand('state',0); 
   %Ber2=ber(); % BER initialization  
   Neb=0;
   Ntb=0; % Initialize the number of error/total bits
   for m=1:N_iter
      % Tx______________________________________________________________
      X= randint(1,Nused*Nframe,M); % bit: integer vector
      Xmod= qammod(X,M,0,'gray')/norms(Nbps);
      if NgType~=2
          x_GI=zeros(1,Nframe*Nsym);
       elseif NgType==2
           x_GI= zeros(1,Nframe*Nsym+Ng);
        % Extend an OFDM symbol by Ng zeros 
      end
      kk1=[1:Nused/2]; 
      kk2=[Nused/2+1:Nused];
      kk3=1:Nfft; 
      kk4=1:Nsym;
      for k=1:Nframe
         if Nvc~=0
             X_shift= [0 Xmod(kk2) zeros(1,Nvc-1) Xmod(kk1)];
         else
             X_shift= [Xmod(kk2) Xmod(kk1)];
         end
         x= ifft(X_shift);
         x_GI(kk4)= guard_interval(Ng,Nfft,NgType,x);
         kk1=kk1+Nused; 
         kk2=kk2+Nused;
         kk3=kk3+Nfft; 
         kk4=kk4+Nsym;
      end
      if Ch==0
          y= x_GI;  % No channel
      else  % Multipath fading channel
        channel=(randn(1,Ntap)+j*randn(1,Ntap)).*sqrt(Power/2);
        h=zeros(1,Lch);
        h(Delay+1)=channel; % cir: channel impulse response
        y = conv(x_GI,h); 
      end
      if i==0 % Only to measure the signal power for adding AWGN noise
        y1=y(1:Nframe*Nsym); 
        sigPow = sigPow + y1*y1';
        continue;
      end
      % Add AWGN noise________________________________________________
      snr = EbN0(i)+10*log10(Nbps*(Nused/Nfft)); % SNR vs. Eb/N0
      noise_mag = sqrt((10.^(-snr/10))*sigPow/2);
      y_GI = y + noise_mag*(randn(size(y))+j*randn(size(y)));
      % Rx_____________________________________________________________
      kk1=(NgType==2)*Ng+[1:Nsym];
      kk2=1:Nfft;
      kk3=1:Nused;
      kk4=Nused/2+Nvc+1:Nfft;
      kk5=(Nvc~=0)+[1:Nused/2];
      if Ch==1
         H= fft([h zeros(1,Nfft-Lch)]); % Channel frequency response
         H_shift(kk3)= [H(kk4) H(kk5)]; 
      end
      for k=1:Nframe
         Y(kk2)= fft(remove_GI(Ng,Nsym,NgType,y_GI(kk1)));
         Y_shift=[Y(kk4) Y(kk5)];
         if Ch==0
             Xmod_r(kk3) = Y_shift;
         else
             Xmod_r(kk3)= Y_shift./H_shift;  % Equalizer - channel compensation
         end
         kk1=kk1+Nsym; 
         kk2=kk2+Nfft;
         kk3=kk3+Nused;
         kk4=kk4+Nfft; 
         kk5=kk5+Nfft;
      end
      X_r=qamdemod(Xmod_r*norms(Nbps),M,0,'gray');
      Neb=Neb+sum(sum(de2bi(X_r,Nbps)~=de2bi(X,Nbps)));
      Ntb=Ntb+Nused*Nframe*Nbps;  %[Ber,Neb,Ntb]=ber(bit_Rx,bit,Nbps); 
      if Neb>Target_neb
          break;
      end
   end
   if i==0
     sigPow= sigPow/Nsym/Nframe/N_iter;
     fprintf('Signal power= %11.3e\n', sigPow);
     fprintf(fid,'%%Signal power= %11.3e\n%%EbN0[dB]       BER\n', sigPow);
    else
     Ber = Neb/Ntb;     
     fprintf('EbN0=%3d[dB], BER=%4d/%8d =%11.3e\n', EbN0(i), Neb,Ntb,Ber)
     fprintf(fid, '%d\t%11.3e\n', EbN0(i), Ber);
     if Ber<1e-6
         break;  
     end
   end
end
if (fid~=0)
    fclose(fid);  
end
disp('Simulation is finished');
plot_ber(file_name,Nbps);