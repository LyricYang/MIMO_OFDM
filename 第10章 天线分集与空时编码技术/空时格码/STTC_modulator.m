function sig_mod = STTC_modulator(data,M,sim_options)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

qam16=[1 1; 2 1; 3 1; 4 1; 4 2; 3 2; 2 2; 1 2; 1 3; 2 3; 3 3; 4 3; 4 4; 3 4; 2 4; 1 4];
[N_frame,space_dim,N_packets]=size(data);  
j2piM=j*2*pi/M;
for k = 1:N_packets
   switch M
	 case 16         % 16QAM
		for l = 1:space_dim
		   k1(:,l) = qam16(data(:,l,k)+1,1);
		   k2(:,l) = qam16(data(:,l,k)+1,2);
		end
		q(:,:,k) = 2*k1-M-1 - j*(2*k2-M-1);
     otherwise
	    q(:,:,k) = exp(j2piM*data(:,:,k));
   end
   sig_mod=q;
end