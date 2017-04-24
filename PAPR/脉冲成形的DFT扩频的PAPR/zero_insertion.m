function y=zero_insertion(x,M,N)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

[Nrow,Ncol]=size(x);
if nargin<3,  N=Ncol*M;  end
%y = [x(:).'; zeros(M-1,length(x))];
%y = y(:).';
y=zeros(Nrow,N);  y(:,1:M:N) = x;
%for k=1:Nrow, y(k,1:M:N)=x(k,:); end