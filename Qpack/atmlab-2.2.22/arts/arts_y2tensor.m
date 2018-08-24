% ARTS_Y2TENSOR   Rearrange a measurement vector to a tensor
%
%    ARTS returns the data as a single vector, *y*. This function rearrange
%    the data into a 4D tensor *Y*. The dimensions of the tensor are:
%       [ frequency, polarisation, line-of-sight, measurement block ]
%
%    The number of frequencies, polarisations, line-of-sights and
%    measurement blocks must be specified. However, if the size of a
%    dimension is set to -1, an automatic selection is made (to match lenthn
%    of *y*). Of course, -1 can only be set for a single dimension.
%
% FORMAT   Y = arts_y2tensor(y,nf[,npol,nlos,nblock])
%        
% OUT   Y        The data in *y* as a tensor with size [nf,npol,nlos,nblock].
% IN    y        Measurement vector
%       nf       Number of frequencies.
% OPT   npol     Number of polarisations. Default is 1.
%       nlos     Number of line-of-sights. Default is 1.
%       nblock   Number of measurement blocks. Default is 1.

% 2011-08-29   Created by Patrick Eriksson.

function Y = arts_y2tensor(y,nf,varargin)
%
[npol,nlos,nblock] = optargs( varargin, { 1, 1, 1 } );


%- Automatic detection of length
%
ny = length(y);
%
if npol < 0
  npol = ny / (nf*nlos*nblock);
elseif nlos < 0
  nlos = ny / (nf*npol*nblock);
elseif nlos < 0
  nblock = ny / (nf*npol*nlos);
end  


% Checks:                                                                  %&%
if nf < 1  |  ~iswhole(nf)                                                 %&%
  error( 'The argument *nf* must be an integer >= 1.' );                   %&%
end                                                                        %&%
if npol < 1  |  ~iswhole(npol)                                             %&%
  error( 'The argument *npol* must be an integer >= 1.' );                 %&%
end                                                                        %&%  
if nlos < 1  |  ~iswhole(nlos)                                             %&%
  error( 'The argument *nlos* must be an integer >= 1.' );                 %&%
end                                                                        %&%  
if nblock < 1  |  ~iswhole(nblock)                                         %&%
  error( 'The argument *nblock* must be an integer >= 1.' );               %&%
end                                                                        %&%
if nf*npol*nlos*nblock ~= ny                                               %&%
  error( 'The product nf*npol*nlos*nblock doesnot match length of *y*.' ); %&%
end                                                                        %&%


% Rearrange data
%
Y = zeros( nf, npol, nlos, nblock );
%
for i = 1 : npol
  Y(:,i,:,:) = reshape( y(i:npol:end), [ nf, 1, nlos, nblock ] );
end
