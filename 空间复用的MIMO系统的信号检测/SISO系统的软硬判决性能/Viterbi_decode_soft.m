function out_bits = Viterbi_decode_soft(rx_bits)
global prev_state;
global prev_state_outbits;
cum_metrics = -1e6*ones(64,1);
cum_metrics(1)=0;
tmp_cum_metrics=zeros(64,1);
max_paths=zeros(64,length(rx_bits)/2);
out_bits=zeros(1,length(rx_bits)/2);
for data_bit=1:2:length(rx_bits)
    for state = 1:64
        tmp_max_cum_metric=-1e7;
        path_metric1=prev_state_outbits(state,1,1)*rx_bits(data_bit)+prev_state_outbits(state,1,2)*rx_bits(data_bit+1);
        path_metric2=prev_state_outbits(state,2,1)*rx_bits(data_bit)+prev_state_outbits(state,2,2)*rx_bits(data_bit+1);
        if cum_metrics(prev_state(state,1)+1)+path_metric1>cum_metrics(prev_state(state,2)+1)+path_metric2
            tmp_cum_metrics(state)=cum_metrics(prev_state(state,1)+1)+path_metric1;
            max_paths(state,(data_bit+1)/2)=0;
        else
            tmp_cum_metrics(state)=cum_metrics(prev_state(state,2)+1)+path_metric2;
            max_paths(state,(data_bit+1)/2)=1;
        end
    end
    for state=1:64
        cum_metrics(state)= tmp_cum_metrics(state);
    end
    
end
state=0;
for data_bit=length(rx_bits)/2:-1:1;
    bit_estimate=rem(state,2);
    out_bits(data_bit)=bit_estimate;
    state=prev_state(state+1,max_paths(state+1,data_bit)+1);
end