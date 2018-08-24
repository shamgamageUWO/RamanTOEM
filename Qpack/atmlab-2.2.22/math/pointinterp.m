% INTERPD  Point interpolation of 1D-5D data
%
%    Atmlabs function for interpolation of data to a set of points. This is
%    basically an interface to to the standard interp1 and interpn functions.
%
%    For "grid interpolation", see accompanying function *gridinterp*.
%
%    The grids of the data to be interpolated (*A*) are packed into the vector
%    array *agrids*. The interpolation points are given as a matrix where each
%    column corresponds to a dimension of *A*. Accordingly, each row in *pos*
%    gives the coordinate for an interpolation point.
%
%    The Atmlab convention of that 1D objects (including grids) are column
%    vectors is here strictly followed.
%
%    The *extrap* optional argument works here as for *gridinterp*.
%
% FORMAT   B = pointinterp(agrids,A,pos,iopt)
%        
% OUT   B        Result of interpolation. A column vector.
% IN    agrids   Grids of A, as an array of vectors.
%       A        Data to be interpolated. 
%       pos      Matrix where each row is a position.
% OPT   iopt     Interpolation option. See *interpn*. Default is 'linear'.
%       extrap   Special treatment of extrapolation. See above. 
%                Default is false.

% 2007-05-22   Created by Patrick Eriksson.


function B = pointinterp(agrids,A,pos,varargin)
%
[iopt,extrap] = optargs( varargin, { 'linear', false } );
                                                                          %&%
%- Check input                                                            %&%
%                                                                         %&%
rqre_nargin( 3, nargin )                                                  %&%
rqre_datatype( agrids, @iscell );                                         %&%
rqre_datatype( A, @isnumeric );                                           %&%
rqre_datatype( pos, @istensor2 );                                         %&%
indim  = length(agrids);
outdim = size(pos,2);
if dimens(A) > length(agrids)                                             %&%
  error( 'Dimensionality of A is higher than number of given grids.' );   %&%
end                                                                       %&%
if outdim < indim                                                         %&%
  error('There can not be fewer columns in *pos* than grids in *agrids*.');%&%
end                                                                       %&%
for d = 1 : indim                                                         %&%
  rqre_datatype( agrids{d}, @istensor1, 'Grids in *agrids*' );            %&%
  rqre_gridmatch( A, d, agrids{d} );                                      %&%
end                                                                       %&%
rqre_datatype( extrap, @isboolean );                                      %&%


%- Check a or determine a's effective dimensions
%
if extrap    % Ignore singleton dimensions
  dims = find( size( A ) > 1 );
  A    = getdims( A, dims );
else
  if outdim ~= indim                                                      %&%
    error( ['With *extrap* false, the number of columns in *pos* ',...    %&%
                'and the number of grids in *agrids* must be equal.'] );  %&%
  end                                                                     %&%
  asize = size( A );                                                      %&%
  if length(asize) < outdim  ||  any( asize(1:outdim)==1 )                %&%
    error( ['With *extrap* false there can not be any singleton ',...     %&%
                                              'dimmensions in *A*.'] );   %&%
  end                                                                     %&%
  dims = 1:outdim;
end

dim = length( dims );

if dim == 0
  %
  B = repmat( A, size(pos,1), 1 );

elseif dim == 1
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, pos(:,dims(1)) );
  else
    xi = pos(:,dims(1));
  end
  %
  B = interp1( agrids{dims(1)}, A, xi, iopt );

elseif dim == 2
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, pos(:,dims(1)) );
    yi = handle_expand( agrids{dims(2)}, pos(:,dims(2)) );
  else
    xi = pos(:,dims(1));
    yi = pos(:,dims(2));
  end
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, A, xi, yi, iopt ); 

elseif dim == 3
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, pos(:,dims(1)) );
    yi = handle_expand( agrids{dims(2)}, pos(:,dims(2)) );
    zi = handle_expand( agrids{dims(3)}, pos(:,dims(3)) );
  else
    xi = pos(:,dims(1));
    yi = pos(:,dims(2));
    zi = pos(:,dims(3));
  end
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, agrids{dims(3)}, ...
                                                      A, xi, yi, zi, iopt ); 

elseif dim == 4
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, pos(:,dims(1)) );
    yi = handle_expand( agrids{dims(2)}, pos(:,dims(2)) );
    zi = handle_expand( agrids{dims(3)}, pos(:,dims(3)) );
    ui = handle_expand( agrids{dims(4)}, pos(:,dims(4)) );
  else
    xi = pos(:,dims(1));
    yi = pos(:,dims(2));
    zi = pos(:,dims(3));
    ui = pos(:,dims(4));
  end
  %
  [xi,yi,zi,ui] = ndgrid( xi, yi, zi, ui );
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, ...
               agrids{dims(3)}, agrids{dims(4)}, A, xi, yi, zi, ui, iopt ); 

elseif dim == 5
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, pos(:,dims(1)) );
    yi = handle_expand( agrids{dims(2)}, pos(:,dims(2)) );
    zi = handle_expand( agrids{dims(3)}, pos(:,dims(3)) );
    ui = handle_expand( agrids{dims(4)}, pos(:,dims(4)) );
    vi = handle_expand( agrids{dims(5)}, pos(:,dims(5)) );
  else
    xi = pos(:,dims(1));
    yi = pos(:,dims(2));
    zi = pos(:,dims(3));
    ui = pos(:,dims(4));
    vi = pos(:,dims(5));
  end
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, agrids{dims(3)}, ...
               agrids{dims(4)}, agrids{dims(5)}, A, xi, yi, zi, ui, vi, iopt ); 

else                                                             %&%
  error( 'Interpolation above 5D is not handled.' );             %&%
end

return


%---
function xi = handle_expand(x,xi)
  %
  v1 = min( x );
  i1 = find( xi<v1 );
  %
  v2 = max( x );
  i2 = find( xi>v2 );
  %
  if ~isempty(v1) 
    xi(i1) = v1;
  end
  %
  if ~isempty(v2) 
    xi(i2) = v2;
  end
  %
return
