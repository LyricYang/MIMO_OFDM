function [mod_symbols,sym_table,M] = modulator(bitseq,b)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

N_bits = length(bitseq);
if b==1      % BPSK modulation
   sym_table=exp(j*[0 -pi]);  sym_table=sym_table([1 0]+1);
   inp=bitseq;   mod_symbols=sym_table(inp+1);   M=2;
 elseif b==2    % QPSK modulation
   sym_table = exp(j*pi/4*[-3 3 1 -1]); sym_table=sym_table([0 1 3 2]+1);
   inp=reshape(bitseq,b,N_bits/b);
   mod_symbols=sym_table([2 1]*inp+1);   M=4;
 elseif b==3    % generates 8PSK symbols
   sym_table=exp(j*pi/4*[0:7]); sym_table=sym_table([0 1 3 2 6 7 5 4]+1);
   inp=reshape(bitseq,b,N_bits/b); mod_symbols=sym_table([4 2 1]*inp+1);
   M=8;   
 elseif b==4    % 16-QAM modulation
   m=0;  sq10=sqrt(10);
   for k=-3:2:3
      for l=-3:2:3
         m=m+1; sym_table(m) = (k+j*l)/sq10; % power normalization
      end
   end
   sym_table = sym_table([0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10]+1); % Gray code mapping pattern for 8-PSK symbols
   inp = reshape(bitseq,b,N_bits/b);
   mod_symbols = sym_table([8 4 2 1]*inp+1);  % maps transmitted bits into 16QAM symbols
   M=16; %16 constellation points
 else
   error('Unimplemented modulation');
end


