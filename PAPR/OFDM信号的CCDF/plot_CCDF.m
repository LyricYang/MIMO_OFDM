% plot_CCDF.m
% Plot the CCDF curves of Fig. 7.3.
clear all; clc; clf
Ns = 2.^[6:10]; 
b=2; 
M=2^b; 
Nblk = 1e3;
%mod_object = modem.qammod('M',M, 'SymbolOrder','gray');
%Es=1; A=sqrt(3/2/(M-1)*Es); 
zdBs = [4:0.1:10];
N_zdBs = length(zdBs);
%Ray_fnc = inline('z/s2*exp(-z^2/(2*s2))','s2','z');
CCDF_formula=inline('1-((1-exp(-z.^2/(2*s2))).^N)','N','s2','z'); % Eq.(7.9)
for n = 1:length(Ns)    
    N=Ns(n);
    x = zeros(Nblk,N); 
    sqN=sqrt(N);
    for k = 1:Nblk
       %msgint=randint(1,N,M); X=A*modulate(mod_object,msgint);
       X = mapper(b,N);
       x(k,:) = ifft(X,N)*sqN;
       CFx(k) = PAPR(x(k,:));
    end
    s2 = mean(mean(abs(x)))^2/(pi/2);
    CCDF_theoretical=CCDF_formula(N,s2,10.^(zdBs/20));
    for i = 1:N_zdBs
       %zdB=zdBs(i); %z=10^(zdB/20); %CCDF_theoretical(i)=CCDF_formula(N,s2,z);
       CCDF_simulated(i) = sum(CFx>zdBs(i))/Nblk;
    end
    semilogy(zdBs,CCDF_theoretical,'k-');  hold on; grid on;
    semilogy(zdBs(1:3:end),CCDF_simulated(1:3:end),'k:*');
end
axis([zdBs([1 end]) 1e-2 1]); 
title('OFDM system with N-point FFT');
xlabel('PAPR0[dB]');
ylabel('CCDF=Probability(PAPR>PAPR0)'); 
legend('Theoretical','Simulated');
