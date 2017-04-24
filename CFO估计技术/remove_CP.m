function y=remove_CP(x,Ncp,Noff)
% Remove cyclic prefix
if nargin<3
    Noff=0; 
end
y=x(:,Ncp+1-Noff:end-Noff);