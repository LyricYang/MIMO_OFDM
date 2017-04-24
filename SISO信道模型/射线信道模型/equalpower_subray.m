function theta=equalpower_subray(AS_deg)
% Get angle spacing for equal power Laplacian PAS in SCM Text
%  Input:
%    AS_deg : Angle spread whose valid value is 2,5(for BS), 35(for MS)
%  Output:
%    theta  : offset angle with M=20
 
%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd
 
% sub-ray angle offsets in SCM text
if AS_deg==2
   theta=[0.0894 0.2826 0.4984 0.7431 1.0257 1.3594 1.7688 2.2961 3.0389 4.3101];
 elseif AS_deg==5
   theta=[0.2236 0.7064 1.2461 1.8578 2.5642 3.3986 4.4220 5.7403 7.5974 10.7753];
 elseif AS_deg==35
   theta=[1.5649 4.9447 8.7224 13.0045 17.9492 23.7899 30.9538 40.1824 53.1816 75.4274];
 else error('Not support AS');
end