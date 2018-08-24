% adt or adt(config)
% 
% config is either a configuration structure or a config filename.
% 
% History:
% 
% 2012-03-22  haa  GluePRR01.m  changed adjrsq from 0.999 to 0.99 after manipulations on the temperature channels


function WaterVaporCalibration(config)

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

%% load reference soundings
% RS-92
fid = fopen(config.ini.dWV.RS92File);
C = textscan(fid,'%f%f%f%f%f%f%f','headerlines',50);
fclose(fid);
[ rs92.time, rs92.z, rs92.p, rs92.T, rs92.rh, rs92.ws, rs92.wd ]  = C{:};

% SnowWhite
fid = fopen(config.ini.dWV.SWFile);
C = textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','headerlines',100,'delimiter',';','emptyvalue',NaN);
fclose(fid);
[ sw.Rel_Time, sw.z,sw.wd,sw.ws,sw.p,sw.T,snd.rh_HC2,snd.DewHC2,sw.O3,sw.O3_norm,sw.TPump,sw.I_cells,sw.Flag,sw.LAT,sw.LON,sw.ALT,sw.VEL,sw.DIR,sw.STA,sw.SAT,sw.PDOP,sw.DIST,sw.ALD,sw.AZI,sw.ELE,sw.CR,sw.p_2,sw.Alt_from_Hypso,sw.T_REF,sw.T_A3,sw.T_A3K,sw.T_A13,sw.T_A14,sw.T_A15,sw.T_HC,sw.DP_HC2,sw.ELE,sw.GEO_ALT,sw.K_P,sw.P_GPS,snd.rh,sw.RH_HC2R_I,sw.RH_HC2R_IK,sw.RH_HC2R_IKS,sw.RH_HC2_K_LIM,sw.RH_HC2_S,sw.RH_MAX,sw.Dew,sw.rh,sw.Humidity,sw.TAU_I,sw.TAU_IS,sw.RH_HC2_LIM,sw.RH_HC2_K_MAX100,sw.DP_HC2_K,sw.DP_HC2_K_LIM,sw.I_SW_P,sw.T_SW_HS,sw.U_SW_1_5V,sw.U_SW_9V,sw.U_SW_ML,sw.CO_0_0,sw.CO_0_1,sw.CO_0_2,sw.CO_0_3,sw.CO_0_4,sw.CO_0_ID ]  = C{:};

% convert to mixing ratio
% rs92.mr = rh2spez( rs92.T+273.15, rs92.rh  , rs92.p   );
% sw.mr = rh2spez( sw.T+273.15, sw.rh  , sw.p   );

rs92.mr = rh2mr( rs92.T+273.15  , rs92.p, rs92.rh   );
sw.mr = rh2mr( sw.T+273.15  , sw.p, sw.rh   );

% remove nans
sw.z=sw.z(isnan(sw.mr)==0);
sw.mr=sw.mr(isnan(sw.mr)==0);
rs92.z=rs92.z(isnan(rs92.mr)==0);
rs92.mr=rs92.mr(isnan(rs92.mr)==0);


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

% Pretreat the inelastic scattering data
S2 = GlueWVN2(S1, config);
       
% Updates the info stored in GluingParameters
save(config.GlueCoef_filename, 'gluecoef');

%% calculate wv

dvariable   = H2O_Inversion_Auto(S2,config);


%% calculate C
z_ref = dvariable.Z.Combined + 491;
% interpolate sonde to lidar altitudes
[x ind]=makeXdistinct(sw.z);
sw.mr_i = interp1(sw.z(ind),sw.mr(ind),z_ref);
[x ind]=makeXdistinct(rs92.z);
rs92.mr_i = interp1(rs92.z,rs92.mr,z_ref);

ind = find(z_ref>config.ini.dWV.calibZinterval(1) & z_ref<config.ini.dWV.calibZinterval(2));
D1 = dvariable.Result.Std.Combined(ind);

% fit SnowWhite to sonde
D2 = sw.mr_i(ind);
[A, dA, q_inf, q_sup] = fit_lidar_to_sonde(D1, D2);
show_plot=1;
if show_plot == 1
    plot_fit(A, dA, D1, D2, q_inf, q_sup, sw, dvariable, z_ref, config, 'SnowWhite')
end

% fit RS92 to sonde
D2 = rs92.mr_i(ind);
[A, dA, q_inf, q_sup] = fit_lidar_to_sonde(D1, D2);
show_plot=1;
if show_plot == 1
    plot_fit(A, dA, D1, D2, q_inf, q_sup, rs92, dvariable, z_ref, config, 'RS92')
end


%% write coefficients to file

fid = fopen(config.ini.dWV.calibFile,'a');
fprintf(fid,'%s\t%5.2f\t%5.4f\r\n',datestr(config.t0,'yyyy-mm-dd HH:MM:SS'), A);
fclose(fid);

%% subroutines
function [A,dA,q_inf,q_sup] = fit_lidar_to_sonde(D1, D2)

% fit using y = a*x
ft = fittype({'x'});
[cf gof] = fit(D1,D2,ft);

A = cf.a;
conf = confint(cf);
dA = diff(conf(:,1))/2;

q_sup = ceil( max( [ A*D1 ; D2 ] ) );
q_inf = floor( min( [ A*D1 ; D2 ] ) );



function plot_fit(A, dA, D1, D2, q_inf, q_sup, snd, dvariable, z_ref, config, sondeStr)

figure
plot(A*D1,D2,'.'), axis square, hold on
plot([q_inf q_sup],[q_inf q_sup],'Color',[.65 .65 .65],'handleVisibility','off')
set(gca,'XMinorTick','on','YMinorTick','on','XLim',[q_inf q_sup],'YLim',[q_inf q_sup])
xlabel('MR_{LIDAR} (K)'); ylabel('MR_{SONDE} (K)')

text(q_inf+.05*(q_sup-q_inf),q_inf+.9*(q_sup-q_inf) ,sprintf('y = %0.2f * x)',A),'FontSize',14)
text(q_inf+.05*(q_sup-q_inf),q_inf+.8*(q_sup-q_inf) ,sprintf('Sigma A : %0.2f',dA),'FontSize',14)
legend('Linear fit',4)
title(sprintf('mixing ratio scatter plot\n%s',datestr(config.t0,'yyyymmddHHMMSS')))

xprint(fullfile(config.ini.dWV.calibDir,sprintf('WV_calib_%s_%s_scatter',sondeStr,datestr(config.t0,'yyyymmddHHMM'))),'eps');
close all

figure
plot(snd.mr,snd.z,'k')
hold
plot(A*dvariable.Result.Std.Combined,z_ref,'r')
ylim([600 10000])
ylabel('Height [m asl]')
xlabel('Mixing Ratio [g/kg]')
grid on
legend(sondeStr,'lidar')

xprint(fullfile(config.ini.dWV.calibDir,sprintf('WV_calib_%s_%s_profile',sondeStr,datestr(config.t0,'yyyymmddHHMM'))),'eps');
close all

