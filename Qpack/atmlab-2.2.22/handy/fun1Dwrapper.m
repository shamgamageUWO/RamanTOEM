% FUN1DWRAPPER   Wrapper around function only handle 1D data
%
%   Applies a "vector operation" on multi-dimensional data. That is, the given
%   function is applied on each vector of *X* and the result is assemled for
%   a function operating on the complete *X*. The vectors can be extracted
%   in dimension (selected by *dim*). The "vector operation" can be a
%   function that takes an arbitrary number of input variables.
%
%   Assume that you have a function z = a(x,y) that performs the operation you
%   want, but a is poorly implented and allows only x to be vector. The
%   function a can be be applied along dimension 2 of a numeric variable X,
%   for some y, as
%      Z = fun1Dwrapper(X,2,@a,'X',y);
%   If a is defined as z = a(y,x) this function is used as
%      Z = fun1Dwrapper(X,2,@a,y,'X');
%
%   The function match *funhandle* can take any number of input variables.
%
%   Example: To randomly permute each vector along dimension 1 of X (where each
%   vector is permuted seperately): 
%      funhandle = @(x) x(randperm(length(x)));
%      Z = fun1Dwrapper(X,1,funhandle,'X');
%
% FORMAT   Y = fun1Dwrapper(X,dim,funhandle,varargin)
%        
% OUT   Y           Output data.
% IN    X           Input data. Dimensionalities <= 6 are handled.
%       dim         The dimension along which *funhandle* shall be applied.
%                   Should work as dim in e.g. *sum*.
%       funhandle   Function handle.
%       varargin    Function arguments. The vector argument matching *X* is
%                   specified by giving the string 'X*'. See further above.

% 2007-11-09   Created by Patrick Eriksson.


function Y = fun1Dwrapper(X,dim,funhandle,varargin)
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

  
for i6 = 1 : size(X,6)
for i5 = 1 : size(X,5)
for i4 = 1 : size(X,4)
for i3 = 1 : size(X,3)
for i2 = 1 : size(X,2)
  
  varargin{ix} = X(:,i2,i3,i4,i5,i6);
  
  y = funhandle( varargin{:} );
  
  if i2 == 1 & i3 == 1 & i4 == 1 & i5 == 1 & i6 == 1
    s    = size(X);
    s(1) = size(y,1);
    Y    = zeros( s );
  end
  
  Y(:,i2,i3,i4,i5,i6) = y;
  
end
end
end
end
end


%- Re-shift dims
%
if dim > 1
  Y = shiftdim( Y, ndims(Y)-dim+1 );
end
