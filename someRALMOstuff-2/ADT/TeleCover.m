TeleCover(file1,file2,file3,file4,file5)

% load data
m1=LoadLicel(1,{file1});
m2=LoadLicel(1,{file2});
m3=LoadLicel(1,{file3});
m4=LoadLicel(1,{file4});
m0=LoadLicel(1,{file5});

%% select channel
channel = 5;

% photon/analogue
if m1.Channel(channel).isPhotonCounting == 1
    chstr = 'photon';
else
    chstr = 'analogue';
end

% wavelength
lambda = m1.Channel(channel).Wavelength;

% normalization interval in m
R1 = 3000;
R2 = 5000;

% date and time
t = datenum(m1.GlobalParameters.Start,'dd-mmm-yyyy HH:MM:SS');

% range
R = m1.Channel(channel).Range;

% background bin
bck_bin = 14000;

% range correction
Nrc=(m1.Channel(channel).Signal-median(m1.Channel(channel).Signal(bck_bin:end))).*R.^2;
Erc=(m2.Channel(channel).Signal-median(m2.Channel(channel).Signal(bck_bin:end))).*R.^2;
Src=(m3.Channel(channel).Signal-median(m3.Channel(channel).Signal(bck_bin:end))).*R.^2;
Wrc=(m4.Channel(channel).Signal-median(m4.Channel(channel).Signal(bck_bin:end))).*R.^2;
Drc=(m0.Channel(channel).Signal-median(m0.Channel(channel).Signal(bck_bin:end))).*R.^2;


% normalize interval 4 - 5 km to 1
N = Nrc / median(Nrc(R>R1 & R<R2));
E = Erc / median(Erc(R>R1 & R<R2));
S = Src / median(Src(R>R1 & R<R2));
W = Wrc / median(Wrc(R>R1 & R<R2));

% the mean profile
M = (N+S+W)/3;
% M = (N+E+S+W)/4;

% the relative differences
NDev = (N - M)./M*100;
EDev = (E - M)./M*100;
SDev = (S - M)./M*100;
WDev = (W - M)./M*100;

figure, hold on, box on, grid on
plot(R(R>100 & R<7000),smooth(NDev(R>100 & R<7000),50),'k');
plot(R(R>100 & R<7000),smooth(EDev(R>100 & R<7000),50),'y');
plot(R(R>100 & R<7000),smooth(SDev(R>100 & R<7000),50),'b');
plot(R(R>100 & R<7000),smooth(WDev(R>100 & R<7000),50),'g');
plot([100 7000],[10 10],'r--')
plot([100 7000],[-10 -10],'r--')
ylim([-50 50])
legend('N','E','S','W')
title(sprintf('PAY, RALMO, %s',datestr(t,'yyyy-mm-dd HH:MM')));
xlabel('Range [m]')
ylabel('Deviation from mean signal [%]')
text(1000,40,sprintf(' %i nm \n %s \n normalization interval: %i - %i', lambda, chstr, R1, R2));

% mean deviation between 3 and 7 km
mean(NDev(R>3000 & R<7000))
mean(EDev(R>3000 & R<7000))
mean(SDev(R>3000 & R<7000))
mean(WDev(R>3000 & R<7000))


%% write data to file to send to EARLINET
file = sprintf('py_telecover_%s_%inm_%s.txt',datestr(t,'yyyymmdd'),lambda,chstr);
fid = fopen(fullfile('C:','Users','haa','EARLINET','QCQA',file),'w');

fprintf(fid,'PY (Payerne)\n');
fprintf(fid,'RALMO\n');
fprintf(fid,'%i,%s\n',lambda,chstr);
fprintf(fid,'%s\n',datestr(t,'dd.mm.yyyy'));
fprintf(fid,'range, N, E, S, W, D\n');
fprintf(fid,'%f, %f, %f, %f, %f\n',[R N E S W D]');

fclose(fid);

%%



