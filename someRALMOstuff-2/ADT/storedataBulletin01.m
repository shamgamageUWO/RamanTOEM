function st = storedataBulletin01(S0, wv, Temp, ASRatio, Ext, att, config, t0)

% output variable
st = 1;

if isempty(config.BulletinFolder)==1
    st=0;
    return
end

% check data availability
if length(wv.mrv)<2 && length(Temp.profile)<2 && length(ASRatio.profile)<2
    st=0;
    return
end

% turn off interpolation waring
warning('off','MATLAB:interp1:NaNinY');


% standard altitude levels
z_ground = 491;
z = [600:30:12000]';


% interpolate profiles (profiles in g/kg, K and errors in %)
% water vapor
if length(wv.mrv)>1
    spec_hum = interp1(wv.altv+z_ground,wv.mrv,z);
    spec_hum_err = interp1(wv.altv+z_ground,wv.errv,z)*100;
    spec_hum_dz = interp1(wv.altv+z_ground,wv.dz,z);
else
    spec_hum = nan(size(z));
    spec_hum_err = nan(size(z));
    spec_hum_dz = nan(size(z));
    wv.constant = [];
end

% Temperature
if length(Temp.profile)>1
    T = interp1(Temp.z + z_ground, Temp.profile, z);
    T_err = interp1(Temp.z + z_ground, Temp.relerr, z)*100;
else
    T = nan(size(z));
    T_err = nan(size(z));
    Temp.cal = [];
end

% ASR
if length(ASRatio.profile)>1
    ASR = interp1(ASRatio.z + z_ground, ASRatio.profile, z);
    ASR_err = interp1(ASRatio.z + z_ground, ASRatio.relerr, z)*100;
else
    ASR = nan(size(z));
    ASR_err = nan(size(z));
    ASRatio.cal = [];
end

% ABS
att.z = att.altv;
att.profile = nanmean(att.absv,2);
if length(att.profile)>1
    ABS = interp1(att.z + z_ground, att.profile, z);
else
    ABS = nan(size(z));
end


% the data matrix
data=[ones(size(spec_hum))*6610 z spec_hum spec_hum_err spec_hum_dz T T_err ASR ASR_err ABS];


% calculate parameters
shots = sum(S0.Channel(1).Shots);
t_int = 24*60*60*(datenum(S0.GlobalParameters.End(end,:),'dd-mmm-yyyy HH:MM:SS') - datenum(S0.GlobalParameters.Start(1,:),'dd-mmm-yyyy HH:MM:SS'));


% open file
file = fullfile(config.BulletinFolder, sprintf('%s_%s.bul',config.dwh.prod_name,datestr(t0,'yyyymmddHHMM')));
fid = fopen(file,'w');


% write file header
fprintf(fid,'000\n');
fprintf(fid,'%s %s\n',config.dwh.header,datestr(t0,'ddHHMM'));
fprintf(fid,'\n');

% write data header
dh = { ...
    'IIiii','06610', ...                                                % station IK
    'zzzzssss',datestr(t0,'yyyymmddHHMMSS'), ...                        % date
    'zxmccos0','2', ...                                                 % meas cat number
    'zxdscos0','38', ...                                                % data source ID
    'zxotcos0','30', ...                                                % obs type ID
    'zxracos0','1104', ...                                              % prof type ID
    'zliints0',sprintf('%i',round(t_int)), ...                          % integration time
    'zliplas0','', ...                                                  % laser power
    'zlicahs0',sprintf('%.4f',wv.constant), ...                         % water vapor calibration constant
    'zlicats0',sprintf('%.2f/%.4f',Temp.cal), ...                       % temperature calibration constants
    'zlicaas0',sprintf('%.4f',ASRatio.cal), ...                         % ASR calibration constant
    'zliclis0',sprintf('%i',shots), ...                                 % number of laser shots    
    };

dh = reshape(dh, 2, []);

fprintf(fid,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s',dh{1,:});
fprintf(fid,'\n');
fprintf(fid,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s',dh{2,:});
fprintf(fid,'\n');



% write data
dd = { ...
    'IIiii', ...                % station ID
    'zrealts0', ...             % height above sea level
    'zliusps0', ...             % specific humidity (g/kg)
    'zlieuss0', ...             % uncertainty in specific humidity (%)
    'zlivuss0', ...             % vertical resolution of specific humidity
    'zretu2s0', ...             % temperature in kelvin
    'zlietts0', ...             % uncertainty in temperature
    'zliasps0', ...             % ASR
    'zlieass0', ...             % uncertainty in ASR
    'zliabss0', ...             % ABS
    };
N = length(dd);                 % number of parameters

fprintf(fid,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s',dd{:});
fprintf(fid,'\n');
    
level_ok = find(sum(~isnan(data),2)>2);

for i=level_ok'
    % WMO ID
    k=1;
    if isnan(data(i,k))==0
        fprintf(fid,'%05i;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % height above sea level
    k=2;
    if isnan(data(i,k))==0
        fprintf(fid,'%i;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % specific humidity
    k=3;
    if isnan(data(i,k))==0
        fprintf(fid,'%.6f;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % uncertainty in specific humidity
    k=4;
    if isnan(data(i,k))==0
        fprintf(fid,'%.1f;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % vertical resolution of specific humidity
    k=5;
    if isnan(data(i,k))==0
        fprintf(fid,'%.1f;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % temperature in kelvin
    k=6;
    if isnan(data(i,k))==0
        fprintf(fid,'%.1f;',data(i,6));
    else
        fprintf(fid,';');
    end
    
    % uncertainty in temperature
    k=7;
    if isnan(data(i,k))==0
        fprintf(fid,'%.1f;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % ASR
    k=8;
    if isnan(data(i,k))==0
        fprintf(fid,'%.5f;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % uncertainty in ASR
    k=9;
    if isnan(data(i,k))==0
        fprintf(fid,'%.1f;',data(i,k));
    else
        fprintf(fid,';');
    end
    
    % ABS
    k=10;
    if isnan(data(i,k))==0
        fprintf(fid,'%.1f\n',data(i,k));
    else
        fprintf(fid,'\n');
    end
    
end

fclose(fid)




