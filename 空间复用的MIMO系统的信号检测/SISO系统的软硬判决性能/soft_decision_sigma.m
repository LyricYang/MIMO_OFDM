function [x4_soft] = soft_decision_sigma(x,h)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

x=x(:).'; xr=real(x); xi=imag(x);  
X=[xr; 2-abs(xr);  xi; 2-abs(xi)];  H=repmat(abs(h(:)).',4,1);
XH = X.*H; x4_soft = XH(:).'; 
