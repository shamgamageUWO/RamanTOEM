function attributes = loadncattr( ncfile , varargin)
%% loadncattr
%
% PURPOSE
%         Load the attributes for all variables in a netcdf file, or just a
%         subset of them
%
% IN
%       ncfile          is either a string filename 
%                       OR
%                       an id of an already open netcdf file
%
%       variables       {'str','str2'} variables to read. if none are given, read all
%
% OUT
%       attributes       struct
%
% Salomon Eliasson
% $Id: loadncattr.m 8189 2013-02-11 14:06:53Z olemke $

errId = ['atmlab:' mfilename];

if ischar(ncfile)
    % UNCOMPRESS if needed
    if strcmp(ncfile(end-2:end),'.gz')
        tmpdir = create_tmpfolder;
        c= onCleanup(@() rmdir(tmpdir,'s'));
        ncfile = uncompress(ncfile,tmpdir);
        if isempty(ncfile), error(errId,'Uncompressing failed'); end
    end
    
    ncid = netcdf.open (ncfile, 'NOWRITE');
    cleanupObject = onCleanup(@() netcdf.close (ncid));
    
else
    ncid = ncfile;
end

[~,nvars] = netcdf.inq(ncid);

[inVars] = optargs(varargin,{''});
isstr=~iscell(inVars); % if only one varname is given
if isstr, inVars={inVars}; end

attributes = struct();
for i = 0:nvars-1
    [varname, ~, ~, natts] = netcdf.inqVar (ncid, i);
    svarname = genvarname(varname);
    if ~isempty(varargin) && ~any(ismember(inVars,svarname)) % skip if I want specific vars
        continue
    end
    for j = 0:natts-1
        attname = netcdf.inqAttName (ncid, i, j);
        if ~isempty(varargin) && isstr 
            attributes.(genvarname(attname)) = ...
                netcdf.getAtt (ncid, i, attname);
        else
            attributes.(svarname).(genvarname(attname)) = ...
                netcdf.getAtt (ncid, i, attname);
            
        end
    end
end

end
