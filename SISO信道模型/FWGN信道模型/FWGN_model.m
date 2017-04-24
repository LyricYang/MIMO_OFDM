function [h,Nfft,Nifft,doppler_coeff]=FWGN_model(fm,fs,N)
% FWGN(Clarke/Gan) Model 
% Input
%   fm= Maximum Doppler frquency
%   fs= Sampling frequency
%   N = Number of samples
% Output
%   h = Complex fading channel
 
%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd
 
% Make them simple by taking a FFT with some 2^n points.
% tone spacing df=2fm/Nfft
Nfft = 2^max(3,nextpow2(2*fm/fs*N));  % Nfft=2^n
Nifft = ceil(Nfft*fs/(2*fm));
% Generate the inependent complex gaussian random process. 
GI = randn(1,Nfft); 
GQ = randn(1,Nfft);
% take FFT of real signal in order to make hermitian symmetric
CGI = fft(GI);       
CGQ = fft(GQ);
% Nfft sample Doppler spectrum generation
doppler_coeff = Doppler_spectrum(fm,Nfft);
% Do the filtering of the gaussian random variables here.
f_CGI = CGI.*sqrt(doppler_coeff);
f_CGQ = CGQ.*sqrt(doppler_coeff);
% adjusting sample size to take IFFT by (Nifft-Nfft) sample zero-padding
tzeros= zeros(1,Nifft-Nfft);
Filtered_CGI=[f_CGI(1:Nfft/2) tzeros f_CGI(Nfft/2+1:Nfft)];
Filtered_CGQ=[f_CGQ(1:Nfft/2) tzeros f_CGQ(Nfft/2+1:Nfft)];
hI = ifft(Filtered_CGI);   
hQ= ifft(Filtered_CGQ);
% Take the magnitude squared of the I and Q components and add them together.
rayEnvelope = sqrt(abs(hI).^2 + abs(hQ).^2);
% Compute the Root Mean Squared Value and Normalize the envelope.
rayRMS = sqrt(mean(rayEnvelope(1:N).*rayEnvelope(1:N)));
h = complex(real(hI(1:N)),-real(hQ(1:N)))/rayRMS;