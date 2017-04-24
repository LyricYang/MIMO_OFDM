function CFO_est=CFO_Classen(yp,Nfft,Ng,Nps)
% Frequency-domain CFO estimation using Classen method based on pilot tones

if length(Nps)==1
    Xp=add_pilot(zeros(1,Nfft),Nfft,Nps); 
else
    Xp=Nps; % If Nps is given as an array, it must be a pilot sequence Xp
end
Nofdm=Nfft+Ng; 
kk=find(Xp~=0); 
Xp=Xp(kk); % Extract pilot tones
for i=1:2 
   yp_without_CP = remove_CP(yp(1+Nofdm*(i-1):Nofdm*i),Ng);
   Yp(i,:) = fft(yp_without_CP,Nfft);
end
CFO_est = angle(Yp(2,kk).*Xp*(Yp(1,kk).*Xp)')/(2*pi)*Nfft/Nofdm; % Eq.(5.31)