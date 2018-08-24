function S = avhrr_cmsaf_gac(file, varargin)

% SATREADERS.AVHRR_CMSAF_GAC Read avhhrCMSAF data in the common format
%
% This file reads data from a avhhrCMSAF file and rearranges the fields to
% the common format. Geodata and time data are always retrieved from the
% data file.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
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
%   S = satreaders.cmsaf_gac(file, varargin)
%
% See also: SatDataset/reader

% $Id: avhrr_cmsaf_gac.m 8720 2013-10-21 20:41:39Z gerrit $
% Created by Salomon Eliasson

core_fields   = {'time','lat','lon'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];
% List of hand-made fields that can be composed already here to save memory and
% storage space. I call them "pseudo fields" (e.g. modis_IWP that depends on 3
% fields in the modis file). The loop of hdfread will check if any psudeo fields
% are present. If so, it will be processed and the fields this pseudo field
% requires to be created are further assumed to be frivolous and therefore
% removed afterwards.
pseudo_fields = {'AVHRR_IWP'};

S.path = file; % get original file

% UNCOMPRESS (if needed)
tmpdir = create_tmpfolder;
c = onCleanup(@() rmdir(tmpdir,'s'));
file = uncompress(file,tmpdir);

for F = all_fields'
    if ismember(F{1},pseudo_fields)
        continue
    end
    S.(F{1}) = loadncvar(file,F{1});
end

% turn time data into seconds (in hours)
S.time = S.time*3600;

S.lat  = double(S.lat'*0.01); % use scale (see attributes), make along x across
S.lon  = double(S.lon'*0.01); % use scale (see attributes), make along x across
S.time = double(S.time);

% get the verion directly from the filename
D = datasets;
info = D.avhrr_cmsaf_gac.find_info_from_granule(file);
S.epoch = round(date2unixsecs(str2double(info.year), str2double(info.month), str2double(info.day)));

if any(ismember(pseudo_fields,extra_fields))
    for P = pseudo_fields(:)'
        S = dealWithPseudoFields(S,P{1},file);
    end
end
S.version = info.version;

S = MaskInvalidGeoTimedataWithNaN(S);

end

%%%%%%%%%%%%%
% SUBFUNCTION

function S = dealWithPseudoFields(S,field,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here to save memory
% and storage space. Will check in the loop if this field is present. The
% crux is that the fields the psuedo field relies on must be read, hence
% listed before it. This is because they are ofcourse needed to build the
% data field. and the fields it required are further assumed to be
% frivolous and therefore removed afterwards. This part is hardcoded

% READ dependent fields
switch field
    case 'AVHRR_IWP'
        dependent_fields = {'cwp','cty'};
        rmflag = ~ismember(dependent_fields,fieldnames(S));
        for F = dependent_fields
            S.(F{1}) = loadncvar(file,F{1})'; % orientation is across x along
        end
end

% use dependent fields to BUILD the pseudo field
switch field
    case 'AVHRR_IWP'
        
        % Keeping record of the pixels that are deemed to be cloud free
        clearPixel = S.cty==0;
        %S.cwp(clearPixel)=0;
        
        % grab values flagged as ice phase
        icePhase = S.cty==2;
             
        % NaN all non applicable data
        S.cwp(~(clearPixel | icePhase)) = NaN;
        
        % Therefore we can call this simply IWP
        S.AVHRR_IWP = S.cwp;
        
end

S=rmfield(S,dependent_fields(rmflag));
end
