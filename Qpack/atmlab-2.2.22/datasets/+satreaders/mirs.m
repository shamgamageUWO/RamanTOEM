function S = mirs(file, varargin)
% SATREADERS.MIRS reads MIRS data
%
% Read MIRS data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% IN
%
%   file    string      Path to hdf file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% FORMAT
%
%   S = satreaders.modis(file, varargin)

% $Id: mirs.m 8720 2013-10-21 20:41:39Z gerrit $
% Created by Salomon Eliasson

try
    X = read_native_mirs(file);
catch ME
    if strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch') % such as if nprf if incorrect
        error('atmlab:invalid_data','Something is wrong with the file')
    else
        error(ME.identifier,ME.message)
    end
    
end
    
core_fields   = {'scanUTC','lat','lon'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];
% List of hand-made fields that can be composed already here to save memory and
% storage space. I call them "pseudo fields" (e.g. modis_IWP that depends on 3
% fields in the modis file). The loop of hdfread will check if any psudeo fields
% are present. If so, it will be processed and the fields this pseudo field
% requires to be created are further assumed to be frivolous and therefore
% removed afterwards.
pseudo_fields = {'MIRS_IWP'};

for F = all_fields'
    if ismember(F{1},pseudo_fields)
        continue
    end
    S.(F{1}) = X.(F{1});
    if isvector(S.(F{1})),
        S.(F{1}) = S.(F{1})';
    end
end

S.lat   = double(S.lat);
S.lon   = double(S.lon);
S.time  = double(S.scanUTC);

% get the verion directly from the filename
D = datasets;
info = D.mirs.find_info_from_granule(file);
% year = YEAR2
date = dayofyear_inverse(2000+str2double(info.year02), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));

S.version = X.algsn; %actually algorithm serial number
S.path = file;

S = MaskInvalidGeoTimedataWithNaN(S);

S = rmfield(S,{'scanUTC'});

end

function S = read_native_mirs(filename)
%% read_native_mirs
% OUT   S   SSM/T-2 structure
%   TYPE   :: DEP_type
%     INTEGER                                    :: AlgSN      !MIRS Algorithm serial number (svn)
%     INTEGER                                    :: iTyp       !0->DEP from Scene, 1->DEP from retrieved scene
%     INTEGER                                    :: ProfIndx   !Profile Index
%     !---Positioning Data
%     REAL                                       :: Angle      !Angle
%     REAL                                       :: RelAziAngle!Relative Azimuth Angle
%     REAL                                       :: SolZenAngle!Solar Zenith Angle
%     REAL                                       :: lat        !Latitude
%     REAL                                       :: lon        !Longitude
%     INTEGER                                    :: node       !=0->ASC, =1->DESC
%     INTEGER                                    :: scanDay    !Day
%     INTEGER                                    :: scanYear   !Year
%     REAL                                       :: scanUTC    !UTC time
%     INTEGER                                    :: iscanPos   !Scan position
%     INTEGER                                    :: iscanLine  !Scan Line index
%     INTEGER                                    :: nPosScan   !Number of scan positions within scanline
%     INTEGER                                    :: nScanLines !Number of scan lines within orbit (msome might be missing)
%     !---Atmospheric/Hydrometeors/Cloud-related information
%     INTEGER                                    :: iTypAtm    !Atmospheric type ID
%     CHARACTER(LEN=20)                          :: DescTypAtm !Label of the atmospheric class
%     REAL                                       :: TPW        !Total precipitable Water
%     REAL                                       :: Clw        !Integrated Cloud amount
%     REAL                                       :: RWP        !Integrated Liquid Rain water path
%     REAL                                       :: LWP        !Integrated Liquid Water Path
%     REAL                                       :: SWP        !Integrated Snow water path
%     REAL                                       :: IWP        !Integrated Ice water path
%     REAL                                       :: GWP        !Integrated Graupel water path
%     REAL                                       :: RR         !Surface rain rate
%     REAL                                       :: SFR        !Snow falling rate
%     REAL                                       :: CldTop     !Cloud Top Pressure
%     REAL                                       :: CldBase    !Cloud Base Pressure
%     REAL                                       :: CldThick   !Cloud thickness
%     REAL                                       :: PrecipType !Precipitation type (frozen/liquid)
%     REAL                                       :: RainFlag   !Rain flag
%     !---Surface -related information
%     INTEGER                                    :: iTypSfc    !Surface type ID
%     CHARACTER(LEN=20)                          :: DescTypSfc !Label of the surface class
%     REAL                                       :: SWE        !Snow water equivalent
%     REAL                                       :: SnowGS     !Snow Effective Grain Size
%     REAL                                       :: SnowCover  !Snow cover extent
%     REAL                                       :: SM         !Soil Moisture
%     REAL                                       :: SIC        !Sea-ice concentration
%     REAL                                       :: SIC_MY     !Multi-year Sea-ice concentration
%     REAL                                       :: SIC_FY     !First-year Sea-ice concentration
%     REAL                                       :: WindSp     !Wind speed
%     REAL                                       :: WindDir    !Wind vector
%     REAL                                       :: WindU      !U-direction wind speed
%     REAL                                       :: WindV      !V-direction wind speed
%     !---QC info
%     INTEGER,           DIMENSION(4)            :: qc         !QC vector
%     !---Convergence items (when the DEP is coming from a retrieved scene )
%     INTEGER                                    :: nIter      !Number of iterations
%     REAL                                       :: ChiSq      !Convergence metric
%
%
% IN    filename            Name of SSM/T-2 file
% OPT

% 2009-11-20   Created by Oliver Lemke and Salomon Eliasson.

errId = ['atmlab:' mfilename ':error'];
if ~exist(filename,'file')
    error(errId,'No such file:  %s',filename)
end
tmpdir = create_tmpfolder();
cleanupObject = onCleanup(@() delete_tmpfolder(tmpdir));
filename = uncompress(filename,tmpdir);
if isempty(filename), error(errId,'Uncompressing failed'); end

fid = fopen (filename, 'rb', 'b');
cleanupObj2 = onCleanup(@() (fclose(fid)));
if (fid == -1)
    error (errId, 'Can''t open input file %s', filename);
end


% READ THE BINARY DATA file

% HEADER
fread (fid, 1, 'int32');
S.itype      = fread (fid, 1, 'int32');
S.algsn      = fread (fid, 1, 'int32');
fread (fid, 1, 'int32');

fread (fid, 1, 'int32');
S.nprf       = fread (fid, 1, 'int32');
fread (fid, 1, 'int32');

fread (fid, 1, 'int32');
S.nPosScan   = fread (fid, 1, 'int32');
fread (fid, 1, 'int32');

fread (fid, 1, 'int32');
S.nScanLines = fread (fid, 1, 'int32');
fread (fid, 1, 'int32');

% loop over profiles
allfields = {'ProfIndx','iTypAtm','TPW','Clw','RWP','SWP','IWP','GWP',...
    'RR','SFR','CldTop','CldBase','CldThick','PrecipType','RainFlag',...
    'LWP','iTypSfc','SWE','SnowCover','SM','SIC','WindSp','WindDir',...
    'WindU','WindV','SnowGS','SIC_FY','SIC_MY','QC','lat','lon','node',...
    'scanUTC','scanYear','scanDay','iscanPos','iscanLine','angle',...
    'RelAziAngle','SolZenAngle','nIter','ChiSq'};
tmp =  cell(1,2*length(allfields)); tmp(1:2:end-1)= allfields;
X = struct(tmp{:});
for i = 1:S.nprf
    % profile index
    fread (fid,1,'int32');
    X.ProfIndx(i) = fread (fid,1, 'int32');
    fread (fid, 1, 'int32');
    
    % ATMOSPHERIC
    fread (fid, 1, 'int32');
    X.iTypAtm(i)     = fread (fid, 1, 'int32');
    X.TPW(i)         = fread (fid, 1, 'single');
    X.Clw(i)         = fread (fid, 1, 'single');
    X.RWP(i)         = fread (fid, 1, 'single');
    X.SWP(i)         = fread (fid, 1, 'single');
    X.IWP(i)         = fread (fid, 1, 'single');
    X.GWP(i)         = fread (fid, 1, 'single');
    X.RR(i)          = fread (fid, 1, 'single');
    X.SFR(i)         = fread (fid, 1, 'single');
    X.CldTop(i)      = fread (fid, 1, 'single');
    X.CldBase(i)     = fread (fid, 1, 'single');
    X.CldThick(i)    = fread (fid, 1, 'single');
    X.PrecipType(i)  = fread (fid, 1, 'single');
    X.RainFlag(i)    = fread (fid, 1, 'single');
    X.LWP(i)         = fread (fid, 1, 'single');
    fread (fid, 1, 'int32');
    
    % SURFACE
    fread(fid,1,'int32');
    X.iTypSfc(i)     = fread (fid, 1, 'int32');
    X.SWE(i)         = fread (fid, 1, 'single');
    X.SnowCover(i)   = fread (fid, 1, 'single');
    X.SM(i)          = fread (fid, 1, 'single');
    X.SIC(i)         = fread (fid, 1, 'single');
    X.WindSp(i)      = fread (fid, 1, 'single');
    X.WindDir(i)     = fread (fid, 1, 'single');
    X.WindU(i)       = fread (fid, 1, 'single');
    X.WindV(i)       = fread (fid, 1, 'single');
    X.SnowGS(i)      = fread (fid, 1, 'single');
    X.SIC_FY(i)      = fread (fid, 1, 'single');
    X.SIC_MY(i)      = fread (fid, 1, 'single');
    fread(fid,1,'int32');
    
    % QUALITY FLAGS
    fread(fid,1,'int32');
    X.QC(i,1:4)   = fread (fid, 4, 'int32');
    fread(fid,1,'int32');
    
    % POSITION
    fread(fid,1,'int32');
    X.lat(i)         = fread (fid, 1, 'single');
    X.lon(i)         = fread (fid, 1, 'single');
    X.node(i)        = fread (fid, 1, 'int32');
    X.scanUTC(i)     = fread (fid, 1, 'single');
    X.scanYear(i)    = fread (fid, 1, 'int32');
    X.scanDay(i)     = fread (fid, 1, 'int32');
    X.iscanPos(i)    = fread (fid, 1, 'int32');
    X.iscanLine(i)   = fread (fid, 1, 'int32');
    X.angle(i)       = fread (fid, 1, 'single');
    X.RelAziAngle(i) = fread (fid, 1, 'single');
    X.SolZenAngle(i) = fread (fid, 1, 'single');
    fread(fid,1,'int32');
    
    if S.itype==1
        % RETRIEVED SCENE
        fread(fid,1,'int32');
        X.nIter(i)   = fread (fid, 1, 'int32');
        X.ChiSq(i)   = fread (fid, 1, 'single');
        fread(fid,1,'int32');
    else
        X.nIter(i)   = -1;
        X.ChiSq(i)   = 0;
    end
end
S = catstruct(S,X);

end
