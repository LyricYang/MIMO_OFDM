function H=Ray_model(L)
% Rayleigh Channel Model
%  Input : L  : # of channel realization
%  Output: H  : Channel vector
H = (randn(1,L)+j*randn(1,L))/sqrt(2);
