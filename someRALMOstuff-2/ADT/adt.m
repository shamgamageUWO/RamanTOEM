% adt or adt(config)
% 
% config is either a configuration structure or a config filename.
% 
% History:
% 
% 2012-03-22  haa  GluePRR01.m  changed adjrsq from 0.999 to 0.99 after manipulations on the temperature channels
% 2012-05-01  haa  gluePRR01.m replaced with gluePRR02.m.


function adt(config)

%%  configuration

if nargin==0
    config=setup('adt.conf');
else
    if isstruct(config)==0
        config=setup(config);
    end
end


%% take values from config
if isempty(config.t0)==1
    dv=datevec(now);
    t0=datenum(dv(1),dv(2),dv(3),dv(4),dv(5)-mod(dv(5),5),0);
    config.t0=t0;
else
    t0=config.t0;
end

if isfield(config,'T')==0
    T=30;
else
    T=config.T;
end

if isfield(config,'tint')==0
    tint=1;
else
    tint=config.tint;
end

% give a message
disp(sprintf('processing %s to %s',datestr(t0-30/24/60,'yyyy-mm-dd HH:MM'),datestr(t0,'yyyy-mm-dd HH:MM')));

% load calibration constants if file is specified
config = getCalibration(config);



%% load level0 data
% find data files
warning('off','MATLAB:fileparts:VersionToBeRemoved');
files = FindFiles03( config.RawDataFolder,'data', t0 , T, tint, 1);

% number of files
Nfile=length(files);

if Nfile<2
    disp('no data files found ...');
    return
end

% load level0 data
S0 = LoadLicel(1,files);

if isstruct(S0)==0
    disp('error when loading data ...')
    return
end

% load laser power
power   = LaserPower02(files, datenum(S0.GlobalParameters.Start,'dd-mmm-yyyy HH:MM:SS'), datenum(S0.GlobalParameters.End,'dd-mmm-yyyy HH:MM:SS'), config.tint, 0, 0);

%% apply cloud filter
S0 = CloudFilter(S0);

%% correct level0 data

% Loads information for transient recorders and initial conditions
gluecoef    = LoadPretreatmentData03(config);

% shift analogue channels
S1 = AssignShift03(S0,config);
% S1a = AssignShift03(S0a,config);

% Pretreat the inelastic scattering data
S2 = GlueWVN2(S1, config);
       
% Pretreat the elastic scattering data
[S3, gluecoef]    = GlueAER02(S1, gluecoef);
% [S3a, gluecoef]    = GlueAER02(S1a, gluecoef);

% Pretreat the pure rotational data
% [S3, gluecoef]    = GluePRR01(S3, gluecoef);
S3    = GluePRR02(S3, config);


% Prepare raw data for attenuated backscatter retrieval
S4 = FileBinAverage04(S3, {'Es'}, config.ini.dABS.vertres);

% Updates the info stored in GluingParameters
% For now the iniGlue.mat is saved here
save(config.GlueCoef_filename, 'gluecoef');


%% retrieve parameters

% overlap function
% calcOverlap(S3,config);

%  retrieve WV
dvariable   = H2O_Inversion_Auto(S2,config);

% retrieve temperature
% Temp =  Temperature02(S3, config.ini.dTE.vertres, config.ini.dTE.precision, config.ini.dTE.constant);
Temp =  Temperature03(S3, config);

% retrieve asr
% ASRatio=AerosolScatteringRatio02(S3, config.ini.dASR.vertres, config.ini.dASR.precision, config.ini.dASR.constant);
ASRatio=AerosolScatteringRatio03(S3, config);

% retrieve aerosol backscatter
bcks=AerosolBackscatter01(ASRatio,config);

% retrieve attenuated backscatter
att = AttBScatt04(S4, power, config);

% retrieve extinction
Ext = [];


%% QC

% WV
[wv.altv, wv.mrv, wv.errv, wv.dz] = cleanData02(round(dvariable.Z.Combined), dvariable.Result.Std.Combined, dvariable.Error.Std.Combined, dvariable.dZ.Combined, config.ini.dWV.maxalt, config.ini.dWV.SmoothIt, config.ini.dWV.SmoothPoints);
wv.constant = dvariable.Result.Constant;

% P*z^2
[att.altv att.absv] = cleanAEdata(att, config);

% Temperature
Temp = cleanTdata(Temp, config);

% ASR
ASRatio = cleanASRdata(ASRatio, config);

% Backscatter
bcks = cleanBCKSdata(bcks, config);

% % recalibrate temperature with radiometer
if config.ini.dTE.MWRCalibrationDo == 1
    Temp = calibrateTempWithMWR(Temp, config);
end

%% save data

% create monthly output directory for treated data
if exist(fullfile(config.TreatedDataFolder,datestr(config.t0,'yyyymm')))~=7
    st=mkdir(fullfile(config.TreatedDataFolder,datestr(config.t0,'yyyymm')));
    if st==1
        config.TreatedDataFolder=fullfile(config.TreatedDataFolder,datestr(config.t0,'yyyymm'));
    else
        disp('could not create monthly treated data folder');
    end
else
    config.TreatedDataFolder=fullfile(config.TreatedDataFolder,datestr(config.t0,'yyyymm'));
end

% create yearly output directory for bulletins
if exist(fullfile(config.BulletinFolder,datestr(config.t0,'yyyy')))~=7
    st=mkdir(fullfile(config.BulletinFolder,datestr(config.t0,'yyyy')));
    if st==1
        config.BulletinFolder=fullfile(config.BulletinFolder,datestr(config.t0,'yyyy'));
    else
        disp('could not create monthly treated data folder');
    end
else
    config.BulletinFolder=fullfile(config.BulletinFolder,datestr(config.t0,'yyyy'));
end


st = storedataWV01(wv.altv, wv.mrv, wv.errv, S2, config.TreatedDataFolder, ...
    0, tint, Nfile, config.ini.dWV.vertres, t0, config.ini.dWV.constant);

st = storedataASR01(S3, ASRatio, config.TreatedDataFolder, ...
    config.localtimezone, 0, Nfile, config.ini.dASR.vertres, t0);

st = storedataTE01(S3, Temp, config.TreatedDataFolder, ...
    config.localtimezone, 0, Nfile, config.ini.dTE.vertres, t0);

st = storedataBCKS(S3, bcks, config.TreatedDataFolder, ...
    config.localtimezone, 0, Nfile, config.ini.dASR.vertres, t0);

st = storedataAE01(att.altv, att.absv, S4, config.TreatedDataFolder, ...
    config.localtimezone, 0, Nfile, config.ini.dABS.vertres, t0);

st = storedataBulletin01(S0, wv, Temp, ASRatio, Ext, att, config, t0);



