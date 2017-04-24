function enc_data = trellis_encoder(data,dlt,slt)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

[L_frame,l,N_frames] = size(data);
n_state = 1; % setting up initial state
for k = 1:N_frames
   for i = 1:L_frame  
	  d = data(i,1,k)+1; % data_dim=1  % stc encoder                      
      enc_data(i,:,k) = dlt(n_state,d,:) ;   % stc encoder
      n_state = slt(n_state,d,:);                  % stc encoder
   end                                 % stc encoder
end