function [X_hat]=QRM_MLD_detecor(Y,H)
% Input parameters
%     Y : received signal, nTx1
%     H : Channel matrix, nTxnT
% Output parameter
%   X_hat : estimated signal, nTx1

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

global QAM_table  Q  R  Y_tilde  NT  M;
% NT : Number of Tx antennas, M : Parameter M in M-algorithm
QAM_table = [-3-3j, -3-j, -3+3j, -3+j, -1-3j, -1-j, -1+3j, -1+j, 3-3j, ...
                       3-j, 3+3j, 3+j, 1-3j, 1-j, 1+3j, 1+j]/sqrt(10); % QAM table
[Q R] = qr(H);   % QR-decomposition
Y_tilde = Q'*Y;  
symbol_replica = zeros(NT,M,NT); % QAM table index
for stage = 1:NT
   symbol_replica = stage_processing1(symbol_replica,stage);
end
X_hat =  QAM_table(symbol_replica(:,1));

function[symbol_replica] = stage_processing1(symbol_replica,stage)
% Input parameters
%     Y_tilde : Q'*Y
%     R : [Q R] = qr(H)
%     QAM_table : 
%     symbol_replica : M candidate vectors
%     stage : stage number
%     M : parameter M in the M-algorithm
%     NT : number of Tx antennas
% Output parameter
%     symbol_replica : M candidate vectors 
global NT  M;
if stage == 1; m = 1; else m = M; end 
symbol_replica_norm = calculate_norm(symbol_replica,stage);
[symbol_replica_norm_sorted, symbol_replica_sorted] = sort_matrix(symbol_replica_norm);  
% sort in norm order, data is in a matrix form
symbol_replica_norm_sorted = symbol_replica_norm_sorted(1:M);
symbol_replica_sorted = symbol_replica_sorted(:,[1:M]); 
if stage>=2 
  for i=1:m
     symbol_replica_sorted([2:stage],i)  =  ...
     symbol_replica([1:stage-1],symbol_replica_sorted(2,i),(NT+2)-stage);   
  end
end
if stage == 1 % In stage 1, size of symbol_replica_sorted is 2xM, 
  the second row is not necessary  
  symbol_replica([1:stage],:,(NT+1)-stage) = symbol_replica_sorted(1,:);
 else
  symbol_replica([1:stage],:,(NT+1)-stage) = symbol_replica_sorted;
end

function [symbol_replica_norm]=calculate_norm(symbol_replica,stage)
% Input parameters
%     Y_tilde : Q'*Y
%     R : [Q R] = qr(H)
%     QAM_table : 
%     symbol_replica : M candidate vectors
%     stage : stage number
%     M : M parameter in M-algorithm
%     NT : number of Tx antennas
% Output parameter
%     symbol_replica_norm : norm values of M candidate vectors
global QAM_table  R  Y_tilde  NT  M;
if stage == 1;  m = 1;  else m = M; end
stage_index = (NT+1)-stage;
for i=1:m
   X_temp = zeros(NT,1);
   for a=NT:-1:(NT+2)-stage 
      X_temp(a) = QAM_table(symbol_replica((NT+1)-a,i,stage_index+1));
   end
   X_temp([(NT+2)-stage:(NT)]) = wrev(X_temp([(NT+2)-stage:(NT)])); 
   % reordering
   Y_tilde_now = Y_tilde([(NT+1)-stage:(NT)]);  
   % Y_tilde used in the current stage    
   R_now = R([(NT+1)-stage:(NT)],[(NT+1)-stage:(NT)]);
   % R used in the current stage
   for k = 1:length(QAM_table) % norm calculation,
      % the norm values in the previous stages can be used, however, 
      % we recalculate them in an effort to simplify the MATLAB code        
      X_temp(stage_index) = QAM_table(k);
      X_now = X_temp([(NT+1)-stage:(NT)]);  
      symbol_replica_norm(i,k) = norm(Y_tilde_now - R_now*X_now)^2;
   end
end

function [index_number] = find_vector(range,target);
% Input parameters
%     target : target vector
%     range : the range of target vector
% Output parameters
%     index_number : the index of range that corresponds to target
for index_number=1:size(range,2)
   if range(:,index_number)==target,  break;   end
end

function [entry_sorted entry_index_sorted] =  sort_matrix(matrix_form)
% Input parameters
%    matrix_form : a matrix to be sorted
%    M : parameter M in M-algorithm
% Output parameters
%    entry_sorted : increasingly ordered norm
%    entry_index_sorted : ordered QAM_table index
[row_size,column_size] = size(matrix_form);
flag=0; % flag = 1 ? the least norm is found
vector_form=[];
entry_index_sorted =[];
for i = 1:row_size % matrix form ? vector form
   vector_form = vector_form matrix_form(i,:); 
end
for m=1:row_size*column_size 
   entry_min = min(vector_form);
   flag=0;
   for i = 1:row_size 
      if flag==1,  break;  end
      for k = 1:column_size 
         if flag==1,  break;  end
         entry_temp = matrix_form(i,k);
         if entry_min == entry_temp
           entry_index_sorted = entry_index_sorted [k; i];
           entry_sorted(m) = entry_temp;
           vector_form((i-1)*column_size+k)=10000000; 
           flag=1;
         end
      end
   end
end
