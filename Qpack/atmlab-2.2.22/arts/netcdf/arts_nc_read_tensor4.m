% ARTS_NC_READ_TENSOR4   Read Tensor4 from ARTS NetCDF file.
%
%    Reads a Tensor4 from a NetCDF file saved with Arts.
%
% FORMAT   ret = arts_nc_read_tensor4(filename)
%        
% OUT   ret      Tensor4
% OUT   gattr    Global attributes
%       
% IN    filename Name of NetCDF input file.

% 2010-02-02   Created by Oliver Lemke.

function [ret, gattr] = arts_nc_read_tensor4 (filename)

gattr = loadncglobalattr (filename);

v = loadncvar (filename, 'Tensor4');
d = size(v);
ret = permute (reshape (v, [d(2) d(3) d(4) d(1)]), [4 3 2 1]);
