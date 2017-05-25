clear, close all
b002=1; % Power of 1st ray of 1st cluster 
N=1000 ; % Number of channels
Lam=0.0233;
lambda=2.5;%射线到达指数分布因子
Gam=7.4;
gamma=4.3;
sigma_x=3; % Standard deviation of log-normal shadowing
%簇到达时间分布
subplot(221)
t1=0:300; 
p_cluster=Lam*exp(-Lam*t1); % ideal exponential pdf
h_cluster=exprnd(1/Lam,1,N);% # of random number are generated
[n_cluster x_cluster]=hist(h_cluster,25); % gets distribution
plot(t1,p_cluster,'k'), hold on
plot(x_cluster,n_cluster*p_cluster(1)/n_cluster(1),'k:');
legend('Ideal','Simulation')
title(['Distribution of Cluster Arrival Time, \Lambda=', num2str(Lam)])
xlabel('T_m-T_{m-1} [ns]'), ylabel('p(T_m|T_{m-1})')
%射线到达时间的分布
subplot(222)
t2=0:0.01:5;
p_ray=lambda*exp(-lambda*t2); % ideal exponential pdf
h_ray=exprnd(1/lambda,1,1000); % # of random number are generated
[n_ray,x_ray]=hist(h_ray,25); % gets distribution
plot(t2,p_ray,'k'), hold on
plot(x_ray,n_ray*p_ray(1)/n_ray(1),'k:');   % plotting graph
legend('Ideal','Simulation')
title(['Distribution of Ray Arrival Time, \lambda=', num2str(lambda)])
xlabel('\tau_{r,m}-\tau_{(r-1),m} [ns]')
ylabel('p(\tau_{r,m}|\tau_{(r-1),m})')
%信道脉冲响应
subplot(223)
[h,t,t0,np]= SV_model_ct(Lam,lambda,Gam,gamma,N,b002,sigma_x);
stem(t(1:np(1),1),abs(h(1:np(1),1)),'ko');
title('Generated Channel Impulse Response')
xlabel('delay[ns]');
ylabel('Magnitude')
%信道功率分布
subplot(224)
X=10.^(sigma_x*randn(1,N)./20);
[temp,x]=hist(20*log10(X),25);
plot(x,temp,'k-'), axis([-10 10 0 120])
title(['Log-normal Distribution, \sigma_X=',num2str(sigma_x),'dB'])
xlabel('20*log10(X)[dB]'), ylabel('Occasion')