function Temperature = Temperature01(data, binave, precision, calibration)
% 
% Temperature = Temperature01(data, binave, precision, calibration)
% Release 3 Version 1
% 
% Retreaves vertical temperature profile from the JH and JL signals using
% two coefficients for calibration. The signals are correspondingly the
% signals isolated form teh PRR polychromator consisting of spectral lines 
% with high and low quantum numbers from the pure-rotatiaoinal Raman 
% spectra of the atmopsheric nitrogen and oxygen. 
% 
% Inputs: 
% -------
% data:     The data structure from LoadLicel, that is transformed by 
%           'AssignShift03' and has passed the gluing functions 'GlueAER02' 
%           and 'GluePRR01'
% 
% binave:       The number of bins for vertical averaging (8 = 30 m)
%   
% precision:    Requred 'precision' defined here as the max allowed
%               relative error of the result
% 
% calibration:  The calibration coefficient for the ASR. It is the defined
%               as the reverse of the ratio of the aerosol to molecular 
%               scattered signal from atmospheric region with minimum aerosols. 
%               Note: The internal calibration is estimated from data 19 to
%               29 July 2010
% 
% Outputs: 
% --------
% Temperature:  Data structure with the result
% 
%   Temperature.z           -   Altitude vector [m]
% 
%   Temperature.profile     -   Temperature profile - T° K
%
%   Temperature.relerr      -	Relative error
% 
%   Temperature.abserr      -   Absolute error (2 Sigma)
%
%   Temperature.SignalRatio -   SignalRatio = JL / JH
% 
%   Temperature.SignalRatio_relerr  - Relative error of the signal ratio
% 
%   Temperature.SignalRatio_abserr  - Absolute error of the signal ratio
% 
%   Temperature.cal         - Used calibration coefficients [A, B]
%
%   Temperature.okflag      - If unity means that both fits for gluing of 
%                           JH and JL signals were with adjusted R squares
%                           bigger than 0.9993
% 
%   Temperature.errind      - Gives the index of the temperature profile 
%                           where the absolute error is > 3°
%
%   Temperature.starttime	-   Start time of the averaged files in matlab
%                           format for time 
% 
%   Temperature.stoptime    -   Stop time of the last averaged file 
% 
% Notes: 
% ------
% [1] Yu. F. Arshinov, et al., "Atmospheric Temperature Measurements Using 
% a Pure Rotational Raman Lidar," Appl. Opt. 22, (1983)
% [2] G. Vaughan et al., "Atmospheric temperature measurements made by 
% rotational Raman scattering", Appl. Opt. 32, (1993).
% 


if isnumeric(calibration)
    A = calibration(1);
    B = calibration(2);
else
    % Internal definition of calibration coeffs for temperature
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A = 370; B = -0.338;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if ~isnumeric(binave), binave = 16; end; % 60  m = 16  bin

if ~isnumeric(precision), precision = 3; end; % 3° abs error 
    



[b,a] = butter(1, 0.5e6/20e6, 'low'); % Nyqwist 20 MHz, cutoff .5 MHz = 75 m

fitokflagJL = data.JL.Combined.fitokflag;
fitokflagJH = data.JH.Combined.fitokflag;


%load('alt_vector');
%alt_vector = alt_vector - 491 + 30;
%bin = 3.75;

what = 'Combined';
z = data.JL.(what).Range;
z = BinAverage01(z, binave);
%z = BinAverageFAV1(z, alt_vector, bin, 0);

% what = 'Combined'; % original
what = 'Photon';
% what = 'Analog';
JL = data.JL.(what).SignalMean;
JL = filtfilt(b,a,JL);
JL = BinSum01( JL,binave );
%JL = BinSumFAV1(JL,alt_vector,bin);

what = 'Photon'; % original
% what = 'Combined';
% what = 'Analog';
JH = data.JH.(what).SignalMean; 
JH = filtfilt(b,a,JH);
JH = BinSum01( JH,binave );
%JH = BinSumFAV1(JH,alt_vector,bin);

% Background correction
bkg_ind = z > 30e3 & z<35e3;
JL = CorrBkg(JL, sum(bkg_ind), 0,1);
JH = CorrBkg(JH, sum(bkg_ind), 0,1);

% Smooth signal
JL = smooth(JL, 1/100, 'lowess');
JH = smooth(JH, 1/100, 'lowess');

% Calculate the signal ratio
SignalRatio = JL./JH; 

% Calculate temperature
try
    LogRatio = log(SignalRatio);
    
    T = A./(LogRatio' - B);
    
    T = real(T)';
    
    T = smooth(T, 1/100, 'rlowess'); % Use robust smooth !!!
    
catch err
    T = nan(size(JL));
    
    warning([err.identifier,'  ', err.message] );
    
end

% Clean negatives
bad_ind     = (T < 100);
T(bad_ind)  = nan;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error estimate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ScaleFactor = 150/(data.JL.Photon.BinSize);
% 1/ ScaleFactor to convert from Mega Counts per second per shot to Number 
% counts for averaging time (1 min = 1800 shots) per bin
Shots       = data.JL.Photon.Shots;
JLsum       = data.JL.(what).Signal * Shots / ScaleFactor;
% Signal*Shots is matrix to vector multiplication to get the number of
% counts per bin for the averaged time defined by the number of laser shots
JLsum       = BinSum01( JLsum, binave);
JLvar       = smooth (JLsum,1/100,'lowess');
JLsig       = CorrBkg(JLvar, 83, 0, 1);

ScaleFactor = 150/data.JH.Photon.BinSize;
Shots       = data.JH.Photon.Shots;
JHsum       = data.JH.(what).Signal * Shots / ScaleFactor;
JHsum       = BinSum01( JHsum, binave);
JHvar       = smooth (JHsum,1/100,'lowess');
JHsig       = CorrBkg(JHvar, 83, 0, 1);



% Relative error of the Signal Ratio
%SignalRatio_relerr        = ( 1./JHsum + 1./JLsum ).^0.5;
SignalRatio_relerr        = ( (JHvar./(JHsig.^2)) + (JLvar./(JLsig.^2)) ).^0.5;
SignalRatio_relerr        = smooth(SignalRatio_relerr, 1/100, 'rlowess'); % the same as T

% Absolute error of the Signal Ratio
% 2 sigma convention
% T error = 2 * sigma
SignalRatio_abserr   = 2 * SignalRatio .* SignalRatio_relerr;  

                     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Temperature.z           = z;
Temperature.profile     = T;
Temperature.relerr      = (T./A)        .*  SignalRatio_relerr;
Temperature.abserr      = ((T.^2)./A)   .*  SignalRatio_relerr;

Temperature.SignalRatio         = SignalRatio;
Temperature.SignalRatio_relerr  = SignalRatio_relerr;
Temperature.SignalRatio_abserr  = SignalRatio_abserr;
Temperature.cal                 = calibration;

Temperature.okflag      = fitokflagJL * fitokflagJH; 

Temperature.errind      = find((Temperature.abserr > precision), 3, 'first'); 
% Gives the index of the profile where the absolute error is > 3°

Temperature.starttime	= datenum(data.GlobalParameters.Start(1,:));    
Temperature.stoptime    = datenum(data.GlobalParameters.End(end,:));

end