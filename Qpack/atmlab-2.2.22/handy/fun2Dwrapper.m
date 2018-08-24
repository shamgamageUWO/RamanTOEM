% FUN2DWRAPPER   Wrapper around function only handle 2D data
%
%   As *fun1dwrapper* but for application of functions operating on
%   matrix input.
%
%   The selected dimension (*dim*) will be dimension when calling the
%   function of *funhandle*.
%
%   Example: To calculate the sum of "matrix blocks" of A:
%      funhandle = @(x) sum(sum(x));
%      Z = fun2Dwrapper(X,1,funhandle,'X');
%
% FORMAT   Y = fun2Dwrapper(X,dim,funhandle,varargin)
%        
% OUT   Y           Output data.
% IN    X           Input data. Dimensionalities <= 6 are handled.
%       dim         The dimension along which *funhandle* shall be applied.
%       funhandle   Function handle.
%       varargin    Function arguments. The vector argument matching *X* is
%                   specified by giving the string 'X*'. See further above.

% 2007-11-09   Created by Patrick Eriksson.


function Y = fun2Dwrapper(X,dim,funhandle,varargin)
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
%rqre_datatype( X, @isfunction_handle );                                   %&%
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

  
for i6 = 1 : size(X,6)
for i5 = 1 : size(X,5)
for i4 = 1 : size(X,4)
for i3 = 1 : size(X,3)
  
  varargin{ix} = X(:,:,i3,i4,i5,i6);
  
  y = funhandle( varargin{:} );
  
  if i3 == 1 & i4 == 1 & i5 == 1 & i6 == 1
    s    = size(X);
    s(1) = size(y,1);
    s(2) = size(y,2);
    Y    = zeros( s );
  end
  
  Y(:,:,i3,i4,i5,i6) = y;
  
end
end
end
end


%- Re-shift dims
%
if dim > 1
  Y = shiftdim( Y, ndims(Y)-dim+1 );
end
