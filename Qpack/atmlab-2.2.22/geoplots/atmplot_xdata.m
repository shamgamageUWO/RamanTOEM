% ATMPLOT_XDATA   A general function to plot retrieval data
%
%    The function aims at provide simple plotting of 1D or 2D data coming
%    naturally as a vector, as when doing retrievals. 2D data are then
%    assumed to be stored as [p1;p2;p3 ..] where p1 is the "profile" for
%    position 1 along second dimension. For atmospheric profiles dimension
%    1 is typically pressure or altitutde, and dimension 2 e.g. latitude.
%
%    Default is to plot dimension 1 in the x-direction. This can be changed
%    by the optional argument *rot*. A "rotation" is also performed if
%    gnames{1} starts as 'Pressure' or 'Altitude'. For 'Pressure' the y-axis
%    is made logarithmic and direction reversed.
%
%    2D data are plotted with *rectgridplot*.
%
% FORMAT   ha = atmplot_xdata(x,xname,g,gnames[,fname,shadtype,rot])
%        
% OUT   ha
% IN    x          Data vector to be plotted.
%       xname      Data description. To be used for xlabel or ylabel. Not 
%                  used for 2D.
%       g          Data grid(s) as a cell array of vectors. For 1D a plain 
%                  vector is also accaepted.
%       gnames     Decscription of grids, as a cell array of strings. For 1D
%                  a plain string is alos accepted.
% OPT   fname      Figure name. That is, title text. Default is [].
%       shadtype   Type of shading for 2D figures. See *rectgridplot* for
%                  options. Default is 'interp'.
%       rot        See above.

% 2007-03-07   Created by Patrick Eriksson.


function ha = atmplot_xdata(x,xname,g,gnames,varargin)
%
[fname,shadtype,rot] = optargs( varargin, { [], 'interp', 0 } );
  
  
%--- Check input
%
rqre_datatype( x, {@isvector,@ismatrix} );
%
if ischar(xname)
  %
elseif iscellstr(xname)  & length(xname)==1
  xname = xname{1};
else
  error( ['Input variable *xname* must be a string or a cell array ', ...
          'of strings with length 1.'] )
end
%
if isnumeric(g)  &  isvector(g)
  tmp = g;
  g   = [];
  g{1} = tmp;
  clear tmp
elseif iscell(g)  &  isvector(g{1})
  %
else
  error( ['Input variable *g* must be a vector or a cell array ', ...
          'of vectors.'] )
end
%
if ischar(gnames)
  tmp       = gnames;
  gnames    = [];
  gnames{1} = tmp;
  clear tmp
elseif iscellstr(gnames)
  %
else
  error( ['Input variable *gnames* must be a string or a cell array ', ...
          'of strings'] )
end
%
if length(g) ~= length(gnames)
  error( 'Different number of implied data dimensions in *g* and *gnames*.' );
end



dim = length(g);


%--- 1D
%
if dim == 1
  
  if size(x,1) ~= length(g{1})
    error( 'Size of *x* and grid length do not match.' )
  end
  
  %- Pressure
  if strncmp( gnames{1}, 'Pressure', 8 )
    semilogy( x, g{1} );
    set( gca, 'Ydir', 'rev' );
    xlabel( xname )
    ylabel( gnames{1} );

  %- Selected rotation or altitude
  elseif rot  |  strncmp( gnames{1}, 'Altitude', 8 )
    plot( x, g{1} );
    xlabel( xname )
    ylabel( gnames{1} );
    
  else
    plot( g{1}, x );
    xlabel( gnames{1} );
    ylabel( xname )
  end
 

%--- 2D
%
elseif dim == 2
  if size(x,1) ~= length(g{1})*length(g{2})
    error( 'Size of *x* and product of grid lengths do not match.' )
  end

  F = reshape( x, length(g{1}), length(g{2}) );
  x = grid2edges( g{1} );
  y = grid2edges( g{2} );
  
  %- Pressure
  if strncmp( gnames{1}, 'Pressure', 8 )
    rectgridplot( y, x, F', shadtype );
    set( gca, 'Yscale', 'log' );
    set( gca, 'Ydir', 'rev' );
    xlabel( gnames{2} )
    ylabel( gnames{1} );

  %- Selected rotation or altitude
  elseif rot  |  strncmp( gnames{1}, 'Altitude', 8 )
    rectgridplot( y, x, F', shadtype );
    xlabel( gnames{2} )
    ylabel( gnames{1} );
    
  else
    rectgridplot( x, y, F, shadtype );
    xlabel( gnames{1} )
    ylabel( gnames{2} );
  end
  
else
  error( 'Only 1D and 2D are handled' );
end


if ~isempty( fname )
  title( fname )
end


ha = gca;