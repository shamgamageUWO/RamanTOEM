function ASRatio = BackScatteringRatio03_local(data, config)

% filter width in m
filter_width = config.ini.dASR.filter_width;

% degree of polynomial of filterh
K = config.ini.dASR.K;

% calibration constant
calibration = config.ini.dASR.constant;
precision = config.ini.dASR.precision;

% which signals to process
what = 'Combined';

% wavelengths
% lambda1 = data.Eb.Photon.Wavelength;
% lambda2 = data.Eb.Photon.Wavelength;

% range vectors
z_bsr  = data.Eb.(what).Range;
z_j=data.JL.(what).Range;

% signals
JL1 = nanmean(data.JL.(what).Signal,2);
JH1 = nanmean(data.JH.(what).Signal,2);

% Background correction
JL = CorrBkg(JL1,150,0,1);
JH = CorrBkg(JH1,150,0,1);

% MOLECULAR SIGNAL (based on total PRR)
Mo = JH + JL;

% ELASTIC SIGNAL
Eb2 = data.Eb.(what).SignalMean;     
Eb1 = CorrBkg(Eb2,150,0,1);
% interpolate the elastic signal to the JH and JL height vector
Eb=time_res_vector(Eb1,z_j,z_bsr)';

% signal ratio
SignalRatio = Eb./Mo;

% C_N
C_N = 1;

% differential transmission
dTr = 1;

% BSR
% calibration=nanmedian(Mo(z_j>4800 & z_j<8000)./Eb(z_j>4800 & z_j<8000));
R = calibration * C_N .* SignalRatio .* dTr ;


% error estimate

% 1/ ScaleFactor to convert from Mega Counts per second per shot to Number 
% counts for averaging time (1 min = 1800 shots) per bin
% Signal*Shots is matrix to vector multiplication to get the number of
% counts per bin for the averaged time defined by the number of laser shots
ScaleFactor = 150/data.JL.J_high.BinSize;
fdummy=data.JL.J_high.Signal;
fdummy(isnan(data.JL.(what).Signal))=0;
Shots       = data.JL.J_high.Shots;
fdummy_shots=Shots;
fdummy_shots(isnan(Shots))=0;
JLsum       = fdummy * fdummy_shots' / ScaleFactor;
% JLsum       = data.JL.(what).SignalMean.*nanmean(Shots) / ScaleFactor;
JLsig       = CorrBkg(JLsum, 150, 0, 1);

ScaleFactor = 150/data.JH.J_high.BinSize;
fdummy=data.JH.J_high.Signal;
fdummy(isnan(data.JH.(what).Signal))=0;
Shots       = data.JH.J_high.Shots;
fdummy_shots=Shots;
fdummy_shots(isnan(Shots))=0;
JHsum       = fdummy * fdummy_shots' / ScaleFactor;
% JHsum       = data.JH.(what).Signal * Shots' / ScaleFactor;
JHsig       = CorrBkg(JHsum, 150, 0, 1);

ScaleFactor = 150/data.Eb.Photon.BinSize;
fdummy=data.Eb.Photon.Signal;
fdummy(isnan(data.Eb.(what).Signal))=0;
Shots       = data.Eb.Photon.Shots;
fdummy_shots=Shots;
fdummy_shots(isnan(Shots))=0;
Ebsum       = fdummy * fdummy_shots / ScaleFactor;
% Ebsum       = data.Eb.(what).SignalMean.*nanmean(Shots) / ScaleFactor;
Ebsig       = CorrBkg(Ebsum, 150, 0, 1);

sigma   = abs(Ebsig./(JLsig + JHsig) .* sqrt( (Ebsum./(Ebsig.^2)) + ((JLsum+JHsum)./((JLsig+JHsig).^2)))); % error computation from the error propagation theory sqrt(sum((df/dxi*sigma_xi)^2)). Sigma_i for photon counting signal is equal to the square root of the number of detections, i.e. the square root of the photon counting signal


%% filtering

% standard altitude grid
z_ref = (z_j(1):30:12000)';
[Rf, sigma_f] = deal(nan(size(z_ref)));


for i = 1:length(z_ref)
    
    % find indices within filter window
    ind = find(z_j>z_ref(i)-filter_width/2 & z_j<z_ref(i)+filter_width/2);
    
    % determine filter width
    if mod(length(ind),2)==0
        F = length(ind)-1;
        ind = ind(1:end-1);
    else
        F = length(ind);
    end
    
    % design filter
    [~, G] = sgolay(K,F);
    
    % filter data
    Rf(i) = G(:,1)'*R(ind);
    
    % error
    sigma_f(i) = sqrt( G(:,1)'.^2 * sigma(ind).^2 ); % the resulting absolute error is smaller than sigma due to the digital filter
    
    
end

% vertical resolution
dz = NDACC_ResolDF(G(:,1))*data.Eb.Photon.BinSize*ones(size(z_ref));


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ASRatio.z           = z_ref;                    
ASRatio.profile     = Rf;
ASRatio.relerr      = (sigma_f./Rf).*100;          
ASRatio.abserr      = sigma_f; 

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

ASRatio.starttime   = datenum(data.GlobalParameters.Start.Licel(1,:));    
ASRatio.stoptime    = datenum(data.GlobalParameters.End.Licel(end,:));

