% LOADNCFILE   Loads a NetCDF file into a structure.
%
%    The function enables direct loading of a whole NetCDF file into
%    a structure.
%
%    Global attributes are stored in ret.global_attributes.(attname)
%    Variable attributes are stored in ret.attributes.(varname).(attname)
%    Variables are stored in ret.(varname)
%
% FORMAT   ret = loadncfile( filename )
%        
% OUT   ret        Loaded NetCDF file structure.
% IN    filename   Name of NetCDF file. (can be gzipped)

% 2013-02-08   Updated by Salomon
% 2010-02-10   Created by Oliver Lemke.

function ret = loadncfile( filename )

errId = ['atmlab:' mfilename];
% UNCOMPRESS if needed
if strcmp(filename(end-2:end),'.gz')
	tmpdir = create_tmpfolder;
    c= onCleanup(@() rmdir(tmpdir,'s'));
	filename = uncompress(filename,tmpdir);
    if isempty(filename), error(errId,'Uncompressing failed'); end
end
  
ncid = netcdf.open (filename, 'NOWRITE');

cleanupObject = onCleanup(@() netcdf.close (ncid));

ret.global_attributes =  loadncglobalattr( ncid );

[~,nvars] = netcdf.inq(ncid);

for i = 0:nvars-1
   [varname, ~, ~, natts] = netcdf.inqVar (ncid, i);
   svarname = genvarname(varname);
   ret.(svarname) = nc_read_varid(ncid,i);
   for j = 0:natts-1
       attname = netcdf.inqAttName (ncid, i, j);
       ret.attributes.(svarname).(genvarname(attname)) = ...
           netcdf.getAtt (ncid, i, attname);
   end 
end

if (which('netcdf.inqGrps'))
	grpids = netcdf.inqGrps (ncid);
	for gid = grpids
        grp = read_group(ncid, gid);
    	ret = catstruct(ret, grp);
	end
else
    warning(errId, ...
        'This Matlab version does not support NetCDF groups.');
end

end

function grp = read_group(~, gid)

varids = netcdf.inqVarIDs(gid);
chgrpids = netcdf.inqGrps(gid);
grpname = genvarname(netcdf.inqGrpName(gid));
grp.(grpname)=struct();
for i = varids
    [varname, ~, ~, natts] = netcdf.inqVar (gid, i);
    svarname = genvarname(varname);
    grp.(grpname).(svarname) = netcdf.getVar (gid, i);
    for j = 0:natts-1
        attname = netcdf.inqAttName (gid, i, j);
        grp.(grpname).attributes.(svarname).(genvarname(attname)) = ...
            netcdf.getAtt (gid, i, attname);
    end
end
for chgid = chgrpids
    childgroup = read_group(gid, chgid);
    grp.(grpname) = catstruct(grp.(grpname), childgroup);
end


end