function S_res = grasdir(file, varargin)
% GRASDIR read directory of gras data
%
% This is a reading routine for the Global Navigation Satellite System
% (GNSS) Receiver for Atmospheric Sounding (GRAS) data directories.
% In GRAS measurements, a single measurement is stored in a single
% NetCDF-file.  In the framework of the collocation toolkit, this is
% impractical and inefficient.  Therefore, the reading is done for a
% whole directory, which still contains only ~20 MiB of data.
%
% For calling format, see Contents.m.  Note that you should pass a
% directory, not a file!
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.

% $Id: grasdir.m 8720 2013-10-21 20:41:39Z gerrit $

% WARNING: functionality relies on consistent no. and order of data
% files within directory!

assert(isdir(file), ['atmlab:' mfilename ':notadirectory'], ...
    'function ''grasdir'' wants a directory, which %s is not', file);

core_fields   = {'lat','lon'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

cont = dir(file);
fullpaths = cellfun(@(x) fullfile(file, x), {cont.name}, 'UniformOutput', false);

% read data into a cell array of structures
path_is_gran = cellfun(@any, strfind(fullpaths, 'nc'));
alldata = cellfun(@(f) loadncvar(f, all_fields), ...
        fullpaths(path_is_gran), ...
        'UniformOutput', false);

% convert cell array of structures into structure with matrices
% NB: this would be the direct output from cellfun with 'UniformOutput'
% set to true, but I cannot assume this if some fields have non-constant
% data sizes
S = horzcat(alldata{:});
if isempty(alldata)
    S_res = cell2struct(repmat({[]}, size(all_fields)), all_fields);
    S_res.epoch = 0;
    S_res.time = [];
    S_res.version = '?';
    return;
end
flds = fieldnames(S(1));
varying_size = cellfun(@(fn) length(unique(cellfun(@length, {S.(fn)}))), flds)>1;
vals = cellfun(@(f) [S.(f)].', flds(~varying_size), 'UniformOutput', false);
S_res = cell2struct(vals.', flds(~varying_size).', 2);

if length(find(varying_size)) > 0
    logtext(atmlab('ERR'), 'Cannot concatenate fields: %s\n', ...
        strjoin(flds(varying_size)));
end

% add time info from filenames
% hardcode regular expression here; this is about files inside the
% 'granule' directory, not the 'granule' directory itself
f_re = 'wet(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})_(?<hour>\d{2})(?<minute>\d{2})(?<second>\d{2})_M.._\d*_N\d*_X*\.nc';
info = regexp({cont(path_is_gran).name}, f_re, 'names');
% str to double and cell array to struct array
info = cellfun(@(S) structfun(@str2double, S, 'UniformOutput', false), info, 'UniformOutput', false);
info = horzcat(info{:});
S_res.time = vec2col([info.hour] * 3600 + [info.minute] * 60 + [info.second]);
S_res.epoch = date2unixsecs(info(1).year, info(1).month, info(1).day);
assert(length(unique([info.day]))==1, ['atmlab:' mfilename ':multi-day'], ...
    'Data appear to span multiple days, I did not expect that');

S_res.version = '?';
end
