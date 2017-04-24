function [X_hat]=SD_detector(y,H,nT)
    % Input parameters
    %     y : received signal, nRx1
    %     H : Channel matrix, nRxnT
    %    nT : number of Tx antennas
    % Output parameter
    %    X_hat : estimated signal, nTx1

    global x_list;         % candidate symbols in real constellations
    global x_now;          % temporary x_vector elements
    global x_hat;          % inv(H)*y
    global x_sliced;       % sliced x_hat
    global x_pre;          % x vectors obtained in the previous stage
    global real_constellation; % real constellation
    global R;               % R in the QR decomposition
    global radius_squared; % radius^2
    global x_metric;       % ML metrics of previous stage candidates
    global len;             % nT*2
    QAM_table2 = [-3-3j, -3-j, -3+3j, -3+j, -1-3j, -1-j, -1+3j, -1+j,3-3j, ...
               3-j, 3+3j, 3+j, 1-3j, 1-j, 1+3j, 1+j]/sqrt(10); % 16-QAM
    real_constellation = [-3 -1 1 3]/sqrt(10);
    y =[real(y); imag(y)];     % y : complex vector  -> real vector
    H =[real(H)  -(imag(H)) ; imag(H)   real(H)];    
    % H : complex vector  -> real vector
    len = nT*2; % complex -> real
    x_list = zeros(len,4); % 4 : real constellation length, 16-QAM
    x_now = zeros(len,1); x_hat = zeros(len,1); x_pre = zeros(len,1); x_metric = 0;
    [Q,R] = qr(H);     % nR x nT QR decomposition
    x_hat = inv(H)*y;                % zero forcing equalization
    x_sliced = QAM16_real_slicer(x_hat,len)';  % slicing
    radius_squared  = norm(R*(x_sliced-x_hat))^2;  % Radious^2
    transition = 1;
    % meaning of transition 
    % 0 : radius*2, 1~len : stage number
    % len+1 : compare two vectors in terms of norm values
    % len+2 : finish
    flag = 1; 
    % transition tracing 0 : stage index increases by +1 
    %1 : stage index decreases by -1 
    %2 : 1->len+2 or len+1->1
    while (transition<len+2)
       if transition==0    % radius_squared*2
         [flag,transition,radius_squared,x_list]= radius_control(radius_squared,transition);
        elseif transition <= len
         [flag,transition] = stage_processing(flag,transition);
        elseif transition == len+1 % 
         [flag,transition] = compare_vector_norm(transition);
       end
    end
    ML = x_pre;
    for i=1:len/2
        X_hat(i) = ML(i)+j*ML(i+len/2);
    end
end

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
    global x_list x_metric x_now x_hat real_constellation R radius_squared x_sliced;

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
    -> upper and lower bound calculation, x_list(stage_index,:)
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
    else              % candidate exist in x_now ? increase stage index
      flag = 1;
      transition = transition+1;
      x_now(stage_index) = x_list(stage_index,1);
      x_list(stage_index,:) = [x_list(stage_index,[2:4]) 0]; 
end

function [bound_lower bound_upper]=bound(transition)
    % Input parameters
    %     R : [Q R] = qr(H)
    %     radius_squared : R^2
    %     transition : stage number
    %     x_hat : inv(H)*y
    %     x_now : slicing x_hat
    % Output parameters
    %     bound_lower : bound lower
    %     bound_upper : bound upper

    global R  radius_squared  x_now  x_hat;
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
end

function [len]=list_length(list)
    % Input parameter
    %     list : vector type
    % Output parameter
    %     len : index number

    len = 0;
    for i=1:4
       if list(i)==0,  break;  else len = len+1;  end
    end
end

function [flag,transition,radius_squared,x_list] =radius_control(radius_squared,transition)
    % Input parameters
    %     radius_squared : current radius
    %     transition : current stage number
    % Output parameters
    %     radius_squared : doubled radius
    %     transition : next stage number
    %     flag : next stage number is calculated from flag
    global len;
    radius_squared = radius_squared*2;
    transition = transition+1;
    flag = 1;
    x_list(len,:)=zeros(1,4);
end

function [check]=vector_comparison(vector_1,vector_2)
    % check if the two vectors are the same
    % Input parameters
    %   pre_x : vector 1
    %   now_x : vector 2
    % Output parameters
    %   check : 1-> same vectors, 0-> different vectors
    check = 0;
    len1 = length(vector_1);  len2 = length(vector_2);
    if len1 ~= len2
      error('vector size is different');
    end
    for column_num = 1:len1
       if vector_1(column_num,1) == vector_2(column_num,1)
         check = check + 1;
       end
    end
    if check == len1,  check = 1;
     else    check = 0;
    end
end

function [flag,transition]=compare_vector_norm(transition)
    % stage index increased(flag = 1) : recalculate x_list(index,:)
    % stage index decreased(flag = 0) : in the previous stage, no candidate x_now in x_list
    % Input parameters
    %     flag : previous stage
    %     transition : stage number
    % Output parameters
    %    flag : next stage number is calculated from flag
    %    transition : next stage number
    global x_list x_pre x_metric x_now x_hat R radius_squared x_sliced len;
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
        x_pre = x_now;  x_metric = metric_temp;
        x_sliced = x_now;  transition = 1;       % restart
        flag = 2;  x_list=zeros(len,4); % initialization
        x_now=zeros(len,1);  % initialization
       else % new candidate vector has a larger ML metric
        transition = transition-1;  % go back to the previous stage
        flag =0;
      end
    end
end
