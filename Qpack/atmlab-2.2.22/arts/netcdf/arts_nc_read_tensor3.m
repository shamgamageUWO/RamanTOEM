% ARTS_NC_READ_TENSOR3   Read Tensor3 from ARTS NetCDF file.
%
%    Reads a Tensor3 from a NetCDF file saved with Arts.
%
% FORMAT   ret = arts_nc_read_tensor3(filename)
%        
% OUT   ret      Tensor3
% OUT   gattr    Global attributes
%       
% IN    filename Name of NetCDF input file.

% 2010-02-02   Created by Oliver Lemke.

function [ret, gattr] = arts_nc_read_tensor3 (filename)

gattr = loadncglobalattr2cell (ncid);

v = loadncvar (filename, 'Tensor3');
ret = permute (v, [3 2 1]);
