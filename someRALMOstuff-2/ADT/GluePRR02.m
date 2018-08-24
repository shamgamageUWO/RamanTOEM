function data = GluePRR02(data, config)
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

% constrained     = 0; %!!! should be constrained if the scaling is constant, but it appears it is not
% store           = 1;
% smoothcoeffs    = 0;

adjrsq = 0.8;

% Defines the data to be extracted from LoadLicel
ChanName = {'JH','JL'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Offset fit and gluing

for n=1:length(ChanName)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % offset fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    chan = ChanName{n};
    
    % Loads in 'data' the coefficients needed to correct and glue signals
    coeffs              = config.gluecoef.(chan).coeffs;
    data.(chan).coeffs  = coeffs;
    
    
    % rename variable
    z           = data.(chan).Photon.Range;
    Analog      = data.(chan).Analog.Signal;
    Photon      = data.(chan).Photon.Signal;
    Combined    = nan(size(Photon));
    a           = coeffs.a;
    
    % desaturate photoncounting
    Photon      = Desaturate(Photon,coeffs.f);
        
    % start loop over all signals
    for i=1:length(data.(chan).Photon.Time)
        
%         % don't glue if clouds are below CloudBaseThreshold
%         if min(data.CloudBase(i).z)<config.CloudBaseThreshold
%             disp(sprintf('%s: clouds below threshold, %s not glued', data.GlobalParameters.Start(1,:), chan));
%             continue
%         end
            
        % temp variables
        tempA = Analog(:,i);
        tempP = Photon(:,i);
        
        % Substract the first 133 bins that have AD noise and signal
        % plathoe and electric offset from AD channel
        sb = 133; eb  = 5000;
        AnalogSM = tempA(sb:eb) - min(tempA(end-2000:end));
        PhotonSM = tempP(sb:eb);
        zSM      = z(sb:eb);
        
        % Region from comparisson - from ADmin to PCmax
%         ii = find( AnalogSM >= (coeffs.ADmin1)  &  PhotonSM <= (coeffs.PCmax1) );
%         i1 = find( smooth(AnalogSM,20) >= (coeffs.ADmin1)  &  smooth(PhotonSM,20) <= (coeffs.PCmax1), 1, 'first' );
%         i2 = find( smooth(AnalogSM,20) >= (coeffs.ADmin1)  &  smooth(PhotonSM,20) <= (coeffs.PCmax1), 1, 'last' );
      
        % begin of gluing region
        i1 = find( flipud(smooth(PhotonSM,20)) > (coeffs.PCmax1), 1, 'first' );
        if isempty(i1)
            i1 = 1;
        else
            i1 = length(PhotonSM) - i1;
        end
        
        % find end of glueing region
        i2 = find( smooth(AnalogSM,20) >= (coeffs.ADmin1), 1, 'last' );
        
        % continue, if analog signal too weak
        if isempty(i2)
            disp('no overlap region found...');
            continue
        end
        
        % continue, if glueing region not well defined
        if i1>i2
            disp('no overlap retion found...')
            continue
        end
        
        
        
        ii = i1:i2;
        
        % return if ii is empty
        if isempty(ii)
            disp('no overlap region found...')
            continue
        end
        
        % Take the compare regio and restrict
        A = tempA(sb:eb);    P = tempP(sb:eb);
        A = A(ii);           P = P(ii);
        Z = zSM(ii);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %     if n == 1,
        %         figure(1000); clf
        %         subplot(3,1,1); hold on; plot(tempA,'k'); plot(A,'r'); hold off
        %         subplot(3,1,2); hold on; plot(tempP,'k'); plot(P,'b'); hold off
        %         subplot(3,1,3); plot(P, P./A);
        %     end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        clear ii AnalogSM PhotonSM
        
%         try
            x=A; y=P;
            
            % The fit
                ft_ = fittype('a*(x-offset)',...
                    'dependent',{'y'},'independent',{'x'},...
                    'coefficients',{'a','offset'});
                fo_ = fitoptions('method','NonlinearLeastSquares','Robust','On');
                set(fo_, 'StartPoint',[a, 0]);%, 'Weights', A./max(A));
                
                [cf_,gof] = fit(x,y,ft_,fo_);
                
                temp = coeffvalues(cf_);
                a           = temp(1); % new value for the scaling 'a'
                offset  = temp(2);
%                 
%                 if gof.adjrsquare < adjrsq; %0.99965,
%                     % if the fit is not good get the onld value for 'a'
%                     disp('glueing: quality of fit insufficient...')
%                     continue
%                 end
                %display(gof.adjrsquare);
                
                % determine PCmax2 and transition altitude
                PCmax2 = min(y) + (max(y)-min(y))/2;
%                 zPCmax2 = Z(find(y>PCmax2,1,'last'));
                zPCmax2 = Z(find(y>coeffs.PCmax2,1,'last'));
                if isempty(zPCmax2)
                    zPCmax2 = 0;
                end
                
                
%                 clf
%                  plot(Z,y)
%                  hold on
%                  plot(Z,a*(x-offset),'r')
%                 
%             clear aa A P x y fo_ ft_ temp Z
%             
%         catch
%             
%             % if something wrong takes the stored offset
%             offsetcorr = 0;
%             store = 0;
%             gof.sse = -999;
%             gof.rsquare = -999;
%             gof.dfe = -999;
%             gof.adjrsquare = -999;
%             gof.rmse = -999;
%             
%         end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Corrects the stored offset with the estimated correction
        display(sprintf('%s: offset = %.4f, z_trans = %i m', chan, offset, round(zPCmax2)));
                
                
        % Combined - glues a*analog with photon signal
        Combined(:,i)     = glueitP( a*(Analog(:,i)-offset), Photon(:,i), coeffs.PCmax2 );
%         Combined(:,i)     = glueitP( a*(Analog(:,i)-offset), Photon(:,i), PCmax2 );
        
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reassign data
    
    data.(chan).Combined.Range      = z;
    data.(chan).Analog.SignalMean   = nanmean(Analog,2);
    data.(chan).Photon.SignalMean   = nanmean(Photon,2);
    data.(chan).Combined.SignalMean = nanmean(Combined,2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Offset Correction , Desaturation, Gluing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Sum of data
    
    data.(chan).Analog.Signal       = Analog;
    data.(chan).Photon.Signal       = Photon;
    data.(chan).Combined.Signal     = Combined;
    data.(chan).Combined.fitokflag  = gof.adjrsquare > adjrsq;
        
    clear Analog Photon Combined AnalogMean PhotonMean CombinedMean
    
end


end % function