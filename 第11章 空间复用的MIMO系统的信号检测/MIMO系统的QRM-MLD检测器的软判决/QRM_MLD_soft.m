function [LLR]=QRM_MLD_soft(y,H,M)

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

QAM_table=[-3-3j, -3-j, -3+3j, -3+j, -1-3j, -1-j, -1+3j, -1+j, 3-3j, ...
              3-j, 3+3j, 3+j, 1-3j, 1-j, 1+3j, 1+j]/sqrt(10); 
norm_array=[norm(H(:,1))    norm(H(:,2))   norm(H(:,3)) norm(H(:,4))];
[X,I]=sort(norm_array); Reversed_order=wrev(I);
H_original=H; H=H(:,Reversed_order);
X_hat=zeros(4,1); X_hat_temp=zeros(4,1);
X_LLR=zeros(4,4); LLR=zeros(4,4); X_LLR2=zeros(4,4);
cost=10000;
%QR decomposition
[Q,R]=qr(H); y_tilde=Q'*y;
% 1st stage
norm_array=10000*ones(16,1);
for i=1:16
    norm_array(i)=abs(y_tilde(4)-R(4,4)*QAM_table(i))^2;
end
[T,Sorted_Index]=sort(norm_array); M_best_index_1=Sorted_Index(1:M);
% 2nd stage
M16_index=zeros(M*16,3); norm_array=zeros(M*16,1);
y_temp=[y_tilde(3); y_tilde(4)];
R_temp=[R(3,3) R(3,4);
         0     R(4,4)];
count=1;
for i=1:M
    x4_temp=QAM_table(M_best_index_1(i));
    for k=1:16
        x3_temp=QAM_table(k);
        norm_array(count)=norm(y_temp-R_temp*[x3_temp; x4_temp])^2;
        M16_index(count,2)=k;
        M16_index(count,3)=M_best_index_1(i);
        count=count+1;
    end
end
clear Sorted_Index; [T,Sorted_Index]=sort(norm_array);
M_best_index_2=M16_index(Sorted_Index(1:M),:);
% 3rd stage
norm_array=zeros(M*16,1);
y_temp=[y_tilde(2); y_tilde(3); y_tilde(4)];
R_temp=[R(2,2)  R(2,3)  R(2,4);
        0       R(3,3)  R(3,4);
        0       0       R(4,4)];

count=1;
for i=1:M
    x4_temp=QAM_table(M_best_index_2(i,3));
    x3_temp=QAM_table(M_best_index_2(i,2));
    for k=1:16
        x2_temp=QAM_table(k);
        norm_array(count)=norm(y_temp-R_temp*[x2_temp; x3_temp; x4_temp])^2;
        M16_index(count,1)=k;
        M16_index(count,2)=M_best_index_2(i,2);
        M16_index(count,3)=M_best_index_2(i,3);
        count=count+1;
    end
end
clear Sorted_Index; [T,Sorted_Index]=sort(norm_array);
M_best_index_3=M16_index(Sorted_Index(1:M),:);
% 4th stage
y_temp=y_tilde; R_temp=R;
cost0=ones(16,1)*100; cost1=ones(16,1)*100;
LLR=zeros(4,4); X_bit=zeros(16,1);
LLR_0=zeros(16,1); LLR_1=zeros(16,1);
for i=1:M
    x4_temp=QAM_table(M_best_index_3(i,3));
    x3_temp=QAM_table(M_best_index_3(i,2));
    x2_temp=QAM_table(M_best_index_3(i,1));
    X_bit(5:8)  =QAM16_slicer_soft(x2_temp);
    X_bit(9:12) =QAM16_slicer_soft(x3_temp);
    X_bit(13:16)=QAM16_slicer_soft(x4_temp);
    for k=1:16
        x1_temp=QAM_table(k);
        X_bit(1:4)=QAM16_slicer_soft(x1_temp);
        distance=norm(y_temp-R_temp*[x1_temp; x2_temp; x3_temp; x4_temp])^2;
        for kk=1:length(X_bit)
            if X_bit(kk)==0
                if distance<cost0(kk)
                    LLR_0(kk)=distance; cost0(kk)=distance;
                end
            elseif X_bit(kk)==1 
                if distance<cost1(kk)
                    LLR_1(kk)=distance; cost1(kk)=distance;
                end
            end
        end
    end
end
LLR_0(find(LLR_0==0))=2; %2 is used for non-existing bit values
LLR_1(find(LLR_1==0))=2; %2 is used for non-existing bit values
LLR(Reversed_order(1),:)=(LLR_0(1:4)-LLR_1(1:4))';
LLR(Reversed_order(2),:)=(LLR_0(5:8)-LLR_1(5:8))';
LLR(Reversed_order(3),:)=(LLR_0(9:12)-LLR_1(9:12))';
LLR(Reversed_order(4),:)=(LLR_0(13:16)-LLR_1(13:16))';