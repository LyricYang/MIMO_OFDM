function [bound_lower,bound_upper]=bound(transition)
% Input parameters
%     R : [Q R] = qr(H)
%     radius_squared : R^2
%     transition : stage number
%     x_hat : inv(H)*y
%     x_now : slicing x_hat
% Output parameters
%     bound_lower : bound lower
%     bound_upper : bound upper

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

global R;
global radius_squared;
global x_now;
global x_hat;
len = length(x_hat);
temp_sqrt = radius_squared;
temp_k=0;
for i=1:1:transition-1
    temp_abs=0;
    for k=1:1:i
        index_1 = len-(i-1);
        index_2 = index_1+ (k-1);
        temp_k = R(index_1,index_2)*(x_now(index_2)-x_hat(index_2));
        temp_abs=temp_abs+temp_k;
    end
    temp_sqrt = temp_sqrt - abs(temp_abs)^2;
end
temp_sqrt = sqrt(temp_sqrt);
temp_no_sqrt = 0;
index_1 = len-(transition-1);
index_2 = index_1;
for i=1:1:transition-1
    index_2 = index_2+1;
    temp_i = R(index_1,index_2)*(x_now(index_2)-x_hat(index_2));
    temp_no_sqrt = temp_no_sqrt - temp_i;
end
temp_lower = -temp_sqrt + temp_no_sqrt;
temp_upper = temp_sqrt + temp_no_sqrt;
index = len-(transition-1);
bound_lower = temp_lower/R(index,index) + x_hat(index);
bound_upper = temp_upper/R(index,index) + x_hat(index);
bound_upper = fix(bound_upper*sqrt(10))/sqrt(10);  
bound_lower = ceil(bound_lower*sqrt(10))/sqrt(10); 
