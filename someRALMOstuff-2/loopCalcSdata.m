config = '/Users/BobSica/Dropbox/matlab/matlabWork/matlabOEM/qpackOEM/wvOEM/ralmodata/adt.conf';
configTmp = setup(config);
config = setup(config);
clight = 299792458; %ISSI value
Rate = 30; % Hz
asrRaw = [];
WVcounts = [];
N2counts = [];
shots = 0;
j = 0;
for i=1:length(configTmp.t)
    config.t0 = configTmp.t(i);
    S2 = calcSdata_ral(config,'S2','data');
    S3 = calcSdata_ral(config,'S3','data');
    if ~isempty(S2) & ~isempty(S3)
        j = j + 1;
        dzRaw = S2.N2.Photon.Range(2) - S2.N2.Photon.Range(1);
        if S2.N2.Photon.Shots ~= 1
            jshots = sum(S2.N2.Photon.Shots);
            y2HzRaw = clight ./ (2.*(jshots./1800).*Rate.*dzRaw);
            WVcts = S2.WV.Photon.Signal ./ (y2HzRaw./1e6);
            N2cts = S2.N2.Photon.Signal ./ (y2HzRaw./1e6);
            wct = sum(WVcts');
            n2ct = sum(N2cts');
        else
            jshots = S2.N2.Photon.Shots;
            y2HzRaw = clight ./ (2.*(jshots./1800).*Rate.*dzRaw);
            wct = S2.WV.Photon.Signal ./ (y2HzRaw./1e6);
            n2ct = S2.N2.Photon.Signal ./ (y2HzRaw./1e6);
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
        shots = shots + jshots;
        timeEnd(j) = S3.stoptime; %datenum(S2.GlobalParameters.Start);
%        timeEnd(j) = (S3.starttime+S3.stoptime)./2; %datenum(S2.GlobalParameters.Start);
        zCounts = S2.N2.Photon.Range;
    end
end

asr.z = zASR;
asr.asr = asrRaw;
save S2S3201503081230photon.mat asr zCounts WVcounts N2counts shots timeEnd

