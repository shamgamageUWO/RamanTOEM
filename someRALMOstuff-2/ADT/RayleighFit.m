RayleighFit(stop_str)

%% set defaults
RawDataFolder = 'F:\RALMO\level0\2012';
t = datenum(stop_str,'yyyymmddHHMMSS');
T = 30;
tint = 1;

% physical constants
k_b=1.380658E-23;

% channel
channel = 10;

% calibration rante
R1 = 10000;
R2 = 11000;

% background bin
bck_bin = 14000;


%% load level0 data
% find data files
warning('off','MATLAB:fileparts:VersionToBeRemoved');
files = FindFiles03( RawDataFolder,'data', t , T, tint, 1);

% number of files
Nfile=length(files);

if Nfile<2
    disp('no data files found ...');
    return
end

% load level0 data
m1 = LoadLicel(1,files);

if isstruct(S0)==0
    disp('error when loading data ...')
    return
end


%% photon/analogue
if m1.Channel(channel).isPhotonCounting == 1
    chstr = 'photon';
else
    chstr = 'analog';
end

% wavelength
lambda = m1.Channel(channel).Wavelength;

% range
R = m1.Channel(channel).Range;

% Molecular density (1/cm^3)
ScaleHeight = 8.771e+3;														% Approximative up to 10km
Nair        = 2.56e25 .* exp(-R/ScaleHeight) / 1e6;

Nair = interp1(snd.ptu.gph, snd.ptu.p*100 ./ k_b ./ snd.ptu.T, R+491) / 1e6;

% molecular backscatter coefficent (1/m/sr)
beta_mol = Nair * 5.45 * (550/lambda)^4 * 1e-28 * 1e2;

% Rayleigh scattering cross section (cm^2)
Ns = 2.547e19;
ns = 1e-8 * (5791817/(238.0185 -(1/lambda)^2) + 167909 / (57.362 - (1/lambda)^2)) + 1;
sigma = 24 * pi^3 * (ns^2 - 1)^2 / ((lambda*1e-9*100)^4 * Ns^2 * (ns^2 + 2)^2);

% Rayleigh extinction coefficient (1/m)
alpha_mol = Nair * sigma * 100;

% Rayleigh transmission (attenuation)
tr = exp(-2*cumsum(alpha_mol) * mean(diff(R)));

% attenuated backscatter
beta_att = tr.*beta_mol;

% calibration of lidar signal
Sm = mean(m1.Channel(channel).Signal,2);
pr2 = (Sm - mean(Sm(bck_bin:end))) .* R.^2;
pr2_cal = pr2 * (mean(beta_att(R>R1 & R<R2)) / mean(pr2(R>R1 & R<R2)));

% plot
figure, hold on, box on, grid on
plot(pr2_cal,R/1000)
plot(smooth(pr2_cal,50),R/1000,'y')
plot(beta_att,R/1000,'r')
title(sprintf('PAY, RALMO, %s',datestr(t,'yyyy-mm-dd HH:MM')));
ylabel('Range [km]')
xlabel('\beta_{att}^{mol} [1/m/sr]')
ylim([3 20])
legend('RALMO','RALMO smoothed','calc')

xl = get(gca,'XLim');
yl = get(gca,'YLim');
text(xl(1)+.5*diff(xl),yl(1)+.7*diff(yl),sprintf(' %i nm \n %s \n normalization interval: %i - %i km', lambda, chstr, R1/1000, R2/1000))

%% write data to file
file = sprintf('py_rayleighfit_%s_%inm_%s.txt',datestr(t,'yyyymmdd'),lambda,chstr);
fid = fopen(fullfile('C:','Users','haa','EARLINET','QCQA',file),'w');

fprintf(fid,'PY (Payerne)\n');
fprintf(fid,'RALMO\n');
fprintf(fid,'%i,%s\n',lambda,chstr);
fprintf(fid,'%s\n',datestr(t,'dd.mm.yyyy'));
fprintf(fid,'Payerne, 06610, %s, %sUT\n',datestr(t,'dd.mm.yy'), datestr(round(2*t)/2,'HH'));
fprintf(fid,'%i, %i\n', R1/1000, R2/1000);
fprintf(fid,'range, att RayleighBSC, RangeCorrectedSignal\n');
fprintf(fid,'%f, %d, %f\n',[R beta_att pr2]');

fclose(fid);





