% COASTLINES   Adds coast lines to your plot.
%
%    The resolution is on the 1 degree level. Thus only suitable for global 
%    plots.
%
%    Note that this function will affect the color map and a colorbar should
%    be placed before calling this function.
%
%    The optional argument *lonrange* can be used when a longitude range
%    different from [0 360] is used.
%
%    Uses the topo.mat file from the matlab demos directory.
%
% FORMAT   coastlines([lcolor,lwidth,lonrange])
%        
% OPT   lcolor   Line color. Default is [0 0 0].
%       lwidth   Line width. Default is 1.
%       lonrange Lower and upper limit for output longitudes. Default
%                is [0 360]. Must be a 360 degree range.

% 2006-03-27   Created by Patrick Eriksson (code from Mattias Ekstrom).


function coastlines(varargin)
%
[lcolor,lwidth,lonrange] = optargs( varargin, { [0 0 0], 1, [0 360] } );
                                                                         %&%
                                                                         %&%
if lonrange(2)-lonrange(1) ~= 360                                        %&%
  error('Longitude range must be 360 degrees wide.')                     %&%
end                                                                      %&%


load topo


lons = 0.5:359.5;

ind       = find( lons < lonrange(1) );
lons(ind) = lons(ind)+360;
ind       = find( lons > lonrange(2) );
lons(ind) = lons(ind)-360;

[lons,ind] = sort( lons );
%
topo       = topo(:,ind);


contour(lons,-89.5:89.5,topo,[0 0],'LineColor',lcolor,'LineWidth',lwidth);



