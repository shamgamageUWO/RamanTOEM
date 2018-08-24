function save_nc_gmt_input (filename, data, lat, lon)
%
% SAVE_NC_GMT_INPUT Write ungridded data for GMT input.
%
% Write ungridded data for GMT input to a netcdf file. Used for nearneighbor and
% others as a replacement for ascii input.
%
% IN    filename Name of NetCDF file.
% IN    data          vector variable.
% IN    lat           vector variable.
% IN    lon           vector variable.
%
% 2010-03-04   Created by Oliver Lemke

if ~isequal(numel(data),numel(lon),numel(lat))
    error('gmtlab:input','This data is expected to be ungridded')
end

if islogical(data)
    data = int8(data);
end

if exist('OCTAVE_VERSION','builtin')
  save_nc_gmt_input_octave (filename, data, lat, lon);
  return;
end;

ncid = netcdf.create (strrep(filename,'~',getenv('HOME')), 'NC_CLOBBER');

len = netcdf.defDim (ncid, 'numel', length(data));


varid1 = netcdf.defVar (ncid, 'x', 'double', len);
varid2 = netcdf.defVar (ncid, 'y', 'double', len);
varid3 = netcdf.defVar (ncid, 'z', gmt_get_nctype(data), len);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid1, lon);
netcdf.putVar (ncid, varid2, lat);
netcdf.putVar (ncid, varid3, data);

netcdf.close (ncid);

function save_nc_gmt_input_octave (filename, data, lat, lon)
%% save_nc_gmt_input_octave
% Octave workaround to save_nc_gmt_input.
%
% Octave uses other netcdflibraries
% 

nc = netcdf (strrep(filename,'~',getenv('HOME')), 'c');

nc('numel') = length(data);

nc{'x'} = ncdouble ('numel');
nc{'y'} = ncdouble ('numel');
if strcmpi(gmt_get_nctype(data),{'SHORT','INT','UBYTE','USHORT','UINT','INT64','UINT64'})
    nc{'z'} = ncint ('numel');
elseif strcmpi(gmt_get_nctype(data),{'FLOAT'})
    nc{'z'} = ncfloat ('numel');
elseif strcmpi(gmt_get_nctype(data),{'DOUBLE'})
    nc{'z'} = ncdouble ('numel');
elseif strcmpi(gmt_get_nctype(data),{'BYTE'})
    nc{'z'} = ncbyte ('numel');
end
nc{'x'}(:) = lon;
nc{'y'}(:) = lat;
nc{'z'}(:) = data;

close (nc);
