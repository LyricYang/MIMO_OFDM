function [flag,transition]=compare_vector_norm(transition)
% stage index increased(flag = 1) : recalculate x_list(index,:)
% stage index decreased(flag = 0) : in the previous stage, no candidate x_now in x_list
% Input parameters
%     flag : previous stage
%     transition : stage number
% Output parameters
%    flag : next stage number is calculated from flag
%    transition : next stage number

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

global x_list;
global x_pre;
global x_metric;
global x_now;
global x_hat;
global R;
global radius_squared;
global x_sliced;
global len;
vector_identity = vector_comparison(x_pre,x_now); 
% check if the new candidate is among the ones we found before
if vector_identity == 1 
% if 1 ? ML solution found
   len_total = 0;
   for i=1:len  % if the vector is unique ? len_total = 0
       len_total = len_total + list_length(x_list(i,:));
   end
   if len_total == 0      % ML solution vector found
     transition = len+2; % finish
     flag = 1;
   else                      % more than one candidates 
      transition = transition-1;  % go back to the previous stage
      flag =0;
   end
else  % if 0 ? new candidate vector is different from the previous candidate vector and norm is smaller ? restart
   x_sliced_temp = x_now;
    metric_temp  = norm(R*(x_sliced_temp-x_hat))^2;
    if metric_temp <=  radius_squared 
      % new candidate vector has smaller metric ? restart
      x_pre = x_now;
      x_metric = metric_temp;
      x_sliced = x_now;
      transition = 1;       % restart
     flag = 2;
      x_list=zeros(len,4); % initialization
      x_now=zeros(len,1);  % initialization
    else % new candidate vector has a larger ML metric
      transition = transition-1;  % go back to the previous stage
      flag =0;
   end
end
