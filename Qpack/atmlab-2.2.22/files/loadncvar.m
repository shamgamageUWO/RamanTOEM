% LOADNCVAR   Loads a specific variable(s) from a NetCDF file
%
%    The function enables direct loading of a named variable from a NetCDF
%    file. varname can be either a string to load one variable or a cell
%    array of several variable names.
%
%    When multiple varnames are given (or if a single varname is given in a cell)
%    the return value is a structure containing the loaded variables.
%
%    lat = loadncvar( 'mydata.nc', 'lat');
%    grid = loadncvar( 'mydata.nc', { 'lat', 'lon' } );
%
%    Note: If you wish to load the whole netcdf file into a structure use
%          struct = loadncfile (filename), instead.
%
% FORMAT   [ret, attr] = loadncvar( filename, varname )
%
% OUT   ret        Loaded variable.
% OUT   glattr     structure containting attributes of the read data.
% OUT   attr       structure containting attributes of the read data.
% IN    filename   Name of NetCDF file.
%       varname    Name of variable.

% 2010-02-02   Created by Oliver Lemke.
% 2010-10-11   Modified by Gerrit Holl.
% 2012-01-30   Modified by Gerrit Holl.
% 2012-02-23   Modified by Gerrit Holl.
% 2013-02-13   Modified by Salomon Eliasson.

function [ret, glattr, attr] = loadncvar( filename, varname )

errId = ['atmlab:' mfilename];
% UNCOMPRESS if needed
if strcmp(filename(end-2:end),'.gz')
    tmpdir = create_tmpfolder;
    c= onCleanup(@() rmdir(tmpdir,'s'));
    filename = uncompress(filename,tmpdir);
    if isempty(filename), error(errId,'Uncompressing failed'); end
end

ncid = netcdf.open (filename, 'NOWRITE');

cleanupObject = onCleanup( @()netcdf.close(ncid) );

if (nargout>1)
    glattr = loadncglobalattr(ncid);
else
    glattr = [];
end

if (nargout>2)
    attr = loadncattr(ncid,varname);
else
    attr = [];
end


if ischar(varname)
    varid = netcdf.inqVarID (ncid, varname);
    ret = nc_read_varid(ncid, varid);
elseif iscell(varname)
    if isempty(varname)
        ret = struct();
    end
    for v = varname(:).'
        try
            varid = netcdf.inqVarID (ncid, v{1});
        catch ME
            if ~isempty(regexp(ME.message,'Variable not found', 'once'))
                error(errId,'Variable ''%s'' not found in file',v{1})
            else
                ME.rethrow();
            end
        end
        ret.(genvarname(v{1})) = nc_read_varid(ncid, varid);
    end
else
    error(errId,'varname must be either of type char or cell');
end

end
