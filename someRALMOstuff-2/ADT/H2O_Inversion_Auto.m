% TD 18 May 2008: For 18 Feb 2008 19h45 with vertical averaging of 500 m 
% the inversion above 9 km gives error of 0.018 and mr = -0.00 g/kg ??????
% TD 29 Nov 2008: raw data smoothing 21 bin
function [Inversion,Lidar] = H2O_Inversion_Auto(Lidar,config)

% Accuracy=config.WV.Accuracy;
% Resolution=config.WV.vvert;
% Average=config.WV.Average;
% dT=config.WV.dT;
% Constant=config.WV.constant;

Precision=config.ini.dWV.precision;
Resolution=config.ini.dWV.vertres;
Average=config.ini.dWV.Average;
dT=config.ini.dWV.dT;
Constant=config.ini.dWV.constant;

AerosolCorrection   = 0; % Defines if to make aerosol correction
SumRelitveErrors    = 0; % if one than calculates relative error as sum of relative errors of WV and Nitro signals (not  Pablo's approach)
TimesSigma          = 2; %How many sigma to take for rel. err. estimation
                        
                 
if Precision > 1																% Correct for Percentual Input
    Precision = Precision/100;												% to obtain a value betwee 0 and 1
end



%If Lidar is not a structure than LoadLidar has stored LoadLidar.mat file
if ischar(Lidar) %If more than 100 files are loaded - Lidar = 'filename'
    multiple = 1;
    load('LoadLidar.mat','ndata')
    load('LoadLidar.mat','MaxNbrFiles')
    varstr=['data' num2str(ndata)];
    Ndata = ndata;
    clear ndata
    load('LoadLidar.mat',varstr);
    eval( ['Lidar=' varstr ';']);
    clear(varstr);
elseif isstruct(Lidar) % If less than 100 files are lodaded - Lidar comes from memory
    multiple = 0;
    Ndata=1;
end

    if ~exist('Lidar.z','var')
        Lidar.z = Lidar.WV.Analog.Range;
    end

    positive =@(x) x.*(x>0).*(isreal(x));

    % Simplified atmospheric model for molecular correction
    % Impact	for Std	Correction
    % 3km       1.7%
    % 7km		3.2%
    ScaleHeight = 8.771e+3;														% Approximative up to 10km
    Nmol        = 2.56e25 .* exp(-Lidar.z/ScaleHeight);							% Molecular profile

    % Raman wavelengths
    LambdaO2 = 375.42;
    LambdaN2 = 386.69;
    LambdaWV = 407.49;

    % Reference air constant [m^2*nm^4]
    SigmaRef    = 3.1335e-20;

    % Molecular extinction cross sections
    SigmaO2=SigmaRef./LambdaO2.^4;
    SigmaN2=SigmaRef./LambdaN2.^4;
    SigmaWV=SigmaRef./LambdaWV.^4;

    % Molecular Extinction
    TrO2 = exp(-cumtrapz(Lidar.z,Nmol*SigmaO2));
    TrN2 = exp(-cumtrapz(Lidar.z,Nmol*SigmaN2));
    TrWV = exp(-cumtrapz(Lidar.z,Nmol*SigmaWV));

    % Molecular Transmission
    MolCorr0 = TrN2 ./ TrWV;
    MolCorr1 = TrN2 ./ TrO2;

    %Aerosol correction parameters
    F=@(a,x) diff((1./a).^x/log(1./a));
    %angstrom_min = 0.0;
    angstrom_min = 2.0;

    angstrom_max = 2.0;
    angstrom = [angstrom_max angstrom_min];

    % Oxygen Channel used for Aerosol Correction
    if AerosolCorrection
        if abs(diff(angstrom)) > 0.001
            gamma = -...
                (F(LambdaWV,angstrom)-F(LambdaN2,angstrom))./...
                (F(LambdaO2,angstrom)-F(LambdaN2,angstrom));
        else
            % if the angstrom values are near the same use this value to correct
            % to avoid instabilities in previous formula
            gamma  = -...
                ((LambdaN2 / LambdaWV).^angstrom(1)-1)./...
                ((LambdaN2 / LambdaO2).^angstrom(1)-1);
        end
    else
        gamma  = 1;
    end
    %End of aerosol correction parameters

    K = {'Analog','Photon','Combined'};
    if AerosolCorrection
        N = {'O2','N2','WV'};
    else
        N = {'N2','WV'};
    end

    warning('off','MATLAB:divideByZero')



    %If Average Value ~= 0
    if Average>0
        if multiple % when more than 100 files - Lidar data from a file LoadLIdar.mat
            Start   = datenum(Lidar.GlobalParameters.Start);
            End     = datenum(Lidar.GlobalParameters.End);
            for ndata=Ndata-1:-1:1
                varstr = ['data' num2str(ndata)];
                load('LoadLidar.mat',varstr);
                eval(['Start = [datenum(' varstr '.GlobalParameters.Start);Start];']);
                clear(varstr);
            end
        else % when loaded less than 100 files - Lidar data is stored in memory
            Start   = datenum(Lidar.GlobalParameters.Start); % record of Standart Times of the starts of the files
            End     = datenum(Lidar.GlobalParameters.End);
            %Profiles = 1:size(Lidar.GlobalParameters.Start,1); %TD added
        end
        Ti    = Start(1);
        %Tf    = Start(end); 
        Tf    = End(end);
        % If you decide to fix the Start Point
        % @ hh:00, hh:15, hh:30, hh:45; then dT = 15
        % @ hh:00, hh:10, hh:20, hh:30, hh:40, hh:50; then dT = 10
        % @ hh:00, hh:05, hh:10, hh:15, hh:20, hh:25, ... ; then dT = 5
        % If dT Value ~= 0

        if dT
            Ti = fix(Start(1) * 24 * 60 / dT) / 24 / 60 * dT + (0.1/24/60/60); % Standart time is in days - time * 24 * 60 = seconds
        end

        % Create Sequence
        % In case there are enough files - make the average on them
        if (1440*(Tf - Ti))>=Average
            for k=fix(1440*(Tf - Ti)./Average) : -1 : 1 % number of coulumns defines how many times to execute the averaging
                Profiles(:,k) = ...
                    (Average .* (k-1)  <= (Start - Ti)*1440) &...
                    (Average .* (k  )  >  (Start - Ti)*1440);
            end
        else Profiles=(ones(length(Start),1));
        end
        % if not enough files

    elseif Average == 0
        %TD Added definition for Start??!! It was not executed for single file ??!!
        Start = datenum(Lidar.GlobalParameters.Start);
        %TD - in this case creates Profiles with columns equal to number of
        %files - this will not do averaging over the files
        Profiles = 1:size(Lidar.GlobalParameters.Start,1);
    else % if Average < 0 in general - when required all files to be averaged
        Start = datenum(Lidar.GlobalParameters.Start);
        Profiles = (1:(length(Start)))'; % Profiles = [1 2 3 4 ...]
    end



    %Main Loop
%     h=waitbar(0,'Treating Data');
    L = size(Profiles,2); % Number of times to run the averaging; index 2 - how many columns are in the Profiles
    percent = @(l,k,n) ((l-1)+((k-1)+((n-1)/length(N)))/length(K))/L;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Loop over the required times to average - Controlled by the number of    %
    %columns in Profiles                                                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for l=1:size(Profiles,2);   % on the Columns - 2 columns -> two times to run -> two sets of n files
        Profiles1=logical([]);
        if multiple
            %Find the datasets involved
            SegmentStart = (0:Ndata-1)*MaxNbrFiles+1;
            SegmentEnd   = min((1:Ndata)*MaxNbrFiles,length(Start));
            SegmentsUsed = 0;
            for ndata=1:Ndata
                %Profile Loader & Eraser
                varstr = ['data' num2str(ndata)];
                if ~any(Profiles(SegmentStart(ndata):SegmentEnd(ndata),l));
                    clear(varstr);
                else
                    Profiles1=[Profiles1;Profiles(SegmentStart(ndata):SegmentEnd(ndata),:)];
                    if ~exist(varstr,'var');
                        load('LoadLidar.mat',varstr);
                    end
                    SegmentsUsed = SegmentsUsed + 1;
                    if SegmentsUsed == 1
                        eval(['Lidar =' varstr ';'])
                    else
                        eval(['Lidar = Combine(Lidar,' varstr ');']);
                    end
                end
            end
        else
            Profiles1 = Profiles;
        end
        if ~exist('Lidar.z','var') %If the common z axis does not exists read the one from H2O
            Lidar.z = (Lidar.WV.Analog.Range);
        end
        if Average>0
            Inversion(l).Time = datestr(Ti + (l-1).*Average/1440); % on the first set of files assign the initial time Ti, for the second - add the 'Average'
            % Time is   %the start time of the file

        else %if Average==0 if it doesn't work
            Inversion(l).Time = Start(l);
        end

        if ~isempty(Profiles1)
            k=1; n=1;
%             waitbar(percent(l,k,n),h)
            % Create Time Stamp

            %Start Mode Loop (Analog, Photon Counting, Combined)
            for k=1:length(K) %K = {'Analog','Photon','Combined'}

                %Start Raman Wavelength Loop (Oxygen, Nitrogen, Water Vapor)
                %N = {'O2','N2','WV'};
                for n = 1:length(N)
%                     waitbar(percent(l,k,n),h)
                    %Background starts at 50 km
                    bkgbin = find(Lidar.z > 4e4,1,'first');
                    if isempty(bkgbin)												% If the sample doesn't reach 50 km then
                        bkgbin = find(Lidar.z > Lidar.z(end-500),1,'first');		% use the last 500 bins
                    end

                    DT	= Lidar.(N{n}).(K{k}).BinSize./150; % this is 1MHz*25ns = 0.025 TD
                    No	= Lidar.(N{n}).(K{k}).Shots;

                    if length(No)>1
                        No = No(Profiles1(:,l));
                    end

                    %Loads the result from LoadLidar
                    Inversion(l).(N{n}).(K{k}).Raw = Lidar.(N{n}).(K{k}).Signal(:,Profiles1(:,l)) * No * DT;
                    %
                    % Moving average smoothing with 11 bins = 41.25 m
                    % Inversion(l).(N{n}).(K{k}).Raw = smooth( Inversion(l).(N{n}).(K{k}).Raw , 11);
                    %
                    if k==1 %Analog - could be better to estimate Combined variance and to add the variance of the analog bkg - TD
                        Inversion(l).(N{n}).(K{k}).Var =...
                            repmat(...
                            var(Inversion(l).(N{n}).(K{k}).Raw(bkgbin:end)),...
                            size(Inversion(l).(N{n}).(K{k}).Raw)...
                            ); % variance of the background part
                        
                    elseif k==2 %Photon Counting
                        %If Photon Counting calculate the total variance as the total
                        %number of photon-counts per bin including the background
                        %Poisson Statistics (Sigma as sqrt(mean_value))
                        Inversion(l).(N{n}).(K{k}).Var = ...
                            Inversion(l).(N{n}).(K{k}).Raw; 

                    else %Combined -> Variance = (DesatPC^2)/(PC) ?????????
                        % changed -> Variance = smooth(DesatPC)+variance(backgound)
                        Inversion(l).(N{n}).(K{k}).Var = ...
                            smooth(smooth(Inversion(l).(N{n}).(K{2}).Raw,40),40)+...
                            max(var(Lidar.(N{n}).(K{2}).Signal(bkgbin:end,:)*mean(Lidar.(N{n}).(K{2}).Shots)*DT));
                        %smoothed profile of all received photons in bin->
                        %this is the Raw profile; it is added the variance
                        %of one of these profiles estimated at the tail
                        %Inversion(l).(N{n}).(K{k}).Var(isnan(Inversion(l).(N{n}).(K{k}).Var)) = 0; 
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Signal Bkg Substraction
                    %
                    
                    if k==1 %Analog
                        Inversion(l).(N{n}).(K{k}).Signal = ...
                            Inversion(l).(N{n}).(K{k}).Raw - mean(Inversion(l).(N{n}).(K{k}).Raw(bkgbin:end));
                        for iii = 1:10
                            Inversion(l).(N{n}).(K{k}).Signal = smooth( Inversion(l).(N{n}).(K{k}).Signal, 11, 'sgolay', 2);
                        end
                    else %Photon Counting
                        Inversion(l).(N{n}).(K{k}).Signal = ...
                            Inversion(l).(N{n}).(K{k}).Raw - median(Inversion(l).(N{n}).(K{k}).Raw(bkgbin:end));
                        for iii = 1:10
                            Inversion(l).(N{n}).(K{k}).Signal = smooth( Inversion(l).(N{n}).(K{k}).Signal, 11, 'sgolay', 2);
                        end
                    end
                    
%                     if k == 3 && n == 3
%                         figure(7);
%                         plot(Inversion(l).(N{n}).(K{k}).Signal);
%                     end
                    %TD: Here PR does not takes into account the added error
                    %from the substraction of the background. ?Maybe this is
                    %not big contribution but however it should be added?

                end %End Raman Loop. TD Comment: End of wavelength Loop

                %Start the Inversion Process
                MaxBin = round(max(Resolution)/Lidar.(N{n}).(K{k}).BinSize);		% Max resolution in bin units [15 150] -> [4 40] bins
                MinBin = round(min(Resolution)/Lidar.(N{n}).(K{k}).BinSize);		% Min resolution in bin units

                % The "m" position in the resulting water vapor profile is obtained
                % by treating the LIDAR data starting at position "m1" and ending
                % at position "m2". "L" stands for the total LIDAR profile length
                % L=length(Inversion(l).(N{n}).(K{k}).Signal);
                 L = 4000;
                
                % Initial conditions for the loop
                AddBin  = MinBin; % TD - bins which are added if not enough accuracy
                nn      = 0;  % new bin number - after averaging from m1 to m2 bins
                m1      = 16;  % to start averaging from 16th bin - 60 m
                m2      = m1; % to work properly leave it = 0
                
         
%---------------% Loop starts - adds up new bins to reduce error 
                while (m2<=L-AddBin)
                    nn = nn + 1;
                    m1 = m2 + 1;
                    Inversion(l).Error.Adv.(K{k})(nn,:)=1;
                   
                    % Loop to determine bins involved in the "n" point of the
                    % inversion:
                    % Conditions to enter in the loop:
                    % 1) End LIDAR point must be less or equal to the LIDAR
                    %    profile length
                    % 2) The error provides less accuracy than the one we need
                    % 3) The number of points analized (m2-m1+1) is bigger than the
                    %    minimum bin and smaller than the maximum bin

%-------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Adding of new bins to reduce error
                    while (m2<=L-AddBin) ...
                          &&...
                          ((Inversion(l).Error.Adv.(K{k})(nn)>Precision) ...
                          &&...
                          (m2-m1+1<MaxBin) || (m2-m1+1<MinBin))
                        %
                        %AddBin is added not one standard bin - TD
                        %
                           m2 = m2 + AddBin; 
                        %
                        %Error.Adv - Condition to trust the other results
                        if AerosolCorrection % original from Pablo
                            %Calculate the error with Oxygen correction
                            Inversion(l).Error.Adv.(K{k})(nn,:) =	sqrt(abs(...
                                (sum(Inversion(l).WV.(K{k}).Var(m1:m2))./sum(Inversion(l).WV.(K{k}).Signal(m1:m2)).^2 +...
                                (gamma.^2+1) .*	sum(Inversion(l).N2.(K{k}).Var(m1:m2))./sum(Inversion(l).N2.(K{k}).Signal(m1:m2)).^2 +...
                                (gamma  ).^2 .*	sum(Inversion(l).O2.(K{k}).Var(m1:m2))./sum(Inversion(l).O2.(K{k}).Signal(m1:m2)).^2)));
                            Inversion(l).Error.Adv.(K{k})(nn,:) = TimesSigma*Inversion(l).Error.Adv.(K{k})(nn,:);
                            %Calculates the error without Oxygen correction
                            Inversion(l).Error.Std.(K{k})(nn,:) = ...
                                sqrt(...
                                abs( sum(Inversion(l).WV.(K{k}).Var(m1:m2) ) )./...
                                (sum(Inversion(l).WV.(K{k}).Signal(m1:m2)).^2)...
                                +...
                                abs( sum(Inversion(l).N2.(K{k}).Var(m1:m2) ) )./...
                                (sum(Inversion(l).N2.(K{k}).Signal(m1:m2)).^2)...
                                );
                            Inversion(l).Error.Std.(K{k})(nn,:) = TimesSigma*Inversion(l).Error.Std.(K{k})(nn,:);
                        else    
                            if SumRelitveErrors %TD - in case of analog it is not true!
                            %-- Simple sum of relative errors of Nitro and water signals
                                Inversion(l).Error.Std.(K{k})(nn,:) = ...
                                    sqrt( abs( sum(Inversion(l).WV.(K{k}).Var(m1:m2) ) )./ ( sum(Inversion(l).WV.(K{k}).Signal(m1:m2)).^2 ) )...
                                    + ...
                                    sqrt( abs( sum(Inversion(l).N2.(K{k}).Var(m1:m2) ) )./ ( sum(Inversion(l).N2.(K{k}).Signal(m1:m2)).^2 ) );

                                Inversion(l).Error.Std.(K{k})(nn,:) = TimesSigma*Inversion(l).Error.Std.(K{k})(nn,:);
                            
                            else % TD - as Pablo calculates
                                Inversion(l).Error.Std.(K{k})(nn,:) = ...
                                    sqrt(...
                                    abs( sum(Inversion(l).WV.(K{k}).Var(m1:m2) ) )./(sum(Inversion(l).WV.(K{k}).Signal(m1:m2)).^2)...
                                    +...
                                    abs( sum(Inversion(l).N2.(K{k}).Var(m1:m2) ) )./(sum(Inversion(l).N2.(K{k}).Signal(m1:m2)).^2)...
                                    );
                                Inversion(l).Error.Std.(K{k})(nn,:) = TimesSigma*Inversion(l).Error.Std.(K{k})(nn,:);
                                
                            end
                            
                            Inversion(l).Error.Adv.(K{k})(nn,:) = Inversion(l).Error.Std.(K{k})(nn,:);
                        end

                    end
                    %
                    % Adding of new bins to reduce error
%-------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    %Calculate the concentration with Oxygen correction
                    if AerosolCorrection
                        Inversion(l).Result.Adv.(K{k})(nn,:) = ...
                            positive(...
                            Inversion(l).Result.Std.(K{k})(nn).*(...
                            mean(Inversion(l).O2.(K{k}).Signal(m1:m2)) ./...
                            mean(Inversion(l).N2.(K{k}).Signal(m1:m2)) .*...
                            mean(MolCorr1(m1:m2))).^gamma ...
                            );
                    else
                    %Calculate the concentration without Oxygen correction
                        Inversion(l).Result.Std.(K{k})(nn,:) = ...
                            positive(...
                            mean(Inversion(l).WV.(K{k}).Signal(m1:m2)) ./...
                            mean(Inversion(l).N2.(K{k}).Signal(m1:m2)) .*...
                            mean(MolCorr0(m1:m2))...
                            );
                    % Advanced result = Standard result   
                       Inversion(l).Result.Adv.(K{k})(nn,:) =  ...
                           Inversion(l).Result.Std.(K{k})(nn,:);
                    end
                    
                    %Calculate the altitude of the New bin as the mean of the
                    %start and stop altitudes used for averaging
                    %Inversion(l).Z.(K{k})(nn,:) = mean(Lidar.z(m1:m2));
                    %Inversion(l).Z.(K{k})(nn,:) = mean(Lidar.z(m1:m2))-Lidar.N2.(K{k}).BinSize/2;
                    Inversion(l).Z.(K{k})(nn,:) = mean(Lidar.z((m1-1):m2));
                    
                    %Calculate the new bin size in meters
                    Inversion(l).dZ.(K{k})(nn,:) = length(Lidar.z(m1:m2))*Lidar.N2.(K{k}).BinSize;

                    %Reconstruct the Raman channels at New bin resolution
                    if AerosolCorrection, O2(nn,:)=mean(Inversion(l).O2.(K{k}).Signal(m1:m2));end
                    N2(nn,:)=mean(Inversion(l).N2.(K{k}).Signal(m1:m2));
                    WV(nn,:)=mean(Inversion(l).WV.(K{k}).Signal(m1:m2));
                    
                    
                end
%---------------% Loop ends - adds up new bins to reduce error 

                if AerosolCorrection, Inversion(l).O2.(K{k}).Signal=O2; end
                Inversion(l).N2.(K{k}).Signal=N2;
                Inversion(l).WV.(K{k}).Signal=WV;
                Inversion(l).Result.Std.(K{k}) = Inversion(l).Result.Std.(K{k}) .* Constant;
                Inversion(l).Result.Adv.(K{k}) = Inversion(l).Result.Adv.(K{k}) .* Constant;
                Inversion(l).Result.Constant = Constant;
                Inversion(l).Result.Std.(K{k})( find(Inversion(l).Result.Std.(K{k})==0,1,'first'):end ) = NaN;
                Inversion(l).Result.Adv.(K{k})( find(Inversion(l).Result.Adv.(K{k})==0,1,'first'):end ) = NaN;
                clear O2 N2 WV
                
            end %Loop over K = {'Analog','Photon','Combined'}

        else %if ~isempty(Profiles1)
            %No data to fill the Inversion variable
            for n=1:length(N)
                for k=1:length(K)
                    Inversion(l).(N{n}).(K{k}).Raw		= nan(size(Inversion(l-1).(N{n}).(K{k}).Raw));
                    Inversion(l).(N{n}).(K{k}).Var		= nan(size(Inversion(l-1).(N{n}).(K{k}).Raw));
                    Inversion(l).(N{n}).(K{k}).Signal	= nan(size(Inversion(l-1).(N{n}).(K{k}).Raw));

                    Inversion(l).Z.(K{k})				= nan(size(Inversion(l-1).Z.(K{k})));
                    Inversion(l).dZ.(K{k})				= nan(size(Inversion(l-1).dZ.(K{k})));

                    Inversion(l).Result.Std.(K{k})      = nan(size(Inversion(l-1).Result.Std.(K{k})));
                    Inversion(l).Result.Adv.(K{k})		= nan(size(Inversion(l-1).Result.Adv.(K{k})));

                    Inversion(l).Error.Std.(K{k})		= nan(size(Inversion(l-1).Error.Std.(K{k})));
                    Inversion(l).Error.Adv.(K{k})		= nan(size(Inversion(l-1).Error.Adv.(K{k})));
                end
            end
        end %~isempty(Profiles1)

    end %for l=1:size(Profiles,2); Loop over the files which are loaded


%     close(h)
    %End Mode Loop
    warning('on','MATLAB:divideByZero');
    if multiple
        Lidar = 'LoadLidar.mat';
    end

%else Inversion=NaN;Lidar=NaN;
end

function data = Combine(data,data1)
name = fieldnames(data);
for n = 1:length(name)
    if ~isstruct(data.(name{n}))
        switch name{n}
            case {'Signal','Counts2mV'}
                data.(name{n}) = [data.(name{n}) data1.(name{n})];
            case {'z','Range'}
                data.(name{n}) = data.(name{n});
            case {'Mean'}
                data.(name{n}) = mean([data.(name{n}),data1.(name{n})],2);
            otherwise
                if isscalar(data.(name{n}))
                    data.(name{n}) = data.(name{n});
                else
                    data.(name{n}) = [data.(name{n});data1.(name{n})];
                end
        end
    else
        data.(name{n}) = Combine(data.(name{n}),data1.(name{n}));
    end
end
end

% On 8 March 2009. TD
% row 428: Averages up to 8000 bins (30 km) 
% row 471: At furst vertical averaging: m1 = 8; and m2 = m1 + 2*AddBin; 
% On 2 April 2009. TD 
% row 539 - 540  prevent false mid altitude level estimation -> 
% row 470 - added to start from 9 bins, which defines start altitude 30 m! 
% On 5 May 2009 
% row -> Var(m1-8:m2+8)
% row 428 allows maximum 4000 (15 km) bins to be treated
% On 12 May 2009
% row 390 - Changed variance estimation for 'Combined' case 
% Variance = smooth(DesatPC, 'rlowess')
% changed to start from 16 bin - 60 m