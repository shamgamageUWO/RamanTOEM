function ASRatio = cleanASRdata(ASRatio, config)

% determine min alt with relerr>0.05
ind = find(ASRatio.relerr > config.ini.dASR.precision);
ind1 = min(ind);

% determine index of max altitude
ind = find(ASRatio.z<config.ini.dASR.maxalt);
ind2 = max(ind);

% take data from 1 to min([ind1 ind2])
ind = 1:min([ind1 ind2]);


ASRatio.z = ASRatio.z(ind);
ASRatio.profile = ASRatio.profile(ind);
ASRatio.abserr = ASRatio.abserr(ind);
ASRatio.relerr = ASRatio.relerr(ind);
ASRatio.signalratio = ASRatio.signalratio(ind);


try
    if ASRatio.errind(3)>length(Remp.z)
        ASRatio.errind(3) = length(ASRatio.z);
    end
catch
    ASRatio.errind(3) = length(ASRatio.z);
end