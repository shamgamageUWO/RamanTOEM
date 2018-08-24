function S = ssmt2_read_ngdc(fn, varargin)

% ssmt2_read_ngdc Read SSM-T/2 NGDC file
%
% Reads an SSM-T/2 file from NGDC
%
% FORMAT
%
%   S = ssmt2_read_ngdc(path_to_file)
%
% IN
%
%   path_to_file    String representing path to file containing data.
%                   Either compressed or plain.
%   fields          Cella rray of strings containing fields to read.
%                   Optional; by default, read all fields.
%                   To explicitly read all, pass string 'all'.
%                   See below for valid fields.
%
% OUT
%
%   S               structure with data fields
%
%
% Fields that can be read:
%
% global_attributes ancil_data tb lon lat channel_quality_flag
% gain_control counts_to_tb_gain counts_to_tb_offset thermal_reference
% Temperature_misc_housekeeping warm_counts cold_counts 

% $Id: ssmt2_read_ngdc.m 8201 2013-02-14 09:10:26Z seliasson $

[~, ~, ext] = fileparts(fn);
fields = optargs(varargin, {'all'});

%% unpack if necessary
if strcmpi(ext, '.gz') 
    T2file = uncompress(fn, atmlab('WORK_AREA'), struct('unidentified', 'error'));
    c1 = onCleanup(@()delete(T2file));
else
    T2file = fn;
end

%% convert from T2 to nc. Needs Python.
pyscript = fullfile(fileparts(mfilename('fullpath')), ...
                    'ssmt2_reader_netcdf.py');

try 
    ncfile = [tempname(atmlab('WORK_AREA')) '.nc'];
    c2 = onCleanup(@()delete(ncfile));
    cmd = [atmlab('PYTHON') ' ' pyscript ' ' T2file ' ' ncfile];
    [out, ret] = exec_system_cmd(cmd, true, false);
catch ME
    error(['atmlab:' mfilename ':conversion'], ...
        ['I tried to convert from T2 to nc using a Python script, ' ...
         'but failed. You need a Python installation with a suitable ' ...
         'right NetCDF library. The problem was: %s'], ME.message);
end
                
switch nargin
    case 1
        S = loadncfile(ncfile);
    case 2
        [S, S.global_attributes] = loadncvar(ncfile, fields);
    otherwise
        error(['atmlab:' mfilename], 'I can''t possibly be here!');
end

end
