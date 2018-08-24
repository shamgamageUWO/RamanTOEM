function collocate_and_store_date(year, month, day, ...
    sat1, sensor1, sat2, sensor2)

% collocate_and_store_date Collect collocations and store appropiately
%
% For a given date, check whether a collocation datafile exists.
% If it doesn't (or colloc_config('overwrite') is set), collocate the indicated
% satellites and sensors with each other and store the result in the
% appropiate datafile.
%
% FORMAT
%
%   collocate_and_store_date(year, month, day, sat1, sensor1, sat2, sensor2)
%
% IN
%
%   year    (numeric)   Year for which to write collocations
%   month   (numeric)   Month for which to write collocations
%   day     (numeric)   Day for which to write collocations
%   sat1    string      Primary satellite to consider
%   sensor1 string      Sensor at sat1 to consider
%   sat2    string      Secondary satellite to consider (POES means many)
%   sensor2 string      Sensor at secondary satellite to consider
%
% OUT
%
%   none (but writes file with write_collocations)
%
% $Id$

%% get filename

% check whether one or two sats should be passed. 

warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

switch number_sats_in_dataset(['collocation_' sensor1 '_' sensor2])
    case 1
        s = sat2;
    case 2
        s = {sat1, sat2};
end

if strcmp(sat2, 'poes')
    allsats = datasets_constants('POES_satellite_names');
    if iscellstr(s) % make satellite pairs {'noaa15', 'noaa18'} rather than
                    % looping over just the satellites
        allsats = mat2cell([allsats; repmat({sat1}, size(allsats))], ...
            2, ones(1, length(allsats)));
    end
    fileexists = all(cellfun(@(v) ...
        exist(...
            find_datafile_by_date([year month day], v, ...
                ['collocation_' sensor1 '_' sensor2]), ...
            'file'), ...
        allsats));
else
    fn = find_datafile_by_date([year month day], s, ...
        ['collocation_' sensor1 '_' sensor2]);
    fileexists = exist(fn, 'file');
end

%% check if file exists and if no, collocate

% no. of outputs of collocate_date is 1–3 depending on overlap, data, mean.
% For some, mean is N/A, so check colloc_constants('no_SENSOR1_SENSOR2').
% When writing collocations, all three are passed, but -1 is interpreted as
% "no value".

C = {-1 -1 -1};

if ~fileexists || colloc_config('overwrite')
    try
        [C{1:colloc_constants(['no_' sensor1 '_' sensor2])}] = ...
            collocate_date(year, month, day, sat1, sensor1, sat2, sensor2);
        writethingy = true;
     catch ME
         if strcmp(ME.identifier, 'atmlab:collocate_date:nosource')
             logtext(atmlab('ERR'), ...
                 'No succesful collocations at %04d-%02d-%02d, not writing\n', ...
                 year, month, day);
             writethingy = false;
         else
             ME.rethrow();
         end
    end
    if writethingy
        write_collocations_netcdf(year, month, day, C{1:3}, sat1, sensor1, sat2, sensor2);
    end
else
    logtext(atmlab('OUT'), 'Output file(s) %s already exist\n', fn);
end
end
