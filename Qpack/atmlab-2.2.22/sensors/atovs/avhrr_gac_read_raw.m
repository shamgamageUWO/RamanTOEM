function varargout = avhrr_gac_read_raw(fn, varargin)

% avhrr_gac_read_raw Read raw (uncalibrated, unprocessed) AVHRR GAC
%
% Read uncalibrated, unprocessed AVHRR GAC data.  It verifies that the file
% is actually AVHRR GAC and applies scale factors, but no calibration or
% geolocation is performed.  For this, see avhrr_gac_read.
%
% For valid field names, call <a href="matlab:help avhrr_define_gac_l1b">avhrr_define_gac_l1b</a>
%
% FORMAT
%
%   [data_head, data_line] = avhrr_gac_read_raw(filename, fields_head, fields_line, lines)
%
% IN
%
%   filename    string      Path to file to read data from
%   fields_head cell-string Fields from header to return
%   fields_line cell-string Fields from each line to return
%   lines       array       Lines to return (0=none).  Default all.
%
% OUT
%
%   data_head   struct      With the required fields
%   data_line   struct with arrays containing data.  Scale factors ar
%
% EXAMPLE
%
% >> data_head = avhrr_gac_read_raw('/local/gerrit/tmp/NSS.GHRR.NN.D08221.S1247.E1434.B1658586.GC', ...
%                   {'avh_h_siteid', 'avh_h_startdatayr', 'avh_h_dataname', 'avh_h_satid'})
% 
% data_head = 
% 
%         avh_h_siteid: [3x1 char]
%    avh_h_startdatayr: 2008
%       avh_h_dataname: [42x1 char]
%          avh_h_satid: 7
%
% See also: avhrr_define_gac_l1b, avhrr_gac_read, avhrr_gac_read_raw

% Format is defined in NOAA KLM User's Guide, section 8.3.1.4.3.2, in
% particular in Table 8.3.1.4.3.2-1.  Page 8-79 or page 363.
% http://www.ncdc.noaa.gov/oa/pod-guide/ncdc/docs/klm/html/c8/sec83143-2.htm

%
% $Id: avhrr_gac_read_raw.m 8345 2013-04-17 18:16:40Z gerrit $

record_size = 4608; % KLM Guide, Section 8.3.1.4.3.2
%n_scanpos = 682;

% get total no. of records
% S = dir(fn);
% nrecords = S.bytes/record_size-1;

[fields_head, fields_line, lines] = optargs(varargin, {{}, {}, -1});

[def_head, def_line] = avhrr_define_gac_l1b();

fp = fopen(fn, 'r', 'b'); % b=big-endian
c = onCleanup(@()fclose(fp));

%% read header fields

data_head = cell2struct(cellfun(@(v) readfield(fp, v, def_head, 0), fields_head, 'UniformOutput', false), fields_head, 2);

%% check data integrity (first 3 characters should do) and verify GAC

fseek(fp, 0, 'bof');
siteid = fread(fp, 3, 'char=>char').';
if ~any(strcmp(siteid, {'NSS', 'DSS', 'CMS', 'UKM'}))
    error(['atmlab:' mfilename ':invalid'], ...
        'Unexpected start of file %s.  Expected first 3 bytes to be one of: NSS DSS CMS UKM.  Not a l1a granule?', fn);
end

fseek(fp, 77, 'bof');
typecode = fread(fp, 1, 'uint16=>uint16');
if typecode ~= 512
    error(['atmlab:' mfilename ':notGAC'], ...
        'Data does not appear to be GAC (typecode = %d, expected 512)', typecode);
end

%% read data fields

nrecords = single(data_head.avh_h_scnlin);
if lines == -1
    lines = nrecords;
end

if isscalar(lines) % interpret as 1,...,lines
    lines = 1:lines;
end

fseek(fp, record_size, 'bof');
data_raw = fread(fp, record_size*nrecords, 'uint8=>uint8', 0);

for field = fields_line
    octets = bsxfun(@plus, ...
        uint32((lines-1).*record_size).', ...
        uint32(def_line.(field{1}).End_Octet:-1:def_line.(field{1}).Start_Octet)).';
    data_casted = typecast(data_raw(octets(:)), def_line.(field{1}).cast_type);
    
    NoW = def_line.(field{1}).Number_of_Words;
    data_reshaped = reshape(data_casted, [NoW, length(data_casted)/NoW]);
    % due to the reading in reverse order, scanlines are reversed
    data_fixed = data_reshaped(end:-1:1, :);
    if def_line.(field{1}).Scale_Factor ~= 0
        data_fixed = single(data_fixed) / 10.^single(def_line.(field{1}).Scale_Factor);
    end
    data_alt.(field{1}) = data_fixed;
    typecast(data_raw(octets(:)), def_line.(field{1}).cast_type);
    
end

if exist('data_alt', 'var')
%    varargout = {data_head, data_line};
    varargout = {data_head, data_alt};    
else
    varargout = {data_head};
end

end
function val = readfield(fp, f, def, offset)
% readfield Reads field from AVHRR GAC
%


code = fseek(fp, offset+uint32(def.(f).Start_Octet)-1, 'bof');
if code ~= 0
    error(['atmlab:' mfilename ':IOError'], ferror(fp));
end
%skip = 0;
val = fread(fp, def.(f).read_size, def.(f).read_type, 0);
% Scale factor from 8.3.1.1 Data Set Structure
if def.(f).Scale_Factor ~= 0
    val = single(val) / 10.^single(def.(f).Scale_Factor);
end
end
