function [data, gluecoef] = GlueAER02(data, gluecoef)

% _________________________________________________________________________
% 
% [data, gluecoef] = GlueAER02(data, gluecoef)
% Release 3 Version 3.2.
% _________________________________________________________________________
% 
% Glues analog to photon signals using coefficients stored in 'gluecoef'. 
% 
% Inputs:
% -------
% data:     Structure created from 'AssignShift03' 
% gluecoef: Structure with gluing data loaded from 'LoadPretreatmentData02'
%
% Outputs:
% -------
% The output data structure includes the fields Analog, Photon, and 
% Combined. Within the Analog and Photon fields one can find the arrays:
% Signal, SignalMean, IniSignal. 
%
% 'Analog'  Includes the fields 'Signal' and 'SignalMean' that store arrays
%           with the analog signal in mV corrected for electrical offset.
%           
%           'Signal'    Array with dimentions (number bins x number files)
%                       The stored signal in mV as the mean per laser shot. 
% 
%           'SignalMean'    Array with dimentions (number bins x 1)
%                           The stored signal is averaged for the provided
%                           files.
%
% Photon    Includes the fields 'Signal' and 'SignalMean' that store arrays
%           with the Photon Counting signal in MHz that is corrected for    
%           saturation of the photon counter.
%          
%           'Signal'    Array with dimentions (number bins x number files)
%                       The stored signal is in MHz (10^6 counts per second)
%                       It is the mean per one second(and not per bin of 
%                       25 ns or 3.75m) at the altitude of the measurement,
%                       and it is the mean per laser shot. (!!!)
%
%           'SignalMean'    Array with dimentions (number bins x 1)
%                           The stored signal is averaged for the provided
%                           files and is again in MHz per laser shot.
% 
% 'Combined'    Includes the fields 'Signal' and 'SignalMean' that store 
%               the signals in MHz that are glued desaturated Photon and 
%               offset corrected Analog signals.
%               
%               'Signal'        -,,- (number bins x number files)
%               'SignalMean'    -,,- (number bins x 1)
% 
% 
% 'gluecoef'    The field includes the the gluing coeffisients 
% 
% Notes:
% ------
% The 'data' for input is retrieved by 'LoadLicel.mat'.
% The output 'data' has an additional field within each channel, which
% includes the coefficients that were used to glue the signals. 
%
% The electrical offset of Eb, elastic signal from the PRR polychromator,
% is estimated using the 'tail' of the the analog signal. It is corrected
% for daytime background by the 'tail' of the PC signal which is first
% desaturated and then is scaled to 'mV' using the scaling coefficient 'a'. 
%
% The electrical offset of the small elastic signal Es is estimated using
% hte same procedure as for the Eb signal. 
% 
% The offsets are used as to correct the 'Analog' signals before gluing.
% 
% Functions: 
% ----------
% Desaturate, DesLambertW, SmoothCoeffs01, glueitP
% Files: 
% ------
% LW.mat - includes data to perform paralyseable desaturation



% Defines the data to be extracted from LoadLicel
ChanName = {'Eb','Eb','Es','Es'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Offset fit and gluing

for n=1:2:length(ChanName) 
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % offset fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    chan = ChanName{n};
    
    % Loads in 'data' the coefficients needed to correct and glue signals
    coeffs              = gluecoef.(chan).coeffs;   
    data.(chan).coeffs  = coeffs;
    
    % Load data. Make averaging and desaturation
    Analog      = data.(chan).Analog.Signal;
    AnalogMean  = nanmean(Analog,2);
    
    Photon      = data.(chan).Photon.Signal;
    
    if ~coeffs.paralyse,
        Photon      = Desaturate(Photon,coeffs.f);  
    else
        load LW.mat;
        Photon      = Desaturate(Photon,coeffs.f);
        
    end
    
    PhotonMean  = nanmean(Photon,2);

    
%     if  strcmp(chan,'Eb');
        
        % Estimate the electrical offset of Eb and the daytime background
        % is sutracted from the photon signal which is rescaled to mV 
        
        signaltail          = nanmean( AnalogMean((end-2000):end) );
        opticalbackground   = nanmean( PhotonMean((end-2000):end)./coeffs.a ); % in mV
        
        offset              = signaltail - opticalbackground;
        
        clear signaltail opticalbackground
        
        if isnan(offset),
            % use previous estimate of offset
            offset = coeffs.offset;
        end
        
        % store the result
        data.(chan).coeffs.offset = offset;
        
        % to have as output of the function (option)
        % offsetEb = offset; 
        
%     else
%         % Extract the offset of Eb; Eb should be treated first
%         offsetEb = data.Eb.coeffs.offset;
%         % use rescaling of the Eb offset
%         offset = offsetEb * coeffs.scaleToEb;
%         if isnan(offset),
%             % use previous estimate of offset
%             offset = coeffs.offset;
%         end
%         % store the result
%         data.(chan).coeffs.offset = offset;   
%     end    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Offset Correction , Desaturation, Gluing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Mean of data 
    
    % Analog is corrected with the last estimate for offset
    Analog      = Analog - offset; 
    AnalogMean  = AnalogMean - offset;
    
    % Photon is already desaturated
    
    % Combined - glues a*analog with photon signal
    Combined     = glueitP( Analog*coeffs.a, Photon, coeffs.PCmax2 );
    CombinedMean = glueitP( AnalogMean*coeffs.a, PhotonMean, coeffs.PCmax2 );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reassign data
    
    data.(chan).Combined.Range  = data.(chan).Photon.Range;
    
    data.(chan).Analog.SignalMean   = AnalogMean;
    data.(chan).Photon.SignalMean   = PhotonMean;
    data.(chan).Combined.SignalMean = CombinedMean;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Offset Correction , Desaturation, Gluing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Sum of data 
    
    data.(chan).Analog.Signal       = Analog;
    data.(chan).Photon.Signal       = Photon;
    data.(chan).Combined.Signal     = Combined;
    
    clear Analog Photon Combined AnalogMean PhotonMean CombinedMean
    
end


end % function 

% Last changes: 
% The PC is furst desaturated and then it is averaged over the files 
% The Analog offset is estimated from the tail which is averaged and is
% substracted the optical background from the PC tail which is averaged. 