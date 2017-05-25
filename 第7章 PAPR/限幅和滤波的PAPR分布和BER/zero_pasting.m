function y=zero_pasting(x)
%在输入序列x的一半中心处粘贴零
N=length(x);
M=ceil(N/4);
y=[x(1:M) zeros(1,N/2) x(N-M+1:N)];
end