% ATMPLOT_TIMESERIES   Makes a time series plot of vertical profiles.
%
%    The function plots a series of vertical profiles as a function of
%    some quantity. The "time" coordinate can be real time, a scan number
%    or any other quantity that has a natural order. The profiles are plotted
%    without any vertical interpolation.
%
%    The profiles are given as a struct vector. Each struct must have, at 
%    least, these fields:
%       t        The time, or some other running quantity.
%       twidth   The width of the observation in units of *t*.
%       z        The altitudes, or equivalent quantity, of the observations.
%       p        The profile.
%
%    For example, profile nr. i is Ps(i).p.
%
%    The observations are assumed to be valid for the given altitudes (z),
%    during the time [t-twidth/2, t+twidth/2]. With *shadearg* = *faceted*
%    or *flat*, each value will be plotted as a rectangle uniformly colored.
%    The values are assumed to valid half-way to neighbouring points. The 
%    values for the end points are assumed to be valid outside the given
%    altitude range, over a distance equal to half the distance to the
%    neighbour point.
%
%    With *shadearg* = 'interp', the color will vary vertically in a 
%    piecewise linear manner, between the given altitudes.
%
%    The shading of the plot shall be set by the optional argument. If the
%    shading is changed later, the profiles can be displayed in an incorrect
%    manner.
%
%    The profiles can contain NaNs, which result a gap in displayed profiles.
%
%    The function performs just the plotting, without clearing the function
%    before start. All other operations, such as setting label texts or
%    setting the color scale, must be handled separately.
%
% FORMAT   atmplot_timeseries( Ps [,shadearg] )
%        
% IN    Ps         Struct vector with profile data. See further above.
% OPT   shadearg   This argument is passed to *shading*. If not given, or 
%                  empty, no call of *shading is done. If no shading is set
%                  before the call of this function, the shading will be 
%                  'faceted'.

% 2002-12-11   Created by Patrick Eriksson.


function atmplot_timeseries(Ps,shadearg)


%=== Basic ckeck of input
%
rqre_nargin( 1, nargin );
%
if nargin < 2
  shadearg = 'faceted';
end


%=== Check that the needed fields exist
%
if ~isfield(Ps,'t')  |  ~isfield(Ps,'twidth')  |  ...
   ~isfield(Ps,'z')  |  ~isfield(Ps,'p')
  serr = sprintf( ['The struct array Ps must have (at least) the fields:\n',...
                                              '   t\n   twidth\n   z\n   p'] );
  error( serr );
end


%=== Loop the profiles, check data and plot
%
for ip = 1: length( Ps )
  %
  n = length( Ps(ip).z );
  %
  if n ~= length( Ps(ip).p )
    serr = sprintf( ['The lengths of vector z and p differ for profile ', ...
                                                                'nr %d'], ip );
    error( serr );
  end
  %
  if n
    %
    t = Ps(ip).t;
    w = Ps(ip).twidth;
    %
    if ~isscalar(w)  |  w <= 0
      serr = sprintf( ['The time widths must be scalars > 0, but this not ',...
                                           'the case for profile nr %d'], ip );
      error( serr );
    end

    %- Flat and faceted shading:
    if ~strcmp( shadearg, 'interp' )
      y = vec2col( Ps(ip).z );
      y = [ y(1)-(y(2)-y(1))/2; y(1:n-1)+diff(y)/2; y(n)+(y(n)-y(n-1))/2 ];
      %
      %- A special solution is needed if not NaNs shall make the color 
      %- rectangle for two altitudes blank.
      z      = vec2col(  Ps(ip).p );
      nns    = find( isnan( z ) );
      z(nns) = z(1);
      z      = [ z; z(n) ];
      %
      n = n + 1;  % As there must be a dummy point to give end for last point

    %- Interp shading
    else
      y = vec2col( Ps(ip).z );
      z = vec2col(  Ps(ip).p );
      nns = [];
    end

    X = repmat( [t-w/2 t+w/2], n, 1 );
    Y = repmat( y, 1, 2 );
    Z = repmat( z, 1, 2 );
    %
    h=surface( X, Y, Z );

    if ~isempty( nns )
      c = get( h, 'CData' );
      c(nns,:) = NaN;
      set( h, 'CData', c );
    end

  end
end


%=== Set shading
%
shading( shadearg );
