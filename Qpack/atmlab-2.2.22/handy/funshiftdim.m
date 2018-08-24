% FUNSHIFTDIM   Applies a function along a non-standard dimension
%
%   Allows the application of a function that only works along a fixed
%   dimension. The function can take an arbitrary number of input variables.
%
%   Example: To make a 1D interpolation along dimension 2 of A:
%      A = randn(3,5,4);
%      Y = funshiftdim(A,2,@interp1,1:5,'X',1.5:1:4.5);
%
% FORMAT   Y = funshiftdim(X,dim,funhandle,varargin)
%        
% OUT   Y           Output data.
% IN    X           Input data. Dimensionalities <= 6 are handled.
%       dim         The dimension along which *funhandle* shall be applied.
%       funhandle   Function handle.
%       varargin    Function arguments. The argument matching *X* is
%                   specified by giving the string 'X*'. See further above.

% 2007-11-09   Created by Patrick Eriksson.


function Y = funshiftdim(X,dim,funhandle,varargin)
%
if nargin < 4
  varargin = { 'X' };
end
%
ix = find( strcmp(varargin,'X') );
                                                                          %&%
                                                                          %&%  
%- Check input                                                            %&%
%                                                                         %&%
rqre_nargin( 3, nargin );                                                 %&%
%                                                                         %&%
rqre_datatype( X, @isnumeric );                                           %&%
rqre_alltypes( dim, {@istensor0,@iswhole} );                              %&%
rqre_in_range( dim, 1, 6 );                                               %&%
if dim > dimens(X)                                                        %&%
  error( 'The selected dimension (*dim*) must be <= dimens(X).' );        %&%
end                                                                       %&%
%                                                                         %&%
rqre_datatype( X, @isfunction_handle );                                   %&%
%                                                                         %&%
if isempty(ix)                                                            %&%
  error( 'One of the varargin arguments must be the string ''X''.' );     %&%
elseif length(ix) > 1                                                     %&%
  error( 'Found several ''X'' among the varargin arguments.' );           %&%
end                                                                       %&%


%- Move selected dimension to front
%
if dim > 1
 X = shiftdim( X, dim-1 );
end

  
varargin{ix} = X;
  
Y = funhandle( varargin{:} );
  

%- Re-shift dims
%
if dim > 1
  Y = shiftdim( Y, ndims(Y)-dim+1 );
end
