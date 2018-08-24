function global_attributes = loadncglobalattr( ncfile )
%% loadncglobalattr
%
% PURPOSE
%         Load the global attributes of a netcdf file
%
% IN
%       ncfile          is either a string filename 
%                       OR
%                       an id of an already open netcdf file
% OUT
%       global_attributes       struct
%
% Salomon Eliasson
% $Id: loadncglobalattr.m 8189 2013-02-11 14:06:53Z olemke $

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

[~,nvars,ngatts] = netcdf.inq(ncid);

global_attributes = struct();
for i = 0:ngatts-1
   attname = netcdf.inqAttName (ncid, netcdf.getConstant('GLOBAL'), i);
   global_attributes.(genvarname(attname)) = ...
       netcdf.getAtt (ncid, netcdf.getConstant('GLOBAL'), attname);
end

