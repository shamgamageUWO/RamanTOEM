% ADDNCATTRIBUTES   Add global attributes to a NetCDF file.
%
%    Adds the given global attributes to a NetCDF file.
%
%    e.g.: addncattributes(ncid, struct('attr1', 'value1', 'attr2', 2))
%
% FORMAT   addncattributes(ncid, attributes)
%        
% IN    ncid        Name of NetCDF file.
% IN    attributes  Structure with name/value pairs.

% 2010-07-06   Created by Oliver Lemke.

function addncattributes (ncid, attributes)

fields = fieldnames(attributes);
for f = fields'
    netcdf.putAtt (ncid, netcdf.getConstant('GLOBAL'), ...
                   char(f{1}), attributes.(f{1}));
end

