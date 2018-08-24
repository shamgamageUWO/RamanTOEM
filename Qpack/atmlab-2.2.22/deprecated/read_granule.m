function M = read_granule(sat, sensor, datevec, remdouble, force)

% read_granule Read any sat/sensor granule (levels 1 and 2)
%
% High-level function to read a particular granule for a
% satellite/sensor-pair, if one doesn't know what function is suitable to
% use to read it. It also gets rid of ballast.
%
% Uses datasets_config('read_SENSOR') to find out what function to use to
% read this particular data. Uses granule_first_line to find out the first
% scanline to use (e.g. the rest are doubles).
%
% Valid datasets are returned by <a href="matlab:help list_datasets">list_datasets</a>.
%
% FORMAT
%
%   M = read_granule(sat, sensor, datevec, remdouble, force)
%
% IN
%
%   sat         string      Satellite (noaa18, cloudsat, etc.)
%   sensor      string      Sensor or dataset (mhs, hirs, cpr, hirscs, etc.)
%   datevec     vector      Date-vector indicating the starting time.
%   remdouble   logical     (optional) Remove doubles or not? Default true.
%   force       logical     (optional) rather than throwing an error,
%                           return [] in case of error. Default false.
%
% OUT
%
%   M       struct      Contains at least lat, lon, time and one or more
%                       data fields. Exact results depend on the particular
%                       satellite/sensor-pair.
%
% $Id: read_granule.m 7564 2012-05-02 14:24:45Z gerrit $

warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

if ~exist('remdouble', 'var')
    remdouble = true;
end

if ~exist('force', 'var')
    force = false;
end

% find datafile and function to read it
datafile = find_datafile_by_date(datevec, sat, sensor);
reader = datasets_constants(['read_' sensor]);

% read datafile
%logtext(colloc_config('stdout'), '%s(''%s'')\n', ...
%    func2str(reader), datafile);
try
    M = reader(datafile);
catch ME
    if force
        switch ME.identifier
            case 'atmlab:invalid_data'
                logtext(atmlab('ERR'), ...
                    'Unable to read HIRS-data: %s\n', ME.message);
                M = [];
                return
            otherwise
                ME.rethrow();
        end
    else
        ME.rethrow();
    end
end
%logtext(colloc_config('stdout'), 'read %s\n', datafile);
nlines = size(M.time, 1);

if remdouble
    % read ballast
    firstline = granule_first_line(sat, sensor, datevec);
    % get rid of ballast
    for f = fieldnames(M)'
        fn = f{1};
        if isnumeric(M.(fn)) && size(M.(fn), 1) == nlines
            % magic in next lines explained at
            % http://www.mathworks.de/matlabcentral/newsreader/view_thread/290890
            sz = size(M.(fn));
            M.(fn) = reshape(M.(fn)(firstline:nlines, :), [nlines-firstline+1, sz(2:end)]);
        end
    end
end
end
