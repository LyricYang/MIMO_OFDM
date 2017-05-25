% plot_UWB_channel.m
clear, clf
no_output_files = 0;  % non-zero: avoids writing output files of continuous-time responses
Ts = 0.167;        % sampling time (nsec)
num_ch=100; % number of channel impulse responses to generate
randn('state',12);  % initialize state of function for repeatability
rand('state',12);   % initialize state of function for repeatability
cm = 1;  % channel model number from 1 to 4
% get channel model params based on this channel model number
[Lam,lam,Gam,gam,nlos,sdi,sdc,sdr] = UWB_parameters(cm);
fprintf(1,['Model Parameters\n' ' Lam= %.4f, lam= %.4f, Gam= %.4f, gam= %.4f\n NLOS flag= %d, std_shdw= %.4f, std_ln_1= %.4f, std_ln_2= %.4f\n'],...
 Lam,lam,Gam,gam,nlos,sdi,sdc,sdr);
% get a bunch of realizations (impulse responses)
[h_ct,t_ct,t0,np] = UWB_model_ct(Lam,lam,Gam,gam,num_ch,nlos,sdi,sdc,sdr);
% now reduce continuous-time result to a discrete-time result
[hN,N] = convert_UWB_ct(h_ct,t_ct,np,num_ch,Ts);
% if we wanted complex baseband model or to impose some filtering function,
% this would be a good place to do it
h = resample(hN,1,N);  % decimate the columns of hN by factor N
h = h*N;  % correct for 1/N scaling imposed by decimation
channel_energy = sum(abs(h).^2);  % channel energy
h_len = size(h,1);
t = [0:(h_len-1)]*Ts;  % for use in computing excess & RMS delays
 
for k=1:num_ch
  % determine excess delay and RMS delay
  sq_h = abs(h(:,k)).^2/channel_energy(k);
  t_norm = t - t0(k);  % remove the randomized arrival time of first cluster
  excess_delay(k) = t_norm*sq_h;
  rms_delay(k) = sqrt((t_norm-excess_delay(k)).^2*sq_h);
  % determine # of significant paths (paths within 10 dB from peak)
  threshold_dB = -10;   % dB
  temp_h = abs(h(:,k));
  temp_thresh = 10^(threshold_dB/20)*max(temp_h);
  num_sig_paths(k) = sum(temp_h>temp_thresh);
  % determine number of sig. paths (captures x % of energy in channel)
  x = 0.85;
  temp_sort = sort(temp_h.^2);  % sorted in ascending order of energy
  cum_energy = cumsum(temp_sort(end:-1:1));  % cumulative energy
  index_e = min(find(cum_energy >= x*cum_energy(end)));
  num_sig_e_paths(k) = index_e;
end
energy_mean = mean(10*log10(channel_energy));
energy_stddev = std(10*log10(channel_energy));
mean_excess_delay = mean(excess_delay);
mean_rms_delay = mean(rms_delay);
mean_sig_paths = mean(num_sig_paths);
mean_sig_e_paths = mean(num_sig_e_paths);
 
fprintf(1,'Model Characteristics\n');
fprintf(1,'  Mean delays: excess (tau_m) = %.1f ns, RMS (tau_rms) = %1.f\n', ...
    mean_excess_delay, mean_rms_delay);
fprintf(1,'  # paths: NP_10dB =  %.1f, NP_85%% = %.1f\n', ...
    mean_sig_paths, mean_sig_e_paths);
fprintf(1,'  Channel energy: mean = %.1f dB, std deviation = %.1f dB\n', ...
  energy_mean, energy_stddev);
 
subplot(421), plot(t,h), grid on
title('Impulse response realizations'), xlabel('Time (nS)')
 
subplot(422), plot([1:num_ch], excess_delay, 'b-', ...
  [1 num_ch], mean_excess_delay*[1 1], 'r--' );
grid on, title('Excess delay (nS)'), xlabel('Channel number')
 
subplot(423), plot([1:num_ch], rms_delay, 'b-', ...
  [1 num_ch], mean_rms_delay*[1 1], 'r--' );
grid on, title('RMS delay (nS)'), xlabel('Channel number')
 
subplot(424), plot([1:num_ch], num_sig_paths, 'b-', ...
  [1 num_ch], mean_sig_paths*[1 1], 'r--');
grid on, title('Number of significant paths within 10 dB of peak')
xlabel('Channel number')
 
subplot(427), plot([1:num_ch], num_sig_e_paths, 'b-', ...
  [1 num_ch], mean_sig_e_paths*[1 1], 'r--');
grid on, title('Number of significant paths capturing > 85% energy')
xlabel('Channel number')
 
temp_average_power = sum(h'.*(h)')/num_ch;
temp_average_power = temp_average_power/max(temp_average_power);
average_decay_profile_dB = 10*log10(temp_average_power);
subplot(425), plot(t,average_decay_profile_dB); grid on
axis([0 t(end) -60 0]), title('Average Power Decay Profile')
xlabel('Delay (nsec)'), ylabel('Average power (dB)')
 
subplot(426)
figh = plot([1:num_ch],10*log10(channel_energy),'b-', ...
  [1 num_ch], energy_mean*[1 1], 'g--', ...
  [1 num_ch], energy_mean+energy_stddev*[1 1], 'r:', ...
  [1 num_ch], energy_mean-energy_stddev*[1 1], 'r:');
xlabel('Channel number'), ylabel('dB'), title('Channel Energy');
legend(figh, 'Per-channel energy', 'Mean', '\pm Std. deviation', 0)
 
if no_output_files, return;  end
%%% save continuous-time (time,value) pairs to files
save_fn = sprintf('cm%d_imr', cm);
% A complete self-contained file for Matlab users
save([save_fn '.mat'], 't_ct', 'h_ct', 't0', 'np', 'num_ch', 'cm');
% Two comma-delimited text files for non-Matlab users:
% File #1: cmX_imr_np.csv lisTs the number of paths in each realization
dlmwrite([save_fn '_np.csv'], np, ',');  % number of paths
% File #2: cmX_imr.csv can open with Excel
%     n'th pair of columns contains the (time,value) pairs for the n'th realization
th_ct = zeros(size(t_ct,1),2*size(t_ct,2));
th_ct(:,1:2:end) = t_ct;  % odd columns are time
th_ct(:,2:2:end) = h_ct; % even columns are values
fid = fopen([save_fn '.csv'], 'w');
if fid < 0,
  error('unable to write .csv file for impulse response, file may be open in another application');
end
for k = 1:size(th_ct,1)
  fprintf(fid,'%.4f,%.6f,', th_ct(k,1:end));
  fprintf(fid,'\r\n'); % \r\n for Windoze end-of-line
end
fclose(fid); 