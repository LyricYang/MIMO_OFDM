function Viterbi_init

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

%Constraint Length K=7 (Memory size=6 => State=64)
ConvCodeGenPoly=[1 0 1 1 0 1 1 ;...
                              1 1 1 1 0 0 1 ];

global prev_state;
global prev_state_outbits;

prev_state = zeros(64, 2);
prev_state_outbits = zeros(64, 2, 2);

for state = 0:63
   state_bits = (fliplr(kron(dec2bin(state,6),1))~=48);     % 1 1 0 0 0 0 (48)
   input_bit = state_bits(1);
   for transition = 0:1
      prev_state_bits = [state_bits(2:6) transition];
      prev_state(state+1, transition+1) = base2dec(fliplr(prev_state_bits)+48,2);
      
      prev_state_outbits(state+1, transition+1, 1) = 2*(rem(sum(ConvCodeGenPoly(1,:).* ...
         [input_bit prev_state_bits]),2)) - 1;
      prev_state_outbits(state+1, transition+1, 2) = 2*(rem(sum(ConvCodeGenPoly(2,:).* ...
         [input_bit prev_state_bits]),2)) - 1;
   end
end
