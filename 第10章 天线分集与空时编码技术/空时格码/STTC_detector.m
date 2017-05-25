function [data_est,state_est] = STTC_detector(sig,dlt,slt,ch_coefs)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

[step_final,space_dim,N_packets] = size(sig);
[s,md,foo] = size(dlt);
qam16=[1 1;2 1;3 1;4 1;4 2;3 2;2 2;1 2;1 3;2 3;3 3;4 3;4 4;3 4;2 4;1 4];
for k = 1:N_packets
   metric(1,2:s) = realmax;
   for l = 1:step_final
	  for m = 1:s % current m
         [s_pre,foo] = find(slt==m);
		 pos = mod(m-1,md) + 1;
		 data_test = dlt(s_pre,pos,:);
		 data_test = reshape(data_test,[md 2]);
		 if md==16 % 16QAM
		   for r = 1:2
			  k1(:,r) = qam16(data_test(:,r)+1,1);
			  k2(:,r) = qam16(data_test(:,r)+1,2);
           end
		   q_test = (2*k1-md-1) - j*(2*k2-md-1);
		  else % 4,8PSK
		   expr = j*2*pi/md;
		   q_test = exp(expr*data_test);
         end
		 metric_d = branch_metric(sig(l,:,k),q_test,ch_coefs(:,:,k));
		 metric_md = metric(l,s_pre)' + metric_d;
		 [metric_min,metric_pos] = min(metric_md);
		 metric(l+1,m) = metric_min;
		 vit_state(l+1,m) = s_pre(metric_pos);
		 vit_data(l+1,m) = pos - 1;
      end
   end
   [foo,state_best] = min(metric(end,:));
   state_est(step_final + 1) = state_best;
   for l = step_final:-1:1
	  state_est(l) = vit_state(l+1,state_est(l+1));
	  data_est(l,:,k) = vit_data(l+1,state_est(l+1));
   end
end