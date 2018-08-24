function ASRatio = AerosolScatteringRatio02(data, binave, precision, calibration)
% 
% ASRatio = AerosolScatteringRatio02(data, binave, precision, calibration)
% Release 3 Version 2
% 
% Retrieves the aerosol scattering ratio. It is defined as the raio of
% the total backscaterreing coefficient to the molecular one.
% ASR = ( beta_mol + beta_aer ) / beta_mol
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
%               Note: The internal calibration estimated on 08 Aug 2010
% 
% Outputs: 
% --------
% ASRatio:  Data structure with the result
% 
%   ASRatio.z           -   Altitude vector
% 
%   ASRatio.profile     -   Clibration aerosol scattering ratio 
% 
%   ASRatio.abserr      -   Absolute error, 2*Sigma, 
% 
%   ASRatio.relerr      -   Relative error, 2*Sigma / ASR 
% 
%   ASRatio.signalratio -   Ratio of aerosol to molecular scattering; 
%                           The molecular scattering is the sum (JH + JL), 
%                           that is practically temperature dependent.
% 
%   ASRatio.calestimate -   It is the reverce of the minimum of the signal 
%                           ratio within the range from 500 m to 10 km.
%                           
%   ASRatio.cal         -   The calibration coefficient that was used
% 
%   ASRatio.okflag      -   Equals to unity if the scattering ratio is not 
%                           smaller than 0.98, or it is but for no more 
%                           than 300 m.
%                           Note: ASR > 1 by definition
%  
%   ASRatio.errind      -   Gives the index of where the profile has 
%                           relative error bigger than the defined within 
%                           'precision' (in terms of relative error) 
% 
%   ASRatio.starttime   -   Start time of the averaged files in matlab
%                           format for time 
% 
%   ASRatio.stoptime    -   Stop time of the last averaged file 
% 
% 
% Notes:
% ------
% The ASR is retrieved using the averaged Combined signals as indicated: 
% 
%	ASR = calibration * [Eb / (JH + JL) ]
% 
% The realtive error is retrieved from the variance of the signals: 
% 
%	RelErr = { var_Eb/s_Eb.^2 + (var_JL+var_JH)/(s_JL+s_JH)^2 }^0.5;
% 
%	var_Eb - sum of all counted photons in 8 bins for all laser shots that
%            were averaged (if the vertical averaging is over 8 bins)
%	s_Eb   - sum of all counted photons as in the variance but with 
%            subtracted background photons
% 
% The absolute error is retrieved (2 sigma !): 
%   
%	deltaASR = 2 * ( RelErr * ASR ) 
%


% if isnumeric(calibration), calibration = 1.19; end; %% originally not commented out!!!!

if ~isnumeric(binave), binave = 8 ; end;            % 30  m = 8  bin 
if ~isnumeric(precision), precision = 0.05; end;    % 5 % relative error

what = 'Combined';

[b,a] = butter(1, .5e6/20e6, 'low'); % Nyqwist 20 MHz, cutoff .5 MHz = 75 m      

z  = data.Eb.(what).Range;
z  = BinAverage01(z, binave);

JL = data.JL.(what).SignalMean; %(!!!)
JL = filtfilt(b,a,JL);
JL = BinAverage01( JL, binave);

JH = data.JH.(what).SignalMean; %(!!!)
JH = filtfilt(b,a,JH);
JH = BinAverage01( JH, binave);

% Background correction
bkg_ind = z > 45e3 & z<50e3;
JL = CorrBkg(JL,sum(bkg_ind),0,1);
JH = CorrBkg(JH,sum(bkg_ind),0,1);

% MOLECULAR SIGNAL
Mo = JH + JL;
Mo = smooth(Mo,1/100,'lowess');

% ELASTIC SIGNAL
Eb = data.Eb.(what).SignalMean;     
Eb = filtfilt(b,a,Eb);          
Eb = BinAverage01( Eb, binave);

Eb = CorrBkg(Eb,sum(bkg_ind),0,1);
Eb = smooth(Eb,1/100,'lowess');

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Signal Ratio %%%%%%%%%%%

SignalRatio = Eb ./ Mo;


% Calibration estimation from the minimum of asr
temp        = smooth(SignalRatio,1/100,'lowess');
freesignalratio  = min(temp (z>0.5e3 & z<10e3)); % self calibration

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aerosol scattering ratio 
% Calibration %%%%%%%%%%%%

ASRcal  = calibration*SignalRatio;


% Clean lower than 1
bad_ind = (ASRcal < .98);
ASRcal(bad_ind) = 1;

% Smooth

ASRcal  = smooth(ASRcal,1/300,'lowess');

ind     = find(z>5e3, 1, 'first');
ASRcal  = [ ASRcal(1:ind); smooth(ASRcal(ind+1:end),16); ]; 

ind     = find(z>8e3, 1, 'first');
ASRcal  = [ ASRcal(1:ind); smooth(ASRcal(ind+1:end),20); ]; 

ind     = find(z>10e3, 1, 'first');
ASRcal  = [ ASRcal(1:ind); smooth(ASRcal(ind+1:end),28); ];

ind     = find(z>15e3, 1, 'first');
ASRcal  = [ ASRcal(1:ind); smooth(ASRcal(ind+1:end),40); ];


%%
% 
% $$e^{\pi i} + 1 = 0$$
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error estimate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
ScaleFactor = 150/data.JL.Photon.BinSize;
% 1/ ScaleFactor to convert from Mega Counts per second per shot to Number 
% counts for averaging time (1 min = 1800 shots) per bin
Shots       = data.JL.Photon.Shots;
JLsum       = data.JL.(what).Signal * Shots / ScaleFactor;
% Signal*Shots is matrix to vector multiplication to get the number of
% counts per bin for the averaged time defined by the number of laser shots
JLsum       = BinSum01( JLsum, binave);
JLvar       = smooth(JLsum,1/100,'lowess');
JLsig       = CorrBkg(JLvar, 166, 0, 1);

ScaleFactor = 150/data.JH.Photon.BinSize;
Shots       = data.JH.Photon.Shots;
JHsum       = data.JH.(what).Signal * Shots / ScaleFactor;
JHsum       = BinSum01( JHsum, binave);
JHvar       = smooth(JHsum,1/100,'lowess');
JHsig       = CorrBkg(JHvar, 166, 0, 1);

ScaleFactor = 150/data.Eb.Photon.BinSize;
Shots       = data.Eb.Photon.Shots;
Ebsum       = data.Eb.(what).Signal * Shots / ScaleFactor;
Ebsum       = BinSum01( Ebsum, binave);
Ebvar       = smooth(Ebsum,1/100,'lowess');
Ebsig       = CorrBkg(Ebvar, 166, 0, 1);

% relative error
ASRcal_relerr   = ( (Ebvar./(Ebsig.^2)) + ((JLvar+JHvar)./((JLsig+JHsig).^2)) ).^0.5;
ASRcal_relerr   = smooth(ASRcal_relerr,1/100,'lowess');

% 2 sigma convention
% abs error = 2 * sigma
ASRcal_abserr   = 2 * ASRcal .* ASRcal_relerr;  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ASRatio.z           = z;                    
      
ASRatio.profile     = ASRcal;

ASRatio.abserr      = ASRcal_abserr;          
ASRatio.relerr      = ASRcal_relerr; 

ASRatio.signalratio = SignalRatio;          
ASRatio.calestimate = 1/freesignalratio; 
ASRatio.cal         = calibration;

ASRatio.okflag      = sum(bad_ind(1:round(10e3/3.75/binave))) < 3; 
% It is ok if there is no smaller scattering ratio than 0.98 for less than
% 300 m form ground to 10 km.
ASRatio.errind      = find((ASRcal_relerr > precision), 3, 'first'); 

% Gives the index of the profile where the relative error is > 5 %

ASRatio.starttime   = datenum(data.GlobalParameters.Start(1,:));    
ASRatio.stoptime    = datenum(data.GlobalParameters.End(end,:));

end
   