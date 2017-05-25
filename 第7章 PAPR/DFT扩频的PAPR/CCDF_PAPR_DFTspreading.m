function [CCDF,PAPRs]=CCDF_PAPR_DFTspreading(fdma_type,Ndb,b,N,dBcs,Nblk,psf,Nos)
% fdma_type: 'ofdma'/'ifdma'(interleaved)/'lfdma'(localized)
% Ndb   : Data block size
% b     : Number of bits per symbol
% N     : FFT size
% dBcs  : dB vector
% Nblk  : Number of OFDM blocks for iteration
% psf   : Pulse shaping filter coefficient vector
% Nos   : Oversampling factor

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

M=2^b; Es=1; A=sqrt(3/2/(M-1)*Es); % Alphbet size and Normalization factor for QAM
mod_object=modem.qammod('M',M,'SymbolOrder','gray'); 
S=N/Ndb; % Spreading factor
rand('twister',5489); randn('state',0);
for iter=1:Nblk
   %tx_bits=floor(rand(1,Ndb*b)*2); % generates random bits
   %mod_sym=QAM_mod(tx_bits,b);   % constellation mapping. average power=1    
   mod_sym = A*modulate(mod_object,randint(1,Ndb,M));
   switch upper(fdma_type(1:2))
     case 'IF', fft_sym = zero_insertion(fft(mod_sym,Ndb),N/Ndb); % IFDMA
     case 'LF', fft_sym = [fft(mod_sym,Ndb) zeros(1,N-Ndb)]; % LFDMA
     case 'OF', fft_sym = zero_insertion(mod_sym,S); % Oversampling, No DFT spreading
     otherwise  fft_sym = mod_sym; % No oversampling, No DFT spraeding
   end
   ifft_sym = ifft(fft_sym,N);       % IFFT
   if nargin>7, ifft_sym = zero_insertion(ifft_sym,Nos); end
   if nargin>6, ifft_sym = conv(ifft_sym,psf); end    
   sym_pow = ifft_sym.*conj(ifft_sym); % measure symbol power
   %mean_pow(iter) = mean(sym_pow); % mean power
   %max_pow(iter) = max(sym_pow); % max power
   PAPRs(iter) = max(sym_pow)/mean(sym_pow); % measure PAPR
end
%PAPRs = max_pow./mean_pow; 
PAPRdBs = 10*log10(PAPRs); % measure PAPR
N_bins = hist(PAPRdBs,dBcs);  count = 0; 
for i=length(dBcs):-1:1
   count = count+N_bins(i); CCDF(i) = count/Nblk;
end