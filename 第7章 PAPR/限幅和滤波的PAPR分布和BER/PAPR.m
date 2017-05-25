function [PAPR_dB, AvgP_dB, PeakP_dB] = PAPR(x)
% PAPR_dB  : PAPR[dB]
% AvgP_dB  : Average power[dB]
% PeakP_dB : Maximum power[dB]

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

Nx=length(x); xI=real(x); xQ=imag(x);
Power = xI.*xI + xQ.*xQ;
PeakP = max(Power); PeakP_dB = 10*log10(PeakP);
AvgP = sum(Power)/Nx; AvgP_dB = 10*log10(AvgP);
PAPR_dB = 10*log10(PeakP/AvgP);
