function Temperature = Temperature03(data, config)
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

% use only signals with clouds higher than a given threshold
ind = ones(size(data.CloudBase));
for i=1:length(ind)
    if isempty(data.CloudBase(i).z)==0
        if min(data.CloudBase(i).z)<config.ini.dTE.minCloudBase
            ind(i)=0;
        end
    end
end

% return if no signals pass the cloud check
if sum(ind)==0
    disp('No temperature retrieval performed due to clouds.')
    Temperature.profile=[];
    return
end

% convert to logical
ind=logical(ind);
    
fitokflagJL = data.JL.Combined.fitokflag;
fitokflagJH = data.JH.Combined.fitokflag;
%%
% calibration constants
A = config.ini.dTE.constant(1);
B = config.ini.dTE.constant(2);

what = 'Combined';
z = data.JL.(what).Range;

what = 'Combined';
% JL = data.JL.(what).SignalMean;
JL = nanmean(data.JL.(what).Signal(:,ind),2);

what = 'Combined';
% JH = data.JH.(what).SignalMean; 
JH = nanmean(data.JH.(what).Signal(:,ind),2);

% Background correction
bkg_ind = z > 30e3 & z<35e3;
JL = CorrBkg(JL, sum(bkg_ind), 0,1);
JH = CorrBkg(JH, sum(bkg_ind), 0,1);

% Calculate the signal ratio
SignalRatio = JL./JH; 

% Calculate temperature
try
    LogRatio = log(SignalRatio);
    
    T = A./(LogRatio + B);
    
    T = real(T);
        
catch err
    
    T = nan(size(JL));
    
    warning([err.identifier,'  ', err.message] );
    
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Error estimate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
ScaleFactor = 150/data.JL.Photon.BinSize;
% Shots       = data.JL.Photon.Shots;
% JLsum       = data.JL.(what).Signal * Shots / ScaleFactor;
JLsum       = data.JL.(what).Signal(:,ind) * data.JL.Photon.Shots(ind) / ScaleFactor;
JLsig       = CorrBkg(JLsum, 166, 0, 1);

ScaleFactor = 150/data.JH.Photon.BinSize;
% Shots       = data.JH.Photon.Shots;
% JHsum       = data.JH.(what).Signal * Shots / ScaleFactor;
JHsum       = data.JH.(what).Signal(:,ind) * data.JH.Photon.Shots(ind) / ScaleFactor;
JHsig       = CorrBkg(JHsum, 166, 0, 1);

sigma        = ( (JHsum./(JHsig.^2)) + (JLsum./(JLsig.^2)) ).^0.5;


% filtering

% standard altitude grid
z_ref = [60:30:12000]';
[Tf sigma_f dz] = deal(nan(size(z_ref)));
filter_width=config.ini.dTE.filter_width;
K = config.ini.dTE.K;

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
    Tf(i) = G(:,1)'*T(ind);
    
    % error
    sigma_f(i) = sqrt( G(:,1)'.^2 * sigma(ind).^2 );
    
end

% vertical resolution
dz = NDACC_ResolDF(G(:,1))*data.Eb.Photon.BinSize*ones(size(z_ref));

%%


Temperature.z           = z_ref;
Temperature.profile     = Tf;
Temperature.relerr      = sigma_f * 100;
Temperature.abserr      = Tf   .*  sigma_f;
Temperature.dz          = dz;

% Temperature.SignalRatio         = SignalRatio;
% Temperature.SignalRatio_relerr  = SignalRatio_relerr;
% Temperature.SignalRatio_abserr  = SignalRatio_abserr;
Temperature.cal                 = config.ini.dTE.constant;

Temperature.okflag      = fitokflagJL * fitokflagJH; 

% Temperature.errind      = find((Temperature.abserr > precision), 3, 'first'); 
Temperature.errind      = 1:length(z_ref);
% Gives the index of the profile where the absolute error is > 3°

Temperature.starttime	= datenum(data.GlobalParameters.Start(1,:));    
Temperature.stoptime    = datenum(data.GlobalParameters.End(end,:));

end