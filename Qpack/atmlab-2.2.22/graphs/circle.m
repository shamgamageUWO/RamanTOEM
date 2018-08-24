% CIRCLE   Generate a circle
%
%    To draw a circle:
%       [x,y] = circle(1,1,1,30);
%       line(x,y)
%
% FORMAT   [x,y] = circle(x0,y0,r,n)
%        
% OUT   x   x coordinates
%       y   y coordinates
% IN    x0  x coordinate for circle centre 
%       y0  y coordinate for circle centre 
%       r   circle radius
%       n   number of brake points

% 2005-12-06   Created by Patrick Eriksson.


function [x,y] = circle(x0,y0,r,n)

alpha = linspace( 0, 2*pi, n );

x = x0 + r * cos( alpha );
y = y0 + r * sin( alpha );
