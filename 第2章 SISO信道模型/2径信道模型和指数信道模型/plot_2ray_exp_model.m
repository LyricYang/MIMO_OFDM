% plot_2ray_exp_model.m
clear, clf
scale=1e-9;                         % ns,数量级
Ts=10*scale;                        % Sampling time
t_rms=30*scale;                     % RMS delay spread
num_ch=10000;                       % # of channel
% 2-ray model
pow_2=[0.5 0.5]; 
delay_2=[0 t_rms*2]/scale;
H_2 = Ray_model(num_ch).'*sqrt(pow_2);
avg_pow_h_2 = mean(H_2.*conj(H_2));%conj共轭数 mean求均值
subplot(211);
stem(delay_2,pow_2);
hold on;
stem(delay_2,avg_pow_h_2,'r.');
xlabel('Delay[ns]');
ylabel('Channel Power[linear]');
title('Ideal PDP and simulated PDP of 2-ray model');
legend('Ideal','Simulation');  
axis([0 140 0 0.7]);
% Exponential model
pow_e=exp_PDP(t_rms,Ts); 
delay_e=(0:length(pow_e)-1)*Ts/scale;
H_e = Ray_model(num_ch).'*sqrt(pow_e);
avg_pow_h_e = mean(H_e.*conj(H_e));
subplot(212);
stem(delay_e,pow_e);
hold on;
stem(delay_e,avg_pow_h_e,'r.');
xlabel('Delay[ns]');
ylabel('Channel Power[linear]');
title('Ideal PDP and simulated PDP of exponential model');
legend('Ideal','Simulation'); 
axis([0 140 0 0.7]);