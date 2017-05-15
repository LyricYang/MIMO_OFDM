%不同天线增益情况下,自由空间的路径损耗随距离而变化的曲线图。
clear all, clf, clc%清除命令，清除图形，清除数据
fc=1.5e9;%载波频率1.5GHz
d0=100;%参考距离
sigma=3;%标准差
distance=[1:2:31].^2;%距离
Gt=[1 1 0.5];%发射天线增益
Gr=[1 0.5 0.5];%接受天线增益
Exp=[2 3 6]; 
for k=1:3
   y_Free(k,:)= PL_free(fc,distance,Gt(k),Gr(k));%自由空间的路径损耗
   y_logdist(k,:)= PL_logdist_or_norm(fc,distance,d0,Exp(k));%对数路径损耗模型
   y_lognorm(k,:)= PL_logdist_or_norm(fc,distance,d0,Exp(1),sigma); %对数正态阴影衰落模型
end
%自由路径损耗模型
figure(1);
semilogx(distance,y_Free(1,:),'k-o',distance,y_Free(2,:),'b-^',distance,y_Free(3,:),'r-s')
grid on, axis([1 1000 40 110]);
title(['Free PL Models, f_c=',num2str(fc/1e6),'MHz'])
xlabel('Distance[m]');
ylabel('Path loss[dB]');
legend('G_t=1, G_r=1','G_t=1, G_r=0.5','G_t=0.5, G_r=0.5');
%对数路径损耗模型
figure(2)
semilogx(distance,y_logdist(1,:),'k-o',distance,y_logdist(2,:),'b-^',distance,y_logdist(3,:),'r-s')
grid on, axis([1 1000 40 110]),
title(['Log-distance PL model, f_c=',num2str(fc/1e6),'MHz'])
xlabel('Distance[m]');
ylabel('Path loss[dB]');
legend('n=2','n=3','n=6');
%对数正态阴影路径损耗模型
figure(3)
semilogx(distance,y_lognorm(1,:),'k-o',distance,y_lognorm(2,:),'b-^',distance,y_lognorm(3,:),'r-s')
grid on, axis([1 1000 40 110]),
title(['Log-normal PL model, f_c=',num2str(fc/1e6),'MHz, ','\sigma=', num2str(sigma), 'dB'])
xlabel('Distance[m]');
ylabel('Path loss[dB]');
legend('path 1','path 2','path 2');