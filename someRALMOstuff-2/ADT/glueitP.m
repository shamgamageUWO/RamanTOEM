function CO = glueitP(AD, PC, PCmax)
% Gluing function - glueitP(AD, PC, PCmax)
% Uses PCmax to glue scaled AD signal to PC signal
% AD         - analog signal, offset corrected, converted in MHz
% PC         - photon counting signal, MHz (desaturated!)
% PCmax    - maximum AD signal after which to take the AD signal and not PC   
%
% a       = 38.2; %MHz/mV for water vapor PMT 
% maxADmv = 1   ; % mV
%
n = 10; % moving average points  
 
CO = zeros(size(PC));
 
%AD is already converted in MHz
indPC = filtfilt(ones(1,n)/n,1,AD) <= PCmax;
% maxii = find(smooth(AD,n) == max(smooth(AD,n)));
% indPC(1:maxii) = 0;

CO = AD.*~indPC + PC.*indPC;

end
