config = './adt.conf';
configTmp = setup(config);
config = setup(config);
clight = 299792458; %ISSI value
Rate = 30; % Hz
asrRaw = [];
WVcounts = [];
N2counts = [];
WVcountsA = [];
N2countsA = [];
shots = 0;
j = 0;
for i=1:1; %length(configTmp.t)
    config.t0 = configTmp.t(i);
%    SS2 = calcSdata_ral(config,'S2','data');
    S00 = calcSdata_ral(config,'S0','data');
    S3 = calcSdata_ral(config,'S3','data');
    S22 = calcSdata_ral(config,'S2','data');
    Swv = calcSdata_ral(config,'S_WV','data');
    S0.N2A = S00.Channel(5);
    S0.N2 = S00.Channel(6);
    S0.WVA = S00.Channel(7);
    S0.WV = S00.Channel(8);
    if ~isempty(S0) & ~isempty(S3)
        j = j + 1;
        dzRaw = S0.N2.Range(2) - S0.N2.Range(1);
        if S0.N2.Shots ~= 1
            jshots = mean(S0.N2.Shots);
%            y2HzRaw = clight ./ (2.*(jshots./1800).*Rate.*dzRaw);
            y2HzRaw = clight ./ (2.*jshots.*dzRaw);
% this is for 1800 shots (1 min)
            WVcts = S0.WV.Signal ./ (y2HzRaw./1e6);
            N2cts = S0.N2.Signal ./ (y2HzRaw./1e6);
% sum for total
            wct = sum(WVcts');
            n2ct = sum(N2cts');
%            WVctsA = S0.WVA.Signal;
%            N2ctsA = S0.N2A.Signal;
            WVctsA = S0.WVA.Signal ./ (y2HzRaw./1e6);
            N2ctsA = S0.N2A.Signal ./ (y2HzRaw./1e6);
            % reviesed 23 July 2015 to sum analog as well as digital
            wctA =  sum(WVctsA'); % WVctsA(:,1);
            n2ctA = sum(N2ctsA'); % N2ctsA(:,1); 
        else
            stop % check this code
            jshots = S0.N2.Shots;
            y2HzRaw = clight ./ (2.*(jshots./1800).*Rate.*dzRaw);
            wct = S0.WV.Signal ./ (y2HzRaw./1e6);
            n2ct = S0.N2.Signal ./ (y2HzRaw./1e6);
        end
        zASR = S3.z;
        f10 = find(zASR > 8000 & zASR < 9000); %10000
        meanout = mean(S3.profile(f10));
        asrm = S3.profile - meanout + 1;
        cut = find(zASR < 12000);
        zASR = zASR(1:cut(end));
        asrC = asrm(1:cut(end));
        asrRaw = [asrRaw asrC];
        WVcounts = [WVcounts wct];
        N2counts = [N2counts n2ct];
        WVcountsA = [WVcountsA wctA];
        N2countsA = [N2countsA n2ctA];
        shots = shots + jshots;
        timeEnd(j) = S3.stoptime; 
        deltaTime = (S3.stoptime-S3.starttime)*24*60*60;
        zCounts = S0.N2.Range;
    end
end

asr.z = zASR;
asr.asr = asrRaw;

outPath = '/Users/BobSica/Dropbox/matlab/matlabWork/fromMCH/ralmodata/';
save([outPath 'S0S3201503051230chan2.mat'], 'asr', 'zCounts', 'WVcounts',...
    'N2counts', 'WVcountsA', 'N2countsA', 'shots', 'deltaTime', 'timeEnd')
