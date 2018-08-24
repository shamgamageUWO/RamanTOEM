function [data, gluecoef] = GluePRR01(data, gluecoef)
% 
% _________________________________________________________________________
% 
% [data, gluecoef] = GluePRR01(data, gluecoef)
% Release 3 Version 3.1.
% _________________________________________________________________________
% 
% Glues Analog to Photon signals to prevent the use of over-satureted 
% Photon signals. The gluing is done using coefficients stored in 'gluecoef' 
% structure and/or fitting the signals to retieve best estiamte 
% for the coefficients.
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
%                       The stored signal [mV] is the mean per laser shot. 
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
%                       It is the mean per one second (and not per bin of 
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
% Each analog signal has an electrical offset. The electrical offsets are 
% needed to correct the 'Analog' signals before gluing them to 'Photon' 
% signals which are over-saturated at high amplitudes. To make the gluing 
% the analog signals have to be scaled to MHz by the coefficient a[MHz/mV]. 
% This coefficient need to be well known as well. 
%
% The signals JH and JL are high and low quantum number pure-rotational 
% singals from the PRR polychromator. The analog signal has electrical 
% offset which is variable and moreover is not constant along the profile.
% The electrical offset is estimated by fitting the 'Photon' and 'Analog' 
% signals within pre-defined amplitude region. That region is channel 
% specific and is important to be carefully chosen. The comparisson region 
% is 'stored' within 'gluecoef' structure (ADmin1 and PCmax1)
%
% If the variable 'constrained' is set to 0 then the scaling coefficient, 
% being the ratio of photon to analog signals, is estimated from the fit for
% the offset. This is required in case the scaling coefficient changes with
% the time, being dependent on the temperature of the power supplies of the 
% PMT detectors for example.
% 
% To prevent instabilities of the estimated offset (and scaling) it is
% possible to set the 'smoothcoeffs' to 1. In that case the last estimates
% from the fit are added to moving average. The number of averaged values 
% should be precisely adjusted to prevent 'bad' fit from influencing the 
% data retrieval, but still allow the soothed values to follow the change 
% of the offset (and scaling).
% 
% Functions: 
% ----------
% Desaturate, DesLambertW, SmoothCoeffs01, glueitP
%
% Files: 
% ------
% LW.mat, ttaa.mat - temp data with saling and offset for last 720 treatments
%
% History:
% 
% 2012-03-22  haa  changed adjrsq from 0.999 to 0.99 after manipulations on the temperature channels

constrained     = 0; %!!! should be constrained if the scaling is constant, but it appears it is not
store           = 1;
smoothcoeffs    = 0; 

adjrsq = 0.99;

% Defines the data to be extracted from LoadLicel
ChanName = {'JH','JH','JL','JL'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Offset fit and gluing

for n=1:2:length(ChanName) 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % offset fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    chan = ChanName{n};
    
    % Loads in 'data' the coefficients needed to correct and glue signals
    coeffs              = gluecoef.(chan).coeffs;   
    data.(chan).coeffs  = coeffs;
    
    if smoothcoeffs, 
        a       = coeffs.asmoothed;
        offset  = coeffs.offsetsmoothed;
    else
        a       = coeffs.a;
        offset  = coeffs.offset;
    end
    
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
    

    tempA = AnalogMean - offset;
    tempP = PhotonMean;
    
    % !!! Removes the daytime background from analig and photon signals 
    % Substract the first 133 bins that have AD noise and signal plathoe
    sb = 133; eb  = 1400;
    AnalogSM = smooth(tempA(sb:eb),20) - nanmean(tempA(end-2000:end));
    PhotonSM = smooth(tempP(sb:eb),20) - nanmean(tempP(end-2000:end));
    
    % Region from comparisson - from ADmin to PCmax
    ii = ( AnalogSM >= (coeffs.ADmin1) ) & ( PhotonSM <= (coeffs.PCmax1) );
         
    % Take the compare regio and restrict
    A = tempA(sb:eb);    P = tempP(sb:eb);
    A = A(ii);           P = P(ii);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if n == 1,
%         figure(1000); clf
%         subplot(3,1,1); hold on; plot(tempA,'k'); plot(A,'r'); hold off
%         subplot(3,1,2); hold on; plot(tempP,'k'); plot(P,'b'); hold off
%         subplot(3,1,3); plot(P, P./A);
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear ii AnalogSM PhotonSM
    
    try
        x=A; y=P;
         
        % The fit
        if ~constrained
            ft_ = fittype('a*(x-offset)',...
                'dependent',{'y'},'independent',{'x'},...
                'coefficients',{'a','offset'});
            fo_ = fitoptions('method','NonlinearLeastSquares','Robust','On');
            set(fo_, 'StartPoint',[a, 0]);%, 'Weights', A./max(A));
            
            [cf_,gof] = fit(x,y,ft_,fo_);
            
            temp = coeffvalues(cf_);
            a           = temp(1); % new value for the scaling 'a'
            offsetcorr  = temp(2);
            
            if gof.adjrsquare < adjrsq; %0.99965,
                % if the fit is not good get the onld value for 'a'
                a           = coeffs.a; 
                offsetcorr  = 0;
                %display('low accuracy of the fit for scaling');
                store       = 0;
            end
            %display(gof.adjrsquare);
            
        else
            aa = num2str(a);
            ft_ = fittype([aa,'*(x-offset)'],...
                'dependent',{'y'},'independent',{'x'},...
                'coefficients','offset');
            fo_ = fitoptions('method','NonlinearLeastSquares','Robust','On');
            set(fo_, 'StartPoint', 0);%, 'Weights', A./max(A));
            
            [cf_,gof] = fit(x,y,ft_,fo_);
            
            temp = coeffvalues(cf_);
            offsetcorr = temp(1);
            
            if gof.adjrsquare < adjrsq; %0.99965,
                offsetcorr = 0; 
            end
            
            %display(gof.adjrsquare);
        end
        
        clear aa A P x y fo_ ft_ temp
        
    catch
        
        % if something wrong takes the stored offset
        offsetcorr = 0;
        if ~constrained, a = coeffs.a; end;
        % new lines to avoid error haa, 2011-11-03 09:15 LT
        store = 0;
        gof.sse = -999;
        gof.rsquare = -999;
        gof.dfe = -999;
        gof.adjrsquare = -999;
        gof.rmse = -999;
        % new lines to avoid error haa, 2011-11-03 09:15 LT
        
    end
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Corrects the stored offset with the estimated correction
    offset = offset + offsetcorr;
    display(chan); display (offset);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The new scaling 'a' is estimated and stored to if ~constrained
    % a = a;
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stores the corrected offset
    
    if smoothcoeffs 
        
        if gof.adjrsquare >= adjrsq,
            coeffs = SmoothCoeffs01('offset', offset, coeffs); % set the new 'offset' in coeffs structure as well as 'offsets'
            data.(chan).coeffs = coeffs;
        else
            coeffs.offset = coeffs.offsetsmoothed;
            data.(chan).coeffs.offset = coeffs.offsetsmoothed;
        end
            
    else
        coeffs.offset = offset; % set the new offset in the coeffs and data
        data.(chan).coeffs.offset = coeffs.offset; 
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MAke use of scaling if estimated
    % Stores the new scaling 'a'
    
    if ~constrained,
        
        if smoothcoeffs 
            if gof.adjrsquare >= adjrsq,
                coeffs = SmoothCoeffs01('a', a, coeffs);
                data.(chan).coeffs = coeffs;
            else
                coeffs.a = coeffs.asmoothed;
                data.(chan).coeffs.a = coeffs.asmoothed;
            end
        else
            coeffs.a = a;
            data.(chan).coeffs.a = coeffs.a;
        end
        
        if store
            try load('ttaa.mat'); catch, temp = zeros(720,3); end
            t = datenum(data.GlobalParameters.Start(1,:));
            temp  = [temp(2:720,1:3); [t a offset]];
            save('ttaa.mat', 'temp');
        end
        
    else % if constrained
        % there is no estimation of the scaling 'a'    
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load new smoothed offset and scaling if is set 'smoothcoeffs'
    if smoothcoeffs,
        a       = coeffs.asmoothed;
        offset  = coeffs.offsetsmoothed;
    end
        
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Offset Correction , Desaturation, Gluing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Mean of data
    
    % Analog is corrected with the last estimate for offset
    Analog      = Analog - offset;
    AnalogMean  = AnalogMean - offset;
    
    % Photon is already desaturated
 
    % Combined - glues a*analog with photon signal
    Combined     = glueitP( Analog*a, Photon, coeffs.PCmax2 );
    CombinedMean = glueitP( AnalogMean*a, PhotonMean, coeffs.PCmax2 );
    
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
    data.(chan).Combined.fitokflag  = gof.adjrsquare > 0.9993;  
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reassign data for gluing coefficients
    gluecoef.(chan).coeffs = coeffs;
    
    clear Analog Photon Combined AnalogMean PhotonMean CombinedMean
    
end


end % function 