%single_carrier_PAPR.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear
Ts = 1; Nos = 8; Fc = 1;  bits = [1 2 4]; %bits=2;
for i_b = 1:length(bits)
   b = bits(i_b); 
   M = 2^b;
   if b==1
       Mod='BPSK'; 
       mod_object = modem.pskmod('M',M); A=1;
    elseif b==2
        Mod='QPSK'; 
        mod_object = modem.pskmod('M',M,'PhaseOffset',pi/4); 
        A=1;
   else
       Mod=[num2str(2^b) 'QAM']; 
       mod_object = modem.qammod('M',M); 
       Es=1;
       A=sqrt(3/2/(M-1)*Es); 
   end
   msgint=[0:M-1];
   X=A*modulate(mod_object,msgint);
   [X,Mod] = mapper(b); 
   %Nos_=16; [out_,xr_,xi_,time_] = modulation0(inI,inQ,M,Ts,Nos_,Fc);
   Nos_=Nos*8; 
   [xt_pass_,time_] = modulation(X,Ts,Nos_,Fc);
   %Nos=4; [out,xr_,xi_,time] = modulation0(inI,inQ,M,Ts,Nos,Fc);
   [xt_pass,time] = modulation(X,Ts,Nos,Fc);
   for i_s = 1:M
      %xt_base(Nos*(i_s-1)*2+1:Nos*i_s*2) = X(i_s)*ones(1,Nos*2);
      %xt_base(Nos_/2*(i_s-1)+1:Nos_/2*i_s) = X(i_s)*ones(1,Nos_/2);
      xt_base(Nos*(i_s-1)+1:Nos*i_s) = X(i_s)*ones(1,Nos);
   end
   PAPR_dB_base(i_b) = PAPR(xt_base);
   figure(2*i_b-1);  clf;
   subplot(311), stem(time,real(xt_base),'k.'); hold on;  ylabel('S_{I}(n)');
   title([Mod ', ' num2str(M) ' symbols, Ts=' num2str(Ts) 's, Fs=' num2str(1/Ts*2*Nos) 'Hz, Nos=' num2str(Nos) ', baseband, g(n)=u(n)-u(n-Ts)']);
   subplot(312), stem(time,imag(xt_base),'k.'); hold on; ylabel('S_{Q}(n)');
   subplot(313), stem(time,abs(xt_base).^2,'k.'); hold on;
   title(['PAPR = ' num2str(round(PAPR_dB_base(i_b)*100)/100) 'dB']);
   xlabel ('samples'); ylabel('|S_{I}(n)|^{2}+|S_{Q}(n)|^{2}');    
   figure(2*i_b), clf;   
   PAPR_dB_pass(i_b) = PAPR(xt_pass);
   %[deMi, deMq, detime] = demodulation(out, Ts, Nos, Fc);
   subplot(211), stem(time,xt_pass,'k.'); hold on; plot(time_,xt_pass_,'k:');
   title([Mod ', ' num2str(M) ' symbols, Ts=' num2str(Ts) 's, Fs=' num2str(1/Ts*2*Nos) 'Hz, Nos=' num2str(Nos) ', Fc=' num2str(Fc) 'Hz, g(n)=u(n)-u(n-Ts)']);
   ylabel('S(n)');
   subplot(212)
   stem(time,xt_pass.*xt_pass,'r.'); hold on; plot(time_,xt_pass_.*xt_pass_,'k:');
   title(['PAPR = ' num2str(round(PAPR_dB_pass(i_b)*100)/100) 'dB']);
   xlabel('samples'); ylabel('|S(n)|^{2}');    
   %bb_I = zeros(1,M*Nos*2); bb_Q = zeros(1,M*Nos*2);
end
disp('PAPRs of baseband/passband signals'); 
PAPRs_of_baseband_passband_signals=[PAPR_dB_base; PAPR_dB_pass]