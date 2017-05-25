% CCDF_of_clipped_filtered_OFDM_signal.m
% Plot Fig. 7.16
clear, clf
SNRdBs=[0:10];  N_SNR=length(SNRdBs); % SNR[dB] vector 
Nblk=100; CRs=[0.8:0.2:1.6]; N_CR=length(CRs); gss='*^<sd>v';
b = 2; M = 2^b;  % Number of bits per QAM symbol and Alphabet size
N = 128; Ncp = 0;  % FFT size and CP size (GI length)
fs = 1e6; L = 8; % Sampling frequency and Oversampling factor
Tsym=1/(fs/N); Ts=1/(fs*L); % OFDM symbol period and Sampling period
fc = 2e6;  wc = 2*pi*fc; % Carrier frequency
t = [0:Ts:2*Tsym-Ts]/Tsym;
if b==1, Mod='BPSK'; elseif b==2, Mod='QPSK'; else Mod=[num2str(M) 'QAM']; end
% const = qammod([0:M-1],M);         % QAM modulation
A = modnorm(qammod([0:M-1],M),'avpow',1); % Normalization factor
mdmod = modem.qammod('M',M, 'SymbolOrder','Gray','InputType','Bit');
mddem = modem.qamdemod('M',M, 'SymbolOrder','Gray','OutputType','Bit');
%Hd = euqiripple_filter_fin; Fcoeff = Hd.numerator; Lcoeff = length(Fcoeff);
Fs=8; Norder=104; dens=20; % Sampling frequency, Order, and Density factor of filter
FF=[0 1.4 1.5 2.5 2.6 Fs/2]; % Stopband/Passband/Stopband frequency edge vector
WW=[10 1 10]; % Stopband/Passband/Stopband weight vector
h = firpm(Norder,FF/(Fs/2),[0 0 1 1 0 0],WW,{dens}); % BPF coefficients
Clipped_errCnt = zeros(size(CRs)); ClippedFiltered_errCnt = zeros(size(CRs));
CF = zeros(1,Nblk); CF_c = zeros(N_CR,Nblk); CF_cf = zeros(N_CR,Nblk);
% ------------- Iteration with increasing SNRdB --------------------%
ber_analytic = berawgn(SNRdBs-10*log10(b),'qam',M);
kk1=1:(N/2-Ncp)*L; kk2=kk1(end)+1:N/2*L+N*L; kk3=kk2(end)+[1:N*L/2];
z = [2:0.1:16];  len_z = length(z);
for i = 1:N_SNR
   SNRdB = SNRdBs(i);
   for ncf = 0:2 % no/clip/clip&filter
      if ncf==2, m=ceil(length(h)/2); else m=1; end
      for cr = 1:N_CR
         if ncf==0&cr>1, break; end
         CR = CRs(cr);  nobe = 0;      
         for nblk = 1:Nblk %(i)
            msgbin = randint(b,N);   % binary squences
            X = A*modulate(mdmod,msgbin); % 4QAM (QPSK) mapper
            X(1) = 0+j*0;    % DC subcarrier not used
            x = IFFT_oversampling(X,N,L);
            x_b = add_CP(x,Ncp*L);
            x_b_os = [zeros(1,(N/2-Ncp)*L), x_b, zeros(1,N*L/2)];
            x_p = sqrt(2)*real(x_b_os.*exp(j*2*wc*t));
            if ncf>0, x_p_c = clipping(x_p,CR); x_p=x_p_c;     % clipping   
              if ncf>1, x_p_cf = ifft(fft(h,length(x_p)).*fft(x_p)); x_p=x_p_cf; end
            end
            if i==N_SNR, CF(nblk) = PAPR(x_p);  end
            y_p_n = [x_p(kk1) awgn(x_p(kk2),SNRdB,'measured') x_p(kk3)]; % add Noise(AWGN)  
            y_b = sqrt(2)*y_p_n.*exp(-j*2*wc*t); 
            Y_b = fft(y_b);
            y_b_z = ifft(zero_pasting(Y_b));   
            y_b_t = y_b_z((N/2-Ncp)*L+m+[0:L:(N+Ncp)*L-1]);
            Y_b_f = fft(y_b_t(Ncp+1:end),N)*L;
            Y_b_bin = demodulate(mddem,Y_b_f);
            nobe = nobe + biterr(msgbin(:,2:end),Y_b_bin(:,2:end)); 
            %Clipped_errCnt(cr) = Clipped_errCnt(cr) + nobe;
         end % End of the nblk loop 
         if ncf==0, ber_no(i) = nobe/Nblk/(N-1)/b;
          elseif ncf==1, ber_c(cr,i) = nobe/Nblk/(N-1)/b;
          else  ber_cf(cr,i) = nobe/Nblk/(N-1)/b;
         end
         if i==N_SNR
           for iz=1:len_z,  CCDF(iz) = sum(CF>z(iz))/Nblk;  end
           if ncf==0,  CCDF_no = CCDF;  break;
            elseif ncf==1, CCDF_c(cr,:) = CCDF;
            else  CCDF_cf(cr,:) = CCDF;
           end
         end
      end
   end
end
subplot(221), semilogy(z,CCDF_no), grid on, hold on
for cr = 1:N_CR
   gs = gss(cr);
   subplot(221), semilogy(z,CCDF_c(cr,:),[gs '-'], z,CCDF_cf(cr,:),[gs ':']), hold on
   subplot(222), semilogy(SNRdBs,ber_c(cr,:),[gs '-'], SNRdBs,ber_cf(cr,:),[gs ':']), hold on
end 
semilogy(SNRdBs,ber_no,'o', SNRdBs,ber_analytic,'k'), grid on