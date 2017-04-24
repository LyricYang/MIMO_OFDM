function [dlt,slt,M]=STTC_stage_modulation(state,NRx)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

switch state
    case '4_State_4PSK',   M=4;  Ns=4;
    case '8_State_4PSK',   M=4;  Ns=8;
    case '16_State_4PSK',  M=4;  Ns=16;
    case '32_State_4PSK',  M=4;  Ns=32;
    case '8_State_8PSK',   M=8;  Ns=8;
    case '16_State_8PSK',  M=8;  Ns=16;
    case '32_State_8PSK',  M=8;  Ns=32;
    case 'DelayDiv_8PSK',  M=8;  Ns=8;
    case '16_State_16qam', M=16; Ns=16;
    case 'DelayDiv_16qam', M=16; Ns=16;
    otherwise, disp('Wrong option !!');
end
base = reshape(1:Ns,M,Ns/M)';  slt = repmat(base,M,1);
stc_bc16 = [ 0  0;11  1; 2  2; 9  3; 4  4;15  5; 6  6;13  7; 
             8  8; 3  9;10 10; 1 11;12 12; 7 13;14 14; 5 15];
for n = 1:M
   l = n-1;
   ak=bitget(l,1); bk=bitget(l,2); dk=bitget(l,3); ek=bitget(l,4);
   switch M
   % 4 PSK
     case 4   % NOTE: trace criterion option implemented as an example
  	   for m = 1:Ns
		  k = m-1;
		  ak_1 = bitget(k,1);  bk_1 = bitget(k,2); 
          ak_2 = bitget(k,3);  bk_2 = bitget(k,4);
		  ak_3 = bitget(k,5);  bk_3 = bitget(k,6);
		  switch Ns
		    case 4 %4state_4psk
              if NRx~=2
    		    dlt(m,n,1) = mod(2*bk_1+ak_1,M);%rank & determinant criteria
			    dlt(m,n,2) = mod(2*bk+ak,M);
               else
    		    dlt(m,n,1) = mod(2*bk_1+ak_1,M);%rank & determinant criteria
			    dlt(m,n,2) = mod(2*bk+ak,M);
              end
		    case 8 %8state_4psk
              if NRx~=2
			    dlt(m,n,1) = mod(2*ak_2+2*bk_1+ak_1,M);%rank & determinant criteria
    		    dlt(m,n,2) = mod(2*ak_2+2*bk+ak,M);
               else
                dlt(m,n,1)= mod(2*bk_1+2*bk+ak_1+2*ak,M);   %trace criterion
                dlt(m,n,2)= mod(bk_1+2*ak_2+2*bk+2*ak_1,M);
              end
		    case 16 %16state_4psk
              if NRx~=2
			    dlt(m,n,1) = mod(2*ak_2+2*bk_1+ak_1,M);%rank & determinant criteria
			    dlt(m,n,2) = mod(2*bk_2+2*ak_1+2*bk+ak,M);    
               else
                dlt(m,n,1)=mod(2*bk_3+2*ak_3+3*bk_2+3*bk_1+2*ak_1+2*ak,M); %trace criterion
                dlt(m,n,2)=mod(2*bk_3+3*bk_2+bk_1+2*ak_1+2*bk+2*ak,M);
              end
		    case 32 %32state_4psk
			  dlt(m,n,1) = mod(2*ak_3+3*bk_2+2*ak_2+2*bk_1+ak_1,M); % rank & determinant criteria
			  dlt(m,n,2) = mod(2*ak_3+3*bk_2+2*bk_1+ak_1+2*bk+ak,M);         
          end
       end
	 % 8 PSK
	 case 8 % 'rank & determinant' criteria only
	   for m = 1:Ns
	 	  k = m - 1;
		  ak_1 = bitget(k,1); bk_1 = bitget(k,2); dk_1 = bitget(k,3); 
          ak_2 = bitget(k,4); bk_2 = bitget(k,5); 		
		  switch Ns
		    case 8
              switch state
                case '8_State_8PSK'
			      dlt(m,n,1) = mod(4*dk_1+2*bk_1+5*ak_1,M);
				  dlt(m,n,2) = mod(4*dk+2*bk+ak,M);
                case 'DelayDiv_8PSK'
       		      dlt(m,n,1)=mod(4*dk_1+2*bk_1+ak_1,M);
				  dlt(m,n,2)=mod(4*dk+2*bk+ak,M);
              end
		    case 16 %16state_8psk
			  dlt(m,n,1) = mod(ak_2+4*dk_1+2*bk_1+5*ak_1,M);
			  dlt(m,n,2) = mod(5*ak_2+4*dk_1+2*bk_1+ak_1+4*dk+2*bk+ak,M);
		    case 32 %32state_8psk
			  dlt(m,n,1) = mod(2*bk_2+3*ak_2+4*dk_1+2*bk_1+5*ak_1,M); 
			  dlt(m,n,2) = mod(2*bk_2+7*ak_2+4*dk_1+2*bk_1+ak_1+4*dk+2*bk+ak,M);
          end
       end
	 % 16 QAM
	 case 16% 'rank & determinant' criteria only
	   for m = 1:Ns
		  k = m - 1;	
		  ak_1 = bitget(k,1);  bk_1 = bitget(k,2);
		  dk_1 = bitget(k,3);  ek_1 = bitget(k,4);
		  switch Ns
		    case 16
              switch state    
                case '16_State_16qam'
                    dlt(m,n,1) = stc_bc16(k+1,1); dlt(m,n,2) = stc_bc16(k+1,2)-m+n;
                case 'DelayDiv_16qam'
                    dlt(m,n,1) = mod(8*ek_1+4*dk_1+2*bk_1+ak_1,M);
					dlt(m,n,2) = mod(8*ek+4*dk+2*bk+ak,M);
			  end
          end
       end
   end
end