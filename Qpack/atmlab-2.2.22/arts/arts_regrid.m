% ARTS_REGRID   Regridding of atmospheric fields
%
%   Mimics the interpolation done in ARTS. For example, log(p) is used as
%   vertical coordinate. 
%
%   There are two options to specify grids, valid for both Q1 and Q2.
%   The first option is that Q is a structure, including the fields 
%   P_GRID, LAT_GRID and LON_GRID. 
%   The second option is that Q is an ArrayOfGrids, where the first
%   grid is taken as p_grid etc.
%
%   Grids for dimensions not used can be left out.
%
%   This function operates just with the internal grids (P_GRID, LAT_GRID and
%   LON_GRID), and can not be used to for interpolation considering LAT_TRUE
%   and LON_TRUE.
%
%   The actual interpolation is made by gridinterp, with *extrap* set to
%   true. That is, "extrapolation" following arts retrieval grids is applied
%   throughout.
%
% FORMAT   F = arts_regrid( dim, Q1, F0, Q2 )
%        
% OUT   F     Interpolated field.
% IN    dim   Atmospheric dimensionality.
%       Q1    Original grids. See further above.
%       F0    Field to interpolate.
%       Q2    New grids. See further above.

% 2006-08-18   Created by Patrick Eriksson


function F = arts_regrid( dim, Q1, F0, Q2 )

%= Check input                                                   %&%
%                                                                %&%
rqre_nargin(4,nargin);                                           %&%
%                                                                %&%
rqre_alltypes( dim, {@istensor0,@iswhole} );                     %&%
rqre_in_range( dim, 1, 3 );                                      %&%


grids1 = extract_grids( dim, Q1, 'Q1' );
grids2 = extract_grids( dim, Q2, 'Q2' );


F = gridinterp( grids1, qarts_get(F0), grids2, 'linear', true );

return

function grids = extract_grids( dim, Q, qname )

if iscell(Q)
  %
  grids = Q;
  grids{1} = -log( grids{1} );
  
elseif isstruct(Q)
  %                                                             %&%
  rqre_field( Q, {'P_GRID'}, qname );                           %&%
  %
  grids{1} = -log( qarts_get( Q.P_GRID ) );

  if dim == 2
    %                                                           %&%
    rqre_field( Q, {'LAT_GRID'}, qname );                       %&%
    %
    grids{2} = qarts_get( Q.LAT_GRID );

  elseif dim == 3
    %                                                           %&%
    rqre_field( Q, {'LAT_GRID'}, qname );                       %&%
    rqre_field( Q, {'LON_GRID'}, qname );                       %&%
    %
    grids{2} = qarts_get( Q.LAT_GRID );
    grids{3} = qarts_get( Q.LON_GRID );
  end
else                                                            %&%
  error( 'Unknown choice for Q.' );                             %&%
end
