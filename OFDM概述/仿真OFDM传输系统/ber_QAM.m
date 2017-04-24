function ber=ber_QAM(EbN0dB,M,AWGN_or_Rayleigh)
% Find ananlytical BER of Mary QAM in AWGN or Rayleigh channel
% EbN0dB=EbN0dB: Energy per bit-to-noise power[dB] for AWGN channel
%       =rdB: Average SNR(2*sigma Eb/N0)[dB] for Rayleigh channel
% M = Modulation order (Constellation size)  

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

N= length(EbN0dB);  
sqM= sqrt(M); 
a= 2*(1-power(sqM,-1))/log2(sqM);  b= 6*log2(sqM)/(M-1);
if nargin<3
    AWGN_or_Rayleigh='AWGN'; 
end
if lower(AWGN_or_Rayleigh(1))=='a'
    ber = a*Q(sqrt(b*10.^(EbN0dB/10)));
else
    rn= b*10.^(EbN0dB/10)/2; 
    ber = 0.5*a*(1-sqrt(rn./(rn+1)));
end