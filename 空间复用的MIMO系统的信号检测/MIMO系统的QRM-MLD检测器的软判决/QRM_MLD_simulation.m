% QRM_MLD_simulation.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all; 
Rc=0.5; % Code rate
N_frame=1e5; Nfft=64;
NT=4; NR=NT; b=4; N_block=10; 
L_frame=NT*N_block*Nfft*b/2-6;
PDP=[6.3233e-1 2.3262e-1 8.5577e-2 3.1482e-2 1.1582e-2 4.2606e-3 1.5674e-3 5.7661e-4];
candidate=16;  sq05=sqrt(0.5);  sq05PDP=sq05*PDP.^(1/2);  LPDP=length(PDP);
SNRdBs=[12:2:20]; %SNRdBs=[10:2:14];
for i_SNR=1:length(SNRdBs)
   SNRdB=SNRdBs(i_SNR);
   sig_power=NT; sigma2=sig_power*10^(-SNRdB/10); sigma1=sqrt(sigma2/2);
   nofe=0; % Number of frame errors
   rand('seed',1); randn('seed',1); Viterbi_init; 
   for i_frame=1:N_frame
      %X=zeros(N_block, NT, Nfft);
      LLR_est=zeros(N_block, NT, 4, Nfft);
      X_Estimated_sym=zeros(N_block, NT, Nfft);
      s=randint(1,L_frame);        
      coded_bits=transpose(convolution_encoder(s));        
      interleaved=[];
      for i=1:128, interleaved=[interleaved  coded_bits([i:128:end])];  end
      %ss=zeros(N_block,NT,Nfft,b);
      for i_bk=1:N_block
         for i_stream=1:NT
            for i_subcarrier=1:Nfft
               ss(i_bk, i_stream, i_subcarrier,:)=interleaved(1:b);
               interleaved(1:b)=[];
            end
         end
      end
      for i_bk=1:N_block
         for i_stream=1:NT
            for i_subcarrier=1:Nfft
               X(i_bk, i_stream, i_subcarrier)=QAM16_mod(ss(i_bk, i_stream, i_subcarrier,:), 1);
            end
         end
      end
      for i_Rx=1:NR
         for i_Tx=1:NT
            Frame_H(i_Rx,i_Tx,:)=fft(sq05PDP.*(randn(1,LPDP)+j*randn(1,LPDP)),Nfft);
         end
      end
      for i_bk=1:N_block
         for i_Rx=1:NR
            temp=0;
            for i_stream=1:NT    
               temp=temp+Frame_H(i_Rx,i_stream,:).*X(i_bk,i_stream,:);
            end
            Y(i_Rx,:)=reshape(temp,1,Nfft)+sigma1*(randn(1,Nfft)+j*randn(1,Nfft));
         end
         for i_subcarrier=1:Nfft
            H=Frame_H(:,:,i_subcarrier);
            y=Y(:, i_subcarrier);
            x_test=X(i_bk, :, i_subcarrier);
            LLR_est(i_bk,:,:, i_subcarrier)=QRM_MLD_soft(y, H, candidate); % 16 : No. of candidate.
         end
      end
      soft_bits=[];   hard_bits=[];  s_hat=[];
      for i_bk=1:N_block
         for i_stream=1:NT
            for i_subcarrier=1:Nfft
               soft_bits=[soft_bits LLR_est(i_bk, i_stream, 1, i_subcarrier),...
                          LLR_est(i_bk, i_stream, 2, i_subcarrier),...
                            LLR_est(i_bk, i_stream, 3, i_subcarrier),...
                            LLR_est(i_bk, i_stream, 4, i_subcarrier)];
            end
         end
      end
      deinterleaved=[];
      for i=1:80
         deinterleaved=[deinterleaved soft_bits([i:80:end])];
      end
      s_hat=Viterbi_decode(deinterleaved);
      temp=find(xor(s,s_hat([1:L_frame]))==1);
      if length(temp)~=0,  nofe=nofe+1;  end
      %if mod(i_frame,100)==0,  fprintf('frame : %d passed\n',i_frame);  end    
      if nofe>100,  break;  end
   end % End of frame index
   FER(i_SNR) = nofe/i_frame; if FER(i_SNR)<1e-3,  break;  end
end % End of SNR
FER

