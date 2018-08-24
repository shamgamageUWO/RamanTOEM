% NC_READ_VARID   Reads a variable by varid from a netcdf id.
%
%    Function used by loadncfile and loadncvar to read the actual
%    variable from the netcdf file. Only used internally by ncloadvar and
%    ncloadfile.
%
% FORMAT   ret = nc_read_varid( ncid, varid )
%        
% OUT   ret        Variable contents.
% IN    ncid       ID of NetCDF file.
% IN    varid      Variable ID.

% 2012-02-09   Created by Oliver Lemke.

function ret = nc_read_varid(ncid, varid)
    [varname, xtype, dimids, natts] = netcdf.inqVar(ncid, varid);
    skipread = false;
    dims = [];
    for dimid = dimids
        [dimname, dimlength] = netcdf. inqDim(ncid, dimid);
        dims = [dims dimlength];
        if (~dimlength) skipread = true; end
    end
    if (skipread)
        ret = zeros(dims);
    else
        ret = netcdf.getVar (ncid, varid);
    end
end
