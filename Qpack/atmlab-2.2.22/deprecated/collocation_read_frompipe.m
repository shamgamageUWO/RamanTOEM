function M = collocation_read_frompipe(hdf5file, fields, query)

% collocation_read_frompipe Low-level, read collocations as client to pytables server
%
% EXPERIMENTAL! Function in α/β and subject to change.
%
% FORMAT
%
% IN
%
%   hdf5file    string      full, absolute path to hdf5file. The absolute
%                           path is required for the correct calculation
%                           of the path to the lockfile.
%   fields      cellstr
%   query
%
%
% TODO:
%   - select particular columns from AMSU/MHS etc.
%   - read meandata and avhrrdata correctly
%   - convert limmat to query-string
%   - do not-exactly-one-year correctly
%   - handle errors
%   - have a better way to treat path_to_server
%
% $Id: collocation_read_frompipe.m 7553 2012-04-27 19:08:16Z gerrit $

%% initialise
path_to_server = '/storage4/home/gerrit/svn/sources/python/scripts/collocation_read.py';

% note: make sure this matches Pythons calculations
lockfile = fullfile('/tmp', strrep(hdf5file, '/', '_'));
% convert fields cellstr to fields "A B C"-string
fields = cellfun(@(c) [c ' '], fields, 'UniformOutput', false);
fields = horzcat(fields{:});
fields = deblank(fields);
scan_format = '%g';

if ~exist(lockfile, 'file') % Start server
    logtext(atmlab('OUT'), 'Initialising program\n');
    c = num2str(round(100*rand));
    pipe_in_name = fullfile(atmlab('WORK_AREA'), ['pipereader' strrep(hdf5file, '/', '_') c]);
    pipe_out_name = fullfile(atmlab('WORK_AREA'), ['pipewriter' strrep(hdf5file, '/', '_') c]);
    log_name = fullfile(atmlab('WORK_AREA'), ['pipelogger' strrep(hdf5file, '/', '_') c]);

    command = sprintf([path_to_server ' -vd -i %s -o %s -f %s -l %s'], ...
        pipe_in_name, pipe_out_name, hdf5file, log_name);
    system(command);
end

%% open files
wait_for_existence(lockfile, 2, 0.1);
f = fileopen(lockfile, 'r');
[~] = fgets(f); % first line is pid
pipe_in_name = deblank(fgets(f));
pipe_out_name = deblank(fgetl(f));
log_name = deblank(fgetl(f));

wait_for_existence(pipe_out_name, 2, 0.1);
pipe_out = fileopen(pipe_out_name, 'r');
wait_for_existence(log_name, 2, 0.1);
logfile = fileopen(log_name, 'r');
fseek(logfile, -1, 'eof');
wait_for_existence(pipe_in_name, 2, 0.1);
pipe_in = fileopen(pipe_in_name, 'w');

%% communicate
logtext(1, 'Sending query: %s ''FIELDS'' %s\n', query, fields);
% send command to program
fprintf(pipe_in, [query ' FIELDS ' fields '\n']);
% read output until '.'
i = 0;
while true
    i = i + 1;
    if mod(i, 100) == 0
        % do a 'tail -f' of the logfile
        fwrite(1, fread(logfile, inf, '*char'));
    end
    line = fgets(pipe_out);
    if strcmp(deblank(line), '.')
        break
    else
        data_in_line = sscanf(line, scan_format);
        if i == 1
            data_total = data_in_line.';
        else
            data_total(i, :) = data_in_line;
        end
        if i == size(data_total, 1) % pre-allocate some more
            data_total = [data_total; nan(size(data_total))]; %#ok<AGROW>
            logtext(1, 'Doubling allocation to %d lines\n', size(data_total, 1))
        end
    end
end
fwrite(1, fread(logfile, inf, '*char'));
%% finalise

M = data_total(~isnan(data_total(:, 1)), :);

end
