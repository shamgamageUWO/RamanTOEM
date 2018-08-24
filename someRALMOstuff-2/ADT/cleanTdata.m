function Temp = cleanTdata(Temp, config)

% check if lidar temp profile available
if isempty(Temp.profile)==1
    disp('cleanTdata: No lidar temperature profile available.')
    return
end


% determine min alt with relerr>0.1
ind = find(Temp.abserr > config.ini.dTE.precision);
ind1 = min(ind);

% determine index of max altitude
ind = find(Temp.z<config.ini.dTE.maxalt);
ind2 = max(ind);

% take data from 1 to min([ind1 ind2])
ind = 1:min([ind1 ind2]);


Temp.z = Temp.z(ind);
Temp.profile = Temp.profile(ind);
Temp.relerr = Temp.relerr(ind);
Temp.abserr = Temp.abserr(ind);
% Temp.SignalRatio = Temp.SignalRatio(ind);
% Temp.SignalRatio_relerr = Temp.SignalRatio_relerr(ind);
% Temp.SignalRatio_abserr = Temp.SignalRatio_abserr(ind);


try
    if Temp.errind(3)>length(Remp.z)
        Temp.errind(3) = length(Temp.z);
    end
catch
    Temp.errind(3) = length(Temp.z);
end