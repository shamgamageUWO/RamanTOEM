function data=GlueWVN2(data,config)

Gluing = 1; 
SaveCo = 0;

Channel = fieldnames(data);

% Channel = ['GlobalParameters','WV', 'N2','O2',...,'z']
% Loop over 'WV', 'N2', and 'O2'

% new field "CloudBase"
if length(Channel)==7
    chi = 2;
elseif length(Channel)==8
    chi = 3;
end

for n=chi:length(Channel); %first is 'Global parameters', last is 'z'
    Mode = fieldnames(data.(Channel{n}));
    
    % Averaging the Analog and Photon signals for all loaded files
    
    % Mode = ['Analog', 'Photon']
    if length(Mode) == 2
        data.(Channel{n}).Combined = data.(Channel{n}).Photon; % Creates field 'Combined' = 'Photon'
        Dim = size(data.(Channel{n}).Analog.Signal);
        data.(Channel{n}).Combined.Signal   = zeros(Dim); % Fills with nulls the field 'Signal' in the 'Combined'
        data.(Channel{n}).Combined.Freq     = zeros(Dim(2),1);
        data.(Channel{n}).Analog.ab         = zeros(Dim(2),2);
        data.(Channel{n}).Analog.bkg        = zeros(Dim(2),1);
        data.(Channel{n}).Photon.bkg        = zeros(Dim(2),1);
        
        % To trim the data vectors
        StartBin    = 8;
        StopBin     = 16000;
        L           = StopBin-StartBin+1;
        
        % Glue or Desaturate
        % Loop on the number of files loaded (num of files = num of columns in the field 'data...Analog.Signal')
        for k=1:size(data.(Channel{n}).Analog.Signal,2);
            
            if strcmp(Channel{n},'WV')
                A=data.(Channel{n}).Analog.Signal(100:3000,k);
                P=data.(Channel{n}).Photon.Signal(100:3000,k);
            else
                A=data.(Channel{n}).Analog.Signal(30:5000,k);
                P=data.(Channel{n}).Photon.Signal(30:5000,k);
            end
            
            if strcmp(Channel{n},'WV')
                f   = 127;                            % 126.67, 127  (before 27 May) % 126 (after 27 May 09)
                a   = 39.2;                           % 39.04, 39.2 (before 27 May) % 39.85 (after 27 May 09)
                b   = - 1.4834 * a;                   % -1.4957, -1.486 (before 27 May) %Estimated electrical offset in WV cahnnel for 22.5 °C b = - 1.4
                %[a,b,f] = DesaturateCoeffExtremes(A, P, 0.1, 0.8, 125, 30)
                % estimate of coeffs for night-time
                if ( mean(data.(Channel{n}).Photon.Signal(end-1000:end,k)) < 5 ) && SaveCo
                    try
                        [aa,bb,ff] = DesaturateCoeffExtremes(A, P, 0.2, 0.8, 80, 0);
                        tt = datenum(data.GlobalParameters.Start);
                        tt = tt (k);
                        load('ttaabbff.mat');
                        temp  = [temp; [tt aa bb ff]];
                        save('ttaabbff.mat', 'temp');
                    end
                end
                
            elseif strcmp(Channel{n},'N2')
                f   = 257.86;                            % 257.86, 235 - for 31 July to 4 Aug 2008 median estimates
                a   = 96.62;                             % 96.62, 95.7
                b   = - 1.6488 * a;                      % 1.629
                %[a,b,f] = DesaturateCoeffExtremes(A, P, 0.1, 0.8, 180, 0)
                
            elseif strcmp(Channel{n}, 'O2')
                warning off
                M = [ones(length(A),1) P P.*A];
                r = M\A;
                f =1/r(3);
                a =1./(r(2)+r(1)*r(3));
                b =-a*r(1);
                warning on
                if (f < 100) || (a <= 0) ;
                    f = 180;
                    M = [ones(length(A),1) P./(1-P/f)];
                    r = M\A;
                    a = 1/r(2);
                    b = -r(1)/r(2);
                end
            else
                warning off
                f = 250;
                M = [ones(length(A),1) P./(1-P/f)];
                r = M\A;
                a = 1/r(2);
                b = -r(1)/r(2);
                warning on
            end
            
            data.(Channel{n}).Analog.bkg(k,1)  = median(data.(Channel{n}).Analog.Signal(end-1000:end,k));
            data.(Channel{n}).Photon.bkg(k,1)  = median(data.(Channel{n}).Photon.Signal(end-1000:end,k));
            
            data.(Channel{n}).Combined.Signal(:,k) = ...           % Combined.Signal = Desaturate (Photon.Singal, f)
                data.(Channel{n}).Photon.Signal(:,k)./...
                (1-data.(Channel{n}).Photon.Signal(:,k)/f);
            
            %data.(Channel{n}).Photon.Signal(:,k) = ...             % Photon.Signal = Desaturate (Photon.Singal, f)
            %    data.(Channel{n}).Combined.Signal(:,k);
            
            data.(Channel{n}).Analog.Signal(:,k)   =  ...          % Analog.Signal = a* Analog + b -> analog signal in MCPS
                a*data.(Channel{n}).Analog.Signal(:,k) + b;
            
            data.(Channel{n}).Combined.Freq(k,:)   =  f;           % Can be extracted typical value of Frequency
            data.(Channel{n}).Analog.ab(k,:)       = [a,b];        % Can be extracted typical values of Scaling Factors
            
            if ( Gluing && strcmp(Channel{n},'WV') )
                data.(Channel{n}).Combined.Signal(:,k) = ...
                    glueit(data.(Channel{n}).Analog.Signal(:,k), data.(Channel{n}).Combined.Signal(:,k), 0.8, a);
            end
                        
            % -----------------------------------------
            %                 if ( Gluing && strcmp(Channel{n},'N2') )
            %                     data.(Channel{n}).Combined.Signal(:,k) = ...
            %                         glueit(data.(Channel{n}).Analog.Signal(:,k), data.(Channel{n}).Combined.Signal(:,k), 0.8, a);
            %                 end
            
            
        end
        
    else msgbox('Missing Analog or Photon Counting data',...
            'Error in recorded LICEL files','warn');
    end
end

