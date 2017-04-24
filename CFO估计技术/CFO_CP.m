function CFO_est=CFO_CP(y,Nfft,Ng)
% Time-domain CFO estimation based on CP (Cyclic Prefix)

nn=1:Ng; 
CFO_est = angle(y(nn+Nfft)*y(nn)')/(2*pi);  