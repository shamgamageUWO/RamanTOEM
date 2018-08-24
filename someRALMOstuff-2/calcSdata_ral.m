function [S,wv,power,Heigth_phc2an]=calcSdata_ral(config,sLevelProcess,subfolder)
%% set the loop over the time variable
if ischar(config)
    config=setup(config);
    config.t0=config.t(1);
end
T=config.T;
t0=config.t0;
tint=config.tint;

S=[];wv=[];power=[];Heigth_phc2an=[];
% give a message
disp(sprintf('processing %s to %s',datestr(t0-T/24/60,'yyyy-mm-dd HH:MM'),datestr(t0,'yyyy-mm-dd HH:MM')));

% Date folder definition
% load calibration constants if file is specified
config = getCalibration(config);



%% load level0 data
% find data files
warning('off','MATLAB:fileparts:VersionToBeRemoved');
% files = FindFiles03( config.RawDataFolder,[ '\' sYear '\' sMonth '\' sDay '\data'], t0 , T, tint, 0);
files = FindFiles03(config.RawDataFolder,subfolder, t0 , T, tint, 0);

if ~isempty(files{1}) % {:}
    % load level0 data
    S0 = LoadLicel(1,files); 
    if strcmp(sLevelProcess,'S0')
        S=S0;
    end
    % load laser power
%    power   = LaserPower02(files, datenum(S0.GlobalParameters.Start,'dd-mmm-yyyy HH:MM:SS'), datenum(S0.GlobalParameters.End,'dd-mmm-yyyy HH:MM:SS'), config.tint, 0, 0);
    if strcmp(sLevelProcess,'S0cl') || strcmp(sLevelProcess,'S1') || strcmp(sLevelProcess,'S2') || strcmp(sLevelProcess,'S_WV')
        % apply cloud filter
        S0 = CloudFilter(S0);
        if strcmp(sLevelProcess,'S0cl')
            S=S0;
        end
    end
    
    if strcmp(sLevelProcess,'S1') || strcmp(sLevelProcess,'S2') || strcmp(sLevelProcess,'S3') || strcmp(sLevelProcess,'S_WV')
        % correct level0 data
        
        % Loads information for transient recorders and initial conditions
        gluecoef = LoadPretreatmentData03(config);
        
        % shift analogue channels
        S1 = AssignShift03(S0,config);
        if strcmp(sLevelProcess,'S1')
            S=S1;
        end
    end
    
    if strcmp(sLevelProcess,'S2') || strcmp(sLevelProcess,'S_WV')
        % Pretreat the inelastic scattering data
        S2 = GlueWVN2(S1, config); % [S2,Heigth_phc2an] = GlueWVN2_local(S1, config); SICA
        if strcmp(sLevelProcess,'S2')
            S=S2;
        end
    end
    
    if strcmp(sLevelProcess,'S_WV')
        %  retrieve WV
        dvariable   = H2O_Inversion_Auto(S2,config);
        [wv.Combined.altv, wv.Combined.mrv, wv.Combined.errv, wv.Combined.dz] = cleanData02(round(dvariable.Z.Combined), dvariable.Result.Std.Combined, dvariable.Error.Std.Combined, dvariable.dZ.Combined, config.ini.dWV.maxalt, config.ini.dWV.SmoothIt, config.ini.dWV.SmoothPoints);
        [wv.Analog.altv, wv.Analog.mrv, wv.Analog.errv, wv.Analog.dz] = cleanData02(round(dvariable.Z.Analog), dvariable.Result.Std.Analog, dvariable.Error.Std.Analog, dvariable.dZ.Analog, config.ini.dWV.maxalt, config.ini.dWV.SmoothIt, config.ini.dWV.SmoothPoints);
        [wv.Photon.altv, wv.Photon.mrv, wv.Photon.errv, wv.Photon.dz] = cleanData02(round(dvariable.Z.Photon), dvariable.Result.Std.Photon, dvariable.Error.Std.Photon, dvariable.dZ.Photon, config.ini.dWV.maxalt, config.ini.dWV.SmoothIt, config.ini.dWV.SmoothPoints);
        wv.constant = dvariable.Result.Constant;
        S=wv;
    else
        wv=[];
    end
    if strcmp(sLevelProcess,'S3')
        % Pretreat the elastic scattering data
        S3 = GlueAER02(S1, gluecoef);
        % [S3a, gluecoef]    = GlueAER02(S1a, gluecoef);
        
        % Pretreat the pure rotational data
        S3 = GluePRR02(S3, config);
        % retrieve asr
        S=AerosolScatteringRatio03(S3, config);
    end
    
end
