function S = read_isccp(file, opt)
%% isccpreadnative
% Purpose: read ISSCP binary data (based on the fortran reading rountines)
%
% IN:    file   %s           ISCCP file (fullpath)
%        opt    struct       contains     e.g.
%                               'dataset'    'dx'
%                               'cols'       [32,54,...]      (D2 dataset only)
%
% OUT:   S      structure with all the data from the file
%
% USAGE: S = read_isccp (file, opt)
%
% Salomon Eliasson
% $Id: read_isccp.m 8372 2013-04-24 06:23:43Z seliasson $

file = uncompress(file);

fid = fopen (file,'rb','b');
cleanObj = onCleanup(@() fclose(fid));
logtext(atmlab('OUT'),'Processing file: %s\n',file)
switch opt.dataset
    case 'dx'
        
        %Each data record consists of a
        %prefix area containing location information followed by a data area containing the packed pixel data,
        %followed by padding to the end of the record (pad value = 255). A data record contains a variable
        %number of whole pixels. All pixel data are reported as single byte values from 0 to 255, with 255
        %reserved to represent missing data. Contents of the header record are given in Table 2.3.3 and of the
        %data record in Table 2.3.4.
        
        rlength = 30720; % record length [bytes]
        % ------------------------
        % GET HEADER
        % ------------------------
        %Year, Month, Day, UTC (1-8), Satellite ID code, Satellite
        %Type Code (SATTYP), Number of channels present (NCHANS), Night Image flag
        %logtext(atmlab('OUT'),'Processing record #1: HEADER\n')
        info = str2num(fread (fid, 80, 'uint8=>char')'); %#ok<ST2NM>
        
        S.global_attributes = struct('year',info(1),'month',info(2),'day',info(3),'utc',info(4),...
            'satID',info(5),'SATTYP',info(6),'NCHANS',info(7),'nightFlag',info(8),...
            'production_time',strtrim(fread (fid, 80, 'uint8=>char')'),...
            'production_date',strtrim(fread (fid, 80, 'uint8=>char')'));
        clear info
        % move to the first byte of line 101 (skipping blanks)
        [~]=fseek(fid,100*80,-1);
        
        % Title, units, format for selected DX variables
        S.global_attributes.titleETC = fread (fid, 80*(1+(135-101)),'uint8=>char')';
        S.attributes = DX_attributes();
        
        % move to the first record of the data (skipping blanks)
        [~]=fseek(fid,rlength,-1); % i.e., end of first record
        
        % ----------------
        % READ DATA
        % ----------------
        
        tic
        % preallocate
        npreall = 2e5;
        T = LookupTables(opt.dataset); % Do all the bitand's in one go
        
        S.lat = ones(1,npreall,'single')*-9;
        S.lon = ones(1,npreall,'single')*-9;
        [S.LNDWTR,S.HITOPO,S.SNOICE,S.MUE,S.IRAD,S.BXICSR,S.GLINT,S.MU0,S.PHI,S.VRAD,...
            S.DAYNIT,S.ITHR,S.VTHR,S.SHORE,S.ICSRAD,S.ITMP,S.IPRS,S.ICSTMP,S.ICSPRS,...
            S.NREF,S.NTHR,S.NCSREF,S.VCSRAD,S.VALBTA,S.VCSALB,S.VTMP,S.VPRS,S.VTAUIC,...
            S.VTMPIC,S.VPRSIC,S.CLOUD,S.CLOUD_PHASE] = deal(ones(1,npreall,'uint8')*255);
        S.ARAD = ones(3,npreall,'uint8')*255;
        
        % Since CLOUD,CLOUD_PHASE is calculated in DXREAD (fortran original), it is
        % calculated here too.
        
        record=2; sNp =1;pix=1;
        while ~feof(fid) % while not eof (i.e., loop over records)
%            logtext(atmlab('OUT'),'Processing record #%g. ',record)
            WM = fread (fid, 1, 'uint32')/10; % Western-most longitude (0-3600 degrees*10)
            if isempty(WM), break, end
%             EM = fread (fid, 1, 'uint32')/10; % Eastern-most longitude (0-3600 degrees*10)
%             NM = fread (fid, 1, 'uint32')/10 -90; % Northern-most latitude (0-1800 degrees*10)
%             SM = fread (fid, 1, 'uint32')/10 -90; % Southern-most latitude (0-1800 degrees*10)
%             fprintf(atmlab('OUT'),'Region: lons between %.1f and %.1f and lats between %.1f and %.1f\n',WM,EM,SM,NM) %#ok<PRTCAL>
            [~]=fseek(fid,3*4,0);
            n_pixels     = fread (fid, 1, 'uint32'); %Number of pixels reported in data area
            iout         = fread (fid, 1, 'uint32'); %Number of bytes in packed data BUFFER
            
            % ---------------
            % GEODATA
            % ---------------
            eNp = sNp+n_pixels-1; % last index for pixel
            
            geo = reshape(fread( fid, n_pixels*4, 'uint16'), 4, [])';
            S.lon(sNp:eNp) = geo(:,1)/10;
            S.lat(sNp:eNp) = geo(:,2)/10 -90;
            sNp = eNp+1;
            % READ THE REST OF THE DATA AS unit8 and loop over the pixels
            buffer = fread(fid, iout, 'uint8=>uint8'); % Packed pixel data for NPIX pixels
            beginB=1;
            for P = 1:n_pixels
                
                [S1,ADD1,S2,S3,ADD3,S4,beginB]=get_dx_sections(buffer,beginB,S.global_attributes,T);
                
                % -----
                % S1. ALWAYS
                % -----
                % '*' means for internal use only
                %Land/water flag (0-1), 1 = water  pixel
                %S.LNDWTR(pix)  = bitshift(bitand(S1(1),2^5,'uint8'),-5);
                S.LNDWTR(pix)  = T.LNDTAB(S1(1)+1);
                %Topography flag (0-1), 1 = high topography pixel
                S.HITOPO(pix)  = T.TOPTAB(S1(1)+1);
                %Snow/ice code (0-3) (See Table 2.5.10)
                S.SNOICE(pix)  = T.SNITAB(S1(1)+1);
                %Cosine of satellite zenith angle * 100 (0-100)
                S.MUE(pix)     = T.ANGTAB(S1(3)+1);
                %IR radiance (0-254 counts)
                S.IRAD(pix)    = S1(4);
                %First IR clear sky radiance (0-254 counts)
                S.BXICSR(pix)  = S1(5);
                
                
                
                % ----------------------
                % ADD1. depends on number of channels
                for i = 1:3
                    %1) First extra wavelength radiance (0-254 counts) (present only when NCHANS > 2)
                    %2) Second extra wavelength radiance (0-254 counts)(present only when NCHANS > 3)
                    %3) Third extra wavelength radiance (0-254 counts)(present only when NCHANS > 4)
                    S.ARAD(i,pix) = ADD1(i);
                    
                end
                
                % ----
                % S2
                % ----
                if ~isempty(S2)
                    S.GLINT(pix)  = T.GLNTAB(S2(1)+1);%Glint flag (0-1), 1 = glint condition exists
                    S.MU0(pix)    = T.ANGTAB(S2(2)+1);%Cosine of solar zenith angle * 100 (0-100)
                    S.PHI(pix)    = S2(3);%Relative azimuth angle (0-180 degrees)
                    S.VRAD(pix)   = S2(4);%VIS radiance (0-254 counts)
                end
                
                % ----
                % S3
                % ----
                %Day/Night flag (0-1), 1 = night pixel (no VIS)
                S.DAYNIT(pix)   = T.NITTAB(S3(1)+1);
                %Final IR threshold result (0-5), 4,5 = cloudy
                S.ITHR(pix)     = T.ITHRTB(S3(1)+1);
                %Final VIS threshold result (0-5), 4,5 = cloudy
                S.VTHR(pix)     = T.VTHRTB(S3(1)+1);
                %Shore flag (0-1), 1 = near-coastal pixel
                S.SHORE(pix)    = T.NSHTAB(S3(1)+1);
                %IR clear sky composite radiance (0-254 counts)
                S.ICSRAD(pix)   = S3(3);
                %IR-retrieved cloud top or surface temperature     (0-254 counts)
                S.ITMP(pix)     = S3(4);
                %IR-retrieved cloud top or surface pressure (0-254 counts)
                S.IPRS(pix)     = S3(5);
                %IR-retrieved clear sky composite temperature (0-254 counts)
                S.ICSTMP(pix)   = S3(6);
                %IR-retrieved clear sky composite pressure (0-254 counts)
                S.ICSPRS(pix)   = S3(7);
                
                % -------
                % ADD3 (polar-orbiting Satellites)
                % -------
                if ~isempty(ADD3)
                    S.NREF(pix)  = ADD3(1); %NIR reflectivity (0-254 counts)
                    S.NTHR(pix)  = T.CRETAB(ADD3(2)+1); %NIR threshold result (1-13), > 8 = cloudy
                    S.NCSREF(pix)= ADD3(3); %NIR clear sky composite reflectance (0-254 counts)
                end
                
                
                % ----
                % S4
                % ----
                if ~isempty(S4)
                    %VIS clear sky composite radiance (0-254 counts)
                    S.VCSRAD(pix) = S4(2);
                    % VIS-retrieved liquid cloud tau or surface refl. (0-254 counts)
                    S.VALBTA(pix) = S4(3);
                    % VIS-retrieved clear sky composite reflectance (0-254 counts)
                    S.VCSALB(pix) = S4(4);
                    % VIS-adjusted cloud top temperature (0-254 counts)
                    S.VTMP(pix)   = S4(5);
                    % VIS-adjusted cloud top pressure (0-254 counts)
                    S.VPRS(pix)   = S4(6);
                    % VIS-retrieved ice cloud tau (0-254 counts)
                    S.VTAUIC(pix) = S4(7);
                    % VIS-adjusted ice cloud top temperature (0-254 counts)
                    S.VTMPIC(pix) = S4(8);
                    % VIS-adjusted ice cloud top pressure (0-254 counts)
                    S.VPRSIC(pix) = S4(9);
                end
                
                % CLOUD=1 /* pixel is cloudy */; CLOUD=0 /* pixel is clear */
                S.CLOUD(pix) = ( S.ITHR(pix) > 3 | S.VTHR(pix) > 3 | S.NTHR(pix) > 8 );
                
                %The actual water cloud - ice cloud decision may be calculated by the user as follows:
                % CLOUD_PHASE = [0 or 1 or 255] (ice,water,not determined)
                S.CLOUD_PHASE(pix) = S.VTMPIC(pix) == 255 | ( S.VTMP(pix) > 74 & S.VTMPIC(pix) > 74 );
                pix = pix+1;
            end
            
            [~]=fseek(fid,record*rlength,'bof');
            
            record = record+1;
        end
        
        % TRUNCATE
        S = truncateS(S,eNp);
        
        % ------------
        % Apply tabulated values
        % ------------

        % temperature variables
        S.IRAD  = T.TMPTAB(S.IRAD+1);
        S.BXICSR  = T.TMPTAB(S.BXICSR+1);
        %ARAD    = TMPTAB(ARAD); Don't know if they are visible or IR
        S.VRAD    = T.RFLTAB(S.VRAD+1);
        S.ICSRAD  = T.TMPTAB(S.ICSRAD+1);
        S.ITMP    = T.TMPTAB(S.ITMP+1);
        S.IPRS    = T.PRETAB(S.IPRS+1);
        S.ICSTMP  = T.TMPTAB(S.ICSTMP+1);
        S.ICSPRS  = T.PRETAB(S.ICSPRS+1);
        S.NREF    = T.RFLTAB(S.NREF+1);
        S.NCSREF  = T.RFLTAB(S.NCSREF+1);
        S.VCSRAD  = T.RFLTAB(S.VCSRAD+1);
        S.VALBTA(S.CLOUD_PHASE==1) = T.TAUTAB(S.VALBTA(S.CLOUD_PHASE==1)+1);
        S.VALBTA(S.CLOUD==0) = T.RFLTAB(S.VALBTA(S.CLOUD==0)+1);
        S.VCSALB  = T.RFLTAB(S.VCSALB+1);
        S.VTMP    = T.TMPTAB(S.VTMP+1);
        S.VPRS    = T.PRETAB(S.VPRS+1);
        S.VTAUIC  = T.TAUTAB(S.VTAUIC+1);
        S.IWP     = S.VTAUIC*T.PATHIW; %convert tau_v to IWP following D1 and D2 dataset definitions (Sec. 3.1.2 ISCCP documentation new cloud datasets Jan 1996)
        S.VTMPIC  = T.TMPTAB(S.VTMPIC+1);
        S.VPRSIC  = T.PRETAB(S.VPRSIC+1);
        
        if npreall<eNp, logtext(atmlab('ERR'),'Need to preallocate to bigger arrays. eNp=%g',eNp), end
        toc
        
    case 'd1'
        error(['atmlab:' mfilename],'Nothing set up for the D1 dataset. Feel free to set it up')
         % nothing set up yet
    case 'd2'
        
        warning(['atmlab:' mfilename ':legacy'],['The output format doesn''t match the documentation.\n'...
            'this is the legacy format from an earlier less generic code.\n'...
            'The plan is to fix this part of the reading routine when I (or someone else has time'])
        fid = fopen (filename,'rb');
        S = uint8(fread (fid));
        S = reshape(S,13000,numel(S)/13000)';     % sort to 13000 bytes for each grid
        S = S(:,131:end);                         % I don't need prefix
        S = reshape(S',numel(S),1);
        S = S(1:end-4810);                        % removed bytes not used
        S = reshape(S,130,numel(S)/130)';         % number of data fields = 130
        S = S (:,cols);
        
    otherwise
        error(['atmlab:' mfilename],'Nothing configured for ISCCP dataset: %s',opt.dataset)
end
logtext(atmlab('OUT'),'DONE\n')

end

function attr = DX_attributes()

% Assign some attributes to the read variables

attr = struct('lon','Longitudes for NPIX pixels (0-3600 degrees*10)',...
    'lat','Latitudes for NPIX pixels (0-1800 degrees*10)',...
    'LNDWTR','Land/water flag (0-1), 1 = water  pixel',...
    'HITOPO','Topography flag (0-1), 1 = high topography pixel',...
    'SNOICE','Snow/ice code (0-3) (See Table 2.5.10)',...
    'MUE','Cosine of satellite zenith angle * 100 (0-100)',...
    'IRAD','IR radiance',...
    'BXICSR','First IR clear sky radiance',...
    'ARAD',['1) First extra wavelength radiance (present only when NCHANS > 2)'...
    '2) Second extra wavelength radiance (present only when NCHANS > 3)'...
    '3) Third extra wavelength radiance (present only when NCHANS > 4)'],...
    'GLINT','Glint flag (0-1), 1 = glint condition exists',...
    'MU0','Cosine of solar zenith angle * 100 (0-100)',...
    'PHI','Relative azimuth angle (0-180 degrees)',...
    'VRAD','VIS radiance',...
    'DAYNIT','Day/Night flag (0-1), 1 = night pixel (no VIS)',...
    'ITHR','Final IR threshold result (0-5), 4,5 = cloudy',...
    'VTHR','Final VIS threshold result (0-5), 4,5 = cloudy',...
    'SHORE','Shore flag (0-1), 1 = near-coastal pixel',...
    'ICSRAD','IR clear sky composite radiance',...
    'ITMP','IR-retrieved cloud top or surface temperature',...
    'IPRS','IR-retrieved cloud top or surface pressure',...
    'ICSTMP','IR-retrieved clear sky composite temperature',...
    'ICSPRS','IR-retrieved clear sky composite pressure',...
    'NREF','NIR reflectivity',...
    'NTHR','NIR threshold result (1-13), > 8 = cloudy',...
    'NCSREF','NIR clear sky composite reflectance',...
    'VCSRAD','VIS clear sky composite radiance',...
    'VALBTA','VIS-retrieved liquid cloud tau or surface reflectance',...
    'VCSALB','VIS-retrieved clear sky composite reflectance',...
    'VTMP',' VIS-adjusted cloud top temperature',...
    'VPRS','VIS-adjusted cloud top pressure',...
    'VTAUIC','VIS-retrieved ice cloud tau',...
    'VTMPIC','VIS-adjusted ice cloud top temperature',...
    'VPRSIC','VIS-adjusted ice cloud top pressure',...
    'CLOUD','CLOUD=1 /* pixel is cloudy */; CLOUD=0 /* pixel is clear */',...
    'CLOUD_PHASE',' [0 or 1 or 255] (ice,water,not determined)',...
    'IWP',['Conversion of tau_v to IWP following D1 and D2 dataset definitions '...
    '(Sec. 3.1.2 ISCCP documentation new cloud datasets Jan 1996)']);

end

function [S1,ADD1,S2,S3,ADD3,S4,bs]=get_dx_sections(buffer,bs,attr,T)
% GET SECTIONS (as documented in the ISCCP DX documentation)

% It's one second faster per isccp binary file file to not frivolously 
%assign variables for the sake of readibility. To clarify what going on ...
%
% bs = begin index
% be = bs + number of bytes to read
% NODAY = T.NITTAB(S1(1)+1) Night flag
% NCHANS = (attr.NCHANS -2); more than 2 channels

%S1
S1 = buffer(bs:bs+5-1);
bs=bs+5;


%ADD1
ADD1 = buffer(bs:bs+(attr.NCHANS -2)-1);
bs = bs+(attr.NCHANS -2);

%S2
S2 = buffer(bs:bs+5*~(T.NITTAB(S1(1)+1))-1);
bs = bs+5*~(T.NITTAB(S1(1)+1));

%S3
S3 = buffer(bs:bs+7-1);
bs = bs+7;

% ADD3
ADD3=buffer(bs:bs+3*(attr.SATTYP>0)-1);
bs = bs+3*(attr.SATTYP>0);

% S4
S4=buffer(bs:bs+9*~(T.NITTAB(S1(1)+1))-1);
bs = bs+9*~(T.NITTAB(S1(1)+1));

end

function S = truncateS(S,eNp)

fls = fieldnames(S);fls=fls(~ismember(fls,{'global_attributes','attributes'}));
for F=fls'
    S.(F{1}) = S.(F{1})(:,1:eNp);
end

end

function T = LookupTables(dataset)
%% LookupTablesBitAnd
% Make look up tables in the same manner as the Fortran code

if strcmp(dataset,'dx')
    % --------------
    % For bitands
    [T.NITTAB,T.LNDTAB,T.TOPTAB,T.SNITAB,T.ANGTAB,T.ITHRTB,T.VTHRTB,...
        T.CRETAB,T.NSHTAB]=deal(zeros(1,255,'uint8'));
    
    for IVAL=1:256
        T.NITTAB(IVAL) = bitshift(bitand(IVAL,2^7),-7);
        T.LNDTAB(IVAL) = bitshift(bitand(IVAL,2^5),-5);
        T.TOPTAB(IVAL) = bitshift(bitand(IVAL,2^4),-4);
        T.SNITAB(IVAL) = bitshift(bitand(IVAL,2^3+2^2),-2);
        T.ANGTAB(IVAL) = bitand(IVAL,2^6+2^5+2^4+2^3+2^2+2^1+2^0);
        T.ITHRTB(IVAL) = bitshift(bitand(IVAL,2^6+2^5+2^4),-4);
        T.VTHRTB(IVAL) = bitshift(bitand(IVAL,2^3+2^2+2^1),-1);
        T.CRETAB(IVAL) = bitand(IVAL,2^3+2^2+2^1+2^0);
        T.NSHTAB(IVAL) = bitand(IVAL,2^0);
    end
    T.GLNTAB = T.NITTAB;
end

% -------------
% CONVERSION tables

% Temperature conversion tables
T.TMPTAB = [-100.000,165.000,169.000,172.000,175.000,177.800,180.500,183.000, ...
    185.500,187.800,190.000,192.000,194.000,195.700,197.500,199.200, ...
    201.000,202.700,204.500,206.200,208.000,209.700,211.500,212.800, ...
    214.100,215.400,216.700,217.900,219.200,220.500,221.800,223.100, ...
    224.400,225.400,226.500,227.500,228.600,229.600,230.600,231.700, ...
    232.700,233.800,234.800,235.700,236.600,237.500,238.400,239.200, ...
    240.100,241.000,241.900,242.800,243.700,244.500,245.300,246.100, ...
    246.900,247.700,248.500,249.300,250.100,250.900,251.700,252.400, ...
    253.100,253.900,254.600,255.300,256.000,256.700,257.500,258.200, ...
    258.900,259.500,260.200,260.800,261.500,262.100,262.800,263.400, ...
    264.100,264.700,265.400,266.000,266.600,267.200,267.800,268.400, ...
    269.100,269.700,270.300,270.900,271.500,272.100,272.700,273.200, ...
    273.800,274.400,275.000,275.600,276.100,276.700,277.300,277.800, ...
    278.400,278.900,279.500,280.000,280.500,281.100,281.600,282.200, ...
    282.700,283.200,283.700,284.200,284.700,285.200,285.800,286.300, ...
    286.800,287.300,287.800,288.300,288.800,289.300,289.800,290.200, ...
    290.700,291.200,291.700,292.200,292.700,293.200,293.600,294.100, ...
    294.600,295.000,295.500,296.000,296.500,296.900,297.400,297.800, ...
    298.300,298.700,299.200,299.600,300.100,300.500,301.000,301.400, ...
    301.900,302.300,302.800,303.200,303.600,304.000,304.500,304.900, ...
    305.300,305.800,306.200,306.600,307.000,307.500,307.900,308.300, ...
    308.700,309.100,309.600,310.000,310.400,310.800,311.200,311.600, ...
    312.000,312.400,312.900,313.300,313.700,314.100,314.500,314.900, ...
    315.300,315.700,316.100,316.400,316.800,317.200,317.600,318.000, ...
    318.400,318.800,319.200,319.500,319.900,320.300,320.700,321.100, ...
    321.400,321.800,322.200,322.600,323.000,323.300,323.700,324.100, ...
    324.500,324.900,325.200,325.600,326.000,326.400,326.700,327.100, ...
    327.400,327.800,328.200,328.500,328.900,329.200,329.600,329.900, ...
    330.300,330.600,331.000,331.300,331.700,332.000,332.400,332.700, ...
    333.100,333.400,333.800,334.100,334.500,334.800,335.200,335.500, ...
    335.900,336.200,336.600,336.900,337.300,337.600,338.000,338.300, ...
    338.600,339.000,339.300,339.700,340.000,345.000,-200.000,-1000.000];

T.RFLTAB = [-100.000,0.000,0.008,0.012,0.016,0.020,0.024,0.028,0.032,0.036, ...
     0.040,0.044,0.048,0.052,0.056,0.060,0.064,0.068,0.072,0.076, ...
     0.080,0.084,0.088,0.092,0.096,0.100,0.104,0.108,0.112,0.116, ...
     0.120,0.124,0.128,0.132,0.136,0.140,0.144,0.148,0.152,0.156, ...
     0.160,0.164,0.168,0.172,0.176,0.180,0.184,0.188,0.192,0.196, ...
     0.200,0.204,0.208,0.212,0.216,0.220,0.224,0.228,0.232,0.236, ...
     0.240,0.244,0.248,0.252,0.256,0.260,0.264,0.268,0.272,0.276, ...
     0.280,0.284,0.288,0.292,0.296,0.300,0.304,0.308,0.312,0.316, ...
     0.320,0.324,0.328,0.332,0.336,0.340,0.344,0.348,0.352,0.356, ...
     0.360,0.364,0.368,0.372,0.376,0.380,0.384,0.388,0.392,0.396, ...
     0.400,0.404,0.408,0.412,0.416,0.420,0.424,0.428,0.432,0.436, ...
     0.440,0.444,0.448,0.452,0.456,0.460,0.464,0.468,0.472,0.476, ...
     0.480,0.484,0.488,0.492,0.496,0.500,0.504,0.508,0.512,0.516, ...
     0.520,0.524,0.528,0.532,0.536,0.540,0.544,0.548,0.552,0.556, ...
     0.560,0.564,0.568,0.572,0.576,0.580,0.584,0.588,0.592,0.596, ...
     0.600,0.604,0.608,0.612,0.616,0.620,0.624,0.628,0.632,0.636, ...
     0.640,0.644,0.648,0.652,0.656,0.660,0.664,0.668,0.672,0.676, ...
     0.680,0.684,0.688,0.692,0.696,0.700,0.704,0.708,0.712,0.716, ...
     0.720,0.724,0.728,0.732,0.736,0.740,0.744,0.748,0.752,0.756, ...
     0.760,0.764,0.768,0.772,0.776,0.780,0.784,0.788,0.792,0.796, ...
     0.800,0.804,0.808,0.812,0.816,0.820,0.824,0.828,0.832,0.836, ...
     0.840,0.844,0.848,0.852,0.856,0.860,0.864,0.868,0.872,0.876, ...
     0.880,0.884,0.888,0.892,0.896,0.900,0.904,0.908,0.912,0.916, ...
     0.920,0.924,0.928,0.932,0.936,0.940,0.944,0.948,0.952,0.956, ...
     0.960,0.964,0.968,0.972,0.976,0.980,0.984,0.988,0.992,1.000, ...
     1.016,1.040,1.072,1.108,-200.000,-1000.000];

% Pressure table
T.PRETAB = [-100.00,1.00,5.00,10.00,15.00,20.00,25.00,30.00,35.00,40.00, ...
    45.00, 50.00, 55.00,60.00,65.00,70.00,75.00,80.00,85.00, ...
    90.00,95.00,100.00,105.00,110.00,115.00,120.00,125.00,130.00, ...
    135.00,140.00,145.00,150.00,155.00,160.00,165.00,170.00,175.00, ...
    180.00,185.00,190.00,195.00,200.00,205.00,210.00,215.00,220.00, ...
    225.00,230.00,235.00,240.00,245.00,250.00,255.00,260.00,265.00, ...
    270.00,275.00,280.00,285.00,290.00,295.00,300.00,305.00,310.00, ...
    315.00,320.00,325.00,330.00,335.00,340.00,345.00,350.00,355.00, ...
    360.00,365.00,370.00,375.00,380.00,385.00,390.00,395.00,400.00, ...
    405.00,410.00,415.00,420.00,425.00,430.00,435.00,440.00,445.00, ...
    450.00,455.00,460.00,465.00,470.00,475.00,480.00,485.00,490.00, ...
    495.00,500.00,505.00,510.00,515.00,520.00,525.00,530.00,535.00, ...
    540.00,545.00,550.00,555.00,560.00,565.00,570.00,575.00,580.00, ...
    585.00,590.00,595.00,600.00,605.00,610.00,615.00,620.00,625.00, ...
    630.00,635.00,640.00,645.00,650.00,655.00,660.00,665.00,670.00, ...
    675.00,680.00,685.00,690.00,695.00,700.00,705.00,710.00,715.00, ...
    720.00,725.00,730.00,735.00,740.00,745.00,750.00,755.00,760.00, ...
    765.00,770.00,775.00,780.00,785.00,790.00,795.00,800.00,805.00, ...
    810.00,815.00,820.00,825.00,830.00,835.00,840.00,845.00,850.00, ...
    855.00,860.00,865.00,870.00,875.00,880.00,885.00,890.00,895.00, ...
    900.00,905.00,910.00,915.00,920.00,925.00,930.00,935.00,940.00, ...
    945.00,950.00,955.00,960.00,965.00,970.00,975.00,980.00,985.00, ...
    990.00,995.00,1000.00,-200.00,-200.00,-200.00,-200.00,-200.00, ...
    -200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00, ...
    -200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00, ...
    -200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00, ...
    -200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00, ...
    -200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00, ...
    -200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00,-200.00, ...
    -1000.00];

T.TAUTAB = [-100.000,0.020,0.040,0.060,0.090,0.110,0.140,0.160,0.190, ...
    0.220,0.240,0.270,0.300,0.330,0.370,0.400,0.430,0.460,0.500, ...
    0.530,0.570,0.600,0.640,0.680,0.720,0.750,0.790,0.830,0.870, ...
    0.920,0.960,1.000,1.040,1.090,1.130,1.180,1.220,1.270,1.320, ...
    1.370,1.420,1.470,1.520,1.570,1.620,1.670,1.730,1.780,1.830, ...
    1.890,1.950,2.000,2.060,2.120,2.180,2.240,2.300,2.360,2.430, ...
    2.490,2.550,2.620,2.690,2.750,2.820,2.890,2.960,3.030,3.100, ...
    3.180,3.250,3.320,3.400,3.480,3.550,3.630,3.710,3.790,3.880, ...
    3.960,4.040,4.130,4.220,4.300,4.390,4.480,4.570,4.670,4.760, ...
    4.850,4.950,5.050,5.150,5.250,5.350,5.450,5.560,5.660,5.770, ...
    5.880,5.990,6.110,6.220,6.340,6.450,6.570,6.690,6.820,6.940, ...
    7.070,7.190,7.330,7.460,7.590,7.730,7.870,8.010,8.150,8.300, ...
    8.440,8.590,8.740,8.900,9.060,9.220,9.380,9.540,9.710,9.880, ...
    10.050,10.230,10.410,10.590,10.780,10.970,11.160,11.350, ...
    11.550,11.760,11.960,12.170,12.390,12.600,12.830,13.050, ...
    13.280,13.520,13.760,14.000,14.250,14.510,14.770,15.030, ...
    15.300,15.580,15.860,16.150,16.440,16.740,17.050,17.360, ...
    17.690,18.020,18.350,18.700,19.050,19.410,19.780,20.160, ...
    20.540,20.940,21.350,21.770,22.200,22.630,23.080,23.550, ...
    24.030,24.520,25.020,25.540,26.070,26.620,27.190,27.770, ...
    28.370,28.990,29.630,30.290,30.970,31.670,32.400,33.160, ...
    33.940,34.740,35.580,36.450,37.350,38.290,39.260,40.260, ...
    41.320,42.420,43.570,44.760,46.000,47.310,48.680,50.110, ...
    51.600,53.170,54.840,56.590,58.430,60.360,62.400,64.590, ...
    66.900,69.360,71.960,74.720,77.730,80.940,84.380,88.060, ...
    92.020,96.400,101.010,105.510,109.870,114.330,119.590, ...
    125.920,133.660,143.120,154.650,169.560,187.490,207.200, ...
    228.130,250.440,282.780,323.920,378.650,-200.000,-200.000, ...
    -200.000,-200.000,-200.000,-200.000,-200.000,-200.000, ...
    -200.000,-200.000,-200.000,-1000.000];

% CONSTANTS
T.PATHLW = 6.292; %for LWP
T.PATHIW = 10.5; %for the IWP

if any(strcmp(dataset,{'d1','d2'}))
    % LATS & LONS for equal area grid
    table.latarray   = -90+2.5/2: 2.5 :90-2.5/2;
    table.lonlist   = [  3,   9,  16,  22,  28,  34,  40,  46,  ...
        52,  58,  64, 69,  75,  80,  85,  90,  95, 100, 104, ...
        108, 112, 116, 120, 123, 126, 129, 132, 134, 136, 138, ...
        140, 141, 142, 143, 144, 144, 144, 144, 143, 142, 141, ...
        140, 138, 136, 134, 132, 129, 126, 123, 120, 116, 112, ...
        108, 104, 100, 95,  90,  85,  80,  75,  69,  64,  58,  ...
        52,  46,  40, 34,  28,  22,  16,   9,   3];
    
    jj = 1; ii = 1;
    ngrid = sum(table.lonlist);
    table.lon = zeros(1,ngrid);
    table.lat = zeros(1,ngrid);
    for k = 1:length(table.latarray)
        for l = 1:table.lonlist(k)
            table.lon(ii) = (l-1)*360.0/table.lonlist(k)+(360.0/table.lonlist(k))/2.0;
            table.lat(ii) = table.latarray(jj);
            ii = ii+1;
        end
        jj = jj+1;
    end
end

end

%% FIELDS NOT READ SINCE THEY ARE INTERNAL
%
% -------
% DX
% -------

%xpos(sNp:eNp)= geo(:,3); %X-positions for NPIX pixels (1-480)
%ypos(sNp:eNp)= geo(:,4); %Y-positions for NPIX pixels (1-550)
%*BX shore flag (0-1)
%BXSHOR(pix)  = bitshift(bitand(S1(1),2^1,'uint8'),-1);
%*Time/space test result (0-3)
%TIMSPA(pix)  = bitshift(bitand(S1(1),2^6+2^7,'uint8'),-6);
%*IR clear sky composite logic code (0-24)
%ICSLOG(pix)  = bitand(S1(2),2^0+2^1+2^2+2^3+2^4,'uint8');
%*First IR threshold result (0-5)
%BXITHR(pix)  = bitshift(bitand(S1(2),2^5+2^6+2^7,'uint8'),-5);
%* VIS clear sky composite logic code (0-14)
%VCSLOG(pix) = bitshift(bitand(S2(1),sum(2.^(1:4)),'uint8'),-1);
%* First VIS threshold result (0-5)
%BXVTHR(pix) = bitshift(bitand(S2(1),sum(2.^(5:7)),'uint8'),-5);
%* First VIS clear sky radiance (0-254 counts)
%BXVCSR(pix) = S2(5);
%*IR retrieval code (0-12)
%IRET(pix)     = bitand(S3(2),2^0+2^1+2^2+2^3,'uint8');
%*IR clear sky composite retrieval code (0-12)
%ICSRET(pix)   = bitshift(bitand(S3(2),2^4+2^5+2^6+2^7,'uint8'),-4);
%*VIS retrieval code (0-14)
%VRET(pix)   = bitand(S4(1),2^0+2^1+2^2+2^3,'uint8');
%*VIS clear sky composite retrieval code (0-14)
%VCSRET(pix) = bitshift(bitand(S4(1),2^4+2^5+2^6+2^7,'uint8'),-4);
