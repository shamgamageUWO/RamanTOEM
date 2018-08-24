function [d, attr] = read_cloudsat_hdf(hdfFile, sdsName)
% READ_CLOUDSAT_HDF Generic reader for CloudSat data
%
% IN  
%     hdfFile  '%s'                string path and name of the hdf file
%     sdsName  '%s' or {'%s',..}   string fieldname or a cellarray of fieldnames
%
% OUT 
%     d        structure           structure containing desired fields from sdsName  
%     attr     structure           structure containing the associated
%                                  attributes of those fields
%
% Example:
%
% >> [d, attr] = read_cloudats_hdf( ...
%     '2010069075419_20562_CS_2B-CWC-RO_GRANULE_P_R04_E03.hdf', ...
%     {'Latitude', 'Longitude'});
%
% >> d
% d =
%
%   Latitude: [1x37082 single]
%   Longitude: [1x37082 single]
%
% >> attr
% attr =
%
%   Latitude: [1x5 struct]
%   Longitude: [1x5 struct]
%
% USAGE
%      [d, attr] = read_cloudsat_hdf(hdfFile, {'field1','field2','etc'})
%
% NOTE: 
%      This function reads the data as is, i.e. no scaling, converting,
%      etc. The 2nd output variable contains the attributes of all the fields 
%      in sdsName
%
%
% Created by Salomon Eliasson based on read_clavrx_hdf by 
% Aleksandar Jelenak <Aleksandar.Jelenak@noaa.gov>
%
% LAST MODIFICATION: "$Id: read_cloudsat_hdf.m 8316 2013-03-27 17:06:01Z gerrit $"

% Error checking.
narginchk(2, 2);
nargoutchk(1, 2);

errId = ['atmlab:' mfilename];
assert(iscellstr(sdsName) || (ischar(sdsName) && size(sdsName, 1) == 1),...
    [errId ':badInput'],'Input argument SDSNAME must be a cell array of strings or a string!');

% UNCOMPRESS if needed
if any([strcmp(hdfFile(end-2:end),'.gz'),strcmp(hdfFile(end-3:end),{'.zip','.bz2'})])
	tmpdir = create_tmpfolder;
    c = onCleanup(@() rmdir(tmpdir,'s'));
    % use a try-catch clause; in some rare cases, the shell unzip cannot
    % unzip but the Matlab built-in unzip can.
    try 
        hdfFile = uncompress(hdfFile, tmpdir);
    catch ME
        switch ME.identifier
            case 'atmlab:exec_system_cmd:shell'
                hdfFile = uncompress(hdfFile, tmpdir, struct('tool', 'builtin'));
            otherwise
                ME.rethrow();
        end
    end
    if isempty(hdfFile)
        error(errId,'Uncompressing failed');
    end
end

% Query the contents of the HDF file.
s = hdfinfo(hdfFile);

% Turn sdsName into a column vector of cell strings.
if iscellstr(sdsName)
    sdsName = sdsName(:);
else
    sdsName = cellstr(sdsName);
end

Vgroup = s.Vgroup.Vgroup;

a = isstruct(s.Attributes);
vd1  = isstruct(Vgroup(1).Vdata);
vd2  = isstruct(Vgroup(1).Vdata);
sds1 = isstruct(Vgroup(1).SDS);
sds2 = isstruct(Vgroup(2).SDS);

% Unfortunately the following fields are not always filled in
allfields = {};
if a, allfields{end+1} = {s.Attributes.Name}; end % Attributes
if vd1, allfields{end+1} = {Vgroup(1).Vdata.Name}; end % Geolocation Fields
if vd2, allfields{end+1} = {Vgroup(2).Vdata.Name};end % Data Fields
if sds1, allfields{end+1} = {Vgroup(1).SDS.Name}; end % Height 2D
if sds2, allfields{end+1} = {Vgroup(2).SDS.Name}; end % Data 2D
allfields = [allfields{:}];

if nargout == 2
    Attributes = {};
    if a, Attributes{end+1} = {s.Attributes.Value}; end
    if vd1, Attributes{end+1} = {Vgroup(1).Vdata.DataAttributes}; end
    if vd2, Attributes{end+1} = {Vgroup(2).Vdata.DataAttributes}; end
    if sds1, Attributes{end+1} = {Vgroup(1).SDS.Attributes}; end
    if sds2, Attributes{end+1} = {Vgroup(2).SDS.Attributes}; end
    Attributes = [Attributes{:}];
end

% Start looping over elements of sdsName.
for i = 1:length(sdsName)
    
    % Look for the SDS var using user-supplied name.
    assert(ismember(sdsName{i}, allfields),...
        [errId ':MissingFromFile'],'variable %s is missing in %s',sdsName{i}, hdfFile)
    
    % READ the data.
    d.(sdsName{i}) = hdfread(hdfFile,sdsName{i});
    
    % hdfread outputs the data in a 1x1 cell. We don't need that
    if iscell(d.(sdsName{i})) && length(iscell(d.(sdsName{i})))==1
        d.(sdsName{i}) = d.(sdsName{i}){1};
    end
    
    % make sure strings are always rowvectors
    if ischar(d.(sdsName{i}))
        d.(sdsName{i}) = d.(sdsName{i})(:)';
    end
        
    % Return SDS attributes if the user has supplied a second output variable.
    if nargout == 2
        attr.(sdsName{i}) = Attributes{ismember(allfields,sdsName{i})};
    end
end
