function write_collocations(year, month, day, S, D, M, ...
    sat1, sensor1, ~, sensor2)

% write_collocations Write collocation data to file
%
% Write collocation data for year/month/day in structure S to a filename. The
% filename is determined from the satellite and sensors used. Needs from
%
% FORMAT
%   
%   write_collocations(year, month, day, S, sat1, sensor1, sat2, sensor2)
%
% IN
%
%   year    (numeric)   Year for which S contains collocations
%   month   (numeric)   Month for which S contains collocations
%   day     (numeric)   Day for which S contains collocations
%   S       structure   As returned by collocate_date, structure whose
%                       field(s) describe the collocations between the sensors
%                       in question. (-1 means none)
%   D       structure   As returned by collocate_date, for the data (-1=none)
%   M       structure   As returned by collocate_date, for the mean data
%                       (-1 means none)
%   sat1    string      Primary satellite under consideration
%   sensor1 string      Sensor at primary satellite
%   sat2    string      Secondary satellite under consideration
%   sensor2 string      Sensor at secondary satellite.
%
% OUT
%
%   none (but writes a file)
%
% $Id$

error('NEEDS REPLACEMENT');
getfn = colloc_config(['filename_' sensor1 '_' sensor2]);

% number of different datasets

no = sum(cellfun(@isstruct, {S, M, D}));

fields = fieldnames(S);
for i = 1:length(fields)
    satname = fields{i};
    [C{1:no}] = getfn(year, month, day, sat1, satname);
    
    if ~exist(fileparts(C{1}), 'dir')
        logtext(colloc_config('stdout'), 'Creating %s\n', fileparts(C{1}));
        mkdir(fileparts(C{1}));
    end
    
    if ~isequal(S, -1)
        collocations = S.(satname);
        logtext(colloc_config('stdout'), 'Writing %s\n', C{1});
        save(C{1}, 'collocations');
    end
    if ~isequal(D, -1)
        data = D.(satname);
        logtext(colloc_config('stdout'), 'Writing %s\n', C{2});
        save(C{2}, 'data');
    end
    if ~isequal(M, -1)
        data_averaged = M.(satname);
        logtext(colloc_config('stdout'), 'Writing %s\n', C{3});
        save(C{3}, 'data_averaged');
    end
end
