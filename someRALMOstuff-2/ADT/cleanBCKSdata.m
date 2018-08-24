function bcks = cleanBCKSdata(bcks, config)

% determine min alt with relerr>0.05
ind = find(bcks.relerr > config.ini.dBCKS.precision);
ind1 = min(ind);

% determine index of max altitude
ind = find(bcks.z<config.ini.dBCKS.maxalt);
ind2 = max(ind);

% take data from 1 to min([ind1 ind2])
ind = 1:min([ind1 ind2]);


bcks.z = bcks.z(ind);
bcks.profile = bcks.profile(ind);
bcks.abserr = bcks.abserr(ind);
bcks.relerr = bcks.relerr(ind);
bcks.signalratio = bcks.signalratio(ind);

try
    if bcks.errind(3)>length(Remp.z)
        bcks.errind(3) = length(bcks.z);
    end
catch
    bcks.errind(3) = length(bcks.z);
end
