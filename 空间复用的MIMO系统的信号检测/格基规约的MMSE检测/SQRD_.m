function [Q,R,P,p] = SQRD(H)
% Sorted QR decomposition
% Input parameter
%     H : complex channel matrix, nRxnT
% Output parameters
%     Q : orthogonal matrix, nRxnT
%     P : permutation matrix
%     p : ordering information

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

Nt=size(H,2);  Nr=size(H,1)-Nt;  R=zeros(Nt);
Q=H;   p=1:Nt;
for i=1:Nt normes(i)=Q(:,i)'*Q(:,i); end
for i=1:Nt
    [mini,k_i]=min(normes(i:Nt)); k_i=k_i+i-1;
    R(:,[i k_i])=R(:,[k_i i]);
    p(:,[i k_i])=p(:,[k_i i]);
    normes(:,[i k_i])=normes(:,[k_i i]);
    Q(1:Nr+i-1,[i k_i])=Q(1:Nr+i-1,[k_i i]);
    % Wubben's algorithm: does not lead to
    % a true QR decomposition of the extended MMSE channel matrix
    % Q(Nr+1:Nr+Nt,:) is not triangular but permuted triangular
R(i,i)=sqrt(normes(i));
    Q(:,i)=Q(:,i)/R(i,i);
    for k=i+1:Nt
        R(i,k)=Q(:,i)'*Q(:,k);
        Q(:,k)=Q(:,k)-R(i,k)*Q(:,i);
        normes(k)=normes(k)-R(i,k)*R(i,k)';
    end
end
P=zeros(Nt); for i=1:Nt P(p(i),i)=1; end