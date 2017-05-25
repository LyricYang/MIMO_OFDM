% MMSE_detection_2x2.m

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

clear all; close all; clc; tic
%%%%%%% option %%%%%%%
bits_option  = 2;   %% 0 : all zeros, 1 : all ones, 2: random binary
noise_option = 1;   %% 0 : no noise addition, 1 : noise added
decision_scheme = 1;%% 0 : Hard decision, 1 : soft decision
b = 4; NT = 2;
SNRdBs =[0:2:25]; sq05=sqrt(0.5);
nobe_target = 500; BER_target = 1e-3;
raw_bit_len = 2592-6;  
interleaving_num = 72; deinterleaving_num = 72;
N_frame = 1e8; %% maximum  generated bits #
for i_SNR=1:length(SNRdBs)
    sig_power=NT;  SNRdB=SNRdBs(i_SNR);
    sigma2=sig_power*10^(-SNRdB/10)*noise_option; sigma1=sqrt(sigma2/2);
    rand('seed',1); randn('seed',1);
    nobe = 0;
    Viterbi_init
    for i_frame=1:1:N_frame
        %%%%%%%%%%%%%%  Random data generation %%%%%%%%%%%%%%
        switch (bits_option)
            case {0}, bits=zeros(1,raw_bit_len);
            case {1}, bits=ones(1,raw_bit_len);
            case {2}, bits=randint(1,raw_bit_len);
        end
        %%% Convolutional encoding %%%%%
        encoding_bits = convolution_encoder(bits);
        % Interleaving %%
        interleaved=[];
        for i=1:interleaving_num
            interleaved=[interleaved  encoding_bits([i:interleaving_num:end])];
        end
        temp_bit =[];
        for tx_time=1:648
            tx_bits=interleaved(1:8);
            interleaved(1:8)=[];
            %%%%%%%%%%%%%%  QAM16 modulation %%%%%%%%%%%%%%
            QAM16_symbol = QAM16_mod(tx_bits, 2);
            %%%%%%%%%%%%%%   S/P   %%%%%%%%%%%%%%
            x(1,1) = QAM16_symbol(1); x(2,1) = QAM16_symbol(2);
            %%%%% Channel H and received y   %%%%%%%%%%%%
            if rem(tx_time-1,81)==0
              H = sq05*(randn(2,2)+j*randn(2,2));  
            end
            y = H*x;  
            %%%  AWGN addition %%%
            
            noise = sqrt(sigma2/2)*(randn(2,1)+j*randn(2,1));
            if noise_option==1,   y = y + noise;  end
            %%%%%%%%%%%%% MMSE Detector %%%%%%%%%%%%%%%%%%
            W = inv(H'*H+sigma2*diag(ones(1,2)))*H';
            X_tilde = W*y;
            %%%%%%%%%%%%% Hard decision %%%%%%%%%%%%%
            if (decision_scheme == 0)
                X_hat = QAM16_slicer(X_tilde, 2);
                temp_bit = [temp_bit QAM16_demapper(X_hat, 2)];
            %%%%%%%%%%%%% Soft decision %%%%%%%%%%%%%
            else
                soft_bits = Softoutput2x2(X_tilde); Ps=1;
                SINR1=(Ps*(abs((W(1,:)*H(:,1)))^2)) / (Ps*( abs((W(1,:)*H(:,2)))^2 + W(1,:)*W(1,:)'*sigma2));
                SINR2=(Ps*(abs((W(2,:)*H(:,2)))^2)) / (Ps*( abs((W(2,:)*H(:,1)))^2 + W(2,:)*W(2,:)'*sigma2));
                soft_bits(1:4)=soft_bits(1:4)*SINR1;
                soft_bits(5:8)=soft_bits(5:8)*SINR2;
                temp_bit=[temp_bit soft_bits];
            end  
        end
        %% Deinterleaving
        deinterleaved=[];
        for i=1:deinterleaving_num
            deinterleaved=[deinterleaved temp_bit([i:deinterleaving_num:end])];
        end
        %% Viterbi
        received_bit=Viterbi_decode(deinterleaved);
        %%%%%  Error check %%%%%%
        for EC_dummy=1:1:raw_bit_len,
            if bits(EC_dummy)~=received_bit(EC_dummy), nobe=nobe+1;  end
            if nobe>=nobe_target,  break;  end
        end
        if (nobe>=nobe_target)  break;  end
    end
    %%%%%%%%%%%%% save BER data & Display %%%%%%%%%%%%%
    BER(i_SNR) = nobe/((i_frame-1)*raw_bit_len+EC_dummy);
    fprintf('\t%d\t\t%1.4f\n',SNRdB,BER(i_SNR));
    if BER(i_SNR)<BER_target, break; end
end