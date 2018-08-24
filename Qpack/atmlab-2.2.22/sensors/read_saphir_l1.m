function saphirL1=read_saphir_l1(filename,selected_entries, mode)
% function read_saphir_l1: reads HDF5 files with SAPHIR leve1 1 data and
% provides a structure containing the useful L1 data and attributes
%
% call: dataL1 = read_saphir_l1(filename,[selected_entries, mode])
%
% filename is the name of the hdf5 file or a gzipped version thereof
% desired_entries is optional if you do not want to extract all variables
% but only a selection. See variable 'strmember' for entries.
%
% relate variable names structure vs hdf5
%
% Initial version mostly by Mathias Milz, adapted by Gerrit Holl
%
% 'mode' can be 'l1a1' or 'l1a2'.

% $Id: read_saphir_l1.m 8941 2014-09-15 11:04:40Z olemke $

errorid = 'Function read_saphir_l1:';

% structure variable names for output
strmember= {'IncidencAngle',...
    'LatNadir',...
    'LatScan',...
    'LonNadir',...
    'LonScan',...
    'QFCh1',...
    'QFCh2',...
    'QFCh3',...
    'QFCh4',...
    'QFCh5',...
    'QFCh6',...
    'QFScan',...
    'ScanTimestart',...
    'ScanGain',...
    'ScanHLTemp',...
    'ScanNumber',...
    'ScanOffset',...
    'TbCh1',...
    'TbCh2',...
    'TbCh3',...
    'TbCh4',...
    'TbCh5',...
    'TbCh6'};

% variable names for h5 internal structure
h5member= {'/ScienceData/IncidenceAngle_Samples',...
    '/ScienceData/Latitude_Nadir',...
    '/ScienceData/Latitude_Samples',...
    '/ScienceData/Longitude_Nadir',...
    '/ScienceData/Longitude_Samples',...
    '/ScienceData/QF_Samples_S1',...
    '/ScienceData/QF_Samples_S2',...
    '/ScienceData/QF_Samples_S3',...
    '/ScienceData/QF_Samples_S4',...
    '/ScienceData/QF_Samples_S5',...
    '/ScienceData/QF_Samples_S6',...
    '/ScienceData/SAPHIR_QF_scan',...
    '/ScienceData/Scan_FirstSampleAcqTime',...
    '/ScienceData/Scan_Gain',...
    '/ScienceData/Scan_HotLoadTemperature',...
    '/ScienceData/Scan_Number',...
    '/ScienceData/Scan_Offset',...
    '/ScienceData/TB_Samples_S1',...
    '/ScienceData/TB_Samples_S2',...
    '/ScienceData/TB_Samples_S3',...
    '/ScienceData/TB_Samples_S4',...
    '/ScienceData/TB_Samples_S5',...
    '/ScienceData/TB_Samples_S6'};

switch nargin
    case 0
        error(errorid,'You need at least Filename as input');
    case 1
        % read all variables
        useentries = 1:length(strmember);
    case {2, 3}
        %read only selected variables given in 'selected_entries'
        [~,useentries] = ismember(selected_entries,strmember);
end

if nargin < 3
    [~,name,~] = fileparts(filename);
    switch name(8:11)
        case 'L1A_'
            mode = 'l1a1';
        case 'L1A2'
            mode = 'l1a2';
        otherwise
            error(['atmlab:' mfilename ':modeunknown'], ...
                'Can''determine mode. Set mode manually to ''l1a1'' or ''l1a2''');
    end
end

switch mode
    case 'l1a1'
        % above is good
    case 'l1a2'
        h5member = strrep(h5member, 'IncidenceAngle_Samples', 'Incidence_Angle');
        h5member = strrep(h5member, 'TB_Samples', 'TB_Pixels');
        h5member = strrep(h5member, 'QF_Samples', 'QF_Pixels');
        h5member = strrep(h5member, 'Samples', 'pixels');
        h5member = strrep(h5member, 'Sample', 'Pixel');
    otherwise
        error(['atmlab:' mfilename ':invalidmode'], ...
            'Expected mode ''l1a1'' or ''l1a2'', got %s', mode);
end

% uncompress file if necessary
try
    info=hdf5info(filename);
catch ME
    switch ME.identifier
        case 'MATLAB:imagesci:deprecatedHDF5:libraryError' % probably compressed
            filename = uncompress(filename, atmlab('WORK_AREA'), ...
                struct('unidentified', 'error'));
            % if we reach here, it means filename uncompressed is not the
            % original filename!
            cleanupObj = onCleanup(@()delete(filename));
            info = h5info(filename);
        otherwise
            ME.rethrow();
    end
end
%Begin MMILZ
% read version from info and adjust h5member names (Latitude_pixels -> Latitude_Pixels
% (1.05->1.06))
info=h5info(filename); %Call necessary to enable the following tastks
natt=length(info.Groups.Attributes);
for iat=1:natt
    if strcmp(info.Groups.Attributes(iat).Name,'Product_Identification')
        fname=info.Groups.Attributes(iat).Value;
        vers=fname(13:16);
        if strcmp(vers,'1.06')
            %fprintf(1,'Ping\n');
            h5member = strrep(h5member, 'Latitude_pixels', 'Latitude_Pixels');
            h5member = strrep(h5member, 'Longitude_pixels', 'Longitude_Pixels');
        end
    end
end
clear natt;
clear iat;
clear fname;
clear vers;
%END MMILZ

% Begin MMILZ 20140730
% Catch the change in Variable naming Icidence_angle -->
% IncidenceAngle_Pixels and adapt the fieldnames in
ndatasets=length(info.Groups.Datasets);
for idatas=1:ndatasets
    if strcmp(info.Groups.Datasets(idatas).Name,'IncidenceAngle_Pixels')
        h5member = strrep(h5member, 'Incidence_Angle', 'IncidenceAngle_Pixels');
    end
end
clear ndatasets;
clear idatas;
%%MM %END MMILZ 20140730


for ie=1:length(useentries)
    % read data
    % use h5read, not hdf5read, as to not get annoying hdf5.h5string object
    %    saphirL1.data.(strmember{useentries(ie)}) = hdf5read(filename,h5member{useentries(ie)});
    saphirL1.data.(strmember{useentries(ie)}) = h5read(filename,h5member{useentries(ie)});
    %fprintf(1,'Read Variable: %s\n',strmember{useentries(ie)});
    % read data attributes
    %fname={info.GroupHierarchy.Groups.Datasets(useentries(ie)).Attributes.Shortname};
    fname = {info.Groups.Datasets(useentries(ie)).Attributes.Name};
    for i =1:length(fname)
        %fprintf(1,'i: %g -- %s\n',i,fname{i});
        try
            %val = info.GroupHierarchy.Groups.Datasets(useentries(ie)).Attributes(i).Value.Data;
            val = info.Groups.Datasets(useentries(ie)).Attributes(i).Value;
            
            saphirL1.attr.(strmember{useentries(ie)}).(strrep(fname{i},'_',''))= val;
        catch ME
            logtext(atmlab('ERR'), ...
                'Error in reading data attribute %s for field %s: %s\n', ...
                fname{i}, strmember{useentries(ie)}, ME.message);
        end
    end
    % Get absolute values by applying offset and scale factor
    if isfield(saphirL1.attr.(strmember{useentries(ie)}),'scalefactor')
        tmpscalefactor=str2num(saphirL1.attr.(strmember{useentries(ie)}).scalefactor);
        saphirL1.data.(strmember{useentries(ie)}) = double(saphirL1.data.(strmember{useentries(ie)})) * ...
            double(tmpscalefactor);
        % Do nothing
        % else
        %    Do something
    end
    
    if isfield(saphirL1.attr.(strmember{useentries(ie)}),'addoffset')
        tmpaddoffset=str2num(saphirL1.attr.(strmember{useentries(ie)}).addoffset);
        saphirL1.data.(strmember{useentries(ie)}) = double(saphirL1.data.(strmember{useentries(ie)})) + ...
            tmpaddoffset;
        % Do nothing
        % else
        %    Do something
    end
end
% Include quality flags.
% If all data are read, use QFlags from structure
% If QFlags are not read, read QFs explicitly and apply
% Channel 1
for ie=6:11
    if isfield(saphirL1.data,strmember{ie+12})
        if ~isfield(saphirL1.data,strmember{ie})
            %            saphirL1.data.(strmember{ie})=  hdf5read(filename,h5member{ie});
            saphirL1.data.(strmember{ie})=  h5read(filename,h5member{ie});
        end
        [QFCh1validtmp,lsChtmp,lsmixChtmp]=getvalidpixels(saphirL1.data.(strmember{ie}));
        % set invalid entries to NaN
        saphirL1.data.(strmember{ie+12})(~QFCh1validtmp) = NaN;
    end
end
%Land Sea? Quality Flag Scan? --> if this is required, the according HDF5
%Entrie can be read and used strmember{12}
end

function [QFvalid,landsea,landseamix]=getvalidpixels(arrayQFCh)
% getvalidpixels scans all uint16 bits of the qualityflags to reurn only
% valid pixel
%
% getvalidpixels extracts the individual bits from the uint16 Quality Flag
% array of each channel and determines the validity of the pixels.
%
% input: arrayQFCh: array with uint16 containing the bitwise quality information
% output: QFvalid: array with true for valid bixels and false for invalid pixels, affected by any undesired error source.
%         landsea: mask defining land or sea surface
%         landseamix: mask defining mixes surfaces
%
% By Mathias Milz

%
% Access individual bits using 'bitget(A,BIT)'
%
% Bits 1, 2: Ice all values accepted
flag1 = bitget(arrayQFCh,1) | ~bitget(arrayQFCh,1) | bitget(arrayQFCh,2)...
    | ~bitget(arrayQFCh,2);
% Bits 3 = 0 blank
flag2 = ~bitget(arrayQFCh,3);
% BITS 4: Interpolation quality: should be 0
flag3 = ~bitget(arrayQFCh,4);
% BITS 5: ColdSky count error: should be 0
flag4 = ~bitget(arrayQFCh,5);
% BITS 6: Hoot Count error: should be 0
flag5 = ~bitget(arrayQFCh,6);
% BITS 7 and 8 : Calibration Flag: should be 0
flag6 = ~bitget(arrayQFCh,7) & ~bitget(arrayQFCh,8);
% BITS 9: Geo-location stimaton should be 0
flag7 = ~bitget(arrayQFCh,9);
% BITS 10: Level-0 Count poor value: should be 0
flag8 = ~bitget(arrayQFCh,10);
% BITS 11: Level-0 Count saturated: should be 0
flag9 = ~bitget(arrayQFCh,11);
% BITS 12: ON OFF Channel flag: should be 0
flag10 = ~bitget(arrayQFCh,12);
% BITS 13: SurfaceType: 0 Sea, 1 Land, both accepted
flag11 = ~bitget(arrayQFCh,13) | bitget(arrayQFCh,13);
landsea = bitget(arrayQFCh,13);
% BITS 14: LandSea contamination: 0 no contamination, 1 contamination, both accepted
flag12 = ~bitget(arrayQFCh,14) | bitget(arrayQFCh,14);
landseamix = bitget(arrayQFCh,14);
% BITS 15: Sun Glint: both accepted
flag13 = ~bitget(arrayQFCh,15) | bitget(arrayQFCh,15);
% BITS 16: TB validy: should be 0
flag14 = ~bitget(arrayQFCh,16);
QFvalid = flag1 & flag2 & flag3 & flag4 & flag5 & flag6 & flag7 & flag8 & ...
    flag9 & flag10 & flag11 & flag12 & flag13 & flag14;
end
