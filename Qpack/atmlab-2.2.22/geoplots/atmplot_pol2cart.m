% ATMPLOT_POL2CART   Plots a line given in polar coordinates.
%
%     The given points are plotted to current axes. No hold commando is 
%     applied. Plot symbol, and additional plot arguments, can be selected
%     by adding arguments after *lat*. 
%
%     Plotting is only performed if there are no output arguments. With
%     output arguments, the function can be used for conversion inside
%     other plotting functions.
%
%     A scalar as input for either radius or latitude means that that value
%     shall be applied for all points. If both the radii and latitudes are
%     given as vectors, the both vectors must have the same size.
%
%     Latitude 0 is placed along the horisontal (x) axis. Latitude 90 is
%     in the upward vertical direction.
%
%     To draw a heart:
%        atmplot_pol2cart( linspace(0,9,91), 90:2:270, 'r-' );
%        hold on
%        atmplot_pol2cart( linspace(0,9,91), 90:-2:-90, 'r-' );
%
% FORMAT   [x,y] = atmplot_pol2cart( r, lat [, varargin ] )
%        
% OUT   x          The x-coordinate for the line to draw.
%       y          The y-coordinate for the line to draw.
% IN    r          A single radius or a vector of radii.
%       lat        A single latitude, or a vector of latitides.
% OPT   varargin   Arguments that are passed to the *plot* commando.

% 2002-12-22   Created by Patrick Eriksson.


function [x,y] = atmplot_pol2cart( r, lat, varargin )


%= Input
%
rqre_nargin( 2, nargin );


DEG2RAD = constants( 'DEG2RAD' );


[x,y] = pol2cart( DEG2RAD * lat, r );


if ~nargout

  plot( x, y, varargin{:} );

end

