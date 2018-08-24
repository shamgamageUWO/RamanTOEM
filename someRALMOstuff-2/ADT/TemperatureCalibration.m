% adt or adt(config)
% 
% config is either a configuration structure or a config filename.
% 
% History:
% 
% 2012-03-22  haa  GluePRR01.m  changed adjrsq from 0.999 to 0.99 after manipulations on the temperature channels


function TemperatureCalibration(config)

%%  configuration

if nargin==0
    config=setup('adt_calib.conf');
else
    if isstruct(config)==0
        config=setup(config);
    end
end


%% take values from config
if isempty(config.t0)==1
    dv=datevec(now);
    t0=datenum(now-mod(2*now,1)/2);
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

%% apply cloud filter
S0 = CloudFilter(S0);

for i=1:length(S0.Channel(9).Time)
    
    if isempty(S0.CloudBase(i).z)==0
        disp('Clouds detected. Calibration not possible...')
        return
    end
    
end


%% correct level0 data

% Loads information for transient recorders and initial conditions
gluecoef    = LoadPretreatmentData03(config);

% shift analogue channels
S1 = AssignShift03(S0,config);
       
% Pretreat the elastic scattering data
[S3, gluecoef]    = GlueAER02(S1, gluecoef);

% Pretreat the pure rotational data
% [S3, gluecoef]    = GluePRR01(S3, gluecoef);
S3    = GluePRR02(S3, config);

% Updates the info stored in GluingParameters
save(config.GlueCoef_filename, 'gluecoef');

%% load/calculate temperature

% retrieve temperature with A=1 and B=0;
% Temp =  Temperature02(S3, config.ini.dTE.vertres, config.ini.dTE.precision, config.ini.dTE.constant);
Temp =  Temperature03(S3, config);
Temp.z = Temp.z + 491;

% load sounding
snd = get_sounding_from_files(datestr(config.t0,'yyyymmddHHMMSS'),datestr(config.t0,'yyyymmddHHMMSS'),Temp.z,'data_dir',config.SoundingDataFolder);


%% calculate A and B

ind = find(Temp.z>config.ini.dTE.calibZinterval(1) & Temp.z<config.ini.dTE.calibZinterval(2));
D1 = 1./Temp.profile(ind);
D2 = snd.T(ind);

% fit using y = a/(x+b)

ft=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
fo = fitoptions('method','NonlinearLeastSquares','Robust','On');
set(fo, 'StartPoint',[350, 0.3]);

[cf gof] = fit(D1,D2,ft,fo);

A = cf.a;
B = cf.b;
conf = confint(cf);
dA = diff(conf(:,1))/2;
dB = diff(conf(:,2))/2;

q_sup = ceil( max( [ A./(D1+B) ; D2 ] ) );
q_inf = floor( min( [ A./(D1+B) ; D2 ] ) );

show_plot=1;
if show_plot == 1,
    
    figure
    plot(A./(D1+B),D2,'.'), axis square, hold on
    plot([q_inf q_sup],[q_inf q_sup],'Color',[.65 .65 .65],'handleVisibility','off')
    set(gca,'XMinorTick','on','YMinorTick','on','XLim',[q_inf q_sup],'YLim',[q_inf q_sup])
    xlabel('T_{LIDAR} (K)'); ylabel('T_{SONDE} (K)')
    
    text(q_inf+.05*(q_sup-q_inf),q_inf+.9*(q_sup-q_inf) ,sprintf('y = %0.2f/(x+%0.3f)',A,B),'FontSize',14)
    text(q_inf+.05*(q_sup-q_inf),q_inf+.8*(q_sup-q_inf) ,sprintf('Sigma A : %0.2f',dA),'FontSize',14)
    text(q_inf+.05*(q_sup-q_inf),q_inf+.7*(q_sup-q_inf) ,sprintf('Sigma B : %0.2f',dB),'FontSize',14)
    legend('Linear fit',4)
    title(sprintf('Temperature scatter plot\n%s',datestr(config.t0,'yyyymmddHHMMSS')))
    
    xprint(fullfile(config.ini.dTE.calibDir,sprintf('Temp_calib_%s_scatter',datestr(config.t0,'yyyymmddHHMM'))),'eps');
    close all
    
    figure
    plot(snd.T,snd.gph,'k')
    hold
    plot(A./(1./Temp.profile+B),Temp.z,'r')
    ylim([500 10000])
    ylabel('Height [m asl]')
    xlabel('Temp. [K]')
    grid on
    legend('sonde','lidar')
    
    xprint(fullfile(config.ini.dTE.calibDir,sprintf('Temp_calib_%s_profile',datestr(config.t0,'yyyymmddHHMM'))),'eps');
    close all
    
end

%% write coefficients to file

fid = fopen(config.ini.dTE.calibFile,'a');
fprintf(fid,'%s\t%5.2f\t%5.4f\r\n',datestr(config.t0,'yyyy-mm-dd HH:MM:SS'), A, B);
fclose(fid);


