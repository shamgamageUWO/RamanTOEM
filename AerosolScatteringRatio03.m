function ASRatio = AerosolScatteringRatio03(data, config,tin)

% filter width in m
filter_width = config.ini.dASR.filter_width;

% degree of polynomial of filter
K = config.ini.dASR.K;

% calibration constant
calibration = config.ini.dASR.constant;
precision = config.ini.dASR.precision;

% which signals to process
what = 'Combined';

% wavelengths
lambda1 = data.Eb.Photon.Wavelength;
lambda2 = data.Eb.Photon.Wavelength;

% range vector
z  = data.Eb.(what).Range;

% Sham adding these lines here
g = hour(data.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(data.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );

% from 2300 to 2330
% tin =Q.time_in;

starttime=find(g==tin & Minute==04);
endtime=find(g==tin & Minute==08);

JL = nanmean(data.JL.(what).Signal(:,starttime:endtime)');
JH = nanmean(data.JH.(what).Signal(:,starttime:endtime)');

JL=JL';
JH=JH';

% figure;semilogx(JL,z./1000,'b',JH,z./1000,'m')

% signals
% JL = data.JL.(what).SignalMean;
% JH = data.JH.(what).SignalMean;

% Background correction
bkg_ind = z > 40e3 & z<50e3;
JL = CorrBkg(JL,sum(bkg_ind),0,1);
JH = CorrBkg(JH,sum(bkg_ind),0,1);

% MOLECULAR SIGNAL
Mo = JH + JL;

% ELASTIC SIGNAL
% Eb = data.Eb.(what).SignalMean; 
Eb = nanmean(data.Eb.(what).Signal(:,starttime:endtime)');
Eb=Eb';
Eb = CorrBkg(Eb,sum(bkg_ind),0,1);

% signal ratio
SignalRatio = Eb./Mo;

% C_N
C_N = 1;

% differential transmission
dTr = 1;

% BSR
R = calibration * C_N .* Eb./Mo .* dTr ;

% figure;plot(R,z./1000,'r')
% hold on;

% error estimate

% 1/ ScaleFactor to convert from Mega Counts per second per shot to Number 
% counts for averaging time (1 min = 1800 shots) per bin
% Signal*Shots is matrix to vector multiplication to get the number of
% counts per bin for the averaged time defined by the number of laser shots
ScaleFactor = 150/data.JL.Photon.BinSize;
Shots       = data.JL.Photon.Shots(starttime:endtime);
JLsum       = data.JL.(what).Signal(:,starttime:endtime) * Shots / ScaleFactor;
JLsig       = CorrBkg(JLsum, 166, 0, 1);

ScaleFactor = 150/data.JH.Photon.BinSize;
Shots       = data.JH.Photon.Shots(starttime:endtime);
JHsum       = data.JH.(what).Signal(:,starttime:endtime) * Shots / ScaleFactor;
JHsig       = CorrBkg(JHsum, 166, 0, 1);

ScaleFactor = 150/data.Eb.Photon.BinSize;
Shots       = data.Eb.Photon.Shots(starttime:endtime);
Ebsum       = data.Eb.(what).Signal(:,starttime:endtime) * Shots / ScaleFactor;
Ebsig       = CorrBkg(Ebsum, 166, 0, 1);

sigma   = Ebsig./(JLsig + JHsig) .* sqrt( (Ebsum./(Ebsig.^2)) + ((JLsum+JHsum)./((JLsig+JHsig).^2)) );


%% filtering

% standard altitude grid
z_ref = [60:30:12000]'; % Sham changed this from 60 to 20. 12000 % 
[Rf sigma_f dz] = deal(nan(size(z_ref)));

% plot(Rf,z_ref./1000,'b')

for i = 1:length(z_ref)
    
    % find indices within filter window
    ind = find(z>z_ref(i)-filter_width/2 & z<z_ref(i)+filter_width/2);
    
    % determine filter width
    if mod(length(ind),2)==0
        F = length(ind)-1;
        ind = ind(1:end-1);
    else
        F = length(ind);
    end
    
    % design filter
    [B G] = sgolay(K,F);
    
    % filter data
    Rf(i) = G(:,1)'*R(ind);
    
    % error
    sigma_f(i) = sqrt( G(:,1)'.^2 * sigma(ind).^2 );
    
    
end
% plot(Rf,z./1000,'g')
% hold off
% legend('R','Rf before filter','Rf after filter')


% vertical resolution
dz = NDACC_ResolDF(G(:,1))*data.Eb.Photon.BinSize*ones(size(z_ref));


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ASRatio.z           = z_ref;                    
      
ASRatio.profile     = Rf;

ASRatio.abserr      = sigma_f;          
ASRatio.relerr      = Rf .* sigma_f; 

ASRatio.dz          = dz;

ASRatio.signalratio = SignalRatio;          
% ASRatio.calestimate = 1/freesignalratio; 
ASRatio.cal         = calibration;

% ASRatio.okflag      = sum(bad_ind(1:round(10e3/3.75/binave))) < 3; 
% It is ok if there is no smaller scattering ratio than 0.98 for less than
% 300 m form ground to 10 km.
ASRatio.okflag      = sum(smooth(Rf,300/30) < .98);
ASRatio.errind      = find((sigma_f > precision), 3, 'first'); 

% Gives the index of the profile where the relative error is > 5 %

ASRatio.starttime   = datenum(data.GlobalParameters.Start(1,:));    
ASRatio.stoptime    = datenum(data.GlobalParameters.End(end,:));

