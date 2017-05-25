function [flag,transition] = stage_processing(flag,transition)
% Input parameters
%    flag : previous stage index
%       flag = 0 : stage index decreased -> x_now empty -> new x_now
%       flag = 1 : stage index decreased -> new x_now
%       flag = 2 : previous stage index =len+1 ->  If R>R'? start from the first stage
%     transition : stage number
% Output parameters
%     flag : stage number is calculated from flag
%     transition : next stage number, 0 : R*2, 1: next stage, len+2: finish

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

global x_list;
global x_metric;
global x_now;
global x_hat;
global real_constellation;
global R;
global radius_squared;
global x_sliced;
stage_index = length(R(1,:))-(transition-1); 
if flag == 2  % previous stage=len+1 : recalculate radius R'
  radius_squared  = norm(R*(x_sliced-x_hat))^2;
end
if flag ~= 0 % previous stage=len+1 or 0 
  % -> upper and lower bound calculation, x_list(stage_index,:)
  [bound_lower bound_upper] = bound(transition);
  for i =1:4    % search for a candidate in x_now(stage_index),
     % 4=size(real_constellation), 16-QAM assumed
     if bound_lower <= real_constellation(i) && real_constellation(i) <= bound_upper
       list_len = list_length(x_list(stage_index,:));
       x_list(stage_index,list_len+1) = real_constellation(i);
     end
  end
end
list_len = list_length(x_list(stage_index,:));
if list_len == 0     % no candidate in x_now
    if x_metric == 0 || transition ~= 1 
       % transition >=2 ? if no candidate ? decrease stage index
       flag = 0;
       transition = transition-1;
     elseif x_metric ~= 0 && transition == 1 
       % above two conditions are met? ML solution found
       transition = length(R(1,:))+2;  % finish stage
    end
 else   % candidate exist in x_now ? increase stage index
    flag = 1;
    transition = transition+1;
    x_now(stage_index) = x_list(stage_index,1);
    x_list(stage_index,:) = [x_list(stage_index,[2:4]) 0]; 
end