function [temp, press, dens, alt] = US1976(date_in, time_in, alt_in)
%
% US 1976 standard atmosphere
%
% Taken from 
% http://www.engineeringtoolbox.com/standard-atmosphere-d_604.html

model_alt = [0
1000
2000
3000
4000
5000
6000
7000
8000
9000
10000
15000
20000
25000
30000
40000
50000
60000
70000
80000]'; % Metres

model_temp = [15.00
8.50
2.00
-4.49
-10.98
-17.47
-23.96
-30.45
-36.94
-43.42
-49.90
-56.50
-56.50
-51.60
-46.64
-22.80
-2.5
-26.13
-53.57
-74.51]' + 273.15; %Kelvin

model_press = [10.13
8.988
7.950
7.012
6.166
5.405
4.722
4.111
3.565
3.080
2.650
1.211
0.5529
0.2549
0.1197
0.0287
0.007978
0.002196
0.00052
0.00011]' * 10^4; % Pascals

model_dens = [12.25
11.12
10.07
9.093
8.194
7.364
6.601
5.900
5.258
4.671
4.135
1.948
0.8891
0.4008
0.1841
0.03996
0.01027
0.003097
0.0008283
0.0001846]' * 0.1; % kg / m^3

% Allow this function to be called without any input arguments. In this
% case, the model values are simply returned as-is.
if 1 < nargin
    % Don't care about date and time. There's just one atmosphere model.
    
    % No alt input. Use model vals
    if isnan(alt_in)
        alt_in = model_alt;
    end
    
    % interpolate the results
    temp = interp1(model_alt, model_temp, alt_in, 'PCHIP'); 

    % Interpolate the results
    press = interp1(model_alt, log(model_press), alt_in, 'linear');
    press = exp(press);

    % Interpolate the results
    dens = interp1(model_alt, log(model_dens), alt_in, 'linear');
    dens = exp(dens);

    % Copy profiles for every time
    temp = repmat(temp,length(time_in),1);
    press = repmat(press,length(time_in),1);
    dens = repmat(dens,length(time_in),1);
    alt = alt_in;
else
    temp = model_temp;
    press = model_press;
    dens = model_dens;
    alt = model_alt;
end
    



