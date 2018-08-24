function [S,attr] = patmosx(file, varargin)

% SATREADERS.PATMOSX reads patmosx data
%
% Read PATMOS-x data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
% NOTE: This reader actually reads 2 files, one ascending, one descending
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% IN
%
%   file    string      Path to gzipped file
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
%   S = satreaders.patmosx(file, varargin)

% $Id: patmosx.m 8720 2013-10-21 20:41:39Z gerrit $
% Salomon Eliasson

core_fields = {'latitude','longitude','scan_line_time'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

% read both ascending and descending files. Get the attributes incase
% wanted
tmpdir = create_tmpfolder();
cleanupObject = onCleanup(@() delete_tmpfolder(tmpdir));
filename = uncompress(file,tmpdir);
% read the data. This also scales the data automatically!
S1  = read_clavrx_hdf(filename,all_fields);
S1.latitude = repmat(S1.latitude',[1,length(S1.longitude)]);
S1.longitude = repmat(S1.longitude,[size(S1.latitude,1),1]);

if regexp(file,'_asc_')
    file2 = strrep(file,'asc','des');
else
    file2 = strrep(file,'des','asc');
end

if exist(file2,'file')
    tmpdir2 = create_tmpfolder();
    cleanupObject2 = onCleanup(@() delete_tmpfolder(tmpdir2));
    filename = uncompress(file2,tmpdir2);
    S2  = read_clavrx_hdf(filename,all_fields);
    S2.latitude = repmat(S2.latitude',[1,length(S2.longitude)]);
    S2.longitude = repmat(S2.longitude,[size(S2.latitude,1),1]);
else
    S2 = [];
end

S = concatenateDatafields(S1,S2);

% rename some fields
S.lon = double(S.longitude(:));
S.lat = double(S.latitude(:));

% construct time axis with same dimensions
S.time = S.scan_line_time*3600; % is in hours
D = datasets;
info = D.patmosx.find_info_from_granule(file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));
S.version = info.version;
S.path = file;

S = rmfield(S,core_fields);

S = MaskInvalidGeoTimedataWithNaN(S);

end
%%%%%%%%%%%%%
% SUBFUNCTION

function S = concatenateDatafields(Sasc,Sdec)
%% concatinateDatafields
% 
%
% For each field make sure they are concatinated and then sorted by time (if applicable)
%

if ~isempty(Sdec)
    % FLATTEN the data
    sz = size(Sasc.scan_line_time);
    for F = fieldnames(Sasc)'
        if isequal(size(Sasc.(F{1})),sz)
            S.(F{1}) = [Sasc.(F{1})(:);Sdec.(F{1})(:)];
        end
    end
else
    % FLATTEN the data
    sz = size(Sasc.scan_line_time);
    for F = fieldnames(Sasc)'
        if isequal(size(Sasc.(F{1})),sz)
            S.(F{1}) = Sasc.(F{1})(:);
        end
    end
    
end
% SORT the data in ascending time
[S.scan_line_time,index] = sort(S.scan_line_time);
sz = size(S.scan_line_time);
for F = fieldnames(S)'
    if isequal(size(S.(F{1})),sz) && ~strcmp(F{1},'scan_line_time')
        S.(F{1}) = S.(F{1})(index);
    end
end

end
