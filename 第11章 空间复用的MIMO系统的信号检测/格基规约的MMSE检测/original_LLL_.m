function [Q,R,T] = original_LLL(Q,R,m,delta)
% Input parameters
%     Q : orthogonal matrix,  nRxnT
%     R : R with a large condition number
%     m : column length of H
%     delta : scaling variable
% Output parameters
%     Q : orthogonal matrix,  nRxnT
%     R : R with a small condition number
%     T : unimodular matrix

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

P=eye(m);  T=P;  k=2;
while (k <= m)
    for j = k-1:-1:1
        mu = round(R(j,k)/R(j,j));
        if (mu ~= 0)
            R(1:j,k)=R(1:j,k)-mu*R(1:j,j); 
            T(:,k)=T(:,k)-mu*T(:,j); 
        end
    end
    if (delta * R(k-1,k-1)^2 > R(k,k)^2 + R(k-1,k)^2)  % column change
       R(:,[k-1 k])=R(:,[k k-1]);
       T(:,[k-1 k])=T(:,[k k-1]);
%calculate Givens rotation matrix such that element R(k,k-1) becomes zero
       alpha = R(k-1,k-1)/sqrt(R(k-1:k,k-1).'*R(k-1:k,k-1));
       beta = R(k,k-1)/sqrt(R(k-1:k,k-1).'*R(k-1:k,k-1));
       theta = [alpha  beta; -beta  alpha];
       R(k-1:k,k-1:m)=theta*R(k-1:k,k-1:m);
       Q(:,k-1:k)=Q(:,k-1:k)*theta.';
       k=max([k-1 2]);
    else
       k=k+1;
    end
end