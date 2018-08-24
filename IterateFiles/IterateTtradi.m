
date = 20110909;
 time = [18 19 20 21 22 23];
% time = [07 08 09 10 11 12 13 14 15 16];

% date = 20110909;
% time = 23;
%  load('20110910traditionalInputs.mat')
  load('20110909traditionalInputs.mat');

    for i = 1:length(time)
        time_in = time(i);
        
        Traditional = TraditionalTemperatureIterate(H,date,time_in);
        
    end
    


